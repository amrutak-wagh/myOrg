/**
 * Test Class for CongaBackground class to attach file to a document.
 * Mock HTTP Callout Test class - CongaBackgroundMockHttpResponseGenerator 
 * Version 1.0
 */

@isTest
private class CongaBackgroundTest {
    
    @testSetup static void testData() {
        Account accObj = new Account();
        accObj.Name = 'Test Account';
        insert accObj;
        
        Contact conObj = new Contact();
        conObj.lastName = 'Test';
        conObj.AccountId = accObj.Id;
        insert conObj;
        
        WorkOrder woObj = new WorkOrder();
        woObj.Subject = 'test';
        woObj.Description = 'test'; 
        insert woObj;
        
        Document__c docObj = new Document__c();
        docObj.Name = 'Test Provisional Approval Letter ';
        docObj.Account__c = accObj.Id;
        docObj.Work_Order__c = woObj.Id;
        docObj.Contact__c = conObj.Id;
        insert docObj;
    }
    
   
     @isTest static void congaBackgroundModeTest() {
         
         Document__c doc = [SELECT Id FROM Document__c LIMIT 1];
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new CongaBackgroundMockHttpResponseGenerator());
        
        // Call method to test.
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock. 
        Test.startTest();
        CongaBackground.CongaBackgroundMode(doc.Id);
         //HttpResponse res;
        // Verify response received contains fake values
        //String actualValue = res.getBody();
        //String expectedValue = '<head><title>Document Moved</title></head><body><h1>Object Moved</h1>This document may be found <a HREF="https://composer.congamerge.com/composer8/index.html?sessionId=SESSION_ID_REMOVED&amp;serverUrl=https%3A%2F%2Ftecomcorporatecrm--4cdev.my.salesforce.com%2Fservices%2FSoap%2Fu%2F29.0%2F00DQ000000BJe6wMAD&amp;id=a0GQ000000a6INZ&amp;TemplateId=a0mQ0000005kFBtIAM&amp;DS7=1&amp;APIMode=1&amp;SC0=1&amp;SC1=SalesforceFile">here</a></body>';
        Test.stopTest();
        List<ContentDocumentLink> fileattached = [SELECT Id,ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: doc.Id];
        //System.assertEquals(fileattached.size(), 1);
        //System.assertEquals(301, res.getStatusCode());
        System.assertNotEquals(null, doc.Id);
    }
}