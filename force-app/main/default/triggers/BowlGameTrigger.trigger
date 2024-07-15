trigger BowlGameTrigger on Bowl_Game__c (after update) {
    if (Trigger.isAfter && Trigger.isUpdate) {
        BowlGameUtil.sumEarnedPoints(Trigger.new, Trigger.oldMap);
    }
}