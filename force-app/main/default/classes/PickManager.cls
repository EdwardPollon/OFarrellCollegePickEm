public with sharing class PickManager {

    @AuraEnabled(cacheable=true)
    public static List<String> getTeams(Id yrId, Id gameId){
        List<String> teams = new List<String>();
        List<Bowl_Game__c> bowlGames = [SELECT Id, Home_Team__c, Away_Team__c FROM Bowl_Game__c WHERE Year__c = :yrId AND Id = :gameId];
        for(Bowl_Game__c bg : bowlGames) {
            teams.add(bg.Home_Team__c);
            teams.add(bg.Away_Team__c);
        }
        return teams;
    }

    @AuraEnabled(cacheable=true)
    public static String getActiveYearId(){
        return [SELECT Id FROM Year__c WHERE Active__c = TRUE LIMIT 1].Id;
    }

    @AuraEnabled
    public static String getBowlGameName(Id bowlGameId){
        return [SELECT Name FROM Bowl_Game__c WHERE Id = :bowlGameId LIMIT 1].Name;
    }

    @AuraEnabled
    public static List<Pick__c> getCurrentParticipantsPicks(Id yrId, Id participantId){
        return [Select Id, Bowl_Game__c, Bowl_Game_Name__c, Bowl_Game__r.Name, Winner__c, Assigned_Points__c, Year__r.Name from Pick__c where Year__c = :yrId AND Participant__c = :participantId ORDER BY Bowl_Game__r.Start_Date__c ASC];
    }

    @AuraEnabled
    public static Boolean validatePasscode(String passcode){
        List<Year_Participated__c> yp= [SELECT Id FROM Year_Participated__c WHERE Passcode__c = :passcode LIMIT 1];
        if(!yp.isEmpty()){
            return true;
        }
        else {
            return false;
        }
    }

    @AuraEnabled
    public static String getCurrentParticipantId(String passcode){
        return [SELECT Id FROM Year_Participated__c WHERE Passcode__c = :passcode LIMIT 1].Id;
    }

    @AuraEnabled
    public static String getCurrentParticipantName(String participantId){
        return [SELECT Id, Participant__r.Name FROM Year_Participated__c WHERE Id = :participantId LIMIT 1].Participant__r.Name;
    }

    @AuraEnabled
    public static List<Pick__c> deletePickHandler(Id pickId, Id yrId, Id participantId){
        Database.delete(pickId);
        return [Select Id, Bowl_Game__c, Bowl_Game_Name__c, Winner__c, Assigned_Points__c, Year__r.Name from Pick__c where Year__c = :yrId AND Participant__c = :participantId];
    }

    @AuraEnabled
    public static List<Pick__c> savePickData(String pickDataString){
        List<Pick__c> pickList = (List<Pick__c>)System.JSON.deserializeStrict(pickDataString, List<Pick__c>.Class);
        Database.insert(pickList);
        return pickList;
    }

    @AuraEnabled
    public static List<String> getAvailablePointValues(Id yrId, String participantId){
        List<Pick__c> currentPicks = [SELECT Id, Assigned_Points__c FROM Pick__c WHERE Year__c = :yrId AND Participant__c = :participantId];
        Map<Decimal,Decimal> usedPointValues = new Map<Decimal,Decimal>();
        for(Pick__c p : currentPicks){
            usedPointValues.put(p.Assigned_Points__c, p.Assigned_Points__c);
        }
        List<Bowl_Game__c> bowlGames = [SELECT Id FROM Bowl_Game__c WHERE Year__c = :yrId];
        Map<Decimal, Decimal> availablePointValues = new Map<Decimal, Decimal>();

        for(Integer i=1; i<=bowlGames.size(); i++) {
            if(!usedPointValues.containsKey(i)){
                availablePointValues.put(i, i);
            }
        }
        System.debug('available point values after: ' + availablePointValues.values());
        //return availablePointValues.values();
        List<String> availablePointValuesList = new List<String>();
        for(Decimal value : availablePointValues.values()){
            availablePointValuesList.add(string.valueOf(value));
        }
        System.debug('List actually returned: ' + availablePointValuesList);
        return availablePointValuesList;
    }

    @AuraEnabled
    public static List<Bowl_Game__c> getAvailableBowlGames(Id yrId, String participantId){
        List<Bowl_Game__c> availableBowlGames = [SELECT Id, Name FROM Bowl_Game__c 
                                                WHERE Year__c = :yrId 
                                                AND Id NOT IN (SELECT Bowl_Game__c FROM Pick__c WHERE Participant__c = :participantId) ORDER BY Start_Date__c ASC];
        return availableBowlGames;
    }
}