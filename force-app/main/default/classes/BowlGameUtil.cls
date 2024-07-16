public with sharing class BowlGameUtil {

    public static void sumEarnedPoints(List<Bowl_Game__c> newBowlGames, Map<Id,Bowl_Game__c> oldBowlGamesMap) {
        Boolean executeSumCalculation = false;
        for(Bowl_Game__c bg : newBowlGames) {
            if(bg.Completed__c == true && oldBowlGamesMap.get(bg.Id).Completed__c == false){
                executeSumCalculation = true;
                break;
            }
        }
        if(executeSumCalculation){
            Boolean noGamesLeft = false;
            List<Year_Participated__c> yearsParticipatedToUpdate = new List<Year_Participated__c>();
            Map<Id, Year_Participated__c> yearsParticipatedToUpdateMap = new Map<Id, Year_Participated__c>();
            List<AggregateResult> correctPicks = [SELECT Participant__c, Count(Id) numberOfCorrectPicks, SUM(Assigned_Points__c) earnedPoints FROM Pick__c WHERE Bowl_Game__r.Completed__c = true  AND Picked_Correctly__c = true AND Year__r.Active__c = true GROUP BY Participant__c];
            List<AggregateResult> picksLeft = [SELECT Participant__c, SUM(Assigned_Points__c) availablePointsLeft FROM Pick__c WHERE Bowl_Game__r.Completed__c = false AND Year__r.Active__c = true GROUP BY Participant__c];
            if(picksLeft.isEmpty()){
                noGamesLeft = true;
            }
            for(AggregateResult aggr : correctPicks) {
                Year_Participated__c yp = new Year_Participated__c();
                yp.Id = (Id)aggr.get('Participant__c');
                yp.Earned_Points__c = (Double)aggr.get('earnedPoints');
                yp.Number_of_Correct_Picks__c = (Double)aggr.get('numberOfCorrectPicks');
                if(noGamesLeft) {
                    yp.Available_Points_Left__c = 0;
                }
                yearsParticipatedToUpdateMap.put(yp.Id, yp);
                yearsParticipatedToUpdate.add(yp);
                System.debug('ParticipantId: ' + yp.Id);
                System.debug('participant earned points: ' + yp.Earned_Points__c);
                System.debug('participant correct picks: ' + yp.Number_of_Correct_Picks__c);
            }

            if(!noGamesLeft) {
                for(AggregateResult aggr : picksLeft) {
                    Year_Participated__c yp = new Year_Participated__c();
                    yp.Id = (Id)aggr.get('Participant__c');
                    yearsParticipatedToUpdateMap.get(yp.Id).Available_Points_Left__c = (Double)aggr.get('availablePointsLeft');
                    
                }
            }
            
            if(!yearsParticipatedToUpdate.isEmpty()){
                try{
                    update yearsParticipatedToUpdate;
                    setKeyParticipants(yearsParticipatedToUpdate);
                }
                catch(Exception e){
                    System.debug('Exception occured while updating the earned points values: ' + e.getMessage());
                }
            }
        }
    }

    public static void setKeyParticipants(List<Year_Participated__c> yearsParticipated) {
        Year__c activeYear = [SELECT Id, First_Place__c, Second_Place__c, Last_Place_DFL__c FROM Year__c WHERE Active__c = true LIMIT 1];
        List<Year_Participated__c> ypList = [SELECT Id, Participant__c FROM Year_Participated__c WHERE Id IN :yearsParticipated ORDER BY Earned_Points__c DESC];
        activeYear.First_Place__c = ypList[0].Participant__c;
        activeYear.Second_Place__c = ypList[1].Participant__c;
        activeYear.Last_Place_DFL__c = ypList[ypList.size()-1].Participant__c;
        try{
            update activeYear;
        }
        catch(Exception e){
            System.debug('Exception occured while updating the key participants for the active year: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static void deleteBowlGames(Id yearId){
        try {
            delete [SELECT Id FROM Bowl_Game__c WHERE Year__c = :yearId];
            Year__c year = [SELECT Id, Bowl_Games_Imported__c FROM Year__c WHERE Id = :yearId];
            year.Bowl_Games_Imported__c = false;
            update year;
        } catch (Exception e) {
            System.debug('An error occurred while deleting the bowl games for the designated year.');
        }
    }
}