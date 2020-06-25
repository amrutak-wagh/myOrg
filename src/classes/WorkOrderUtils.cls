/************************************************************************************
* Name          : WorkOrderUtils                                                 
* Description   : Utility of Work Order Trigger
* Created Date  :                                                    
* Created By    : 4C - Anshul Garg (anshul.garg@weare4c.com)
* Jira/Req By   :                                                                                                                                           
* -----------------------------------------------------------------------------------------------------------------------
* VERSION   Developer   Date        Description     Ticket/Reference    

************************************************************************************/
global class WorkOrderUtils {
    /**
     *  @description Throws error if WOs are not approved sequentially
     *  @param  workOrderList  List of WorkOrders from Trigger.New
     *  @return 
     */
	public static void checkWorkOrderSequence(List<WorkOrder> workOrderList) {
        Set<Id> caseIds = new Set<Id>();
        System.debug('workOrderList'+workOrderList);
        
        for(WorkOrder wo : workOrderList) {
            if(wo.Status == 'Approved' || wo.Status == 'Rejected' || wo.Status == 'Completed') {
            	caseIds.add(wo.CaseId);
            }
        }
		System.debug('caseIds'+caseIds);  
        List<WorkOrder> workOrdersRelatedToCasesLst = 
            [SELECT Id, Status, Work_Order_Type__c, RecordTypeId, Work_Order_Number__c, CaseId
            FROM WorkOrder
            WHERE CaseId IN: caseIds
            AND Id NOT IN : Trigger.new
            AND (Status != 'Approved' 
            AND Status != 'Rejected'
            AND  Status != 'Completed')];
        
        System.debug('workOrdersRelatedToCasesLst'+workOrdersRelatedToCasesLst);
        
        //Set<Integer> sequenceNumbers = new Set<Integer>();
        Map<Id, Set<Decimal>> mapCaseIdWithSequenceNumber = new Map<Id, Set<Decimal>>();
        
        for(WorkOrder woObj : workOrdersRelatedToCasesLst) {
            //sequenceNumbers.add(woObj.Work_Order_Number__c);
            if(!mapCaseIdWithSequenceNumber.containsKey(woObj.CaseId)) {
                mapCaseIdWithSequenceNumber.put(woObj.CaseId,new Set<Decimal> {woObj.Work_Order_Number__c});
            }
            else {
                mapCaseIdWithSequenceNumber.get(woObj.CaseId).add(woObj.Work_Order_Number__c);
            }
            
           /* if(!quoteVsProductMap.containsKey(lineItemObj.QuoteId)) {
               quoteVsProductMap.put(lineItemObj.QuoteId, new Set<Id> {lineItemObj.Product2Id});
           }
           else {
               quoteVsProductMap.get(lineItemObj.QuoteId).add(lineItemObj.Product2Id);
           }*/
        }
        System.debug('mapCaseIdWithSequenceNumber=='+mapCaseIdWithSequenceNumber);
        
        for(WorkOrder woObj : workOrderList) {
            if(woObj.Status == 'Approved' || woObj.Status == 'Rejected' || woObj.Status == 'Completed') {
                if(mapCaseIdWithSequenceNumber.containsKey(woObj.caseId)) {
                    Set<Decimal> workOrderNumberSet = mapCaseIdWithSequenceNumber.get(woObj.CaseId);
                    System.debug('workOrderNumberSet=='+workOrderNumberSet);
                    workOrderNumberSet.remove(null);
                    if(!workOrderNumberSet.isEmpty()) {
                        for(Decimal sequenceNumber : workOrderNumberSet) {
                            if(sequenceNumber < woObj.Work_Order_Number__c) {
                                woObj.addError('The work orders has to be approved or rejected sequentially. Please approve or reject previous work orders first.');
                            }
                        }
                    }
                }
            }
        }
        
    }
    
    //Added methods from WorkOrderToolbarHandler
    @AuraEnabled
    global static WorkOrder getWorkOrderDetails(Id workOrderId) {
        try{            
            return [SELECT Id,Status,Account.Legal_Framework__c,
                    IsMovedToNextStep__c,Account.Security_Clearance_Status__c,Trust_Account_Payments_Received__c,
                    Account.Security_Clearance_Date__c,Account_Type__c,Minimum_Required_Share_Capital__c,
                    Account.Business_Plan_Request_Date_Approval_Date__c 
                    FROM WorkOrder WHERE Id = :workOrderId LIMIT 1];
        }catch(Exception ex){
            System.debug(ex);
            throw new AuraHandledException('Darn it! Something went wrong: '+ ex.getMessage());
        }
    }
    
    @AuraEnabled
    global static List<QuoteLineItem> getQuoteProducts(WorkOrder workOrder) {
        try{
            return [SELECT Id,Is_Registered_Address__c,Product2.Name,Quote.Opportunity.AG_Number__c,Product2.Unit__r.Name
                    FROM QuoteLineItem WHERE Quote.AccountId = :workOrder.AccountId AND Revision_Number__c = null];
        }catch(Exception ex){
            System.debug(ex);
            throw new AuraHandledException('Darn it! Something went wrong: '+ ex.getMessage());
        }
    }
    
    @AuraEnabled
    global static void updateRegisteredAddress(String qLineId) {
        try{
            update new QuoteLineItem(Id=qLineId,Is_Registered_Address__c=true);
        }catch(Exception ex){
            System.debug(ex);
            throw new AuraHandledException('Darn it! Something went wrong: '+ ex.getMessage());
        }
    }
    
    @AuraEnabled
    global static List<Registration_Request_Status_Setting__mdt> getStatusSettings() {
        try{
            return [SELECT Id,MasterLabel,DeveloperName,Convert_To_Trust_Account__c,Legal_Framework__c,
                    Move_To_Next_Status__c,Status__c,Validate_Lease_Items__c
                    FROM Registration_Request_Status_Setting__mdt];
        }catch(Exception ex){
            System.debug(ex);
            throw new AuraHandledException('Darn it! Something went wrong: '+ ex.getMessage());
        }
    }
    
    @AuraEnabled
    global static String sendUpdateToDDA(Id workOrderId, Boolean convertToTrust, Boolean isMoveToNext) {
        try{
            WorkOrder wo = [SELECT Id,AccountId,Skip_Lease_Validation__c,No_Of_Trust_account_Payments__c,Account_Type__c FROM WorkOrder WHERE Id =: workOrderId];            
            String errorMessage = '';
            if(isMoveToNext){
                errorMessage = isMoveToNextPossible(wo);
            }
            if(convertToTrust){
                errorMessage = isConvertToTrustPossible(wo);
            }
            if(String.isEmpty(errorMessage)){
                if(isMoveToNext){wo.IsMovedToNextStep__c = isMoveToNext;}
                if(convertToTrust){wo.Account_Type__c='Trust Account';}
                update wo;
                DDAIntegration.createNewServiceRequest(new Set<Id>{workOrderId}, convertToTrust, isMoveToNext);
                return '';
            }else{
                return errorMessage;
            }
        }catch(Exception ex){
            System.debug(ex);
            throw new AuraHandledException('Darn it! Something went wrong: '+ ex.getMessage());
        }
    }
    
    public static String isMoveToNextPossible(WorkOrder wo){
        String errorMessage = '';
        List<Document__c> docs = [SELECT Id,Name FROM Document__c WHERE Work_Order__c = :wo.Id AND Is_Mandatory__c = true AND File_Attached__c = false];
        if(!docs.isEmpty()){
            errorMessage = '* Please attach all mandatory Documents to Work Order.<br/>';
        }
        
        Boolean oppProductsFlag = true;
        Boolean opportunityFlag = true;
        Boolean serviceRequestTrustAccountPaymentFlag = true;
        Boolean licensedActivityFlag = true;
        Boolean opportunityStatusFlag = true;
        Boolean multipleUnits = false;
        Boolean isRegAddSelected = false;
        
        List<Quote> opportunityList = [SELECT Id,(SELECT Id,Is_Registered_Address__c FROM QuoteLineItems WHERE Revision_Number__c = null) FROM Quote WHERE AccountId = :wo.AccountId];
        opportunityFlag = opportunityList.isEmpty()?false:true;
        
        if(!opportunityFlag){
            errorMessage +='* Please add opportunity to related account.<br/>';
        }        

        if(opportunityFlag==true){
            for(Quote quo : opportunityList){
                oppProductsFlag = quo.QuoteLineItems.isEmpty()?false:true;
                if(!quo.QuoteLineItems.isEmpty() && quo.QuoteLineItems.size()>1){
                    multipleUnits = true;
                    for(QuoteLineItem qline : quo.QuoteLineItems){
                        if(qline.Is_Registered_Address__c){
                            isRegAddSelected = true;
                        }
                    }
                }
            }
        }
        
        if(oppProductsFlag==false && wo.Skip_Lease_Validation__c==false){
            errorMessage +='* Please add products to related opportunity.<br/>';
        }
        
        if(multipleUnits && !isRegAddSelected){
            errorMessage +='* Please select registered address.<br/>';
        }

        if(wo.No_Of_Trust_account_Payments__c==0 && wo.Account_Type__c == 'Trust Account'){
            errorMessage += '* Please add at least one Trust Account Payment.<br/>';
        }
        
        List<Requested_Licensed_Activity__c> requestedLicActs = [SELECT Id FROM Requested_Licensed_Activity__c WHERE Account__c =: wo.AccountId];
        if(requestedLicActs.isEmpty()){
            errorMessage += '* Please add requested licensed activities.<br/>';
        }
        
        if(errorMessage!=null){
            errorMessage = errorMessage.replace('null','');
        }
        return errorMessage;
    }
    
    public static String isConvertToTrustPossible(WorkOrder wo){
        String errorMessage = '';
        List<Document__c> docs = [SELECT Id,Name FROM Document__c WHERE Work_Order__c = :wo.Id AND Is_Mandatory__c = true AND File_Attached__c = false];
        if(!docs.isEmpty()){
            errorMessage = '* Please attach all mandatory Documents to Work Order.<br/>';
        }
        
        Boolean oppProductsFlag = true;
        Boolean opportunityFlag = true;
        Boolean serviceRequestTrustAccountPaymentFlag = true;
        Boolean licensedActivityFlag = true;
        Boolean opportunityStatusFlag = true;
        
        List<Opportunity> opportunityList = [SELECT Id FROM Opportunity WHERE AccountId = :wo.AccountId];
        opportunityFlag = opportunityList.isEmpty()?false:true;
        
        if(!opportunityFlag){
            errorMessage +='* Please add opportunity to related account.<br/>';
        }

        if(opportunityFlag==true){
            for(Opportunity opp:opportunityList){
                oppProductsFlag = opp.opportunityLineItems.isEmpty()?false:true;                
            }
        }
        
        if(oppProductsFlag==false && wo.Skip_Lease_Validation__c==false){errorMessage +='* Please add products to related opportunity.<br/>';}

        if(wo.No_Of_Trust_account_Payments__c==0 && wo.Account_Type__c == 'Trust Account'){
            errorMessage += '* Please add at least one Trust Account Payment.<br/>';        
        }
        
        List<Requested_Licensed_Activity__c> requestedLicActs = [SELECT Id FROM Requested_Licensed_Activity__c WHERE Account__c =: wo.AccountId];
        if(requestedLicActs.isEmpty()){
            errorMessage += '* Please add requested licensed activities.<br/>';
        }
        
        if(errorMessage!=null){
            errorMessage = errorMessage.replace('null','');
        }
        return errorMessage;
    }
}