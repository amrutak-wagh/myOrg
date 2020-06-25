public class WorkOrderRejectedCTRL{
    public Static void SendMailRejected(List<WorkOrder> objListWorkOrder){
        Set<Id> objAccId = new Set<Id>();
        Map<Id,String> objAccDescription = new Map<Id,String>();
        for(WorkOrder objWorkOrder : objListWorkOrder){
            objAccId.add(objWorkOrder.AccountId);
            objAccDescription.put(objWorkOrder.AccountId,objWorkOrder.Description);
        }
        
        List<Messaging.SingleEmailMessage> objMassMailSend = new List<Messaging.SingleEmailMessage>();
        List<Contact> objListContact = [select id,isSubmit__c,Email,Name,AccountId from Contact where AccountId IN : objAccId and ParentCon__c = true];
        EmailTemplate EmailTemplateFile = [Select id,HtmlValue,DeveloperName,Subject from EmailTemplate where DeveloperName = 'Application_Rejected'];
        for(Contact objCon : objListContact){
            String bodyName = EmailTemplateFile.HtmlValue;
            
            if(bodyName.contains('{!DescriptionforReasons}') && objAccDescription.get(objCon.AccountId) != null)
                 bodyName = bodyName.replace('{!DescriptionforReasons}',objAccDescription.get(objCon.AccountId));
                 
            if(bodyName.contains('{!Contact.Id}') && objCon.Id != null)
                bodyName = bodyName.replace('{!Contact.Id}',objCon.Id);
                
            if(bodyName.contains('{!Contact.LastName}') && objCon.Name != null)
                bodyName = bodyName.replace('{!Contact.LastName}',objCon.Name);
            
            if(bodyName.contains('{!Contact.Email}') && objCon.Email != null)
                bodyName = bodyName.replace('{!Contact.Email}',objCon.Email);
            
            if(bodyName.contains('{!isOpen}'))
                bodyName = bodyName.replace('{!isOpen}','false');
           
            Messaging.SingleEmailMessage objMessage = new Messaging.SingleEmailMessage();
            objMessage.setTargetObjectId(objCon.Id); //Sets the Who Id to the logged in User
            objMessage.setSubject(EmailTemplateFile.Subject);
            objMessage.setHtmlBody(bodyName); 
            objMassMailSend.add(objMessage); 
            objCon.isSubmit__c = false;
         } 
         Messaging.sendEmail(objMassMailSend); 
         update objListContact;        
    }
}