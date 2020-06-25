public class DDAIntegration {
    public static HttpResponse postJSONRequest(String endPoint, String body){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endPoint);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        String username = 'apeksha.r.rathore@oracle.com';
        String password = 'Oracle@123456';
        Blob headerValue = Blob.valueOf(username + ':' + password);
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        request.setHeader('Authorization', authorizationHeader);
        request.setTimeout(60000);
        request.setBody(body);
        return http.send(request);
    }
    
    @future(callout=true)
    public static void createNameApprovalRequest(Set<Id> workOrderIds){
        Map<Id,WorkOrder> workOrderMap = new Map<Id,WorkOrder>([SELECT Id,DDA_Request_Number__c,Account.License_Business_Park__r.Name,Account.Legal_Framework__c,Proposed_Name_of_Business_1st_choice__c,Proposed_Name_of_Business_2nd_choice__c,Proposed_Name_of_Business_3rd_choice__c,Account.Owner.Email,Account.Owner.Name FROM WorkOrder WHERE Id IN :workOrderIds]);
        List<DDAIntegrationWrapper.NameApprovalRequest> reqs = new List<DDAIntegrationWrapper.NameApprovalRequest>();
        for(WorkOrder wo :workOrderMap.values()){
            DDAIntegrationWrapper.NameApprovalRequest narReq = new DDAIntegrationWrapper.NameApprovalRequest();
            narReq.businessPark = wo.Account.License_Business_Park__r.Name;
            narReq.legalStructure = wo.Account.Legal_Framework__c;
            narReq.name1 = wo.Proposed_Name_of_Business_1st_choice__c;
            narReq.name2 = wo.Proposed_Name_of_Business_2nd_choice__c;
            narReq.name3 = wo.Proposed_Name_of_Business_3rd_choice__c;
            narReq.NARNo = wo.DDA_Request_Number__c;
            narReq.requestorEmail = wo.Account.Owner.Email;
            narReq.requestorName = wo.Account.Owner.Name;
            narReq.workOrderId = wo.Id;
            reqs.add(narReq);
        }
        try{
            JSONGenerator gen = JSON.createGenerator(false);
            gen.writeStartObject();
            gen.writeFieldName('CreateNameApprovalRequest');
            gen.writeStartObject();
            gen.writeObjectField('narRequest', reqs);
            gen.WriteEndObject();
            gen.WriteEndObject();
            System.HttpResponse response = DDAIntegration.postJSONRequest(Label.OIC_NAR_Request_Endpoint, gen.getAsString());
            System.debug('response '+response.getBody());
            if(response.getStatusCode() == 200){
                Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody()); 
                System.debug('response====='+response.getBody());
                Map<String, Object> obj = (Map<String, Object>) results.get('CreateNameApprovalRequestResponse');
                for(Object asd : (List<Object>) obj.get('result')){
                    Map<String, Object> valuesMap = (Map<String, Object>) asd;
                    String workOrderId = String.valueOf(valuesMap.get('workOrderId'));
                    if(Boolean.valueOf(valuesMap.get('isSuccess'))){
                        workOrderMap.get(workOrderId).DDA_Request_Number__c = String.valueOf(valuesMap.get('NARNo'));
                        workOrderMap.get(workOrderId).DDA_Request_Id__c = String.valueOf(valuesMap.get('DDAID'));
                        workOrderMap.get(workOrderId).Status = String.valueOf(valuesMap.get('status'));
                        workOrderMap.get(workOrderId).Integration_Status__c = 'Success';
                    }else{
                        workOrderMap.get(workOrderId).Integration_Error_Message__c = String.valueOf(valuesMap.get('errorMessage'));
                    }
                }
                update workOrderMap.values();
            }
        }catch(Exception ex){
            
        }
    }
    
    @future(callout=true)
    public static void createNewServiceRequest(Set<Id> workOrderIds, Boolean convertToTrustAccount, Boolean moveToNextStep){
        Set<Id> accountIds = new Set<Id>();
        Map<Id,List<Requested_Licensed_Activity__c>> reqActivities = new Map<Id,List<Requested_Licensed_Activity__c>>();
        for(Requested_Licensed_Activity__c rla : [SELECT Id,Activity__r.Name,Activity__r.RnL_Activity_SF_ID__c,Work_Order__c FROM Requested_Licensed_Activity__c WHERE Type__c = 'Requested Activity' AND Work_Order__c IN :workOrderIds]){
            if(reqActivities.containsKey(rla.Work_Order__c)){
                reqActivities.get(rla.Work_Order__c).add(rla);
            }else{
                reqActivities.put(rla.Work_Order__c,new List<Requested_Licensed_Activity__c>{rla});
            }
        }
        Map<Id,WorkOrder> workOrderMap = new Map<Id,WorkOrder>([SELECT Skip_Lease_Validation__c,DDA_Request_Id__c,WorkOrderNumber,Id,Account.Name_Approval_Request_Number__c,Account.Legal_Name__c,Account.Operating_Name_Arabic__c,Account.ORACLE_PARTY_ID__c, Account.Oracle_Party_Number__c, Account.License_Business_Park__r.Name, Account.Legal_Framework__c, Account.Account_Type__c, Account.Phone, Account.Owner.Name, Account.DED_Initial_Approval_Number__c, Account.Owner.Email, Account.DED_Trade_License_number__c, Account.Security_Clearance_Date__c, Account.Manager_In_Charge__r.Email, Account.Business_Plan_Request_Date_Approval_Date__c FROM WorkOrder WHERE Id IN :workOrderIds]);
        for(WorkOrder wo :workOrderMap.values()){
            accountIds.add(wo.AccountId);
        }
        Map<Id,List<Contact>> contactsMap = new Map<Id,List<Contact>>();
        for(Contact con : [SELECT Id,Birthdate,AccountId,Type__c,Date_Of_Incorporation__c,Email,FirstName,Gender__c,LastName,Legal_Name__c,Name,Nationality__r.Name,Passport_Expiry_Date__c,Passport_Issue_Date__c,Passport_No__c,Position__c,Registration_No__c,Salutation,Statutory_Seat__c FROM Contact WHERE AccountId IN :accountIds]){
            if(contactsMap.containsKey(con.AccountId)){
                contactsMap.get(con.AccountId).add(con);
            }else{
                contactsMap.put(con.AccountId, new List<Contact>{con});
            }
        }
        List<DDAIntegrationWrapper.ServiceRequest> reqs = new List<DDAIntegrationWrapper.ServiceRequest>();
        for(WorkOrder wo :workOrderMap.values()){
            DDAIntegrationWrapper.ServiceRequest servReq = new DDAIntegrationWrapper.ServiceRequest();
            servReq.requestId = wo.DDA_Request_Id__c==null?'':wo.DDA_Request_Id__c;
            servReq.skipLeaseValidation = wo.Skip_Lease_Validation__c;
            servReq.convertToTrustAccount = convertToTrustAccount==null?false:convertToTrustAccount;
            servReq.isMovetonextStep = moveToNextStep==null?false:moveToNextStep;
            servReq.workorderName = wo.WorkOrderNumber;
            servReq.workorderId = wo.Id;
            servReq.narno = wo.Account.Name_Approval_Request_Number__c;
            servReq.serviceName = '6-New Registration';
            servReq.approvedName = wo.Account.Legal_Name__c;
            servReq.approvedArabicName = wo.Account.Operating_Name_Arabic__c;
            servReq.oraclePartyId = String.valueOf(wo.Account.ORACLE_PARTY_ID__c);
            servReq.oraclePartyNo = wo.Account.Oracle_Party_Number__c;
            servReq.businessUnit = wo.Account.License_Business_Park__r.Name;
            servReq.legalFramework = wo.Account.Legal_Framework__c;
            servReq.accountType = wo.Account.Account_Type__c;
            servReq.bpMobileNo = wo.Account.Phone;
            servReq.salesPerson = wo.Account.Owner.Name;
            servReq.companyLeaseType = '';
            servReq.DEDInitialApprovalName = wo.Account.DED_Initial_Approval_Number__c;
            servReq.contactEmail = wo.Account.Owner.Email;
            servReq.DEDTradeLicenseNo = wo.Account.DED_Trade_License_number__c;
            servReq.contactPerson = '';
            servReq.securityClearanceDate = wo.Account.Security_Clearance_Date__c;
            servReq.securityClearanceExpiryDate = wo.Account.Security_Clearance_Date__c==null?null:wo.Account.Security_Clearance_Date__c.addDays(60);
            servReq.isSercurityApproved = TRUE;
            servReq.securityClearanceStatus = 'Approved';
            servReq.managerInchargeEmail = wo.Account.Manager_In_Charge__r.Email;
            servReq.businessPlanApprovalDate = wo.Account.Business_Plan_Request_Date_Approval_Date__c;
            servReq.businessPlanApprovalStatus = 'Approved';
            
            List<DDAIntegrationWrapper.RequestRelation> reqRelations = new List<DDAIntegrationWrapper.RequestRelation>();
            for(Contact con : contactsMap.get(wo.AccountId)){
                DDAIntegrationWrapper.RequestRelation rr = new DDAIntegrationWrapper.RequestRelation();                
                rr.birthDate = con.Birthdate;
                rr.dateOfIncorporation = con.Date_Of_Incorporation__c;
                rr.email = con.Email;
                rr.externalCRMID = con.Id;
                rr.firstName = con.FirstName;
                rr.gender = con.Gender__c;
                rr.lastName = con.LastName;
                rr.legalName = con.Legal_Name__c;
                rr.name = con.Name;
                rr.nationality = con.Nationality__r.Name;
                rr.passportExpiryDate = con.Passport_Expiry_Date__c;
                rr.passportIssueDate = con.Passport_Issue_Date__c;
                rr.passportNo = con.Passport_No__c;
                rr.position = con.Type__c;
                rr.registrationNo = con.Registration_No__c;
                rr.salutation = con.Salutation;
                rr.StatutorySeat = con.Statutory_Seat__c;
                reqRelations.add(rr);
            }
            servReq.requestRelations = reqRelations;
            List<DDAIntegrationWrapper.RequestedActivity> requestedActivity = new List<DDAIntegrationWrapper.RequestedActivity>();
            if(reqActivities.containsKey(wo.Id)){
                for(Requested_Licensed_Activity__c rla : reqActivities.get(wo.Id)){
                    DDAIntegrationWrapper.RequestedActivity ra = new DDAIntegrationWrapper.RequestedActivity();
                    ra.DDAActivityID = rla.Activity__r.RnL_Activity_SF_ID__c;
                    ra.externalCRMID = rla.Id;
                    requestedActivity.add(ra);
                }
            }
            servReq.requestActivities = requestedActivity;
            reqs.add(servReq);
        }
        JSONGenerator gen = JSON.createGenerator(false);
        gen.writeStartObject();
        gen.writeFieldName('CreateNewServiceRequest');
        gen.writeStartObject();
        gen.writeObjectField('requestList', reqs);
        gen.WriteEndObject();
        gen.WriteEndObject();
        System.HttpResponse response = DDAIntegration.postJSONRequest(Label.OIC_Service_Request_Endpoint, gen.getAsString());
        System.debug('response==> ' + response);
        if(response.getStatusCode() == 200){
            List<Document__c> documentsToInsert = new List<Document__c>();
            Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            System.debug('response::'+response.getBody());
            Map<String, Object> obj = (Map<String, Object>) results.get('CreateNewServiceRequestResponse');
            System.debug('obj=='+obj);
            for(Object srResponse : (List<Object>) obj.get('result')){
                Map<String, Object> valuesMap = (Map<String, Object>) srResponse;
                System.debug('valuesMap---------> ' + valuesMap);
                System.debug('requestName============> ' + String.valueOf(valuesMap.get('requestName')));
                System.debug('workOrderId============> ' + String.valueOf(valuesMap.get('workOrderId')));
                String workOrderId = String.valueOf(valuesMap.get('workOrderId'));
                
                if(Boolean.valueOf(valuesMap.get('isSuccess'))){
                    if(!moveToNextStep){
                        System.debug('DDA_Request_Number__c============> ' + workOrderMap.get(workOrderId).DDA_Request_Number__c);
                        workOrderMap.get(workOrderId).DDA_Request_Number__c = String.valueOf(valuesMap.get('requestName'));
                        workOrderMap.get(workOrderId).DDA_Request_Id__c = String.valueOf(valuesMap.get('requestId'));
                        workOrderMap.get(workOrderId).Integration_Status__c = 'Success';
                        for(Object docs : (List<Object>) valuesMap.get('docs')){
                            Map<String, Object> documentsMap = (Map<String, Object>) docs;
                            Document__c doc = new Document__c();
                            doc.Name = String.valueOf(documentsMap.get('docName')).length()>80?String.valueOf(documentsMap.get('docName')).substring(0, 80):String.valueOf(documentsMap.get('docName'));
                            doc.DDA_Document_Id__c = String.valueOf(documentsMap.get('DDAattachmentID'));
                            doc.Is_Mandatory__c = Boolean.valueOf(documentsMap.get('isMandatory'));
                            doc.Work_Order__c = workOrderId;
                            doc.Description__c = String.valueOf(documentsMap.get('docName'));
                            documentsToInsert.add(doc);
                        }
                    }
                }else{
                    workOrderMap.get(workOrderId).Integration_Error_Message__c = String.valueOf(valuesMap.get('errorMessage'));
                }
            }
            update workOrderMap.values();
            if(!documentsToInsert.isEmpty()){
                insert documentsToInsert;
            }
        }
    }
    
    @future(callout=true)
    public static void processLeaseItems(Set<Id> quoteIds){
        List<DDAIntegrationWrapper.Lease> leases = new List<DDAIntegrationWrapper.Lease>();
        List<Quote> quotes = [SELECT Id,Account.License__c,Account.ORACLE_PARTY_ID__c,Status,Proposed_Start_Date__c,Proposed_End_Date__c,Opportunity.AG_Number__c,Opportunity.Business_Park__r.Name,Type__c,Opportunity.Type,Opportunity.Lease_Type__c,(SELECT Id,Area__c,Is_Registered_Address__c,Product2.Building__r.Plot__r.Name,Product2.Unit_Sub_Category__r.Name,Product2.Unit_Sub_Category__r.Unit_Category__r.Name,Product2.Unit__r.Unit_No_English__c,Product2.Unit__r.Unit_No_Arabic__c,Product2.Unit__r.Floor_English__c,Product2.Unit__r.Floor_Arabic__c,Product2.Building__r.Building_Name_English__c,Product2.Building__r.Building_Name_Arabic__c,Product2.Unit__c,Product2.Building__c FROM QuoteLineItems WHERE Revision_Number__c = null) FROM Quote WHERE Id IN :quoteIds];
        if(!quotes.isEmpty()){
            Map<Id,String> serviceReqIdMap = new Map<Id,String>();
            for(Quote q : quotes){
                if(q.Account.License__c==null){
                    serviceReqIdMap.put(q.AccountId,'');
                }
            }
            for(WorkOrder wo : [SELECT Id,DDA_Request_Id__c,AccountId FROM WorkOrder WHERE AccountId IN :serviceReqIdMap.keySet() AND RecordType.Name = 'License Registration Request']){
                serviceReqIdMap.put(wo.AccountId,wo.DDA_Request_Id__c);
            }
            for(Quote q : quotes){
                DDAIntegrationWrapper.Lease lease = new DDAIntegrationWrapper.Lease();
                lease.oraclePartyId = q.Account.ORACLE_PARTY_ID__c;
                lease.licenseNo = q.Account.License__c==null?'':q.Account.License__c;
                lease.serviceRequestId = '';
                if(serviceReqIdMap.containsKey(q.AccountId) && q.Account.License__c==null){
                    lease.serviceRequestId = serviceReqIdMap.get(q.AccountId);
                }
                lease.opportunityStage = q.Status;
                lease.leaseStartDate = q.Proposed_Start_Date__c;
                lease.leaseEndDate = q.Proposed_End_Date__c;
                lease.leaseTerminationDate = null;//Need to check
                lease.contractStatus = '';
                lease.contractStatusReason = '';
                lease.agreementNo = q.Opportunity.AG_Number__c;
                lease.businessPark = q.Opportunity.Business_Park__r.Name;
                lease.oppType = q.Opportunity.Type;//New, renew etc
                lease.leasetype = q.Opportunity.Lease_Type__c;//pms etc
                lease.originalAggrement = '';
                lease.leaseItems = new List<DDAIntegrationWrapper.LeaseItem>();
                for(QuoteLineItem qLine : q.QuoteLineItems){
                    DDAIntegrationWrapper.LeaseItem item = new DDAIntegrationWrapper.LeaseItem();
                    item.externalOLIID = qLine.Id;
                    item.area = qLine.Area__c;
                    item.plot = qLine.Product2.Building__r.Plot__r.Name;
                    item.subCategory = qLine.Product2.Unit_Sub_Category__r.Name;
                    item.category = item.subCategory = qLine.Product2.Unit_Sub_Category__r.Unit_Category__r.Name;
                    item.unitNoEnglish = qLine.Product2.Unit__r.Unit_No_English__c;
                    item.unitNoArabic = qLine.Product2.Unit__r.Unit_No_Arabic__c;
                    item.floorEnglish = qLine.Product2.Unit__r.Floor_English__c;
                    item.floorArabic = qLine.Product2.Unit__r.Floor_Arabic__c;
                    item.propertyEnglish = qLine.Product2.Building__r.Building_Name_English__c;
                    item.propertyArabic = qLine.Product2.Building__r.Building_Name_Arabic__c;
                    item.propertyUnitId = qLine.Product2.Unit__c;
                    item.propertyId = qLine.Product2.Building__c;
                    item.isRegisteredAddress = qLine.Is_Registered_Address__c;
                    lease.leaseItems.add(item);
                }
                leases.add(lease);
            }
            JSONGenerator gen = JSON.createGenerator(false);
            gen.writeStartObject();
            gen.writeFieldName('processLeaseItems');
            gen.writeStartObject();
            gen.writeObjectField('leaseData', leases);
            gen.WriteEndObject();
            gen.WriteEndObject();
            System.debug(''+gen.getAsString());
            System.HttpResponse response = DDAIntegration.postJSONRequest(Label.OIC_Lease_Items_Endpoint, gen.getAsString());
            System.debug('response :- '+response.getBody());
            List<DDAIntegrationWrapper.LeaseItemResponse> leaseItemResponses = new List<DDAIntegrationWrapper.LeaseItemResponse>();
            if(response.getStatusCode() == 200){
                Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());                
                Map<String, Object> obj = (Map<String, Object>) results.get('processLeaseItemsResponse');
                for(Object res : (List<Object>) obj.get('result')){
                    Map<String, Object> valuesMap = (Map<String, Object>) res;
                    if(Boolean.valueOf(valuesMap.get('isSuccess'))){
                        
                    }else{
                        
                    }
                }
            }
        }
    }
    
    @future(callout=true)
    public static void processAttachment(Set<Id> contentDocumentIds){
        List<DDAIntegrationWrapper.ProcessAttachment> attachments = new List<DDAIntegrationWrapper.ProcessAttachment>();
        Map<Id, Document__c> documentsMap = new Map<Id,Document__c>();
        Map<Id,Id> cvDocsMap = new Map<Id,Id>();
        Schema.DescribeSObjectResult doc = Document__c.sObjectType.getDescribe();
        String keyPrefix = doc.getKeyPrefix();
        Map<Id,ContentVersion> contentVersions = new Map<Id,ContentVersion>([SELECT Id,PathOnClient,VersionData,ContentDocumentId FROM ContentVersion WHERE ContentDocumentId IN :contentDocumentIds]);
        for(ContentDocumentLink cdl : [SELECT Id,ContentDocumentId,LinkedEntityId FROM ContentDocumentLink WHERE ContentDocumentId IN :contentDocumentIds]){            
            if(String.valueOf(cdl.LinkedEntityId).startsWith(keyPrefix)){
                documentsMap.put(cdl.LinkedEntityId,new Document__c());
                cvDocsMap.put(cdl.ContentDocumentId,cdl.LinkedEntityId);
            }
        }
        documentsMap = new Map<Id, Document__c>([SELECT Id,Name,Description__c,DDA_Document_Id__c FROM Document__c WHERE Id IN :documentsMap.keySet()]);
        for(ContentVersion cv : contentVersions.values()){
            if(cvDocsMap.containsKey(cv.ContentDocumentId) && documentsMap.containsKey(cvDocsMap.get(cv.ContentDocumentId))){
                DDAIntegrationWrapper.ProcessAttachment att = new DDAIntegrationWrapper.ProcessAttachment();
                att.body = EncodingUtil.base64Encode(cv.VersionData);
                att.fileName = cv.PathOnClient;
                att.parentId = documentsMap.get(cvDocsMap.get(cv.ContentDocumentId)).DDA_Document_Id__c;
                att.description = documentsMap.get(cvDocsMap.get(cv.ContentDocumentId)).Description__c;
                attachments.add(att);
            }
        }
        System.debug(JSON.serialize(attachments));
        if(!attachments.isEmpty()){
            JSONGenerator gen = JSON.createGenerator(false);
            gen.writeStartObject();
            gen.writeFieldName('processAttachments');
            gen.writeStartObject();
            gen.writeObjectField('attachItem', attachments); 
            gen.WriteEndObject();
            gen.WriteEndObject();
            System.debug(''+gen.getAsString());
            System.HttpResponse response = DDAIntegration.postJSONRequest(Label.OIC_Attachment_Binary_Endpoint, gen.getAsString());
            System.debug('response :- '+response.getBody());
            if(response.getStatusCode() == 200){
                Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                system.debug('results===='+results);
                Map<String, Object> obj = (Map<String, Object>) results.get('processAttachmentsResponse');
                for(Object attach : (List<Object>) obj.get('result')){
                    Map<String, Object> valuesMap = (Map<String, Object>) attach;
                    if(Boolean.valueOf(valuesMap.get('isSuccess'))){
                        
                    }else{
                        
                    }
                }
            }
        }
    }
}