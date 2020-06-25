public class OpportunityUtility {
    public static void validateOpportunityStatusChange(Map<Id,Opportunity> oldMap,Map<Id,Opportunity> newMap){
        Set<Id> oppIdSet = new Set<Id>();
        Set<String> statusValueSet = new Set<String>{'Proposal/Price Quote','Negotiation','Active'};
        for(Opportunity o :newMap.values()){
            if(o.Type == 'Renewal' && statusValueSet.contains(o.StageName))
            	oppIdSet.add(o.Id);
        }
        System.debug('oppIdSet---'+oppIdSet);
        List<Case> caseList = new List<Case>();
        caseList = [SELECT Status,Opportunity__r.Id FROM Case WHERE Opportunity__r.Id IN :oppIdSet AND Status IN ('In_Progress','Brand Sales Approved','Finance Approved','Closed - Approved')];
        System.debug('caseList---'+caseList);
        Map<Id,List<Case>> oppIdCaseListMap = new Map<Id,List<Case>>();
        for(Case c : caseList){
            if(!oppIdCaseListMap.containsKey(c.Opportunity__r.Id)){
                oppIdCaseListMap.put(c.Opportunity__r.Id,new List<Case>());
            }
            oppIdCaseListMap.get(c.Opportunity__r.Id).add(c);
        }
        System.debug('oppIdCaseListMap---'+oppIdCaseListMap);
        for(Id i : oppIdSet){
            if(oppIdCaseListMap.containsKey(i) && oppIdCaseListMap.get(i).size() > 0){
                newMap.get(i).addError('Stage of this opportunity can not be changed as it have In Progess Case Termination');
            }
        }
    }
    
    public static void checkContactRoleAgainstAccount(List<Opportunity> newOppList, Map<Id, Opportunity> oldOppMap) {

        Set<Id> accountIdSet = new Set<Id>();
        Map<Id, Set<Id>> accountIdVsContactIdMap = new Map<Id, Set<Id>>();
        
        for(Opportunity oppObj : newOppList) {
            if((oldOppMap != null && 
               (oppObj.AccountId != oldOppMap.get(oppObj.Id).AccountId || 
                oppObj.Contact__c != oldOppMap.get(oppObj.Id).Contact__c)) ||
                oppObj.AccountId != null 
               ) {
                accountIdSet.add(oppObj.AccountId);
            }
        }
         
        for(AccountContactRelation roleObj : [SELECT ContactId, AccountId, Roles
                                          FROM AccountContactRelation
                                          WHERE AccountId IN: accountIdSet
                                          AND Contact.Is_Billing_Contact__c = TRUE]) {
            if(accountIdVsContactIdMap.containsKey(roleObj.AccountId)) {
                accountIdVsContactIdMap.get(roleObj.AccountId).add(roleObj.ContactId);
            }
            else {
                accountIdVsContactIdMap.put(roleObj.AccountId, new Set<Id> {roleObj.ContactId});
            }
        }
        Map<Id,Set<Id>> accIdRelatedContactIdsSetMap = new Map<Id,Set<Id>>();
        for(Contact c : [SELECT AccountId FROM Contact WHERE AccountId IN :accountIdSet ]){
            if(!accIdRelatedContactIdsSetMap.containsKey(c.AccountId)){
                accIdRelatedContactIdsSetMap.put(c.AccountId,new Set<Id>());
            }
            accIdRelatedContactIdsSetMap.get(c.AccountId).add(c.Id);
        }
        for(Opportunity oppObj : newOppList) {
            if(oppObj.AccountId != null && oppObj.Contact__c != null) {
                Set<Id> contactIdSet = accountIdVsContactIdMap.containsKey(oppObj.AccountId) ? 
                                       accountIdVsContactIdMap.get(oppObj.AccountId) : 
                                       new Set<Id>();
                
                Set<Id> directlyRelatedConIdSet = accIdRelatedContactIdsSetMap.containsKey(oppObj.AccountId) ? 
                    							  accIdRelatedContactIdsSetMap.get(oppObj.AccountId) : 
                								  new Set<Id>();
                
                if((contactIdSet.isEmpty() ||
                   !contactIdSet.contains(oppObj.Contact__c)) && 
                   (directlyRelatedConIdSet.isEmpty() ||
                   !directlyRelatedConIdSet.contains(oppObj.Contact__c))
                  ) {
                    oppObj.addError(System.Label.Account_Related_Contact_Role); 
                }  
            }
        }
    }

}