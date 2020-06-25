/***********************************************************************************************
* Name              : LeadTriggerConvertTest                                                 
* Description       : LeadTriggerConvertTest test class for LeadTriggerConvert
* Created Date      : 23/07/2019                                                    
* Created By        : Amruta K                                                                                    
* ----------------------------------------------------------------------------------------------
* VERSION   Developer   Date        Description     Ticket/Reference                                                                    
* 1.0       Divya       23/07/2019   Created                              
************************************************************************************************/
@isTest
public class LeadTriggerConvertTest {
    
    // Method to test leadConvert method.
    testMethod static void leadConvertTestCase() {
        
        Business_Park__c businessPark = new Business_Park__c(
                Name = 'D3'
        );
        insert businessPark;
        
        Lead lead=new Lead(LastName='Doe',
                           FirstName='John',
                           Company='Test',
                           Status='Inquiry', 
                           Business_Park__c = businessPark.Id, 
                           Product_Category__c = 'Land',
                           Email = 'test@gmail.com',
                           TempOwnerId__c = 'SKIP');
        insert lead;             
        
        LeadStatus convertStatus = [Select Id, MasterLabel from LeadStatus where IsConverted=true limit 1];
        
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(lead.id);
        lc.setConvertedStatus(convertStatus.MasterLabel);
        
        Task t = new Task();
        t.OwnerId = UserInfo.getUserId();
        t.Subject='Donni';
        t.Status='Not Started';
        t.Priority='Normal';
        t.WhoId = lead.Id;
        insert t; 

        Database.LeadConvertResult lcr;
        
        Test.startTest();
        	lcr = Database.convertLead(lc);
        Test.stopTest();
        
        List<WorkOrder> insertedWorkOrderList = [SELECT Id FROM WorkOrder];
        List<Case> insertedCaseList = [SELECT Id FROM Case];
        
        System.assertEquals(insertedWorkOrderList.size(), 1);
        System.assertEquals(insertedCaseList.size(), 2);
    }
    // Method to test afterCovertUpdateContactOnOpportunity method.
     testMethod static void afterCovertUpdateContactOnOpportunityTestCase() {
        
        Business_Park__c businessPark = new Business_Park__c(
                Name = 'D3'
        );
        insert businessPark;
        
        Lead lead=new Lead(LastName='Doe',
                           FirstName='John',
                           Company='Test',
                           Status='Inquiry', 
                           Business_Park__c = businessPark.Id, 
                           Product_Category__c = 'Land',
                           Email = 'test@gmail.com',
                           TempOwnerId__c = 'SKIP');
        insert lead;             
        
        LeadStatus convertStatus = [Select Id, MasterLabel from LeadStatus where IsConverted=true limit 1];
        
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(lead.id);
        lc.setConvertedStatus(convertStatus.MasterLabel);
        
        Task t = new Task();
        t.OwnerId = UserInfo.getUserId();
        t.Subject='Donni';
        t.Status='Not Started';
        t.Priority='Normal';
        t.WhoId = lead.Id;
        insert t; 

        Database.LeadConvertResult lcr;
        
        Test.startTest();
        	lcr = Database.convertLead(lc);
        Test.stopTest();
        
		List<Opportunity> oppList = [SELECT Id, Contact__c FROM Opportunity WHERE Id =: lcr.getOpportunityId()];
        
         System.assertEquals(oppList[0].Contact__c,  lcr.getContactId());
    }

}