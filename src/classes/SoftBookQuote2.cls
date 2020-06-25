/*
 * @Who   Divya Chary <divya.chary@weare4c.com>
 * @What  Utility Class to soft book units, and mark other Quotes as Cancelled
 * @When  17/7/2019
 */
 //Needs to be without sharing since as a result, other quotes can be cancelled
 public without sharing class SoftBookQuote2 {
      public static void softBookQuote(List<Quote> lstQuoteRecords, Map<Id, Quote> mapOldQuoteRecords){
          //Fetch the list of Quote Ids that were not soft booked in the past.
          List<Id> lstQuoteId = new List<Id>();
          Set<Id> setOpptyId = new Set<Id>();
            for(Quote oQuote : lstQuoteRecords) {
                Boolean bQuoteSoftBooked = oQuote.Soft_Book__c && !mapOldQuoteRecords.get(oQuote.Id).Soft_Book__c;
                if(oQuote.Soft_Book__c && !mapOldQuoteRecords.get(oQuote.Id).Soft_Book__c) {
                    lstQuoteId.add(oQuote.Id);
                    setOpptyId.add(oQuote.OpportunityId);
                }
            }
            //Using the Quote Ids, fetch the Unit__c and Product2 information into separate lists
            map<Id,List<product2>> mapIdVsProduct = new Map<Id,List<Product2>>();
            List<QuoteLineItem> lstLineItem = new List<QuoteLineItem>();
            Set<Product2> setProduct = new Set<Product2>();
            Set<Unit__c> setUnit = new Set<Unit__c>();
            List<Product2> lstProduct= new List<Product2>();
            List<Unit__c> lstUnit = new List<Unit__c>();
            if(lstQuoteId.size()>0){
                lstLineItem=[SELECT Id,Product2.Id,Product2.Quote__C,Product2.Status__c,Product2.Unit__c FROM QuoteLineItem WHERE QuoteId in:lstQuoteId];
            }
            //Loop over line items to fetch the products and units
            for(QuoteLineItem oItem :lstLineItem){
                if(mapIdVsProduct!=NULL && mapIdVsProduct.get(oItem.Id)!=NULL){
                    List<Product2> lstProd2=mapIdVsProduct.get(oItem.Id);
                    lstProd2.add(oItem.Product2);
                    mapIdVsProduct.put(oItem.Id,lstProd2);
                }
                ELSE{
                    List<Product2> lstProd2= new List<Product2>();
                    lstProd2.add(oItem.Product2);
                    mapIdVsProduct.put(oItem.Id,lstProd2);
                }
                setProduct.add(new Product2 (Id=oItem.Product2Id, Status__c = 'Soft Booked'));
                setUnit.add(new Unit__c(Id=oItem.Product2.Unit__C, Status__c= 'Soft Booked'));
            }
            //Typecasting to a List, to be optimised
            lstProduct.addAll(setProduct);
            lstUnit.addAll(setUnit);
            //Update Products and Units
            if(!lstProduct.isEmpty()) update lstProduct;
            if(!lstUnit.isEmpty()) update lstUnit;
            //Query Quote Lines that have same product but different Quote Status
            List<QuoteLineItem> lstItemsToUpdate = new List<QuoteLineItem>();
            lstItemsToUpdate = [Select Id, QuoteId,Quote.Opportunityid, Quote.Status,Quote.Cancellation_Reason__C From QuoteLineItem Where Product2.Unit__c IN :lstUnit and QuoteId Not IN :lstQuoteRecords AND Quote.Status='Draft'AND Quote.OpportunityId NOT IN :setOpptyId];
            List<Quote> lstQuoteToUpdate = new List<Quote>();
            Set<Quote> SetQuoteToUpdate = new Set<Quote>();
            for(QuoteLineItem oItem : lstItemsToUpdate){
                SetQuoteToUpdate.add(new Quote (Id=oItem.QuoteId, Status = 'Cancelled',Cancellation_Reason__c='Product Unavailable'));    
            }
            lstQuoteToUpdate.addAll(SetQuoteToUpdate);
            if(!lstQuoteToUpdate.isEmpty()) update lstQuoteToUpdate;
      }
 }