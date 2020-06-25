public class TerminationProcessContractController {
	@AuraEnabled
    public static Id getContractDetailApcx(Id contractId) {
        
        List<Contract> contractList = [SELECT Id,Opportunity__c FROM Contract WHERE Id =: contractId];
        if(contractList.size() > 0) {
            return contractList[0].Opportunity__c;
        }
        else 
            return null;
    }
}