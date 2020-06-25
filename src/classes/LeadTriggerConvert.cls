/***********************************************************************************************
* Name              : LeadTriggerConvert                                                 
* Description       : LeadTriggerConvert class for triggers related to Leads.after Convert send the Mail to Contact Mail Id.
* Created Date      : 05/04/2019                                                    
* Created By        : Divya Chary (divya.chary@were4c.com)                                                                                                    
* ----------------------------------------------------------------------------------------------
* VERSION   Developer   Date        Description     Ticket/Reference                                                                    
* 1.0       Divya       05/04/2019   Created                              
************************************************************************************************/
public class LeadTriggerConvert{
    /************************************************************************************
    Method  :         leadConvert Method
    Description :     after Convert send the Mail to Contact Mail Id.
    Version :         1.0
    ************************************************************************************/
    public static void leadConvert(List<Lead> lstLead, Map<Id,Lead> oldMap){
        Set<Id> convertedContactIds = new Set<Id>();
        for(Lead objLeadConvert : lstLead){
            for(Lead objOldMapLead : oldMap.values()) {
                 if (objLeadConvert.convertedContactId != null && objLeadConvert.convertedContactId != objOldMapLead.ConvertedContactId) {
                        convertedContactIds.add(objLeadConvert.convertedContactId);
                 }
            }
        }
        System.debug('convertedContactIds ==='+convertedContactIds );
        System.debug('convertedContactIds size ==='+convertedContactIds.size() );
        List<WorkOrder> objWorkOrderList = new List<WorkOrder>();
        List<Case> objCaseOrderList = new List<Case>();
        List<Contact> objListOfCon = [select id,Email,Name,AccountId,Encrypted_Contact_Id__c from Contact where Id IN : convertedContactIds];
        System.debug('objListOfCon ==='+objListOfCon );
        System.debug('objListOfCon size ==='+objListOfCon.size());
        List<Messaging.SingleEmailMessage> objMassMailSend = new List<Messaging.SingleEmailMessage>();
        EmailTemplate EmailTemplateFile = [Select id,HtmlValue,DeveloperName,Subject from EmailTemplate where DeveloperName = 'Application_Form'];
         for(Contact objCon : objListOfCon){
            String bodyName = EmailTemplateFile.HtmlValue;
            
            if(bodyName.contains('{!Contact.Encrypted_Contact_Id__c}') && objCon.Id != null)
                bodyName = bodyName.replace('{!Contact.Encrypted_Contact_Id__c}',objCon.Encrypted_Contact_Id__c);
                
            if(bodyName.contains('{!Contact.LastName}') && objCon.Name != null)
                bodyName = bodyName.replace('{!Contact.LastName}',objCon.Name);
            
            Id WoRecordTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByName().get('Brand Approval').getRecordTypeId();
            WorkOrder objWorkOrder = new WorkOrder();
            objWorkOrder.ContactId = objCon.id;
            objWorkOrder.AccountId = objCon.AccountId;
            objWorkOrder.RecordTypeId = WoRecordTypeId; 
            objWorkOrderList.add(objWorkOrder);
            
            Case objCase = new Case();
            Id CaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Provisional Approval').getRecordTypeId();
            objCase.RecordTypeId = CaseRecordTypeId;
            objCase.ContactId = objCon.Id;
            objCase.AccountId = objCon.AccountId;
            objCaseOrderList.add(objCase);
            
            Messaging.SingleEmailMessage objMessage = new Messaging.SingleEmailMessage();
            objMessage.setTargetObjectId(objCon.Id); //Sets the Who Id to the logged in User
            objMessage.setSubject(EmailTemplateFile.Subject);
            objMessage.setHtmlBody(bodyName); 
            objMassMailSend.add(objMessage);  
         } 
         System.debug('objCaseOrderList size ==='+objCaseOrderList.size());
         Messaging.sendEmail(objMassMailSend);      
         insert objWorkOrderList;
         insert objCaseOrderList;
    }
    
    /************************************************************************************
    Method  :         afterCovertUpdateContactOnOpportunity Method
    Description :     After lead convert populate Contact on Opportunity record.
    Version :         1.0
    ************************************************************************************/
    public static void afterCovertUpdateContactOnOpportunity(List<Lead> lstLead, Map<Id,Lead> oldMap) {
        
        Map<Id, Id> opportunityIdVsContactIdMap = new Map<Id, Id>();
        for(Lead leadObj : lstLead) {
            Lead oldLeadObj = oldMap.get(leadObj.Id);
            if(leadObj.IsConverted != oldLeadObj.IsConverted &&
              leadObj.ConvertedOpportunityId != null && 
              leadObj.ConvertedContactId != null) {
                opportunityIdVsContactIdMap.put(leadObj.ConvertedOpportunityId, leadObj.ConvertedContactId);
            }
        }
        
        if(!opportunityIdVsContactIdMap.isEmpty()) {
            List<Opportunity> opportunityList = new List<Opportunity>();
            for(Id oppId : opportunityIdVsContactIdMap.KeySet()) {
                opportunityList.add(new Opportunity(Id = oppId, Contact__c = opportunityIdVsContactIdMap.get(oppId)));
            }
            
            update opportunityList;
        }
    }
}