/*This class will make the callout to the college football API and return the bowl game data for a specified year.
*/
public class CollegeFootballCallout {

    @AuraEnabled
    public static void importBowlGames(Id yearId) {
        
        Year__c year = [SELECT Id, Name FROM Year__c WHERE Id = :yearId LIMIT 1];
        List<Bowl_Game__c> bowlGamesToCreate = new List<Bowl_Game__c>();
        List<CollegeFootballWrapper> wrapper = makeCallout(yearId);

        for(CollegeFootballWrapper bowlGame : wrapper){
            Bowl_Game__c bg = new Bowl_Game__c();
            bg.Name = bowlGame.notes.left(80); //the name field can only be 80 characters long
            bg.Year__c = yearId;
            bg.Game_ID__c = String.valueOf(bowlGame.id);
            bg.Home_Team__c = bowlGame.home_team;
            bg.Home_Points__c = bowlGame.home_points;
            bg.Away_Team__c = bowlGame.away_team;
            bg.Away_Points__c = bowlGame.away_points;
            bg.Start_Date__c = bowlGame.start_date;
            bg.Completed__c = bowlGame.completed;
            bowlGamesToCreate.add(bg);
        }
        System.debug('Number Of Bowl Games: ' + wrapper.size());
        try {
            insert bowlGamesToCreate;
            year.Bowl_Games_Imported__c = true;
            update year;
        } catch (Exception e) {
            System.debug('An error occurred when attempting to retrieve bowl games: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static void updateBowlGames(Id yearId){

        List<Bowl_Game__c> bowlGamesToUpdate = new List<Bowl_Game__c>();
        List<Bowl_Game__c> existingBowlGames = [SELECT Id, Name, Year__c, Game_ID__c, Home_Team__c, Home_Points__c, Away_Team__c, Away_Points__c, Start_Date__c, Completed__c FROM Bowl_Game__c WHERE Year__c = :yearId];
        Map<String, Bowl_Game__c> existingBowlGamesMap = new Map<String, Bowl_Game__c>();
        for(Bowl_Game__c bg : existingBowlGames) {
            existingBowlGamesMap.put(bg.Game_ID__c, bg);
        }

        List<CollegeFootballWrapper> wrapper = makeCallout(yearId);

        for(CollegeFootballWrapper bowlGame : wrapper){
            Bowl_Game__c bg = new Bowl_Game__c();
            bg.Id = existingBowlGamesMap.get(String.valueOf(bowlGame.id)).Id;
            bg.Home_Points__c = bowlGame.home_points;
            bg.Away_Points__c = bowlGame.away_points;
            bg.Completed__c = bowlGame.completed;
            bowlGamesToUpdate.add(bg);
        }
        try {
            update bowlGamesToUpdate;
        } catch (Exception e) {
            System.debug('An error occurred when attempting to update bowl games: ' + e.getMessage());
        }
    }

    public static List<CollegeFootballWrapper> makeCallout(Id yearId) {

        Year__c year = [SELECT Id, Name FROM Year__c WHERE Id = :yearId LIMIT 1];
        HttpRequest req = new HttpRequest();
        req.setHeader('Accept', 'application/json');
        req.setHeader('Content-Type', 'application/json');
        req.setMethod('GET');
        Http http = new Http();

        String baseEndpoint = 'callout:CollegeFootballAPI' + '/games?seasonType=postseason&year=' + year.Name + '&division=fbs';
        req.setEndpoint(baseEndpoint);
        HttpResponse res = http.send(req);

        //returns in the format of List<CollegeFootballWrapper>
        return CollegeFootballWrapper.parse(res.getBody());
    }
}