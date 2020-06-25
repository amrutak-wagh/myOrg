trigger OpportunityTrigger on Opportunity (before insert, before update, after update) {
    
    if(trigger.isBefore && trigger.isInsert){
        OpportunityTriggerHandler.handleBeforeInsert(trigger.new);
    }
    if(trigger.isAfter && trigger.isUpdate)
    {
        NewRenewIntegrationIntegrationUtil.sendHSEStatus(trigger.new, trigger.oldmap);
    }
    if(trigger.isBefore && trigger.isUpdate){
        OpportunityTriggerHandler.handleBeforeUpdate(trigger.oldMap,trigger.newMap);
    }

}