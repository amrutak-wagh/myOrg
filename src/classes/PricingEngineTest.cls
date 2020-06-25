/**
 *  @description Test class for PricingEngine
 *
 *  2019-07-12  Samuel Arroyo    Start writing test class
 */
@IsTest
private class PricingEngineTest {

    @TestSetup
    static void testSetup() {
        Account account = TestDataFactory.getAccountWithContact();
        Business_Park__c businessPark = TestDataFactory.getBusinessParkWithUnits();
        Opportunity opportunity = TestDataFactory.getOpportunityWithQuote(account.Id, businessPark.Id, Date.today().addMonths(-3), Date.today().addYears(2).addDays(-1));
        Price_Rule__c priceRule = TestDataFactory.getPriceRuleWithSchedules();
    }

    @IsTest
    static void testGetPricingPackagesForNewLease() {

        Quote quote = [SELECT Proposed_Start_Date__c, Proposed_End_Date__c, Type__c FROM Quote];

        List<PricingEngine.Input> inputs = new List<PricingEngine.Input>();
        for (Integer i = 0; i < 500; i++) {
            PricingEngine.Input input = new PricingEngine.Input();
            input.businessPark = 'D3';
            input.building = 'B-P1-1';
            input.floorNumber = '05';
            input.utility = true;
            input.cooling = true;
            input.assetClass = 'Commercial';
            input.productCategory = 'Office';
            input.productSubcategory = 'Standard Office';
            input.ownershipStatus = 'TECOM Owned';
            input.reraIndex = '10';
            input.rentCap = '10';
            input.transactionType = quote.Type__c;
            input.transactionDate = quote.Proposed_Start_Date__c;
            input.initialBestRate = '100';
            input.lastBestRate = '105';
            input.lastPassingRate = '95';
            input.leaseTerm = String.valueOf(quote.Proposed_Start_Date__c.daysBetween(quote.Proposed_End_Date__c));
            input.totalLeasedArea = '10000';
            inputs.add(input);
        }

        List<PricingEngine.PricingPackage> packages = PricingEngine.getPricingPackages(inputs);
        for (PricingEngine.PricingPackage packageItem : packages) {
            System.assert(packageItem.priceRule != null);
        }
    }

    @IsTest
    static void testGetPricingPackagesForRenewalLease() {

        Quote quote = [SELECT Proposed_Start_Date__c, Proposed_End_Date__c, Type__c FROM Quote];

        List<PricingEngine.Input> inputs = new List<PricingEngine.Input>();
        for (Integer i = 0; i < 500; i++) {
            PricingEngine.Input input = new PricingEngine.Input();
            input.businessPark = 'D3';
            input.building = 'B-P1-1';
            input.floorNumber = '05';
            input.utility = true;
            input.cooling = true;
            input.assetClass = 'Commercial';
            input.productCategory = 'Office';
            input.productSubcategory = 'Standard Office';
            input.ownershipStatus = 'TECOM Owned';
            input.reraIndex = '10';
            input.rentCap = '10';
            input.transactionType = 'Renewal';
            input.transactionDate = quote.Proposed_Start_Date__c;
            input.initialBestRate = '100';
            input.lastBestRate = '105';
            input.lastPassingRate = '95';
            input.leaseTerm = String.valueOf(quote.Proposed_Start_Date__c.daysBetween(quote.Proposed_End_Date__c));
            input.totalLeasedArea = '10000';
            inputs.add(input);
        }

        List<PricingEngine.PricingPackage> packages = PricingEngine.getPricingPackages(inputs);
        for (PricingEngine.PricingPackage packageItem : packages) {
            System.assert(packageItem.priceRule != null);
        }
    }
}