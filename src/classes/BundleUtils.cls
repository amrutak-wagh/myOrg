/*
 * @Who   Gen Estrada <genalyn.estrada@weare4c.com>
 * @What  Utility class for Bundle
 * @When  09/07/2019
 */
public with sharing class BundleUtils {
	public static final String TYPE_NORMAL = 'Normal';

	/**
    *  Deletes child records of Type Normal if the parent record has been deleted
    *
    *  @param  Map<Id,QuoteLineItem> oldMap   Trigger.old
    */
    public static void deleteNormalChildLineItems(Map<Id,QuoteLineItem> oldMap) {
		List<Id> parentQuoteIds = new List<Id>();

		// Get all parent IDs
		for (QuoteLineItem lineItem : oldMap.values()) {
			if (lineItem.Type__c == TYPE_NORMAL && String.isEmpty(lineItem.Parent_Quote_Line_Item__c)) {
				parentQuoteIds.add( String.valueOf(lineItem.Id).substring(0, 15));
			}
		}

		if (!parentQuoteIds.isEmpty()) {
			delete [
				SELECT Id
				FROM QuoteLineItem
				WHERE Parent_Quote_Line_Item__c IN :parentQuoteIds
				AND Id NOT IN :oldMap.keySet()
				AND Type__c = :TYPE_NORMAL
			];
		}

    }
}