/**
*  @description Test class for LicenseRegistrationWebservice
*
*  2019-08-22  Shraddha N    First version
*  
*/
@isTest
public class LicenseRegistrationWebserviceTest {
    
    /* global HTTPResponse respond(HTTPRequest request) {
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"result": "abc"}');
        response.setStatusCode(200);
        return response; 
    }*/
    
    /*Common test data to be used in test class*/
    @testSetup
    public static void setUp(){

        WorkOrder workOrderObject = new WorkOrder(Status = 'New', 
                                                  Description = 'test Description', 
                                                  Work_Order_Number__c = 1, 
                                                  Account_Type__c = 'Trust Account', 
                                                  Minimum_Required_Share_Capital__c = 10000,
                                                  IsMovedToNextStep__c = true,
                                                  DDA_Request_Id__c = 'Req-1',
                                                  Service_Name__c = 'Test Service',
                                                  Is_Data_Migrated_and_Locked__c = FALSE,
                                                  Assigned_To_RC__c = 'Test Assignment',
                                                  Under_Registration_BU_Sub_Category__c = 'Test Under Registration BU Sub_Category',
                                                  Skip_Lease_Validation__c = TRUE,
                                                  Call_For_Review_Reason__c = 'Test Call',
                                                  Total_Amount_Due__c = 123,
                                                  Bank__c = 'Test Bank',
                                                  Bank_Branch__c = 'Test Bank Branch');
        insert workOrderObject;  
    }
    
    // Getting metadata object record
    @testVisible 
    static List<Registration_Request_Status_Setting__mdt> customMetadata { 
        get {
            if ( customMetadata == null )
                customMetadata = [SELECT Id,Legal_Framework__c, Move_To_Next_Status__c,Status__c
                                  FROM Registration_Request_Status_Setting__mdt]; 
            return customMetadata;
        } 
        set; 
    }
    
    //Method to test pushServiceRequestUpdates method
    @isTest
    public static void pushServiceRequestUpdatesTest(){
        WorkOrder workOrderObject = [SELECT Id, DDA_Request_Id__c, Service_Name__c, Status, Is_Data_Migrated_and_Locked__c,
                                     Assigned_To_RC__c, Under_Registration_BU_Sub_Category__c, Skip_Lease_Validation__c,
                                     Call_For_Review_Reason__c, Total_Amount_Due__c, Minimum_Required_Share_Capital__c,
                                     Bank__c, Bank_Branch__c FROM WorkOrder WHERE Status = 'New' LIMIT 1];
        
        LicenseRegistrationWebservice.ServiceRequest serviceReqObject = new LicenseRegistrationWebservice.ServiceRequest();
        serviceReqObject.workOrderId = workOrderObject.Id;
        serviceReqObject.ddaSerReqId = workOrderObject.DDA_Request_Id__c;
        serviceReqObject.serviceName = workOrderObject.Service_Name__c;
        serviceReqObject.status = workOrderObject.Status;
        serviceReqObject.isDataMigratedLocked = workOrderObject.Is_Data_Migrated_and_Locked__c;
        serviceReqObject.assignedToRCName = workOrderObject.Assigned_To_RC__c;
        serviceReqObject.busiUnitSubCat = workOrderObject.Under_Registration_BU_Sub_Category__c;
        serviceReqObject.skipLeaseValidation = workOrderObject.Skip_Lease_Validation__c;
        serviceReqObject.callForReviewReason = workOrderObject.Call_For_Review_Reason__c;
        serviceReqObject.totalAmountDue = workOrderObject.Total_Amount_Due__c;
        serviceReqObject.minReqShareCapital = workOrderObject.Minimum_Required_Share_Capital__c;
        serviceReqObject.bank = workOrderObject.Bank__c;
        serviceReqObject.bankBranch = workOrderObject.Bank_Branch__c;
        
        LicenseRegistrationWebservice.ServiceRequest serviceReqObject2 = new LicenseRegistrationWebservice.ServiceRequest();

        List<LicenseRegistrationWebservice.ServiceRequest> serviceReqList = new List<LicenseRegistrationWebservice.ServiceRequest>();
        serviceReqList.add(serviceReqObject);
        
        
        Test.startTest();        
        LicenseRegistrationWebservice.RequestResponse reqResponse1 = LicenseRegistrationWebservice.pushServiceRequestUpdates(serviceReqList);
        serviceReqList.add(serviceReqObject2);
        LicenseRegistrationWebservice.RequestResponse reqResponse2 = LicenseRegistrationWebservice.pushServiceRequestUpdates(serviceReqList);
        Test.stopTest();
        
        System.assertNotEquals(NULL, reqResponse1);
        System.assertNotEquals(NULL, reqResponse2);
        System.assertEquals(TRUE, reqResponse1.success);
        System.assertEquals(FALSE, reqResponse2.success);
        System.assertEquals('', reqResponse1.errorMessage);
        System.assertNotEquals('', reqResponse2.errorMessage);
    }
}