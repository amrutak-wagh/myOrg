/**
 *  @description This class is invoked via a Document process on document create with Name 'Provisional Approval Letter'
 *
 *  2019-07-26  Amruta K   First version
 * 
 */
global without sharing class CongaBackground {        
	
    // Method to call from process builder of Document record and call method to attach file to document.
    @InvocableMethod
    public static void callWebservice(List<Document__c> docList){
        CongaBackgroundMode(docList[0].Id);
    }
    
    // Method to attach conga document as file to document object record.
    @future(callout=true)
    public static void CongaBackgroundMode(String docObj) {
        String result;
        String sessId = UserInfo.getSessionId();
        String servUrl = 
            Url.getSalesforceBaseUrl().toExternalForm()+'/services/Soap/u/29.0/'+UserInfo.getOrganizationId();
        String curl = 'https://composer.congamerge.com'+
            '?sessionId='+UserInfo.getSessionId()+
            '&serverUrl='+EncodingUtil.urlEncode(servUrl, 'UTF-8')+
            '&id='+docObj+
            '&TemplateId='+ System.Label.CCL_Generation_Template_Id + 
            '&DS7=1'+
            '&APIMode=1'+
            '&SC0=1'+
            '&SC1=SalesforceFile';
        
        System.debug(curl);
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(curl);
        req.setMethod('GET');
        req.setTimeout(60000);
        
        // Send the request, and return a response
        HttpResponse res = http.send(req);
        If(res.getStatusCode() == 301 || res.getStatusCode() == 302)
        {    
            req.setEndpoint(res.getHeader('Location'));
            res = new Http().send(req);
        }
    }
}