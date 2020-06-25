/************************************************************************************
* Name          : EmailMessageTrigger                                                 
* Description   : Master trigger on EmailMessage
* Created Date  : 15/04/2019                                                    
* Created By    : 4C - Adeel Ahmad (adeel.ahmad@weare4c.com)
* Jira/Req By   :                                                                                                                                           
* -----------------------------------------------------------------------------------------------------------------------
* VERSION   Developer   Date        Description     Ticket/Reference                                                                    
************************************************************************************/
trigger EmailMessageTrigger on EmailMessage (after insert) {
    if(trigger.isAfter && trigger.IsInsert){
        EmailMessageTriggerHandler.afterInsert(trigger.new);
    }
}