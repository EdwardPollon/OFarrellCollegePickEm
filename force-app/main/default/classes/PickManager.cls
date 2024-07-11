public with sharing class PickManager {

    // public static void createPicks(string participantPasscode) {
    //     Participant__c participant = Database.query('SELECT Id FROM Participant__c WHERE Passcode__c = ' + participantPasscode + 'LIMIT 1');
    //     List<Bowl_Game__c> bowlGames = [SELECT Id, Year__c FROM Bowl_Game__c WHERE Year__c = 'a008b00001ji1bSAAQ'];

    //     for(Bowl_Game__c bg : bowlGames) {
    //         Pick__c pick = new Pick__c(
    //             Bowl_Game__c = bg.Id,
    //             Picked_By__c = participant.Id,
    //             Assigned_Points__c = 0
    //         );
    //     }
    // }

    // public static void editPicks(String participantPasscode) {
    //     List<Pick__c> existingPicks = [SELECT Id, Winner__c, Assigned_Points__c FROM Pick__c WHERE Picked_By__r.Passcode__c = :participantPasscode];
    // }

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
    public static List<Bowl_Game__c> getBowlGames(Id yrId){
        return [SELECT Id, Name, Home_Team__c, Away_Team__c FROM Bowl_Game__c WHERE Year__c = :yrId];
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
    public static List<Pick__c> getRelatedPicks(Id yrId){
        return [Select Id, Bowl_Game__c, Bowl_Game_Name__c, Bowl_Game__r.Name, Winner__c, Assigned_Points__c, Year__r.Name from Pick__c where Year__c = :yrId];
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
    public static List<Pick__c> deletePickHandler(Id pickId, Id yrId){
        Database.delete(pickId);
        return [Select Id, Bowl_Game__c, Bowl_Game_Name__c, Winner__c, Assigned_Points__c, Year__r.Name from Pick__c where Year__c = :yrId];
    }

    @AuraEnabled
    public static List<Pick__c> savePickData(String pickDataString){
        List<Pick__c> pickList = (List<Pick__c>)System.JSON.deserializeStrict(pickDataString, List<Pick__c>.Class);
        Database.insert(pickList);
        return pickList;
    }
}