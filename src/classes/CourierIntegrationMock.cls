@isTest
global class CourierIntegrationMock implements HttpCalloutMock{
     // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"processLeaseItemsResponse" : {"result" : [ {"errorMessage" : "","externalOLIID" : "","isSuccess" : "true", "oraclePartyId" : "","serviceRequestId" : "" } ]}}');
        res.setStatusCode(200);
        return res;
    }
}