/************************************************************************************
* Name          : ExpansionControllerTest                                                 
* Description   : Test class for lightning component 'Expansion'
* Created Date  : 28/08/2019                                                   
* Created By    : Adeel Ahmad (adeel.ahmad@weare4c.com)
************************************************************************************/
@isTest
public class DownsizeController_V2Test {
	
    public static testMethod void testDownsize_V1(){
        Account account = TestDataFactory.getAccountWithContact();
        Business_Park__c bp = TestDataFactory.getBusinessParkWithUnits();
        Opportunity opp = TestDataFactory.getOpportunityWithQuote(account.Id, bp.Id, Date.today(), Date.today().addDays(5));
		Quote quote = [SELECT Id FROM Quote WHERE OpportunityId =:opp.Id];
		
        opp.SyncedQuoteId = quote.Id;
        update opp;
        
        Test.startTest();
            //Testing quote record.
            Quote q = DownsizingController_V2.getQuoteRecord(opp.Id);
            System.assert(q.Id != null);
            
            //Fetching quote line items
            LIST<QuoteLineItem> qli = DownsizingController_V2.fetchQuoteLineItems(q.Id);
        	System.assert(qli != null);
        
            //Fetching page layouts
            DownsizingController_V2.PageLayoutWrapper pr = DownsizingController_V2.fetchPageLayouts();
            
			//Testing save
			String str = DownsizingController_V2.save(opp.Id, String.valueOf(Date.today().addDays(100)), '');
            System.assert(str == 'SUCCESS');
        Test.stopTest();
    }
    
}