@RestResource(urlMapping='/cdcollection/*')
global with sharing class CourierDocCollection {

    @HttpGet
    global static void getOpNoSchedules() {
        List<DocCollResponse> resps = new List<DocCollResponse>();
        RestRequest req = RestContext.request;
        RestResponse res = Restcontext.response;
        try{
            String oracleId = req.params.get('oracleId');
            if(oracleId!=null && oracleId!=''){
                for(Quote quote : [SELECT Id,Account.ORACLE_PARTY_ID__c,Opportunity.AG_Number__c,Status,Payment_Terms__r.No_of_Installments__c,Category__c FROM Quote WHERE Account.ORACLE_PARTY_ID__c =: OracleID AND Status = 'CCL Acceptance']){
                    DocCollResponse resp = new DocCollResponse();
                    resp.agNo =  ''+quote.Opportunity.AG_Number__c==null?'':quote.Opportunity.AG_Number__c;
                    resp.noChqs = quote.Payment_Terms__r.No_of_Installments__c==null?'':''+quote.Payment_Terms__r.No_of_Installments__c;
                    resp.oracleId = ''+oracleId;
                    resp.category = ''+quote.Category__c==null?'':quote.Category__c;
                    resp.isSuccess = true;
                    resp.errorMessage = '';
                    resps.add(resp);
                }
                String respStr = JSON.serialize(resps);
                System.debug('respStr :- '+respStr);
                res.responseBody = Blob.valueOf(respStr);
            }else{
                DocCollResponse resp = new DocCollResponse();
                resp.isSuccess = false;
                resp.errorMessage = 'Required parameter missing : Oracle Party ID';
                String respStr = JSON.serialize(new List<DocCollResponse>{resp});
                res.responseBody = Blob.valueOf(respStr);
            }
        }catch(Exception ex){
            DocCollResponse resp = new DocCollResponse();
            resp.isSuccess = false;
            resp.errorMessage = ex.getStackTraceString();
            String respStr = JSON.serialize(new List<DocCollResponse>{resp});
            res.responseBody = Blob.valueOf(respStr);
        }
    }
    
    public class DocCollResponse{
        public String agNo;
        public String noChqs;
        public String oracleId;
        public String category;
        public Boolean isSuccess;
        public String errorMessage;
    }
    
    @HttpPost
    global static void createDocCollServReq() {
        RestRequest req = RestContext.request;
        RestResponse res = Restcontext.response;
        System.debug('Request JSON : '+req.requestBody.toString());
        CourierDocCollection ci = (CourierDocCollection) System.JSON.deserialize(req.requestBody.toString(), CourierDocCollection.class);  
        System.debug('CourierDocCollection============>> ' + ci);
        Set<String> srNums = new Set<String>();
        Map<String,SRRequest> srMap = new Map<String,SRRequest>();
        for(SRRequest sr : ci.reqs){
            if(sr.agNo!=null && sr.agNo!='' && sr.SRN!=null && sr.SRN!=''){
                List<String> agNums = new List<String>();
                String agChqStr = sr.agNo.replace(',','_');
                agNums = agChqStr.split('_');
                Map<String,Decimal> noOfSchPerAg = new Map<String,Decimal>();
                for(String str : agNums){
                    List<String> agChqs = new List<String>();
                    agChqs = str.split(':');
                    noOfSchPerAg.put(agChqs[0],Decimal.valueOf(agChqs[1]));
                }
                if(!agNums.isEmpty()){
                    Courier_Request__c cReq = new Courier_Request__c();
                    cReq.Service_Request_Number__c = sr.SRN;
                    cReq.Airway_Bill_Number__c = sr.AWB=='null'?'':sr.AWB;
                    cReq.Status__c = sr.delStatus;
                    cReq.Source_System__c = sr.sourceSystem==null?'CorpCRM':sr.sourceSystem;
                    String timeSt = sr.timeStamp;
                    cReq.Last_Updated_On__c = DateTime.newInstance(Long.valueOf(timeSt));
                    cReq.Integration_Status__c = 'Ready';
                    if(sr.delStatus.equalsIgnoreCase('at dispatcher')){
                        //cReq.At_Dispatcher_Date__c = DateTime.newInstance(Long.valueOf(timeSt));
                    }else if(sr.delStatus.equalsIgnoreCase('At Hub')){
                        //cReq.At_Hub_Date__c = DateTime.newInstance(Long.valueOf(timeSt));
                    }else if(sr.delStatus.equalsIgnoreCase('Out for Delivery')){
                        //cReq.Out_For_Delivery_Date__c = DateTime.newInstance(Long.valueOf(timeSt));
                    }else if(sr.delStatus.equalsIgnoreCase('Delivered')){
                        //cReq.Doc_Delivered_Date__c = DateTime.newInstance(Long.valueOf(timeSt));
                    }else if(sr.delStatus.equalsIgnoreCase('Return to Sender')){
                        //cReq.Return_to_Sender_Date__c = DateTime.newInstance(Long.valueOf(timeSt));
                    }else if(sr.delStatus.equalsIgnoreCase('Allotted')){
                        //cReq.Doc_Allotted_Date__c = DateTime.newInstance(Long.valueOf(timeSt));
                    }else if(sr.delStatus.equalsIgnoreCase('Out For Collection')){
                        //cReq.Out_For_Collection_Date__c = DateTime.newInstance(Long.valueOf(timeSt));
                    }
                    cReq.Account_Name__c = sr.acName;
                    cReq.Contact_Name__c = sr.conName;
                    cReq.Oracle_Party_ID__c = sr.oracleId;
                    cReq.Document_Type__c = sr.docType;
                    cReq.Reference_Mobile__c = sr.refMobile;
                    cReq.Delivery_Zone__c = sr.delZone;
                    cReq.Building_Name__c = sr.bldngName;
                    cReq.Delivery_Location__c = sr.delLoc;
                    cReq.Notes__c = sr.notes;
                    cReq.AXS_Request_Id__c = sr.axsReqId;
                    cReq.Agreement_Num__c = sr.agNo;
                    cReq.Number_Of_Cheques__c = Decimal.valueOf(sr.noCheques);
                    System.Savepoint sp = Database.setSavepoint();
                    try{
                        insert cReq;
                        SRResponse respo = new SRResponse();
                        respo.respMsg = 'Success';
                        respo.respCode = '0';
                        String respStr = JSON.serialize(respo);
                        res.responseBody = Blob.valueOf(respStr);
                    }catch(Exception ex){
                        Database.rollback(sp);
                        SRResponse respo = new SRResponse();
                        respo.respMsg = '#Error : '+ex.getMessage()+' #Line Number : '+ex.getLineNumber();
                        respo.respCode = '1';
                        String respStr = JSON.serialize(respo);
                        res.responseBody = Blob.valueOf(respStr);
                    }
                }
            }else{
                SRResponse respo = new SRResponse();
                if(sr.agNo==null && sr.agNo=='' && sr.SRN!=null && sr.SRN!=''){respo.respMsg = 'Required field "Opportunity Id" is missing.';
                }else if(sr.agNo!=null && sr.agNo!='' && sr.SRN==null && sr.SRN==''){respo.respMsg = 'Required field "Service Request Number" is missing.';
                }else if(sr.agNo==null && sr.agNo=='' && sr.SRN==null && sr.SRN==''){respo.respMsg = 'Required fields "Service Request Number" and "Opportunity Id" are missing.';
                }
                respo.respCode = 'DE_01';
                String respStr = JSON.serialize(respo);
                res.responseBody = Blob.valueOf(respStr);
            }
        }
    }
    
    public List<SRRequest> reqs;
    
    public class SRRequest{
        public String SRN;
        public String AWB;
        public String status;
        public String delStatus;
        public String timeStamp;
        public String acName;
        public String conName;
        public String oracleId;
        public String docType;
        public String refMobile;
        public String delZone;
        public String bldngName;
        public String delLoc;
        public String notes;
        public String axsReqId;
        public String noCheques;
        public String agNo;
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