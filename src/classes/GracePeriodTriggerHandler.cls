public class GracePeriodTriggerHandler {
    public static void handleGracePeriodInsert(Map<Id,Grace_Period__c> newMap){
        GracePeriodUtility.createGraceGracePeriodLineItems(newMap.keyset());
    }
    public static void handleGracePeriodUpdate(Map<Id,Grace_Period__c> newMap,Map<Id,Grace_Period__c> oldMap){
        GracePeriodUtility.deleteQLIonGracePeriodDeletion(oldMap.keyset());
        GracePeriodUtility.createGraceGracePeriodLineItems(newMap.keyset());
    }
    public static void handleGracePeriodDelete(Map<Id,Grace_Period__c> oldMap){
        GracePeriodUtility.deleteQLIonGracePeriodDeletion(oldMap.keyset());
    }
}