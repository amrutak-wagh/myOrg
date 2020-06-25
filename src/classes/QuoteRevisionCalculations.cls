/**
 * @who    : Sadiq Adesanya <sadiq.adesanya@weare4c.com>
 * @when  : 18/06/2019
 * @what  : Class is used to calculate and insert quote revisions (QuoteLineItem)
 */
public class QuoteRevisionCalculations {
    public static final String TYPE_NORMAL = 'Normal';
    public static final String TYPE_REVISION = 'Revision';
    
    /**
     * @method    : handleQuoteUpdate()
     * @description  : Method to handle changes made on the quote object and re-calculate quote revisions if needed
     * @return    : N/A
     * @params    : oldMap - old quote version
     *           newMap - version of quote containing changed values
     */
    public static void handleQuoteUpdate(Map<Id,Quote> oldMap, Map<Id,Quote> newMap) {
        Set<Id> parentQuoteIds = new Set<Id>();
        for(Quote loopQuote : newMap.values()) {
            if(loopQuote.Proposed_Start_Date__c != oldMap.get(loopQuote.Id).Proposed_Start_Date__c ||
               loopQuote.Proposed_End_Date__c != oldMap.get(loopQuote.Id).Proposed_End_Date__c)
            {
                parentQuoteIds.add(loopQuote.Id);
            }
        }
        if(!parentQuoteIds.isEmpty()) {
            // Get parent line items for quote revisions
            Map<Id, QuoteLineItem> quoteChildrenRecords = new Map<Id, QuoteLineItem>([
                    SELECT  Id, QuoteId, Quantity, PricebookEntryId, Price_Schedule__c,
                            UnitPrice, Charge_Code__c, Area__c, Transactional_Unit__c,
                            Offer_Price__c, Type__c, Start_Date__c, End_Date__c,
                            Revision_Number__c, Parent_Quote_Line_Item__c, Best_Rate__c
                    FROM    QuoteLineItem
                    WHERE   QuoteId IN :parentQuoteIds AND
                            Type__c = :TYPE_NORMAL
            ]);
            
            
            if(!quoteChildrenRecords.keySet().isEmpty()) {
                // delete previous quote revisions
                deleteQuoteRevisions(parentQuoteIds);
                deleteQuoteRevisionItems(quoteChildrenRecords.keySet());
                generateQuoteRevisions(quoteChildrenRecords.values());
            }
        }
    }

    /**
     * @method    : handleQuoteLineItemInsert()
     * @description  : Method to generate quote revisions if needed
     * @return    : N/A
     * @params    : oldMap - old quote line version
     *           newMap - version of quote line containing changed values
     */
    public static void handleQuoteLineItemInsert(Map<Id, QuoteLineItem> newMap) {
        // Generate quote revisions and quote revision items
        List<QuoteLineItem> parentRevisionItems = new List<QuoteLineItem>();
        for(QuoteLineItem quoteLineItem : newMap.values()) {
            if(quoteLineItem.Type__c == TYPE_NORMAL &&
               quoteLineItem.Price_Schedule__c != null &&
               quoteLineItem.Offer_Price__c != null)
            {
                parentRevisionItems.add(quoteLineItem);
            }
        }
        Map<Id, Quote_Revision__c> revisionsByIds = new Map<Id, Quote_Revision__c>();
        if(!parentRevisionItems.isEmpty()) {
            revisionsByIds = generateQuoteRevisions(parentRevisionItems);
        }

        // Roll up to Quote Revision
        Set<Id> quoteRevisionsToRecalculate = new Set<Id>();
        for(QuoteLineItem quoteLineItem : newMap.values()) {
            if (quoteLineItem.Quote_Revision__c != null) {
                quoteRevisionsToRecalculate.add(quoteLineItem.Quote_Revision__c);
            }
        }
        quoteRevisionsToRecalculate.addAll(revisionsByIds.keySet());
        if(!quoteRevisionsToRecalculate.isEmpty()){
            rollUpQuoteRevisions(quoteRevisionsToRecalculate);
        }
    }

    /**
     * @method    : handleQuoteLineItemUpdate()
     * @description  : Method to handle changes made on the quote line item object and re-calculate quote revisions if needed
     * @return    : N/A
     * @params    : oldMap - old quote line version
     *           newMap - version of quote line containing changed values
     */
    public static void handleQuoteLineItemUpdate(Map<Id, QuoteLineItem> oldMap, Map<Id, QuoteLineItem> newMap) {
        // Generate quote revisions and quote revision items
        Map<Id, QuoteLineItem> parentRevisionItems = new Map<Id, QuoteLineItem>();
        for(QuoteLineItem quoteLineItem : newMap.values()) {
            if(quoteLineItem.Type__c == TYPE_NORMAL && quoteLineItem.Price_Schedule__c != null &&
               (quoteLineItem.Offer_Price__c != oldMap.get(quoteLineItem.Id).Offer_Price__c ||
                quotelineItem.Price_Schedule__c != oldMap.get(quoteLineItem.Id).Price_Schedule__c))
            {
                parentRevisionItems.put(quoteLineItem.Id, quoteLineItem);
            }
        }
        Map<Id, Quote_Revision__c> revisionsByIds = new Map<Id, Quote_Revision__c>();
        if(!parentRevisionItems.isEmpty()) {
            deleteQuoteRevisionItems(parentRevisionItems.keySet());
            revisionsByIds = generateQuoteRevisions(parentRevisionItems.values());
        }

        // Roll up to Quote Revision
        Set<Id> quoteRevisionsToRecalculate = new Set<Id>();
        for(QuoteLineItem quoteLineItem : newMap.values()) {
            if (quoteLineItem.Quote_Revision__c != oldMap.get(quoteLineItem.Id).Quote_Revision__c ||
                quoteLineItem.Total_Offered_Price__c != oldMap.get(quoteLineItem.Id).Total_Offered_Price__c ||
                quoteLineItem.Total_Best_Rate__c != oldMap.get(quoteLineItem.Id).Total_Best_Rate__c) {
                quoteRevisionsToRecalculate.add(quoteLineItem.Quote_Revision__c);
            }
        }
        quoteRevisionsToRecalculate.addAll(revisionsByIds.keySet());
        if(!quoteRevisionsToRecalculate.isEmpty()){
            rollUpQuoteRevisions(quoteRevisionsToRecalculate);
        }
    }

    public static void handleQuoteLineItemDelete(Map<Id, QuoteLineItem> oldMap){
        //Calculate quote revision totals
        Set<Id> parentQuoteLineItemIds = new Set<Id>();
        Set<Id> quoteRevisionIds = new Set<Id>();
        for(QuoteLineItem quoteLineItem : oldMap.values()) {
            if (quoteLineItem.Type__c == TYPE_NORMAL) {
                parentQuoteLineItemIds.add(quoteLineItem.Id);
            }
            if(quoteLineItem.Quote_Revision__c != null){
                quoteRevisionIds.add(quoteLineItem.Quote_Revision__c);
            }
        }
        if (!parentQuoteLineItemIds.isEmpty()) {
            deleteQuoteRevisionItems(parentQuoteLineItemIds, oldMap.keySet());
        }
        if(!quoteRevisionIds.isEmpty()){
            rollUpQuoteRevisions(quoteRevisionIds);
        }

    }

    /**
     * @method    : deleteQuoteRevisions
     * @description  : Method to delete quote revisions
     * @return    : N/A
     * @params    : quoteIds - Set of quote ids
     */
    public static void deleteQuoteRevisions(Set<Id> quoteIds) {
        delete [SELECT Id FROM Quote_Revision__c WHERE Quote__c IN :quoteIds];
    }
    
    /**
     * @method    : deleteQuoteRevisionItems
     * @description  : Method to delete quote line items of type Revision
     * @return    : N/A
     * @params    : parentQuoteLineItemIds - Set of parent quote line item ids
     */
    public static void deleteQuoteRevisionItems(Set<Id> parentQuoteLineItemIds) {
        delete [SELECT Id FROM QuoteLineItem WHERE Parent_Quote_Line_Item__c IN :parentQuoteLineItemIds AND Type__c = :TYPE_REVISION];
    }

    public static void deleteQuoteRevisionItems(Set<Id> parentQuoteLineItemIds, Set<Id> idsToExclude) {
        delete [SELECT Id FROM QuoteLineItem WHERE Parent_Quote_Line_Item__c IN :parentQuoteLineItemIds AND Type__c = :TYPE_REVISION AND Id NOT IN :idsToExclude];
    }
    
    /**
     * @method    : generateQuoteRevisions
     * @description  : Method which creates and inserts quote revisions and quote line items of type Revision
     * @return    : N/A
     * @params    : lineItems - Parent quote line items
     */
    public static Map<Id, Quote_Revision__c> generateQuoteRevisions(List<QuoteLineItem> lineItems) {
        Map<Id, Quote_Revision__c> revisionsByIds = new Map<Id, Quote_Revision__c>();

        // Declare and initialise all variables to be used to make the necessary calculations
        List<QuoteLineItem> quoteLineItemsToProcess = new List<QuoteLineItem>();
        Set<Id> priceScheduleIds = new Set<Id>();
        Set<Id> quoteIds = new Set<Id>();

        // Populate the above variables with relevant values for calculation. Only initial revision records should have calculation done
        for(QuoteLineItem lineItem : lineItems) {
            if(lineItem.Type__c == TYPE_NORMAL && lineItem.Price_Schedule__c != null) {
                priceScheduleIds.add(lineItem.Price_Schedule__c);
                quoteLineItemsToProcess.add(lineItem);
                quoteIds.add(lineItem.QuoteId);
            }
        }
        if(!quoteLineItemsToProcess.isEmpty() && !priceScheduleIds.isEmpty()) {
            // Retrieve quotes and create Revision records in case they are missing
            Map<Id, Quote> parentQuotes = new Map<Id, Quote>([
                    SELECT Id, Proposed_Start_Date__c, Proposed_End_Date__c,
                    (SELECT Id, Quote__c, Revision_Number__c FROM Quote_Revisions__r ORDER BY Revision_Number__c ASC)
                    FROM    Quote
                    WHERE   Id IN :quoteIds
            ]);

            Map<Id, Map<Integer, Quote_Revision__c>> relatedQuoteRevisions = createRevisionItems(parentQuotes);
            for (Map<Integer, Quote_Revision__c> revisionsByNumber : relatedQuoteRevisions.values()) {
                revisionsByIds.putAll(revisionsByNumber.values());
            }

            // Retrieve Rate Increase Index by Price Schedule Id and create quote line items of type Revision
            Map<Id, Price_Schedule__c> priceSchedulesByIds = new Map<Id, Price_Schedule__c>([
                    SELECT  Id, Rate_Cap__c, (SELECT Id, Price_Schedule__c, Name, Effective_Date_From__c, Percent_Increase__c,
                            Order__c, Duration_Years__c FROM Rate_Increase_Indexes__r WHERE RecordType.Name = 'Rate Increase' ORDER BY Order__c ASC)
                    FROM    Price_Schedule__c
                    WHERE   Id IN :priceScheduleIds
            ]);
            createRevisionLineItems(quoteLineItemsToProcess, priceSchedulesByIds, parentQuotes, relatedQuoteRevisions);
        }
        return revisionsByIds;
    }

    /**
     * @method    : createRevisionItems
     * @description  : Calculate and generate missing quote revisions on quotes based on proposed start/end date
     * @return    : Map of Quote Revisions per Revision Number and Quote
     * @params    : quotes - Map of quotes by id
     */
    private static Map<Id, Map<Integer, Quote_Revision__c>> createRevisionItems(Map<Id, Quote> quotes) {
        Map<Id, Map<Integer, Quote_Revision__c>> revisionsPerQuote = new Map<Id, Map<Integer, Quote_Revision__c>>();
        List<Quote_Revision__c> quoteRevisionsToInsert = new List<Quote_Revision__c>();
        for(Quote quote : quotes.values()) {
            // Initialise map with expected number of revisions
            revisionsPerQuote.put(quote.Id, getExpectedRevisions(quote.Id, quote.Proposed_Start_Date__c, quote.Proposed_End_Date__c));

            // Overwrite map with existing quote revisions
            for(Quote_Revision__c quoteRevision : quote.Quote_Revisions__r) {
                revisionsPerQuote.get(quote.Id).put(Integer.valueOf(quoteRevision.Revision_Number__c), quoteRevision);
            }

            // Add new quote revisions to list to be inserted
            for (Quote_Revision__c revision : revisionsPerQuote.get(quote.Id).values()) {
                if (revision.Id == null) {
                    quoteRevisionsToInsert.add(revision);
                }
            }
        }

        // Insert new revisions
        if (!quoteRevisionsToInsert.isEmpty()) {
            System.debug('Generating Quote Revisions - ' + quoteRevisionsToInsert.size());
            insert quoteRevisionsToInsert;
        }

        return revisionsPerQuote;
    }

    /**
     * @method    : getExpectedRevisions
     * @description  : Calculate expected revisions on quote based on proposed start/end date.
     *                One revision per year
     * @return    : Map of Quote Revisions by Revision Number
     * @params    : quoteId - Id of a quote
     *                startDate - Date to start first revision
     *                endDate - Date to finish last revision
     */
    private static Map<Integer, Quote_Revision__c> getExpectedRevisions(Id quoteId, Date startDate, Date endDate) {
        Map<Integer, Quote_Revision__c> expectedRevisionsByNumber = new Map<Integer, Quote_Revision__c>();
        while (startDate < endDate) {
            Integer daysBetween = startDate.daysBetween(endDate);
            Date revisionEndDate;
            if (daysBetween<365) {
                revisionEndDate = startDate.addDays(daysBetween);
            } else {
                revisionEndDate = startDate.addMonths(12).addDays(-1);
            }
            Integer revisionNumber = expectedRevisionsByNumber.size();
            expectedRevisionsByNumber.put(revisionNumber, new Quote_Revision__c(
                Revision_Number__c = revisionNumber,
                Quote__c = quoteId,
                Start_Date__c = startDate,
                End_Date__c = revisionEndDate
            ));
            if (daysBetween<365) {
                startDate = revisionEndDate;
            } else {
                startDate = startDate.addMonths(12);
            }
        }
        return expectedRevisionsByNumber;
    }
    
    /**
     * @method    : createRevisionLineItems
     * @description  : Method to compute quote revision line items and their offer/best price, which should relate to original line item from trigger.
     * @return    : TotalRevisionRecords - Inner class which collates all the records created within methods and groups them for insertion
     * 
     * @params    : lineItemsWithSchedule - All line items that need computing
     *           priceSchedulesByIds - Price Schedule records which contain rate increase records. Rate increases needed to calculate offer price for each revision year
     *           parentQuotes - Parent quote records
     *           relatedQuoteRevisions - Quote revision records which will be applied to a lookup on revision line items. Sorted by parent quotes
     */
    private static List<QuoteLineItem> createRevisionLineItems(
            List<QuoteLineItem> lineItemsWithSchedule,
            Map<Id, Price_Schedule__c> priceSchedulesByIds,
            Map<Id, Quote> parentQuotes,
            Map<Id, Map<Integer, Quote_Revision__c>> relatedQuoteRevisions)
    {
        List<QuoteLineItem> revisionLineItems = new List<QuoteLineItem>();
        for(QuoteLineItem lineItem : lineItemsWithSchedule) {
            // Get related rate increase records
            Price_Schedule__c priceSchedule = priceSchedulesByIds.get(lineItem.Price_Schedule__c);
            List<Rate_Increase_Index__c> relatedRateIncreases = priceSchedule.Rate_Increase_Indexes__r;
            Date startDate = parentQuotes.get(lineItem.QuoteId).Proposed_Start_Date__c;
            Date endDate = parentQuotes.get(lineItem.QuoteId).Proposed_End_Date__c;

            Integer rateIndex = 0;
            Decimal totalDurationInYears = relatedRateIncreases.isEmpty()?-1:relatedRateIncreases[rateIndex].Duration_Years__c;
            Decimal totalDurationInYearsSoFar = 0;

            Boolean normalQuoteLineProcessed = false;
            Integer currentRevision = 0;
            Decimal lastOfferPrice = lineItem.Offer_Price__c;
            Decimal lastBestRate = lineItem.Best_Rate__c;
            while (startDate < endDate) {
                // Calculate end date of current revision
                Integer daysBetween = startDate.daysBetween(endDate);
                Date revisionEndDate;
                if (daysBetween<365) {
                    revisionEndDate = startDate.addDays(daysBetween);
                } else {
                    revisionEndDate = startDate.addMonths(12).addDays(-1);
                }

                // Clone line item
                QuoteLineItem quoteLineItem = lineItem.clone(!normalQuoteLineProcessed, true, false, false);
                quoteLineItem.Start_Date__c = startDate;
                quoteLineItem.End_Date__c = revisionEndDate;
                quoteLineItem.Revision_Number__c = currentRevision;
                quoteLineItem.Quote_Revision__c = relatedQuoteRevisions.get(quoteLineItem.QuoteId).get(currentRevision).Id;
                if (!normalQuoteLineProcessed) {
                    normalQuoteLineProcessed = true;
                } else {
                    quoteLineItem.Type__c = TYPE_REVISION;
                    quoteLineItem.Parent_Quote_Line_Item__c = lineItem.Id;

                    // Calculate new rate based on rate increase
                    Decimal percentIncrease = relatedRateIncreases.isEmpty()?0:relatedRateIncreases[rateIndex].Percent_Increase__c;
                    Decimal newOfferPrice = (lastOfferPrice * (1+(percentIncrease/100))).setScale(2);
                    Decimal newBestRate = (lastBestRate * (1+(percentIncrease/100))).setScale(2);

                    // Check new rate is not over Rate Cap
                    if (priceSchedule.Rate_Cap__c != null) {
                        if (newOfferPrice > priceSchedule.Rate_Cap__c) {
                            newOfferPrice = priceSchedule.Rate_Cap__c;
                        }
                        if (newBestRate > priceSchedule.Rate_Cap__c) {
                            newBestRate = priceSchedule.Rate_Cap__c;
                        }
                    }
                    quoteLineItem.Offer_Price__c = newOfferPrice;
                    quoteLineItem.Best_Rate__c = newBestRate;
                }
                revisionLineItems.add(quoteLineItem);

                // Update variables to move to the next revision period
                totalDurationInYearsSoFar++;
                system.debug('totalDurationInYearsSoFar------:'+totalDurationInYearsSoFar);
                system.debug('totalDurationInYears------:'+totalDurationInYears);
                system.debug('relatedRateIncreases------:'+relatedRateIncreases);
                 system.debug('rateIndex------:'+rateIndex);
                if (totalDurationInYearsSoFar == totalDurationInYears && relatedRateIncreases.size()>rateIndex+1 ) {
                    rateIndex++;
                    if (relatedRateIncreases[rateIndex].Duration_Years__c == -1) {
                        totalDurationInYears = -1;
                    } else {
                        totalDurationInYears+=relatedRateIncreases[rateIndex].Duration_Years__c;
                    }
                }
                /* Changes made by Sadiq Adesanya 19-08-19
                lastOfferPrice = quoteLineItem.Offer_Price__c;
                lastBestRate = quoteLineItem.Best_Rate__c;
        */
                lastOfferPrice = lineItem.Offer_Price__c;
                lastBestRate = lineItem.Best_Rate__c;
                
                if (daysBetween<365) {
                    startDate = revisionEndDate;
                } else {
                    startDate = startDate.addMonths(12);
                }
                currentRevision++;
            }
        }

        // Insert/update quote line items
        if(!revisionLineItems.isEmpty()) {
            upsert revisionLineItems;
        }

        return revisionLineItems;
    }

    /**
     * @method    : rollUpQuoteRevisions()
     * @description  : Method to roll up totals from quote line items to quote revisions
     * @return    : N/A
     * @params    : quoteRevisionIds - Quote Revision ids to recalculate
     */
    public static void rollUpQuoteRevisions(Set<Id> quoteRevisionIds){
        if (!quoteRevisionIds.isEmpty()) {
            System.debug('Rolling up to Quote Revisions...');
            Map<Id,Quote_Revision__c> quoteRevisions = new Map<Id, Quote_Revision__c>(
                [SELECT Total_Best_Rate__c, Total_Offered_Price__c FROM Quote_Revision__c WHERE Id IN :quoteRevisionIds]
            );

            // Initialise totals on quote revisions
            for (Quote_Revision__c revision : quoteRevisions.values()) {
                revision.Total_Best_Rate__c = 0;
                revision.Total_Offered_Price__c = 0;
            }

            // Query and process related quote line items
            for(QuoteLineItem lineItem : [SELECT Id, Quote_Revision__c, Total_Best_Rate__c, Total_Offered_Price__c FROM QuoteLineItem WHERE Quote_Revision__c IN :quoteRevisionIds]){
                Quote_Revision__c revision = quoteRevisions.get(lineItem.Quote_Revision__c);
                if(revision != NULL){
                    revision.Total_Best_Rate__c = revision.Total_Best_Rate__c + (lineItem.Total_Best_Rate__c!=null?lineItem.Total_Best_Rate__c:0);
                	revision.Total_Offered_Price__c = revision.Total_Offered_Price__c + (lineItem.Total_Offered_Price__c!=null?lineItem.Total_Offered_Price__c:0);
                }
            }

            update quoteRevisions.values();
        }
    }

}