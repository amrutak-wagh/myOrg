/**
 *  @description Test class for QLIOverrideDeleteExtension Controller
 *
 *  2019/08/27  Amruta K     First version
 *  
 */
@isTest
public class QLIOverrideDeleteExtensionTest {

    @testSetup
    public static void createData(){
        Business_Park__c bsp = new Business_Park__c(Name = 'D3',Business_Park_Yardi__c = 'D3');
        insert bsp;
        
        Account acc = new Account(Name='Test Account', License_Business_Park__c = bsp.Id );
        insert acc;
        
        Contact conObj = new Contact(LastName = 'Test Contact', AccountId = acc.Id);
        insert conObj;
        
        Opportunity opp = new Opportunity(Name = 'Test Opp' , AccountId = acc.Id , StageName = 'New',
                                          CloseDate = Date.newInstance(2019,7,2),
                                         Sub_Type__c = 'Expansion',CurrencyIsoCode = 'AED', Contact__c = conObj.Id,Business_Park__c = bsp.Id);
        insert opp;
        
        Opportunity opp1 = new Opportunity(Name = 'Test Opp1' , AccountId = acc.Id , StageName = 'New',
                                          CloseDate = Date.newInstance(2019,7,2), Type = 'Renewal', Parent_Opportunity__c = opp.Id,
                                         Sub_Type__c = 'Expansion',CurrencyIsoCode = 'AED', Contact__c = conObj.Id,Business_Park__c = bsp.Id,
                                          Expansion_Separate_Amendment_Terms__c = '0');
        insert opp1;
        
        Quote q = new Quote(Name = 'Test Quote',OpportunityId = opp.Id,CCL_Sign_Date__c = Date.today(),
                            Status = 'Draft',Type__c = 'Renewal', Proposed_Start_Date__c = Date.today(),
                            Proposed_End_Date__c = Date.today().addDays(90),Lease_Start_Date__c = Date.today(),
                            Pricebook2Id = Test.getStandardPricebookId(),Lease_End_Date__c = Date.today().addDays(90));
        insert q;
        
        Product2 prod = new Product2(Name = 'testProd',isActive = true,Unique_Key__c = 'pricingEngineTestProd' );
        insert prod;
        Product2 prod1 = new Product2(Name = 'testProd1',isActive = true,Unique_Key__c = 'pricingEngineTestProd1');
        insert prod1;
        // Test pricebook entry
        PricebookEntry pbe = new PricebookEntry(isActive = true,UnitPrice = 100,Product2Id = prod.Id,
                                                Pricebook2Id = Test.getStandardPricebookId(),CurrencyIsoCode = 'AED');
        insert pbe;
        PricebookEntry pbe1 = new PricebookEntry(
                IsActive = true,
                Product2Id = prod1.Id,
                Pricebook2Id = Test.getStandardPricebookId(),
                UnitPrice = 100
        );
        insert pbe1;
        
        QuoteLineItem qli = new QuoteLineItem(
                QuoteId = q.Id,
                Best_Rate__c = 10000,
                Offer_Price__c = 8000,
                PricebookEntryId = pbe1.Id,
                Quantity = 1,
                UnitPrice = 10000,
                Start_Date__c = Date.Today() + 120,
                End_Date__c = Date.Today() + 120 + 365,
                Type__c = 'Normal',
                Area__c = 1000,
                Transactional_Unit__c = 'Unit',
            	Product2Id = prod.Id
        );
        
        Quote q1 = new Quote(Name = 'Test Quote1',OpportunityId = opp1.Id,CCL_Sign_Date__c = Date.today(),
                            Status = 'Draft',Type__c = 'Renewal', Proposed_Start_Date__c = Date.today(),
                            Proposed_End_Date__c = Date.today().addDays(90),Lease_Start_Date__c = Date.today(),
                            Pricebook2Id = Test.getStandardPricebookId(),Lease_End_Date__c = Date.today().addDays(90));
        insert q1;
        
        Product2 prod11 = new Product2(Name = 'testProd1',isActive = true,Unique_Key__c = 'pricingEngineTestProd1' );
        insert prod11;
        Product2 prod12 = new Product2(Name = 'testProd12',isActive = true,Unique_Key__c = 'pricingEngineTestProd12');
        insert prod12;
        // Test pricebook entry
        PricebookEntry pbe11 = new PricebookEntry(isActive = true,UnitPrice = 100,Product2Id = prod11.Id,
                                                Pricebook2Id = Test.getStandardPricebookId(),CurrencyIsoCode = 'AED');
        insert pbe11;
        PricebookEntry pbe12 = new PricebookEntry(
                IsActive = true,
                Product2Id = prod12.Id,
                Pricebook2Id = Test.getStandardPricebookId(),
                UnitPrice = 100
        );
        insert pbe12;
        
        QuoteLineItem qli2 = new QuoteLineItem(
                QuoteId = q1.Id,
                Best_Rate__c = 10000,
                Offer_Price__c = 8000,
                PricebookEntryId = pbe12.Id,
                Quantity = 1,
                UnitPrice = 10000,
                Start_Date__c = Date.Today() + 120,
                End_Date__c = Date.Today() + 120 + 365,
                Type__c = 'Normal',
                Area__c = 1000,
                Transactional_Unit__c = 'Unit',
            	Product2Id = prod.Id
        );

        List<QuoteLineItem> quoteLineItemsList= new List<QuoteLineItem>();
        quoteLineItemsList.add(qli);
        quoteLineItemsList.add(qli2);
        
       	insert quoteLineItemsList;
    }
    
    /* Method to test Error message if Opportunity Type is not Renewal & display error*/
    @isTest
    public static void testCheckOpportunityForError() {
        List<QuoteLineItem> qliLst = [SELECT Id,Quote.Opportunity.Type FROM QuoteLineItem
                                      WHERE Quote.Opportunity.Type = 'Renewal'];
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(qliLst[0]);
        QLIOverrideDeleteExtension qliObj = new QLIOverrideDeleteExtension(sc);
        qliObj.displayError = false;
        qliObj.checkOpportunity();
        Test.stopTest();
                
        System.assertEquals(qliObj.displayError, true);
        
    }
    /* Method to test Success message if Opportunity Type is not Renewal & delete the record*/
    @isTest
    public static void testCheckOpportunityForSuccess() {
        List<QuoteLineItem> qliLst = [SELECT Id,Quote.Opportunity.Type FROM QuoteLineItem];
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(qliLst[0]);
        QLIOverrideDeleteExtension qliObj = new QLIOverrideDeleteExtension(sc);
        qliObj.displaySuccess = false;
        qliObj.checkOpportunity();
        Test.stopTest();
        List<QuoteLineItem> qliLstDeleted = [SELECT Id,Quote.Opportunity.Type FROM QuoteLineItem
                                      WHERE Quote.Opportunity.Type != 'Renewal'];
		System.assertEquals(qliObj.displaySuccess, true);
        System.assertEquals(qliLstDeleted.Size(), 0);
    }
}