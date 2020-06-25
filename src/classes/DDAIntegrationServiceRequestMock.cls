@isTest
global class DDAIntegrationServiceRequestMock implements HttpCalloutMock {
    //WorkOrder data
    @isTest
    global static Id workOrderSetUp(){
        Case caseObject = new Case(Status = 'New');
        insert caseObject;
        Account accountObject = new Account(Name = 'Test',Phone='1111111', Legal_Framework__c = 'Branch of a Foreign Company', Security_Clearance_Date__c = Date.today(), Security_Clearance_Status__c = 'NA', Business_Plan_Request_Date_Approval_Date__c = Date.today());
        insert accountObject;
        Contact contactObject = new Contact(LastName = 'Test',Email = 'test.mail@test.com', isSubmit__c = true, ParentCon__c = true, AccountId= accountObject.Id ,Type__c = 'Billing;Leasing Contact;Licensee Contact;Manager Incharge');
        insert contactObject;
        WorkOrder workOrderObject = new WorkOrder(Status = 'New', 
                                     Description = 'test Description', 
                                     AccountId = accountObject.Id, 
                                     CaseId = caseObject.Id, 
                                     Skip_Lease_Validation__c = true, 
                                     Work_Order_Number__c = 1, 
                                     Account_Type__c = 'Trust Account', 
                                     Minimum_Required_Share_Capital__c = 10000,
                                     IsMovedToNextStep__c = true);
        insert workOrderObject; 
        return workOrderObject.Id;
    }
	// Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        Id workOrderId = workOrderSetUp();
       
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"CreateNewServiceRequestResponse" : {"result" : [ {"errorMessage" : "","externalOLIID" : "","isSuccess" : "true", "oraclePartyId" : "","serviceRequestId" : "", "workOrderId" :"'+ workOrderId +'" ,"requestName":"test","requestId":""} ]}}');
        res.setStatusCode(200);
        return res;
    }
}