/**
 *  @description Auxiliary class that generates test data
 *
 *  2019-07-12  Samuel Arroyo    Start writing factory
 */
public with sharing class TestDataFactory {

    public static Id standardPricebookId {
        get {
            if (standardPricebookId == null) {
                standardPricebookId = Test.getStandardPricebookId();
            }
            return standardPricebookId;
        }
        set;
    }

    public static Account getAccountWithContact() {
        Decimal randomNumber = Math.random();
        Account account = new Account(
                Name = 'Test Account ' + String.valueOf(randomNumber)
        );
        insert account;

        Contact contact = new Contact(
                AccountId = account.Id,
                FirstName = 'John',
                LastName = 'Smith',
                Email = 'john.smith' + String.valueOf(randomNumber) + '@gmail.com'
        );
        insert contact;

        return account;
    }

    public static Business_Park__c getBusinessParkWithUnits() {
        Asset_Class__c assetClassCommercial = new Asset_Class__c(
                Name = 'Commercial'
        );
        insert assetClassCommercial;

        Unit_Category__c unitCategoryOffice = new Unit_Category__c(
                Name = 'Office',
                Asset_Class__c = assetClassCommercial.Id
        );
        insert unitCategoryOffice;

        Unit_Sub_Category__c standardOffice = new Unit_Sub_Category__c(
                Name = 'Standard Office',
                Unit_Category__c = unitCategoryOffice.Id
        );
        insert standardOffice;

        Business_Park__c businessPark = new Business_Park__c(
                Business_Park_Code__c = 'D3',
                Name = 'D3'
        );
        insert businessPark;

        List<Plot__c> plots = new List<Plot__c>();
        for (Integer i = 0; i < 10; i++) {
            plots.add(new Plot__c(
                    Name = 'P' + i,
                    Business_Park__c = businessPark.Id,
                    Area_sqft__c = 100000,
                    Plot_Name_YARDI__c = 'YARDI_NAME_'+i,
                    Plot_Code_YARDI__c = 'YARDI_CODE_'+i,
                    Type__c = 'Commercial',
                    Status__c = 'Available - Sale',
                    Sector_Name__c = 'Sector 1'
            ));
        }
        insert plots;

        List<Building__c> buildings = new List<Building__c>();
        for (Integer i = 0; i < plots.size(); i++) {
            for (Integer j = 0; j < 10; j++) {
                buildings.add(new Building__c(
                        Name = 'Building ' + plots[i].Name + ' ' + String.valueOf(j),
                        Building_Code__c = 'B-' + plots[i].Name + '-' + String.valueOf(j),
                        Ownership_Type__c = 'TECOM Owned',
                        Plot__c = plots[i].Id,
                        Business_Park__c = businessPark.Id,
                        Development_Status__c='Developed',
                        Property_Code_YARDI__c = 'YARDI_CODE_'+i+'_'+j,
                        Property__c='Office'
                ));
            }
        }
        insert buildings;

        List<Unit__c> units = new List<Unit__c>();
        for (Integer i = 0; i < buildings.size(); i++) {
            for (Integer j = 0; j < 10; j++) {
                units.add(new Unit__c(
                        Name = 'Unit ' + buildings[i].Building_Code__c + '-' + String.valueOf(j),
                        Building__c = buildings[i].Id,
                        Area_ft__c = Math.random() * 1000,
                        Floor_Number__c = 'Fifth Floor',
                        Floor_Name__c = '5',
                        Floor_Type__c = '05',
                        Transactional_Unit__c = 'Sqft',
                        Unit_Sub_Category__c = standardOffice.Id,
                        Unit_Code_YARDI__c = 'YARDI_CODE_'+i+'_'+j
                ));
            }
        }
        insert units;

        return businessPark;
    }

    public static Opportunity getOpportunityWithQuote(Id accountId, Id businessParkId, Date startDate, Date endDate) {
        Opportunity opportunity = new Opportunity(
                Pricebook2Id = standardPricebookId,
                AccountId = accountId,
                Name = 'Test Opportunity ' + String.valueOf(Math.random()),
                StageName = 'Draft',
                CloseDate = Date.today(),
                Business_Park__c = businessParkId,
                Type = 'New',
                Lease_Type__c = 'land'
        );
        insert opportunity;

        Quote quote = new Quote(
                Pricebook2Id = standardPricebookId,
                Name = 'Test Quote ' + String.valueOf(Math.random()),
                OpportunityId = opportunity.Id,
                Proposed_Start_Date__c = startDate,
                Proposed_End_Date__c = endDate,
                Type__c = 'New'
        );
        insert quote;

        return opportunity;
    }

    public static List<Product2> getProducts() {
        List<Unit__c> units = [SELECT Name, Building__c, Unit_Sub_Category__c, Transactional_Unit__c FROM Unit__c];
        List<Product2> products = new List<Product2>();
        for (Unit__c unit : units) {
            products.add(new Product2(
                    Name = unit.Name,
                    ProductCode = unit.Name,
                    Unit__c = unit.Id,
                    Building__c = unit.Building__c,
                    Unit_Sub_Category__c = unit.Unit_Sub_Category__c,
                    Transaction_Unit__c = unit.Transactional_Unit__c,
                    IsActive = true
            ));
        }
        insert products;

        List<PricebookEntry> pricebookEntries = new List<PricebookEntry>();
        for (Product2 product : products) {
            pricebookEntries.add(new PricebookEntry(
                    Pricebook2Id = standardPricebookId,
                    Product2Id = product.Id,
                    IsActive = true,
                    UnitPrice = 100
            ));
        }
        insert pricebookEntries;
        return products;
    }

    public static Price_Rule__c getPriceRuleWithSchedules() {
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
                    Name = 'Service Charge (new)',
                    Transaction_Type__c = 'New',
                    Charge_Type__c = chargeTypeServiceCharge.Id,
                    Start_Date__c = startDate,
                    End_Date__c = endDate,
                    Rate__c = 10,
                    Rate_Cap__c = 14,
                    Transactional_Unit__c = 'Sq ft',
                    Total_Leased_Area_Operator__c = 'less than',
                    Total_Leased_Area_Value__c = '9999999'
            ));
            priceSchedules.add(new Price_Schedule__c(
                    Price_Rule__c = priceRule.Id,
                    Name = 'Service Charge (renewal)',
                    Transaction_Type__c = 'Renewal',
                    Charge_Type__c = chargeTypeServiceCharge.Id,
                    Start_Date__c = startDate,
                    End_Date__c = endDate,
                    Rate__c = 10,
                    Rate_Cap__c = 14,
                    Transactional_Unit__c = 'Sq ft',
                    Rate_Increase_Mechanism__c = 'Fixed Rate',
                    Total_Leased_Area_Operator__c = 'less than',
                    Total_Leased_Area_Value__c = '9999999'
            ));
        }
        insert priceSchedules;

        return priceRule;
    }


}