/*
* Created By : Raza Khan (raza.khan@weare4c.com)
* Dated:       28-07-2019
* Description: This is the util class for calling the account integrations api
*              for oracle and yardi integrations.
* 
* 
* 
* */

public class AccountIntegrationUtil {
    
    Public static map<Id,String> caseRecordTypes{
        get{
            if(caseRecordTypes == null)
            {
                caseRecordTypes = new Map<Id,String>();
                for(RecordTypeInfo rec: Schema.SObjectType.Case.getRecordTypeInfosByName().values())
                {
                    caseRecordTypes.put(rec.getRecordTypeId(), rec.getName());
                }
                
            }
            return caseRecordTypes;
        } set;
    }
    
    public static void updateAccountStatusYardiIntegration(List<Case> newCases, Map<Id, Case> oldmap)
    {
        List<Id> accountIds = new List<Id>();
        System.debug('caseRecordTypes ===='+caseRecordTypes);
        for(Case c: newCases)
        {
            System.debug('caseRecordTypes values==== '+caseRecordTypes.get(c.recordTypeId));
            if(c.status != oldmap.get(c.id).status && c.status == 'Closed - Approved' &&
               (caseRecordTypes.get(c.recordTypeId) == 'On-Boarding Premise' || caseRecordTypes.get(c.RecordTypeId) == 'Land On-Boarding'))
            {
                accountIds.add(c.AccountId);
            }
        }
        if(!accountIds.isempty())
        {
            updateAccountStatusYardi(accountIds);
        }
    }
    
    public static void updateContactStatusYardiIntegration(List<Account> newAccounts, Map<Id, Account> oldMap)
    {
        List<Id> accountIds = new List<Id>();
        
        for(Account a: newAccounts)
        {
            if(a.Yardi_Account_Id__c != oldmap.get(a.id).Yardi_Account_Id__c  && a.Yardi_Account_Id__c  != null)
            {
                accountIds.add(a.id);
            }
        }
        if(!accountIds.isempty())
        {
            List<Contact> contacts = [Select id, Yardi_Integration_Status__c  from contact where accountId in: accountIds
                                      And Type__c  includes('Leasing Contact','Billing', 'Licensing Contact') ];
            for(Contact c: contacts)
            {
                c.Yardi_Integration_Status__c = 'Ready for Integration - Yardi';
                
            }
            if(contacts != null)
            {
                update contacts;
            }
        }
    }
    
    public static void updateContactStatusOracleIntegration(List<Account> newAccounts, Map<Id, Account> oldMap)
    {
        List<Id> accountIds = new List<Id>();
        
        for(Account a: newAccounts)
        {
            if(a.ORACLE_PARTY_ID__c  != oldmap.get(a.id).ORACLE_PARTY_ID__c   && a.ORACLE_PARTY_ID__c != null)
            {
                accountIds.add(a.id);
            }
        }
        if(!accountIds.isempty())
        {
            List<Contact> contacts = [Select id, Oracle_Integration_Status__c   from contact where accountId in: accountIds
                                      And Type__c  includes('Leasing Contact','Billing', 'Licensing Contact') ];
            for(Contact c: contacts)
            {
                c.Oracle_Integration_Status__c  = 'Ready for Integration - Oracle';
                
            }
            if(contacts != null)
            {
                update contacts;
            }
        }
    }
    
    
    public static void updateAccountStatusYardi(List<Id> accountIds)
    {
        List<Account> accounts = [Select id, Yardi_Integration_Status__c  from Account where Id in:accountIds ];
        for(Account a: accounts)
        {
            a.Yardi_Integration_Status__c = 'Ready for Integration - Yardi';
        }
        update accounts;
    }
    
    
    public static void sendAccountsToOracle(List<Account> newAcoounts)
    {
        List<Id> accountIds = new List<Id>();
        
        for(Account a: newAcoounts)
        {
            accountIds.add(a.Id);
        }
        if(!accountIds.isempty())
        {
            AccountIntegrationOracleERP.sendAccountsToOracle(accountIds);
        }
        
    }
}