/************************************************************************************
* Name          : ExpansionControllerTest                                                 
* Description   : Test class for lightning component 'Expansion'
* Created Date  : 27/08/2019                                                   
* Created By    : Adeel Ahmad (adeel.ahmad@weare4c.com)
************************************************************************************/
@isTest
public class ExpansionControllerTest {
    
    public static testMethod void testExpensionProcess(){
        Account account = TestDataFactory.getAccountWithContact();
        Business_Park__c bp = TestDataFactory.getBusinessParkWithUnits();
        Opportunity opp = TestDataFactory.getOpportunityWithQuote(account.Id, bp.Id, Date.today(), Date.today().addDays(5));
		Quote quote = [SELECT Id FROM Quote WHERE OpportunityId =:opp.Id];
        Building__c b = [SELECT Id,Building_Code__c FROM Building__c LIMIT 1];
		
        opp.SyncedQuoteId = quote.Id;
        opp.Building_Name__c = b.Building_Code__c;
        opp.Lease_End_Date__c = Date.today().addDays(25);
        opp.Lease_Start_Date__c = Date.today();
        update opp;
        
        Opportunity newOpp = new Opportunity();
        newOpp.Lease_Start_Date__c = Date.today();
        newOpp.Lease_End_Date__c = Date.today().addDays(100);
        
        //Testing quote record.
        Quote oppQuote = ExpansionController.getQuoteRecord(opp.Id);
        System.assert(oppQuote.Id != null);
        
        //Inserting QLI for save
        Quote_Revision__c revisionObj = new Quote_Revision__c(Quote__c = oppQuote.Id,
                                                              Total_Best_Rate__c = 300,
                                                              Total_Offered_Price__c = 500
                                                            );
        insert revisionObj;
        
        Product2 prod = new Product2(Name = 'testProd',isActive = true,Unique_Key__c = 'pricingEngineTestProd' );
        insert prod;
        
        PricebookEntry pbe = new PricebookEntry(isActive = true,UnitPrice = 100,Product2Id = prod.Id,
                                                Pricebook2Id = Test.getStandardPricebookId(),CurrencyIsoCode = 'AED');
        insert pbe;
        
        QuoteLineItem qliObject = new QuoteLineItem(
                                                    Best_Rate__c = 100,
                                                    Offer_Price__c = 80,
                                                    PricebookEntryId = pbe.Id,
                                                    Quantity = 1,
                                                    UnitPrice = 100,
                                                    Start_Date__c = Date.Today() + 120,
                                                    End_Date__c = Date.Today() + 120 + 365,
                                                    Type__c = 'Normal',
                                                    Area__c = 1000,
                                                    Transactional_Unit__c = 'Sqft',
                                                    Quote_Revision__c = revisionObj.Id,
                                                    Product2Id = prod.Id);
        
        LIST<ExpansionController.LineItem> lineItems = new LIST<ExpansionController.LineItem>();
        ExpansionController.LineItem item = new ExpansionController.LineItem();
        item.quoteLineItem = qliObject;
        lineItems.add(item);

        LIST<ExpansionController.BuildingOptions> buildingInfo = ExpansionController.fetchBuildingInfo(opp.Id);
        ExpansionController.PageLayoutWrapper wrp = ExpansionController.fetchPageLayouts(opp.Id, quote.Id);
        String str = ExpansionController.save(opp.Id, lineItems, newOpp);
        System.debug('@@str='+str);
    }
}