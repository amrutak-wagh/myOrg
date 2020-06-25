/***********************************************************************************************
* Name              : AccountIntegrationOracleERPTest                                               
* Description       : Test class to test AccountIntegrationOracleERP class
* Created Date      :                                                                                                                                                    
* ----------------------------------------------------------------------------------------------
* VERSION   Developer   Date        Description     Ticket/Reference                                                                    
************************************************************************************************/
@istest
public class AccountIntegrationOracleERPTest {
    //Method to test updated accounts to be sent to Oracle
    @istest
    private static void accountOracleIntegrationTest()
    {
        String responseStr = '{"ORACLE_PARTY_ID__c":"12345","Oracle_Integration_Error_Message__c":"","Oracle_Customer_Id__c":"12345","Oracle_Customer_Number__c":"12345","Oracle_Integration_Status__c":"S"}';
        Test.setMock(HttpCalloutMock.class, new NewRenewLeaseMockResponse(responseStr));   
        List<Id> accLst = new List<Id>();
        test.startTest();
        Account acc = TestDataFactory.getAccountWithContact();
        accLst.add(acc.Id);
        AccountIntegrationOracleERP.sendAccountsToOracle(accLst);
        test.stopTest();
        
        List<Account> accUpdatedList = [SELECT Id, Name, Oracle_Integration_Status__c FROM Account];
        System.assertEquals(accUpdatedList[0].Oracle_Integration_Status__c, 'S');
    } 
    //Negative test accountOracleIntegrationOracleERP
    @istest
    private static void accountOracleIntegrationNegativeTest()
    {
        String responseStr = '';
        Test.setMock(HttpCalloutMock.class, new NewRenewLeaseMockResponse(responseStr));   
        List<Id> accLst = new List<Id>();
        
        
        try {
            test.startTest();
            Account acc = TestDataFactory.getAccountWithContact();
            accLst.add(acc.Id);
            AccountIntegrationOracleERP.sendAccountsToOracle(accLst);
            
            test.stopTest();
            
            List<Account> accUpdatedList = [SELECT Id, Name, Oracle_Integration_Status__c FROM Account];
        }
        catch(Exception e) {
            System.assertEquals(e.getMessage(), 'No content to map to Object due to end of input');
        }
    } 
    
    @istest
    private static void accountIntegrationStatusTest()
    {
         String responseStr = '{"ORACLE_PARTY_ID__c":"12345","Oracle_Integration_Error_Message__c":"","Oracle_Customer_Id__c":"12345","Oracle_Customer_Number__c":"12345","Oracle_Integration_Status__c":"S"}';
        Test.setMock(HttpCalloutMock.class, new NewRenewLeaseMockResponse(responseStr)); 
         try {
        Account acc = TestDataFactory.getAccountWithContact();
        Contact cont = [Select id, type__c from contact where accountid =:acc.id];
        cont.Type__c = 'Billinng';
        update cont;
        Case sobj = new Case(
            Status = 'New',                   // Status
            Priority = 'Medium',                // Priority
            Work_Orders_In_Progress__c = false , // Work Orders In Progress
            accountId = acc.id,
            recordtypeId = [select id from recordtype where developername = 'On_Boarding_Premise' limit 1].id,
            contactid = cont.id
            
        );
        insert sobj;
        List<workorder> worders = [SELECT Id, Status, CaseId FROM WorkOrder where caseId =: sobj.id ];
        for(workorder wo: worders)
        {
            wo.status = 'Approved';
        }
        update worders;
       // sobj.Work_Orders_In_Progress__c = false;
        //update sobj;
         //String responseStr = '{"ORACLE_PARTY_ID__c":"12345","Oracle_Integration_Error_Message__c":"","Oracle_Customer_Id__c":"12345","Oracle_Customer_Number__c":"12345","Oracle_Integration_Status__c":"S"}';
        //Test.setMock(HttpCalloutMock.class, new NewRenewLeaseMockResponse(responseStr)); 
        test.startTest();
        sobj.Status = 'Closed - Approved';
        update sobj;
        test.stopTest();
         } catch(Exception e)
         {
             
         }
        
    }
}