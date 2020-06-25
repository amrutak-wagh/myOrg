/*
 * @Who   Cameron Stewart <cameron.stewart@weare4c.com>
 * @What  Utils to handle deleting quote line items when a quote is unsynced
 * @When  24/6/2019
 */
public class QuoteSyncUtils {
    public static void removeQuoteLineItemsOnUnsyncedQuote(List<Quote> quoteRecords, Map<Id, Quote> oldQuoteRecords) {
        List<Quote> quoteRecordsToProcess = new List<Quote>();
        
        for(Quote quoteRecord : quoteRecords) {
            system.debug('oldQuoteRecords.get(quoteRecord.Id).IsSyncing--------'+oldQuoteRecords.get(quoteRecord.Id).IsSyncing);
         system.debug('quoteRecord.IsSyncing--------'+quoteRecord.IsSyncing);
            if(oldQuoteRecords.get(quoteRecord.Id).IsSyncing && !quoteRecord.IsSyncing) {
                quoteRecordsToProcess.add(quoteRecord);
            }
        }
        
        if(!quoteRecordsToProcess.isEmpty()) {
            removeQuoteLineItemsOnUnsyncedQuote(quoteRecordsToProcess);
        }
    }
    
    public static void removeQuoteLineItemsOnUnsyncedQuote(List<Quote> quoteRecords) {
        Set<Id> opportunityIdsToRemoveLineItems = new Set<Id>();
        for(Quote quoteRecord : quoteRecords) {
            if(!quoteRecord.IsSyncing) {
                opportunityIdsToRemoveLineItems.add(quoteRecord.OpportunityId);
            }
        }
        
        if(!opportunityIdsToRemoveLineItems.isEmpty()) {
            delete [SELECT Id From OpportunityLineItem WHERE OpportunityId IN :opportunityIdsToRemoveLineItems];
        }
    }
}