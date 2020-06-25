@isTest
global class DDAIntegrationNameApprovalMock implements HttpCalloutMock {
	 global HTTPResponse respond(HTTPRequest req) {
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"CreateNameApprovalRequestResponse" : {"result" : [ {"errorMessage" : "","externalOLIID" : "","isSuccess" : "true", "oraclePartyId" : "","serviceRequestId" : "","workOrderId" : "0WOQ0000001bFUTOA2"} ]}}');
        res.setStatusCode(200);
        return res;
    }
}