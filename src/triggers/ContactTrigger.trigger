/************************************************************************************
* Name          : ContactTrigger                                                 
* Description   : Master trigger on Contact
* Created Date  : 22/05/2019                                                    
* Created By    : 4C - Adeel Ahmad (adeel.ahmad@weare4c.com)
* Jira/Req By   :                                                                                                                                           
* -----------------------------------------------------------------------------------------------------------------------
* VERSION   Developer   Date        Description     Ticket/Reference                                                                    
************************************************************************************/
trigger ContactTrigger on Contact (before Insert,before Update,after insert) {
    
    if(Trigger.isBefore){
        if(Trigger.isUpdate){
            ContactTriggerHandler.handleBeforeUpdate(trigger.new,trigger.oldMap);
            //ContactUtils.validateContactType(trigger.new,trigger.oldMap);
        }
        if(Trigger.isInsert){
            ContactTriggerHandler.handleBeforeInsert(trigger.new,trigger.oldMap);
            //ContactUtils.validateContactType(trigger.new,trigger.oldMap);
        }
    }
    else if (Trigger.isAfter){
        if(Trigger.isInsert){
            ContactTriggerHandler.handleAfterInsert(trigger.new);
            //ContactUtils.afterInsert(trigger.new);
        }
    }
    
}