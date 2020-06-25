/**
 *  @description Test class for WorkOrderToolbarHandler
 *
 *  2019-08-19  Shraddha N    First version
 *  
 */

@isTest
public class EmailMessageTriggerHandlerTest {
	
    //Common test data to be used in test class
    @testSetup
    //@isTest
    public static void setUp(){
       
        //EmailMessageMock fakeResponse = new EmailMessageMock(200, 'Complete', '{"body" : [{"FromName": "sForceTest1"}]}', null);
      	//Test.setMock(HttpCalloutMock.class, fakeResponse); //HttpCalloutMock
        
        Account accountObject = new Account(Name = 'Test',Phone='1111111', Legal_Framework__c = 'Branch of a Foreign Company', Security_Clearance_Date__c = Date.today(), Security_Clearance_Status__c = 'NA', Business_Plan_Request_Date_Approval_Date__c = Date.today());
        insert accountObject;
        
        Contact contactObject = new Contact(LastName = 'Test',Email = 'test.mail@test.com', isSubmit__c = true, ParentCon__c = true, AccountId= accountObject.Id ,Type__c = 'Billing;Leasing Contact;Licensee Contact;Manager Incharge');
        insert contactObject;
        
        Case caseObject = new Case(Status = 'New', ContactId = contactObject.Id);
        insert caseObject;
        
		Lead leadObject = new Lead(LastName = 'Test',Activity_Logged_Time__c = System.today().addDays(2));
		insert leadObject;       
        
        Case caseObj = [SELECT ContactEmail FROM Case WHERE ContactId = :contactObject.Id LIMIT 1];
        
        EmailMessage emailMessageObject = new EmailMessage(ToAddress = caseObj.ContactEmail,
                                                           FromAddress = 'testemail@test.com',
                                                           FromName = 'Test',
                                                           HtmlBody = 'Test Email Message Body',
                                                           MessageDate = System.today(),
                                                           Incoming = FALSE,
                                                           Status = '0',
                                                           ParentId = caseObject.Id);
        insert emailMessageObject;
       
        List<EmailMessage> getEmailMessageObject = [SELECT Id, ActivityId, Incoming, ToAddress FROM EmailMessage LIMIT 1] ;

        Task taskObject = [SELECT Id FROM Task WHERE Id = :getEmailMessageObject[0].ActivityId];
        taskObject.WhatId = null;
        taskObject.WhoId = leadObject.Id;
        update taskObject;
        
        //EmailMessage getEmailMessageObject = [SELECT Id, ActivityId, Incoming, ToAddress FROM EmailMessage LIMIT 1] ;
        
    }
    
   //method to test afterInsert
    @isTest
    public static void afterInsertTest(){
        
        List<EmailMessage> emailMessageList = [SELECT Id, ActivityId, Incoming, ToAddress FROM EmailMessage WHERE Incoming = FALSE];
        
        Test.startTest();
        	EmailMessageTriggerHandler.afterInsert(emailMessageList);
        Test.stopTest();
        Lead leadObject1 = [SELECT Activity_Logged_Time__c FROM Lead WHERE LastName = 'Test' LIMIT 1];
        //System.assertEquals(errorMessage, '');
        System.assertEquals(leadObject1.Activity_Logged_Time__c,DateTime.now() );
    }
  
}