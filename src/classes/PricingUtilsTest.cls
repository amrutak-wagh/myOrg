/**
 *  @description Test class for PricingUtils
 *
 *  2019-07-04  Samuel Arroyo    First version
 *  2019-07-15  Amruta K         Modified class to add new test cases.
 */
@IsTest
public class PricingUtilsTest {
    
    // Method to create test setup data.
    public static Quote createData() {

        Id standardPricebookId = Test.getStandardPricebookId();
         Test.setMock(HttpCalloutMock.class, new DDAIntegrationMock());

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
        insert new List<Product2>{unit1, unit2};

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
                Type = 'New'
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

        Opportunity oppRenewalObj = new Opportunity(
                Pricebook2Id = standardPricebookId,
                Name = 'Test Opp',
                AccountId = account.Id,
                StageName = 'New',
                CloseDate = Date.today(),
                Business_Park__c = businessPark.Id,
                Lease_Start_Date__c = Date.Today() + 120,
                Lease_End_Date__c = Date.Today() + 120 + 365,
                Type = 'Renewal',
                Parent_Opportunity__c = opp.Id
        );
        insert oppRenewalObj;

        Quote quote1 = new Quote(
                Pricebook2Id = standardPricebookId,
                Name = 'Test Quote 1',
                Type__c = 'New',
                OpportunityId = oppRenewalObj.Id,
                Proposed_Start_Date__c = Date.Today() + 120,
                Proposed_End_Date__c = Date.Today() + 120 + 365,
                Previous_Quote__c = quote.Id,
                Grace_Period__c = 30,
                Grace_Period_Period__c = 'days',
                Grace_Period_Mechanism__c = 'initial'
        );
        insert quote1;

        QuoteLineItem sqftLineItem = new QuoteLineItem(
                QuoteId = quote.Id,
                Best_Rate__c = 100,
                Offer_Price__c = 80,
                PricebookEntryId = pbe1.Id,
                Quantity = 1,
                UnitPrice = 100,
                Start_Date__c =  Date.Today(),
                End_Date__c =  Date.Today() + 120,
                Type__c = 'Normal',
                Area__c = 1000,
                Transactional_Unit__c = 'Sqft'
        );
        QuoteLineItem unitLineItem = new QuoteLineItem(
                QuoteId = quote.Id,
                Best_Rate__c = 10000,
                Offer_Price__c = 8000,
                PricebookEntryId = pbe2.Id,
                Quantity = 1,
                UnitPrice = 10000,
                Start_Date__c =  Date.Today(),
                End_Date__c =  Date.Today() + 120,
                Type__c = 'Normal',
                Area__c = 1000,
                Transactional_Unit__c = 'Unit'
        );
        List<QuoteLineItem> quoteLineItems = new List<QuoteLineItem>{sqftLineItem,unitLineItem};
        insert quoteLineItems;

        return quote1;
    }
    
    // Method to create test setup data.
    public static Quote createDataRenewal() {

        Id standardPricebookId = Test.getStandardPricebookId();
         Test.setMock(HttpCalloutMock.class, new DDAIntegrationMock());

        Business_Park__c businessPark = new Business_Park__c(
                Name = 'D3', Business_Park_Code__c = 'D3'
        );
        insert businessPark;
        
        Plot__c plot = new Plot__c(Name = 'testPlot',Plot_Code_YARDI__c = 'pricingEngineTestPlot',Area_sqft__c = 100.0,
            					   Business_Park__c = businessPark.Id,Plot_Name_YARDI__c = 'pricingEngineTestPlotName',
            					   Type__c = 'type',Status__c = 'Available - Sale',Sector_Name__c = 'sectorName');
        insert plot;
        
        Building__c build1 = new Building__c(Plot__c = plot.Id,Name = 'Test Build 1' , Business_Park__c = businessPark.Id,
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

        Account account = new Account(
                Name = 'Test Company'
        );
        insert account;

        Product2 unit1 = new Product2(
                IsActive = true,
                Name = 'Unit 1',
                Transaction_Unit__c = 'Sqft',
                Unit__c = un.Id
        );
        Product2 unit2 = new Product2(
                IsActive = true,
                Name = 'Unit 2',
                Transaction_Unit__c = 'Unit',
                Unit__c = un2.Id
        );
        insert new List<Product2>{unit1, unit2};

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
                Type = 'New'
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

        Opportunity oppRenewalObj = new Opportunity(
                Pricebook2Id = standardPricebookId,
                Name = 'Test Opp',
                AccountId = account.Id,
                StageName = 'New',
                CloseDate = Date.today(),
                Business_Park__c = businessPark.Id,
                Lease_Start_Date__c = Date.Today() + 120,
                Lease_End_Date__c = Date.Today() + 120 + 365,
                Type = 'Renewal',
                Parent_Opportunity__c = opp.Id
        );
        insert oppRenewalObj;

        Quote quote1 = new Quote(
                Pricebook2Id = standardPricebookId,
                Name = 'Test Quote 1',
                Type__c = 'New',
                OpportunityId = oppRenewalObj.Id,
                Proposed_Start_Date__c = Date.Today() + 120,
                Proposed_End_Date__c = Date.Today() + 120 + 365,
                Previous_Quote__c = quote.Id,
            	Grace_Period__c = 30,
                Grace_Period_Period__c = 'days',
                Grace_Period_Mechanism__c = 'initial'
        );
        insert quote1;
		
        TestDataFactory.getPriceRuleWithSchedules();
        
        List<Price_Schedule__c> priceScheduleList = [SELECT Id, Price_Rule__c FROM Price_Schedule__c WHERE Charge_Type__r.Name = 'Rent'];
        
        system.debug('priceScheduleList-----:'+priceScheduleList);
        
        QuoteLineItem sqftLineItem = new QuoteLineItem(
                QuoteId = quote.Id,
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
            	Transaction_Type__c = 'Renewal',
            	Price_Schedule__c = priceScheduleList[0].Id
        );
        QuoteLineItem unitLineItem = new QuoteLineItem(
                QuoteId = quote.Id,
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
            	Transaction_Type__c = 'Renewal',
            	Price_Schedule__c = priceScheduleList[0].Id
        );
        List<QuoteLineItem> quoteLineItems = new List<QuoteLineItem>{sqftLineItem,unitLineItem};
        insert quoteLineItems;

        return quote1;
    }
    
    // Method to create test setup data.
    public static Quote setUp() {

        Id standardPricebookId = Test.getStandardPricebookId();
         Test.setMock(HttpCalloutMock.class, new DDAIntegrationMock());

        Business_Park__c businessPark = new Business_Park__c(
                Name = 'D3', Business_Park_Code__c = 'D3'
        );
        insert businessPark;
        
        Plot__c plot = new Plot__c(Name = 'testPlot',Plot_Code_YARDI__c = 'pricingEngineTestPlot',Area_sqft__c = 100.0,
            					   Business_Park__c = businessPark.Id,Plot_Name_YARDI__c = 'pricingEngineTestPlotName',
            					   Type__c = 'type',Status__c = 'Available - Sale',Sector_Name__c = 'sectorName');
        insert plot;
        
        Building__c build1 = new Building__c(Plot__c = plot.Id,Name = 'Test Build 1' , Business_Park__c = businessPark.Id,
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

        Account account = new Account(
                Name = 'Test Company'
        );
        insert account;

        Product2 unit1 = new Product2(
                IsActive = true,
                Name = 'Unit 1',
                Transaction_Unit__c = 'Sqft',
                Unit__c = un.Id
        );
        Product2 unit2 = new Product2(
                IsActive = true,
                Name = 'Unit 2',
                Transaction_Unit__c = 'Unit',
                Unit__c = un2.Id
        );
        insert new List<Product2>{unit1, unit2};

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
                Type = 'New'
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

        Opportunity oppRenewalObj = new Opportunity(
                Pricebook2Id = standardPricebookId,
                Name = 'Test Opp',
                AccountId = account.Id,
                StageName = 'New',
                CloseDate = Date.today(),
                Business_Park__c = businessPark.Id,
                Lease_Start_Date__c = Date.Today() + 120,
                Lease_End_Date__c = Date.Today() + 120 + 365,
                Type = 'Renewal',
                Parent_Opportunity__c = opp.Id
        );
        insert oppRenewalObj;

        Quote quote1 = new Quote(
                Pricebook2Id = standardPricebookId,
                Name = 'Test Quote 1',
                Type__c = 'New',
                OpportunityId = oppRenewalObj.Id,
                Proposed_Start_Date__c = Date.Today() + 120,
                Proposed_End_Date__c = Date.Today() + 120 + 365,
                Previous_Quote__c = quote.Id,
            	Grace_Period__c = 30,
                Grace_Period_Period__c = 'days',
                Grace_Period_Mechanism__c = 'initial'
        );
        insert quote1;
		
       // TestDataFactory.getPriceRuleWithSchedules();
        
        //List<Price_Schedule__c> priceScheduleList = [SELECT Id, Price_Rule__c FROM Price_Schedule__c WHERE Charge_Type__r.Name = 'Rent'];
        
        //system.debug('priceScheduleList-----:'+priceScheduleList);
        //
         Charge_Type__c chargeTypeRent = new Charge_Type__c(Name = 'Rent');
        Charge_Type__c chargeTypeServiceCharge = new Charge_Type__c(Name = 'Service Charge');
        insert new List<Charge_Type__c>{chargeTypeRent, chargeTypeServiceCharge};

        Price_Rule__c priceRule = new Price_Rule__c(
                Name = 'Price Rule ' + String.valueOf(Math.random()),
                Status__c = 'Active',
                Business_Park_Operator__c = 'equal',Business_Park_Value__c = 'D3',
                Building_Operator__c = 'include',Building_Value__c = 'B-P1-1;B-P1-2',
                Floor_Operator__c = 'equal',Floor_Value__c = '05',
                Utility_Submeter_Operator__c = 'equal',Utility_Submeter_Value__c = '1',
                Cooling_Submeter_Operator__c = 'equal',Cooling_Submeter_Value__c = '1',
                Asset_Class_Operator__c = 'include',Asset_Class_Value__c = 'Commercial',
                Product_Category_Operator__c = 'include',Product_Category_Value__c = 'Office',
                Product_Sub_Category_Operator__c = 'include',Product_Sub_Category_Value__c = 'Standard Office;Executive Office',
                Ownership_Status_Operator__c = 'equal',Ownership_Status_Value__c = 'TECOM Owned',
                Current_RERA_Index_Operator__c = 'less than',Current_RERA_Index_Value__c = '9999',
                Rent_Cap_Operator__c = 'more than',Rent_Cap_Value__c = '0',
                Lease_Term_Operator__c = 'between',Lease_Term_Value__c = '0-10000'
        );
        insert priceRule;

        List<Price_Schedule__c> priceSchedules = new List<Price_Schedule__c>();
        for (Integer i = -2; i < 4; i++) {
            Date startDate = Date.today().addMonths(i*6);
            Date endDate = startDate.addMonths(6).addDays(-1);

            priceSchedules.add(new Price_Schedule__c(
                    Price_Rule__c = priceRule.Id,
                    Name = 'Rent (new)',
                    Transaction_Type__c = 'New',
                    Charge_Type__c = chargeTypeRent.Id,
                    Start_Date__c = startDate,
                    End_Date__c = endDate,
                    Rate__c = 100,
                    Rate_Cap__c = 140,
                    Transactional_Unit__c = 'Sq ft',
                    Grace_Period_Mechanism__c = 'initial',
                    Grace_Period__c = 30,
                    Grace_Period_Format__c = 'days',
                    Total_Leased_Area_Operator__c = 'less than',
                    Total_Leased_Area_Value__c = '9999999'
            ));
            priceSchedules.add(new Price_Schedule__c(
                    Price_Rule__c = priceRule.Id,
                    Name = 'Rent (renewal)',
                    Transaction_Type__c = 'Renewal',
                    Charge_Type__c = chargeTypeRent.Id,
                    Start_Date__c = startDate,
                    End_Date__c = endDate,
                    Rate__c = 100,
                    Rate_Cap__c = 140,
                    Transactional_Unit__c = 'Sq ft',
                    Rate_Increase_Mechanism__c = 'Fixed Percentage',
                    Percent_Increase__c = 5,
                    Renewal_Downsize_Rate_To_Use__c = 'Initial Best Rate',
                    Total_Leased_Area_Operator__c = 'less than',
                    Total_Leased_Area_Value__c = '9999999'
            ));
            priceSchedules.add(new Price_Schedule__c(
                    Price_Rule__c = priceRule.Id,
                    Name = 'Rent (renewal)',
                    Transaction_Type__c = 'Renewal',
                    Charge_Type__c = chargeTypeRent.Id,
                    Start_Date__c = startDate,
                    End_Date__c = endDate,
                    Rate__c = 100,
                    Rate_Cap__c = 140,
                    Transactional_Unit__c = 'Sq ft',
                    Rate_Increase_Mechanism__c = 'Fixed Percentage',
                    Percent_Increase__c = 5,
                    Renewal_Downsize_Rate_To_Use__c = 'Last Best Rate',
                    Total_Leased_Area_Operator__c = 'less than',
                    Total_Leased_Area_Value__c = '9999999'
            ));
            priceSchedules.add(new Price_Schedule__c(
                    Price_Rule__c = priceRule.Id,
                    Name = 'Rent (renewal)',
                    Transaction_Type__c = 'Renewal',
                    Charge_Type__c = chargeTypeRent.Id,
                    Start_Date__c = startDate,
                    End_Date__c = endDate,
                    Rate__c = 100,
                    Rate_Cap__c = 140,
                    Transactional_Unit__c = 'Sq ft',
                    Rate_Increase_Mechanism__c = 'Fixed Percentage',
                    Percent_Increase__c = 5,
                    Renewal_Downsize_Rate_To_Use__c = 'Last Passing Rate',
                    Total_Leased_Area_Operator__c = 'less than',
                    Total_Leased_Area_Value__c = '9999999'
            ));
            priceSchedules.add(new Price_Schedule__c(
                    Price_Rule__c = priceRule.Id,
                    Name = 'Rent (renewal)',
                    Transaction_Type__c = 'Renewal',
                    Charge_Type__c = chargeTypeRent.Id,
                    Start_Date__c = startDate,
                    End_Date__c = endDate,
                    Rate__c = 100,
                    Rate_Cap__c = 140,
                    Transactional_Unit__c = 'Sq ft',
                    Rate_Increase_Mechanism__c = 'Use RERA Index',
                    Percent_Increase__c = 5,
                    Renewal_Downsize_Rate_To_Use__c = 'Initial Best Rate',
                    Total_Leased_Area_Operator__c = 'less than',
                    Total_Leased_Area_Value__c = '9999999'
            ));
            priceSchedules.add(new Price_Schedule__c(
                    Price_Rule__c = priceRule.Id,
                    Name = 'Rent (renewal)',
                    Transaction_Type__c = 'Renewal',
                    Charge_Type__c = chargeTypeRent.Id,
                    Start_Date__c = startDate,
                    End_Date__c = endDate,
                    Rate__c = 100,
                    Rate_Cap__c = 140,
                    Transactional_Unit__c = 'Sq ft',
                    Rate_Increase_Mechanism__c = 'Use RERA Index',
                    Percent_Increase__c = 5,
                    Renewal_Downsize_Rate_To_Use__c = 'Last Best Rate',
                    Total_Leased_Area_Operator__c = 'less than',
                    Total_Leased_Area_Value__c = '9999999'
            ));
            priceSchedules.add(new Price_Schedule__c(
                    Price_Rule__c = priceRule.Id,
                    Name = 'Rent (renewal)',
                    Transaction_Type__c = 'Renewal',
                    Charge_Type__c = chargeTypeRent.Id,
                    Start_Date__c = startDate,
                    End_Date__c = endDate,
                    Rate__c = 100,
                    Rate_Cap__c = 140,
                    Transactional_Unit__c = 'Sq ft',
                    Rate_Increase_Mechanism__c = 'Use RERA Index',
                    Percent_Increase__c = 5,
                    Renewal_Downsize_Rate_To_Use__c = 'Last Passing Rate',
                    Total_Leased_Area_Operator__c = 'less than',
                    Total_Leased_Area_Value__c = '9999999'
            ));
        }
        insert priceSchedules;
        
        QuoteLineItem sqftLineItem = new QuoteLineItem(
                QuoteId = quote.Id,
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
            	Transaction_Type__c = 'Renewal',
            	Price_Schedule__c = priceSchedules[1].Id
        );
        QuoteLineItem unitLineItem = new QuoteLineItem(
                QuoteId = quote.Id,
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
            	Transaction_Type__c = 'Renewal',
            	Price_Schedule__c = priceSchedules[1].Id
        );
        List<QuoteLineItem> quoteLineItems = new List<QuoteLineItem>{sqftLineItem,unitLineItem};
        insert quoteLineItems;

        return quote1;
    }

    // Method to test CalculateQuoteLineItemTotals.
    @IsTest
    static void testCalculateQuoteLineItemTotals() {
       Id standardPricebookId = Test.getStandardPricebookId();
       Test.setMock(HttpCalloutMock.class, new DDAIntegrationMock());

        Business_Park__c businessPark = new Business_Park__c(
                Name = 'D3'
        );
        insert businessPark;

        Account account = new Account(
                Name = 'Test Company'
        );
        insert account;

        Opportunity opp = new Opportunity(
                Pricebook2Id = standardPricebookId,
                Name = 'Test Opp',
                AccountId = account.Id,
                StageName = 'Draft',
                CloseDate = Date.today(),
                Business_Park__c = businessPark.Id
        );
        insert opp;

        Date startDate = Date.newInstance(2019,1,1);
        Date endDate = Date.newInstance(2019, 12, 31);

        Quote quote = new Quote(
                Pricebook2Id = standardPricebookId,
                Name = 'Test Quote',
                Type__c = 'New',
                OpportunityId = opp.Id,
                Proposed_Start_Date__c = startDate,
                Proposed_End_Date__c = endDate
        );
        insert quote;

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
        insert new List<Product2>{unit1, unit2};

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

        QuoteLineItem sqftLineItem = new QuoteLineItem(
                QuoteId = quote.Id,
                Best_Rate__c = 100,
                Offer_Price__c = 80,
                PricebookEntryId = pbe1.Id,
                Quantity = 1,
                UnitPrice = 100,
                Start_Date__c = startDate,
                End_Date__c = endDate,
                Type__c = 'Normal',
                Area__c = 1000,
                Transactional_Unit__c = 'Sqft'
        );
        QuoteLineItem unitLineItem = new QuoteLineItem(
                QuoteId = quote.Id,
                Best_Rate__c = 10000,
                Offer_Price__c = 8000,
                PricebookEntryId = pbe2.Id,
                Quantity = 1,
                UnitPrice = 10000,
                Start_Date__c = startDate,
                End_Date__c = endDate,
                Type__c = 'Normal',
                Area__c = 1000,
                Transactional_Unit__c = 'Unit'
        );
        List<QuoteLineItem> quoteLineItems = new List<QuoteLineItem>{sqftLineItem,unitLineItem};

        Test.startTest();
            insert quoteLineItems;
        Test.stopTest();

        quoteLineItems = [SELECT Total_Offered_Price__c, Total_Best_Rate__c FROM QuoteLineItem WHERE Id IN :quoteLineItems ORDER BY Best_Rate__c ASC];

        // Check sqft total is correct
        System.assertEquals(sqftLineItem.Best_Rate__c * sqftLineItem.Area__c, quoteLineItems.get(0).Total_Best_Rate__c);
        System.assertEquals(sqftLineItem.Offer_Price__c * sqftLineItem.Area__c, quoteLineItems.get(0).Total_Offered_Price__c);

        // Check unit total is correct
        System.assertEquals(unitLineItem.Best_Rate__c, quoteLineItems.get(1).Total_Best_Rate__c);
        System.assertEquals(unitLineItem.Offer_Price__c, quoteLineItems.get(1).Total_Offered_Price__c);
    }

    // Method to test GetTotalRateBetweenDates.
    @IsTest
    static void testGetTotalRateBetweenDates() {
        Decimal annualRate = 100000;

        // Test 1 full year
        Date startDate = Date.newInstance(2019, 1, 1);
        Date endDate = Date.newInstance(2019, 12, 31);
        System.assertEquals(100000, PricingUtils.getTotalRateBetweenDates(startDate, endDate, annualRate));

        // Test years, months and days on a leap year (2020)
        startDate = Date.newInstance(2019, 1, 1);
        endDate = Date.newInstance(2020, 2, 13);
        Decimal expectedRate = annualRate + (annualRate/12) + (annualRate/12/29)*13;
        expectedRate = expectedRate.setScale(2);
        System.assertEquals(expectedRate, PricingUtils.getTotalRateBetweenDates(startDate, endDate, annualRate));
    }

    // Method to test checkDuplicateQLI.
    @IsTest
    static void checkDuplicateQLITestCase() {

        Id standardPricebookId = Test.getStandardPricebookId();
        Test.setMock(HttpCalloutMock.class, new DDAIntegrationMock());

        Business_Park__c businessPark = new Business_Park__c(
                Name = 'D3'
        );
        insert businessPark;

        Account account = new Account(
                Name = 'Test Company'
        );
        insert account;

        Opportunity opp = new Opportunity(
                Pricebook2Id = standardPricebookId,
                Name = 'Test Opp',
                AccountId = account.Id,
                StageName = 'Draft',
                CloseDate = Date.today(),
                Business_Park__c = businessPark.Id
        );
        insert opp;

        Date startDate = Date.newInstance(2019,1,1);
        Date endDate = Date.newInstance(2019, 12, 31);

        Quote quote = new Quote(
                Pricebook2Id = standardPricebookId,
                Name = 'Test Quote',
                Type__c = 'New',
                OpportunityId = opp.Id,
                Proposed_Start_Date__c = startDate,
                Proposed_End_Date__c = endDate
        );
        insert quote;

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
        insert new List<Product2>{unit1, unit2};

        PricebookEntry pbe1 = new PricebookEntry(
                IsActive = true,
                Product2Id = unit1.Id,
                Pricebook2Id = standardPricebookId,
                UnitPrice = 100
        );

        insert new List<PricebookEntry>{pbe1};

        Price_Rule__c ruleObj = new Price_Rule__c(Name = 'Test Rule', Status__c = 'Active');
        insert ruleObj;

        Price_Schedule__c scheduleObj = new Price_Schedule__c(Price_Rule__c = ruleObj.Id,
                                                              Name = 'Test Price Schedule',
                                                              Transaction_Type__c = 'New',
                                                              Start_Date__c = startDate,
                                                             End_Date__c = endDate
                                                              );
        insert scheduleObj;

        QuoteLineItem sqftLineItem = new QuoteLineItem(
                QuoteId = quote.Id,
                Best_Rate__c = 100,
                Offer_Price__c = 80,
                PricebookEntryId = pbe1.Id,
                Quantity = 1,
                UnitPrice = 100,
                Start_Date__c = startDate,
                End_Date__c = endDate,
                Type__c = 'Normal',
                Area__c = 1000,
                Transactional_Unit__c = 'Sqft',
                Price_Schedule__c = scheduleObj.Id
        );

        insert sqftLineItem;


        QuoteLineItem sqftLineItem2 = new QuoteLineItem(
                QuoteId = quote.Id,
                Best_Rate__c = 100,
                Offer_Price__c = 80,
                PricebookEntryId = pbe1.Id,
                Quantity = 1,
                UnitPrice = 100,
                Start_Date__c = startDate,
                End_Date__c = endDate,
                Type__c = 'Normal',
                Area__c = 1000,
                Transactional_Unit__c = 'Sqft',
                Price_Schedule__c = scheduleObj.Id
        );

        String errorMsg;

        Test.startTest();
            try {
                insert sqftLineItem2;
            }
            catch(Exception ex) {
                errorMsg = ex.getMessage();
            }
        Test.stopTest();

        System.assert(errorMsg.containsIgnoreCase('Product has already added with same Price schedule.'));
    }

    // Method to test pricingScheduleRealTimeCalculation method when Rate_Increase_Mechanism__c = 'Fixed Rate' for renewal QLI.
    @IsTest
    static void pricingScheduleRealTimeCalculationTestCase1() {

        Test.setMock(HttpCalloutMock.class, new DDAIntegrationMock());
        
        Quote quote1 =  createData();

        Quote_Revision__c revisionObj = new Quote_Revision__c(Quote__c = quote1.Id,
                                                              Total_Best_Rate__c = 300,
                                                              Total_Offered_Price__c = 500
                                                            );
        insert revisionObj;

        List<PricebookEntry> pbeList = [SELECT Id FROM PricebookEntry];

        QuoteLineItem sqftLineItem1 = new QuoteLineItem(
                QuoteId = quote1.Id,
                Best_Rate__c = 100,
                Offer_Price__c = 80,
                PricebookEntryId = pbeList[0].Id,
                Quantity = 1,
                UnitPrice = 100,
                Start_Date__c = Date.Today() + 120,
                End_Date__c = Date.Today() + 120 + 365,
                Type__c = 'Normal',
                Area__c = 1000,
                Transactional_Unit__c = 'Sqft',
                Quote_Revision__c = revisionObj.Id
        );
        QuoteLineItem unitLineItem2 = new QuoteLineItem(
                QuoteId = quote1.Id,
                Best_Rate__c = 10000,
                Offer_Price__c = 8000,
                PricebookEntryId = pbeList[1].Id,
                Quantity = 1,
                UnitPrice = 10000,
                Start_Date__c = Date.Today() + 120,
                End_Date__c = Date.Today() + 120 + 365,
                Type__c = 'Normal',
                Area__c = 1000,
                Transactional_Unit__c = 'Unit',
                Quote_Revision__c = revisionObj.Id
        );
        List<QuoteLineItem> quoteLineItemsList= new List<QuoteLineItem>{sqftLineItem1,unitLineItem2}; 

        Price_Rule__c priceRule = TestDataFactory.getPriceRuleWithSchedules();

        Test.startTest();
            insert quoteLineItemsList;
        Test.stopTest();


        for(QuoteLineItem quoteObj : [SELECT Id, Best_Rate__c, Offer_Price__c
                                      FROM QuoteLineItem
                                      WHERE Id IN: quoteLineItemsList
                                     ]) {
            System.assertEquals(quoteObj.Best_Rate__c, 100);
            System.assertEquals(quoteObj.Offer_Price__c, 100);
        }

        List<QuoteLineItem> createdChargesQLIList = [SELECT Id, Best_Rate__c, Offer_Price__c
                                                      FROM QuoteLineItem
                                                      WHERE QuoteId =: quote1.Id
                                                      AND Id NOT IN: quoteLineItemsList
                                                    ];

        System.assertEquals(createdChargesQLIList.size(), 6);

    }

     // Method to test pricingScheduleRealTimeCalculation method when Rate_Increase_Mechanism__c = 'Fixed Rate' for renewal QLI.
    @IsTest
    static void pricingScheduleRealTimeCalculationRenewTestCase1() {

        Test.setMock(HttpCalloutMock.class, new DDAIntegrationMock());
        
        Quote quote1 =  createDataRenewal();

        Quote_Revision__c revisionObj = new Quote_Revision__c(Quote__c = quote1.Id,
                                                              Total_Best_Rate__c = 300,
                                                              Total_Offered_Price__c = 500
                                                            );
        insert revisionObj;

        List<PricebookEntry> pbeList = [SELECT Id FROM PricebookEntry];

        QuoteLineItem sqftLineItem1 = new QuoteLineItem(
                QuoteId = quote1.Id,
                Best_Rate__c = 100,
                Offer_Price__c = 80,
                PricebookEntryId = pbeList[0].Id,
                Quantity = 1,
                UnitPrice = 100,
                Start_Date__c = Date.Today() + 120,
                End_Date__c = Date.Today() + 120 + 365,
                Type__c = 'Normal',
                Area__c = 1000,
                Transactional_Unit__c = 'Sqft',
                Quote_Revision__c = revisionObj.Id,
            	Transaction_Type__c = 'Renewal'
        );
        QuoteLineItem unitLineItem2 = new QuoteLineItem(
                QuoteId = quote1.Id,
                Best_Rate__c = 10000,
                Offer_Price__c = 8000,
                PricebookEntryId = pbeList[1].Id,
                Quantity = 1,
                UnitPrice = 10000,
                Start_Date__c = Date.Today() + 120,
                End_Date__c = Date.Today() + 120 + 365,
                Type__c = 'Normal',
                Area__c = 1000,
                Transactional_Unit__c = 'Unit',
                Quote_Revision__c = revisionObj.Id,
            	Transaction_Type__c = 'Renewal'
        );
        List<QuoteLineItem> quoteLineItemsList= new List<QuoteLineItem>{sqftLineItem1,unitLineItem2}; 

        Price_Rule__c priceRule = TestDataFactory.getPriceRuleWithSchedules();

        Test.startTest();
            insert quoteLineItemsList;
        Test.stopTest();


        for(QuoteLineItem quoteObj : [SELECT Id, Best_Rate__c, Offer_Price__c
                                      FROM QuoteLineItem
                                      WHERE Id IN: quoteLineItemsList
                                     ]) { 
            System.assertNotEquals(quoteObj.Best_Rate__c, 10000.00);
            System.assertNotEquals(quoteObj.Offer_Price__c, 10000.00);
        }

        List<QuoteLineItem> createdChargesQLIList = [SELECT Id, Best_Rate__c, Offer_Price__c
                                                      FROM QuoteLineItem
                                                      WHERE QuoteId =: quote1.Id
                                                      AND Id NOT IN: quoteLineItemsList
                                                    ];

        System.assertEquals(createdChargesQLIList.size(), 6);

    }
    
    
     // Method to test pricingScheduleRealTimeCalculation method when Rate_Increase_Mechanism__c = 'Fixed Rate' for renewal QLI.
   /* @IsTest
    static void calculateGraceDiscountsAmountTestCase() {

        Test.setMock(HttpCalloutMock.class, new DDAIntegrationMock());
        
        Quote quote1;

        Test.startTest();
            quote1 =  createDataRenewal();
        Test.stopTest();


        for(QuoteLineItem quoteObj : [SELECT Id, Default_GP_Discount_Amount__c, Additional_GP_Discount_Amount__c
                                      FROM QuoteLineItem
                                      WHERE QuoteId =: quote1.Id
                                     ]) {
            //System.assertEquals(quoteObj.Best_Rate__c, 100);
            //System.assertEquals(quoteObj.Offer_Price__c, 100);
            system.debug('I am here---:'+ quoteObj);
        }

    }*/
    
     /* Method to test pricingScheduleRealTimeCalculation method when Rate_Increase_Mechanism__c = 'Fixed Percentage' 
        and Renewal_Downsize_Rate_To_Use__c = 'Initail Best Rate' for renewal QLI..*/
    @IsTest
    static void pricingScheduleRealTimeCalculationEenewTestCase2() {

        Test.setMock(HttpCalloutMock.class, new DDAIntegrationMock());

        Quote quote1 = createDataRenewal();

        Quote_Revision__c revisionObj = new Quote_Revision__c(Quote__c = quote1.Id,
                                                              Total_Best_Rate__c = 300,
                                                              Total_Offered_Price__c = 500
                                                            );
        insert revisionObj;

        List<PricebookEntry> pbeList = [SELECT Id FROM PricebookEntry];

        QuoteLineItem sqftLineItem1 = new QuoteLineItem(
                QuoteId = quote1.Id,
                Best_Rate__c = 100,
                Offer_Price__c = 80,
                PricebookEntryId = pbeList[0].Id,
                Quantity = 1,
                UnitPrice = 100,
                Start_Date__c = Date.Today() + 120,
                End_Date__c = Date.Today() + 120 + 365,
                Type__c = 'Normal',
                Area__c = 1000,
                Transactional_Unit__c = 'Sqft',
                Quote_Revision__c = revisionObj.Id,
            	Transaction_Type__c = 'Renewal'
        );
        QuoteLineItem unitLineItem2 = new QuoteLineItem(
                QuoteId = quote1.Id,
                Best_Rate__c = 10000,
                Offer_Price__c = 8000,
                PricebookEntryId = pbeList[1].Id,
                Quantity = 1,
                UnitPrice = 10000,
                Start_Date__c = Date.Today() + 120,
                End_Date__c = Date.Today() + 120 + 365,
                Type__c = 'Normal',
                Area__c = 1000,
                Transactional_Unit__c = 'Unit',
                Quote_Revision__c = revisionObj.Id,
            	Transaction_Type__c = 'Renewal'
        );
        
        List<QuoteLineItem> quoteLineItemsList= new List<QuoteLineItem>();
        quoteLineItemsList.add(sqftLineItem1);
        quoteLineItemsList.add(unitLineItem2);
        
        
        Price_Rule__c priceRule = TestDataFactory.getPriceRuleWithSchedules();
        List<Price_Schedule__c> scheduleList = new List<Price_Schedule__c> ();

        for(Price_Schedule__c priceObj : [SELECT Id, 
                                                 Rate_Increase_Mechanism__c, 
                                                 Percent_Increase__c, 
                                                 Renewal_Downsize_Rate_To_Use__c
                                          FROM Price_Schedule__c
                                          WHERE Charge_Type__r.Name = 'Rent'
                                          AND Price_Rule__c =: priceRule.Id]) {
            priceObj.Rate_Increase_Mechanism__c = 'Fixed Percentage';
            priceObj.Renewal_Downsize_Rate_To_Use__c = 'Initial Best Rate';
            priceObj.Percent_Increase__c = 5;
            scheduleList.add(priceObj);
        }
        update scheduleList;

        Test.startTest();
            insert quoteLineItemsList;
        Test.stopTest();


        for(QuoteLineItem quoteObj : [SELECT Id, Best_Rate__c, Offer_Price__c
                                      FROM QuoteLineItem
                                      WHERE Id IN: quoteLineItemsList
                                     ]) {
            if(quoteObj.Id == quoteLineItemsList[0].Id) {
                System.assertEquals(quoteObj.Best_Rate__c, 105.00);
                System.assertEquals(quoteObj.Offer_Price__c, 105.00);
            }
            if(quoteObj.Id == quoteLineItemsList[1].Id) {
                System.assertEquals(quoteObj.Best_Rate__c, 10500.00);
                System.assertEquals(quoteObj.Offer_Price__c, 10500.00);
            }
        }

        List<QuoteLineItem> createdChargesQLIList = [SELECT Id, Best_Rate__c, Offer_Price__c
                                                      FROM QuoteLineItem
                                                      WHERE QuoteId =: quote1.Id
                                                      AND Id NOT IN: quoteLineItemsList
                                                    ];
 system.debug('createdChargesQLIList==='+createdChargesQLIList);
        System.assertEquals(createdChargesQLIList.size(), 6);
    }

    /* Method to test pricingScheduleRealTimeCalculation method when Rate_Increase_Mechanism__c = 'Fixed Percentage' 
        and Renewal_Downsize_Rate_To_Use__c = 'Last Best Rate' for renewal QLI.*/
    @IsTest
    static void pricingScheduleRealTimeCalculationRenewTestCase3() {

        Test.setMock(HttpCalloutMock.class, new DDAIntegrationMock());

        Quote quote1 = createDataRenewal();

        Quote_Revision__c revisionObj = new Quote_Revision__c(Quote__c = quote1.Id,
                                                              Total_Best_Rate__c = 300,
                                                              Total_Offered_Price__c = 500
                                                            );
        insert revisionObj;

        List<PricebookEntry> pbeList = [SELECT Id FROM PricebookEntry];

        QuoteLineItem sqftLineItem1 = new QuoteLineItem(
                QuoteId = quote1.Id,
                Best_Rate__c = 100,
                Offer_Price__c = 80,
                PricebookEntryId = pbeList[0].Id,
                Quantity = 1,
                UnitPrice = 100,
                Start_Date__c = Date.Today() + 120,
                End_Date__c = Date.Today() + 120 + 365,
                Type__c = 'Normal',
                Area__c = 1000,
                Transactional_Unit__c = 'Sqft',
                Quote_Revision__c = revisionObj.Id,
            	Transaction_Type__c = 'Renewal'
        );
        QuoteLineItem unitLineItem2 = new QuoteLineItem(
                QuoteId = quote1.Id,
                Best_Rate__c = 10000,
                Offer_Price__c = 8000,
                PricebookEntryId = pbeList[1].Id,
                Quantity = 1,
                UnitPrice = 10000,
                Start_Date__c = Date.Today() + 120,
                End_Date__c = Date.Today() + 120 + 365,
                Type__c = 'Normal',
                Area__c = 1000,
                Transactional_Unit__c = 'Unit',
                Quote_Revision__c = revisionObj.Id,
            	Transaction_Type__c = 'Renewal'
        );
        
        List<QuoteLineItem> quoteLineItemsList= new List<QuoteLineItem>();
        quoteLineItemsList.add(sqftLineItem1);
        quoteLineItemsList.add(unitLineItem2);
        
        
        Price_Rule__c priceRule = TestDataFactory.getPriceRuleWithSchedules();
        List<Price_Schedule__c> scheduleList = new List<Price_Schedule__c> ();
        
        List<Price_Rule__c> priceRuleList = [SELECT Id, Name FROM Price_Rule__c];
        
        system.debug('priceRule-----:'+priceRuleList);

        for(Price_Schedule__c priceObj : [SELECT Id, 
                                                 Rate_Increase_Mechanism__c, 
                                                 Percent_Increase__c, 
                                                 Renewal_Downsize_Rate_To_Use__c
                                          FROM Price_Schedule__c
                                          WHERE Charge_Type__r.Name = 'Rent'
                                          AND Transaction_Type__c = 'Renewal'
                                          AND Price_Rule__c =: priceRule.Id]) {
            priceObj.Rate_Increase_Mechanism__c = 'Fixed Percentage';
            priceObj.Renewal_Downsize_Rate_To_Use__c = 'Last Best Rate';
            priceObj.Percent_Increase__c = 5;
            scheduleList.add(priceObj);
        }
        update scheduleList;

        Test.startTest();
            insert quoteLineItemsList;
        Test.stopTest();


        for(QuoteLineItem quoteObj : [SELECT Id, Best_Rate__c, Offer_Price__c
                                      FROM QuoteLineItem
                                      WHERE Id IN: quoteLineItemsList
                                     ]) {
            if(quoteObj.Id == quoteLineItemsList[0].Id) {
                System.assertEquals(quoteObj.Best_Rate__c, 105.00);
                System.assertEquals(quoteObj.Offer_Price__c, 105.00);
            }
            if(quoteObj.Id == quoteLineItemsList[1].Id) {
                System.assertEquals(quoteObj.Best_Rate__c, 10500.00);
                System.assertEquals(quoteObj.Offer_Price__c, 10500.00);
            }
        }

        List<QuoteLineItem> createdChargesQLIList = [SELECT Id, Best_Rate__c, Offer_Price__c
                                                      FROM QuoteLineItem
                                                      WHERE QuoteId =: quote1.Id
                                                      AND Id NOT IN: quoteLineItemsList
                                                    ];

        System.assertEquals(createdChargesQLIList.size(), 6);
    }

    /* Method to test pricingScheduleRealTimeCalculation method when Rate_Increase_Mechanism__c = 'Fixed Percentage' 
        and Renewal_Downsize_Rate_To_Use__c = 'Last Passing Rate'. for renewal QLI.*/
    @IsTest
    static void pricingScheduleRealTimeCalculationRenewTestCase4() {

        Test.setMock(HttpCalloutMock.class, new DDAIntegrationMock());

        Quote quote1 = createDataRenewal();

        Quote_Revision__c revisionObj = new Quote_Revision__c(Quote__c = quote1.Id,
                                                              Total_Best_Rate__c = 300,
                                                              Total_Offered_Price__c = 500
                                                            );
        insert revisionObj;

        List<PricebookEntry> pbeList = [SELECT Id FROM PricebookEntry];

        QuoteLineItem sqftLineItem1 = new QuoteLineItem(
                QuoteId = quote1.Id,
                Best_Rate__c = 100,
                Offer_Price__c = 80,
                PricebookEntryId = pbeList[0].Id,
                Quantity = 1,
                UnitPrice = 100,
                Start_Date__c = Date.Today() + 120,
                End_Date__c = Date.Today() + 120 + 365,
                Type__c = 'Normal',
                Area__c = 1000,
                Transactional_Unit__c = 'Sqft',
                Quote_Revision__c = revisionObj.Id,
            	Transaction_Type__c = 'Renewal'
        );
        QuoteLineItem unitLineItem2 = new QuoteLineItem(
                QuoteId = quote1.Id,
                Best_Rate__c = 10000,
                Offer_Price__c = 8000,
                PricebookEntryId = pbeList[1].Id,
                Quantity = 1,
                UnitPrice = 10000,
                Start_Date__c = Date.Today() + 120,
                End_Date__c = Date.Today() + 120 + 365,
                Type__c = 'Normal',
                Area__c = 1000,
                Transactional_Unit__c = 'Unit',
                Quote_Revision__c = revisionObj.Id,
            	Transaction_Type__c = 'Renewal'
        );

        List<QuoteLineItem> quoteLineItemsList= new List<QuoteLineItem>();
        quoteLineItemsList.add(sqftLineItem1);
        quoteLineItemsList.add(unitLineItem2);
        
        Price_Rule__c priceRule = TestDataFactory.getPriceRuleWithSchedules();
        List<Price_Schedule__c> scheduleList = new List<Price_Schedule__c> ();

        for(Price_Schedule__c priceObj : [SELECT Id, 
                                                 Rate_Increase_Mechanism__c, 
                                                 Percent_Increase__c, 
                                                 Renewal_Downsize_Rate_To_Use__c
                                          FROM Price_Schedule__c
                                          WHERE Charge_Type__r.Name = 'Rent'
                                          AND Price_Rule__c =: priceRule.Id]) {
            priceObj.Rate_Increase_Mechanism__c = 'Fixed Percentage';
            priceObj.Renewal_Downsize_Rate_To_Use__c = 'Last Passing Rate';
            priceObj.Percent_Increase__c = 5;
            scheduleList.add(priceObj);
        }
        update scheduleList;

        Test.startTest();
            insert quoteLineItemsList;
        Test.stopTest();


        for(QuoteLineItem quoteObj : [SELECT Id, Best_Rate__c, Offer_Price__c
                                      FROM QuoteLineItem
                                      WHERE Id IN: quoteLineItemsList
                                     ]) {
            if(quoteObj.Id == quoteLineItemsList[0].Id) {
                System.assertEquals(quoteObj.Best_Rate__c, 105.00);
                System.assertEquals(quoteObj.Offer_Price__c, 105.00);
            }
            if(quoteObj.Id == quoteLineItemsList[1].Id) {
                System.assertEquals(quoteObj.Best_Rate__c, 10500.00);
                System.assertEquals(quoteObj.Offer_Price__c, 10500.00);
            }
            
        }

        List<QuoteLineItem> createdChargesQLIList = [SELECT Id, Best_Rate__c, Offer_Price__c
                                                      FROM QuoteLineItem
                                                      WHERE QuoteId =: quote1.Id
                                                      AND Id NOT IN: quoteLineItemsList
                                                    ];

        System.assertEquals(createdChargesQLIList.size(), 6);
    }

    /* Method to test pricingScheduleRealTimeCalculation method when Rate_Increase_Mechanism__c = 'Use RERA Index' 
        and Renewal_Downsize_Rate_To_Use__c = 'Inital Best Rate'. for renewal QLI.*/
    @IsTest
    static void pricingScheduleRealTimeCalculationRenewTestCase5() {

        Test.setMock(HttpCalloutMock.class, new DDAIntegrationMock());

        Quote quote1 = createDataRenewal();

        Quote_Revision__c revisionObj = new Quote_Revision__c(Quote__c = quote1.Id,
                                                              Total_Best_Rate__c = 300,
                                                              Total_Offered_Price__c = 500
                                                            );
        insert revisionObj;

        List<PricebookEntry> pbeList = [SELECT Id FROM PricebookEntry];

        QuoteLineItem sqftLineItem1 = new QuoteLineItem(
                QuoteId = quote1.Id,
                Best_Rate__c = 100,
                Offer_Price__c = 80,
                PricebookEntryId = pbeList[0].Id,
                Quantity = 1,
                UnitPrice = 100,
                Start_Date__c = Date.Today() + 120,
                End_Date__c = Date.Today() + 120 + 365,
                Type__c = 'Normal',
                Area__c = 1000,
                Transactional_Unit__c = 'Sqft',
                Quote_Revision__c = revisionObj.Id,
            	Transaction_Type__c = 'Renewal'
        );
        QuoteLineItem unitLineItem2 = new QuoteLineItem(
                QuoteId = quote1.Id,
                Best_Rate__c = 10000,
                Offer_Price__c = 8000,
                PricebookEntryId = pbeList[1].Id,
                Quantity = 1,
                UnitPrice = 10000,
                Start_Date__c = Date.Today() + 120,
                End_Date__c = Date.Today() + 120 + 365,
                Type__c = 'Normal',
                Area__c = 1000,
                Transactional_Unit__c = 'Unit',
                Quote_Revision__c = revisionObj.Id,
            	Transaction_Type__c = 'Renewal'
        );

        List<QuoteLineItem> quoteLineItemsList= new List<QuoteLineItem>();
        quoteLineItemsList.add(sqftLineItem1);
        quoteLineItemsList.add(unitLineItem2);
        
        Price_Rule__c priceRule = TestDataFactory.getPriceRuleWithSchedules();
        List<Price_Schedule__c> scheduleList = new List<Price_Schedule__c> ();

        for(Price_Schedule__c priceObj : [SELECT Id, 
                                                 Rate_Increase_Mechanism__c, 
                                                 Percent_Increase__c, 
                                                 Renewal_Downsize_Rate_To_Use__c
                                          FROM Price_Schedule__c
                                          WHERE Charge_Type__r.Name = 'Rent'
                                          AND Price_Rule__c =: priceRule.Id]) {
            priceObj.Rate_Increase_Mechanism__c = 'Use RERA Index';
            priceObj.Renewal_Downsize_Rate_To_Use__c = 'Initial Best Rate';
            priceObj.Percent_Increase__c = 5;
            scheduleList.add(priceObj);
        }
        update scheduleList;

        Test.startTest();
            insert quoteLineItemsList;
        Test.stopTest();


        for(QuoteLineItem quoteObj : [SELECT Id, Best_Rate__c, Offer_Price__c
                                      FROM QuoteLineItem
                                      WHERE Id IN: quoteLineItemsList
                                     ]) {
            if(quoteObj.Id == quoteLineItemsList[0].Id) {
                System.assertEquals(quoteObj.Best_Rate__c, 105.00);
                System.assertEquals(quoteObj.Offer_Price__c, 105.00);
            }
            if(quoteObj.Id == quoteLineItemsList[1].Id) {
                System.assertEquals(quoteObj.Best_Rate__c, 10500.00);
                System.assertEquals(quoteObj.Offer_Price__c, 10500.00);
            }
            
        }

        List<QuoteLineItem> createdChargesQLIList = [SELECT Id, Best_Rate__c, Offer_Price__c
                                                      FROM QuoteLineItem
                                                      WHERE QuoteId =: quote1.Id
                                                      AND Id NOT IN: quoteLineItemsList
                                                    ];

        System.assertEquals(createdChargesQLIList.size(),6);
    }

    /* Method to test pricingScheduleRealTimeCalculation method when Rate_Increase_Mechanism__c = 'Use RERA Index' 
        and Renewal_Downsize_Rate_To_Use__c = 'Last Best Rate'. for renewal QLI.*/
    @IsTest
    static void pricingScheduleRealTimeCalculationRenewTestCase6() {

        Test.setMock(HttpCalloutMock.class, new DDAIntegrationMock());

        Quote quote1 = createDataRenewal();

        Quote_Revision__c revisionObj = new Quote_Revision__c(Quote__c = quote1.Id,
                                                              Total_Best_Rate__c = 300,
                                                              Total_Offered_Price__c = 500
                                                            );
        insert revisionObj;

        List<PricebookEntry> pbeList = [SELECT Id FROM PricebookEntry];

        QuoteLineItem sqftLineItem1 = new QuoteLineItem(
                QuoteId = quote1.Id,
                Best_Rate__c = 100,
                Offer_Price__c = 80,
                PricebookEntryId = pbeList[0].Id,
                Quantity = 1,
                UnitPrice = 100,
                Start_Date__c = Date.Today() + 120,
                End_Date__c = Date.Today() + 120 + 365,
                Type__c = 'Normal',
                Area__c = 1000,
                Transactional_Unit__c = 'Sqft',
                Quote_Revision__c = revisionObj.Id,
            	Transaction_Type__c = 'Renewal'
        );
        QuoteLineItem unitLineItem2 = new QuoteLineItem(
                QuoteId = quote1.Id,
                Best_Rate__c = 10000,
                Offer_Price__c = 8000,
                PricebookEntryId = pbeList[1].Id,
                Quantity = 1,
                UnitPrice = 10000,
                Start_Date__c = Date.Today() + 120,
                End_Date__c = Date.Today() + 120 + 365,
                Type__c = 'Normal',
                Area__c = 1000,
                Transactional_Unit__c = 'Unit',
                Quote_Revision__c = revisionObj.Id,
            	Transaction_Type__c = 'Renewal'
        );

        List<QuoteLineItem> quoteLineItemsList= new List<QuoteLineItem>();
        quoteLineItemsList.add(sqftLineItem1);
        quoteLineItemsList.add(unitLineItem2);
        
        Price_Rule__c priceRule = TestDataFactory.getPriceRuleWithSchedules();
        List<Price_Schedule__c> scheduleList = new List<Price_Schedule__c> ();

        for(Price_Schedule__c priceObj : [SELECT Id, 
                                                 Rate_Increase_Mechanism__c, 
                                                 Percent_Increase__c, 
                                                 Renewal_Downsize_Rate_To_Use__c
                                          FROM Price_Schedule__c
                                          WHERE Charge_Type__r.Name = 'Rent'
                                          AND Price_Rule__c =: priceRule.Id]) {
            priceObj.Rate_Increase_Mechanism__c = 'Use RERA Index';
            priceObj.Renewal_Downsize_Rate_To_Use__c = 'Last Best Rate';
            priceObj.Percent_Increase__c = 5;
            scheduleList.add(priceObj);
        }
        update scheduleList;

        Test.startTest();
            insert quoteLineItemsList;
        Test.stopTest();


        for(QuoteLineItem quoteObj : [SELECT Id, Best_Rate__c, Offer_Price__c
                                      FROM QuoteLineItem
                                      WHERE Id IN: quoteLineItemsList
                                     ]) {
            if(quoteObj.Id == quoteLineItemsList[0].Id) {
                System.assertEquals(quoteObj.Best_Rate__c, 105.00);
                System.assertEquals(quoteObj.Offer_Price__c, 105.00);
            }
            if(quoteObj.Id == quoteLineItemsList[1].Id) {
                System.assertEquals(quoteObj.Best_Rate__c, 10500.00);
                System.assertEquals(quoteObj.Offer_Price__c, 10500.00);
            }
            
        }

        List<QuoteLineItem> createdChargesQLIList = [SELECT Id, Best_Rate__c, Offer_Price__c
                                                      FROM QuoteLineItem
                                                      WHERE QuoteId =: quote1.Id
                                                      AND Id NOT IN: quoteLineItemsList
                                                    ];

        System.assertEquals(createdChargesQLIList.size(), 6);
    }

    /* Method to test pricingScheduleRealTimeCalculation method when Rate_Increase_Mechanism__c = 'Use RERA Index' 
        and Renewal_Downsize_Rate_To_Use__c = 'Last Passing Rate' for renewal QLI.*/
    @IsTest
    static void pricingScheduleRealTimeCalculationRenewTestCase7() {

        Test.setMock(HttpCalloutMock.class, new DDAIntegrationMock());

        Quote quote1 = createDataRenewal();

        Quote_Revision__c revisionObj = new Quote_Revision__c(Quote__c = quote1.Id,
                                                              Total_Best_Rate__c = 300,
                                                              Total_Offered_Price__c = 500
                                                            );
        insert revisionObj;

        List<PricebookEntry> pbeList = [SELECT Id FROM PricebookEntry];

        QuoteLineItem sqftLineItem1 = new QuoteLineItem(
                QuoteId = quote1.Id,
                Best_Rate__c = 100,
                Offer_Price__c = 80,
                PricebookEntryId = pbeList[0].Id,
                Quantity = 1,
                UnitPrice = 100,
                Start_Date__c = Date.Today() + 120,
                End_Date__c = Date.Today() + 120 + 365,
                Type__c = 'Normal',
                Area__c = 1000,
                Transactional_Unit__c = 'Sqft',
                Quote_Revision__c = revisionObj.Id,
            	Transaction_Type__c = 'Renewal'
        );
        QuoteLineItem unitLineItem2 = new QuoteLineItem(
                QuoteId = quote1.Id,
                Best_Rate__c = 10000,
                Offer_Price__c = 8000,
                PricebookEntryId = pbeList[1].Id,
                Quantity = 1,
                UnitPrice = 10000,
                Start_Date__c = Date.Today() + 120,
                End_Date__c = Date.Today() + 120 + 365,
                Type__c = 'Normal',
                Area__c = 1000,
                Transactional_Unit__c = 'Unit',
                Quote_Revision__c = revisionObj.Id,
            	Transaction_Type__c = 'Renewal'
        );

        List<QuoteLineItem> quoteLineItemsList= new List<QuoteLineItem>();
        quoteLineItemsList.add(sqftLineItem1);
        quoteLineItemsList.add(unitLineItem2);
        
        Price_Rule__c priceRule = TestDataFactory.getPriceRuleWithSchedules();
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
            insert quoteLineItemsList;
        Test.stopTest();


        for(QuoteLineItem quoteObj : [SELECT Id, Best_Rate__c, Offer_Price__c
                                      FROM QuoteLineItem
                                      WHERE Id IN: quoteLineItemsList
                                     ]) {
            if(quoteObj.Id == quoteLineItemsList[0].Id) {
                System.assertEquals(quoteObj.Best_Rate__c, 105.00);
                System.assertEquals(quoteObj.Offer_Price__c, 105.00);
            }
            if(quoteObj.Id == quoteLineItemsList[1].Id) {
                System.assertEquals(quoteObj.Best_Rate__c, 10500.00);
                System.assertEquals(quoteObj.Offer_Price__c, 10500.00);
            }
             
        }

        List<QuoteLineItem> createdChargesQLIList = [SELECT Id, Best_Rate__c, Offer_Price__c
                                                      FROM QuoteLineItem
                                                      WHERE QuoteId =: quote1.Id
                                                      AND Id NOT IN: quoteLineItemsList
                                                    ];

        System.assertEquals(createdChargesQLIList.size(), 6);
    }
     @IsTest
    static void restrictDeletionRenewalExpansionLineItemsTestCase1() {
         Test.setMock(HttpCalloutMock.class, new DDAIntegrationMock());

        Quote quote1 = createDataRenewal();

        Quote_Revision__c revisionObj = new Quote_Revision__c(Quote__c = quote1.Id,
                                                              Total_Best_Rate__c = 300,
                                                              Total_Offered_Price__c = 500
                                                            );
        insert revisionObj;

        List<PricebookEntry> pbeList = [SELECT Id FROM PricebookEntry];

        QuoteLineItem sqftLineItem1 = new QuoteLineItem(
                QuoteId = quote1.Id,
                Best_Rate__c = 100,
                Offer_Price__c = 80,
                PricebookEntryId = pbeList[0].Id,
                Quantity = 1,
                UnitPrice = 100,
                Start_Date__c = Date.Today() + 120,
                End_Date__c = Date.Today() + 120 + 365,
                Type__c = 'Normal',
                Area__c = 1000,
                Transactional_Unit__c = 'Sqft',
                Quote_Revision__c = revisionObj.Id,
            	Transaction_Type__c = 'Renewal'
        );
        QuoteLineItem unitLineItem2 = new QuoteLineItem(
                QuoteId = quote1.Id,
                Best_Rate__c = 10000,
                Offer_Price__c = 8000,
                PricebookEntryId = pbeList[1].Id,
                Quantity = 1,
                UnitPrice = 10000,
                Start_Date__c = Date.Today() + 120,
                End_Date__c = Date.Today() + 120 + 365,
                Type__c = 'Normal',
                Area__c = 1000,
                Transactional_Unit__c = 'Unit',
                Quote_Revision__c = revisionObj.Id,
            	Transaction_Type__c = 'Renewal'
        );

        List<QuoteLineItem> quoteLineItemsList= new List<QuoteLineItem>();
        quoteLineItemsList.add(sqftLineItem1);
        quoteLineItemsList.add(unitLineItem2);
        
        Price_Rule__c priceRule = TestDataFactory.getPriceRuleWithSchedules();
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
            insert quoteLineItemsList;
        Test.stopTest();
        PricingUtils.restrictDeletionRenewalExpansionLineItems(quoteLineItemsList);
    }
    
  /*  @IsTest
    static void pricingScheduleRealTimeCalculationRenewTestCase10() {

        Test.setMock(HttpCalloutMock.class, new DDAIntegrationMock());

        Quote quote1 = setUp();

        Quote_Revision__c revisionObj = new Quote_Revision__c(Quote__c = quote1.Id,
                                                              Total_Best_Rate__c = 300,
                                                              Total_Offered_Price__c = 500
                                                            );
        insert revisionObj;

        List<PricebookEntry> pbeList = [SELECT Id FROM PricebookEntry];

        QuoteLineItem sqftLineItem1 = new QuoteLineItem(
                QuoteId = quote1.Id,
                Best_Rate__c = 100,
                Offer_Price__c = 80,
                PricebookEntryId = pbeList[0].Id,
                Quantity = 1,
                UnitPrice = 100,
                Start_Date__c = Date.Today() + 120,
                End_Date__c = Date.Today() + 120 + 365,
                Type__c = 'Normal',
                Area__c = 1000,
                Transactional_Unit__c = 'Sqft',
                Quote_Revision__c = revisionObj.Id,
            	Transaction_Type__c = 'Renewal'
        );
        QuoteLineItem unitLineItem2 = new QuoteLineItem(
                QuoteId = quote1.Id,
                Best_Rate__c = 10000,
                Offer_Price__c = 8000,
                PricebookEntryId = pbeList[1].Id,
                Quantity = 1,
                UnitPrice = 10000,
                Start_Date__c = Date.Today() + 120,
                End_Date__c = Date.Today() + 120 + 365,
                Type__c = 'Normal',
                Area__c = 1000,
                Transactional_Unit__c = 'Unit',
                Quote_Revision__c = revisionObj.Id,
            	Transaction_Type__c = 'Renewal'
        );

        List<QuoteLineItem> quoteLineItemsList= new List<QuoteLineItem>();
        quoteLineItemsList.add(sqftLineItem1);
        quoteLineItemsList.add(unitLineItem2);
        
        //Price_Rule__c priceRule = TestDataFactory.getPriceRuleWithSchedules();
        Price_Rule__c priceRuleObject = [SELECT Id FROM Price_Rule__c WHERE Status__c = 'Active'];
        List<Price_Schedule__c> scheduleList = new List<Price_Schedule__c> ();

        for(Price_Schedule__c priceObj : [SELECT Id, 
                                                 Rate_Increase_Mechanism__c, 
                                                 Percent_Increase__c, 
                                                 Renewal_Downsize_Rate_To_Use__c
                                          FROM Price_Schedule__c
                                          WHERE Charge_Type__r.Name = 'Rent'
                                          AND Price_Rule__c =: priceRuleObject.Id
                                         AND Rate_Increase_Mechanism__c = 'Use RERA Index'
                                         AND Renewal_Downsize_Rate_To_Use__c = 'Last Passing Rate']) {
            
            scheduleList.add(priceObj);
        }
        update scheduleList;

        Test.startTest();
            insert quoteLineItemsList;
        Test.stopTest();


        for(QuoteLineItem quoteObj : [SELECT Id, Best_Rate__c, Offer_Price__c
                                      FROM QuoteLineItem
                                      WHERE Id IN: quoteLineItemsList
                                     ]) {
            if(quoteObj.Id == quoteLineItemsList[0].Id) {
                System.assertEquals(quoteObj.Best_Rate__c, 105.00);
                System.assertEquals(quoteObj.Offer_Price__c, 105.00);
            }
            if(quoteObj.Id == quoteLineItemsList[1].Id) {
                System.assertEquals(quoteObj.Best_Rate__c, 10500.00);
                System.assertEquals(quoteObj.Offer_Price__c, 10500.00);
            }
             
        }

        List<QuoteLineItem> createdChargesQLIList = [SELECT Id, Best_Rate__c, Offer_Price__c
                                                      FROM QuoteLineItem
                                                      WHERE QuoteId =: quote1.Id
                                                      AND Id NOT IN: quoteLineItemsList
                                                    ];

        System.assertEquals(createdChargesQLIList.size(), 6);
    }*/
}