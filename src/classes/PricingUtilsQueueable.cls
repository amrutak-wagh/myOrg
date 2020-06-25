public class PricingUtilsQueueable implements Queueable {
	Set<Id> quoteLineItemSet = new Set<Id>();
    public PricingUtilsQueueable(Set<Id> quoteLineItemSet){
        this.quoteLineItemSet = quoteLineItemSet;
    }
    public void execute(QueueableContext context) {
         populatePaymentTermOnQuote(quoteLineItemSet);       
    }
    public static void populatePaymentTermOnQuote(Set<Id> quoteLineItemSet) {
        
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
}