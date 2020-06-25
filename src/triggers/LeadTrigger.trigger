/***********************************************************************************************
* Name              : LeadTrigger                                                 
* Description       : Trigger for lead object                                           
* Created Date      : 20/03/2019                                                    
* Created By        : Divya Chary (divya.chary@were4c.com)                                                                                                    
* ----------------------------------------------------------------------------------------------
**/
trigger LeadTrigger on Lead (before update, after update) {
    
    if(trigger.isUpdate) {
        if(trigger.isBefore) {
            LeadTriggerHelper.leadRoundRobin(Trigger.New,Trigger.OldMap);
    		LeadTriggerConvert.leadConvert(Trigger.New,Trigger.OldMap);
        }
        else {
        	LeadTriggerConvert.afterCovertUpdateContactOnOpportunity(Trigger.New,Trigger.OldMap);
        }
        
    }
    
    // Sam's quick validation rule (temporary)
    /*String convertedStatus = 'Closed - Converted';
    for (Integer i = 0; i < Trigger.new.size(); i++) {
        if (Trigger.old[i].Status != convertedStatus && Trigger.new[i].Status == convertedStatus) {
            if (Trigger.new[i].Activity_Logged_Time__c == null) {
                Trigger.new[i].addError('Please log at least one activity before converting the lead.');
            }
        }
    }*/
}