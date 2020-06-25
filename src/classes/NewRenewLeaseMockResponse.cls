@istest
global class NewRenewLeaseMockResponse implements HttpCalloutMock {
    public string responseStr { get; set; }
    global NewRenewLeaseMockResponse(String responseJson){
        responseStr = responseJson;
    }
    global HttpResponse respond(HttpRequest req)
    {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(responseStr);
        res.setStatusCode(200);
        return res;
    }

}