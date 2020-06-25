/***********************************************************************************************
* Name              : AccountIntegrationOracleERP                                               
* Description       : real-time integration for accounts to Oracle ERP after lead conversion.
* Created Date      : 13/06/2019                                                    
* Created By        : Prachi Sinha (prachi.sinha@were4c.com)                                                                                                    
* ----------------------------------------------------------------------------------------------
* VERSION   Developer   Date        Description     Ticket/Reference                                                                    
* 1.0       Prachi      13/06/2019   Created       
* 2.0      Raza         28/07/2019 . Update         Enable the method to make call out
************************************************************************************************/

public with sharing class AccountIntegrationOracleERP{

    /************************************************************************************
    Method  :         sendAccountsToOracle 
    Description :     push accounts to Oracle ERP after lead conversion
    Version :         1.0
                      2.0 - Enable the method to make call out
    ************************************************************************************/
    @future(callout = true)
    public static void sendAccountsToOracle(List<Id> accountIdList){

        List<Account> accList = [SELECT Id, Name,legal_name__c,parent.Name,parent.legal_name__c,License__c,Industry,Related_Company_Type__c,
                        License_Business_Park__r.Name, VAT__c, BillingStreet,BillingCity,BillingState,BillingCountry,BillingPostalCode,
                        Phone,Primary_Email__c,Oracle_Party_Number__c,Oracle_Customer_Id__c,Oracle_Customer_Number__c,ORACLE_PARTY_ID__c 
                        from account where id in: accountIdList];
        
        List<Account> accountsToUpdate = new List<Account>();
        
        for(Account acc : accList){        

            RequestWrapper.AccountWrapper accWrap = new RequestWrapper.AccountWrapper();
            accWrap.P_SALESFORCE_ID = acc.Id;
            if(acc.legal_name__c == null)             
                accWrap.P_PARTY_NAME = acc.Name;
            else
                accWrap.P_PARTY_NAME = acc.legal_name__c;
            if(acc.parent <> null){
                if(acc.parent.legal_name__c == null)
                    accWrap.P_PARENT_COMPANY_NAME = acc.parent.Name;
                else
                    accWrap.P_PARENT_COMPANY_NAME = acc.parent.legal_name__c;
            }
            
            accWrap.P_LICENSE_NUMBER = String.valueOf(acc.License__c);
            accWrap.P_CUSTOMER_CLASSIFICATION = acc.Industry;
            accWrap.P_RELATED_PARTY_TYPE = acc.Related_Company_Type__c;
            accWrap.P_BUSINESS_PARK = acc.License_Business_Park__r.Name;
            accWrap.P_TRN_NUMBER = acc.VAT__c;
            accWrap.P_ADDRESS1 = acc.BillingStreet;
            accWrap.P_CITY = acc.BillingCity;                
            accWrap.P_STATE = acc.BillingState;
            accWrap.P_COUNTRY = acc.BillingCountry;
            accWrap.P_POSTAL_CODE = acc.BillingPostalCode;               
            accWrap.P_PRIMARY_PHONE_NUMBER = acc.Phone;
            accWrap.P_EMAIL_ADDRESS =  acc.Primary_Email__c;
            
            if(acc.Oracle_Party_Number__c <> null)
                accWrap.X_PARTY_NUMBER = acc.Oracle_Party_Number__c;
            if(acc.Oracle_Customer_Id__c <> null)
                accWrap.X_CUSTOMER_ID = acc.Oracle_Customer_Id__c;
            if(acc.Oracle_Customer_Number__c <> null)
                accWrap.X_CUSTOMER_NUMBER = acc.Oracle_Customer_Number__c;
            if(acc.ORACLE_PARTY_ID__c <> null)
                accWrap.X_PARTY_ID = acc.ORACLE_PARTY_ID__c;
            
            httpResponse response = new httpResponse();
            
            try{
                response = RealTimeIntegrationFramework.realTimeCall(JSON.serialize(accWrap), System.Label.OracleCustomerCreation); 
    
                system.debug('see response '+response);
                System.debug('see string response '+response.getBody());
                
                //if it is successful
                if(response <> null){
                    if(response.getBody() <> null){
                        
                        Map<String, String> values = (Map<String, String>)JSON.deserialize(response.getBody(), Map<String, String>.class);
                        acc.oracle_party_id__c = values.get('ORACLE_PARTY_ID__c');
                        acc.Oracle_Party_Number__c = values.get('Oracle_Party_Number__c');
                        acc.Oracle_Integration_Error_Message__c = values.get('Oracle_Integration_Error_Message__c');
                        acc.Oracle_Customer_Id__c = values.get('Oracle_Customer_Id__c');
                        acc.Oracle_Customer_Number__c = values.get('Oracle_Customer_Number__c');
                        system.debug('Oracle_Integration_Status__c:'+ values.get('Oracle_Integration_Status__c'));
                        acc.Oracle_Integration_Status__c = values.get('Oracle_Integration_Status__c');
                    }
                }
                    
            }catch(Exception e) {
                System.debug('Callout error: '+ e.getMessage());
                System.debug(response.toString());
                acc.Oracle_Integration_Error_Message__c = e.getMessage();
            }   
            
            accountsToUpdate.add(acc);     
        }
        
        if(accountsToUpdate.size() > 0){
            update accountsToUpdate;
        }
    }
    
}