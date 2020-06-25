global class LicenseRegistrationWebservice {
    
    global class ServiceRequest{
        webservice String ddaSerReqId;
        webservice String workOrderId;
        webservice String serviceName;
        webservice String status;
        webservice Boolean isDataMigratedLocked;
        webservice String assignedToRCName;
        webservice String busiUnitSubCat;
        webservice Boolean skipLeaseValidation;
        webservice String callForReviewReason;
        webservice Decimal totalAmountDue;
        webservice Decimal minReqShareCapital;
        webservice String bank;
        webservice String bankBranch;
    }
    
    global class RequestResponse{
        webservice Boolean success;
        webservice String errorMessage;
    }
    
    webservice static RequestResponse pushServiceRequestUpdates(List<ServiceRequest> reqs){
        RequestResponse reqRes = new RequestResponse();
        reqRes.success = true;
        reqRes.errorMessage  = '';
        try{
            Set<String> statuses = new Set<String>();
            for(Registration_Request_Status_Setting__mdt rrss : [SELECT Id,Legal_Framework__c,Status__c FROM Registration_Request_Status_Setting__mdt WHERE Move_To_Next_Status__c = TRUE]){
                statuses.add(rrss.Status__c);
            }
            List<WorkOrder> workOrders = new List<WorkOrder>();
            for(ServiceRequest servReq : reqs){
                WorkOrder wo = new WorkOrder();
                wo.Id = servReq.workOrderId;
                wo.DDA_Request_Id__c = servReq.ddaSerReqId;
                wo.Service_Name__c = servReq.serviceName;
                wo.Status = servReq.status;
                wo.Is_Data_Migrated_and_Locked__c = servReq.isDataMigratedLocked;
                wo.Assigned_To_RC__c = servReq.assignedToRCName;
                wo.Under_Registration_BU_Sub_Category__c = servReq.busiUnitSubCat;
                wo.Skip_Lease_Validation__c = servReq.skipLeaseValidation;
                wo.Call_For_Review_Reason__c = servReq.callForReviewReason;
                wo.Total_Amount_Due__c = servReq.totalAmountDue;
                wo.Minimum_Required_Share_Capital__c = servReq.minReqShareCapital;
                wo.Bank__c = servReq.bank;
                wo.Bank_Branch__c = servReq.bankBranch;
                if(statuses.contains(servReq.status)){
                    wo.IsMovedToNextStep__c = false;
                }
                workOrders.add(wo);
            }
            update workOrders;
            return reqRes;
        }catch(Exception ex){
            reqRes.success = false;
            reqRes.errorMessage  = 'Error message :- '+ex.getMessage()+' Stack trace :- '+ex.getStackTraceString();
            return reqRes;
        }
    }
}