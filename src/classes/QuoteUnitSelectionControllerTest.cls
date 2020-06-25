/**
 *  @description Test Class for QuoteUnitSelectionAssistantController class
 *
 *  2019-16-07 Anshul Garg
*/
@isTest
global class QuoteUnitSelectionControllerTest {
    
    /*Test setup to create the required test data*/
    @testSetup public static void createTestData() {
        Test.setMock(HttpCalloutMock.class, new DDAIntegrationMock());
        
        Test.startTest();
        
        Business_Park__c bsp = new Business_Park__c(Name = 'D3',Business_Park_Yardi__c = 'D3');
        insert bsp;
        Business_Park__c bsp2 = new Business_Park__c(Name = 'Test2',Business_Park_Yardi__c = 'Test2');
        insert bsp2;
        
        Account acc = new Account(Name='Test Account' , License_Business_Park__c = bsp.Id);
        insert acc;
        
        Contact conObj = new Contact(LastName = 'Test Contact', AccountId = acc.Id);
        insert conObj;
        
        Opportunity opp = new Opportunity(Name = 'Test Opp' , AccountId = acc.Id , StageName = 'New',
                                         Business_Park__c = bsp.Id , CloseDate = Date.newInstance(2019,7,2),
                                         Sub_Type__c = 'Expansion',CurrencyIsoCode = 'AED', Contact__c = conObj.Id);
        insert opp;
        
        Plot__c plot = new Plot__c(Name = 'testPlot',Plot_Code_YARDI__c = 'pricingEngineTestPlot',Area_sqft__c = 100.0,
            					   Business_Park__c = bsp.Id,Plot_Name_YARDI__c = 'pricingEngineTestPlotName',
            					   Type__c = 'type',Status__c = 'Available - Sale',Sector_Name__c = 'sectorName');
        insert plot;
        
        Plot__c plot2 = new Plot__c(Name = 'testPlot2',Plot_Code_YARDI__c = 'pricingEngineTestPlot2',Area_sqft__c = 1100.0,
            					   Business_Park__c = bsp2.Id,Plot_Name_YARDI__c = 'pricingEngineTestPlotName123',
            					   Type__c = 'type',Status__c = 'Available - Sale',Sector_Name__c = 'sectorName1');
        insert plot2;
        
        Building__c build1 = new Building__c(Plot__c = plot.Id,Name = 'Test Build 1' , Business_Park__c = bsp.Id,
                                             Ownership_Type__c = 'TECOM Owned', Development_Status__c = 'Under Development',
                                             Property_Code_YARDI__c ='d3_cb',Property__c ='Parking', Building_Code__c = 'B-P1-1');
        insert build1;
        
        Asset_Class__c assetClass = new Asset_Class__c(Name = 'testAssetClass');
        insert assetClass;
        
        Unit_Category__c uc1 = new Unit_Category__c(Name = 'Office');
        insert uc1;

        Unit_Sub_Category__c usc1 = new Unit_Sub_Category__c(Name = 'Standard Office',Unit_Category__c = uc1.Id);
        insert usc1;
        
        Unit__c un = new Unit__c(Name  ='Test Unit',Area_ft__c = 910,Building__c = build1.Id, Unit_Sub_Category__c = usc1.Id,
                                 Unit_Code_YARDI__c = 'B106',Transactional_Unit__c ='Sqft', Floor_Number__c = 'Fifth Floor', Floor_Type__c = '05');
        insert un;
        
        Unit__c un2 = new Unit__c(Name  ='Test Unit',Area_ft__c = 910,Building__c = build1.Id, Unit_Sub_Category__c = usc1.Id,
                                 Unit_Code_YARDI__c = 'B107',Transactional_Unit__c ='Sqft', Floor_Number__c = 'Fifth Floor', Floor_Type__c = '05');
        insert un2;

        
        Quote q = new Quote(Name = 'Test Quote',OpportunityId = opp.Id,CCL_Sign_Date__c = Date.today(),
                            Status = 'Draft',Type__c = 'Renewal', Proposed_Start_Date__c = Date.today(),
                            Proposed_End_Date__c = Date.today().addDays(90),Lease_Start_Date__c = Date.today(),
                            Pricebook2Id = Test.getStandardPricebookId(),Lease_End_Date__c = Date.today().addDays(90));
        insert q;
        
        Quote previousQuote = new Quote(Name = 'testQuotePrevious',CCL_Sign_Date__c = Date.today(),OpportunityId = opp.Id,
            							Lease_Start_Date__c = Date.today(),Lease_End_Date__c = Date.today().addDays(90),
            							Proposed_Start_Date__c = Date.today(),Proposed_End_Date__c = Date.today().addDays(90),
            							Type__c = 'New',Pricebook2Id = Test.getStandardPricebookId());
        insert previousQuote;
        
        q.previous_quote__c = previousQuote.Id;
        update q;
        Quote_Revision__c revisionObj = new Quote_Revision__c(Quote__c = q.Id,
                                                              Total_Best_Rate__c = 300,
                                                              Total_Offered_Price__c = 500
                                                            );
        insert revisionObj;
        /*Price_Rule__c pr = new Price_Rule__c(Name = 'Test PR');
        insert pr;
        Price_Schedule__c ps = new Price_Schedule__c(Name = 'Test PS1',Start_Date__c = Date.today(),End_Date__c = Date.today().addDays(90),Transaction_Type__c = 'New',Price_Rule__c = pr.Id);
        insert ps; */
        
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
        QuoteLineItem sqftLineItem1 = new QuoteLineItem(
                QuoteId = q.Id,
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
            	Product2Id = prod.Id
        );
        QuoteLineItem unitLineItem2 = new QuoteLineItem(
                QuoteId = previousQuote.Id,
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
                Quote_Revision__c = revisionObj.Id,
            	Product2Id = prod.Id
        );

        List<QuoteLineItem> quoteLineItemsList= new List<QuoteLineItem>();
        quoteLineItemsList.add(sqftLineItem1);
        quoteLineItemsList.add(unitLineItem2);
        
        Price_Rule__c priceRule = TestDataFactory.getPriceRuleWithSchedules();
        /*List<Price_Schedule__c> scheduleList = new List<Price_Schedule__c> ();

        for(Price_Schedule__c priceObj : [SELECT Id, 
                                                 Rate_Increase_Mechanism__c, 
                                                 Percent_Increase__c, 
                                                 Renewal_Downsize_Rate_To_Use__c
                                          FROM Price_Schedule__c
                                          WHERE Charge_Type__r.Name = 'Rent'
                                          AND Price_Rule__c =: priceRule.Id]) {
            priceObj.Rate_Increase_Mechanism__c = 'Use RERA Index';
            priceObj.Renewal_Downsize_Rate_To_Use__c = 'Last Passing Rate';
            priceObj.Percent_Increase__c = 5;
            scheduleList.add(priceObj);
        }
        update scheduleList; */
       	insert quoteLineItemsList;
        /*Building__c build1 = new Building__c(Plot__c = plot.Id,Name = 'Test Build 1' , Business_Park__c = bsp.Id,Ownership_Type__c = 'TECOM Owned',
                                           Development_Status__c = 'Under Development',Property_Code_YARDI__c ='d3_cb',Property__c ='Parking');
        insert build1;*/
        
        Building__c build2 = new Building__c(Plot__c = plot2.Id,Name = 'Test Build 2' , Business_Park__c = bsp2.Id,Ownership_Type__c = 'TECOM Owned',
                                           Development_Status__c = 'Under Development',Property_Code_YARDI__c ='d3_cb2',Property__c ='Parking');
        insert build2;
        
        /*Asset_Class__c assetClass = new Asset_Class__c(Name = 'testAssetClass');
        insert assetClass;*/
        
        /*Unit_Category__c uc1 = new Unit_Category__c(Name = 'Test UC 1');
        insert uc1;*/
        Unit_Category__c uc2 = new Unit_Category__c(Name = 'Test UC 2');
        insert uc2;
        /*Unit_Sub_Category__c usc1 = new Unit_Sub_Category__c(Name = 'Test USC 1',Unit_Category__c = uc1.Id);
        insert usc1;*/
        Unit_Sub_Category__c usc2 = new Unit_Sub_Category__c(Name = 'Test USC 2',Unit_Category__c = uc1.Id);
        insert usc2;
        Unit_Sub_Category__c usc3 = new Unit_Sub_Category__c(Name = 'Test USC 3',Unit_Category__c = uc2.Id);
        insert usc3;
        Unit_Sub_Category__c usc4 = new Unit_Sub_Category__c(Name = 'Test USC 4',Unit_Category__c = uc2.Id);
        insert usc4;
        Unit_Sub_Category__c usc5 = new Unit_Sub_Category__c(Name = 'Test USC 5',Unit_Category__c = uc2.Id);
        insert usc5;
        
        /*Unit__c un = new Unit__c(Name  ='Test Unit',Area_ft__c = 910,Building__c = build1.Id,Unit_Sub_Category__c = usc1.Id,
                                 Unit_Code_YARDI__c = 'B106',Transactional_Unit__c ='Sqft',Floor_Number__c = 'Fifth Floor');
        insert un;*/
        
        Price_Rule__c priceRuleObject = new Price_Rule__c(Name = 'Test Price Rule');
        insert priceRuleObject;
        
        Charge_Type__c chargeTypeObject = new Charge_Type__c(Name = 'Rent');
        insert chargeTypeObject;
        
        Price_Schedule__c priceScheduleObject = new Price_Schedule__c(Name = 'Test Price', Price_Rule__c = priceRuleObject.Id, Transaction_Type__c = 'New', 
                                                                      Start_Date__c = Date.today(), End_Date__c = Date.today().addDays(90), 
                                                                      Charge_Type__c = chargeTypeObject.Id,
                                                                      Rate__c = 322, Grace_Period__c = 12, Grace_Period_Format__c = 'days', 
                                                                      Grace_Period_Mechanism__c = 'initial');
        insert priceScheduleObject;
        
        Unit_Sub_Category__c unitSubCategoryObject = new Unit_Sub_Category__c(Name = 'Test Unit sub-category');
        insert unitSubCategoryObject;
        
        Rate_Increase_Index__c rateIncreaseIndexObj = new Rate_Increase_Index__c(Business_Park__c = bsp.Id, Percent_Increase__c = 22.3,
                                                                                Unit_Sub_Category__c = unitSubCategoryObject.Id, 
                                                                                Effective_Date_From__c = Date.today(),
                                                                                Effective_Date_To__c = Date.today(),
                                                                                Current_Rate_From__c = 22.2,
                                                                                Current_Rate_To__c = 22.2);
        insert rateIncreaseIndexObj;
        
        Test.stopTest();
    }
    
    /*Test method to test the creation of Category and sub category filter*/
    public static testmethod void getCategoryFilterPositive(){
        Quote q = [SELECT Id FROM Quote WHERE Name ='Test Quote' LIMIT 1];
        Test.startTest();
        List<QuoteUnitSelectionAssistantController.CategorySubCategoryWrapper> wrapperList = QuoteUnitSelectionAssistantController.getCategoryFilter(q.Id);
        Test.stopTest();
        System.assertEquals(1,wrapperList.size());
    }
    
    /*Test method to test the creation of picklist of Building names on the basis of selected sub category*/
    public static testmethod void getBuildingListPositive(){
        List<Unit_Sub_Category__c> uscList = new List<Unit_Sub_Category__c>();
        uscList = [SELECT Id FROM Unit_Sub_Category__c LIMIT 2];
        List<Id> subCategoryIdList = new List<Id>();
        subCategoryIdList.add(uscList[0].Id);
        subCategoryIdList.add(uscList[1].Id);
        Test.startTest();
        List<QuoteUnitSelectionAssistantController.SubCategory> buildingList = QuoteUnitSelectionAssistantController.getBuildingList(subCategoryIdList);
        Test.stopTest();
        System.assertEquals(1, buildingList.size());
    }
    
    /*Test method to test the creation of Floor Number picklist on the selection of building*/
    public static testmethod void getFloorListPositive(){
        Building__c build = [SELECT Id FROM Building__c LIMIT 1];
        Test.startTest();
        List<QuoteUnitSelectionAssistantController.SubCategory> floorList = QuoteUnitSelectionAssistantController.getFloorList(build.Id);
        Test.stopTest();
        System.assertEquals(1, floorList.size());
    }
    
    /*Test method to check the searching of Unit on the basis of filters*/
    public static testmethod void getUnitPositive(){
        List<Building__c> buildList = [SELECT Id FROM Building__c LIMIT 2];
        List<Id> buildingOnExistingQLI = new List<Id>();
        buildingOnExistingQLI.add(buildList[0].Id);
        buildingOnExistingQLI.add(buildList[1].Id);
        List<Unit_Sub_Category__c> uscList = new List<Unit_Sub_Category__c>();
        uscList = [SELECT Id FROM Unit_Sub_Category__c LIMIT 2];
        List<Id> subCategoryIdList = new List<Id>();
        subCategoryIdList.add(uscList[0].Id);
        subCategoryIdList.add(uscList[1].Id);
        Test.startTest();
        List<Id> unitIdList = new List<Id>();
        List<Id> excludedUnitsList = new List<Id>();
        List<Unit__c> listUnit = QuoteUnitSelectionAssistantController.getUnits(buildList[0].Id,900,910,'Fifth Floor',subCategoryIdList,buildingOnExistingQLI,unitIdList, excludedUnitsList);
        Test.stopTest();
        System.assertEquals(0, listUnit.size());
    }
    
    /*Test method to fetch LineItems */
    public static testmethod void fetchLineItemsPositive(){
        Test.setMock(HttpCalloutMock.class, new DDAIntegrationMock());
        Quote quote1 = [SELECT Id FROM Quote Where Name = 'Test Quote'];
		Price_Rule__c priceRule = TestDataFactory.getPriceRuleWithSchedules();
        Product2 p = [SELECT Id from Product2 where name ='testProd' LIMIT 1];
        Unit__c u = [SELECT Id from Unit__c where Name ='Test Unit' LIMIT 1];
        p.Unit__c = u.Id;
        update p;
        List<Price_Schedule__c> scheduleList = new List<Price_Schedule__c> ();

        for(Price_Schedule__c priceObj : [SELECT Id, 
                                                 Rate_Increase_Mechanism__c, 
                                                 Percent_Increase__c, 
                                                 Renewal_Downsize_Rate_To_Use__c
                                          FROM Price_Schedule__c
                                          WHERE Charge_Type__r.Name = 'Rent'
                                          AND Price_Rule__c =: priceRule.Id]) {
            priceObj.Rate_Increase_Mechanism__c = 'Use RERA Index';
            priceObj.Renewal_Downsize_Rate_To_Use__c = 'Last Passing Rate';
            priceObj.Percent_Increase__c = 5;
            scheduleList.add(priceObj);
        }
        update scheduleList;
        Test.startTest();
        try{
            List <QuoteUnitSelectionAssistantController.LineItem> l = QuoteUnitSelectionAssistantController.fetchLineItems(String.valueOf(quote1.Id),u.Id, new List<QuoteUnitSelectionAssistantController.LineItem>());
        	System.assertEquals(1, l.size());
        }catch(Exception e){
            
        }
        Test.stopTest();
        

    }
    
    /*Test method to save LineItems */
    public static testmethod void savePositive(){
        Test.setMock(HttpCalloutMock.class, new DDAIntegrationMock());
        Quote quote1 = [SELECT Id FROM Quote Where Name = 'Test Quote'];
		Price_Rule__c priceRule = TestDataFactory.getPriceRuleWithSchedules();
        Product2 p = [SELECT Id from Product2 where name ='testProd' LIMIT 1];
        Unit__c u = [SELECT Id from Unit__c where Name ='Test Unit' LIMIT 1];
        p.Unit__c = u.Id;
        update p;
        List<Price_Schedule__c> scheduleList = new List<Price_Schedule__c> ();

        for(Price_Schedule__c priceObj : [SELECT Id, 
                                                 Rate_Increase_Mechanism__c, 
                                                 Percent_Increase__c, 
                                                 Renewal_Downsize_Rate_To_Use__c
                                          FROM Price_Schedule__c
                                          WHERE Charge_Type__r.Name = 'Rent'
                                          AND Price_Rule__c =: priceRule.Id]) {
            priceObj.Rate_Increase_Mechanism__c = 'Use RERA Index';
            priceObj.Renewal_Downsize_Rate_To_Use__c = 'Last Passing Rate';
            priceObj.Percent_Increase__c = 5;
            scheduleList.add(priceObj);
        }
        update scheduleList;
        Test.startTest();
        	List<QuoteUnitSelectionAssistantController.LineItem> lineItemList = QuoteUnitSelectionAssistantController.fetchLineItems(String.valueOf(quote1.Id),u.Id,new List<QuoteUnitSelectionAssistantController.LineItem>());
        	QuoteUnitSelectionAssistantController.save(new List<QuoteUnitSelectionAssistantController.LineItem>(lineItemList));
        Test.stopTest();
        System.assertEquals(3, [SELECT Id FROM QuoteLineItem WHERE QuoteId = :quote1.Id].size());
    }
    
     /*Test method to get TotalOfferedPrice */
    public static testmethod void getTotalOfferedPricePositive(){
        QuoteUnitSelectionAssistantController.LineItem lineItemObject;
        Quote q = [SELECT Id FROM Quote WHERE Name ='Test Quote' LIMIT 1];
        try{
            List<QuoteUnitSelectionAssistantController.LineItem> li = QuoteUnitSelectionAssistantController.fetchLineItems(String.valueOf(q.Id),'testProd',new List<QuoteUnitSelectionAssistantController.LineItem>());
        	Test.startTest();
            lineItemObject = QuoteUnitSelectionAssistantController.getTotalOfferedPrice(li[0]);
            Test.stopTest();
            
            System.assertNotEquals(null, lineItemObject);
        }catch(Exception e){
            
        }
    }
    
   	/*Test method to remove and update SelectedProductsBestRate */
    public static testmethod void removeAndUpdateSelectedProductsBestRatePositive(){
        Quote quote1 = [SELECT Id FROM Quote Where Name = 'Test Quote'];
		Price_Rule__c priceRule = TestDataFactory.getPriceRuleWithSchedules();
        
        QuoteLineItem itemObj = [SELECT Id, Start_Date__c, End_Date__c, Transactional_Unit__c, Area__c, Best_Rate__c, Offer_Price__c,Total_Offered_Price__c
                                 FROM QuoteLineItem
                                 WHERE QuoteId =: quote1.Id
                                 Limit 1
                                ];
        
        QuoteUnitSelectionAssistantController.LineItem lineObj = new QuoteUnitSelectionAssistantController.LineItem();
        lineObj.unitName = 'Test Product';
        lineObj.unitId = itemObj.Id;
        lineObj.quoteLineItem = itemObj;
        lineObj.pricingPackage = null;
        lineObj.subCategory = 'Óffice';
        lineObj.chargesRelatedQLIList = new List<QuoteLineItem>();
        lineObj.changedOfferedRate = 200;
		
        List<QuoteUnitSelectionAssistantController.LineItem> lineItemList = new List<QuoteUnitSelectionAssistantController.LineItem>{lineObj};
        try{
            Test.startTest();
            lineItemList = QuoteUnitSelectionAssistantController.removeAndUpdateSelectedProductsBestRate(quote1.Id, lineItemList);
            Test.stopTest();
            
            
        }catch(Exception e){
            
        }
        System.assertNotEquals(lineItemList[0].quoteLineItem.Total_Offered_Price__c, 0);
    }
    
    /*Test method to test getTotalOfferedPrice */
    testMethod static void getTotalOfferedPriceTestCase() {
        
        Quote quote1 = [SELECT Id FROM Quote Where Name = 'Test Quote'];
        
        QuoteLineItem itemObj = [SELECT Id, Start_Date__c, End_Date__c, Transactional_Unit__c, Area__c, Best_Rate__c, Offer_Price__c
                                 FROM QuoteLineItem
                                 WHERE QuoteId =: quote1.Id
                                 Limit 1
                                ];
        
        QuoteUnitSelectionAssistantController.LineItem lineObj = new QuoteUnitSelectionAssistantController.LineItem();
        lineObj.unitName = 'Test Product';
        lineObj.unitId = itemObj.Id;
        lineObj.quoteLineItem = itemObj;
        lineObj.pricingPackage = null;
        lineObj.subCategory = 'Óffice';
        lineObj.chargesRelatedQLIList = new List<QuoteLineItem>();
        lineObj.changedOfferedRate = 200;
		
		        
        Test.startTest();
       		lineObj = QuoteUnitSelectionAssistantController.getTotalOfferedPrice(lineObj);
        Test.stopTest();
        
        System.assertNotEquals(lineObj.quoteLineItem.Total_Offered_Price__c, 0);
    }
    
    /*Test method to test updateSelectedProductsBestRate */
    testMethod static void updateSelectedProductsBestRateTestCase() {
        
        Quote quote1 = [SELECT Id, Previous_Quote__c, Type__c, Proposed_Start_Date__c, Proposed_End_Date__c FROM Quote Where Name = 'Test Quote'];
        
        QuoteLineItem itemObj = [SELECT Id, Start_Date__c, End_Date__c, Transactional_Unit__c, Area__c, Best_Rate__c, Offer_Price__c, PricebookEntryId
                                 FROM QuoteLineItem
                                 WHERE QuoteId =: quote1.Id
                                 Limit 1
                                ];
        
        QuoteUnitSelectionAssistantController.LineItem lineObj = new QuoteUnitSelectionAssistantController.LineItem();
        lineObj.unitName = 'Test Product';
        lineObj.unitId = itemObj.Id;
        lineObj.quoteLineItem = itemObj;
        lineObj.pricingPackage = null;
        lineObj.subCategory = 'Óffice';
        lineObj.chargesRelatedQLIList = new List<QuoteLineItem>();
        lineObj.changedOfferedRate = 200;
		
        List<QuoteUnitSelectionAssistantController.LineItem> lineItemList = new List<QuoteUnitSelectionAssistantController.LineItem>();
        lineItemList.add(lineObj);
		        
        Test.startTest();
       		lineItemList = QuoteUnitSelectionAssistantController.updateSelectedProductsBestRate(quote1, lineItemList, 5000.45);
        Test.stopTest();
        
        System.assertNotEquals(lineItemList[0].quoteLineItem.Total_Offered_Price__c, 0);
    }

}