/**
 *  @description Auxiliary functions related to pricing
 *
 *  2019-07-04  Samuel Arroyo    Implement calculation of total rates depending on start/end dates
 */
public with sharing class PricingUtils {
	
    public static String opportunityType = 'Renewal';
    public static String opportunitySubType = 'Expansion';
    /**
     *  @description Function that calculates totals on quote line item
     *  @param  quoteLineItems  List of quote line items
     */
    public static void calculateQuoteLineItemTotals(List<QuoteLineItem> quoteLineItems) {
        for (QuoteLineItem quoteLineItem : quoteLineItems) {
            if (quoteLineItem.Start_Date__c != null && quoteLineItem.End_Date__c != null) {
                String transactionUnit = quoteLineItem.Transactional_Unit__c != null ? 
                    					 quoteLineItem.Transactional_Unit__c : 
                						 quoteLineItem.Transaction_Unit__c;
                // Calculate total Best Rate
                if (quoteLineItem.Best_Rate__c != null) {
                    Decimal annualBestRate = 0;
                    if (transactionUnit == 'Sqft') {
                        annualBestRate = quoteLineItem.Area__c * quoteLineItem.Best_Rate__c;
                    } else if (transactionUnit == 'Unit') {
                        annualBestRate = quoteLineItem.Best_Rate__c;
                    }
                    
                    quoteLineItem.Total_Best_Rate__c = getTotalRateBetweenDates(quoteLineItem.Start_Date__c, quoteLineItem.End_Date__c, annualBestRate);
                }

                // Calculate total Offer Price
                if (quoteLineItem.Offer_Price__c != null) {
                    Decimal annualOfferPrice = 0;
                    if (transactionUnit == 'Sqft') {
                        annualOfferPrice = quoteLineItem.Area__c * quoteLineItem.Offer_Price__c;
                    } else if (transactionUnit == 'Unit') {
                        annualOfferPrice = quoteLineItem.Offer_Price__c;
                    }
                    quoteLineItem.Total_Offered_Price__c = getTotalRateBetweenDates(quoteLineItem.Start_Date__c, quoteLineItem.End_Date__c, annualOfferPrice);
                }
            }
        }
    }
    
    public static void calculateGraceDiscountsAmountOnUpdate(List<QuoteLineItem> quoteLineItemList, Map<Id, QuoteLineItem> oldMap) {
        
        List<QuoteLineItem> quoteLineItemNewList = new List<QuoteLineItem>();
        for(QuoteLineItem itemObj : quoteLineItemList) {
            if((oldMap != null && 
                itemObj.Total_Offered_Price__c != oldMap.get(itemObj.Id).Total_Offered_Price__c &&
               itemObj.Price_Schedule__c != oldMap.get(itemObj.Id).Price_Schedule__c
               ) ||
               (itemObj.Total_Offered_Price__c != null && 
               itemObj.Price_Schedule__c != null)) {
                quoteLineItemNewList.add(itemObj);
            }
            
        }
        if(!quoteLineItemNewList.isEmpty()) {
            calculateGraceDiscountsAmount(quoteLineItemNewList);
        }
    }

    /**
     *  @description Function that calculates GP discount related formulas.
     *  @param  quoteLineItems  List of quote line items
     */
    public static void calculateGraceDiscountsAmount(List<QuoteLineItem> quoteLineItemList) {

        Set<Id> quoteIdSet = new Set<Id>();
        for(QuoteLineItem itemObj : quoteLineItemList) {
            quoteIdSet.add(itemObj.QuoteId);
        }
		
        Map<Id, Quote> quoteMap = new Map<Id, Quote> ([SELECT Id, Grace_Period__c, Grace_Period_Period__c
                                                       FROM Quote
                                                       WHERE Id IN: quoteIdSet
                                                    ]);

        for(QuoteLineItem qliObj : quoteLineItemList) {

            Decimal defaultGPDiscountAmount = 0.0;
            Decimal additionalGPDiscountAmount = 0.0;
            Quote quoteObj = quoteMap.get(qliObj.QuoteId);
            if(quoteObj.Grace_Period__c == null || qliObj.Total_Offered_Price__c == null ||  qliObj.Price_Schedule__c == null ||
               quoteObj.Grace_Period__c == 0 || quoteObj.Grace_Period_Period__c == null) {
                defaultGPDiscountAmount = 0.0;
            }
            else if(quoteObj.Grace_Period__c <= qliObj.Default_Grace_Period__c) { 
                if(quoteObj.Grace_Period_Period__c.equalsIgnoreCase('days')) {
                    defaultGPDiscountAmount = (qliObj.Total_Offered_Price__c / 365) * quoteObj.Grace_period__c;
                }
                else {
                    defaultGPDiscountAmount = (qliObj.Total_Offered_Price__c / 12) * quoteObj.Grace_period__c;
                }   
            }
            else if(quoteObj.Grace_Period__c >  qliObj.Default_Grace_Period__c) {
                Decimal qliGracePeriod = qliObj.Default_Grace_Period__c != null ? qliObj.Default_Grace_Period__c : 1;
                if(quoteObj.Grace_Period_Period__c.equalsIgnoreCase('days')) {
                    defaultGPDiscountAmount = (qliObj.Total_Offered_Price__c / 365) *  qliGracePeriod;
                    additionalGPDiscountAmount = (qliObj.Total_Offered_Price__c / 365) * (quoteObj.Grace_period__c -  qliGracePeriod);

                }
                else {
                    defaultGPDiscountAmount = (qliObj.Total_Offered_Price__c / 12) *  qliGracePeriod;
                    additionalGPDiscountAmount = (qliObj.Total_Offered_Price__c / 12) * (quoteObj.Grace_period__c -  qliGracePeriod);

                }   
            }
            qliObj.Default_GP_Discount_Amount__c = defaultGPDiscountAmount;
            qliObj.Additional_GP_Discount_Amount__c = additionalGPDiscountAmount;
        }
        system.debug('Limit SOQL calculateGraceDiscountsAmount-----:'+Limits.getQueries());
    }

    /**
     *  @description Function that returns the total rate based on annual rate and start/end date
     *  @param  startDate        First day
     *          endDate          Last day, included in rate
     *  @return Total rate with 2 decimal places
     */
    public static Decimal getTotalRateBetweenDates(Date startDate, Date endDate, Decimal annualRate) {
        Decimal totalRate = 0;

        if (startDate != null && endDate != null && annualRate != null && endDate > startDate) {

            Date currentDate = startDate;

            // 1. Process years
            while (endDate >= currentDate.addYears(1).addDays(-1)) {
                totalRate += annualRate;
                currentDate = currentDate.addYears(1);
            }

            // 2. Process months
            if (endDate > currentDate) {
                Decimal monthlyRate = annualRate/12;

                while (endDate >= currentDate.addMonths(1).addDays(-1)) {
                    totalRate += monthlyRate;
                    currentDate = currentDate.addMonths(1);
                }
            }
            // 3. Process days
            if (endDate >= currentDate) {
                Decimal dailyRate;
                if(currentDate.Month() != endDate.Month()) {
                	Integer numberOfDaysInCurrentMonth = Date.daysInMonth(currentDate.year(), currentDate.month());
                    Decimal numberOfDaysRemainingInCurrentMonth = currentDate.daysBetween(Date.newInstance(currentDate.year(), 
                                                                                                   currentDate.month(), 
                                                                                                   numberOfDaysInCurrentMonth
                                                                                                  )
                                                                                         ) + 1;
                    Integer numberOfDaysInEndMonth = Date.daysInMonth(endDate.year(), endDate.month());
                    Date firstDate = endDate.toStartOfMonth();
                    Decimal numberOfDaysRemainingInEndMonth = firstDate.daysBetween(endDate) + 1;
                    
                    
                    if(numberOfDaysRemainingInCurrentMonth > numberOfDaysRemainingInEndMonth) {
                         dailyRate = (annualRate/12)/numberOfDaysInCurrentMonth;
                    }
                    if(numberOfDaysRemainingInCurrentMonth <= numberOfDaysRemainingInEndMonth) {
                        dailyRate = (annualRate/12)/numberOfDaysInEndMonth;
                    }
                    
                } 
                else {
                    Decimal numberOfDaysInMonth = Date.daysInMonth(currentDate.year(), currentDate.month());
                    dailyRate = (annualRate/12)/numberOfDaysInMonth;
                }
                totalRate += dailyRate * (currentDate.daysBetween(endDate) + 1); // Last day is included too
            }
        }

        return totalRate.setScale(2);
    }

    /**
     *  @description Function that update price schedule and best price on QLI, also create related QLI for price shcedule charges.
     *  @param  newMap        Map of new QLI
     *  @return NA
     */
    public static void pricingScheduleRealTimeCalculation(Map<Id, QuoteLineItem> newMap) {

        Set<Id> currentQuoteIdSet = new Set<Id>();
        Map<Id, Id> currentQuoteIdVsPreviousQuoteIdMap = new Map<Id, Id>();
        Map<Id, Id> previousQuoteIdVscurrentQuoteIdMap = new Map<Id, Id>();
        Set<Id> productIdSet = new Set<Id>();
        Set<Id> quoteNewTypeIdSet = new Set<Id>();
        Map<Id, QuoteLineItem> lineItemMap = new Map<Id, QuoteLineItem>();
        Map<Id, Set<Id>> quoteVsProductMap = new Map<Id, Set<Id>>();
        Map<Id, Map<Id, List<QuoteLineItem>>> previousQuoteVsQliMap = new Map<Id, Map<Id, List<QuoteLineItem>>>();
        Map<Id, List<QuoteLineItem>> currentQuoteVsQliMap = new Map<Id, List<QuoteLineItem>>();
        Map<Id, List<PricingEngine.PricingPackage>> quoteIdVsPackageMap = new  Map<Id, List<PricingEngine.PricingPackage>>();
        Map<Id, Map<Id, PricingEngine.PricingPackage>> quoteVsProductPackageMap = new Map<Id, Map<Id, PricingEngine.PricingPackage>>();
        List<QuoteLineItem> serviceItemsList = new List<QuoteLineItem>();
        Map<Id,Decimal> quoteIdVsProposedTotalLeasedAreaMap = new Map<Id, Decimal>();
	
        // Get Quote and Product Id's for QLI for which Price Schedule is blank.
        for(QuoteLineItem qliObj : newMap.values()) {
            if(String.isBlank(qliObj.Price_Schedule__c) &&
               String.isBlank(qliObj.Parent_Quote_Line_Item__c)) {
                lineItemMap.put(qliObj.Id, qliObj);
                currentQuoteIdSet.add(qliObj.QuoteId);
                productIdSet.add(qliObj.Product2Id);
                if(!currentQuoteVsQliMap.containsKey(qliObj.QuoteId)) {
                    currentQuoteVsQliMap.put(qliObj.QuoteId, new List<QuoteLineItem> {qliObj});
                } else {
                    currentQuoteVsQliMap.get(qliObj.QuoteId).add(qliObj);
                }
            }
            if(String.isBlank(qliObj.Price_Schedule__c) &&
               String.isBlank(qliObj.Parent_Quote_Line_Item__c) &&
               qliObj.Transaction_Type__c.equalsIgnoreCase('New')) {
                quoteNewTypeIdSet.add(qliObj.QuoteId);
            }
        }

        if(!currentQuoteIdSet.isEmpty()) {

            // Get Quote information for related QLI.
            Map<Id, Quote> currentQuoteMap = new Map<Id, Quote>([
                SELECT  AccountId,
                        Type__c,
                        Status,
                        Proposed_Start_Date__c,
                        Previous_Quote__c,
                        Pricebook2Id,
                        Pricebook2.Name,
                        Proposed_End_Date__c
                FROM   Quote
                WHERE  Id IN :currentQuoteIdSet
            ]);
            
            // New changes
            if(!quoteNewTypeIdSet.isEmpty()) {
                
                system.debug('I am in ---:'+quoteNewTypeIdSet);
                for(QuoteLineItem itemObj: [SELECT Id, Area__c, QuoteId
                                            FROM QuoteLineItem
                                            WHERE QuoteId IN: quoteNewTypeIdSet
                                            AND Type__c = 'Normal'
                                            AND Parent_Quote_Line_Item__c = null
                                          ]) {
                    if(itemObj.Area__c != null) {
                        if(quoteIdVsProposedTotalLeasedAreaMap.containsKey(itemObj.QuoteId)) {
                            Decimal proposedTotalLeasedArea = quoteIdVsProposedTotalLeasedAreaMap.get(itemObj.QuoteId);
                            quoteIdVsProposedTotalLeasedAreaMap.put(itemObj.QuoteId, proposedTotalLeasedArea + itemObj.Area__c);
                        }
                        else {
                            quoteIdVsProposedTotalLeasedAreaMap.put(itemObj.QuoteId, itemObj.Area__c);
                        }
                    }
                }

            }

            // Get product information for related QLI.
            Map<Id, Product2> productMap = new Map<Id, Product2> ([
                SELECT  Name, Unit__r.Name, Unit__r.Building__r.Plot__r.Business_Park__c, Unit__r.Building__r.Plot__r.Business_Park__r.Business_Park_Code__c,
                        Unit__r.Building__r.Building_Code__c,  Unit__r.Floor_Type__c, Unit__r.Unit_Sub_Category__c, Unit__r.Unit_Sub_Category__r.Name,
                        Unit__r.Unit_Sub_Category__r.Unit_Category__r.Name, Unit__r.Exclude_DEWA_Charges_Common_Area__c, Unit__r.Exclude_Cooling_Charges__c,
                        Unit__r.Asset_Class_Name__c, Unit__r.Area_ft__c, Unit__r.Building__r.Ownership_Type__c
                FROM    Product2
                WHERE   Id IN : productIdSet
            ]);

            // Create current and previous map to use in next logic.
            for(Quote quoteObj :currentQuoteMap.values()) {

                currentQuoteIdVsPreviousQuoteIdMap.put(quoteObj.Id, quoteObj.Previous_Quote__c);
                previousQuoteIdVscurrentQuoteIdMap.put(quoteObj.Previous_Quote__c, quoteObj.Id);
            }

            // Fetch previous QLI for related products and Quote of inserted QLI.
            for(QuoteLineItem lineItemObj : [SELECT  Best_Rate__c, 
                                                     Price_Schedule__c, Type__c,
                                                     Price_Schedule__r.Rate_Cap__c, 
                                                     Quote.Proposed_Start_Date__c,
                                                     Offer_Price__c,
                                                     QuoteId, 
                                                     Product2Id
                                             FROM    QuoteLineItem 
                                             WHERE   QuoteId IN: previousQuoteIdVscurrentQuoteIdMap.keySet() AND
                                                     Product2Id IN :productIdSet AND
                                                     PriceSch_ChargeType__c = 'Rent'
                                             ORDER BY Start_Date__c ASC
                                           ]) {
                if(!quoteVsProductMap.containsKey(lineItemObj.QuoteId)) {
                    quoteVsProductMap.put(lineItemObj.QuoteId, new Set<Id> {lineItemObj.Product2Id});
                }
                else {
                    quoteVsProductMap.get(lineItemObj.QuoteId).add(lineItemObj.Product2Id);
                }
                if(!previousQuoteVsQliMap.containsKey(lineItemObj.QuoteId)) {
                    Map<Id, List<QuoteLineItem>> productIdVsQILmap = new 
                            Map<Id, List<QuoteLineItem>>{lineItemObj.Product2Id => new List<QuoteLineItem> {lineItemObj}};
                    previousQuoteVsQliMap.put(lineItemObj.QuoteId, productIdVsQILmap);
                }
                else {
                    
                    Map<Id, List<QuoteLineItem>> productIdVsLineItemList = previousQuoteVsQliMap.get(lineItemObj.QuoteId);
                    if(productIdVsLineItemList.containsKey(lineItemObj.Product2Id)) {
                        productIdVsLineItemList.get(lineItemObj.Product2Id).add(lineItemObj);
                    }
                    else {
                        productIdVsLineItemList.put(lineItemObj.Product2Id, new List<QuoteLineItem> {lineItemObj});
                    }
                    previousQuoteVsQliMap.put(lineItemObj.QuoteId, productIdVsLineItemList);
                }
            }

            Map<Id, Decimal> accountIdVsTotalLeasedAreaMap = getTotalLeaseAreaForEachQuote(currentQuoteMap);

            // Generate pricing packages for products related to Quote.
            for(Id quoteId  : currentQuoteVsQliMap.keySet()) {

                List<PricingEngine.Input> pricingInputList = new List<PricingEngine.Input>();
                Quote quote = currentQuoteMap.containsKey(quoteId) ? currentQuoteMap.get(quoteId) : null;
                //if(currentQuoteIdVsPreviousQuoteIdMap.containsKey(quoteId) && 
                   //quoteVsProductMap.containsKey(currentQuoteIdVsPreviousQuoteIdMap.get(quoteId))) {
                    for(QuoteLineItem quoteLineItemObj : currentQuoteVsQliMap.get(quoteId)) {
						
                        Decimal proposedTotalLeasedArea = quoteIdVsProposedTotalLeasedAreaMap.containsKey(quoteId) ? 
													      quoteIdVsProposedTotalLeasedAreaMap.get(quoteId) : 0.0; 
                        
                        Decimal existingLeaseArea = accountIdVsTotalLeasedAreaMap.containsKey(quote.AccountId) ?         
                                                    accountIdVsTotalLeasedAreaMap.get(quote.AccountId) : 0;
                                                        
                        Decimal totalLeaseArea = proposedTotalLeasedArea + existingLeaseArea;
                         
                        Product2 productObj = productMap.get(quoteLineItemObj.Product2Id);
                        PricingEngine.Input input = new PricingEngine.Input();
                        input.businessPark = productObj.Unit__r.Building__r.Plot__r.Business_Park__r.Business_Park_Code__c;
                        input.building = productObj.Unit__r.Building__r.Building_Code__c;
                        input.floorNumber = productObj.Unit__r.Floor_Type__c;
                        input.utility = productObj.Unit__r.Exclude_DEWA_Charges_Common_Area__c ? false : true;
                        input.cooling = productObj.Unit__r.Exclude_Cooling_Charges__c ? false : true;
                        input.assetClass = productObj.Unit__r.Asset_Class_Name__c;
                        input.productCategory = productObj.Unit__r.Unit_Sub_Category__r.Unit_Category__r.Name;
                        input.productSubcategory = productObj.Unit__r.Unit_Sub_Category__r.Name;
                        input.ownershipStatus = productObj.Unit__r.Building__r.Ownership_Type__c;
                        input.transactionType = quoteLineItemObj.Transaction_Type__c;
                        input.transactionDate = quote.Proposed_Start_Date__c;
                        input.leaseTerm = String.valueOf(quote.Proposed_Start_Date__c.monthsBetween(quote.Proposed_End_Date__c));
                        input.totalLeasedArea = String.valueOf(totalLeaseArea);
                        pricingInputList.add(input);

                    }
                    List<PricingEngine.PricingPackage> pricingPackages = PricingEngine.getPricingPackages(pricingInputList);
                    quoteIdVsPackageMap.put(quote.Id, pricingPackages);
                //}
                

            }

            system.debug('quoteIdVsPackageMap----:'+quoteIdVsPackageMap);

            // Create map of Quote and it's related product with pricing package.
            for(Id quoteId  : currentQuoteVsQliMap.keySet()) {

                Map<Id, PricingEngine.PricingPackage> productIdVsPricingPackage = new Map<Id, PricingEngine.PricingPackage>();
                Integer count = 0;
                List<PricingEngine.PricingPackage> pricingPackagesList = quoteIdVsPackageMap.get(quoteId);
                //if(currentQuoteIdVsPreviousQuoteIdMap.containsKey(quoteId) && 
                 // quoteVsProductMap.containsKey(currentQuoteIdVsPreviousQuoteIdMap.get(quoteId))) { 
                    for(QuoteLineItem quoteLineItemObj : currentQuoteVsQliMap.get(quoteId)) {

                        productIdVsPricingPackage.put(quoteLineItemObj.Id, pricingPackagesList.get(count));
                        ++count;
                    }

                    quoteVsProductPackageMap.put(quoteId, productIdVsPricingPackage);
                //}
            }
            system.debug('quoteVsProductPackageMap----:'+quoteVsProductPackageMap);
            
            // Update QLI with pricing schedule, calculate best rate as per price schedule and create QLI for related charges 
            Set<Id> uniqueSetId = new Set<Id>();
            for(Id quoteId  : currentQuoteVsQliMap.keySet()) {

                Map<Id, List<QuoteLineItem>> previousQuoteLinesMap = previousQuoteVsQliMap.get(currentQuoteIdVsPreviousQuoteIdMap.get(quoteId));
                Map<Id, PricingEngine.PricingPackage> productIdVsPricingPackage = quoteVsProductPackageMap.get(quoteId);
                system.debug('productIdVsPricingPackage----:'+productIdVsPricingPackage);
                 system.debug('urrentQuoteVsQliMap.get(quoteId)----:'+currentQuoteVsQliMap.get(quoteId));
                for(QuoteLineItem itemObj : currentQuoteVsQliMap.get(quoteId)) {
                    	if(itemObj.Transaction_Type__c.equalsIgnoreCase('Renewal')) {
                            if(productIdVsPricingPackage != null && 
                               previousQuoteLinesMap != null &&
                               productIdVsPricingPackage.containsKey(itemObj.Id) //&&
                               //previousQuoteLinesMap.containsKey(itemObj.Product2Id) 
                               ) {
        
                                List<QuoteLineItem> previousQuoteLines = previousQuoteLinesMap.containsKey(itemObj.Product2Id) ? 
                                                                         previousQuoteLinesMap.get(itemObj.Product2Id) : new List<QuoteLineItem>();
        
                                PricingEngine.PricingPackage pricingPackage = productIdVsPricingPackage.get(itemObj.Id);
                                system.debug('pricingPackage----:'+pricingPackage);
                                if (pricingPackage.rates != null) {
                                    for (Price_Schedule__c rate : pricingPackage.rates) {
                                        if (rate.Charge_Type__r.Name == 'Rent') {
                                            
                                            if(String.isBlank(rate.Rate_Increase_Mechanism__c) ||
                                              (rate.Rate_Increase_Mechanism__c.equalsIgnoreCase('Fixed Percentage') && 
                                               rate.Percent_Increase__c == null)) {
                                                itemObj.addError(System.Label.Rate_Of_Mechanism_Blank_Error);
                                                return; 
                                            }
        
                                            QuoteLineItem quoteLineItem = new QuoteLineItem(
                                                Id = itemObj.Id,
                                                Offer_Price__c = rate.Rate__c,
                                                Default_Grace_Period__c = rate.Grace_Period__c,
                                                Default_Grace_Period_Format__c = rate.Grace_Period_Format__c,
                                                Default_Grace_Period_Mechanism__c = rate.Grace_Period_Mechanism__c,
                                                Price_Schedule__c = rate.Id,
                                                Best_Rate__c = rate.Rate__c,
                                                Charge_Type__c = 'Rent'
                                            );
        
                                            if(rate.Rate_Increase_Mechanism__c.equalsIgnoreCase('Fixed Rate')) {
                                                quoteLineItem.Best_Rate__c = rate.Rate__c;
        
                                            }
                                            else if(rate.Rate_Increase_Mechanism__c.equalsIgnoreCase('Fixed Percentage') && !previousQuoteLines.isEmpty()) {
                                                Decimal rateOfIncrease = rate.Percent_Increase__c / 100;
                                                if(rate.Renewal_Downsize_Rate_To_Use__c.equalsIgnoreCase('Initial Best Rate')) {
        
                                                    quoteLineItem.Best_Rate__c = previousQuoteLines.get(0).Best_Rate__c + (previousQuoteLines.get(0).Best_Rate__c * rateOfIncrease);
                                                }
                                                else if(rate.Renewal_Downsize_Rate_To_Use__c.equalsIgnoreCase('Last Best Rate')) {
                                                    quoteLineItem.Best_Rate__c = previousQuoteLines.get(previousQuoteLines.size()-1).Best_Rate__c + (previousQuoteLines.get(previousQuoteLines.size()-1).Best_Rate__c * rateOfIncrease);
                                                }
                                                else if(rate.Renewal_Downsize_Rate_To_Use__c.equalsIgnoreCase('Last Passing Rate')) {
                                                    quoteLineItem.Best_Rate__c = previousQuoteLines.get(previousQuoteLines.size()-1).Offer_Price__c + (previousQuoteLines.get(previousQuoteLines.size()-1).Offer_Price__c * rateOfIncrease);
                                                }
                                                
                                            }
        
                                            else if(rate.Rate_Increase_Mechanism__c.equalsIgnoreCase('Use RERA Index') && 
                                                    !previousQuoteLines.isEmpty()) {

                                                if(rate.Renewal_Downsize_Rate_To_Use__c.equalsIgnoreCase('Initial Best Rate')) {
                                                    Decimal reraIndex = getRERAIndex(productMap.get(itemObj.Product2Id), 
                                                                                     currentQuoteMap.get(itemObj.QuoteId).Proposed_Start_Date__c, 
                                                                                     previousQuoteLines.get(0).Best_Rate__c) / 100;
                                                    quoteLineItem.Best_Rate__c = previousQuoteLines.get(0).Best_Rate__c + (previousQuoteLines.get(0).Best_Rate__c * reraIndex);
                                                }
                                                else if(rate.Renewal_Downsize_Rate_To_Use__c.equalsIgnoreCase('Last Best Rate')) {
         
        
                                                    Decimal reraIndex = getRERAIndex(productMap.get(itemObj.Product2Id), 
                                                                                     currentQuoteMap.get(itemObj.QuoteId).Proposed_Start_Date__c, 
                                                                                     previousQuoteLines.get(previousQuoteLines.size()-1).Best_Rate__c) / 100;
                                                    quoteLineItem.Best_Rate__c = previousQuoteLines.get(previousQuoteLines.size()-1).Best_Rate__c + 
                                                                                (previousQuoteLines.get(previousQuoteLines.size()-1).Best_Rate__c * reraIndex);
                                                }
                                                else if(rate.Renewal_Downsize_Rate_To_Use__c.equalsIgnoreCase('Last Passing Rate')) {
                                                    Decimal reraIndex = getRERAIndex(productMap.get(itemObj.Product2Id), 
                                                                                     currentQuoteMap.get(itemObj.QuoteId).Proposed_Start_Date__c, 
                                                                                     previousQuoteLines.get(previousQuoteLines.size()-1).Offer_Price__c) / 100;
                                                    quoteLineItem.Best_Rate__c = previousQuoteLines.get(previousQuoteLines.size()-1).Offer_Price__c + 
                                                                                (previousQuoteLines.get(previousQuoteLines.size()-1).Offer_Price__c * reraIndex);
                                                }
                                                
                                            }
                                            //break;
                                            quoteLineItem.Offer_Price__c = quoteLineItem.Best_Rate__c;
                                            system.debug('rewnalw QLI-----:'+quoteLineItem);
                                            serviceItemsList.add(quoteLineItem);
                                        }
                                        else {
        
        
                                            QuoteLineItem quoteLineItem = new QuoteLineItem(
                                                QuoteId = quoteId,
                                                PricebookEntryId = itemObj.PricebookEntryId,
                                                UnitPrice = itemObj.UnitPrice,
                                                Quantity = 1,
                                                Area__c = itemObj.Area__c,
                                                Best_Rate__c = rate.Rate__c,
                                                Offer_Price__c = rate.Rate__c,
                                                Default_Grace_Period__c = rate.Grace_Period__c,
                                                Default_Grace_Period_Format__c = rate.Grace_Period_Format__c,
                                                Default_Grace_Period_Mechanism__c = rate.Grace_Period_Mechanism__c,
                                                Price_Schedule__c = rate.Id,
                                                Parent_Quote_Line_Item__c = itemObj.Id,
                                                Transaction_Type__c = 'Renewal',
                                                Charge_Type__c = 'Service Charge'
                                            );
        									system.debug('rewnalw QLI-----:'+quoteLineItem);
                                            serviceItemsList.add(quoteLineItem);
                                        }
        
                                    }
                                }
                            }
                        }
                        else if(itemObj.Transaction_Type__c.equalsIgnoreCase('New') && 
                                productIdVsPricingPackage != null && 
                                productIdVsPricingPackage.containsKey(itemObj.Id)) {
        
                                PricingEngine.PricingPackage pricingPackage = productIdVsPricingPackage.get(itemObj.Id);
                                
                                    
                                system.debug('pricingPackage----:'+pricingPackage);
                                if (pricingPackage.rates != null) {
                                    for (Price_Schedule__c rate : pricingPackage.rates) {
                                        if (rate.Charge_Type__r.Name == 'Rent') {
        
                                            QuoteLineItem quoteLineItem = new QuoteLineItem(
                                                Id = itemObj.Id,
                                                Offer_Price__c = rate.Rate__c,
                                                Default_Grace_Period__c = rate.Grace_Period__c,
                                                Default_Grace_Period_Format__c = rate.Grace_Period_Format__c,
                                                Default_Grace_Period_Mechanism__c = rate.Grace_Period_Mechanism__c,
                                                Price_Schedule__c = rate.Id,
                                                Best_Rate__c = rate.Rate__c,
                                                Charge_Type__c = 'Rent'
                                            );
                                            system.debug('quoteLineItem-----:'+quoteLineItem);
                                            serviceItemsList.add(quoteLineItem);
                                        }
                                        else {
        
        
                                            QuoteLineItem quoteLineItemCharge = new QuoteLineItem(
                                                QuoteId = quoteId,
                                                PricebookEntryId = itemObj.PricebookEntryId,
                                                UnitPrice = itemObj.UnitPrice,
                                                Quantity = 1,
                                                Area__c = itemObj.Area__c,
                                                Best_Rate__c = rate.Rate__c,
                                                Offer_Price__c = rate.Rate__c,
                                                Default_Grace_Period__c = rate.Grace_Period__c,
                                                Default_Grace_Period_Format__c = rate.Grace_Period_Format__c,
                                                Default_Grace_Period_Mechanism__c = rate.Grace_Period_Mechanism__c,
                                                Price_Schedule__c = rate.Id,
                                                Parent_Quote_Line_Item__c = itemObj.Id,
                                                Transactional_Unit__c = itemObj.Transactional_Unit__c,
                                                Charge_Type__c = 'Service Charge'
                                            );
        									system.debug('quoteLineItemCharge-----:'+quoteLineItemCharge);
                                            serviceItemsList.add(quoteLineItemCharge);
                                        }
        
                                    }
                                }  
                            
                        }
                    }                
            }
            if(!serviceItemsList.isEmpty())
                upsert serviceItemsList;
        } 
        
        system.debug('Limit SOQL PricingSchduel-----:'+Limits.getQueries());
    }


    /**
     *  @description Function that returns the RERA Index for a specific product/date/rate
     *  @param  product     Product to filter by
     *          startDate   Start of the lease
     *          rate        Current rate
     *  @return Decimal with percent increase
     */
     private static Decimal getRERAIndex(Product2 product, Date startDate, Decimal rate){
        if (product != null && startDate != null) {
            List<Rate_Increase_Index__c> rateIncreaseIndexes = [
                SELECT  Percent_Increase__c
                FROM    Rate_Increase_Index__c 
                WHERE   Business_Park__c = :product.Unit__r.Building__r.Plot__r.Business_Park__c AND
                        (Unit_Sub_Category__c = null OR Unit_Sub_Category__c = :product.Unit__r.Unit_Sub_Category__c) AND
                        Effective_Date_From__c <= :startDate AND
                        (Effective_Date_To__c = null OR Effective_Date_To__c >= :startDate) AND
                        (Current_Rate_From__c =null OR Current_Rate_From__c <= :rate) AND
                        (Current_Rate_To__c = null OR Current_Rate_To__c >= :rate)
                LIMIT 1
            ];
            if(!rateIncreaseIndexes.isEmpty()){   
                return rateIncreaseIndexes.get(0).Percent_Increase__c;
            }
        }
        return 0;
    }
    /**
     *  @description Function that total leased area for passed map of quote
     *  @param  quoteMap     map of Quote
     *  @return map of each account Id vs existing leased are of related QLI
     */
    public static Map<Id, Decimal> getTotalLeaseAreaForEachQuote(Map<Id, Quote> quoteMap) {

        Map<Id, Decimal> accountIdVsTotalLeasedAreaMap = new Map<Id, Decimal>();
        Set<Id> accountIdSet = new Set<Id>();

        for(Quote quoteObj : quoteMap.values()) {
            accountIdSet.add(quoteObj.AccountId);
        }   

        for(QuoteLineItem resultObj : [SELECT Area__c, Quote.AccountId 
                                       FROM QuoteLineItem
                                       WHERE Quote.AccountId IN: accountIdSet
                                        AND Type__c = 'Normal'
                                        AND Parent_Quote_Line_Item__c = null
                                        AND Quote.Status IN ('Accepted', 'Synched')
                                      ]) {
            if(resultObj.Area__c != null) {
                if(accountIdVsTotalLeasedAreaMap.containsKey(resultObj.Quote.AccountId)) {
                    Decimal existingLeasedArea = accountIdVsTotalLeasedAreaMap.get(resultObj.Quote.AccountId);
                    accountIdVsTotalLeasedAreaMap.put(resultObj.Quote.AccountId, existingLeasedArea + resultObj.Area__c);
                }
                else {
                    accountIdVsTotalLeasedAreaMap.put(resultObj.Quote.AccountId,  resultObj.Area__c);
                }
            }
            
        }
        return accountIdVsTotalLeasedAreaMap;
    }

    /**
     *  @description Method to avoid inserting duplicate quote line items of same type, product and price schedule.
     *  @param  currentlineItems    inserted QLI
     */
    public static void checkDuplicateQLI(List<QuoteLineItem> currentlineItems) {

        Set<Id> quoteIdSet = new Set<Id>();
        for(QuoteLineItem qliObj : currentlineItems) {
            if(qliObj.Type__c.equalsIgnoreCase('Normal') && qliObj.Parent_Quote_Line_Item__c == null) {
                quoteIdSet.add(qliObj.QuoteId);
            }
        }

        if (!quoteIdSet.isEmpty()) {
            Map<Id, Set<String>> quoteIdVsProductScheduleMap = new Map<Id, Set<String>>();
            for (QuoteLineItem itemObj : [
                    SELECT Id, Price_Schedule__c, PricebookEntryId, QuoteId
                    FROM QuoteLineItem
                    WHERE QuoteId IN:quoteIdSet
                    AND Type__c = 'Normal'
                    AND Id NOT IN :currentlineItems
                    AND Price_Schedule__c != null
            ]) {
                if (quoteIdVsProductScheduleMap.containsKey(itemObj.QuoteId)) {
                    quoteIdVsProductScheduleMap.get(itemObj.QuoteId).add(itemObj.PricebookEntryId + '' + itemObj.Price_Schedule__c);
                } else {
                    quoteIdVsProductScheduleMap.put(itemObj.QuoteId, new Set<String>{itemObj.PricebookEntryId + '' + itemObj.Price_Schedule__c});
                }
            }
			
            for (QuoteLineItem newQLI : currentlineItems) {
                if (newQLI.Type__c.equalsIgnoreCase('Normal') &&
                        quoteIdVsProductScheduleMap.containsKey(newQLI.QuoteId) &&
                        quoteIdVsProductScheduleMap.get(newQLI.QuoteId).contains(newQLI.PricebookEntryId + '' + newQLI.Price_Schedule__c) &&
                        newQLI.Price_Schedule__c != null) {
                    newQLI.addError('Product has already added with same Price schedule.');
                }
            }
        }
    }
	/**
     *  @description Method to check if Price schedule is changed with Rent type then populate Number of terms on Quote. 
     *  @param  newQuoteLineItemList    List of inserted Quote Line Item
	 *  @param  oldQuoteLineItemMap     Map of old values of Quote line Items
     */
	public static void checkToPopulatePaymentTermOnQuote(List<QuoteLineItem> newQuoteLineItemList, 
													     Map<Id, QuoteLineItem> oldQuoteLineItemMap) {
		
		//Map<Id, QuoteLineItem> quoteLineItemMap = new Map<Id, QuoteLineItem>();
		Set<Id> quoteLineItemSet = new Set<Id>();
		for(QuoteLineItem lineObj : newQuoteLineItemList) {
            if(oldQuoteLineItemMap == null) {
				if(lineObj.Price_Schedule__c != null)  {
					quoteLineItemSet.add(lineObj.Id);
				}
			}
			else {
				if(lineObj.Price_Schedule__c != null && 
				   lineObj.Price_Schedule__c != oldQuoteLineItemMap.get(lineObj.Id).Price_Schedule__c) {
					quoteLineItemSet.add(lineObj.Id);
				}
			}
		}
		
		if(!quoteLineItemSet.isEmpty()) {
            if(!System.isBatch()){
                populatePaymentTermOnQuoteAsync(quoteLineItemSet);
            }else if(System.isBatch()){
                populatePaymentTermOnQuote(quoteLineItemSet);
            }
		}
	}
    @future
    public static void populatePaymentTermOnQuoteAsync(Set<Id> quoteLineItemSet){
        populatePaymentTermOnQuote(quoteLineItemSet);
    }
    
    /**
     *  @description Method to avoid inserting duplicate quote line items of same type, product and price schedule.
     *  @param  quoteLineItemMap    Map of inserted Quote Line Item
     */
    //@future
    public static void populatePaymentTermOnQuote(Set<Id> quoteLineItemSet) {
        System.debug('-----Inside Trigger-------');
        Map<Id, Quote> QuoteIdVsNoOfPaymentMap = new Map<Id, Quote>();
        List<QuoteLineItem> lineItemList = [SELECT Id, Price_Schedule__r.Payment_Term__r.Number_Of_Payments__c, QuoteId, 		
												   Product2.Unit__r.Unit_Sub_Category__r.Unit_Category__c
                                            FROM QuoteLineItem 
                                            WHERE Id IN: quoteLineItemSet
                                            AND Price_Schedule__r.Charge_Type__r.Name = 'Rent'
                                            AND Quote.Category__c = null
                                            AND Quote.Number_Of_Payments__c = null
                                           ];
        for(QuoteLineItem lineObj : lineItemList) {
            
            if(!QuoteIdVsNoOfPaymentMap.containsKey(lineObj.QuoteId)) {
            	QuoteIdVsNoOfPaymentMap.put(lineObj.QuoteId, new Quote(Id = lineObj.QuoteId, 
                                                                       Number_Of_Payments__c = lineObj.Price_Schedule__r.Payment_Term__r.Number_Of_Payments__c,
                                                                       Category__c = lineObj.Product2.Unit__r.Unit_Sub_Category__r.Unit_Category__c
                                                                      ));
            }
        }
        
        update (QuoteIdVsNoOfPaymentMap.values());
    }
    /**
     *  @description Function that restricts deletion of QLI if it's Quote's opportunity Type is Renewal and Sub-type is Expansion.
     *  @param  List        List of QuoteLineItem
     *  @return NA
     */
    public static void restrictDeletionRenewalExpansionLineItems(List<QuoteLineItem> lineItems)
    {
        //System.debug(ApexPages.CurrentPage());
        Map<Id, Quote> quoteMap = new Map<Id, Quote>();
        Set<Id> quoteIds = new Set<Id>();
        for(QuoteLineItem qliObj: lineItems) {
            quoteIds.add(qliObj.QuoteId);
        }
        if (!quoteIds.isEmpty()) {
            for (Quote qObj : [SELECT 
                               		Id, 
                               		Opportunity.Type, 
                               		Opportunity.Sub_Type__c 
                               FROM Quote 
                               WHERE Id IN :quoteIds
                              ]) {
                if(!quoteMap.containsKey(qObj.Id)) {
                	quoteMap.put(qObj.Id, qObj);
                }
            } 
        }
        
        for(QuoteLineItem qliObj: lineItems)
        {	
            if(quoteMap.get(qliObj.QuoteId).Opportunity.Type == opportunityType && 
               quoteMap.get(qliObj.QuoteId).Opportunity.Sub_Type__c == opportunitySubType) {
                //qliObj.addError(Label.Cannot_delete_QLI_if_opportunity_type_is_renewal_and_Expansion);
            }
        }
    }
}