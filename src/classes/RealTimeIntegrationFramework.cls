/***********************************************************************************************
* Name              : RealTimeIntegrationFramework                                             
* Description       : Framework for invoking the real-time integrations to OIC endpoint
* Created Date      : 20/06/2019                                                    
* Created By        : Prachi Sinha (prachi.sinha@were4c.com)                                                                                                    
* ----------------------------------------------------------------------------------------------
* VERSION   Developer   Date        Description                                                                        
* 1.0       Prachi      20/06/2019   Created  
*2.0        Paza        09/07/2019    update the creedentials to named credentials
************************************************************************************************/

public with sharing class RealTimeIntegrationFramework{

    /************************************************************************************
    Method  :         sendLeaseToOIC 
    Description :     POST lease details to OIC endpoint
    Version :         1.0
    ************************************************************************************/
    public static httpResponse realTimeCall(String jsonRequest, String endpoint){ 
    
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        HttpResponse response = new HttpResponse();
        //request.setEndpoint(System.Label.OracleCustomerCreation);
        request.setEndpoint(endpoint);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        //change the below to named credential
        //String username = 'apeksha.r.rathore@oracle.com';
        //String password = 'Oracle@123456';
        //Blob headerValue = Blob.valueOf(username + ':' + password);
       // String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
       // request.setHeader('Authorization', authorizationHeader);
       	System.debug('jsonRequest:'+ jsonRequest);
        request.setBody(jsonRequest);
        System.debug('request:'+ request);
        request.setTimeout(120000);
        response = http.send(request);
        system.debug('body:'+ response.getbody());
        System.debug('response:'+ response);
        return response;
    }
    
}