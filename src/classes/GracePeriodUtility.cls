/*
 * @who   Patrick Duncan <patrick.duncan@weare4c.com>
 * @what  Auxiliary methods to calculate Grace Period records
 * @when  24/6/2019
*/
public with sharing class GracePeriodUtility {

	private static String TYPE_NORMAL = 'Normal';
	private static String TYPE_GRACE_PERIOD = 'Grace Period';

	/**
	 *  @description Function that processes new quote line items and creates grace period records for records
	 *  			 of type Normal
	 *  @param  newMap		Map of new quote line items
	 */
	public static void handleQuoteLineItemInsert(Map<Id,QuoteLineItem> newMap) {
		Set<Id> parentQuoteLineItemIds = new Set<Id>();
		for (QuoteLineItem item : newMap.values()) {
			if (item.Type__c == TYPE_NORMAL && item.Parent_Quote_Line_Item__c == null) {
				parentQuoteLineItemIds.add(item.Id);
			}
		}

		if (!parentQuoteLineItemIds.isEmpty()) {
			createGracePeriodLineItems(parentQuoteLineItemIds);
		}
	}

	/**
	 *  @description Function that processes updated quote line items, deletes existing grace period records
	 *				 and creates new grace period records if the Offered Price has changed
	 *  @param  oldMap		Map of old quote line items
	 *  		newMap		Map of new quote line items
	 */
	public static void handleQuoteLineItemUpdate(Map<Id,QuoteLineItem> oldMap, Map<Id,QuoteLineItem> newMap) {
		Set<Id> parentQuoteLineItemIds = new Set<Id>();
		for (Id quoteLineId : newMap.keySet()) {
			QuoteLineItem oldLineItem = oldMap.get(quoteLineId);
			QuoteLineItem newLineItem = newMap.get(quoteLineId);
			if (newLineItem.Type__c == TYPE_NORMAL &&
				newLineItem.Parent_Quote_Line_Item__c == null &&
				oldLineItem.Offer_Price__c != newLineItem.Offer_Price__c)
			{
				parentQuoteLineItemIds.add(quoteLineId);
			}
		}

		if (!parentQuoteLineItemIds.isEmpty()) {
			deleteRelatedGracePeriodLineItems(parentQuoteLineItemIds);
			createGracePeriodLineItems(parentQuoteLineItemIds);
		}
	}

	/**
	 *  @description Function that processes deleted quote line items and deletes related grace period records
	 *  @param  oldMap		Map of old quote line items
	 */
	public static void handleQuoteLineItemDelete(Map<Id,QuoteLineItem> oldMap) {
		// Only parent quote line items should be processed
		Set<Id> parentQuoteLineItemIds = new Set<Id>();
		for (QuoteLineItem item : oldMap.values()) {
			if (item.Type__c == TYPE_NORMAL && item.Parent_Quote_Line_Item__c == null) {
				parentQuoteLineItemIds.add(item.Id);
			}
		}

		if (!parentQuoteLineItemIds.isEmpty()) { 
			deleteRelatedGracePeriodLineItems(parentQuoteLineItemIds, oldMap.keySet());
        }
	}

	/**
	 *  @description Function that processes updated quotes, deletes existing grace period records
	 *				 and creates new grace period records if the proposed start/end dates or Grace Period has changed
	 *  @param  oldMap		Map of old quotes
	 *  		newMap		Map of new quotes
	 */
	public static void handleQuoteUpdate(Map<Id,Quote> oldMap, Map<Id,Quote> newMap) {
		Set<Id> updatedQuoteIds = new Set<Id>();
		for (Id quoteId : newMap.keySet()) {
			Quote oldQuote = oldMap.get(quoteId);
			Quote newQuote = newMap.get(quoteId);
			if (oldQuote.Grace_Period__c != newQuote.Grace_Period__c ||
				oldQuote.Grace_Period_Mechanism__c != newQuote.Grace_Period_Mechanism__c ||
				oldQuote.Grace_Period_Period__c != newQuote.Grace_Period_Period__c ||
				oldQuote.Proposed_Start_Date__c != newQuote.Proposed_Start_Date__c ||
				oldQuote.Proposed_End_Date__c != newQuote.Proposed_End_Date__c)
			{
				updatedQuoteIds.add(quoteId);
			}
		}

		if (!updatedQuoteIds.isEmpty()) {
			Map<Id,QuoteLineItem> quoteLineItems = new Map<Id, QuoteLineItem>([SELECT Id FROM QuoteLineItem WHERE Type__c = :TYPE_NORMAL AND QuoteId IN :updatedQuoteIds AND Parent_Quote_Line_Item__c = null]);
			deleteRelatedGracePeriodLineItems(quoteLineItems.keySet());
			createGracePeriodLineItems(quoteLineItems.keySet());
		}
	}

	/**
     *  @description Function that creates a grace period line item for each parent line item being inserted using fields on its Quote
     *  @param  quoteLineItems	Set of quote line item ids
     */
	public static void createGracePeriodLineItems(Set<Id> quoteLineItems){
		//Query for all the fields on the QuoteLineItem's related objects that are required
		List<QuoteLineItem> lineItems = [
			SELECT 	Id, Offer_Price__c, Product2.Unit__r.Transactional_Unit__c, PricebookEntryId, QuoteId, Type__c,
					Parent_Quote_Line_Item__c, UnitPrice, Product2Id, Best_Rate__c, Area__c, Start_Date__c, End_Date__c,
					Quote.Proposed_Start_Date__c, Quote.Proposed_End_Date__c, Transactional_Unit__c, Transaction_Unit__c,
					Grace_Period__c, Grace_Period_Format__c, Grace_Period_Mechanism__c,
					Quote.Grace_Period__c, Quote.Grace_Period_Period__c, Quote.Grace_Period_Mechanism__c
			FROM 	QuoteLineItem
			WHERE 	Id IN :quoteLineItems AND
					Offer_Price__c != null AND
					Quote.Proposed_Start_Date__c != null AND
					Quote.Proposed_End_Date__c != null AND
            		Quote.Type__c != 'Renewal'
		];

		Set<Id> quoteIds = new Set<Id>();
		for (QuoteLineItem item : lineItems) {
			quoteIds.add(item.QuoteId);
		}

		// Query quote revisions so grace period items are linked to them
		Map<Id, List<Quote_Revision__c>> quoteRevisionsByQuoteId = new Map<Id, List<Quote_Revision__c>>();
		for (Quote_Revision__c revision : [SELECT Quote__c, Start_Date__c, End_Date__c, Revision_Number__c FROM Quote_Revision__c WHERE Quote__c IN :quoteIds ORDER BY Revision_Number__c ASC]) {
			if (!quoteRevisionsByQuoteId.containsKey(revision.Quote__c)) {
				quoteRevisionsByQuoteId.put(revision.Quote__c, new List<Quote_Revision__c>());
			}
			quoteRevisionsByQuoteId.get(revision.Quote__c).add(revision);
		}

		// Generate grace period line items
		List<QuoteLineItem> newLineItems = new List<QuoteLineItem>();
		Set<Id> quoteRevisionsToRecalculate = new Set<Id>();
		for(QuoteLineItem lineItem : lineItems){
			if(lineItem.Type__c==TYPE_NORMAL){
				String mechanism = lineItem.Grace_Period_Mechanism__c!=null?lineItem.Grace_Period_Mechanism__c:lineItem.Quote.Grace_Period_Mechanism__c;
				String format = lineItem.Grace_Period_Format__c!=null?lineItem.Grace_Period_Format__c:lineItem.Quote.Grace_Period_Period__c;
				Decimal duration = lineItem.Grace_Period__c!=null?lineItem.Grace_Period__c:lineItem.Quote.Grace_Period__c;

				if (String.isBlank(mechanism) || String.isBlank(format) || duration == null || duration == 0) {
					continue;
				}

				//For each parent line item being inserted create a grace period line item
				QuoteLineItem newLineItem = lineItem.clone(false, true);
				newLineItem.Quantity = 1;
				newLineItem.Offer_Price__c=lineItem.Offer_Price__c!=null?-lineItem.Offer_Price__c:0;
				newLineItem.Best_Rate__c=lineItem.Best_Rate__c!=null?-lineItem.Best_Rate__c:0;
				newLineItem.Type__c=TYPE_GRACE_PERIOD;
				newLineItem.Parent_Quote_Line_Item__c=lineItem.Id;
                newLineItem.Charge_Type__c = TYPE_GRACE_PERIOD;
				if(mechanism=='initial'){
					newLineItem.Start_Date__c = lineItem.Quote.Proposed_Start_Date__c;
					if(format=='days'){
						newLineItem.End_Date__c = lineItem.Quote.Proposed_Start_Date__c.addDays((Integer)duration - 1);
					}
					else if(format=='months'){
						newLineItem.End_Date__c = lineItem.Quote.Proposed_Start_Date__c.addMonths((Integer)duration - 1);
					}
				}
				else if(mechanism=='end'){
					newLineItem.End_Date__c = lineItem.Quote.Proposed_End_Date__c;
					if(format=='days'){
						newLineItem.Start_Date__c = lineItem.Quote.Proposed_End_Date__c.addDays((Integer)-duration + 1);
					}
					else if(format=='months'){
						newLineItem.Start_Date__c = lineItem.Quote.Proposed_End_Date__c.addMonths((Integer)-duration + 1);
					}
				}

				// Find quote revision
				if (quoteRevisionsByQuoteId.containsKey(lineItem.QuoteId)) {
					for (Quote_Revision__c revision : quoteRevisionsByQuoteId.get(lineItem.QuoteId)) {
						if (revision.Start_Date__c <= newLineItem.Start_Date__c && newLineItem.Start_Date__c < newLineItem.End_Date__c) {
							newLineItem.Quote_Revision__c = revision.Id;
							newLineItem.Revision_Number__c = revision.Revision_Number__c;
							quoteRevisionsToRecalculate.add(revision.Id);
							break;
						}
					}
				}

				newLineItems.add(newLineItem);
			}
		}

		if(!newLineItems.isEmpty()){
			System.debug('Generating Grace Periods - ' + newLineItems.size());
			insert newLineItems;
		}

		if (!quoteRevisionsToRecalculate.isEmpty()) {
			QuoteRevisionCalculations.rollUpQuoteRevisions(quoteRevisionsToRecalculate);
		}
		List<Grace_Period__c> existingGracePeriodList = new List<Grace_Period__c>();
        existingGracePeriodList = [SELECT Id FROM Grace_Period__c WHERE Quote__r.Id IN :quoteIds];
        Set<Id> gpIdSet = new Set<Id>();
        for(Grace_Period__c gp : existingGracePeriodList){
            gpIdSet.add(gp.Id);
        }
        if(!gpIdSet.isEmpty())
            createGraceGracePeriodLineItems(gpIdSet);
	}
	
	/**
     *  @description Function that finds all the child line items of each parent and deletes them
     *  @param  parentQuoteLineItemIds	Set of quote line item ids
     */
	public static void deleteRelatedGracePeriodLineItems(Set<Id> parentQuoteLineItemIds){
		delete [SELECT Id FROM QuoteLineItem WHERE Parent_Quote_Line_Item__c IN :parentQuoteLineItemIds AND Type__c = :TYPE_GRACE_PERIOD];
	}

	public static void deleteRelatedGracePeriodLineItems(Set<Id> parentQuoteLineItemIds, Set<Id> idsToExclude){
		delete [SELECT Id FROM QuoteLineItem WHERE Parent_Quote_Line_Item__c IN :parentQuoteLineItemIds AND Type__c = :TYPE_GRACE_PERIOD AND Id NOT IN :idsToExclude];
	}
    
    public static void createGraceGracePeriodLineItems(Set<Id> gracePeriodIdSet){
        List<QuoteLineItem> qliToInsert = new List<QuoteLineItem>();
        List<QuoteLineItem> newLineItems = new List<QuoteLineItem>();
        Set<Id> quoteRevisionsToRecalculate = new Set<Id>();
        Set<Id> quoteIdSet = new Set<Id>();
        Map<Id, List<Quote_Revision__c>> quoteRevisionsByQuoteId = new Map<Id, List<Quote_Revision__c>>();
        Map<Id,List<QuoteLineItem>> quoteIdQuoteLineItemMap = new Map<Id,List<QuoteLineItem>>();
        
        List<Grace_Period__c> gracePeriodList = [SELECT   Id
                                                 		, Start_Date__c
                                                 		, Duration__c
                                                 		, Period__c
                                                 		, Quote__r.Id 
                                                 FROM  Grace_Period__c 
                                                 WHERE Id IN :gracePeriodIdSet];
        
        
        for(Grace_Period__c gp : gracePeriodList){
            quoteIdSet.add(gp.Quote__r.Id);
        }
        
        List<QuoteLineItem> normalQuoteLineItemList = [SELECT    Id, Quote.Proposed_Start_Date__c, Grace_Period_Format__c
                                                               , Offer_Price__c, UnitPrice, Grace_Period__c
                                                               , Product2.Unit__r.Transactional_Unit__c, Product2Id, Quote.Grace_Period__c
                                                               , PricebookEntryId, Best_Rate__c, Grace_Period_Mechanism__c
                                                               , QuoteId, Area__c, Quote.Proposed_End_Date__c
                                                               , Type__c, End_Date__c, Transactional_Unit__c
                                                               , Parent_Quote_Line_Item__c, Start_Date__c,Transaction_Unit__c
                                                               , Quote.Grace_Period_Period__c, Quote.Grace_Period_Mechanism__c
                                                       FROM  QuoteLineItem
                                                       WHERE QuoteId IN :quoteIdSet
                                                       AND   Type__c = 'Normal'
                                                       AND 	 Parent_Quote_Line_Item__c = NULL];
        
        
        for(QuoteLineItem qli : normalQuoteLineItemList){
            if(!quoteIdQuoteLineItemMap.containsKey(qli.QuoteId)){
                quoteIdQuoteLineItemMap.put(qli.QuoteId,new List<QuoteLineItem>{qli});
            }else{
                quoteIdQuoteLineItemMap.get(qli.QuoteId).add(qli);
            }
        }
        
		for (Quote_Revision__c revision : [SELECT 	Quote__c, Start_Date__c
                                           		  , End_Date__c, Revision_Number__c 
                                           FROM Quote_Revision__c 
                                           WHERE Quote__c IN :quoteIdQuoteLineItemMap.keyset() ORDER BY Revision_Number__c ASC]) {
			if (!quoteRevisionsByQuoteId.containsKey(revision.Quote__c)) {
				quoteRevisionsByQuoteId.put(revision.Quote__c, new List<Quote_Revision__c>());
			}
			quoteRevisionsByQuoteId.get(revision.Quote__c).add(revision);
		}
        for(QuoteLineItem qli : normalQuoteLineItemList){
            QuoteLineItem newLineItem = qli.clone(false, true);
            newLineItem.Quantity = 1;
            newLineItem.Offer_Price__c=qli.Offer_Price__c!=null?-qli.Offer_Price__c:0;
            newLineItem.Best_Rate__c=qli.Best_Rate__c!=null?-qli.Best_Rate__c:0;
            newLineItem.Type__c=TYPE_GRACE_PERIOD;
            newLineItem.Parent_Quote_Line_Item__c=qli.Id;
            if (quoteRevisionsByQuoteId.containsKey(qli.QuoteId)) {
                for (Quote_Revision__c revision : quoteRevisionsByQuoteId.get(qli.QuoteId)) {
                    if (revision.Start_Date__c <= newLineItem.Start_Date__c && newLineItem.Start_Date__c < newLineItem.End_Date__c) {
                        newLineItem.Quote_Revision__c = revision.Id;
                        newLineItem.Revision_Number__c = revision.Revision_Number__c;
                        quoteRevisionsToRecalculate.add(revision.Id);
                        break;
                    }
                }
            }
            newLineItems.add(newLineItem);
        }
        for(Grace_Period__c gp : gracePeriodList){
            if(quoteIdQuoteLineItemMap.containsKey(gp.Quote__r.Id)){
                    String format = gp.Period__c != NULL ? gp.Period__c : '';
					Decimal duration = gp.Duration__c != NULL ? gp.Duration__c : NULL;
                    if(String.isBlank(format) || duration == NULL || gp.Start_Date__c == NULL || duration == 0){
                        continue;
                    }
                    for(QuoteLineItem qli : newLineItems){
                        QuoteLineItem qliWithGPDetails = qli;
                        qliWithGPDetails.Related_Grace_Period__c = gp.Id;
                        qliWithGPDetails.Start_Date__c = gp.Start_Date__c;
                        if(format == 'days'){
                            qliWithGPDetails.End_Date__c = gp.Start_Date__c.addDays((Integer)duration - 1);
                        }else if(format == 'months'){
                            qliWithGPDetails.End_Date__c = gp.Start_Date__c.addMonths((Integer)duration - 1);
                        }
                        qliToInsert.add(qliWithGPDetails);
                    }
            }
        }
        if(!qliToInsert.isEmpty()){
			System.debug('Generating Grace Periods - ' + qliToInsert.size());
			insert qliToInsert;
		}

		if (!quoteRevisionsToRecalculate.isEmpty()) {
			QuoteRevisionCalculations.rollUpQuoteRevisions(quoteRevisionsToRecalculate);
		}
    }
	
    public static void deleteQLIonGracePeriodDeletion(Set<Id> gracePeriodIdSet){
        delete [SELECT Id FROM QuoteLineItem WHERE Related_Grace_Period__r.Id IN :gracePeriodIdSet];
    }
}