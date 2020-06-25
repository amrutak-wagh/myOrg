/************************************************************************************
* Name          : LeaseMergerBatch                                                 
* Description   : Batch for Merger of Leases
* Created Date  :                                                    
* Created By    : 4C Vaibhavi
* Jira/Req By   :                                                                                                                                           
* -----------------------------------------------------------------------------------------------------------------------
* VERSION   Developer   Date        Description     Ticket/Reference    
1.0
************************************************************************************/
global class LeaseMergerBatch implements Database.Batchable<sObject>,Database.Stateful {
    public Map<Id,Opportunity> oppIdVsRecMap = new Map<Id,Opportunity>();
    
    Id opportunityId;
    public LeaseMergerBatch() {}
    public LeaseMergerBatch(Id opportunityId) {
        this.opportunityId = opportunityId;
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        // collect the batches of records or objects to be passed to execute
        Date filterDate = Date.today().addDays(120);
        String oppQuery = 'SELECT Id, Name, Type, Lease_End_Date__c,SyncedQuoteId, Lease_Type__c,Lease_Start_Date__c,CloseDate,'+
            			  'ContactId,Opportunity_Type__c,StageName,Parent_Amendment_Id__c,Amendment_Id__c,Contact__c,T_Code__c,'+
            			  'AccountId, CurrencyIsoCode, Business_Park__c, Sub_Type__c, Parent_Opportunity__c,Building_Name__c , ' +
                          '(SELECT Id FROM Opportunities__r WHERE Type = \'Renewal\' AND  StageName != \'Cancelled\')'+
            			  ' FROM Opportunity WHERE Lease_End_Date__c =:filterDate AND StageName = \'Active\' ';
        
        if(String.isNotBlank(opportunityId)) { 
            oppQuery += 'AND Id =: opportunityId';
        }
        oppQuery += ' ORDER BY CreatedDate DESC';
        List<Opportunity> oppList = Database.query(oppQuery);
        oppIdVsRecMap = new Map<Id,Opportunity>(oppList);
        return Database.getQueryLocator(oppQuery);        
    }
    
    /**
    *  @description Creates Opportunity if Parent's and Child's opportunities have same Lease End date and Building name. 
    *      Creates a quote related to the newly created opportunity and related QLI's of parent's and child's synced Quote.  
    *  @param List of Opportunity where type is Renewal
    *  @return 
    */
    
    global void execute(Database.BatchableContext bc, List<Opportunity> scope){
        // process each batch of records
        createRenewalOppAndQuoteQLI(scope);
    }            
    global void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    }    

      /**
        * @method	: createRenewalOppAndQuoteQLI()
        * @description	: Method to create renewal opportunity, quote and related QLI records
        * @return	: NA
        * @params	: scope - List of Opportunity
        */
    public void createRenewalOppAndQuoteQLI(List<Opportunity> scope) {

        Map<Id,List<Id>> oppIdVsMergeOppIdListMap = new Map<Id,List<Id>>();
        Map<String,List<Opportunity>> criteriaVsOpplistMap = new Map<String,List<Opportunity>>();
        for(Opportunity opp : scope) {
            if(opp.Opportunities__r.size() == 0) {
                String key = String.valueOf(opp.AccountId) + String.valueOf(opp.Lease_End_Date__c) + opp.Building_Name__c;
                if(!criteriaVsOpplistMap.containsKey(key)){
                    criteriaVsOpplistMap.put(key,new List<Opportunity>());
                }
                criteriaVsOpplistMap.get(key).add(opp);
            }
        }
        Map<String,List<Id>>  criteriaVsOppToMergeIdListMap = new Map<String,List<Id>>();
        List<Id> idsWithChildRecordList = new List<Id>();
        
        for(String key : criteriaVsOpplistMap.keyset()){
            List<Id> oppToMergeIdList = new List<Id>();
            List<Opportunity> sameCriteriaOppList = criteriaVsOpplistMap.get(key);
            List<Id> sameCriteriaOppIdList = new List<Id>();
            for(Opportunity o :sameCriteriaOppList){
                sameCriteriaOppIdList.add(o.Id);
            }
            for(Opportunity o : criteriaVsOpplistMap.get(key)){
                if(o.Parent_Opportunity__c == NULL){
                    if(!oppToMergeIdList.contains(o.Id))
                    	oppToMergeIdList.add(o.Id);
                }else if(!sameCriteriaOppIdList.contains(o.Parent_Opportunity__c)){
                    if(!oppToMergeIdList.contains(o.Id))
                    	oppToMergeIdList.add(o.Id);
                }else if(sameCriteriaOppIdList.contains(o.Parent_Opportunity__c)){
                    if(oppToMergeIdList.contains(o.Id)){
                        oppToMergeIdList.remove(oppToMergeIdList.indexOf(o.Id));
                    }
                    if(idsWithChildRecordList.contains(o.Id)){
                        idsWithChildRecordList.remove(oppToMergeIdList.indexOf(o.Id));
                    }
                    if(!oppToMergeIdList.contains(o.Parent_Opportunity__c))
                    	oppToMergeIdList.add(o.Parent_Opportunity__c);
                    if(!idsWithChildRecordList.contains(o.Parent_Opportunity__c))
                    	idsWithChildRecordList.add(o.Parent_Opportunity__c);
                }
            }
            criteriaVsOppToMergeIdListMap.put(key, oppToMergeIdList);
        }
        
        for(String str : criteriaVsOppToMergeIdListMap.keyset()){
            for(Id i : criteriaVsOppToMergeIdListMap.get(str)){
                if(idsWithChildRecordList.contains(i)){
                    criteriaVsOppToMergeIdListMap.get(str).remove(criteriaVsOppToMergeIdListMap.get(str).indexOf(i));
                }
            }
        }
        
        List<Opportunity> oppList = [SELECT  Id, Name, Type, Lease_End_Date__c,SyncedQuoteId, Lease_Type__c,Lease_Start_Date__c
                                     		,CloseDate,ContactId,Opportunity_Type__c,StageName,Parent_Amendment_Id__c,T_Code__c,AccountId
                                     		,CurrencyIsoCode, Business_Park__c, Sub_Type__c,Parent_Opportunity__c,Building_Name__c
                                     		,(SELECT  Id, Name, Type, Lease_End_Date__c, Lease_Start_Date__c,CloseDate, SyncedQuoteId
                                            		  ,ContactId, StageName,AccountId, CurrencyIsoCode, Business_Park__c, Sub_Type__c
                                            		  ,Parent_Opportunity__c,Building_Name__c 
                                     		  FROM Opportunities__r 
                                     		  WHERE StageName = 'Active') 
                                     FROM  Opportunity 
                                     WHERE Id IN :idsWithChildRecordList];
        
        //Create new Renewal Opportunity
        for(Opportunity o : oppList){
            if(!oppIdVsMergeOppIdListMap.containsKey(o.Id)){
                oppIdVsMergeOppIdListMap.put(o.Id,new List<Id>());
            }
            for(Opportunity childOpp : o.Opportunities__r){
                if(childOpp.Lease_End_Date__c == o.Lease_End_Date__c 
                   && childOpp.Building_Name__c == o.Building_Name__c
                   && childOpp.AccountId == o.AccountId){
                       if(oppIdVsRecMap.containsKey(childOpp.Id)){
                           oppIdVsMergeOppIdListMap.get(o.Id).add(childOpp.Id);
                       }
                   }
            }
        }
        
        for(String str : criteriaVsOppToMergeIdListMap.keyset()){
            if(criteriaVsOppToMergeIdListMap.get(str).size()>0){
                idsWithChildRecordList.add(criteriaVsOppToMergeIdListMap.get(str)[0]);
                List<Id> internalList = new List<Id>(criteriaVsOppToMergeIdListMap.get(str));
                internalList.remove(0);
                oppIdVsMergeOppIdListMap.put(criteriaVsOppToMergeIdListMap.get(str)[0],internalList);
            }
        }
        
        Map<Id,List<Id>> oppIdVsSyncQuoteIdListMap = new Map<Id,List<Id>>();
        for(Id id :oppIdVsMergeOppIdListMap.keyset()){
            if(!oppIdVsSyncQuoteIdListMap.containsKey(id)){
                oppIdVsSyncQuoteIdListMap.put(id,new List<Id>());
            }
            for(Id internalId : oppIdVsMergeOppIdListMap.get(id)){
                if(oppIdVsRecMap.get(internalId).SyncedQuoteId != NULL)
                	oppIdVsSyncQuoteIdListMap.get(id).add(oppIdVsRecMap.get(internalId).SyncedQuoteId);
            }
            if(oppIdVsRecMap.get(id).SyncedQuoteId != NULL)
            	oppIdVsSyncQuoteIdListMap.get(id).add(oppIdVsRecMap.get(id).SyncedQuoteId);
        }
       	
        List<Opportunity> renewalOppLst = new List<Opportunity>();
        
        for(Id parentOppId : idsWithChildRecordList) {
            Opportunity parentOpp = oppIdVsRecMap.get(parentOppId);
            Opportunity renewalOppObj = new Opportunity();
            renewalOppObj.Business_Park__c = parentOpp.Business_Park__c;
            renewalOppObj.CloseDate = parentOpp.CloseDate;
            renewalOppObj.ContactId = parentOpp.ContactId;
            renewalOppObj.Name = parentOpp.Name + ' Renewal';
            renewalOppObj.StageName = 'New';
            renewalOppObj.AccountId = parentOpp.AccountId;
            renewalOppObj.Contact__c = parentOpp.Contact__c;
            renewalOppObj.CurrencyIsoCode = parentOpp.CurrencyIsoCode;
            renewalOppObj.Parent_Opportunity__c = parentOpp.Id;
            renewalOppObj.Lease_Start_Date__c = parentOpp.Lease_End_Date__c.addDays(1);
            renewalOppObj.Lease_End_Date__c = parentOpp.Lease_End_Date__c.addMonths(12);
            renewalOppObj.Lease_Type__c = parentOpp.Lease_Type__c;
            renewalOppObj.Opportunity_Type__c = 'Renew';
            renewalOppObj.Parent_Amendment_Id__c = parentOpp.Amendment_Id__c;
            renewalOppObj.T_Code__c = parentOpp.T_Code__c;
            renewalOppObj.Type = 'Renewal';
            renewalOppObj.Sub_Type__c = 'Renewal';
            renewalOppObj.Building_Name__c = parentOpp.Building_Name__c;
            renewalOppLst.add(renewalOppObj);
        }
        
        if(!renewalOppLst.isEmpty()) {
            insert renewalOppLst;
            System.debug('inserted Opportunities size==='+renewalOppLst.size());
        }
        
        Set<Id> quoteIdSet = new Set<Id>();    
        for(Id id : idsWithChildRecordList){
            if(oppIdVsRecMap.get(id).SyncedQuoteId != NULL)
            	quoteIdSet.add(oppIdVsRecMap.get(id).SyncedQuoteId);
        }
        List<Quote> quoteList = [SELECT   Id,Lease_Start_Date__c,Name,Type__c,Proposed_Start_Date__c,Proposed_End_Date__c
                                 		 ,Grace_Period__c,Grace_Period_Period__c,Grace_Period_Mechanism__c,Payment_Terms__c
                                 		 ,Status, IsSyncing, OpportunityId,Lease_End_Date__c ,Pricebook2Id,Opportunity.Contact__c 
                                 FROM Quote WHERE Id IN :quoteIdSet];

        Map<id,Quote> parentOppIdSyncedQuoteMap = new Map<id,Quote>();
        for(Quote q : quoteList){
            parentOppIdSyncedQuoteMap.put(q.OpportunityId,q);
        }
        
        //Parent Synced Quote's QuoteLineItems
        Set<Id> masterSyncedQuoteIdSet = new Set<Id>();
        for(Id recId : oppIdVsRecMap.keyset()){
            if(oppIdVsRecMap.get(recId).SyncedQuoteId != NULL)
            	masterSyncedQuoteIdSet.add(oppIdVsRecMap.get(recId).SyncedQuoteId);
        }
        
        List<QuoteLineItem> lineItemsLst = [SELECT   Id
                                            		,UnitPrice
                                            		,QuoteId
                                            		,Transactional_Unit__c
                                            		,Transaction_Type__c
                                            		,Start_Date__c
                                            		,End_Date__c
                                            		,Quantity
                                            		,Product2Id
                                            		,Area__c
                                            		,PricebookEntryId
                                            		,Quote.OpportunityId
                                            		,Quote.Opportunity.Parent_Opportunity__r.Id
                                            FROM QuoteLineItem
                                            WHERE QuoteId IN: masterSyncedQuoteIdSet
                                            AND PriceSch_ChargeType__c = 'Rent'
                                            AND Type__c = 'Normal'];
        
        Map<Id,List<Id>> oppIdQLIToMergerListMap = new Map<Id,List<Id>>();
        for(Id id : oppIdVsSyncQuoteIdListMap.keyset()){
            if(!oppIdQLIToMergerListMap.containsKey(id)){
                oppIdQLIToMergerListMap.put(id,new List<Id>());
            }
            
            for(Id internalId : oppIdVsSyncQuoteIdListMap.get(id)){
                for(QuoteLineItem qli : lineItemsLst){
                    if(qli.QuoteId == internalId){
                        oppIdQLIToMergerListMap.get(id).add(qli.id);
                    }
                }
            }
        }
        
        List<Quote> renewalQuoteList = new List<Quote>();
        for(Opportunity renewalObj : renewalOppLst) {
            if(parentOppIdSyncedQuoteMap.containsKey(renewalObj.Parent_Opportunity__c) && parentOppIdSyncedQuoteMap.get(renewalObj.Parent_Opportunity__c) != NULL){
                Quote syncQuoteInstance = parentOppIdSyncedQuoteMap.get(renewalObj.Parent_Opportunity__c);
                Quote quoteObj = new Quote();
                quoteObj.Lease_End_Date__c = syncQuoteInstance.Lease_End_Date__c;
                quoteObj.Lease_Start_Date__c = syncQuoteInstance.Lease_Start_Date__c;
                quoteObj.Name = syncQuoteInstance.Name;
                quoteObj.Type__c = 'Renewal';
                quoteObj.Proposed_End_Date__c = syncQuoteInstance.Proposed_End_Date__c;
                quoteObj.Proposed_Start_Date__c = syncQuoteInstance.Proposed_Start_Date__c;
                //quoteObj.Grace_Period__c = syncQuoteInstance.Grace_Period__c;
                //quoteObj.Grace_Period_Period__c = syncQuoteInstance.Grace_Period_Period__c;
                //quoteObj.Grace_Period_Mechanism__c = syncQuoteInstance.Grace_Period_Mechanism__c;
                quoteObj.Payment_Terms__c = syncQuoteInstance.Payment_Terms__c;
                quoteObj.Status = 'Draft';
                quoteObj.OpportunityId = renewalObj.Id;
                quoteObj.Pricebook2Id = syncQuoteInstance.Pricebook2Id;
                quoteObj.Previous_Quote__c = syncQuoteInstance.Id;
                quoteObj.ContactId = syncQuoteInstance.Opportunity.Contact__c;
                renewalQuoteList.add(quoteObj);
            }
        }
        if(!renewalQuoteList.isEmpty()) {
            insert renewalQuoteList;
        }
        Set<Id> newQuoteIdSet = new Set<Id>();
        for(Quote q : renewalQuoteList){
            newQuoteIdSet.add(q.Id);
        }
        Map<Id,Quote> newQuoteIdParentOpportunityIdMap = new Map<Id,Quote>([Select OpportunityId,Opportunity.Parent_Opportunity__r.Id From Quote WHERE Id IN :newQuoteIdSet]);
        List<QuoteLineItem> parentsQLILst = new List<QuoteLineItem>();
        //Insert parent's synced QLI's to the Quote
        System.debug('parents Lineitems size===='+lineItemsLst.size());
            
        if(!renewalQuoteList.isEmpty() && !lineItemsLst.isEmpty()) {
            for(Quote quoteObj: renewalQuoteList) {
                for(QuoteLineItem parentsQLIObj : lineItemsLst) {
                    if(oppIdQLIToMergerListMap.get(newQuoteIdParentOpportunityIdMap.get(quoteObj.Id).Opportunity.Parent_Opportunity__r.Id).contains(parentsQLIObj.Id)){
                        QuoteLineItem newQLI = new QuoteLineItem();
                        newQLI.UnitPrice = parentsQLIObj.UnitPrice;
                        newQLI.QuoteId = quoteObj.Id;
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
                }
            }
        }
        
        List<Id> renewalOppIdList = new List<Id>();
        for(Opportunity o :renewalOppLst){
            renewalOppIdList.add(o.Id);
        }
        List<Opportunity> newOppList = new List<Opportunity>();
        newOppList = [SELECT Parent_Opportunity__r.Id,Name FROM Opportunity WHERE ID IN :renewalOppIdList];
        if(!parentsQLILst.isEmpty()) {
            try{
                insert parentsQLILst;
                List<Opportunity_Junction__c> oppJuncList = new List<Opportunity_Junction__c>();
                for(Opportunity newOpp : newOppList){
                    for(Id internalId : oppIdVsMergeOppIdListMap.get(newOpp.Parent_Opportunity__r.Id)){
                        Opportunity_Junction__c oppJun = new Opportunity_Junction__c();
                        oppJun.Name = newOpp.Name;
                        oppJun.Opportunity__c = newOpp.Id;
                        oppJun.Opportunity_Lookup__c = internalId;
                        oppJuncList.add(oppJun);
                    }
                    if(oppIdVsMergeOppIdListMap.get(newOpp.Parent_Opportunity__r.Id).size() > 0){
                        Opportunity_Junction__c oppJunParent = new Opportunity_Junction__c();
                        oppJunParent.Name = newOpp.Name;
                        oppJunParent.Opportunity__c = newOpp.Id;
                        oppJunParent.Opportunity_Lookup__c = newOpp.Parent_Opportunity__r.Id;
                        oppJuncList.add(oppJunParent);
                    }
                }
                insert oppJuncList;
            }
            catch(Exception e) {
                System.debug('Exception===='+e.getMessage());
            }
        }
    }
}