@IsTest
global class RealTimeIntegrationFrameworkTest implements HttpCalloutMock {
    
    global HTTPResponse respond(HTTPRequest request) {
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"result": "abc"}');
        response.setStatusCode(200);
        return response; 
    }
    
    @isTest static void testPostCallout() {
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new RealTimeIntegrationFrameworkTest()); 
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock. 
        HttpResponse response = RealTimeIntegrationFramework.realTimeCall('test','test2');
        System.assertEquals(200, response.getStatusCode());
    }
}