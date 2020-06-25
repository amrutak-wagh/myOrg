/**
 *  @description Test class for GenerateCCLDocument
 *
 *  2019-07-26  Amruta K   First version
 * 
 */
@isTest
public class GenerateCCLDocumentTest {
     // Method to create test setup data.
	@testSetup static void testData() {
        Account accObj = new Account();
        accObj.Name = 'Test Account';
        insert accObj;
        
        Contact conObj = new Contact();
        conObj.lastName = 'Test';
        conObj.AccountId = accObj.Id;
        insert conObj;
        
        Business_Park__c bParkObj = new Business_Park__c(Name = 'Business', Business_Park_Yardi__c = 'Yardi Park');
        insert bParkObj;
        
        Opportunity oppObj = new Opportunity(
            AccountId = accObj.Id,
            name = accObj.name,
            closedate = system.today(),
            Lease_Type__c = 'land', 
            Opportunity_Type__c = 'Renew',
            stagename='Prospecting',
            Business_Park__c = bParkObj.Id
        );
        insert oppObj;
        
        Quote quoteObj = new Quote(
            Name='01010', 
            OpportunityId=oppObj.Id, 
            Status='Approved',
        	Lease_Start_Date__c = System.today(),
            Lease_End_Date__c = System.today()+10,
            Type__c = 'New',
            Proposed_Start_Date__c = System.today()-10,
            Proposed_End_Date__c = System.today()+10,
            CCL_Sign_Date__c = System.today()
        );
        insert quoteObj;
       
    }
    
    // @isTest Method to test if Payment_Schedules__r is Empty
    public static testMethod void testCreateDocument1(){
        List<Quote> quoteObj = [SELECT Id, Name, OpportunityId, AccountId 
                                FROM Quote LIMIT 1];
        
        Test.setMock(HttpCalloutMock.class, new CongaBackgroundMockHttpResponseGenerator());
        
        Test.startTest();
        String docs = GenerateCCLDocument.createDocument(quoteObj[0].Id);
        Test.stopTest();
        
        System.assertEquals(docs, 'Quote should have one Payment Schedule record to generate CCL document.');
       
    }
    
    // @isTest Method to test if all the conditions are met and result is success
    public static testMethod void testCreateDocument2(){
        List<Quote> quoteObj = [SELECT Id, Name, OpportunityId, AccountId 
                                FROM Quote LIMIT 1];
        Payment_Schedule__c paySchedObj = NEW Payment_Schedule__c(Quote__c = quoteObj[0].Id);
        insert paySchedObj;
        Test.setMock(HttpCalloutMock.class, new CongaBackgroundMockHttpResponseGenerator());
        
        Test.startTest();
        String docs = GenerateCCLDocument.createDocument(quoteObj[0].Id);
        Test.stopTest();
        
        System.assertEquals(docs, 'Success');
      
    }
    
    // @isTest Method to test if Quote list which status is not approved
    public static testMethod void testCreateDocument3(){
        List<Quote> quoteObj = [SELECT Id, Name, OpportunityId, AccountId 
                                FROM Quote LIMIT 1];
        Payment_Schedule__c paySchedObj = NEW Payment_Schedule__c(Quote__c = quoteObj[0].Id);
        insert paySchedObj;
        
		quoteObj[0].Status='Draft';
        update quoteObj;
        Test.setMock(HttpCalloutMock.class, new CongaBackgroundMockHttpResponseGenerator());
        
        Test.startTest();
        String docs = GenerateCCLDocument.createDocument(quoteObj[0].Id);
        Test.stopTest();
        
        System.assertEquals(docs, 'Quote should be Approved to generate CCL document.');
    
    }
}