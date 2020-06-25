/*
 * Created by : Raza khan (raza.khan@weare4c.com)
 * 
 * Description: this controller is for completing the code coverage of the MassDeleteController
 * 
 * */
@istest
public class MassDeleteQliControllerTest {
    private static Id quoteId;
    /*
     * Method :setupData
     * 
     * Desrciption: it is for setting up the setup data for testing
     * 
     * */
    private static void setupData(){
     Id standardPricebookId = Test.getStandardPricebookId();
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
                Grace_Period__c=10,Grace_Period_Format__c = 'days', Grace_Period_Mechanism__c = 'end',
                Name='Test PC',Transaction_Type__c = 'New', Start_Date__c = Date.today(), End_Date__c = Date.today() + 10,
                Price_Rule__c=priceRule.Id);
		insert priceSchedule;

        Quote quote = new Quote(
                Name='Test Q',
                OpportunityId=opportunity.Id,
                Type__c = 'New',
                CCL_Sign_Date__c=Date.today(),
                Pricebook2Id=standardPricebookId,
                Grace_Period__c=10,
            	Grace_Period_Period__c = 'days',
            	Grace_Period_Mechanism__c = 'initial',
                Lease_Start_Date__c=Date.today(),
                Lease_End_Date__c=Date.today().addDays(10),
                Proposed_Start_Date__c = System.today(),
                Proposed_End_Date__c = System.today().addYears(3));
		insert quote;
        quoteId = quote.id;


        Quote quote1 = new Quote(
                Name='Test Q1',
                OpportunityId=opportunity.Id,
                Type__c = 'New',
                CCL_Sign_Date__c=Date.today(),
                Pricebook2Id=standardPricebookId,
                Grace_Period__c=10,
            	Grace_Period_Period__c = 'days',
            	Grace_Period_Mechanism__c = 'initial',
                Lease_Start_Date__c=Date.today(),
                Lease_End_Date__c=Date.today().addDays(10),
                Proposed_Start_Date__c = System.today(),
                Proposed_End_Date__c = System.today().addYears(10));
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
      
       // insert quotelineItem; //new List<QuoteLineItem> {quotelineItem};//, quoteLineItem1,quoteLineItem2};//
            }
    
    /*
     * Method :massDeleteQliTest
     * 
     * Desrciption: it is for testing MassDeleteQliController
     * 
     * */
    @istest
    private static void massDeleteQliTest()
    {
        setupData();
        test.startTest();
        string resp = MassDeleteQliController.massQuoteLineItemsDelete(quoteId);
        Quote q = new Quote(Id =quoteId );
        q.Soft_Book__c = true;
        update q; 
        resp = MassDeleteQliController.massQuoteLineItemsDelete(quoteId);
        
        test.stopTest();
        System.assert(resp != null);
        
    }
}