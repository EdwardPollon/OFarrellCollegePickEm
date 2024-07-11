public class CollegeFootballCallout {
    public static void collegeFootballCallout() {
        
        HttpRequest req = new HttpRequest();
        req.setHeader('Accept', 'application/json');
        req.setHeader('Content-Type', 'application/json');
        req.setMethod('GET');
        Http http = new Http();

        String baseEndpoint = 'callout:CollegeFootballAPI' + '/games?seasonType=postseason&year=2023&division=fbs';
        List<Bowl_Game__c> bowlGamesToCreate = new List<Bowl_Game__c>();
        List<Year__c> years = [SELECT Id FROM Year__c WHERE Name = '2023'];

        req.setEndpoint(baseEndpoint);
        HttpResponse res = http.send(req);
        List<CollegeFootballWrapper> wrapper = CollegeFootballWrapper.parse(res.getBody());

        for(CollegeFootballWrapper bowlGame : wrapper){
            Bowl_Game__c bg = new Bowl_Game__c();
            bg.Name = bowlGame.notes;
            bg.Year__c = years[0].Id;
            bg.Game_ID__c = String.valueOf(bowlGame.id);
            bg.Home_Team__c = bowlGame.home_team;
            bg.Home_Points__c = bowlGame.home_points;
            bg.Away_Team__c = bowlGame.away_team;
            bg.Away_Points__c = bowlGame.away_points;
            bowlGamesToCreate.add(bg);
        }
        System.debug('Number Of Bowl Games: ' + wrapper.size());
        insert bowlGamesToCreate;
    }
}