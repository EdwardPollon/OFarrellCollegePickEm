/*This class will make the callout to the college football API and return the bowl game data for a specified year.
*/
public class CollegeFootballCallout {

    @AuraEnabled
    public static void importBowlGames(Id yearId) {
        
        HttpRequest req = new HttpRequest();
        req.setHeader('Accept', 'application/json');
        req.setHeader('Content-Type', 'application/json');
        req.setMethod('GET');
        Http http = new Http();

        Year__c year = [SELECT Id, Name FROM Year__c WHERE Id = :yearId LIMIT 1];
        String baseEndpoint = 'callout:CollegeFootballAPI' + '/games?seasonType=postseason&year=' + year.Name + '&division=fbs';
        List<Bowl_Game__c> bowlGamesToCreate = new List<Bowl_Game__c>();

        req.setEndpoint(baseEndpoint);
        HttpResponse res = http.send(req);
        List<CollegeFootballWrapper> wrapper = CollegeFootballWrapper.parse(res.getBody());

        for(CollegeFootballWrapper bowlGame : wrapper){
            Bowl_Game__c bg = new Bowl_Game__c();
            bg.Name = bowlGame.notes;
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
    public static void updateBowlGames(){

    }
}