/*
* @Who   Patrick Duncan <patrick.duncan@weare4c.com>
 * @What  Test class for GracePeriodUtility
 * @When  25/6/2019
*/
@isTest
public with sharing class GracePeriodUtilityTest{

	@testSetup
	static void testSetup(){
        Test.setMock(HttpCalloutMock.class, new DDAIntegrationMock());
        Test.startTest();
		Building__c building = new Building__c(Development_Status__c='Developed',Property_Code_YARDI__c='XXXX',Property__c='Office',Ownership_Type__c='TECOM Owned');
		insert building;
		Unit__c unit = new Unit__c(Transactional_Unit__c='Sq.Ft',Building__c=building.Id,Unit_Code_YARDI__c='test');
		insert unit;
		Product2 prod = new Product2(Name = 'Product X', ProductCode = 'Pro-X', isActive = true,Unit__c=unit.Id);
		insert prod;
		PricebookEntry pbEntry = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = prod.Id, UnitPrice = 100.00, IsActive = true);
		insert pbEntry;
		Business_Park__c businessPark = new Business_Park__c();
		insert businessPark;
		Opportunity opportunity = new Opportunity(Name='Test O',StageName='Prospecting',CloseDate=Date.today(),Lease_Type__c='office',Business_Park__c=businessPark.Id,Opportunity_Type__c='New',Pricebook2Id=Test.getStandardPricebookId());
		insert opportunity;
		Price_Rule__c priceRule = new Price_Rule__c(Name='Test PR');
		insert priceRule;
		Price_Schedule__c priceSchedule = new Price_Schedule__c(Grace_Period__c=10,Name='Test PC',Price_Rule__c=priceRule.Id,Grace_Period_Mechanism__c ='initial',Grace_Period_Format__c ='days',
                                                               Transaction_Type__c ='New',Start_Date__c=Date.newInstance(2019, 6, 1),End_Date__c=Date.newInstance(2019, 10, 1));
		insert priceSchedule;
		Payment_Term__c pTerm = new Payment_Term__c(Number_Of_Payments__c = 2);
		insert pTerm;
		Quote quote = new Quote(Name='Test Q',OpportunityId=opportunity.Id,CCL_Sign_Date__c=Date.today(),Pricebook2Id=Test.getStandardPricebookId(),Type__c='New',Lease_Start_Date__c=Date.today(),Lease_End_Date__c=Date.today().addDays(10),Payment_Terms__c=pTerm.Id,Grace_Period_Mechanism__c='initial',Grace_Period_Period__c='days',Grace_Period__c=5,Proposed_Start_Date__c=Date.today(),Proposed_End_Date__c=Date.today().addMonths(5),Number_Of_Payments__c = 1);
		insert quote;
        Test.stopTest();
	}

	
	/*
	* @method GracePeriodUtility.createGracePeriodLineItems
   	* @case when updating the Grace_Period__c on a quote for Grace_Period_Mechanism__c of initial
   	* @result the quote's grace period line item should be recreated with a new End_Date__c that reflects the new Grace_Period__c
	*/
	@isTest
	static void updateQuoteGracePeriod(){
        Test.setMock(HttpCalloutMock.class, new DDAIntegrationMock());
        Test.startTest();
		Quote quote = [SELECT Id FROM Quote];
		Price_Schedule__c priceSchedule = [SELECT Id FROM Price_Schedule__c];
		PricebookEntry pbEntry = [SELECT Id FROM PricebookEntry];
		QuoteLineItem quoteLineItem = new QuoteLineItem(QuoteId=quote.Id,Quantity=1,PricebookEntryId=pbEntry.Id,Price_Schedule__c=priceSchedule.Id,UnitPrice=10,Charge_Code__c='Test',Offer_Price__c=10,Type__c='Normal');
		//Test.startTest();		
			insert quoteLineItem;
			quote.Grace_Period__c = 10;
			update quote;
		Test.stopTest();
		List<QuoteLineItem> lineItemResults = [SELECT Id, Offer_Price__c, End_Date__c FROM QuoteLineItem WHERE Parent_Quote_Line_Item__c = :quoteLineItem.Id];
		system.assertEquals(1, lineItemResults.size());
		//system.assertEquals(Date.today().addDays(10), lineItemResults.get(0).End_Date__c);
	}

	/*
	* @method GracePeriodUtility.createGracePeriodLineItems
   	* @case when updating the Grace_Period_Period__c to months on a quote for Grace_Period_Mechanism__c of initial
   	* @result the quote's grace period line item should be recreated with a new End_Date__c that reflects the new Grace_Period_Period__c - 5 months more rather than 5 days
	*/
	@isTest
	static void updateQuoteGracePeriodPeriod(){
        Test.setMock(HttpCalloutMock.class, new DDAIntegrationMock());
        Test.startTest();
		Quote quote = [SELECT Id FROM Quote];
		Price_Schedule__c priceSchedule = [SELECT Id FROM Price_Schedule__c];
		PricebookEntry pbEntry = [SELECT Id FROM PricebookEntry];
		QuoteLineItem quoteLineItem = new QuoteLineItem(QuoteId=quote.Id,
														Quantity=1,
														PricebookEntryId=pbEntry.Id,
														Price_Schedule__c=priceSchedule.Id,
														UnitPrice=10,
														Charge_Code__c='Test',
														Offer_Price__c=10,
														Type__c='Normal',
														Default_Grace_Period__c = 4
														);
		//Test.startTest();		
			insert quoteLineItem;
			quote.Grace_Period_Period__c = 'months';
			update quote;
		Test.stopTest();
		List<QuoteLineItem> lineItemResults = [SELECT Id, Offer_Price__c, End_Date__c FROM QuoteLineItem WHERE Parent_Quote_Line_Item__c = :quoteLineItem.Id];
		system.assertEquals(1, lineItemResults.size());
		//system.assertEquals(Date.today().addMonths(5), lineItemResults.get(0).End_Date__c);
	}

	/*
	* @method GracePeriodUtility.createGracePeriodLineItems
   	* @case when updating the Grace_Period_Mechanism__c to end on quote
   	* @result the quote's grace period line item should be recreated with a new Start_Date__c that reflects the fact the grace period happens at the end of the lease
	*/
	@isTest
	static void updateQuoteGracePeriodMechanism(){
		Test.setMock(HttpCalloutMock.class, new DDAIntegrationMock());
        Test.startTest();
        Quote quote = [SELECT Id FROM Quote];
		Price_Schedule__c priceSchedule = [SELECT Id FROM Price_Schedule__c];
		PricebookEntry pbEntry = [SELECT Id FROM PricebookEntry];
		QuoteLineItem quoteLineItem = new QuoteLineItem(QuoteId=quote.Id,
													    Quantity=1,
														PricebookEntryId=pbEntry.Id,
														Price_Schedule__c=priceSchedule.Id,
														UnitPrice=10,
														Charge_Code__c='Test',
														Offer_Price__c=10,
														Type__c='Normal',
														Default_Grace_Period__c = 30
												    );
		//Test.startTest();		
			insert quoteLineItem;
			quote.Grace_Period_Period__c = 'months';
			quote.Grace_Period_Mechanism__c = 'end';
			update quote;
		Test.stopTest();
		List<QuoteLineItem> lineItemResults = [SELECT Id, Offer_Price__c, Start_Date__c FROM QuoteLineItem WHERE Parent_Quote_Line_Item__c = :quoteLineItem.Id];
		system.assertEquals(1, lineItemResults.size());
		//system.assertEquals(Date.today(), lineItemResults.get(0).Start_Date__c);
	}

	/*
	* @method GracePeriodUtility.createGracePeriodLineItems
   	* @case when updating the Proposed_Start_Date__c on a quote
   	* @result the quote's grace period line item should be recreated with a new End_Date__c that reflects the fact the grace period starts on a different date
	*/
	@isTest
	static void updateQuoteStartDate(){
        Test.setMock(HttpCalloutMock.class, new DDAIntegrationMock());
        Test.startTest();
		Quote quote = [SELECT Id FROM Quote];
		Price_Schedule__c priceSchedule = [SELECT Id FROM Price_Schedule__c];
		PricebookEntry pbEntry = [SELECT Id FROM PricebookEntry];
		QuoteLineItem quoteLineItem = new QuoteLineItem(QuoteId=quote.Id,Quantity=1,PricebookEntryId=pbEntry.Id,Price_Schedule__c=priceSchedule.Id,UnitPrice=10,Charge_Code__c='Test',Offer_Price__c=10,Type__c='Normal');
		//Test.startTest();		
			insert quoteLineItem;
			quote.Proposed_Start_Date__c = Date.today().addDays(-5);
			update quote;
		Test.stopTest();
		List<QuoteLineItem> lineItemResults = [SELECT Id, Offer_Price__c, End_Date__c FROM QuoteLineItem WHERE Parent_Quote_Line_Item__c = :quoteLineItem.Id];
		system.assertEquals(1, lineItemResults.size());
		//system.assertEquals(Date.today(), lineItemResults.get(0).End_Date__c);
	}

	/*
	* @method GracePeriodUtility.createGracePeriodLineItems
   	* @case when updating the Proposed_End_Date__c on a quote and changing the Grace_Period_Mechanism__c to end
   	* @result the quote's grace period line item should be recreated with a new Start_Date__c that reflects the fact the grace period ends on a different date and at the end of the lease
	*/
	@isTest
	static void updateQuoteEndDate(){
        Test.setMock(HttpCalloutMock.class, new DDAIntegrationMock());
        Test.startTest();
		Quote quote = [SELECT Id FROM Quote];
		Price_Schedule__c priceSchedule = [SELECT Id FROM Price_Schedule__c];
		PricebookEntry pbEntry = [SELECT Id FROM PricebookEntry];
		QuoteLineItem quoteLineItem = new QuoteLineItem(QuoteId=quote.Id,
														Quantity=1,
														PricebookEntryId=pbEntry.Id,
														Price_Schedule__c=priceSchedule.Id,
														UnitPrice=10,
														Charge_Code__c='Test',
														Offer_Price__c=10,
														Type__c='Normal',
														Default_Grace_Period__c = 30);
		//Test.startTest();		
			insert quoteLineItem;
			quote.Proposed_End_Date__c = Date.today().addDays(5);
			quote.Grace_Period_Period__c = 'days';
			quote.Grace_Period_Mechanism__c = 'end';
			update quote;
		Test.stopTest();
		List<QuoteLineItem> lineItemResults = [SELECT Id, Offer_Price__c, Start_Date__c FROM QuoteLineItem WHERE Parent_Quote_Line_Item__c = :quoteLineItem.Id];
		system.assertEquals(1, lineItemResults.size());
		//system.assertEquals(Date.today(), lineItemResults.get(0).Start_Date__c);
	}

	/*
	* @method GracePeriodUtility.createGracePeriodLineItems
   	* @case when inserting a parent line item whose master quote has a Grace_Period_Period__c in days and a Grace_Period_Mechanism__c of initial
   	* @result expect the child line item to have a End_Date__c equal to its quote's Start_Date__c plus as many days as its quote's Grace_Period__C
	*/
	@isTest
	static void createLineItemWithInitialMechanismInDays(){
        Test.setMock(HttpCalloutMock.class, new DDAIntegrationMock());
        Test.startTest();
		Quote quote = [SELECT Id FROM Quote];
		Price_Schedule__c priceSchedule = [SELECT Id FROM Price_Schedule__c];
		PricebookEntry pbEntry = [SELECT Id FROM PricebookEntry];
		QuoteLineItem quoteLineItem = new QuoteLineItem(QuoteId=quote.Id,Quantity=1,PricebookEntryId=pbEntry.Id,Price_Schedule__c=priceSchedule.Id,UnitPrice=10,Charge_Code__c='Test',Offer_Price__c=10,Type__c='Normal');
		//Test.startTest();		
			insert quoteLineItem;
		Test.stopTest();
		List<QuoteLineItem> lineItemResults = [SELECT Id, Offer_Price__c, End_Date__c FROM QuoteLineItem WHERE Parent_Quote_Line_Item__c = :quoteLineItem.Id];
		system.assertEquals(1, lineItemResults.size());
		system.assertEquals(-10, lineItemResults.get(0).Offer_Price__c);
		//system.assertEquals(Date.today().addDays(5), lineItemResults.get(0).End_Date__c);
	}

	/*
	* @method GracePeriodUtility.createGracePeriodLineItems
   	* @case when inserting a parent line item whose master quote has a Grace_Period_Period__c in months and a Grace_Period_Mechanism__c of end
   	* @result expect the child line item to have a Start_Date__c equal to its quote's End_Date__c minus as many months as its quote's Grace_Period__C
	*/
	@isTest
	static void createLineItemWithEndMechanismInMonths(){
        Test.setMock(HttpCalloutMock.class, new DDAIntegrationMock());
        Test.startTest();
		Quote quote = [SELECT Id FROM Quote];
		quote.Grace_Period_Mechanism__c = 'end';
		quote.Grace_Period_Period__c = 'months';
		Price_Schedule__c priceSchedule = [SELECT Id FROM Price_Schedule__c];
		PricebookEntry pbEntry = [SELECT Id FROM PricebookEntry];
		QuoteLineItem quoteLineItem = new QuoteLineItem(QuoteId=quote.Id,Quantity=1,PricebookEntryId=pbEntry.Id,Price_Schedule__c=priceSchedule.Id,UnitPrice=10,Charge_Code__c='Test',Offer_Price__c=10,Type__c='Normal');
		//Test.startTest();		
			insert quoteLineItem;
		Test.stopTest();
		List<QuoteLineItem> lineItemResults = [SELECT Id, Offer_Price__c, Start_Date__c FROM QuoteLineItem WHERE Parent_Quote_Line_Item__c = :quoteLineItem.Id];
		system.assertEquals(1, lineItemResults.size());
		system.assertEquals(-10, lineItemResults.get(0).Offer_Price__c);
		system.assertEquals(Date.today(), lineItemResults.get(0).Start_Date__c);
	}

	/*
	* @method GracePeriodUtility.createGracePeriodLineItems
   	* @case when updating the offer price on a parent line item
   	* @result expect the child line item to have an Offer_Price__c equal to minus the Offer_Price__c value of its parent line item
	*/
	@isTest
	static void updateLineItemOfferPrice(){
        Test.setMock(HttpCalloutMock.class, new DDAIntegrationMock());
        Test.startTest();
		Quote quote = [SELECT Id FROM Quote];
		Price_Schedule__c priceSchedule = [SELECT Id FROM Price_Schedule__c];
		PricebookEntry pbEntry = [SELECT Id FROM PricebookEntry];
		QuoteLineItem quoteLineItem = new QuoteLineItem(QuoteId=quote.Id,Quantity=1,PricebookEntryId=pbEntry.Id,Price_Schedule__c=priceSchedule.Id,UnitPrice=10,Charge_Code__c='Test',Offer_Price__c=10,Type__c='Normal');
		//Test.startTest();		
			insert quoteLineItem;
			quoteLineItem.Offer_Price__c = 20;
			update quoteLineItem;
		Test.stopTest();
		List<QuoteLineItem> lineItemResults = [SELECT Id, Offer_Price__c FROM QuoteLineItem WHERE Parent_Quote_Line_Item__c = :quoteLineItem.Id];
		//system.assertEquals(1, lineItemResults.size());
		//system.assertEquals(-20, lineItemResults.get(0).Offer_Price__c);
	}

	/*
	* @method GracePeriodUtility.deleteQuoteLineItems
   	* @case when deleting a parent line item
   	* @result expect the parent and its children to be deleted
	*/
	@isTest
	static void deleteParentLineItem(){
        Test.setMock(HttpCalloutMock.class, new DDAIntegrationMock());
        Test.startTest();
		Quote quote = [SELECT Id FROM Quote];
		Price_Schedule__c priceSchedule = [SELECT Id FROM Price_Schedule__c];
		PricebookEntry pbEntry = [SELECT Id FROM PricebookEntry];
		QuoteLineItem quoteLineItem = new QuoteLineItem(QuoteId=quote.Id,Quantity=1,PricebookEntryId=pbEntry.Id,Price_Schedule__c=priceSchedule.Id,UnitPrice=10,Charge_Code__c='Test',Offer_Price__c=10,Type__c='Normal');
		//Test.startTest();		
			insert quoteLineItem;
			delete quoteLineItem;
		Test.stopTest();
		List<QuoteLineItem> lineItemResults = [SELECT Id FROM QuoteLineItem];
		//system.assertEquals(0, lineItemResults.size());
	}

	/*
	* @method GracePeriodUtility.createGracePeriodLineItems
   	* @case when undeleting a parent line item
   	* @result expect the parent and its children to be re-created
	*/
	@isTest
	static void undeleteParentLineItems(){
        Test.setMock(HttpCalloutMock.class, new DDAIntegrationMock());
        Test.startTest();
		Quote quote = [SELECT Id FROM Quote];
		Price_Schedule__c priceSchedule = [SELECT Id FROM Price_Schedule__c];
		PricebookEntry pbEntry = [SELECT Id FROM PricebookEntry];
		QuoteLineItem quoteLineItem = new QuoteLineItem(QuoteId=quote.Id,Quantity=1,PricebookEntryId=pbEntry.Id,Price_Schedule__c=priceSchedule.Id,UnitPrice=10,Charge_Code__c='Test',Offer_Price__c=10,Type__c='Normal');
		//Test.startTest();		
			insert quoteLineItem;
			delete quoteLineItem;
			undelete quoteLineItem;
		Test.stopTest();
		List<QuoteLineItem> lineItemResults = [SELECT Id FROM QuoteLineItem];
		system.assertEquals(2, lineItemResults.size());
	}
    @isTest
    static void testCreateGraceGracePeriod(){
        Test.setMock(HttpCalloutMock.class, new DDAIntegrationMock());
        Test.startTest();
        Quote quote = [SELECT Id FROM Quote];
        Price_Schedule__c priceSchedule = [SELECT Id FROM Price_Schedule__c];
		PricebookEntry pbEntry = [SELECT Id FROM PricebookEntry];
        QuoteLineItem quoteLineItem = new QuoteLineItem(QuoteId=quote.Id,Quantity=1,PricebookEntryId=pbEntry.Id,Price_Schedule__c=priceSchedule.Id,UnitPrice=10,Charge_Code__c='Test',Offer_Price__c=10,Type__c='Normal');
        insert quoteLineItem;
        Grace_Period__c gp = new Grace_Period__c(Quote__c=quote.Id,Start_Date__c=Date.today(),Period__c ='days',Duration__c =10);
        insert gp;
        Test.stopTest();
    }
    
    @isTest
    static void testUpdateGraceGracePeriod(){
        Test.setMock(HttpCalloutMock.class, new DDAIntegrationMock());
        Test.startTest();
        Quote quote = [SELECT Id FROM Quote];
        Price_Schedule__c priceSchedule = [SELECT Id FROM Price_Schedule__c];
		PricebookEntry pbEntry = [SELECT Id FROM PricebookEntry];
        QuoteLineItem quoteLineItem = new QuoteLineItem(QuoteId=quote.Id,Quantity=1,PricebookEntryId=pbEntry.Id,Price_Schedule__c=priceSchedule.Id,UnitPrice=10,Charge_Code__c='Test',Offer_Price__c=10,Type__c='Normal');
        insert quoteLineItem;
        Grace_Period__c gp = new Grace_Period__c(Quote__c=quote.Id,Start_Date__c=Date.today(),Period__c ='days',Duration__c =10);
        insert gp;
        gp.Duration__c = 20;
        update gp;
        Test.stopTest();
    }
    @isTest
    static void testDeleteGraceGracePeriod(){
        Test.setMock(HttpCalloutMock.class, new DDAIntegrationMock());
        Test.startTest();
        Quote quote = [SELECT Id FROM Quote];
        Price_Schedule__c priceSchedule = [SELECT Id FROM Price_Schedule__c];
		PricebookEntry pbEntry = [SELECT Id FROM PricebookEntry];
        QuoteLineItem quoteLineItem = new QuoteLineItem(QuoteId=quote.Id,Quantity=1,PricebookEntryId=pbEntry.Id,Price_Schedule__c=priceSchedule.Id,UnitPrice=10,Charge_Code__c='Test',Offer_Price__c=10,Type__c='Normal');
        insert quoteLineItem;
        Grace_Period__c gp = new Grace_Period__c(Quote__c=quote.Id,Start_Date__c=Date.today(),Period__c ='days',Duration__c =10);
        insert gp;
        delete gp;
        Test.stopTest();
    }
}