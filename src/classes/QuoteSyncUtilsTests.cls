/*
 * @Who   Cameron Stewart <cameron.stewart@weare4c.com>
 * @What  A test class for verifying the quote syncing line item deletion
 * @When  24/6/2019
 */
@isTest
public class QuoteSyncUtilsTests {
    
    @testSetup
    static void createTestData() {
        
        Product2 productRecord = new Product2(Name = 'Test', IsActive = True);
        insert productRecord;
        
        PricebookEntry pricebookEntryRecord = new PriceBookEntry(Product2Id = productRecord.Id, Pricebook2Id = test.getStandardPricebookId(), UnitPrice = 100, IsActive = true);
        insert pricebookEntryRecord;
        
        Business_Park__c businessPark = new Business_Park__c();
        insert businessPark;
        
        Opportunity opportunityRecord = new Opportunity(Name = 'Test', StageName = 'New', CloseDate = date.today().addDays(0), Business_Park__c = businessPark.Id, PriceBook2Id = test.getStandardPricebookId());
        insert opportunityRecord;
        
        //OpportunityLineItem opportunityLineItemRecord = new OpportunityLineItem(OpportunityId = opportunityRecord.Id, PricebookEntryId = pricebookEntryRecord.Id, Quantity = 1, TotalPrice = 100);
        //insert opportunityLineItemRecord;
        
        Quote quoteRecord = new Quote(OpportunityId = opportunityRecord.Id, Name = 'Test', Proposed_Start_Date__c = date.today(), Proposed_End_Date__c = date.today().addDays(1), PriceBook2Id = test.getStandardPricebookId());
        insert quoteRecord;
        
        QuoteLineItem quoteLineItem = new QuoteLineItem(QuoteId = quoteRecord.Id, Quantity = 1, PricebookEntryId = pricebookEntryRecord.Id, UnitPrice = 100, Product2Id = productRecord.Id);
        insert quoteLineItem;
        
        opportunityRecord.SyncedQuoteId = quoteRecord.Id;
        update opportunityRecord;
    }
	
    @isTest static void happyPathCheck() {
        
        Opportunity opportunityRecord  = [SELECT Id, SyncedQuoteId FROM Opportunity];
        opportunityRecord.SyncedQuoteId = null;
        
        test.startTest();
        update opportunityRecord;
        test.stopTest();

        System.assertEquals(1, [Select Id From OpportunityLineItem].size());
        
    }
}