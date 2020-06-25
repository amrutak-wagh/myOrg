/***********************************************************************************************
* Name              : TerminationIntegration                                               
* Description       : Real-time integration for termination/assignment details to be sent to OIC, which will push the details to Yardi
* Created Date      : 06/08/2019                                                    
* Created By        : Raza khan (raza.khan@were4c.com)                                                                                                    
* ----------------------------------------------------------------------------------------------
* VERSION   Developer   Date        Description     Ticket/Reference                                                                    
* 1.0       Raza      20/08/2019   Created 
* 2.0 .     Raza     03/09/2019 .  Update .         Update the notice date for the terminations
* 3.0 .     Raza     08/09/2019 .  Update .         Update the controller to add new assignment integration request
************************************************************************************************/

public with sharing class TerminationIntegration {
    
    
    public static void sentTerminationToOIC(List<Id> caseIds)
    {
        List<Case> terminationCases =  [SELECT Id, Quote__c,SF_AGNO__c,Yardi_Brand_Code__c,Financial_Obligation_Date__c,
                                        Case_Comments__c,Move_Out_Date__c,Key_Handover_Date__c,Termination_Type__c,Termination_Reason_new__c,
                                        Is_Cancelled__c,Quote__r.OpportunityId, Yardi_Integration_Error_Message__c, Yardi_Integration_Status__c,
                                        Contract__c, AccountId,type, createddate FROM Case where recordtype.Developername = 'Lease_Termination' and Id in:caseIds ];
        
        Map<Id, String> productCodeMap = getProductCode(terminationCases);
        
        List<case> terminationToUpdate = new List<Case>();
        List<Outstanding_Payments__c> outsandingPayments = new List<Outstanding_Payments__c>();
        
        for(Case cas:terminationCases )
        {
            RequestWrapper.TerminationRequestWrapper requestWrap = new RequestWrapper.TerminationRequestWrapper();
            requestWrap.propertyCode = productCodeMap.get(cas.Quote__c);
            requestWrap.opportunityAGNumber = cas.SF_AGNO__c;
            requestWrap.brandCode = cas.Yardi_Brand_Code__c;
            requestWrap.fodDate = cas.Financial_Obligation_Date__c;
            requestWrap.description = cas.Case_Comments__c != null ? cas.Case_Comments__c: '';
            requestWrap.moveOutDate = cas.Move_Out_Date__c;
            requestWrap.keyHandOverDate = cas.Key_Handover_Date__c != null ?  cas.Key_Handover_Date__c: system.today().addYears(-20);
            requestWrap.terminationType = cas.Termination_Type__c;
            requestWrap.reason = cas.Termination_Reason_new__c;
            requestWrap.isCancelled = cas.Is_Cancelled__c;
            requestWrap.opportunityId = cas.Quote__r.OpportunityId;
            requestWrap.NoticeDate = cas.CreatedDate.date();
            
            httpResponse response = new httpResponse();
            
            try{ 
                String request = JSON.serialize(requestWrap);   
                System.debug('request:'+ request);
                response =  RealTimeIntegrationFramework.realTimeCall(request,System.Label.OIC_Termination_Endpoint);  // need to change the end point to termination
                
                system.debug('response:'+ response);                                             
                RequestWrapper.TerminationResponse responseData = (RequestWrapper.TerminationResponse)JSON.deserialize(response.getBody(), RequestWrapper.TerminationResponse.class);
                if(responseData != null){
                    if( responseData.opportunityTCode != null && !string.isBlank(responseData.opportunityTCode)  ){
                        
                        cas.Yardi_Integration_Status__c  = responseData.yardiIntegrationStatus;
                        cas.Yardi_Integration_Error_Message__c  = responseData.yardiIntegrationErrorMessage;
                        
                        if(responseData.outstandingPayments != null){
                            
                            for(RequestWrapper.OutstandingPayment wpayment: responseData.outstandingPayments)
                            {
                                if((wpayment.billedAmount != null && wpayment.billedAmount >0) ||
                                   (wpayment.vatAmount != null && wpayment.vatAmount >0))
                                {
                                    Outstanding_Payments__c payment = new Outstanding_Payments__c();
                                    payment.Description__c   = wpayment.description;
                                    payment.Charge_Code__c  = wpayment.chargeCode;
                                    payment.Outstanding_Lease_Amount__c   = wpayment.billedAmount;
                                    payment.VAT_Amount__c  = wpayment.vatAmount;
                                    payment.Charge_From__c   = wpayment.chargeFrom;
                                    payment.Charge_From__c  = wpayment.chargeTo;
                                    payment.Charge_To__c = wpayment.chargeTo;
                                    payment.Opportunity__c  = cas.Quote__r.OpportunityId;
                                    payment.Contract__c = cas.Contract__c;
                                    payment.Account__c = cas.AccountId;
                                    outsandingPayments.add(payment);
                                }
                                
                            }
                        }
                        
                        
                    } 
                }else{
                    cas.Yardi_Integration_Status__c  = 'Error';
                    cas.Yardi_Integration_Error_Message__c  = response.getBody();
                }
                
            }
            catch(Exception e){
                System.debug('Callout error: '+ e);
                cas.Yardi_Integration_Error_Message__c = e.getMessage();
            }     
            
            terminationToUpdate.add(cas);   
        }
        
        if(terminationToUpdate.size() > 0){
            update terminationToUpdate;
        }
        
        if(outsandingPayments.size() >0){
            insert outsandingPayments;
        }
    }
    
     public static void sentAssigmentToOIC(List<Id> caseIds)
    {
        List<Case> terminationCases =  [Select  id , accountId, Account.Yardi_Account_Id__c, account.ParentId, account.Parent.Yardi_Account_Id__c,Opportunity__c,
                                        Opportunity__r.AG_Number__c, Quote__r.Legal_Terms_Changed__c,Opportunity__r.Type, Opportunity__r.Sub_Type__c,Opportunity__r.name, 
                                        Account.Legal_Name__c, Opportunity__r.Lease_Type__c,createddate,Opportunity__r.Retail_Sales_Category__c, Case_Comments__c,Opportunity__r.T_Code__c,
                                        Quote__r.Yardi_Brand_Code__c, Quote__r.Contact.Yardi_Contact_Id__c,Yardi_Integration_Status__c, Yardi_Integration_Error_Message__c
                                        FROM Case where recordtype.Developername = 'Assignment' and Id in:caseIds ];
        
        Map<Id, String> productCodeMap = getProductCode(terminationCases);
        
        List<case> terminationToUpdate = new List<Case>();
        
        for(Case cas:terminationCases )
        {
            RequestWrapper.Assignment requestWrap = new RequestWrapper.Assignment();
            requestWrap.propertyCode = productCodeMap.get(cas.Quote__c);
            requestWrap.extRefLeaseId = cas.Opportunity__c;
            requestWrap.opportunityAGNumber = cas.SF_AGNO__c;
           	requestWrap.legalTermChanged = cas.Quote__r.Legal_Terms_Changed__c;
            requestWrap.amendmentType = cas.Opportunity__r.Type;
            requestWrap.amendmentSubType = cas.Opportunity__r.Sub_Type__c;
            requestWrap.yardiLeaseCode = cas.Opportunity__r.T_Code__c;
            requestWrap.yardibrandCode = cas.Quote__r.Yardi_Brand_Code__c; 
            requestWrap.status  = cas.Quote__r.Status;
            requestWrap.leaseName = cas.Opportunity__r.Name;
            requestWrap.companyName = cas.Account.Legal_Name__c;
            requestWrap.leaseType = cas.Opportunity__r.Lease_Type__c;
            requestWrap.assignmentDate = cas.createddate.date();
            requestWrap.description = cas.Case_Comments__c != null ? cas.Case_Comments__c: '';
            requestWrap.yardiContactCode = cas.Quote__r.Contact.Yardi_Contact_Id__c;
            httpResponse response = new httpResponse();
            
            try{ 
                String request = JSON.serialize(requestWrap);   
                System.debug('request:'+ request);
                response =  RealTimeIntegrationFramework.realTimeCall(request,'System.Label.OIC_Assignment_Endpoint');  // need to change the end point to assignment
                
                system.debug('response:'+ response);                                             
                RequestWrapper.TerminationResponse responseData = (RequestWrapper.TerminationResponse)JSON.deserialize(response.getBody(), RequestWrapper.TerminationResponse.class);
                if(responseData != null){ 
                    if( responseData.opportunityTCode != null && !string.isBlank(responseData.opportunityTCode)  ){
                        
                        cas.Yardi_Integration_Status__c  = responseData.yardiIntegrationStatus;
                        cas.Yardi_Integration_Error_Message__c  = responseData.yardiIntegrationErrorMessage;
                        
                       
                        }
                        
                        
                    } 
                else{
                    cas.Yardi_Integration_Status__c  = 'Error';
                    cas.Yardi_Integration_Error_Message__c  = response.getBody();
                }
                
            }
            catch(Exception e){
                System.debug('Callout error: '+ e);
                cas.Yardi_Integration_Error_Message__c = e.getMessage();
            }     
            
            terminationToUpdate.add(cas);   
        }
        
        if(terminationToUpdate.size() > 0){
            update terminationToUpdate;
        }
    }
    
    private static map<Id, String> getProductCode(List<Case> cases)
    {
        Map<Id, String> productCodeMap = new Map<Id, String>();
        List<Id> quoteIds = new List<Id>();
        for(Case c: cases)
        {
            quoteIds.add(c.Quote__c);
        }
        List<QuoteLineItem> items = [Select id, QuoteId, Product_Code__c from QuoteLineItem where QuoteId in:quoteIds and Product_Code__c  != null  ];
        for( QuoteLineItem qli: items)
            productCodeMap.put(qli.QuoteId, qli.Product_Code__c);
        
        return productCodeMap;
        
    }
    
}