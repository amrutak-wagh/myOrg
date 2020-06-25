/*
 *  Class: TerminationIntegrationTest
 *  Created by : Raza khan (raza.khan@wear4c.com)
 *  Description: This class is for covering the test cases of integration for termination requests.
 * 
 * 
 * */

@istest
public class TerminationIntegrationTest {
    
    
    @TestSetup
    private static void setupData()
    {
        PricingUtilsTest.createData();
        
        Id accId = [select id from Account where name = 'Test Company' limit 1].id;
        List<RecordType> recrordType = [SELECT Id, Name, DeveloperName, SobjectType FROM RecordType where SobjectType ='Case'];
        Map<String, Id> recordTypeMap = new Map<String, Id>();
        for(RecordType rec : recrordType)
        {
            recordTypeMap.put(rec.DeveloperName, rec.id);
        }
        //'Lease_Termination'
        Quote q = [select id, OpportunityId from Quote where name='Test Quote' limit 1];
        
        Contact sobj = new Contact(
            AccountId = accId,                                                                // Account Name
            Email = 'oeafefe@web.de',                                                                          // Email
            Phone = '223424234',                                                                               // Phone
            MobilePhone = '(824) 543-5345',                                                                    // Mobile
            CurrencyIsoCode = 'AED',                                                              // Contact Currency
            Encrypted_Contact_Id__c = 'knA4xzSqpPeaE7dFajzaCuz2eVJ6rn%2FKESjtD4%2FJM8IQ4QsP6Kj3I114VnlbU1bI',  // Encrypted Contact Id
            Registration_Page_Indicator__c = 1,                                                              // Registration Page Indicator
           // Security__c = false,                                                                               // Security Clearance?
            Is_Billing_Contact__c = true,                                                                      // Is Billing Contact
            Is_Active__c = true  ,																				// Is Active
			Lastname = 'test'
        );
        insert sobj;
        
        
        Contract contr = new Contract(
            accountId = accId,
            Status = 'Draft',   // Status
            StartDate = system.today().addDays(-30),  // Contract Start Date
            Contact__c = sobj.id,      // Contact
            ContractTerm = 12,                    // Contract Term (months)
            Opportunity__c = q.OpportunityId,  // Opportunity
            Quote__c = q.id        // Quote
        );
        insert contr;
        
        Case cas = new Case(
            recordtypeId = recordTypeMap.get('Lease_Termination'),
            Status = 'New',                     // Status
            Priority = 'Medium',                               // Priority
            Work_Orders_In_Progress__c = false,                // Work Orders In Progress
            Type = 'Termination',                              // Type
            Contract__c = contr.Id,                // Contract
            Quote__c = q.id,                   // Quote
            ContactId = sobj.id,                  // Contact Name
            Termination_Date__c = system.today().addDays(-10),    // Termination Date
            Move_Out_Date__c = system.today().addDays(30),       // Move Out Date
            Termination_Reason_new__c = 'Lease Cancellation',  // Termination Reason
            Key_Handover_Date__c = system.today().addDays(50), // Key Handover Date
            Financial_Obligation_Date__c = system.today()
        );
        insert cas;
         Case assignmentCase = new Case(
            recordtypeId = recordTypeMap.get('Lease_Termination'),
            Status = 'New',                     // Status
            Priority = 'Medium',                               // Priority
            Work_Orders_In_Progress__c = false,                // Work Orders In Progress
            Type = 'Termination',                              // Type
            Contract__c = contr.Id,                // Contract
            Quote__c = q.id,                   // Quote
            ContactId = sobj.id,                  // Contact Name
            Termination_Date__c = system.today().addDays(-10),    // Termination Date
            Move_Out_Date__c = system.today().addDays(30),       // Move Out Date
            Termination_Reason_new__c = 'Lease Cancellation',  // Termination Reason
            Key_Handover_Date__c = system.today().addDays(50), // Key Handover Date
            Financial_Obligation_Date__c = system.today()
        );
        insert assignmentCase;
        
        
    }
    
    @istest
    private static void testTeremination()
    {
        String responseStr = '{"YardiIntegrationStatus":"Success","YardiIntegrationErrorMessage":"","OpportunityTCode":"123456","OpportunityAmendmentId":1234,"outstandingPayments":[{"description":"testing","chargeCode":"123","vatAmount":1234,"billedAmount":123,"chargeFrom":"2020-01-01","chargeTo":"2020-05-01","opportunityId":""}]}';
        Test.setMock(HttpCalloutMock.class, new NewRenewLeaseMockResponse(responseStr));
        List<Case> updatecase = [Select id, status from case where type ='Termination' ];
        test.startTest();
        updatecase[0].status = 'Brand Sales Approved';
        update updatecase;
        test.stopTest();
    }
    
    @istest
    private static void testAssignment()
    {
        String responseStr = '{"YardiIntegrationStatus":"Success","YardiIntegrationErrorMessage":"","OpportunityTCode":"123456","OpportunityAmendmentId":1234,"outstandingPayments":[{"description":"testing","chargeCode":"123","vatAmount":1234,"billedAmount":123,"chargeFrom":"2020-01-01","chargeTo":"2020-05-01","opportunityId":""}]}';
        Test.setMock(HttpCalloutMock.class, new NewRenewLeaseMockResponse(responseStr));
        List<Case> updatecase = [Select id, status from case where type ='Termination' ];
        test.startTest();
        updatecase[0].status = 'Brand Sales Approved';
        update updatecase;
        test.stopTest();
    }
    
    
}