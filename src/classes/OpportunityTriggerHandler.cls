public class OpportunityTriggerHandler {
    public static void handleBeforeUpdate(Map<Id,Opportunity> oldMap,Map<Id,Opportunity> newMap){
        OpportunityUtility.validateOpportunityStatusChange(oldMap,newMap);
        OpportunityUtility.checkContactRoleAgainstAccount(newMap.values(), oldMap);
    }
    public static void handleBeforeInsert(List<Opportunity> newOppList) {
        OpportunityUtility.checkContactRoleAgainstAccount(newOppList, null);
    }
}