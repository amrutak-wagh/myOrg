global class ManagerInchargeWebservice {
    global class Identity{
        webservice String name;
        webservice String arabic_name;
        webservice String email;
        webservice String mobile;
        webservice String phone;
        webservice String nationality;
        webservice List<String> orcIds;
        webservice String managerIdentityId;
        webservice String middleName;
        webservice String middleNameArabic;
    }
    
    global class RequestResponse{
        webservice Boolean success;
        webservice String errorMessage;
    }
    
    global class Attach {
        webservice String base64String;
        webservice String contentType;
        webservice String documentName;
        webservice String identityId;
        webservice String orcId;
        webservice String docFileName;
    }
    
    webservice static RequestResponse pushContacts(List<Identity> identities){
        System.debug('identities :- '+identities);
        RequestResponse reqRes = new RequestResponse();
        reqRes.success = true;
        reqRes.errorMessage = '';
        try{
            List<Contact> contactsToUpdate = new List<Contact>();
            List<Contact> contactsToInsert = new List<Contact>();
            List<String> nameList = new List<String>();
            Map<String, String> nationalityMap = new Map<String, String>();
            Set<String> oraclePartyIds = new Set<String>();
            Map<String, Set<String>> manIdsOracleIds = new Map<String, Set<String>>();
            for(Identity con : identities){
                nationalityMap.put(con.nationality,'');
                Set<String> oIds = new Set<String>();
                for(String oc:con.orcIds){
                    oIds.add(oc);
                    oraclePartyIds.add(oc);
                }
                manIdsOracleIds.put(con.managerIdentityId,oIds);
            }
            System.debug('manIdsOracleIds :- '+manIdsOracleIds);
            for(Country__c country : [SELECT Id,Name FROM Country__c WHERE Name IN :nationalityMap.keySet()] ){
                nationalityMap.put(country.Name, country.Id);
            }
            System.debug('nationalityMap :-'+nationalityMap);
            Map<String,Account> accountsMap = new Map<String,Account>();
            for(Account a : [SELECT Id,Name,Oracle_Party_Id__c FROM Account WHERE Oracle_Party_Id__c IN :oraclePartyIds]){
                accountsMap.put(a.ORACLE_PARTY_ID__c,a);
            }
            System.debug('accountsMap :- '+accountsMap);
            List<String> orcNotPresent = new List<String>();
            for(String d : oraclePartyIds){
                if(!accountsMap.containsKey(d)){
                    orcNotPresent.add(d);
                }
            }
            if(!orcNotPresent.isEmpty()){
                reqRes.success = false;
                reqRes.errorMessage = 'Error message - Oracle party id '+String.valueOf(orcNotPresent)+' not present.';
                return reqRes;
            }
            
            Map<String,Contact> contactsMap = new Map<String,Contact>();
            for(Contact c : [SELECT Id,Name,DDA_Manger_Id__c,AccountId,Account.ORACLE_PARTY_ID__c FROM Contact WHERE DDA_Manger_Id__c IN :manIdsOracleIds.keySet() AND Account.ORACLE_PARTY_ID__c IN :oraclePartyIds]){
                contactsMap.put(c.Account.ORACLE_PARTY_ID__c,c);
            }
            
            for(Identity con : identities){
                nameList = con.Name.split(' ',2);
                System.debug('nameList '+nameList);
                for(String oc:con.orcIds){
                    if(contactsMap.containsKey(oc)){
                        Contact newCon = new Contact();
                        newCon.FirstName = nameList.size() > 1 ? nameList[0] : null;
                        newCon.LastName =  nameList.size() > 1 ? nameList[1] :nameList[0];
                        newCon.Phone = con.Phone;
                        newCon.Middle_Name__c = con.middleName;
                        newCon.Middle_Name_Arabic__c = con.middleNameArabic;
                        newCon.Arabic_Full_Name__c = con.arabic_name;
                        newCon.MobilePhone =  con.Mobile;
                        newCon.Email =  con.email;
                        newCon.DDA_Manger_Id__c = con.managerIdentityId;
                        if(!String.isBlank(con.nationality) && nationalityMap.containsKey(con.nationality)){
                            newCon.Nationality__c = nationalityMap.get(con.nationality);
                        }
                        newCon.Id = contactsMap.get(oc).Id;
                        newCon.AccountId = accountsMap.get(oc).Id;
                        newCon.Type__c = 'Licensing Contact';
                        newCon.Client_Profile_Status__c = 'Active';
                        contactsToUpdate.add(newCon);
                    }else{
                        Contact newCon = new Contact();
                        newCon.FirstName = nameList.size() > 1 ? nameList[0] : null;
                        newCon.LastName =  nameList.size() > 1 ? nameList[1] :nameList[0];
                        newCon.Phone = con.Phone;
                        newCon.Middle_Name__c = con.middleName;
                        newCon.Middle_Name_Arabic__c = con.middleNameArabic;
                        newCon.Arabic_Full_Name__c = con.arabic_name;                  
                        newCon.MobilePhone =  con.Mobile;
                        newCon.Email =  con.email;
                        newCon.DDA_Manger_Id__c = con.managerIdentityId;
                        if(!String.isBlank(con.nationality) && nationalityMap.containsKey(con.nationality)){
                            newCon.Nationality__c = nationalityMap.get(con.nationality);
                        }
                        System.debug('newCon.Nationality__c '+newCon.Nationality__c);
                        newCon.AccountId = accountsMap.get(oc).Id;
                        newCon.Type__c = 'Licensing Contact';
                        newCon.Client_Profile_Status__c = 'Active';
                        contactsToInsert.add(newCon);
                    }
                }
            }
            List<Contact> conListOld = [SELECT Id, Type__c  FROM Contact WHERE Type__c ='Licensing Contact' AND Account.ORACLE_PARTY_ID__c IN :oraclePartyIds AND DDA_Manger_Id__c NOT IN :manIdsOracleIds.keySet()];
            for(Contact c : conListOld){
                c.Type__c = 'Previous Licensing Contact';
            }
            update conListOld;
            if(!contactsToInsert.isEmpty()){
                insert contactsToInsert;
            }
            if(!contactsToUpdate.isEmpty()){
                update contactsToUpdate;
            }
        }catch(Exception ex){
            reqRes.success = false;
            reqRes.errorMessage = 'Stacktrace :- '+ex.getStackTraceString()+' Error message :- '+ex.getMessage();
        }
        return reqRes;
    }
    
    /*********************************Method to insert attachments*********************/
    // @desc This API is being called from DCCA for inserting the attachments
    webservice static RequestResponse pushLicAttachment(List<Attach> attachments){
        RequestResponse reqRes = new RequestResponse();
        reqRes.success = true;
        reqRes.errorMessage  = '';
        try{
            Set<String> orcIdSet = new Set<String>();
            for (Attach  att : attachments) {
                orcIdSet.add(att.orcId);
            }
            Map<String, String> accManagerMap = new Map<String, String>();
            List<Account> accList = [select id,ORACLE_PARTY_ID__c from Account where ORACLE_PARTY_ID__c IN:orcIdSet ];        
            for(Account c : accList){
                accManagerMap.put(c.ORACLE_PARTY_ID__c , c.Id);
            }
            Map<String,Document__c> docMap = new Map<String,Document__c>();
            Map<String,ContentVersion> contVerMap = new Map<String,ContentVersion>();
            List<ContentDocumentLink> contentLinks = new List<ContentDocumentLink>();
            Map<Id,ContentVersion> contentVersions = new Map<Id,ContentVersion>();
            String customKey = 'key';
            Integer count = 0;
            for (Attach  att : attachments) {
                if(accManagerMap.containsKey(att.orcId)){
                    Document__c doc = new Document__c();
                    doc.Name = att.documentName;
                    doc.Account__c = accManagerMap.get(att.orcId);
                    docMap.put(customKey+count,doc);
                    ContentVersion conVer = new ContentVersion();
                    conVer.ContentLocation = 'S';
                    conVer.PathOnClient = att.docFileName;
                    conVer.Title = att.documentName;
                    conVer.VersionData = EncodingUtil.base64Decode(att.base64String);
                    contVerMap.put(customKey+count,conVer);
                }
            }
            
            insert docMap.values();
            insert contVerMap.values();
            Set<Id> cnVerIds = new Set<Id>();
            for(ContentVersion cv : contVerMap.values()){
                cnVerIds.add(cv.Id);
            }
            contentVersions = new Map<Id,ContentVersion>([SELECT Id,ContentDocumentId FROM ContentVersion WHERE Id IN :cnVerIds]);
            count=0;
            for(String cKey : docMap.keySet()){
                ContentDocumentLink cDe = new ContentDocumentLink();
                cDe.ContentDocumentId = contentVersions.get(contVerMap.get(cKey).Id).ContentDocumentId;
                cDe.LinkedEntityId = docMap.get(cKey).Id;
                cDe.ShareType = 'I';
                cDe.Visibility = 'InternalUsers';
                contentLinks.add(cDe);
            }
            insert contentLinks;
        }catch(Exception ex){
            reqRes.success = False;
            reqRes.errorMessage = 'Stacktrace :- '+ex.getStackTraceString()+' Error message :- '+ex.getMessage();
        }
        return reqRes;
    }
    
    /*********************************Method to insert attachments*********************/
    // @desc This API is being called from DCCA for inserting the attachments
    webservice static RequestResponse pushIdentityAttachment(List<Attach> attachments){
        RequestResponse reqRes = new RequestResponse();
        reqRes.success = true;
        reqRes.errorMessage  = '';
        try{
            Set<String> identityIdSet = new Set<String>();
            for(Attach att : attachments){
                identityIdSet.add(att.identityId);
            }
            Map<String, List<Contact>> conManagerMap = new Map<String, List<Contact>>();
            List<Contact> conList = [select id,Signature_Document_Id__c, DDA_Manger_Id__c from Contact where DDA_Manger_Id__c IN:identityIdSet ];
            Map<Id, List<Contact>> contactMap = new Map<Id, List<Contact>>();
            for(Contact c : conList){
                if(!conManagerMap.containsKey(c.DDA_Manger_Id__c)){
                    conManagerMap.put(c.DDA_Manger_Id__c, new List<Contact>{c});
                }else{
                    conManagerMap.get(c.DDA_Manger_Id__c).add(c);
                }
                if(!contactMap.containsKey(c.id)){
                    contactMap.put(c.Id, new List<Contact>{c});
                }else{
                    contactMap.get(c.Id).add(c);
                }
            }
            List<Document> docList = new List<Document>();
            Map<String, Document> docNameMap = new Map<String, Document>();
            List<Document> docListToUpdate = new List<Document>();
            List<Attachment> signatureattachList = new List<Attachment>();
            Map<String,Document__c> docMap = new Map<String,Document__c>();
            Map<String,ContentVersion> contVerMap = new Map<String,ContentVersion>();
            List<ContentDocumentLink> contentLinks = new List<ContentDocumentLink>();
            Map<Id,ContentVersion> contentVersions = new Map<Id,ContentVersion>();
            String customKey = 'key';
            Integer count = 0;
            for (Attach att : attachments) {
                if(conManagerMap.containsKey(att.identityId)){
                    for(Contact con : conManagerMap.get(att.identityId)){
                        String filename = att.docFileName;
                        Document__c doc = new Document__c();
                        doc.Name = att.documentName;
                        doc.Contact__c = con.Id;
                        docMap.put(customKey+count,doc);
                        ContentVersion conVer = new ContentVersion();
                        conVer.ContentLocation = 'S';
                        conVer.PathOnClient = filename;
                        conVer.Title = att.documentName;
                        conVer.VersionData = EncodingUtil.base64Decode(att.base64String);
                        contVerMap.put(customKey+count,conVer);
                    }
                }
            }
            
            insert docMap.values();
            insert contVerMap.values();
            Set<Id> cnVerIds = new Set<Id>();
            for(ContentVersion cv : contVerMap.values()){
                cnVerIds.add(cv.Id);
            }
            contentVersions = new Map<Id,ContentVersion>([SELECT Id,ContentDocumentId FROM ContentVersion WHERE Id IN :cnVerIds]);
            count=0;
            for(String cKey : docMap.keySet()){
                ContentDocumentLink cDe = new ContentDocumentLink();
                cDe.ContentDocumentId = contentVersions.get(contVerMap.get(cKey).Id).ContentDocumentId;
                cDe.LinkedEntityId = docMap.get(cKey).Id;
                cDe.ShareType = 'I';
                cDe.Visibility = 'InternalUsers';
                contentLinks.add(cDe);
            }
            insert contentLinks;
            List<Contact> updatedList = new List<Contact>();
            for(Attachment d : signatureattachList){
                if(contactMap.containsKey(d.parentId)){
                    for(Contact con : contactMap.get(d.parentId)){
                        Contact c = con;
                        c.Signature_Document_Id__c = d.Id;
                        updatedList.add(c);
                    }
                }
            }
            if(!updatedList.isEmpty()){
                update updatedList;
            }
        }catch(Exception ex){
            reqRes.success = False;
            reqRes.errorMessage = 'Stacktrace :- '+ex.getStackTraceString()+' Error message :- '+ex.getMessage();
        }
        return reqRes;
    }
}