/**
 *  @description Implementation of the Pricing Engine
 *  
 *  2019-04-16  Jack Tolladay    Initial PoC
 *  2019-05-08  Samuel Arroyo    Extend PoC with support for 4 fields
 *  2019-05-30  Alasdair Leggat  Add support for more fields, overwrite price rule 
 */
public with sharing class PricingEngine {

    /**
     *  @description Algorithm that returns a matching price rule for a given input criteria
     *  @param  inputs              List of input parameters that will be matched against active price rules
     *  @return List of pricing packages, which are a wrapper of input + matching pricing rule + related pricing schedules
     */
    public static List<PricingPackage> getPricingPackages(List<Input> inputs){

        // Build pricing packages
        List<Price_Rule__c> priceRules = retrievePriceRules(inputs);
        system.debug('priceRules----:'+priceRules);
        List<PricingPackage> pricingPackages = new List<PricingPackage>();
        for (Input input : inputs) {
            pricingPackages.add(generatePricingPackage(input, priceRules));
        }
        // Add price schedules to pricing packages
        Set<Id> foundPriceRuleIds = new Set<Id>();
        Set<String> transactionTypes = new Set<String>();
        Date startTransactionDate, endTransactionDate;
        for (PricingPackage pricingPackage : pricingPackages) {
            if (pricingPackage.priceRule != null) {
                foundPriceRuleIds.add(pricingPackage.priceRule.Id);
                system.debug('foundPriceRuleIds-----:'+foundPriceRuleIds);
                transactionTypes.add(pricingPackage.input.transactionType);

                if (startTransactionDate == null || pricingPackage.input.transactionDate < startTransactionDate) {
                    startTransactionDate = pricingPackage.input.transactionDate;
                }
                if (endTransactionDate == null || pricingPackage.input.transactionDate > endTransactionDate) {
                    endTransactionDate = pricingPackage.input.transactionDate;
                }
            }
        }
        if (!foundPriceRuleIds.isEmpty()) {
            Map<Id, List<Price_Schedule__c>> priceRuleToSchedules = retrievePriceSchedulesByPriceRule(foundPriceRuleIds, startTransactionDate, endTransactionDate, transactionTypes);
            system.debug('priceRuleToSchedules----:'+priceRuleToSchedules);
            for (PricingPackage pricingPackage : pricingPackages) {
                if (pricingPackage.priceRule != null && priceRuleToSchedules.containsKey(pricingPackage.priceRule.Id)) {
                    pricingPackage.setRates(priceRuleToSchedules.get(pricingPackage.priceRule.Id));
                }
            }
        }

        return pricingPackages;
    }

    /**
     *  @description Retrieve list of price rules that match input conditions
     *  @param  inputs              List of input parameters that will be matched against active price rules
     *  @return List<Price_Rule__c>
     */
    private static List<Price_Rule__c> retrievePriceRules(List<Input> inputs) {
        // Group input criteria
        Set<String> businessParks = new Set<String>();
        Set<String> buildings = new Set<String>();
        Set<String> assetClasses = new Set<String>();
        Set<String> productCategories = new Set<String>();
        Set<String> productSubcategories = new Set<String>();
        Set<String> floorNumbers = new Set<String>();
        Set<String> ownershipStatuses = new Set<String>();
        for (Input input : inputs) {
            if (String.isNotBlank(input.businessPark)) {
                businessParks.add('');
                businessParks.add('%'+input.businessPark+'%');
            }
            if (String.isNotBlank(input.building)) {
                buildings.add('');
                buildings.add('%'+input.building+'%');
            }
            if (String.isNotBlank(input.assetClass)) {
                assetClasses.add('');
                assetClasses.add('%'+input.assetClass+'%');
            }
            if (String.isNotBlank(input.productCategory)) {
                productCategories.add('');
                productCategories.add('%'+input.productCategory+'%');
            }
            if (String.isNotBlank(input.productSubcategory)) {
                productSubcategories.add('');
                productSubcategories.add('%'+input.productSubcategory+'%');
            }
            if (String.isNotBlank(input.floorNumber)) {
                floorNumbers.add('');
                floorNumbers.add('%'+input.floorNumber+'%');
            }
            if (String.isNotBlank(input.ownershipStatus)) {
                ownershipStatuses.add('');
                ownershipStatuses.add('%'+input.ownershipStatus+'%');
            }
        }
        System.debug('##### businessParks: ' + businessParks);
        System.debug('##### buildings: ' + buildings);
        System.debug('##### assetClasses: ' + assetClasses);
        System.debug('##### productCategories: ' + productCategories);
        System.debug('##### floorNumbers: ' + floorNumbers);
        System.debug('##### ownershipStatuses: ' + ownershipStatuses);

        // Create query filters
        List<String> queryFilters = new List<String>{'Status__c = \'Active\''};
        if (!businessParks.isEmpty()) queryFilters.add('Business_Park_Value__c LIKE :businessParks');
        if (!buildings.isEmpty()) queryFilters.add('Building_Value__c LIKE :buildings');
        if (!assetClasses.isEmpty()) queryFilters.add('Asset_Class_Value__c LIKE :assetClasses');
        if (!productCategories.isEmpty()) queryFilters.add('Product_Category_Value__c LIKE :productCategories');
        if (!productSubcategories.isEmpty()) queryFilters.add('Product_Sub_Category_Value__c LIKE :productSubcategories');
        if (!floorNumbers.isEmpty()) queryFilters.add('Floor_Value__c LIKE :floorNumbers');
        if (!ownershipStatuses.isEmpty()) queryFilters.add('Ownership_Status_Value__c LIKE :ownershipStatuses');

        // Query price rules
        List<String> fieldsToQuery = new List<String>{
            'Business_Park_Operator__c',
            'Business_Park_Value__c',
            'Building_Operator__c',
            'Building_Value__c',
            'Lease_Term_Operator__c',
            'Lease_Term_Value__c',
            'Product_Category_Operator__c',
            'Product_Category_Value__c',
            'Product_Sub_Category_Operator__c',
            'Product_Sub_Category_Value__c',
            'Asset_Class_Operator__c',
            'Asset_Class_Value__c',
            'Floor_Operator__c',
            'Floor_Value__c',
            'Utility_Submeter_Operator__c',
            'Utility_Submeter_Value__c',
            'Cooling_Submeter_Operator__c',
            'Cooling_Submeter_Value__c',
            //'Pricing_Group_Operator__c',
            //'Pricing_Group_Operator__c',
            'Ownership_Status_Operator__c',
            'Ownership_Status_Value__c',
            'Current_RERA_Index_Operator__c',
            'Current_RERA_Index_Value__c',
            'Rent_Cap_Operator__c',
            'Rent_Cap_Value__c'
        };

        return Database.query('SELECT ' + String.join(fieldsToQuery, ', ') + ' FROM Price_Rule__c WHERE ' + String.join(queryFilters, ' AND '));
    }

    /**
     *  @description Build a pricing package with matching price rules
     *  @param  input               Input parameters that will be matched against active price rules
     *          priceRules          List of previously filtered price rules
     *  @return Pricing package, which is a wrapper of input + matching pricing rule
     */
    private static PricingPackage generatePricingPackage(Input input, List<Price_Rule__c> priceRules) {
        PricingPackage pricingPackage = new PricingPackage(input);

        // Keep track of number of populated fields
        Integer previousPopulatedFieldCount = 0;
        Integer populatedFieldCount;
        
        // Find price rules for each input
        if (priceRules != null) {
            for(Price_Rule__c pr : priceRules){
                
                populatedFieldCount = 0;

                // Prioritised fields
                if(pr.Business_Park_Operator__c != null){
                    populatedFieldCount++;
                    if (!evaluateCondition(pr.Business_Park_Operator__c, pr.Business_Park_Value__c, input.businessPark)) continue;
                }
                if(pr.Building_Operator__c != null){
                    populatedFieldCount++;
                    if (!evaluateCondition(pr.Building_Operator__c, pr.Building_Value__c, input.building)) continue;
                }
                if(pr.Asset_Class_Operator__c != null){
                    populatedFieldCount++;
                    if (!evaluateCondition(pr.Asset_Class_Operator__c, pr.Asset_Class_Value__c, input.assetClass)) continue;
                }
                if(pr.Product_Category_Operator__c != null){
                    populatedFieldCount++;
                    if (!evaluateCondition(pr.Product_Category_Operator__c, pr.Product_Category_Value__c, input.productCategory)) continue;
                }
                if(pr.Product_Sub_Category_Operator__c != null){
                    populatedFieldCount++;
                    if (!evaluateCondition(pr.Product_Sub_Category_Operator__c, pr.Product_Sub_Category_Value__c, input.productSubcategory)) continue;
                }
                
                // Physical attribute fields
                if(pr.Floor_Operator__c != null){
                    populatedFieldCount++;
                    if (!evaluateCondition(pr.Floor_Operator__c, pr.Floor_Value__c, input.floorNumber)) continue;
                }
                if(pr.Utility_Submeter_Operator__c != null){
                    populatedFieldCount++;
                    if (!evaluateCondition(pr.Utility_Submeter_Operator__c, pr.Utility_Submeter_Value__c, input.utility?'1':'0')) continue;
                }
                if(pr.Cooling_Submeter_Operator__c != null){
                    populatedFieldCount++;
                    if (!evaluateCondition(pr.Cooling_Submeter_Operator__c, pr.Cooling_Submeter_Value__c, input.cooling?'1':'0')) continue;
                }
                
                // Commercial attributes
                /*if(pr.Pricing_Group_Operator__c != null){
                    populatedFieldCount++;
                    if (!evaluateCondition(pr.Pricing_Group_Operator__c, pr.Pricing_Group_Value__c, input.pricingGroup)) continue;
                }*/
                if(pr.Ownership_Status_Operator__c != null){
                    populatedFieldCount++;
                    if (!evaluateCondition(pr.Ownership_Status_Operator__c, pr.Ownership_Status_Value__c, input.ownershipStatus)) continue;
                }
                if(pr.Current_RERA_Index_Operator__c != null){
                    populatedFieldCount++;
                    if (!evaluateCondition(pr.Current_RERA_Index_Operator__c, pr.Current_RERA_Index_Value__c, input.reraIndex)) continue;
                }
                if(pr.Rent_Cap_Operator__c != null){
                    populatedFieldCount++;
                    if (!evaluateCondition(pr.Rent_Cap_Operator__c, pr.Rent_Cap_Value__c, input.rentCap)) continue;
                }
                
                // Transactional attribute fields
                if(pr.Lease_Term_Operator__c != null){
                    populatedFieldCount++;
                    if (!evaluateCondition(pr.Lease_Term_Operator__c, pr.Lease_Term_Value__c, input.leaseTerm)) continue;
                }

                // Set found pricing rule
                if(populatedFieldCount > previousPopulatedFieldCount){
                    pricingPackage.priceRule = pr;
                    
                    // Update previous price rule populated field count
                    previousPopulatedFieldCount = populatedFieldCount;
                }
            }
        }

        return pricingPackage;
    }

    /**
     *  @description Retrieve price schedules grouped by price rule
     *  @param  foundPriceRuleIds       Set of previously matched price rules
     *          startTransactionDate    Earliest transaction date
     *          endTransactionDate      Latest transaction date
     *          transactionType         Type of transaction (e.g. New, Renewal, etc.)
     *  @return Map of Price Rule Id to List of price schedules
     */
    private static Map<Id, List<Price_Schedule__c>> retrievePriceSchedulesByPriceRule(Set<Id> foundPriceRuleIds, Date startTransactionDate, Date endTransactionDate, Set<String> transactionTypes) {
        Map<Id, List<Price_Schedule__c>> priceRuleToSchedules = new Map<Id, List<Price_Schedule__c>>();
        List<Price_Schedule__c> schedules = [
            SELECT  Price_Rule__c, Charge_Type__r.Name, Start_Date__c, End_Date__c,
                    Grace_Period__c, Grace_Period_Format__c, Grace_Period_Mechanism__c, Service_Charge_Mechanism__c,
                    Transaction_Type__c, Rate__c, Rate_Cap__c, Transactional_Unit__c,
                    Initial_Best_Rate_Operator__c, Initial_Best_Rate_Value__c,
                    Last_Best_Rate_Operator__c, Last_Best_Rate_Value__c,
                    Last_Passing_Rate_Operator__c, Last_Passing_Rate_Value__c,
                    Rate_Increase_Mechanism__c, Renewal_Downsize_Rate_To_Use__c, Percent_Increase__c,
                    Total_Leased_Area_Operator__c, Total_Leased_Area_Value__c
            FROM    Price_Schedule__c
            WHERE   Price_Rule__c IN :foundPriceRuleIds AND
                    Start_Date__c <= :endTransactionDate AND
                    End_Date__c > :startTransactionDate AND
                    Transaction_Type__c IN :transactionTypes
        ];
        for (Price_Schedule__c schedule : schedules) {
            if (!priceRuleToSchedules.containsKey(schedule.Price_Rule__c)) {
                priceRuleToSchedules.put(schedule.Price_Rule__c, new List<Price_Schedule__c>{schedule});
            } else {
                priceRuleToSchedules.get(schedule.Price_Rule__c).add(schedule);
            }
        }
        return priceRuleToSchedules;
    }

    /**
     *  @description Auxiliary function that evaluates values against a given condition
     *  @param  operator            Defines type of comparison
     *          priceRuleValue      Particular price rule configuration
     *          inputValue          Value to match against price rule
     *  @return True if it matches, false otherwise
     */
    private static Boolean evaluateCondition(String operator, String priceRuleValue, String inputValue){
        if (String.isBlank(operator) || String.isBlank(priceRuleValue) || String.isBlank(inputValue)) {
            return true;
        } else {
            operator = operator.toLowerCase();
            switch on operator {
                when 'equal' { return priceRuleValue == inputValue; }
                when 'include' {
                    Set<String> priceRuleValues = new Set<String>(priceRuleValue.split(';'));
                    return priceRuleValues.contains(inputValue);
                }
                when 'less than' { 
                    Decimal inputValueDecimal = Decimal.valueOf(inputValue);
                    Decimal priceRuleValueDecimal = Decimal.valueOf(priceRuleValue);
                    return inputValueDecimal < priceRuleValueDecimal; 
                }
                when 'more than' { 
                    Decimal inputValueDecimal = Decimal.valueOf(inputValue);
                    Decimal priceRuleValueDecimal = Decimal.valueOf(priceRuleValue);
                    return inputValueDecimal > priceRuleValueDecimal; 
                }
                when 'between' {
                    try{
                        List<String> priceRuleValues = priceRuleValue.split('-');
                        if (priceRuleValues.size() == 2) {
                            Decimal lowerTerm = Decimal.valueOf(priceRuleValues[0]);
                            Decimal higherTerm = Decimal.valueOf(priceRuleValues[1]);
                            Decimal inputDecimal = Decimal.valueOf(inputValue);
                            return (lowerTerm <= inputDecimal && inputDecimal <= higherTerm) ;
                        }
                    } catch (Exception e) {
                        System.debug('Exception: ' + e);
                    }
                }
            }
        }
        return false;
    }

    public class PricingPackage {
        @AuraEnabled public Input input;
        @AuraEnabled public Price_Rule__c priceRule;
        @AuraEnabled public List<Price_Schedule__c> rates;
        public PricingPackage(){}
        public PricingPackage(Input input){
            this.input = input;
        }
        public void setRates(List<Price_Schedule__c> rates) {
            // Filter out rates that don't match input
            this.rates = new List<Price_Schedule__c>();
            for (Price_Schedule__c rate : rates) {
                // Check it's correct transaction type
                if (rate.Transaction_Type__c != input.transactionType) {
                    continue;
                }

                // Check it's within transaction date
                if (rate.Start_Date__c > input.transactionDate || rate.End_Date__c <= input.transactionDate) {
                    continue;
                }

                // Volume based discount
                if(rate.Total_Leased_Area_Operator__c != null) {
                    if (!evaluateCondition(rate.Total_Leased_Area_Operator__c, rate.Total_Leased_Area_Value__c, input.totalLeasedArea)) continue;
                }

                // Check other conditions
                if(rate.Initial_Best_Rate_Operator__c != null) {
                    if (!evaluateCondition(rate.Initial_Best_Rate_Operator__c, rate.Initial_Best_Rate_Value__c, input.initialBestRate)) continue;
                }
                if (rate.Last_Best_Rate_Operator__c != null) {
                    if (!evaluateCondition(rate.Last_Best_Rate_Operator__c, rate.Last_Best_Rate_Value__c, input.lastBestRate)) continue;
                }
                if (rate.Last_Passing_Rate_Operator__c != null) {
                    if (!evaluateCondition(rate.Last_Passing_Rate_Operator__c, rate.Last_Passing_Rate_Value__c, input.lastPassingRate)) continue;
                }

                this.rates.add(rate);
            }
        }
    }

    public class Input {
        @AuraEnabled public String businessPark;
        @AuraEnabled public String building;
        @AuraEnabled public String floorNumber;
        @AuraEnabled public Boolean utility;
        @AuraEnabled public Boolean cooling;
        @AuraEnabled public String assetClass;
        @AuraEnabled public String productCategory;
        @AuraEnabled public String productSubcategory;
        //@AuraEnabled public String pricingGroup;
        @AuraEnabled public String ownershipStatus;
        @AuraEnabled public String reraIndex;
        @AuraEnabled public String rentCap;
        @AuraEnabled public String transactionType;
        @AuraEnabled public Date transactionDate;
        @AuraEnabled public String initialBestRate;
        @AuraEnabled public String lastBestRate;
        @AuraEnabled public String lastPassingRate;
        @AuraEnabled public String leaseTerm;
        @AuraEnabled public String totalLeasedArea;
    }
    
}