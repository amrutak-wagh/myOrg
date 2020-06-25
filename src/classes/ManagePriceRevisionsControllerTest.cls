/************************************************************************************
* Name          : ManagePriceRevisionsControllerTest                                                 
* Description   : Test class for controller class for Manage Pricing Revision lightning component
* Created Date  : 23/08/2019                                                   
* Created By    : Amruta Kumbhakarn (amruta.kumbhakarn@weare4c.com)
* Jira/Req By   :                                                                                                                                           
* -----------------------------------------------------------------------------------------------------------------------
* VERSION   Developer   Date        Description     Ticket/Reference    
************************************************************************************/
@isTest
public class ManagePriceRevisionsControllerTest {
    // Method to create test data related to lighting component.
    @testSetup
    static void createTestData() {
         Id standardPricebookId = Test.getStandardPricebookId();
        Test.setMock(HttpCalloutMock.class, new DDAIntegrationMock());
        
        insert new Manage_Price_Revision_Setting__c(SetupOwnerId = UserInfo.getProfileId(), 
                                                    Allow_To_Edit_Best_Rate__c = true
                                                   );

        Business_Park__c businessPark = new Business_Park__c(
                Name = 'D3'
        );
        insert businessPark;

        Account account = new Account(
                Name = 'Test Company'
        );
        insert account;

        Product2 unit1 = new Product2(
                IsActive = true,
                Name = 'Unit 1',
                Transaction_Unit__c = 'Sqft'
        );
        Product2 unit2 = new Product2(
                IsActive = true,
                Name = 'Unit 2',
                Transaction_Unit__c = 'Unit'
        );
        List<Product2> productList = new List<Product2>{unit1, unit2};
        insert productList;

        PricebookEntry pbe1 = new PricebookEntry(
                IsActive = true,
                Product2Id = unit1.Id,
                Pricebook2Id = standardPricebookId,
                UnitPrice = 100
        );
        PricebookEntry pbe2 = new PricebookEntry(
                IsActive = true,
                Product2Id = unit2.Id,
                Pricebook2Id = standardPricebookId,
                UnitPrice = 10000
        );
        insert new List<PricebookEntry>{pbe1, pbe2};

        Opportunity opp = new Opportunity(
                Pricebook2Id = standardPricebookId,
                Name = 'Test Opp',
                AccountId = account.Id,
                StageName = 'Draft',
                CloseDate = Date.today(),
                Business_Park__c = businessPark.Id,
                Lease_Start_Date__c = Date.Today(),
                Lease_End_Date__c = Date.Today() + 120,
                Type = 'New',
                Lease_Type__c = 'land'
        );
        insert opp;

        Quote quote = new Quote(
                Pricebook2Id = standardPricebookId,
                Name = 'Test Quote',
                Type__c = 'New',
                OpportunityId = opp.Id,
                Proposed_Start_Date__c = Date.Today(),
                Proposed_End_Date__c = Date.Today() + 120
        );
        insert quote;
        
        Quote_Revision__c revisionObj = new Quote_Revision__c(Quote__c = quote.Id,
                                                              Total_Best_Rate__c = 300,
                                                              Total_Offered_Price__c = 500
                                                            );
        insert revisionObj;
        
        Quote_Revision__c revisionObj2 = new Quote_Revision__c(Quote__c = quote.Id,
                                                              Total_Best_Rate__c = 300,
                                                              Total_Offered_Price__c = 500
                                                            );
        insert revisionObj2;

        QuoteLineItem sqftLineItem1 = new QuoteLineItem(
                QuoteId = quote.Id,
            	Product2Id = productList[0].Id,
                Best_Rate__c = 100,
                Offer_Price__c = 80,
                PricebookEntryId = pbe1.Id,
                Quantity = 1,
                UnitPrice = 100,
                Start_Date__c =  Date.Today(),
                End_Date__c =  Date.Today() + 120,
                Type__c = 'Normal',
                Area__c = 1000,
                Transactional_Unit__c = 'Sqft',
            	Quote_Revision__c = revisionObj.Id
        );
        QuoteLineItem sqftLineItem2 = new QuoteLineItem(
                QuoteId = quote.Id,
            	Product2Id = productList[0].Id,
                Best_Rate__c = 100,
                Offer_Price__c = 80,
                PricebookEntryId = pbe1.Id,
                Quantity = 1,
                UnitPrice = 100,
                Start_Date__c =  Date.Today(),
                End_Date__c =  Date.Today() + 120,
                Type__c = 'Normal',
                Area__c = 1000,
                Transactional_Unit__c = 'Sqft',
            	Quote_Revision__c = revisionObj2.Id
        );
        QuoteLineItem sqftLineItem3 = new QuoteLineItem(
                QuoteId = quote.Id,
            	Product2Id = productList[0].Id,
                Best_Rate__c = 100,
                Offer_Price__c = 80,
                PricebookEntryId = pbe1.Id,
                Quantity = 1,
                UnitPrice = 100,
                Start_Date__c =  Date.Today(),
                End_Date__c =  Date.Today() + 120,
                Type__c = 'Normal',
                Area__c = 1000,
                Transactional_Unit__c = 'Sqft',
            	Quote_Revision__c = revisionObj2.Id
        );
        QuoteLineItem unitLineItem1 = new QuoteLineItem(
                QuoteId = quote.Id,
            	Product2Id = productList[1].Id,
                Best_Rate__c = 10000,
                Offer_Price__c = 8000,
                PricebookEntryId = pbe2.Id,
                Quantity = 1,
                UnitPrice = 10000,
                Start_Date__c =  Date.Today(),
                End_Date__c =  Date.Today() + 120,
                Type__c = 'Normal',
                Area__c = 1000,
                Transactional_Unit__c = 'Unit',
            	Quote_Revision__c = revisionObj.Id
        );
        QuoteLineItem unitLineItem2 = new QuoteLineItem(
                QuoteId = quote.Id,
            	Product2Id = productList[1].Id,
                Best_Rate__c = 10000,
                Offer_Price__c = 8000,
                PricebookEntryId = pbe2.Id,
                Quantity = 1,
                UnitPrice = 10000,
                Start_Date__c =  Date.Today(),
                End_Date__c =  Date.Today() + 120,
                Type__c = 'Normal',
                Area__c = 1000,
                Transactional_Unit__c = 'Unit',
            	Quote_Revision__c = revisionObj2.Id
        );
        QuoteLineItem unitLineItem3 = new QuoteLineItem(
                QuoteId = quote.Id,
            	Product2Id = productList[1].Id,
                Best_Rate__c = 10000,
                Offer_Price__c = 8000,
                PricebookEntryId = pbe2.Id,
                Quantity = 1,
                UnitPrice = 10000,
                Start_Date__c =  Date.Today(),
                End_Date__c =  Date.Today() + 120,
                Type__c = 'Normal',
                Area__c = 1000,
                Transactional_Unit__c = 'Unit',
            	Quote_Revision__c = revisionObj2.Id
        );
        List<QuoteLineItem> quoteLineItems = new List<QuoteLineItem>{sqftLineItem1,sqftLineItem2,sqftLineItem3,unitLineItem1,unitLineItem2,unitLineItem3};
        insert quoteLineItems;
    }
	
    // Method to test getLineItemsDetailsByUnitApx method and check if record return group by unit or not.
    testMethod static void getLineItemsDetailsByUnitApxTestCase() {
        
        Quote quoteObj = [SELECT Id FROM Quote WHERE Name = 'Test Quote'];
         
    	Test.startTest();
        List<ManagePriceRevisionsController.UnitLineItemWrapper> unitWrapperList = 
            ManagePriceRevisionsController.getLineItemsDetailsByUnitApx(quoteObj.Id);
        Test.stopTest();
        
        System.assertEquals(unitWrapperList.size(), 2);
        System.assertEquals(unitWrapperList[0].lineItemList.size(), 3);
        System.assertEquals(unitWrapperList[1].lineItemList.size(), 3);
    }
    
    // Method to test getLineItemsDetailsByRevisionApx method and check if record return group by revision or not.
    testMethod static void getLineItemsDetailsByRevisionApxTestCase() {
        
        Quote quoteObj = [SELECT Id FROM Quote WHERE Name = 'Test Quote'];
         
    	Test.startTest();
        List<ManagePriceRevisionsController.RevisionLineItemWrapper> revisionWrapperList = 
            ManagePriceRevisionsController.getLineItemsDetailsByRevisionApx(quoteObj.Id);
        Test.stopTest();
        
        System.assertEquals(revisionWrapperList.size(), 2);
        System.assertEquals(revisionWrapperList[0].unitLineItemList.size(), 2);
        System.assertEquals(revisionWrapperList[0].unitLineItemList[0].lineItemList.size(), 1);
        System.assertEquals(revisionWrapperList[0].unitLineItemList[1].lineItemList.size(), 1);
    }
    
    // Method to test getTotalOfferedPrice to check if Total fields updates or not if user changed offered rate or best rate.
    testMethod static void getTotalOfferedPriceTestCase() {
        
        Quote quoteObj = [SELECT Id FROM Quote WHERE Name = 'Test Quote'];
         
        List<ManagePriceRevisionsController.UnitLineItemWrapper> unitWrapperList = 
            ManagePriceRevisionsController.getLineItemsDetailsByUnitApx(quoteObj.Id);
         
        QuoteLineItem updatedQuoteLineItem = unitWrapperList[0].lineItemList[0];
        updatedQuoteLineItem.Offer_Price__c = 150;
         
    	Test.startTest();
        	updatedQuoteLineItem = 
                ManagePriceRevisionsController.getTotalOfferedPrice(updatedQuoteLineItem);
        Test.stopTest();
        
        System.assertEquals(updatedQuoteLineItem.Offer_Price__c, 150);
       
        System.assertNotEquals(updatedQuoteLineItem.Total_Offered_Price__c, NULL);
    }
    
    // Method to test saveLineItemApx to check if changed values are saved to database or not.
    testMethod static void saveLineItemApxTestCase() {
        List<String> qliToUpdateList = new List<String>();
         Quote quoteObj = [SELECT Id FROM Quote WHERE Name = 'Test Quote'];
         
        List<ManagePriceRevisionsController.UnitLineItemWrapper> unitWrapperList = 
            ManagePriceRevisionsController.getLineItemsDetailsByUnitApx(quoteObj.Id);
         
        QuoteLineItem updatedQuoteLineItem = unitWrapperList[0].lineItemList[0];
        qliToUpdateList.add(updatedQuoteLineItem.Id);
        updatedQuoteLineItem.Best_Rate__c = 130;
        updatedQuoteLineItem =   
                ManagePriceRevisionsController.getTotalOfferedPrice(updatedQuoteLineItem);
         
    	Test.startTest();
        String result = ManagePriceRevisionsController.saveLineItemApx(new List<QuoteLineItem> {updatedQuoteLineItem}, qliToUpdateList);
        Test.stopTest();
        
        QuoteLineItem udpatedLineItem = [SELECT Id, Best_Rate__c, Total_Best_Rate__c FROM QuoteLineItem WHERE ID =: updatedQuoteLineItem.Id];
        
        System.assertEquals(result, 'SUCCESS');   
        System.assertEquals(udpatedLineItem.Best_Rate__c, 130);   
        System.assertNotEquals(udpatedLineItem.Total_Best_Rate__c, NULL);
        System.assertNotEquals(qliToUpdateList, NULL);
    }
}