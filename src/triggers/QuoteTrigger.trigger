/*
 * @Who   Patrick Duncan <patrick.duncan@weare4c.com>
 * @What  Trigger on Quote
 * @When  24/6/2019
 */
trigger QuoteTrigger on Quote(before update, after update) {
    if(Trigger.isBefore){
        if(Trigger.isUpdate){
            QuoteTriggerHandler.handleBeforeUpdate(Trigger.oldMap, Trigger.newMap);
        }
    }
    else if (Trigger.isAfter){
        if(Trigger.isUpdate){
            QuoteTriggerHandler.handleAfterUpdate(Trigger.oldMap,Trigger.newMap);
        }
    }
}