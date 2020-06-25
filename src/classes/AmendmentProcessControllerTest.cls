/************************************************************************************
* Name          : AmendmentProcessControllerTest                                                 
* Description   : Test class for AmendmentProcessController
* Created Date  :                                                    
* Created By    : 4C - Shraddha N (shraddha.naik@weare4c.com)
* Jira/Req By   :                                                                                                                                           
* -----------------------------------------------------------------------------------------------------------------------
* VERSION   Developer   Date        Description     Ticket/Reference    
	1
************************************************************************************/
@isTest
public class AmendmentProcessControllerTest {

    // Method to create test setup data.
    public static Opportunity createOpportunityData(){
        Test.setMock(HttpCalloutMock.class, new DDAIntegrationMock());
        Account accountObject = new Account(Name = 'Test Account',
                                            Phone = '123456');
        insert accountObject;
        
        Contact contactObject = new Contact(LastName = 'Test Contact Record',
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
        
        return opportunityObject;
    }
    
    // Method to create test setup data.
    public static Quote createQuoteData(){
        Test.setMock(HttpCalloutMock.class, new DDAIntegrationMock());
        Opportunity opportunityObject = createOpportunityData();
        
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
                                                    Quantity = 1,
                                                    UnitPrice = 100,
                                                    Start_Date__c = Date.Today() + 120,
                                                    End_Date__c = Date.Today() + 120 + 365,
                                                    Type__c = 'Normal',
                                                    Area__c = 1000,
                                                    Transactional_Unit__c = 'Sqft',
                                                    Quote_Revision__c = revisionObj.Id,
                                                    Product2Id = prod.Id);
        insert qliObject;
        
        return quoteObject;
    }
    
    // Method to create test setup data.
    public static List<QuoteLineItem> createQuoteLineItemsData(){
        Test.setMock(HttpCalloutMock.class, new DDAIntegrationMock());
       
        List<QuoteLineItem> qliList = new List<QuoteLineItem>();
        
        Quote quoteObject = createQuoteData();
        
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
                                                    Quantity = 1,
                                                    UnitPrice = 100,
                                                    Start_Date__c = Date.Today() + 120,
                                                    End_Date__c = Date.Today() + 120 + 365,
                                                    Type__c = 'Normal',
                                                    Area__c = 1000,
                                                    Transactional_Unit__c = 'Sqft',
                                                    Quote_Revision__c = revisionObj.Id,
                                                    Product2Id = prod.Id);
        insert qliObject;
        
        qliList.add(qliObject);
        return qliList;
    }
    
    
    
	@isTest
    public static void createChildOpportunityTest(){
        Opportunity opportunityObject = createOpportunityData();
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
        opportunityObject.SyncedQuoteId = quoteObject.Id;
        update opportunityObject;
        
        Test.startTest();
        Opportunity childOpportunityObject = AmendmentProcessController.createChildOpportunity(opportunityObject.Id);
        AmendmentProcessController.getChildOpportunityRecord(childOpportunityObject.Id);
        Test.stopTest();
    }
   
    
    @isTest
    public static void getQuoteRecordTest(){
        Opportunity opportunityObject = createOpportunityData();
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
        Test.startTest();
        AmendmentProcessController.getQuoteRecord(opportunityObject.Id);
        Test.stopTest();
       
    }
    
    @isTest
    public static void updatetQuoteRecordTest(){
        Opportunity opportunityObject = createOpportunityData();
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
        Test.startTest();
        AmendmentProcessController.updateQuoteRecord(opportunityObject.Id, '2019-12-12');
        Test.stopTest();
       
    }
    
    @isTest
    public static void getQuoteLineItemRecordTest(){
        Quote quoteObject = createQuoteData();
        
       	Test.startTest();
        AmendmentProcessController.getQuoteLineItemRecord(quoteObject.Id);
        Test.stopTest();
        //return qliList;
    }
    
    @isTest
    public static void getRemovedQuoteLineItemList(){
        List<Id> qliIdList = new List<Id>();
      
        List<QuoteLineItem> qliList = createQuoteLineItemsData();
        
        for(QuoteLineItem qliObj : qliList){
            qliIdList.add(qliObj.Id);
        }
        
        Test.startTest();
        AmendmentProcessController.getRemovedQuoteLineItemList(qliIdList);
        Test.stopTest();
    }
    
    @isTest
    public static void removeSelectedQuoteLineItemsTest(){
        List<String> qliIdList = new List<String>();
       
        List<QuoteLineItem> qliList = createQuoteLineItemsData();
        
        for(QuoteLineItem qliObj : qliList){
            qliIdList.add(qliObj.Id);
        }
        
        String qliIdListString = String.join(qliIdList, ',');
        Test.startTest();
        AmendmentProcessController.removeSelectedQuoteLineItems(qliIdListString);
        Test.stopTest();
    }
    
    @isTest
    public static void getQuoteRecordsTest(){
        Quote quoteObject = createQuoteData();
        
       	Test.startTest();
        AmendmentProcessController.getQuoteRecords(quoteObject.Id);
        Test.stopTest();
    }
     @isTest
    static void getPageLayoutMetadata_emptyPageLayoutName_expectEmptyPageLayoutTest() {
        AmendmentProcessController.PageLayout pageLayout =
                AmendmentProcessController.getPageLayoutMetadata('');
        
        assertEmptyPageLayout(pageLayout);
    }
    
    @isTest
    static void getPageLayoutMetadata_nonExistentPageLayout_expectEmptyPageLayoutTest() {
        String nonExistentPageLayout = 'asfdsdf1213120akdk';
        
        AmendmentProcessController.PageLayout pageLayout =
                AmendmentProcessController.getPageLayoutMetadata(nonExistentPageLayout);

        assertEmptyPageLayout(pageLayout);
    }
    
    @isTest
    static void getPageLayoutMetadata_existingPageLayout_expectNonEmptyPageLayoutTest() {
        String existentPageLayout = 'Account-Account Layout';
        
        AmendmentProcessController.PageLayout pageLayout =
                AmendmentProcessController.getPageLayoutMetadata(existentPageLayout);

        assertNonEmptyPageLayout(pageLayout);
    }
    
    static void assertEmptyPageLayout(AmendmentProcessController.PageLayout pageLayout) {
        system.assert(pageLayout != null, 'The page layout should not be null.');
        system.assert(pageLayout.Sections != null, 'The page layout\'s sections should not be null.');
        system.assertEquals(0, pageLayout.Sections.size(), 'The page layout\'s sections should be empty.');
    }

    static void assertNonEmptyPageLayout(AmendmentProcessController.PageLayout pageLayout) {
        system.assert(pageLayout != null, 'The page layout should not be null.');
        system.assert(pageLayout.Sections != null, 'The page layout\'s sections should not be null.');
        system.assert(pageLayout.Sections.size() > 0, 'The page layouts should have sections.');
    }
     
}