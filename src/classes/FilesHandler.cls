/*
 * Created by : Misbah
 * Creted Date: 
 * 
 * Desription: It is Api for yardi to get the document details from Salesforce and post the document to Salesforce from yardi
 * 
 * Updated by : Raza Khan (raza.khan@weare4c.com)
 * Dated : 18-06-2019
 * Description: Update the methods as the json trying to build was giving errors
 * 
 * Updated by: Raza khan (raza.khan@weare4c.com)
 * Dated: 07-07-2019
 * Desription: created the wrapper class for the json response that needs to be sent to the yardi for the get method and use that populated the 
 * rcords so yardi could parse the reponse 
 * Dated: 18-08-2018
 * Description: update the class to have capability and description in response and be able to filter it.
 * 
 * */

@RestResource(urlMapping='/files/*')
global with sharing class FilesHandler 
{
    /*
     * Method :  donGet
     * Updated by : Raza - update the method to use the wrapper class for building the response and send the wrapper class as a reponse
     * 
     * */
    @HttpGet
    global static filesDetail doGet() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        system.debug('URI:'+ req.requestURI);
        String parentId = req.params.get('Id'); //req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        List<String> categoryparm = new List<String>();//req.params.get('category');
        string category = req.params.get('category');
        /*if(categoryparm.size() > 1){
            parentId = categoryparm.get(0);
            category =  categoryparm.get(1).split('=').get(1);
            System.debug('category:'+ category);
        }*/
         System.debug('category:'+ category);
        System.debug('parentId:'+ parentId);
       // JSONGenerator jsGen = JSON.createGenerator(true);
        
        filesDetail details = new filesDetail();
       // jsGen.writeStartObject();
        if(parentId != null)
        {
            details.isSuccess = true;
           // jsGen.writeBooleanField('IsSuccess', true);
           // //[SELECT   Id, Name,Public_link__c,Category__c, Description__c FROM Document__c  Where parentId__c=:parentId]
           string query = 'SELECT   Id, Name,Public_link__c,Category__c, Description__c FROM Document__c  Where parentId__c=:parentId';
            if(category != '')
            {
                query += ' And Category__c =:category';
            }
            system.debug('query:'+ query);
            List<Document__c> lstDocuments = Database.query(query);
            details.numberOfRecords = lstDocuments.size();
              List<Record> records = new List<Record>();
            for(Document__c d: lstDocuments)
            {
                Record r = new Record();
                r.recordId = d.id;
                r.name =d.name;
                r.publicLink= d.Public_link__c;
                r.category = d.Category__c;
                r.description = d.Description__c;
                records.add(r);
            }
            details.records = records;
            /*jsGen.writeNumberField('NumberOfRecords',lstDocuments.size());
           // jsGen.writeString('Records');
            jsGen.writeFieldname('Records'); 
            jsGen.writeStartArray();
                jsGen.writeObject(lstDocuments);
            jsGen.writeEndArray();*/
        }
        else
        {
             details.isSuccess = true;
            details.numberOfRecords = 0;
            details.error = 'Invalid/Missing Parent Id';
            /*jsGen.writeBooleanField('IsSuccess', false);
            jsGen.writeNumberField('NumberOfRecords',0);
            jsGen.writeStringField('Error','Invalid/Missing Parent Id');  */          
        }
       // jsGen.writeStartObject();
       //	jsGen.writeEndObject();
       //JSON.serializePretty(details);
        return details; //JSON.serializePretty(details);
    }
  	/*
  	 * Method : doPost
  	 * 
  	 * Updated by : Raza - this method is used by yardi to pass the document to salesforce and document record will be created for it.
  	 * 
  	 * */
    @HttpPost
    global static JsonResponse doPost(Map<String,String> Params) 
    {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        JsonResponse jsRes = new JsonResponse(false,'','','Unknown Method',200);
     
        String functionName = req != null? req.requestURI.substring(req.requestURI.lastIndexOf('/')+1): ''; // req.requestURI.subString(0,req.requestURI.lastIndexOf('/')); 
        system.debug('functionName:'+ functionName);
        
        if(functionName.toLowerCase() == 'upload' || test.isRunningTest())
        {
            jsRes = uploadAttachment(Params);
        }
        return jsRes;        
    }
	
    /*
  	 * Method : uploadAttachment
  	 * 
  	 * Updated by : Raza - updated the method for inserting the contentdistribution and populate that on the document record as on public link field. 
  	 *  18/08/2019 - Raza - update to retrieve category and description and set it on the document object.
  	 * */
    public static JsonResponse uploadAttachment(Map<String,String> Params)
    {        
        try 
        {
            JsonResponse res;// = new JsonResponse();
            Id parentId = Params.get('ParentId');
            String fileName = Params.get('FileName');
            String fileType = Params.get('FileType');
            String base64String = Params.get('Base64String');
            String category = Params.get('Category');
            String description = Params.get('Description');
            Blob fileBody = EncodingUtil.base64Decode(base64String);

            //Insert a Document Record based on File Type
            Document__c doc = new Document__c();
            doc.Category__c = category;
            doc.Description__c = description;
            doc.Name = filename;
            insert doc;  

            //Insert a Content Version
            ContentVersion cv = new ContentVersion();
            cv.ContentLocation = 'S';            
            cv.VersionData = fileBody;
            cv.Title = fileName;
            cv.PathOnClient = filename;
            insert cv;
            
            ContentDistribution cd = new ContentDistribution();
            cd.Name = cv.PathOnClient;
            cd.ContentVersionId = cv.id;
            cd.PreferencesAllowViewInBrowser= true;
            cd.PreferencesLinkLatestVersion=true;
            cd.PreferencesNotifyOnVisit=false;
            cd.PreferencesPasswordRequired=false;
            cd.PreferencesAllowOriginalDownload= true;
            insert cd;

            //Insert a Content Document Link
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: cv.Id].ContentDocumentId;
            cdl.LinkedEntityId = doc.id;//parentId;
            cdl.ShareType = 'I';
            insert cdl;

            //Add Content Document Link to the Document Record;
            doc.Linked_File_Id__c = cdl.Id;
            doc.parentId__c = parentId;
            doc.Public_link__c = [SELECT Id, DistributionPublicUrl FROM ContentDistribution where ContentVersionId =: cv.id].DistributionPublicUrl;
            update Doc;

            res = new JsonResponse(true,'File',cdl.Id,'',200);
            return res;
        } 
        catch (Exception ex)
        {            
            return new JsonResponse(false,'','',ex.getMessage(),500);
        }
    }
    
    // this is the wrapper class for the file details
    global class filesDetail{
        public boolean isSuccess;
        public integer numberOfRecords;
        public List<Record> records;
        public string error;
        
        
    }
   // this is the wrapper class for each file details
    global class Record{
        Public string recordId;
        public string name;
        public string publicLink;
        public string category;
        public string description;
        
    }
    global class JsonResponse
    {
        public Boolean Success {get;set;}
        public String ObjectName {get;set;}
        public String ObjectID {get;set;}
        public String Error {get;set;}
        public Integer ResponseCode {get;set;}
        
        public JsonResponse(Boolean iSuccess,String iObjectName,String iOBjectID,String ierror,Integer rCode)
        {
            success = iSuccess;
            ObjectName = iObjectName;
            ObjectID = iObjectID;
            error = iError;
            responseCode = rCode;
        }

        public JsonResponse(){}
    }

    @AuraEnabled(cacheable=true)
    public static List<Document__c> getAllDocuments(String ParentId)
    {
        List<Document__c> lstDocuments = new List<Document__c>([Select Id,Name,createdDate,ParentId__c,Linked_File_Id__c from Document__c Where parentId__c=:parentId]);
        return lstDocuments;
    }    

}