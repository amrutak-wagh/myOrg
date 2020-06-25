public class CaseTriggerHandler {
    public static void beforeUpdate(Map<Id,Case> oldCaseMap ,List<Case> newCaseList){
        Set<Id> caseIdSet = new Set<Id>();
        System.debug('----Here----');
        for(Case c : newCaseList){
            if(c.Status == 'Closed - Approved' && oldCaseMap.get(c.Id).Status != 'Closed - Approved')
            caseIdSet.add(c.Id);
        }
        System.debug('----caseIdSet----'+caseIdSet);
        List<WorkOrder> workOrderList = [SELECT Status,CaseId FROM WorkOrder WHERE CaseId IN : caseIdSet];
        Map<Id,List<WorkOrder>> caseIdWorkOrderMap = new Map<Id,List<WorkOrder>>();
        for(WorkOrder wo : workOrderList){
            if(!caseIdWorkOrderMap.containsKey(wo.CaseId)){
                caseIdWorkOrderMap.put(wo.CaseId,new List<WorkOrder>());
            }
            caseIdWorkOrderMap.get(wo.CaseId).add(wo);
        }
        System.debug('-----caseIdWorkOrderMap---'+caseIdWorkOrderMap);
        for(Case c : newCaseList){
            if(caseIdWorkOrderMap.containsKey(c.Id) && caseIdWorkOrderMap.get(c.Id).size()>0){
                for(WorkOrder wo : caseIdWorkOrderMap.get(c.Id)){
                    System.debug('----Here----');
                    if(wo.Status != 'Approved'){
                        System.debug('----Here----');
                        c.addError('To Approve the case all work orders should be approved');
                        break;
                    }
                }
            }
            
        }
    }
    
    public static void afterUpdate(List<Case> newCaseList){
        Set<Id> caseIdSet = new Set<Id>();
        for(Case c : newCaseList){
            if(c.Status == 'Closed - Rejected')
           		caseIdSet.add(c.Id);
        }
        List<WorkOrder> workOrderList = [SELECT Status,CaseId FROM WorkOrder WHERE CaseId IN : caseIdSet];
        List<WorkOrder> workOrderToUpdateList = new List<WorkOrder>();
        for(WorkOrder wo : workOrderList){
            wo.Status = 'Rejected';
            wo.Feedback_Reason__c = 'Case is closed - rejected';
            wo.Description = 'Case is closed - rejected';
            workOrderToUpdateList.add(wo);
        }
        if(workOrderToUpdateList.size() > 0){
            update workOrderToUpdateList;
        }
    }
}