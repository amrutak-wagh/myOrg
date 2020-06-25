/************************************************************************************
* Name          : PremiseLeaseComponentController                                                 
* Description   : Controller class for PremiseLeaseComponent
* Created Date  : 10/09/2019                                                 
* Created By    : 4C Amruta K
* Jira/Req By   :                                                                                                                                           
* -----------------------------------------------------------------------------------------------------------------------
* VERSION   Developer   Date        Description     Ticket/Reference    
1.0
************************************************************************************/
public class PremiseLeaseComponentController {
    
   /**
    * @method	: checkForValidOppAndExecuteBatch()
    * @description	: Method to check if opportunity is valid for renewal if yes create renewal record.
    * @return	: Error/ Success message for user.
    * @params	: opportunityId - Opportunity Id
    */
    @AuraEnabled
    public static String checkForValidOppAndExecuteBatch(Id opportunityId) {
        
        String resultMsg;
        List<Opportunity> opportunityList = [SELECT Id, Name, Type, Lease_End_Date__c,SyncedQuoteId, Lease_Type__c,Lease_Start_Date__c,CloseDate,
                                             ContactId,Opportunity_Type__c,StageName,Parent_Amendment_Id__c,Amendment_Id__c,Contact__c,T_Code__c,
                                             AccountId, CurrencyIsoCode, Business_Park__c, Sub_Type__c, Parent_Opportunity__c,Building_Name__c, 
                                      		 (SELECT Id FROM Opportunities__r WHERE Type = 'Renewal' AND  StageName != 'Cancelled')
                                      FROM Opportunity
                                      WHERE Id =: opportunityId
                                     ];
        if(opportunityList[0].Opportunities__r.size() > 0) {
             resultMsg = 'Renewal Opportunity is already present.';
        }
        else {
            resultMsg = 'Success';
            //Database.executeBatch(new LeaseMergerBatch(opportunityId));
            LeaseMergerBatch leaseBatchObj = new LeaseMergerBatch();
            leaseBatchObj.oppIdVsRecMap = new Map<Id,Opportunity>(opportunityList);
            leaseBatchObj.createRenewalOppAndQuoteQLI(opportunityList); 
        }
        return resultMsg;
    }

}