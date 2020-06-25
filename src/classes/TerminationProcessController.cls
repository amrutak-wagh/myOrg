public class TerminationProcessController {
    
    @AuraEnabled
    public static Id getContractDetailApcx(Id opportunityId) {
        
        List<Contract> contractList = [SELECT Id FROM Contract WHERE Opportunity__c =: opportunityId];
        if(contractList.size() > 0) {
            return contractList[0].Id;
        }
        else 
            return null;
    }
}