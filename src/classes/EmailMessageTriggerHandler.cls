/************************************************************************************
* Name          : EmailMessageTriggerHandler                                                 
* Description   : Handler class for EmailMessageTrigger
* Created Date  : 15/04/2019                                                    
* Created By    : 4C - Adeel Ahmad (adeel.ahmad@weare4c.com)
* Jira/Req By   :                                                                                                                                           
* -----------------------------------------------------------------------------------------------------------------------
* VERSION   Developer   Date        Description     Ticket/Reference                                                                    
************************************************************************************/
public class EmailMessageTriggerHandler {
    public static void afterInsert(LIST<EmailMessage> newList){
		LIST<EmailMessage> updateables = new LIST<EmailMessage>();
        for(EmailMessage em : newList){
            if(em.ActivityId != null && em.Incoming == false){
                updateables.add(em);
            }
        }
        
        if(updateables.size() > 0){
            updateLeadActivityDate(updateables);
        }
    }
    
    /************************************************************************************
    Method      :   updateLeadActivityDate
    Description :   Method to update the Last Activity Date on lead
    returns     :   void
    Created Date:   15/04/2018
    *************************************************************************************
    */

    private static void updateLeadActivityDate(LIST<EmailMessage> newList){
		SET<Id> leadIds = new SET<Id>();
        LIST<Lead> updateableLeads = new LIST<Lead>();
        SET<Id> activityIds = new SET<Id>();
        for(EmailMessage em : newList){
           	activityIds.add(em.ActivityId);
        }
        
        for(Task t : [SELECT Id,WhoId FROM Task WHERE Id IN:activityIds ]){
            if(t.WhoId != null && String.valueOf(t.WhoId).startsWith('00Q')){
                leadIds.add(t.WhoId);
            }
        }
        
        if(leadIds.size() > 0){
			updateableLeads = [SELECT Id,Activity_Logged_Time__c FROM Lead WHERE Id IN:leadIds];
            if(updateableLeads.size() > 0){
                for(Lead l : updateableLeads){
                    l.Activity_Logged_Time__c = DateTime.now();
                }
				update updateableLeads;            
            }
        }
    }
}