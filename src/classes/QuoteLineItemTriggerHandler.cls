/**
 *  @description Trigger Handler for QuoteLineItem
 *
 *  2019-06-24  Patrick Duncan      First Version
 *  2019-07-17  Raza Khan           Update the DOA approvers after insert & update
 */
public with sharing class QuoteLineItemTriggerHandler {

    public static void handleBeforeInsert(List<QuoteLineItem> newList) {
        PricingUtils.checkDuplicateQLI(newList);
        PricingUtils.calculateQuoteLineItemTotals(newList);
        //PricingUtils.calculateGraceDiscountsAmount(newList);
        PricingUtils.calculateGraceDiscountsAmountOnUpdate(newList, null);
        
    }

    public static void handleBeforeUpdate(Map<Id,QuoteLineItem> oldMap, Map<Id,QuoteLineItem> newMap){
        //PricingUtils.checkDuplicateQLI(newMap.values());
        PricingUtils.calculateQuoteLineItemTotals(newMap.values());
        //PricingUtils.calculateGraceDiscountsAmount(newMap.values());
        PricingUtils.calculateGraceDiscountsAmountOnUpdate(newMap.values(), oldMap);
        DOAUtils.restrictUpdateUnderApproval(newMap, oldMap);
    }

    public static void handleBeforeDelete(Map<Id,QuoteLineItem> oldMap){
        GracePeriodUtility.handleQuoteLineItemDelete(oldMap);
        DOAUtils.restrictDeletionUnderApprovalLineItems(oldMap.values());
        BundleUtils.deleteNormalChildLineItems(oldMap);
        //PricingUtils.restrictDeletionRenewalExpansionLineItems(oldMap.values());
        
    }

    public static void handleAfterInsert(Map<Id,QuoteLineItem> newMap){
        QuotePriceManagement.handleQuoteLineItemInsert(newMap.values());
        QuoteRevisionCalculations.handleQuoteLineItemInsert(newMap);
        GracePeriodUtility.handleQuoteLineItemInsert(newMap);
        //PricingUtils.pricingScheduleRealTimeCalculation(newMap);

        // DO NOT UNCOMMENT!!
        // THIS FUNCTION IS NOT EFFICIENT AND ALWAYS UPDATES QUOTES EVEN WHEN NOT NEEDED
        PricingUtils.checkToPopulatePaymentTermOnQuote(newMap.values(), null);

        Set<Id> quoteIds = new Set<Id>();
        for(QuoteLineItem qLine : newMap.values()){
            quoteIds.add(qLine.QuoteId);
        }
        if(!quoteIds.isEmpty()){
            //Send quote lines to DDA
            //DDAIntegration.processLeaseItems(quoteIds);

            // populated DOA approvers on quote
            DOAUtils.populateApprover(quoteIds);
        }
    }

    public static void handleAfterUpdate(Map<Id,QuoteLineItem> oldMap, Map<Id,QuoteLineItem> newMap){
        QuotePriceManagement.handleQuoteLineItemUpdate(newMap, oldMap);
        QuoteRevisionCalculations.handleQuoteLineItemUpdate(oldMap, newMap);
        GracePeriodUtility.handleQuoteLineItemUpdate(oldMap,newMap);
        Set<Id> quoteIds = new Set<Id>();
        for(QuoteLineItem qLine : newMap.values()){
            quoteIds.add(qLine.QuoteId);
        }

        // 31/07/2019 - Adeel Ahmad, reinitialize approvers on quote if qli offer price gets updated
        SET<Id> updateableQuoteIds = new SET<Id>();
        for(QuoteLineItem qLine : newMap.values()){
            if(qLine.Offer_Price__c != oldMap.get(qLine.Id).Offer_Price__c){
                updateableQuoteIds.add(qLine.QuoteId);
            }
        }
        if(updateableQuoteIds.size() > 0){
            DOAUtils.populateApprover(updateableQuoteIds);
        }

        //Send quote lines to DDA
        if(!quoteIds.isEmpty()){
           // DDAIntegration.processLeaseItems(quoteIds);
        } 
        // populated DOA approvers on quote
        DOAUtils.updateDoAproversQli(newMap.values(),oldMap);

        // DO NOT UNCOMMENT!!
        // THIS FUNCTION IS NOT EFFICIENT AND ALWAYS UPDATES QUOTES EVEN WHEN NOT NEEDED
        PricingUtils.checkToPopulatePaymentTermOnQuote(newMap.values(), oldMap);

    }

    public static void handleAfterDelete(Map<Id,QuoteLineItem> oldMap){
        QuoteRevisionCalculations.handleQuoteLineItemDelete(oldMap);
        QuotePriceManagement.handleQuoteLineItemDelete(oldMap);
    }

    public static void handleAfterUndelete(Map<Id,QuoteLineItem> newMap){
        QuoteRevisionCalculations.handleQuoteLineItemInsert(newMap);
        GracePeriodUtility.handleQuoteLineItemInsert(newMap);
    }

}