/*
 * @Who   Divya Chary <divya.chary@weare4c.com>
 * @What  Utility Class to soft book units, and mark other Quotes as Cancelled
 * @When  17/7/2019
 */
//Needs to be without sharing since as a result, other quotes can be cancelled
public without sharing class SoftBookQuote {
    public static void softBookQuote(List<Quote> lstQuoteRecords, Map<Id, Quote> mapOldQuoteRecords){
        //Fetch the list of Quote Ids that were not soft booked in the past.
        Set<Id> quoteIds = new Set<Id>();
        Set<Id> opportunityIds = new Set<Id>();
        for(Quote oQuote : lstQuoteRecords) {
            if(oQuote.Soft_Book__c && !mapOldQuoteRecords.get(oQuote.Id).Soft_Book__c) {
                quoteIds.add(oQuote.Id);
                opportunityIds.add(oQuote.OpportunityId);
            }
        }

        //Using the Quote Ids, fetch the Unit__c and Product2 information into separate lists
        if(quoteIds.size()>0){
            List<QuoteLineItem> lstLineItem = [SELECT Id, Product2Id, Product2.Unit__c, QuoteId FROM QuoteLineItem WHERE QuoteId IN :quoteIds];

            //Loop over line items to fetch the products and units
            Set<Product2> setProduct = new Set<Product2>();
            Set<Unit__c> setUnit = new Set<Unit__c>();
            for(QuoteLineItem oItem :lstLineItem){
                setProduct.add(new Product2 (Id=oItem.Product2Id,Quote__c=oItem.QuoteId,Status__c='Soft Booked'));
                setUnit.add(new Unit__c(Id=oItem.Product2.Unit__c, Status__c='Soft Booked'));
            }

            //Typecasting to a List, to be optimised
            List<Product2> lstProduct= new List<Product2>();
            lstProduct.addAll(setProduct);

            List<Unit__c> lstUnit = new List<Unit__c>();
            lstUnit.addAll(setUnit);

            //Update Products and Units
            if(!lstProduct.isEmpty()) update lstProduct;
            if(!lstUnit.isEmpty()) update lstUnit;

            //Query Quote Lines that have same product but different Quote Status
            List<QuoteLineItem> lstItemsToUpdate = [
                    SELECT Id, QuoteId, Quote.OpportunityId, Quote.Status, Quote.Cancellation_Reason__c
                    FROM QuoteLineItem
                    WHERE Product2.Unit__c IN :lstUnit
                    AND QuoteId NOT IN :lstQuoteRecords
                    AND Quote.Status='Draft'
                    AND Quote.OpportunityId NOT IN :opportunityIds
                	AND (Quote.IsSyncing = TRUE OR Quote.Opportunity.SyncedQuoteId = NULL)
            ];
            Set<Quote> SetQuoteToUpdate = new Set<Quote>();
            for(QuoteLineItem oItem : lstItemsToUpdate){
                SetQuoteToUpdate.add(new Quote (Id=oItem.QuoteId, Status = 'Cancelled',Cancellation_Reason__c='Product Unavailable'));
            }
            List<Quote> lstQuoteToUpdate = new List<Quote>();
            lstQuoteToUpdate.addAll(SetQuoteToUpdate);
            if(!lstQuoteToUpdate.isEmpty()) update lstQuoteToUpdate;
        }
    }
}