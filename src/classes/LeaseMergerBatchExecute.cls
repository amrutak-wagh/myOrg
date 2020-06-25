public class LeaseMergerBatchExecute {
    @InvocableMethod
    public static void executeBatch(List<Id> requiredIds){
        String renewalOppId =  requiredIds[0];
        System.debug('requiredIds[0]-----'+requiredIds[0]);
        List<Opportunity> renewalOppList = [SELECT Name,Parent_Opportunity__r.Id,(Select Id From Quotes) FROM Opportunity WHERE Id = :renewalOppId];
        System.debug('renewalOppList[0]-----'+renewalOppList[0]);
        String parentOppId = renewalOppList[0].Parent_Opportunity__r.Id;
        System.debug('renewalOppList[0].Parent_Opportunity__r.Id-----'+renewalOppList[0].Parent_Opportunity__r.Id);
        Opportunity opp = renewalOppList[0];
        String quoteId = opp.Quotes[0].Id;
        System.debug('quoteId-----'+quoteId);
        String oppQuery = 'SELECT Id, Name, Type, Lease_End_Date__c,SyncedQuoteId, Lease_Type__c,Lease_Start_Date__c,CloseDate, ContactId,Opportunity_Type__c,' +
            			  'StageName,Parent_Amendment_Id__c,T_Code__c, AccountId, CurrencyIsoCode, Business_Park__c, Sub_Type__c, Parent_Opportunity__c,Building_Name__c,' +
            			  '(SELECT Id, Name, Type, Lease_End_Date__c, Lease_Start_Date__c,CloseDate, SyncedQuoteId,ContactId, StageName,' +
            			  'AccountId, CurrencyIsoCode, Business_Park__c, Sub_Type__c, Parent_Opportunity__c,Building_Name__c FROM Opportunities__r WHERE StageName =\'Active\')'+ 
            			  ' FROM Opportunity WHERE  Id =:parentOppId';
        List<Opportunity> qualifiedChildOppLst = new List<Opportunity>();
        Set<Id> syncedQuoteIdSet = new Set<Id>();
        System.debug('oppQuery-----'+oppQuery);
        List<Opportunity> listOpp = Database.query(oppQuery);
        System.debug('listOpp-----'+listOpp);
        if(!listOpp.isEmpty() && listOpp[0] != Null){
            Opportunity parentOppObj = listOpp[0];
            System.debug('parentOppObj-----'+parentOppObj);
            System.debug('listOpp[0].Opportunities__r-----'+listOpp[0].Opportunities__r);
            if(listOpp[0].Opportunities__r.size() > 0){
                for(Opportunity childOppObj : listOpp[0].Opportunities__r) {
                   if(childOppObj.Lease_End_Date__c == parentOppObj.Lease_End_Date__c 
                       && childOppObj.Building_Name__c == parentOppObj.Building_Name__c
                       && childOppObj.AccountId == parentOppObj.AccountId){
                           qualifiedChildOppLst.add(childOppObj);
                           System.debug('Here-----');
                           syncedQuoteIdSet.add(childOppObj.SyncedQuoteId);   
                       }
                }
            }
            syncedQuoteIdSet.add(parentOppObj.SyncedQuoteId);
        }
        System.debug('syncedQuoteIdSet-----'+syncedQuoteIdSet);
        List<QuoteLineItem> lineItemsLst = [SELECT   Id
                                            	   , UnitPrice 
                                                   , QuoteId 
                                                   , Transaction_Type__c 
                                                   , Start_Date__c
                                                   , End_Date__c
                                                   , Quantity
                                                   , Product2Id
                                                   , PricebookEntryId
                                            	   , Transactional_Unit__c
                                                   , Area__c
                                             FROM  QuoteLineItem
                                             WHERE QuoteId IN: syncedQuoteIdSet AND
                                             Type__c = 'Normal' AND Parent_Quote_Line_Item__c = NULL];
        System.debug('lineItemsLst-----'+lineItemsLst);
        List<QuoteLineItem> parentsQLILst = new List<QuoteLineItem>();
        
        for(QuoteLineItem parentsQLIObj : lineItemsLst) {
            QuoteLineItem newQLI = new QuoteLineItem();
            newQLI.UnitPrice = parentsQLIObj.UnitPrice;
            newQLI.QuoteId = quoteId;
            newQLI.Transaction_Type__c = 'Renewal'; 
            newQLI.Start_Date__c = parentsQLIObj.Start_Date__c;
            newQLI.End_Date__c = parentsQLIObj.End_Date__c;
            newQLI.Quantity = parentsQLIObj.Quantity;
            newQLI.Product2Id = parentsQLIObj.Product2Id;
            newQLI.PricebookEntryId = parentsQLIObj.PricebookEntryId;
            newQLI.Transactional_Unit__c = parentsQLIObj.Transactional_Unit__c;
            newQLI.Area__c = parentsQLIObj.Area__c;
            parentsQLILst.add(newQLI);
        }
        
        if(!parentsQLILst.isEmpty()) {
                try{
                    System.debug('parents QLI inserted size=1==='+parentsQLILst.size());
                    insert parentsQLILst;
                    System.debug('parents QLI inserted size===='+parentsQLILst.size());
                    List<Opportunity_Junction__c> oppJuncList = new List<Opportunity_Junction__c>();
                    for(Opportunity childOpp : qualifiedChildOppLst){
                        Opportunity_Junction__c instance = new Opportunity_Junction__c();
                        instance.Name = renewalOppList[0].Name;
                        instance.Opportunity__c = renewalOppId;
                        instance.Opportunity_Lookup__c = childOpp.Id;
                        oppJuncList.add(instance);
                    }
                    Opportunity_Junction__c instance = new Opportunity_Junction__c();
                    instance.Name = renewalOppList[0].Name;
                    instance.Opportunity__c = renewalOppId;
                    instance.Opportunity_Lookup__c = parentOppId;
                    oppJuncList.add(instance);
                    insert oppJuncList;
                    System.debug('oppJuncList---'+oppJuncList);
                }
                catch(Exception e) {
                    System.debug('Exception===='+e.getMessage());
                }
            }
    }
}