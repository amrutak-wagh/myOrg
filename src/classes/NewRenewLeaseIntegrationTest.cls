/***********************************************************************************************
* Name              : NewRenewLeaseIntegrationTest                                               
* Description       : Test class to test NewRenewLeaseIntegration integration
* Created Date      :                                                                                                                                                    
* ----------------------------------------------------------------------------------------------
* VERSION   Developer   Date        Description     Ticket/Reference                                                                    
************************************************************************************************/
@istest
public class NewRenewLeaseIntegrationTest {
    
    @TestSetup
    private static void setupData()
    {
        PricingUtilsTest.createData();
    }
    
    //Method to test sendLeaseToOIC method
    @istest
    private static void sendNewLeaseTest()
    {
        string response = '{"yardiIntegrationStatus":"Success","yardiIntegrationErrorMessage":"Successfully Imported. SF Lease Status - Approved","opportunityTCode":"t0003396","opportunityAmendmentId":"5383","paymentSchedule":[{"propertyCode":"d3_b05 ","tenantCode":"t0003396","description":"Rental Income - Office","chargeCode":"rntoff ","billedAmount":"10.83","chargeFrom":"2019-07-16","chargeTo":"2019-08-15","quoteId":"0Q0Q0000000TzjBKAS"}]}';
        Test.setMock(HttpCalloutMock.class, new NewRenewLeaseMockResponse(response));
        List<Quote> quotes = [Select id, status, OpportunityId from Quote where name = 'Test Quote'];
        Turn_Over_Rent__c sobj = new Turn_Over_Rent__c(
            Quote__c = quotes[0].id,
            Retail_Start_Date__c = system.today().addDays(-30),   // Retail Start Date
            Retail_End_Date__c =  system.today().addDays(30),    // Retail End Date
            Sales_Report_Frequency__c = '4',            // Sales Report Frequency
            Retail_Billing_Frequency__c = '4',          // Retail Billing Frequency
            BreakPoint_Frequency__c = '4',              // BreakPoint Frequency
            Sales_End_Of_Year__c = '1',                  // Sales End Of Year
            Overage_From_Date__c =  system.today().addDays(30),  // Overage From Date
            Overage_To_Date__c =  system.today().addDays(60),    // Overage To Date
            Natural_Breakpoint__c = '1',                     // Natural Breakpoint
            Natural_Breakpoint_Percentage__c = 15,             // Natural Breakpoint Percentage
            Overage_Offset_Type__c = '1',           // Overage Offset Type
            Overage_Offset_Account_Charge_Code_1__c = '10'    // Overage Offset Account Charge Code 1
        );
        insert sobj;
          
        quotes[0].status = 'Approved';
        update  quotes[0];
        test.startTest();
     
        NewRenewLeaseIntegration.sendLeaseToOIC(new List<Id>{quotes[0].id});
        quotes[0].status = 'Accepted';
        update  quotes[0];
        //NewRenewLeaseIntegration.sendLeaseToOIC(new List<Id>{quotes[0].id});
        test.stopTest();
        
        List<Payment_Schedule__c> paymenySchedulesInserted = [SELECT Id, Name FROM Payment_Schedule__c];
        System.assertEquals(paymenySchedulesInserted.size(),1,'Size of payment schedules');
        
        List<Opportunity> oppLst = [SELECT Id, Name FROM Opportunity];
        List<Quote> quoteLst = [SELECT Id, Name,OpportunityId FROM Quote];
        
        System.assertEquals(oppLst[0].Id, quoteLst[0].OpportunityId);
    }
    
    //Method to test sendHSEStatus method
    @istest
    private static void sendHseStatusTest()
    {
        string response = '{"yardiIntegrationStatus":"Success","yardiIntegrationErrorMessage":"Hse status imported successfully"}';
        Test.setMock(HttpCalloutMock.class, new NewRenewLeaseMockResponse(response));
        List<Opportunity> opportunities = [Select id, HSE_Status__c  from Opportunity where name = 'Test Opp'];
        
        test.startTest();
        opportunities[0].HSE_Status__c = 'Approved';
        update  opportunities[0]; 
        NewRenewLeaseIntegration.hseOpportunityStatus(new List<Id>{opportunities[0].id});
        test.stopTest();
        
        List<Opportunity> updatedOppLst = [Select id, HSE_Status__c  from Opportunity where name = 'Test Opp']; 
        System.assertEquals(updatedOppLst[0].HSE_Status__c, opportunities[0].HSE_Status__c);
    }
    
    //Method to test sendApprovedQuote method
    @istest
    private static void sendApprovedQuotesTest(){
        Map<Id, Quote> quoteIdVsQUoteOldmap = new  Map<Id, Quote>();
        List<Quote> newQuoteList = new List<Quote>();
        List<Quote> quoteList = [SELECT Id, Status FROM Quote WHERE Name = 'Test Quote'];
        
        for(Quote quoteObject :quoteList){
            quoteIdVsQUoteOldmap.put(quoteObject.Id, quoteObject);
            Quote quoteObject2 = quoteObject.clone(true,true);
            quoteObject2.Status = 'Approved';
            newQuoteList.add(quoteObject2);
        }
        
        Test.startTest();
        NewRenewIntegrationIntegrationUtil.sendApprovedQuote(newQuoteList, quoteIdVsQUoteOldmap);
        Test.stopTest();
        
        System.assertNotEquals(newQuoteList, NULL);
        System.assertNotEquals(quoteIdVsQUoteOldmap, NULL);
        System.assertEquals(newQuoteList[0].Status, 'Approved');
    }
    
    //Method to test sendCclSignedQuote method
    @istest
    private static void sendCclSignedQuoteTest(){
        Map<Id, Quote> quoteIdVsQUoteOldmap = new  Map<Id, Quote>();
        List<Quote> newQuoteList = new List<Quote>();
        List<Quote> quoteList = [SELECT Id, Status FROM Quote WHERE Name = 'Test Quote'];
        
        for(Quote quoteObject :quoteList){
            quoteIdVsQUoteOldmap.put(quoteObject.Id, quoteObject);
            Quote quoteObject2 = quoteObject.clone(true,true);
            quoteObject2.Status = 'Accepted';
            newQuoteList.add(quoteObject2);
        }
        
        Test.startTest();
        NewRenewIntegrationIntegrationUtil.sendCclSignedQuote(newQuoteList, quoteIdVsQUoteOldmap);
        Test.stopTest();
        
        System.assertNotEquals(newQuoteList, NULL);
        System.assertNotEquals(quoteIdVsQUoteOldmap, NULL);
        System.assertEquals(newQuoteList[0].Status, 'Accepted');
    }
    
}