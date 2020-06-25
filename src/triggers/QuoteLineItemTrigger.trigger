/*
 * @Who   Patrick Duncan <patrick.duncan@weare4c.com>
 * @What  Trigger on QuoteLineItem
 * @When  24/6/2019
 */
trigger QuoteLineItemTrigger on QuoteLineItem(before insert, before update, before delete, after insert, after update, after delete, after undelete) {
	if(Trigger.isBefore){
		if(Trigger.isInsert){
			QuoteLineItemTriggerHandler.handleBeforeInsert(Trigger.new);
		}
		else if(Trigger.isUpdate){
			QuoteLineItemTriggerHandler.handleBeforeUpdate(Trigger.oldMap, Trigger.newMap);
		}
		else if(Trigger.isDelete){
			QuoteLineItemTriggerHandler.handleBeforeDelete(Trigger.oldMap);
            System.debug('Checking isExecuting==='+Trigger.isExecuting);
		}
	}
	else{
		if(Trigger.isInsert){
			QuoteLineItemTriggerHandler.handleAfterInsert(Trigger.newMap);
		}
		else if(Trigger.isUpdate){
			QuoteLineItemTriggerHandler.handleAfterUpdate(Trigger.oldMap, Trigger.newMap);
		}
		else if(Trigger.isDelete){
			QuoteLineItemTriggerHandler.handleAfterDelete(Trigger.oldMap);
		}
		else if (Trigger.isUndelete){
			QuoteLineItemTriggerHandler.handleAfterUndelete(Trigger.newMap);
		}
	}
}