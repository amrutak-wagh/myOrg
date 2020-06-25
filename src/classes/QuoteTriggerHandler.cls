/*
 * @Who   Patrick Duncan <patrick.duncan@weare4c.com>
 * @What  Trigger Handler for Quote
 * @When  24/6/2019
 * Update by : Raza khan (raza.khan@weare4c.com)
 * Dated: 17/6/2019
 * Description: Update the DOA approvers and inetegrate the approved quotes with yardi
 * Updated by: Raza - Dated: 29/07/2019
 * Update by : Raza - on the accepted status send the lease information to yardi
 * Description: 
 */
public with sharing class QuoteTriggerHandler {
    public static void handleBeforeUpdate( Map<Id, Quote> oldMap, Map<Id, Quote> newMap){
        DOAUtils.resetApprover(newMap.values(), oldMap);
    }

    public static void handleAfterUpdate(Map<Id,Quote> oldMap, Map<Id,Quote> newMap){
        QuotePriceManagement.handleQuoteUpdate(oldMap, newMap);
        QuoteRevisionCalculations.handleQuoteUpdate(oldMap, newMap);
        GracePeriodUtility.handleQuoteUpdate(oldMap,newMap);
       // DOAUtils.isApproverPopulationRequired(oldMap,newMap);
        QuoteSyncUtils.removeQuoteLineItemsOnUnsyncedQuote(newMap.values(), oldMap);
        SoftBookQuote.SoftBookQuote(newMap.values(), oldMap);
        QuoteTriggerHelper.isStatusDraft(newMap.values(), oldmap);
        // 31/07/2019 - Adeel - Ahmad
        QuoteTriggerHelper.reinitializeApprover(newMap.values(), oldmap);
        // Updated by Raza - send the lease the information to yardi
        //NewRenewIntegrationIntegrationUtil.sendApprovedQuote(newMap.values(),oldmap);
         // Updated by Raza - send the ccl signed lease the information to yardi
        //NewRenewIntegrationIntegrationUtil.sendCclSignedQuote(newMap.values(),oldmap);
        
    }
}