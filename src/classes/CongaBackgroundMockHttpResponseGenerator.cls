/**
 * Sets mock response for CongaBackground class to attach file to a document.
 * Version 1.0
 */

@isTest
global class CongaBackgroundMockHttpResponseGenerator implements HttpCalloutMock {
    
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
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint and method.
        Document__c doc = [SELECT Id FROM Document__c LIMIT 1];
        String servUrl = 
            Url.getSalesforceBaseUrl().toExternalForm()+'/services/Soap/u/29.0/'+UserInfo.getOrganizationId();
            String curl = 'https://composer.congamerge.com'+
                '?sessionId='+UserInfo.getSessionId()+
                '&serverUrl='+EncodingUtil.urlEncode(servUrl, 'UTF-8')+
                '&id='+doc.Id+
                '&TemplateId=a0mQ0000005kFBtIAM'+
                '&DS7=1'+
                '&APIMode=1'+
                '&SC0=1'+
                '&SC1=SalesforceFile';
        System.assertEquals('GET', req.getMethod());
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setBody('<head><title>Document Moved</title></head><body><h1>Object Moved</h1>This document may be found <a HREF="https://composer.congamerge.com/composer8/index.html?sessionId=SESSION_ID_REMOVED&amp;serverUrl=https%3A%2F%2Ftecomcorporatecrm--4cdev.my.salesforce.com%2Fservices%2FSoap%2Fu%2F29.0%2F00DQ000000BJe6wMAD&amp;id=a0GQ000000a6INZ&amp;TemplateId=a0mQ0000005kFBtIAM&amp;DS7=1&amp;APIMode=1&amp;SC0=1&amp;SC1=SalesforceFile">here</a></body>');
        res.setHeader('Location', 'Content-Location');
        res.setStatusCode(301);
        return res;
    }
}