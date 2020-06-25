/**
 * @who		: Sadiq Adesanya <sadiq.adesanya@weare4c.com>
 * @when	: 18/06/2019
 * @what	: Test for QuoteRevisionCalculations
 */
@isTest
public class QuoteRevisionCalculationsTest{
	
    /**
     * @method		: createTestData()
     * @description	: Test setup method to insert all necessary records
     * @return		: N/A
     * @params		: N/A
     */
	@testSetup static void createTestData(){
        Id standardPricebookId = Test.getStandardPricebookId();
        Test.setMock(HttpCalloutMock.class, new DDAIntegrationMock());
		Product2 prod = new Product2(
                Name = 'Product X',
                ProductCode = 'Pro-X',
                IsActive = true);
		insert prod;

		PricebookEntry pbEntry = new PricebookEntry(
                Pricebook2Id = standardPricebookId,
                Product2Id = prod.Id,
                UnitPrice = 100.00,
                IsActive = true);
		insert pbEntry;

		Business_Park__c businessPark = new Business_Park__c();
		insert businessPark;

		Opportunity opportunity = new Opportunity(
                Name='Test O',
                StageName='Prospecting',
                CloseDate=Date.today(),
                Lease_Type__c='office',
                Business_Park__c=businessPark.Id,
                Opportunity_Type__c='New',
                Pricebook2Id=standardPricebookId);
		insert opportunity;

		Price_Rule__c priceRule = new Price_Rule__c(Name='Test PR');
		insert priceRule;

		Price_Schedule__c priceSchedule = new Price_Schedule__c(
                Grace_Period__c=10,
                Name='Test PC',
                Price_Rule__c=priceRule.Id,
				Grace_Period_Mechanism__c = 'initial',
                Grace_Period_Format__c = 'days',
                Transaction_Type__c = 'New',
                Start_Date__c = Date.Today() + 1,
               End_Date__c = Date.Today() + 100
        );
		insert priceSchedule;

        Quote quote = new Quote(
                Name='Test Q',
                OpportunityId=opportunity.Id,
                Type__c = 'New',
                CCL_Sign_Date__c=Date.today(),
                Pricebook2Id=standardPricebookId,
                Grace_Period__c=10,
                Lease_Start_Date__c=Date.today(),
                Lease_End_Date__c=Date.today().addDays(10),
                Proposed_Start_Date__c = System.today(),
                Proposed_End_Date__c = System.today().addYears(3),
            	Grace_Period_Period__c = 'days',
             	Grace_Period_Mechanism__c = 'initial'
                );
		insert quote;


        Quote quote1 = new Quote(
                Name='Test Q1',
                OpportunityId=opportunity.Id,
                Type__c = 'New',
                CCL_Sign_Date__c=Date.today(),
                Pricebook2Id=standardPricebookId,
                Grace_Period__c=10,
                Lease_Start_Date__c=Date.today(),
                Lease_End_Date__c=Date.today().addDays(10),
                Proposed_Start_Date__c = System.today(),
                Proposed_End_Date__c = System.today().addYears(10),
                Grace_Period_Period__c = 'days',
             	Grace_Period_Mechanism__c = 'initial');
		insert quote1;

        Quote_Revision__c quoteRevision = new Quote_Revision__c(Quote__c=quote.Id);
        insert quoteRevision;

        QuoteLineItem quoteLineItem = new QuoteLineItem(
                QuoteId=quote.Id,
                Quantity=1,
                PricebookEntryId=pbEntry.Id,
                Price_Schedule__c=priceSchedule.Id,
                UnitPrice=10,
                Charge_Code__c='Test',
                Area__c=10,
                Transactional_Unit__c='Sqft',
                Best_Rate__c=10,
                Offer_Price__c=10,
                Default_Grace_Period__c=quote.Grace_Period__c,Type__c='Normal',
                Parent_Quote_Line_Item__c = 'unique',
                Quote_Revision__c = quoteRevision.Id,
                Start_Date__c = System.today(),
                End_Date__c = System.today().addYears(3));
        QuoteLineItem quoteLineItem1 = new QuoteLineItem(
                QuoteId=quote1.Id,
                Quantity=1,
                PricebookEntryId=pbEntry.Id,
                Price_Schedule__c=priceSchedule.Id,
                UnitPrice=10,
                Charge_Code__c='Test',
                Area__c=10,
                Transactional_Unit__c='Sqft',
                Best_Rate__c=10,
                Offer_Price__c=10,
                Default_Grace_Period__c=quote.Grace_Period__c,Type__c='Normal',
                Parent_Quote_Line_Item__c = 'testTwo',
                Quote_Revision__c = quoteRevision.Id,
                Start_Date__c = System.today(),
                End_Date__c = System.today().addYears(3));
        QuoteLineItem quoteLineItem2 = new QuoteLineItem(
                QuoteId=quote1.Id,
                Quantity=1,
                PricebookEntryId=pbEntry.Id,
                Price_Schedule__c=priceSchedule.Id,
                UnitPrice=10,
                Charge_Code__c='Test',
                Area__c=10,
                Transactional_Unit__c='Sqft',
                Best_Rate__c=10,
                Offer_Price__c=10,
                Default_Grace_Period__c=quote.Grace_Period__c,Type__c='Normal',
                Parent_Quote_Line_Item__c = 'testTwo',
                Start_Date__c = System.today(),
                Quote_Revision__c = quoteRevision.Id,
                End_Date__c = System.today().addYears(3));


        insert new List<QuoteLineItem> {quotelineItem, quoteLineItem1,quoteLineItem2};
	}
    
    /**
     * @method		: testThreeYearContract()
     * @description	: test method to test  
     * @return		: N/A
     * @params		: N/A
     */
    private static testMethod void testThreeYearContract() {

        // Get all relevant records
        Price_Schedule__c priceSchedule = [SELECT Id FROM Price_Schedule__c WHERE Name='Test PC'];
        Rate_Increase_Index__c rateIncreaseIndex = new Rate_Increase_Index__c(
                Order__c = 1,
                Percent_Increase__c = 0.0,
                Price_Schedule__c = priceSchedule.Id,
                Duration_Years__c = 2);
        Rate_Increase_Index__c rateIncreaseIndex1 = new Rate_Increase_Index__c(
                Order__c = 2,
                Percent_Increase__c = 0.5,
                Price_Schedule__c = priceSchedule.Id,
                Duration_Years__c = 2);
        insert new List<Rate_Increase_Index__c> {rateIncreaseIndex, rateIncreaseIndex1};

        QuoteLineItem updatedLineItem = [SELECT Id, QuoteId, Quantity, PricebookEntryId, Price_Schedule__c, UnitPrice, Charge_Code__c, Area__c,
                                                Transactional_Unit__c, Best_Rate__c, Offer_Price__c, Type__c, Start_Date__c, End_Date__c, Revision_Number__c
                                         FROM QuoteLineItem WHERE Type__c = 'Normal' AND Parent_Quote_Line_Item__c = 'unique'];
        
        // pass line items and run logic
        Test.startTest();
        QuoteRevisionCalculations.generateQuoteRevisions(new List<QuoteLineItem>{updatedLineItem});
        Test.stopTest();
        
		List<QuoteLineItem> insertedLineItems = [SELECT Id,Type__c, Start_Date__c, Offer_Price__c, Total_Offered_Price__c
                                                FROM QuoteLineItem WHERE Type__c = 'Revision' ORDER BY Revision_Number__c ];
        if(!insertedLineItems.isEmpty()) {
            System.debug('insertedLineItems: ' + insertedLineItems.size());
            // Verify expected behaviour
            System.assertEquals(22 ,insertedLineItems.size());
            System.assertEquals(10,insertedLineItems[0].Offer_Price__c);
            System.assertEquals(10,insertedLineItems[1].Offer_Price__c);
        } else {
            System.assert(false, 'Failed to find quote line revisions.');
        }
    }
    
    /**
     * @method		: testSevenYearContract()
     * @description	: test method should insert 
     * @return		: N/A
     * @params		: N/A
     */
    private static testMethod void testSevenYearContract() {
   		Price_Schedule__c priceSchedule = [SELECT Id FROM Price_Schedule__c WHERE Name='Test PC'];
        QuoteLineItem  insertedTestItem = [SELECT Id, QuoteId, Quantity, PricebookEntryId, Price_Schedule__c, UnitPrice, Charge_Code__c, Area__c,
                                            Transactional_Unit__c, Offer_Price__c, Best_Rate__c, Type__c, Start_Date__c, End_Date__c, Revision_Number__c
                                           FROM QuoteLineItem WHERE Type__c = 'Normal' AND Parent_Quote_Line_Item__c = 'testTwo' LIMIT 1];
        Rate_Increase_Index__c rateIncreaseIndex = new Rate_Increase_Index__c(
                Order__c = 1,
                Percent_Increase__c = 0.1,
                Price_Schedule__c = priceSchedule.Id,
                Duration_Years__c = 2);
        Rate_Increase_Index__c rateIncreaseIndex1 = new Rate_Increase_Index__c(
                Order__c = 2,
                Percent_Increase__c = 0.5,
                Price_Schedule__c = priceSchedule.Id,
                Duration_Years__c = 3);
        Rate_Increase_Index__c rateIncreaseIndex2 = new Rate_Increase_Index__c(
                Order__c = 3,
                Percent_Increase__c = 1.00,
                Price_Schedule__c = priceSchedule.Id,
                Duration_Years__c = 2);
        insert new List<Rate_Increase_Index__c> {rateIncreaseIndex, rateIncreaseIndex1, rateIncreaseIndex2};

        Test.startTest();
        QuoteRevisionCalculations.generateQuoteRevisions(new List<QuoteLineItem>{insertedTestItem});
        Test.stopTest();
        
		List<QuoteLineItem> insertedLineItems = [SELECT Id,Type__c, Start_Date__c, Offer_Price__c, Total_Offered_Price__c
                                                FROM QuoteLineItem WHERE Type__c = 'Revision' ORDER BY Revision_Number__c ];
        if(!insertedLineItems.isEmpty()) {
            System.debug('insertedLineItems: ' + insertedLineItems.size());
            // Verify expected behaviour
            System.assertEquals(29 ,insertedLineItems.size());
            System.assertEquals(10,insertedLineItems[0].Offer_Price__c);
            System.assertEquals(10.01,insertedLineItems[1].Offer_Price__c);
            System.assertEquals(10,insertedLineItems[2].Offer_Price__c);
            System.assertEquals(10,insertedLineItems[3].Offer_Price__c);
            System.assertEquals(10,insertedLineItems[4].Offer_Price__c);
            System.assertEquals(10.05,insertedLineItems[5].Offer_Price__c);
            System.assertEquals(10,insertedLineItems[6].Offer_Price__c);
            System.assertEquals(10,insertedLineItems[7].Offer_Price__c);
            System.assertEquals(10,insertedLineItems[8].Offer_Price__c);
        } else {
            System.assert(false, 'Failed to find quote line revisions.');
        }
    }
    
    /**
     * @method		: testQuoteDateChange()
     * @description	: test method should insert 
     * @return		: N/A
     * @params		: N/A
     */
    private static testMethod void testQuoteDateChange() {
        Price_Schedule__c priceSchedule = [SELECT Id FROM Price_Schedule__c WHERE Name='Test PC'];
        Quote quote = [SELECT Id, Proposed_Start_Date__c, Proposed_End_Date__c FROM Quote WHERE Name = 'Test Q1'];
        
        QuoteLineItem  insertedTestItem = [SELECT Id, QuoteId, Quantity, PricebookEntryId, Price_Schedule__c, UnitPrice, Charge_Code__c, Area__c,
                                            Transactional_Unit__c, Offer_Price__c, Best_Rate__c, Type__c, Start_Date__c, End_Date__c, Revision_Number__c, Parent_Quote_Line_Item__c
                                           FROM QuoteLineItem WHERE Type__c = 'Normal' AND Parent_Quote_Line_Item__c = 'testTwo' LIMIT 1];
        Rate_Increase_Index__c rateIncreaseIndex = new Rate_Increase_Index__c(
                Order__c = 1,
                Percent_Increase__c = 0.1,
                Price_Schedule__c = priceSchedule.Id,
                Duration_Years__c = 2);
        Rate_Increase_Index__c rateIncreaseIndex1 = new Rate_Increase_Index__c(
                Order__c = 2,
                Percent_Increase__c = 0.5,
                Price_Schedule__c = priceSchedule.Id,
                Duration_Years__c = 3);
        Rate_Increase_Index__c rateIncreaseIndex2 = new Rate_Increase_Index__c(
                Order__c = 3,
                Percent_Increase__c = 1.00,
                Price_Schedule__c = priceSchedule.Id,
                Duration_Years__c = 2);
        insert new List<Rate_Increase_Index__c> {rateIncreaseIndex, rateIncreaseIndex1, rateIncreaseIndex2};

        QuoteRevisionCalculations.generateQuoteRevisions(new List<QuoteLineItem>{insertedTestItem});
        insertedTestItem.Parent_Quote_Line_Item__c = null;
        update insertedTestItem;
        
		List<QuoteLineItem> insertedLineItems = [SELECT Id,Type__c, Start_Date__c, Offer_Price__c, Total_Offered_Price__c
                                                FROM QuoteLineItem WHERE Type__c = 'Revision' ORDER BY Revision_Number__c ];
        if(!insertedLineItems.isEmpty()) {
            System.debug('insertedLineItems: ' + insertedLineItems.size());
            // Verify expected behaviour
            System.assertEquals(29 ,insertedLineItems.size());
            System.assertEquals(10,insertedLineItems[0].Offer_Price__c);
            System.assertEquals(10.01,insertedLineItems[1].Offer_Price__c);
        } else {
            System.assert(false, 'Failed to find quote line revisions.');
        }
        Quote clonedQuote = quote.clone(true, true, false, false);
        quote.Proposed_End_Date__c = System.today().addYears(6);
        update quote;
        
        quote = [SELECT Id, Proposed_Start_Date__c, Proposed_End_Date__c FROM Quote WHERE Name = 'Test Q1'];
        Test.startTest();
        QuoteRevisionCalculations.handleQuoteUpdate(new Map<Id, Quote>{clonedQuote.Id => clonedQuote}, new Map<Id, Quote>{quote.Id => quote});
        Test.stopTest();
        
        insertedLineItems = [SELECT Id,Type__c, Start_Date__c, Offer_Price__c, Total_Offered_Price__c FROM QuoteLineItem WHERE Type__c = 'Revision' ORDER BY Revision_Number__c ];
        if(!insertedLineItems.isEmpty()) {
            System.debug('insertedLineItems: ' + insertedLineItems.size());
            // Verify expected behaviour
            System.assertEquals(2 ,insertedLineItems.size());
            System.assertEquals(10,insertedLineItems[0].Offer_Price__c);
            System.assertEquals(10,insertedLineItems[1].Offer_Price__c);
            //System.assertEquals(15,insertedLineItems[2].Offer_Price__c);
            //System.assertEquals(15,insertedLineItems[3].Offer_Price__c);
            //System.assertEquals(20,insertedLineItems[4].Offer_Price__c);            
        }

    }

    /*
    * @method rollUpQuoteRevisions
    * @case when inserting a new QuoteLineItem with a QuoteRevision
    * @result expect QuoteRevion's total fields to be updated with the correct values
    */
    private static testMethod void insertQuoteRevisionLineItem() {

        List<Quote_Revision__c> revisions = [SELECT Id, Total_Best_Rate__c, (SELECT Id FROM Quote_Line_Items__r), Total_Offered_Price__c FROM Quote_Revision__c];
        for(Quote_Revision__c revision:revisions){
            if(!revision.Quote_Line_Items__r.isEmpty()){
                System.assertNotEquals(null, (Integer) revision.Total_Best_Rate__c);
                System.assertNotEquals(null, (Integer) revision.Total_Offered_Price__c);
            }
        }
    }

      /*
    * @method rollUpQuoteRevisions
    * @case when updating a new QuoteLineItem with a QuoteRevision
    * @result expect QuoteRevion's total fields to be updated with the correct values
    */
    private static testMethod void updateQuoteRevisionLineItem() {

        List<QuoteLineItem> lineItems = [SELECT Id FROM QuoteLineItem];
        lineItems.get(0).Best_Rate__c = 20;
        lineItems.get(0).Offer_Price__c = 20;
        update lineItems;
        
        List<Quote_Revision__c> revisions = [SELECT Id, Total_Best_Rate__c, (SELECT Id FROM Quote_Line_Items__r), Total_Offered_Price__c FROM Quote_Revision__c];
        for(Quote_Revision__c revision:revisions){
            if(!revision.Quote_Line_Items__r.isEmpty()){
                System.assertEquals(200, (Integer) revision.Total_Best_Rate__c);
                System.assertEquals(200, (Integer) revision.Total_Offered_Price__c);
            }
        }
    }

    private static testMethod void deleteQuoteRevisionLineItem() {

        List<QuoteLineItem> lineItems = [SELECT Id FROM QuoteLineItem];
        delete lineItems.get(0);
        
        List<Quote_Revision__c> revisions = [SELECT Id, Total_Best_Rate__c, (SELECT Id FROM Quote_Line_Items__r), Total_Offered_Price__c FROM Quote_Revision__c];
        for(Quote_Revision__c revision:revisions){
            if(!revision.Quote_Line_Items__r.isEmpty()){
                System.assertEquals(200, (Integer) revision.Total_Best_Rate__c);
                System.assertEquals(200, (Integer) revision.Total_Offered_Price__c);
            }
        }
    }

}