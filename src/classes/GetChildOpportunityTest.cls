@isTest
public class GetChildOpportunityTest {
    @testSetUp
    public static void setUp(){
        //if (test.isRunningTest()) Test.setMock(HttpCalloutMock.class, new GetChildOpportunity());
        //Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business_Account').getRecordTypeId();
       // String strRecordTypeId = [Select Id From RecordType Where SobjectType = 'Account' and Name = 'Business_Account'].Id;
        Account accountObject = new Account(Name = 'Test Account',
                                                         Phone = '123456'
                                                        );
        insert accountObject;
        
        Contact contactObject = new Contact(LastName = 'Test Contact',
                                            AccountId = accountObject.Id,
                                            Email = 'test@test.com',
                                            Phone = '123456');
        insert contactObject;
            
        Business_Park__c businessParkObject = new Business_Park__c(Name = 'Test BusinessPark',
                                                                                Business_Park_Yardi__c = 'Test Yardi');
        insert businessParkObject;
        
        Opportunity opportunityObject = new Opportunity(Name = 'Test Opportunity',
                                                                      AccountId = accountObject.Id,
                                                                      Contact__c = contactObject.Id,
                                                                      Business_Park__c = businessParkObject.Id,
                                                                      StageName = 'New',
                                                                      CloseDate = System.today()
                                                                      );
        insert opportunityObject;
        
        Payment_Term__c paymentTermObject = new Payment_Term__c(Name = 'Test Payment Term',
                                                               Number_Of_Payments__c = 2);
        insert paymentTermObject;
        
        Quote quoteObject = new Quote(Name = 'Test Quote',
                                     Proposed_Start_Date__c = System.today(),
                                     Proposed_End_Date__c = System.today().addDays(2),
                                     Type__c = 'Expansion',
                                     Payment_Terms__c = paymentTermObject.Id,
                                     OpportunityId = opportunityObject.Id,
                                     Pricebook2Id = Test.getStandardPricebookId());
        insert quoteObject;
        Quote_Revision__c revisionObj = new Quote_Revision__c(Quote__c = quoteObject.Id,
                                                              Total_Best_Rate__c = 300,
                                                              Total_Offered_Price__c = 500
                                                            );
        insert revisionObj;
        
        Product2 prod = new Product2(Name = 'testProd',isActive = true,Unique_Key__c = 'pricingEngineTestProd' );
        insert prod;
        
        PricebookEntry pbe = new PricebookEntry(isActive = true,UnitPrice = 100,Product2Id = prod.Id,
                                                Pricebook2Id = Test.getStandardPricebookId(),CurrencyIsoCode = 'AED');
        insert pbe;
        
        QuoteLineItem qliObject = new QuoteLineItem(QuoteId = quoteObject.Id,
                                                    Best_Rate__c = 100,
                                                    Offer_Price__c = 80,
                                                    PricebookEntryId = pbe.Id,
                                                    Quantity = 1.00,
                                                    UnitPrice = 100,
                                                    Start_Date__c = Date.Today() + 120,
                                                    End_Date__c = Date.Today() + 120 + 365,
                                                    Type__c = 'Normal',
                                                    Area__c = 1000,
                                                    Transactional_Unit__c = 'Sqft',
                                                    Quote_Revision__c = revisionObj.Id,
                                                    Product2Id = prod.Id);
        insert qliObject;
        
        opportunityObject.SyncedQuoteId = quoteObject.Id;
		update opportunityObject;
    }
    
	@isTest
    public static void createAndGetChildOpportunityTest(){
        Opportunity opportunityObject = [SELECT Id FROM Opportunity WHERE Name =: 'Test Opportunity' LIMIT 1];
        Test.startTest();
        GetChildOpportunity.createAndGetChildOpportunity(opportunityObject.Id);
        Test.stopTest();
    }
    
    @isTest
    public static List<Quote> getQuoteRecordTest(){
         Opportunity opportunityObject = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity' LIMIT 1];
        List<Quote> quoteList = [SELECT Id FROM Quote WHERE Name = 'Test Quote' AND OpportunityId = :opportunityObject.Id LIMIT 1];
        Test.startTest();
        GetChildOpportunity.getQuoteRecord(opportunityObject.Id);
        Test.stopTest();
        return quoteList;
    }
    
    @isTest
    public static List<QuoteLineItem> getQuoteLineItemRecordTest(){
        Quote quoteObject = [SELECT Id FROM Quote WHERE Name = 'Test Quote' LIMIT 1];
        List<QuoteLineItem> qliList = [SELECT Id FROM QuoteLineItem WHERE QuoteId = :quoteObject.Id LIMIT 1];
        
        Test.startTest();
        GetChildOpportunity.getQuoteLineItemRecord(quoteObject.Id);
        Test.stopTest();
        return qliList;
    }
}