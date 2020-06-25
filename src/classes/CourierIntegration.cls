@RestResource(urlMapping='/csrupdate/*')
global with sharing class CourierIntegration {
    
    @HttpPost
    global static void updateCourierServReq() {
        RestRequest req = RestContext.request;
        RestResponse res = Restcontext.response;
        System.debug('Request JSON : '+req.requestBody.toString());
        CourierIntegration ci = (CourierIntegration) System.JSON.deserialize(req.requestBody.toString(), CourierIntegration.class);
        System.debug('ci -> '+ci);
        Set<String> srNums = new Set<String>();
        Map<String,SRRequest> srMap = new Map<String,SRRequest>();
        for(SRRequest sr : ci.reqs){
            if(sr.SRN!=null && sr.SRN!=''){
                srNums.add(sr.SRN);
                srMap.put(sr.SRN,sr);
            }
        }
        List<SRResponse> responses = new List<SRResponse>();
        if(!srNums.isEmpty()){
            List<Courier_Request__c> axsRequests = [SELECT Id,Name,Status__c,Last_Updated_On__c,Service_Request_Number__c,Airway_Bill_Number__c FROM Courier_Request__c WHERE Service_Request_Number__c = :srNums];
            if(!axsRequests.isEmpty()){
                for(Courier_Request__c acr : axsRequests){
                    if(srMap.containsKey(acr.Service_Request_Number__c)){
                        String status = srMap.get(acr.Service_Request_Number__c).delStatus;
                        String timeSt = srMap.get(acr.Service_Request_Number__c).timeStamp;
                        acr.Source_System__c = srMap.get(acr.Service_Request_Number__c).sourceSystem;
                        acr.Airway_Bill_Number__c = srMap.get(acr.Service_Request_Number__c).AWB;
                        //acr.Status__c = srMap.get(acr.Service_Request_Number__c).status; //axs request status may not be required
                        acr.Status__c = srMap.get(acr.Service_Request_Number__c).delStatus;
                        acr.Last_Updated_On__c = DateTime.newInstance(Long.valueOf(timeSt));
                        acr.Integration_Status__c = 'Ready';
                        if(status.equalsIgnoreCase('at dispatcher')){
                            //acr.At_Dispatcher_Date__c = DateTime.newInstance(Long.valueOf(timeSt));
                        }else if(status.equalsIgnoreCase('At Hub')){
                            //acr.At_Hub_Date__c = DateTime.newInstance(Long.valueOf(timeSt));
                        }else if(status.equalsIgnoreCase('Out for Delivery')){
                            //acr.Out_For_Delivery_Date__c = DateTime.newInstance(Long.valueOf(timeSt));
                        }else if(status.equalsIgnoreCase('Delivered')){
                            //acr.Doc_Delivered_Date__c = DateTime.newInstance(Long.valueOf(timeSt));
                        }else if(status.equalsIgnoreCase('Return to Sender')){
                            //acr.Return_to_Sender_Date__c = DateTime.newInstance(Long.valueOf(timeSt));
                        }else if(status.equalsIgnoreCase('Allotted')){
                            //acr.Doc_Allotted_Date__c = DateTime.newInstance(Long.valueOf(timeSt));
                        }
                    }
                }
                try{
                    update axsRequests;
                    SRResponse respo = new SRResponse();
                    respo.respMsg = 'Success';
                    respo.respCode = '0';
                    String respStr = JSON.serialize(respo);
                    
                    res.responseBody = Blob.valueOf(respStr);
                }catch(Exception ex){
                    SRResponse respo = new SRResponse();
                    respo.respMsg = '#Error : '+ex.getMessage()+' #Line Number : '+ex.getLineNumber();
                    respo.respCode = '1';
                    String respStr = JSON.serialize(respo);
                    System.assertEquals(res+'', respStr);
                    res.responseBody = Blob.valueOf(respStr);
                }
            }else{
                SRResponse respo = new SRResponse();
                respo.respMsg = 'Courier request not found.';
                respo.respCode = 'DE_01';
                String respStr = JSON.serialize(respo);
                res.responseBody = Blob.valueOf(respStr);
            }
        }else{
            SRResponse respo = new SRResponse();
            respo.respMsg = 'Required field "Service Request Number" is missing.';
            respo.respCode = 'DE_01';
            String respStr = JSON.serialize(respo);
            res.responseBody = Blob.valueOf(respStr);
        }
    }
    
    public List<SRRequest> reqs;
    
    public class SRRequest{
        public String SRN;
        public String AWB;
        public String status;
        public String delStatus;
        public String timeStamp;
        public String sourceSystem;
    }
    
    public class SRResponse{
        public String SRN;
        public String respMsg;
        public String respCode;
        public String AWB;
        public String agNum;
    }
}