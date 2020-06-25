@isTest
public with sharing class BundleUtilsTest {

	@testSetup
	public static void setupTests(){
		// Create Business Park
		Business_Park__c businessPark = new Business_Park__c();
		insert businessPark;

		// Create opportunity
		Opportunity opp = new Opportunity(
			Name = 'Test Opp',
			StageName = 'Prospecting',
			CloseDate = System.today(),
			Lease_Type__c = 'office',
			Business_Park__c = businessPark.Id,
			Opportunity_Type__c = 'New',
			Pricebook2Id = Test.getStandardPricebookId());
		insert opp;

		// Create payment term
		Payment_Term__c pTerm = new Payment_Term__c(Number_Of_Payments__c = 2);
		insert pTerm;
		
		// Create Quote
		Quote quo = new Quote(
			Name = 'Test Quote',
			OpportunityId = opp.Id,
			CCL_Sign_Date__c = System.today(),
			Pricebook2Id = Test.getStandardPricebookId(),
			Type__c = 'New',
			Lease_Start_Date__c = System.today(),
			Lease_End_Date__c = System.today().addDays(10),
			Payment_Terms__c = pTerm.Id,
			Grace_Period_Mechanism__c = 'initial',
			Grace_Period_Period__c = 'days',
			Grace_Period__c = 5,
			Proposed_Start_Date__c = System.today(),
			Proposed_End_Date__c = System.today().addMonths(5));
		insert quo;

		// Create building
		Building__c building = new Building__c(
			Development_Status__c = 'Developed',
			Property_Code_YARDI__c = 'XXXX',
			Property__c = 'Office',
			Ownership_Type__c = 'TECOM Owned');
		insert building;

		// Insert unit
		Unit__c unit = new Unit__c(
			Transactional_Unit__c = 'Sq.Ft',
			Building__c = building.Id,
			Unit_Code_YARDI__c='test');
		insert unit;

		// Insert product
		Product2 prod = new Product2(
			Name = 'Product X', 
			ProductCode = 'Pro-X', 
			isActive = true,
			Unit__c = unit.Id);
		insert prod;

		// Create PriceBookEntry
		PricebookEntry pbEntry = new PricebookEntry(
			Pricebook2Id = Test.getStandardPricebookId(), 
			Product2Id = prod.Id, 
			UnitPrice = 100.00, 
			IsActive = true);
		insert pbEntry;

		// Create Parent Quoteline
		QuotelineItem parentLineItem = new QuoteLineItem(
			Quantity = 1,
			QuoteId = quo.Id, 
			PricebookEntryId = pbEntry.Id, 
			UnitPrice = 100, 
			Product2Id = prod.Id,
			Type__c = 'Normal');
		insert parentLineItem;

		// Create Child Quoteline
		QuotelineItem firstChildLineItem = new QuoteLineItem(
			Quantity = 1,
			QuoteId = quo.Id, 
			PricebookEntryId = pbEntry.Id, 
			UnitPrice = 100, 
			Product2Id = prod.Id,
			Parent_Quote_Line_Item__c = String.valueOf(parentLineItem.Id),
			Type__c = 'Normal');
		insert firstChildLineItem;

		// Create Child Quoteline
		QuotelineItem secondChildLineItem = new QuoteLineItem(
			Quantity = 1,
			QuoteId = quo.Id, 
			PricebookEntryId = pbEntry.Id, 
			UnitPrice = 100, 
			Product2Id = prod.Id,
			Parent_Quote_Line_Item__c = String.valueOf(parentLineItem.Id),
			Type__c = 'Normal');
		insert secondChildLineItem;
	}

	@isTest
	public static void testDeleteNormalChildLineItemsPositive(){
		Integer lineItemsCount = [SELECT COUNT() FROM QuotelineItem WHERE Quote.Name = 'Test Quote'];
		// Expected: 4 as there were 4 line items created in the set up
		System.assertEquals(3, lineItemsCount);

		// Query for line items
		List<QuotelineItem> lineItems = [SELECT Id FROM QuotelineItem WHERE Type__c = 'Normal' AND Parent_Quote_Line_Item__c = null];

		// Delete parent line
		delete lineItems;

		lineItemsCount = [SELECT COUNT() FROM QuotelineItem];
		// Expected: 0 as the child records should have been deleted 
		System.assertEquals(0, lineItemsCount);
	}
}