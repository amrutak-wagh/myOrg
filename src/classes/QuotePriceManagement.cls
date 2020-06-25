public class QuotePriceManagement {

    public static final String TYPE_NORMAL = 'Normal';
    
    /**
    * @method	: handleQuoteUpdate()
    * @description	: Method to handle changes made on the quote object
    * @return	: N/A
    * @params	: oldMap - old quote version
    * newMap - version of quote containing changed values
    */
    public static void handleQuoteUpdate(Map<Id,Quote> oldMap, Map<Id,Quote> newMap) {
        Set<Id> parentQuoteIds = new Set<Id>();
        Map<Id, Quote> parentQuoteCalculationIdsMap = new Map<Id, Quote>();
        for(Quote loopQuote : newMap.values()) {
            if(loopQuote.Proposed_Start_Date__c != oldMap.get(loopQuote.Id).Proposed_Start_Date__c ||
            	loopQuote.Proposed_End_Date__c != oldMap.get(loopQuote.Id).Proposed_End_Date__c) {
            	parentQuoteIds.add(loopQuote.Id);
            }
            if(loopQuote.Grace_Period__c != oldMap.get(loopQuote.Id).Grace_Period__c ||
               loopQuote.Grace_Period_Period__c != oldMap.get(loopQuote.Id).Grace_Period_Period__c) {
               		parentQuoteCalculationIdsMap.put(loopQuote.Id, loopQuote);
            }
        }
        if(!parentQuoteIds.isEmpty()) {
        
            // Get Quote Line Item for related changed Quote to calculate new price rule for them.
            Map<Id, QuoteLineItem> rentLineItemsByIds = new Map<Id, QuoteLineItem>([
                                        SELECT Start_Date__c, Product2Id, Transactional_Unit__c, Transaction_Type__c,
                                        PricebookEntryId, UnitPrice, Area__c, QuoteId, Parent_Quote_Line_Item__c,
                                        End_Date__c, Quote.Proposed_Start_Date__c, Quote.Proposed_End_Date__c, Price_Schedule__c
                                        FROM QuoteLineItem
                                        WHERE QuoteId IN: parentQuoteIds
                                        AND Type__c = :TYPE_NORMAL
                                        AND Parent_Quote_Line_Item__c = null
            ]);
        
            if(!rentLineItemsByIds.isEmpty()) {
                // Delete all quote line items except Rent
                delete [SELECT Id FROM QuoteLineItem WHERE QuoteId IN :parentQuoteIds AND Parent_Quote_Line_Item__c != null AND Type__c = :TYPE_NORMAL];
                
                // Reset Price Schedule on Rent qlis
                for(QuoteLineItem rentLineItem : rentLineItemsByIds.values()) {
                    rentLineItem.Price_Schedule__c = null;
                }
                // Update Rent QLI to assign new price rule with updated values.
                try {
                    update rentLineItemsByIds.values();
                }
                catch(Exception ex) {
                    if(ex.getMessage().contains(System.Label.Rate_Of_Mechanism_Blank_Error)) {
                        throw new RateValidationException(System.Label.Rate_Of_Mechanism_Blank_Error);
                    }
                    else {
                       throw new RateValidationException(ex.getMessage());
                    }
                    
                }
            }
    	}
        
        if(!parentQuoteCalculationIdsMap.isEmpty()) {
            
            calculateGraceDiscountsAmountForQuoteUpdate(parentQuoteCalculationIdsMap);
        }
        
    }
    
    /**
    * @method	: handleQuoteLineItemUpdate()
    * @description	: Method to handle changes made on the quote line item object.
    * @return	: N/A
    * @params	: newMap - New quote version
    *             oldMap - Old Quote Version
    */
    public static void handleQuoteLineItemUpdate(Map<Id, QuoteLineItem> newMap, Map<Id, QuoteLineItem> oldMap) {
        
        List<QuoteLineItem> quoteLineItemList = new List<QuoteLineItem>();
        for(QuoteLineItem qliObj : newMap.values()) {
            if(oldMap.get(qliObj.Id).Price_Schedule__c != null &&
               String.isBlank(qliObj.Price_Schedule__c) &&
               String.isBlank(qliObj.Parent_Quote_Line_Item__c)) {
                quoteLineItemList.add(qliObj);
            }
        }
        
        if(!quoteLineItemList.isEmpty())
            PricingUtils.pricingScheduleRealTimeCalculation(new Map<Id, QuoteLineItem> (quoteLineItemList));
        
    }
    
    /**
    * @method	: handleQuoteLineItemInsert()
    * @description	: Method to handle insert on the quote line item.
    * @return	: N/A
    * @params	: newList - New quote version
    */
    public static void handleQuoteLineItemInsert(List<QuoteLineItem> newList) {
        
        List<QuoteLineItem> quoteLineItemList = new List<QuoteLineItem>();
        for(QuoteLineItem qliObj : newList) {
            if(String.isBlank(qliObj.Price_Schedule__c) &&
               String.isBlank(qliObj.Parent_Quote_Line_Item__c)) {
                quoteLineItemList.add(qliObj);
            }
        }
        
        if(!quoteLineItemList.isEmpty())
            PricingUtils.pricingScheduleRealTimeCalculation(new Map<Id, QuoteLineItem> (quoteLineItemList));
        
    }
    
   /**
    * @method	: handleQuoteLineItemInsert()
    * @description	: Method to handle delete on the quote line item.
    * @return	: N/A
    * @params	: oldMap - old quote version
    */
    public static void handleQuoteLineItemDelete( Map<Id, QuoteLineItem> oldMap) {
        
        Set<Id> quoteLineItemIds = new Set<Id>();
        for (QuoteLineItem item : oldMap.values()) {
			if (item.Type__c == TYPE_NORMAL && item.Parent_Quote_Line_Item__c == null) {
                quoteLineItemIds.add(item.QuoteId);
			}
		}

        if(!quoteLineItemIds.isEmpty()) {
            
             // Get Quote Line Item for related changed Quote to calculate new price rule for them.
            Map<Id, QuoteLineItem> rentLineItemsByIds = new Map<Id, QuoteLineItem>([
                SELECT Start_Date__c, Product2Id, Transactional_Unit__c, Transaction_Type__c,
                PricebookEntryId, UnitPrice, Area__c, QuoteId, Parent_Quote_Line_Item__c,
                End_Date__c, Quote.Proposed_Start_Date__c, Quote.Proposed_End_Date__c, Price_Schedule__c
                FROM QuoteLineItem
                WHERE QuoteId IN: quoteLineItemIds
                AND Type__c = :TYPE_NORMAL
                AND Parent_Quote_Line_Item__c = null
            ]);
            
            if(!rentLineItemsByIds.isEmpty()) {
                // Delete all quote line items except Rent
                delete [SELECT Id FROM QuoteLineItem WHERE QuoteId IN: quoteLineItemIds AND Parent_Quote_Line_Item__c != null AND Type__c = :TYPE_NORMAL];
                
                // Reset Price Schedule on Rent qlis
                for(QuoteLineItem rentLineItem : rentLineItemsByIds.values()) {
                    rentLineItem.Price_Schedule__c = null;
                }
               //Update Rent QLI to assign new price rule with updated values.
               update rentLineItemsByIds.values();
        	}
        }
    }
    
    /**
    * @method	: calculateGraceDiscountsAmountForQuoteUpdate()
    * @description	: Method to calculate discount fields on change in quote record.
    * @return	: N/A
    * @params	: quoteMap - new quote version
    */
    public static void calculateGraceDiscountsAmountForQuoteUpdate(Map<Id, Quote> quoteMap) {
        
        List<QuoteLineItem> quoteLineItemList = [SELECT Id, Total_Offered_Price__c, Price_Schedule__c, Default_Grace_Period__c, QuoteId 
                                                 FROM QuoteLineItem
                                                 WHERE QuoteId IN : quoteMap.keySet()
                                                ];
        
        for(QuoteLineItem qliObj : quoteLineItemList) {

            Decimal defaultGPDiscountAmount = 0.0;
            Decimal additionalGPDiscountAmount = 0.0;
            Quote quoteObj = quoteMap.get(qliObj.QuoteId);
            if(quoteObj.Grace_Period__c == null || qliObj.Total_Offered_Price__c == null || qliObj.Price_Schedule__c == null ||
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
        update quoteLineItemList;
    }
    
    public class RateValidationException extends Exception{}
}