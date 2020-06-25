/************************************************************************************
* Name          : CustomerRegistrationController                                                 
* Description   : Controller class for lightning component 'CustomerRegistration'
* Created Date  : 06/05/2019                                                    
* Created By    : 4C - Adeel Ahmad (adeel.ahmad@weare4c.com)
* Jira/Req By   :                                                                                                                                           
* -----------------------------------------------------------------------------------------------------------------------
* VERSION   Developer   Date        Description     Ticket/Reference                                                                    
************************************************************************************/
public without sharing class CustomerRegistrationController {

    /************************************************************************************
    Method      :   sendVerificationCode
    Description :   Method to send the verification code to contact's email
    Created Date:   06/05/2019
    *************************************************************************************
    */
    @AuraEnabled
    public static Boolean sendVerificationCode(String contactId){
        Boolean isValid = true;
        List<Contact> contacts = [SELECT Id,Email,Code__c from Contact where Encrypted_Contact_Id__c =:contactId];
        if(contacts.size() > 0){
            String CodeLength = String.valueof(Math.abs(Crypto.getRandomLong()));
            if(CodeLength.length() > 5)
                CodeLength = CodeLength.substring(0,8);
            contacts[0].Code__c = CodeLength;
            Messaging.SingleEmailMessage objMessage = new Messaging.SingleEmailMessage();
            objMessage.setToAddresses(new String[]{contacts[0].Email});
            objMessage.setSubject('Application Access Code');
            objMessage.setHtmlBody('This is your Code for Access the Application '+contacts[0].Code__c);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { objMessage });
            update contacts;
        }else{
            isValid = false;
        }
        return isValid;
    }

    /************************************************************************************
    Method      :   confirmVerificationCode
    Description :   Method to confirm verification code and generate the information
    Created Date:   23/05/2019
    *************************************************************************************
    */
    @AuraEnabled
    public static AccountWrapper confirmVerificationCode(String contactId, String confirmationCode){
        AccountWrapper wrp = new AccountWrapper();
        List<Contact> contacts = [SELECT Id From Contact where Encrypted_Contact_Id__c =:contactId and Code__c =:confirmationCode];

        if(contacts.size() > 0 && contacts != null){
            String cId = String.valueOf(contacts[0].Id);
            wrp = getAccountInfo(cId);
        }else{
            wrp.isValid = false;            
        }
        return wrp;
    }

    /************************************************************************************
    Method      :   getAccountInfo
    Description :   Method to get the information related to that company/contact 
                :   This will gets called from multiple places in order to generate data
    Created Date:   23/05/2019
    *************************************************************************************
    */
    public static AccountWrapper getAccountInfo(String contactId){
        AccountWrapper wrp = new AccountWrapper();
        Contact contact = [SELECT Id, Name, AccountId, Account.Name, Account.Proposed_Legal_Form_of_Business__c, Account.License_Type__c, 
                            Account.Parent_Company_Name__c,Account.Parent_Company_Registration_Number__c,Account.Statutory_Seat_Parent_Company__c, 
                            Account.Date_of_Incorporation_Parent_Company__c, Account.Community_Page_Indicator__c,Registration_Page_Indicator__c
                            FROM Contact WHERE Id =:contactId];
        LIST<WorkOrder> workOrders = [Select id,Proposed_Name_of_Business_1st_choice__c,Proposed_Name_of_Business_2nd_choice__c,Proposed_Name_of_Business_3rd_choice__c
                                     FROM WorkOrder WHERE ContactId =:contactId AND RecordType.Name = 'DDA Name Reservation' LIMIT 1];
        wrp.accountId = contact.AccountId;
        wrp.contactId = contact.Id;
        wrp.accountName = contact.Account.Name;
        wrp.proposedLegalFormOfBusiness = contact.Account.Proposed_Legal_Form_of_Business__c;
        wrp.selectedLicenseType = contact.Account.License_Type__c;
        wrp.currentPage = contact.Registration_Page_Indicator__c;

        //Company details
        wrp.parentCompanyName = contact.Account.Parent_Company_Name__c;
        wrp.registrationNo = contact.Account.Parent_Company_Registration_Number__c;
        wrp.dateOfIncorporation = contact.Account.Date_of_Incorporation_Parent_Company__c;
        wrp.selectedtatutorySeat = contact.Account.Statutory_Seat_Parent_Company__c;
        wrp.statutorySeatWrapper = getCountries();

        if(workOrders.size() > 0){
            wrp.ProposedNameofBusiness1stchoice = workOrders[0].Proposed_Name_of_Business_1st_choice__c;
            wrp.ProposedNameofBusiness2ndchoice = workOrders[0].Proposed_Name_of_Business_2nd_choice__c;
            wrp.ProposedNameofBusiness3rdchoice = workOrders[0].Proposed_Name_of_Business_3rd_choice__c;
            wrp.WorkOrderId = workOrders[0].Id;
        }

        wrp.businessLegalFormsWrapper = getBusinessLegalForms();
        wrp.activities = getActivities(contact.AccountId);
        wrp.licenseTypeWrapper = getLicenseTypes();
        wrp.members = getMembers(wrp.proposedLegalFormOfBusiness != null ? wrp.proposedLegalFormOfBusiness : '', contact.Id, contact.AccountId);

        wrp.isValid = true;
        //check if license type and legal form of business were already populated on lead
        LIST<Lead> leads = [SELECT ID,License_type__c FROM Lead WHERE ConvertedAccountId =:contact.AccountId];
        if(leads.size() > 0){
            if(leads[0].License_type__c != null){
                wrp.disableLicenseTypeSelection = true;                
            }
        }else{
            wrp.disableLicenseTypeSelection = false;
            wrp.disableLegalFormSelection = false;
        }

        //Additional documents
        LIST<AdditionalDocumentsWrapper> additionalDocuments = new LIST<AdditionalDocumentsWrapper>();
        LIST<Document__c> documents = [SELECT Id, Name, Account__c FROM Document__c WHERE Account__c =:contact.AccountId AND Contact__c = NULL];
        MAP<Id,Id> documentIdToFileId = new MAP<Id,Id>();
        for(Document__c doc : documents){
            documentIdToFileId.put(doc.Id, null);
        }

        if(!documentIdToFileId.isEmpty()){
            for(ContentDocumentLink cdl : [SELECT Id,ContentDocumentId,LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN:documentIdToFileId.keyset() ORDER BY Id DESC LIMIT 1]){
                documentIdToFileId.put(cdl.LinkedEntityId, cdl.ContentDocumentId);
            }

            for(Document__c doc : documents){
                AdditionalDocumentsWrapper aDocument = new AdditionalDocumentsWrapper();
                aDocument.documentName = doc.Name;
                aDocument.documentId = doc.Id;
                aDocument.uploadedFileId = documentIdToFileId.get(doc.Id);
                additionalDocuments.add(aDocument);
            }            
        }
        wrp.additionalDocuments = additionalDocuments;
        return wrp;
    }

    /************************************************************************************
    Method      :   saveBusinessFormInfo
    Description :   Method to save business information provided by user on step1 of wizard
    Created Date:   23/05/2019
    *************************************************************************************
    */
    @AuraEnabled
    public static AccountWrapper saveBusinessFormInfo(String contactId, String accountId, String wrapperJSON){
        AccountWrapper wrp = (AccountWrapper)JSON.deserialize(wrapperJSON, AccountWrapper.class);
        try{
            Account acc = [SELECT Id FROM Account WHERE Id=:accountId];
            WorkOrder wo = [SELECT Id FROM WorkOrder WHERE Id=:wrp.WorkOrderId];
            acc.License_Type__c = wrp.selectedLicenseType;
            acc.Proposed_Legal_Form_of_Business__c = wrp.proposedLegalFormOfBusiness;
            update acc;

            if(wrp.selectedLicenseType == 'DED'){
                wo.Proposed_Name_of_Business_1st_choice__c = ''; 
                wo.Proposed_Name_of_Business_2nd_choice__c = '';
                wo.Proposed_Name_of_Business_3rd_choice__c = '';            
            }else{
                wo.Proposed_Name_of_Business_1st_choice__c = wrp.ProposedNameofBusiness1stchoice; 
                wo.Proposed_Name_of_Business_2nd_choice__c = wrp.ProposedNameofBusiness2ndchoice;
                wo.Proposed_Name_of_Business_3rd_choice__c = wrp.ProposedNameofBusiness3rdchoice;                    
            }
            update wo;

            //Update contact for site page indicator
            Contact contact = [SELECT Id,Registration_Page_Indicator__c FROM Contact WHERE Id=:contactId];
            contact.Registration_Page_Indicator__c = wrp.proposedLegalFormOfBusiness.contains('FZ-LLC') ? 3 : 2;
            update contact;

            wrp = getAccountInfo(contactId);
        }catch(Exception e){
            wrp.isValid = false;
            wrp.errorMsg = e.getMessage();
        }
        return wrp;                
    }

    /************************************************************************************
    Method      :   saveCompanyInfo
    Description :   Method to save company information provided by user on step2 of wizard
    Created Date:   23/05/2019
    *************************************************************************************
    */
    @AuraEnabled
    public static AccountWrapper saveCompanyInfo(String contactId, String accountId, String wrapperJSON){
        AccountWrapper wrp = (AccountWrapper)JSON.deserialize(wrapperJSON, AccountWrapper.class);
        try{
            Account acc = [SELECT Id FROM Account WHERE Id=:accountId];

            if(String.isNotBlank(wrp.parentCompanyName)){
                acc.Parent_Company_Name__c = wrp.parentCompanyName;
            }

            if(String.isNotBlank(wrp.registrationNo)){
                acc.Parent_Company_Registration_Number__c = wrp.registrationNo;
            }

            if(wrp.dateOfIncorporation != null){
                acc.Date_of_Incorporation_Parent_Company__c = wrp.dateOfIncorporation;
            }

            if(String.isNotBlank(wrp.selectedtatutorySeat)){
                acc.Statutory_Seat_Parent_Company__c = wrp.selectedtatutorySeat;
            }
            update acc;

            //Update contact for site page indicator
            Contact contact = [SELECT Id,Encrypted_Contact_Id__c FROM Contact WHERE Id=:contactId];
            contact.Registration_Page_Indicator__c = 3;
            update contact;

            wrp = getAccountInfo(contactId);
        }catch(Exception e){
            wrp.isValid = false;
            wrp.errorMsg = e.getMessage();
        }
        return wrp;
    }

    /************************************************************************************
    Method      :   saveActivities
    Description :   Method to save activities selected by user on step3 of wizard
    Created Date:   23/05/2019
    *************************************************************************************
    */
    @AuraEnabled 
    public static AccountWrapper saveActivities(String contactId, String accountId, String activitiesJSON){
        List<LookupSearchResult> selectedActivities = (List<LookupSearchResult>)JSON.deserialize(activitiesJSON, List<LookupSearchResult>.class);
        AccountWrapper wrp = new AccountWrapper();
        try{
            //Delete any previous activities
            LIST<Requested_Licensed_Activity__c> deleteableRecords = [SELECT Id FROM Requested_Licensed_Activity__c WHERE Account__c =:accountId];
            if(deleteableRecords.size() > 0){
                Delete deleteableRecords;
            }

            LIST<Case> cases = [SELECT Id FROM Case WHERE ContactId =:contactId];
            Id caseId = null;
            if(cases.size() > 0){
                caseId = cases[0].Id;
            }

            //Insert new records
            LIST<Requested_Licensed_Activity__c> insertableRecords = new LIST<Requested_Licensed_Activity__c>();
            for(LookupSearchResult result : selectedActivities){
                Requested_Licensed_Activity__c activity = new Requested_Licensed_Activity__c();
                activity.Account__c = accountId;
                activity.Activity__c = result.getId();
                activity.Type__c = 'Requested Activity';
                activity.Case__c = caseId;
                insertableRecords.add(activity);
            }

            if(insertableRecords.size() > 0){
                insert insertableRecords;
            }

            //Update contact for site page indicator
            Contact contact = [SELECT Id,Encrypted_Contact_Id__c FROM Contact WHERE Id=:contactId];
            contact.Registration_Page_Indicator__c = 4;
            update contact;

            wrp = getAccountInfo(contactId);
        }catch(Exception e){
            wrp.isValid = false;
            wrp.errorMsg = e.getMessage();
        }
        return wrp;
    }

    /************************************************************************************
    Method      :   saveMembersInfo
    Description :   Method to save members added by on step4 of wizard
    Created Date:   23/05/2019
    *************************************************************************************
    */
    @AuraEnabled
    public static AccountWrapper saveMembersInfo(String contactId, String accountId, String membersJSON){
        List<MemberWrapper> selectedMembers = (List<MemberWrapper>)JSON.deserialize(membersJSON, List<MemberWrapper>.class);
        AccountWrapper wrp = new AccountWrapper();
        try{
            //Delete any previous activities

            //Insert new records
            LIST<Contact> updateableRecords = new LIST<Contact>();
            MAP<String, Attachment> contactToAttachmentMap = new MAP<String, Attachment>();
            for(MemberWrapper result : selectedMembers){
                Contact c = new Contact();
                c.FirstName = result.firstName;
                c.LastName = result.lastName;
                c.Nationality__c = result.selectedCountry;
                c.Passport_No__c = result.passportNo;
                c.Number_of_Shares__c = result.noShares;
                c.GM_Resident_in_UAE_Yes_No__c = result.residentInUAE;
                c.MobilePhone = result.mobilePhone;
                c.Role__c = getContactrolesFromWrapper(result.contactRole);
                c.AccountId = accountId;
                if(result.contactId != ''){
                    c.Id = result.contactId;
                }
                c.MailingCountryCode = result.mailingAddress.selectedCountry;
                c.MailingStateCode = result.mailingAddress.selectedState;
                c.MailingCity = result.mailingAddress.city;
                c.MailingStreet = result.mailingAddress.street;
                c.MailingPostalCode = result.mailingAddress.postalCode;
                updateableRecords.add(c);
            }

            if(updateableRecords.size() > 0){
                upsert updateableRecords;
            }

            // Delete all contacts which are deleted from frontend
            LIST<Contact> delteableContacts = [SELECT Id FROM Contact WHERE AccountId =:accountId AND Id != :contactId AND Id NOT IN:updateableRecords];
            if(delteableContacts.size() > 0){
                Delete delteableContacts;
            }

            //Update contact for site page indicator
            Contact contact = [SELECT Id,Registration_Page_Indicator__c FROM Contact WHERE Id=:contactId];
            contact.Registration_Page_Indicator__c = 5;
            update contact;

            //wrp.members = getMembers('', contactId, accountId);
            wrp = getAccountInfo(contactId);
        }catch(Exception e){
            wrp.isValid = false;
            wrp.errorMsg = e.getMessage();
        }
        return wrp;
    }

    /************************************************************************************
    Method      :   saveDocuments
    Description :   As documents are already getting uploaded by lightning:upload
                :   This method will update the application status
    Created Date:   23/05/2019
    *************************************************************************************
    */
    @AuraEnabled
    public static AccountWrapper saveDocuments(String contactId, String accountId){
        AccountWrapper wrp = new AccountWrapper();
        try{
            //Update contact for site page indicator
            Contact contact = [SELECT Id,Registration_Page_Indicator__c FROM Contact WHERE Id=:contactId];
            contact.Registration_Page_Indicator__c = 6;
            update contact;

            wrp.isValid = true;
        }catch(Exception e){
            wrp.isValid = false;
            wrp.errorMsg = e.getMessage();
        }
        return wrp;                
    }

    /************************************************************************************
    Method      :   submitApplication
    Description :   Submit application form, 
                :   TODO: update the account/contact status, creation of case/workorders
    Created Date:   23/05/2019
    *************************************************************************************
    */
    @AuraEnabled
    public static AccountWrapper submitApplication(String contactId, String accountId){
        AccountWrapper wrp = new AccountWrapper();
        try{
            //Update contact for site page indicator
            Contact contact = [SELECT Id,Registration_Page_Indicator__c FROM Contact WHERE Id=:contactId];
            contact.Registration_Page_Indicator__c = 7;
            update contact;

            wrp.isValid = true;
        }catch(Exception e){
            wrp.isValid = false;
            wrp.errorMsg = e.getMessage();
        }
        return wrp;                
    }

    private static String getContactrolesFromWrapper(LIST<ContactRoleWrapper> selectedContactRoles){
        String selectedRole = '';
        for(ContactRoleWrapper cr : selectedContactRoles){
            if(cr.isSelected == true){
                selectedRole += cr.roleName + ';';
            }
        }
        if(String.isNotBlank(selectedRole)){
            selectedRole = selectedRole.removeEnd(';');
        }
        return selectedRole;
    }

    private static LIST<BusinessLegalFormsWrapper> getBusinessLegalForms(){
        LIST<BusinessLegalFormsWrapper> businessLegalForms = new LIST<BusinessLegalFormsWrapper>();
        schema.DescribeFieldResult fieldResult = Account.Proposed_Legal_Form_of_Business__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple){
            businessLegalForms.add(new BusinessLegalFormsWrapper(f.getLabel(), f.getValue()));
        }
        return businessLegalForms;
    }

    private static LIST<LicenseTypeWrapper> getLicenseTypes(){
        LIST<LicenseTypeWrapper> licenseTypes = new LIST<LicenseTypeWrapper>();
        schema.DescribeFieldResult fieldResult = Account.License_Type__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple){
            licenseTypes.add(new LicenseTypeWrapper(f.getLabel(), f.getValue()));
        }       
        return licenseTypes;
    }

    private static LIST<LookupSearchResult> getActivities(Id accountId){
        LIST<LookupSearchResult> associatedActivities = new LIST<LookupSearchResult>();
        for(Requested_Licensed_Activity__c activity : [SELECT Id,Account__c,Activity__c,Activity__r.Name 
                                                        FROM Requested_Licensed_Activity__c
                                                        WHERE Account__c =:accountId]){
            associatedActivities.add(new LookupSearchResult(activity.Activity__c, 'Activity_Custom__c', 'custom:custom33', activity.Activity__r.Name, ''));            
        }
        return associatedActivities;
    }
    
    @AuraEnabled
    public static LIST<MemberWrapper> getMembers(String proposedLegalFormOfBusiness, Id contactId, Id accountId){
        LIST<CountryWrapper> countries = getCountries();
        LIST<MemberWrapper> membersWrapper = new LIST<MemberWrapper>();        
        LIST<Contact> contacts = [SELECT Id,FirstName,LastName,Passport_No__c,Number_of_Shares__c,MobilePhone,
                                 Nationality__c,GM_Resident_in_UAE_Yes_No__c,Local_Address__c,Role__c,
                                 MailingCountryCode,MailingStateCode, MailingCity, MailingStreet, MailingPostalCode
                                FROM Contact
                                WHERE Id !=:contactId
                                AND AccountId =:accountId
                                ORDER BY CreatedDate ASC
                                ];

        if(contacts.size() > 0){
            Integer i = 0;
            MAP<Id, LIST<Document__c>> contactIdToListDocumentsMap = new MAP<Id, LIST<Document__c>>();
            MAP<Id,Id> documentIdToFileId = new MAP<Id,Id>();
            for(Document__c doc : [SELECT Id, Name, Contact__c FROM Document__c WHERE Contact__c IN:contacts]){
                LIST<Document__c> documents = contactIdToListDocumentsMap.get(doc.Contact__c) == null ? new LIST<Document__c>() : contactIdToListDocumentsMap.get(doc.Contact__c);
                documents.add(doc);
                contactIdToListDocumentsMap.put(doc.Contact__c, documents);
                documentIdToFileId.put(doc.Id, null);
            } 

            if(!documentIdToFileId.isEmpty()){
                for(ContentDocumentLink cdl : [SELECT Id,ContentDocumentId,LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN:documentIdToFileId.keyset() ORDER BY Id DESC LIMIT 1]){
                    documentIdToFileId.put(cdl.LinkedEntityId, cdl.ContentDocumentId);
                }                
            }

            for(Contact c : contacts){
                MemberWrapper member = new MemberWrapper();
                member.firstName = c.FirstName;
                member.lastName = c.LastName;
                member.selectedCountry = c.Nationality__c;
                member.passportNo = c.Passport_No__c;
                member.noShares = c.Number_of_Shares__c;
                member.residentInUAE = c.GM_Resident_in_UAE_Yes_No__c;
                member.country = countries;
                member.mobilePhone = c.MobilePhone;
                member.contactRole = getContactRoles(proposedLegalFormOfBusiness,c.Role__c);
                member.index = i;
                member.contactId = c.Id;
                member.mailingAddress = getContactMailingAddress();
                member.mailingAddress.selectedCountry = c.MailingCountryCode;
                member.mailingAddress.selectedState = c.MailingStateCode;
                member.mailingAddress.city = c.MailingCity;
                member.mailingAddress.street = c.MailingStreet;
                member.mailingAddress.postalCode = c.MailingPostalCode; 
                member.countryOptions = getCountryOptions(); 
                member.stateCodeToStateMap = getStateCodeToStateMap();
                member.countryToStateMap = controllingToDependentValues(contact.MailingCountryCode, contact.MailingStateCode);
                member.stateOptions = getStateOptions(member.countryToStateMap, c.MailingCountryCode);
                if(member.stateOptions.size() > 1){
                    member.mailingAddress.isStateDisabled = false;                    
                }else{
                    member.mailingAddress.isStateDisabled = true;                    
                }

                //Get the associated documents
                if(contactIdToListDocumentsMap.get(c.Id) != null){
                    LIST<AdditionalDocumentsWrapper> additionalDocuments = new LIST<AdditionalDocumentsWrapper>();
                    for(Document__c doc : contactIdToListDocumentsMap.get(c.Id)){
                        AdditionalDocumentsWrapper additionalDocument = new AdditionalDocumentsWrapper();
                        additionalDocument.documentId = doc.Id;
                        additionalDocument.documentName = doc.Name;
                        additionalDocument.uploadedFileId = documentIdToFileId.get(doc.Id);
                        additionalDocuments.add(additionalDocument);
                    }
                    member.additionalDocuments = additionalDocuments;
                }
                membersWrapper.add(member);                            
                i++;
            }
        }else{
            MemberWrapper member = new MemberWrapper();
            member.firstName = '';
            member.lastName = '';
            member.selectedCountry = '';
            member.country = countries;
            member.contactRole = getContactRoles(proposedLegalFormOfBusiness, '');
            member.mailingAddress = getContactMailingAddress();
            member.countryOptions = getCountryOptions();
            member.stateCodeToStateMap = getStateCodeToStateMap();
            member.countryToStateMap = controllingToDependentValues(contact.MailingCountryCode, contact.MailingStateCode);
            member.stateOptions = getStateOptions(member.countryToStateMap, '');
            member.mailingAddress.isStateDisabled = true;                    

            member.index = 0;
            membersWrapper.add(member);            
        }
        return membersWrapper;
    }

    //Method that will return the member wrapper output
    @AuraEnabled
    public static MemberWrapper getNewMember(String proposedLegalFormOfBusiness){
        LIST<CountryWrapper> countries = getCountries();
        MemberWrapper member = new MemberWrapper();
        member.firstName = '';
        member.lastName = '';
        member.selectedCountry = '';
        member.country = countries;
        member.contactRole = getContactRoles(proposedLegalFormOfBusiness, '');
        member.mailingAddress = getContactMailingAddress();
        member.countryOptions = getCountryOptions();
        member.stateCodeToStateMap = getStateCodeToStateMap();
        member.countryOptions = getCountryOptions(); 
        member.stateCodeToStateMap = getStateCodeToStateMap();
        member.countryToStateMap = controllingToDependentValues(contact.MailingCountryCode, contact.MailingStateCode);
        member.stateOptions = getStateOptions(member.countryToStateMap, '');
        member.mailingAddress.isStateDisabled = true;                    
        return member;
    }

    private static LIST<CountryWrapper> getCountryOptions(){
        LIST<CountryWrapper> wrapperList = new LIST<CountryWrapper>();
        wrapperList.add(new CountryWrapper('--None--', ''));
        for (PicklistEntry pe : Contact.MailingCountryCode.getDescribe().getPicklistValues()) {
            wrapperList.add(new CountryWrapper(pe.getLabel(), pe.getValue()));
        }
        return wrapperList;
    }

    private static LIST<CountryWrapper> getStateOptions(MAP<String, LIST<String>> countryCodeToStatesMap, String mailingCountry){
        MAP<String, String> stateCodeToStateMap = getStateCodeToStateMap();

        LIST<CountryWrapper> wrapperList = new LIST<CountryWrapper>();
        wrapperList.add(new CountryWrapper('--None--', ''));
        if(String.isNotBlank(mailingCountry)){
            for(String s : countryCodeToStatesMap.get(mailingCountry)){
                wrapperList.add(new CountryWrapper(stateCodeToStateMap.get(s),s));
            }
        }
        return wrapperList;
    }

    private static MAP<String,String> getStateCodeToStateMap(){
        MAP<String, String> stateCodeToStateMap = new MAP<String, String>();
        for (PicklistEntry pe : Contact.MailingStateCode.getDescribe().getPicklistValues()) {
            stateCodeToStateMap.put(pe.getValue(), pe.getLabel());
        }
        return stateCodeToStateMap;
    }


    private static LIST<ContactRoleWrapper> getContactroles(String proposedLegalFormOfBusiness, String selectedRole){
        LIST<ContactRoleWrapper> contactRoles = new LIST<ContactRoleWrapper>();

        schema.DescribeFieldResult fieldResult = Contact.Role__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple){
            if(proposedLegalFormOfBusiness.contains('FZ-LLC') && (f.getValue() == 'Member' || f.getValue() == 'Board of Directors')){
                contactRoles.add(new ContactRoleWrapper(f.getValue(), String.isNotBlank(selectedRole) && selectedRole.contains(f.getValue()) ? true : false));
            }else if(f.getValue() != 'Member' && f.getValue() != 'Board of Directors'){
                contactRoles.add(new ContactRoleWrapper(f.getValue(), String.isNotBlank(selectedRole) && selectedRole.contains(f.getValue()) ? true : false));                
            }
        }       
        return contactRoles;
    }

    public static LIST<CountryWrapper> getCountries(){
        LIST<CountryWrapper>  countryWrapperList = new LIST<CountryWrapper>();

        countryWrapperList.add(new CountryWrapper('None', ''));

        for( Country__c country : [SELECT Id,Name FROM Country__c]){
            CountryWrapper c = new CountryWrapper(country.Name, country.Id);
            countryWrapperList.add(c);
        }
        return countryWrapperList;
    }

    //Method that will return the contact mailing address
    private static AddressWrapper getContactMailingAddress(){
        AddressWrapper wrp = new AddressWrapper();
        //wrp.countryToStateMap = controllingToDependentValues(Contact.MailingCountryCode, Contact.MailingStateCode);
        return wrp;
    }
    
    /* Custom auraEnabled method to search the records */
    @AuraEnabled(cacheable=true)
    public static List<LookupSearchResult> search(String searchTerm, Id parentRecordId, String sObjectName, String icon, String selectedSegment, String excludedRecordsIds) {
        List<LookupSearchResult> results = new List<LookupSearchResult>();
        String objIcon = String.isNotBlank(icon) ? icon : 'custom:custom9';
        LIST<String> excludedIds = new LIST<String>();
        if(String.isNotBlank(excludedRecordsIds)){
            excludedIds = excludedRecordsIds.split(',');
        }

        //Incase of less than 2, perform SOQL instead of SOSL
        if(String.isBlank(searchTerm) || searchTerm.length() < 2){
            searchTerm = '%'+searchTerm+'%';
            if(sObjectName == 'Segment__c'){
                for(Segment__c s : [SELECT Id,Name FROM Segment__c WHERE Name LIKE:searchTerm LIMIT 10]){
                    results.add(new LookupSearchResult(s.Id, 'Segment__c', objIcon, s.Name, ''));
                }
            }else if(sObjectName == 'Activity_Custom__c'){
                for(Activity_Custom__c a : [SELECT Id,Name,Segment__c FROM Activity_Custom__c WHERE Name LIKE:searchTerm AND Id NOT IN:excludedIds LIMIT 10]){
                    if( selectedSegment == '' || ( selectedSegment != '' && a.Segment__c == selectedSegment)){
                        results.add(new LookupSearchResult(a.Id, 'Activity_Custom__c', objIcon, a.Name, ''));
                    }
                }
            }
        }else{
            searchTerm += '*';
            
            List<List<SObject>> searchResults = [FIND :searchTerm IN NAME FIELDS RETURNING
                Segment__c (Id, Name),
                Activity_Custom__c (Id, Name, Segment__c WHERE Id NOT IN:excludedIds),
                Country__c (Id, Name)
                LIMIT 10];
            


            Segment__c [] segments = ((List<Segment__c>) searchResults[0]);
            Activity_Custom__c [] activities = ((List<Activity_Custom__c>) searchResults[1]);
            Country__c [] countries = ((List<Country__c>) searchResults[2]);

            if(sObjectName == 'Segment__c'){
                for (Segment__c segment : segments) {
                    results.add(new LookupSearchResult(segment.Id, 'Segment__c', objIcon, segment.Name, ''));
                }            
            }else if(sObjectName == 'Activity_Custom__c'){
                for (Activity_Custom__c activity : activities) {
                    if( selectedSegment == '' || ( selectedSegment != '' && activity.Segment__c == selectedSegment)){
                        results.add(new LookupSearchResult(activity.Id, 'Activity_Custom__c', objIcon, activity.Name, ''));
                    }
                }
            }
        }
        return results;
    }

    // Wrapper class for account which will contains all the information related to account/contact/segments/activities
    public class AccountWrapper{
        @AuraEnabled public Boolean isValid {get; set;}
        @AuraEnabled public String errorMsg {get; set;}
        @AuraEnabled public String accountName {get; set;}
        @AuraEnabled public Id accountId {get; set;}
        @AuraEnabled public Id contactId {get; set;}
        @AuraEnabled public String proposedLegalFormOfBusiness {get; set;}
        @AuraEnabled public String selectedLicenseType {get; set;}
        @AuraEnabled public Boolean disableLicenseTypeSelection {get; set;} //If populated on lead, dn't allow to change
        @AuraEnabled public Boolean disableLegalFormSelection {get; set;} //If populated on lead, dn't allow to change
        @AuraEnabled public Decimal currentPage {get; set;}

        //Company Info
        @AuraEnabled public String parentCompanyName {get; set;}
        @AuraEnabled public String registrationNo {get; set;}
        @AuraEnabled public Date dateOfIncorporation {get; set;}
        @AuraEnabled public String selectedtatutorySeat {get; set;}
        @AuraEnabled public LIST<CountryWrapper> statutorySeatWrapper {get; set;}

        //WorkOrders
        @AuraEnabled public String ProposedNameofBusiness1stchoice {get;set;}
        @AuraEnabled public String ProposedNameofBusiness2ndchoice {get;set;}
        @AuraEnabled public String ProposedNameofBusiness3rdchoice {get;set;}
        @AuraEnabled public String WorkOrderId {get; set;}
        
        @AuraEnabled public LIST<BusinessLegalFormsWrapper> businessLegalFormsWrapper {get; set;}
        @AuraEnabled public LIST<LookupSearchResult> activities {get; set;}
        @AuraEnabled public LIST<LicenseTypeWrapper> licenseTypeWrapper {get; set;}
        @AuraEnabled public LIST<MemberWrapper> members {get; set;}
        @AuraEnabled public String deletedMembers {get; set;} //Comma separated deleted members Ids

        //Additional documents
        @AuraEnabled public LIST<AdditionalDocumentsWrapper> additionalDocuments {get; set;}
    }
    
    public class MemberWrapper{
        @AuraEnabled public String firstName {get; set;}
        @AuraEnabled public String lastName {get; set;}
        @AuraEnabled public String passportNo {get; set;}
        @AuraEnabled public String noShares {get; set;}
        @AuraEnabled public String nationality {get; set;}
        @AuraEnabled public LIST<ContactRoleWrapper> contactRole {get; set;}
        @AuraEnabled public String selectedCountry {get; set;}
        @AuraEnabled public String residentInUAE {get; set;}
        @AuraEnabled public String mobilePhone {get; set;}
        @AuraEnabled public String address {get; set;}
        @AuraEnabled public Integer index {get; set;}
        @AuraEnabled public String contactId {get; set;}
        @AuraEnabled public AddressWrapper mailingAddress {get; set;}
        @AuraEnabled public LIST<CountryWrapper> country {get; set;} //Country lookup for nationality field

        //For country and states
        @AuraEnabled public MAP<String, String> countryCodeToCountryMap {get; set;}
        @AuraEnabled public MAP<String, String> stateCodeToStateMap {get; set;}
        @AuraEnabled public LIST<CountryWrapper> countryOptions {get; set;}
        @AuraEnabled public LIST<CountryWrapper> stateOptions {get; set;}
        @AuraEnabled public Map<String, List<String>> countryToStateMap {get; set;}

        //Documents associated to each member record
        @AuraEnabled public LIST<AdditionalDocumentsWrapper> additionalDocuments {get; set;}
    }

    public class AddressWrapper{
        @AuraEnabled public String street {get; set;}
        @AuraEnabled public String city {get; set;}
        @AuraEnabled public String postalCode {get; set;}
        @AuraEnabled public String selectedCountry {get; set;}
        @AuraEnabled public String selectedState {get; set;}
        @AuraEnabled public Boolean isStateDisabled {get; set;}
        
    }

    public class AdditionalDocumentsWrapper{
        @AuraEnabled public String documentName {get; set;}
        @AuraEnabled public String documentId {get; set;}
        @AuraEnabled public String uploadedFileId {get; set;}
    }
    
    public class CountryWrapper{
        @AuraEnabled public String label {get; set;}
        @AuraEnabled public String value {get; set;}

        public CountryWrapper(String label, String value){
            this.label = label;
            this.value = value;
        }
    }

    public class ContactRoleWrapper{
    	@AuraEnabled public String roleName {get; set;}
    	@AuraEnabled public Boolean isSelected {get; set;}
        public ContactRoleWrapper(String roleName, Boolean isSelected){
            this.roleName = roleName;
            this.isSelected = isSelected;
        }
    }

    public class LicenseTypeWrapper{
        @AuraEnabled public String label {get; set;}
        @AuraEnabled public String value {get; set;}

        public LicenseTypeWrapper(String label, String value){
            this.label = label;
            this.value = value;
        }
    }

    public class BusinessLegalFormsWrapper{
        @AuraEnabled public String label {get; set;}
        @AuraEnabled public String value {get; set;}

        public BusinessLegalFormsWrapper(String label, String value){
            this.label = label;
            this.value = value;
        }
    }

    //method used to get the states against the country codes
    //getting address info
    private static final String BASE_64_CHARS = ''
            + 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
            + 'abcdefghijklmnopqrstuvwxyz'
            + '0123456789+/';

    private class PicklistEntryBean {
        public Boolean active {get; set;}
        public String value {get; set;}
        public String validFor {get; set;}
    }

    private static Map<String, Set<Integer>> cache;

    public static Map<String, List<String>> controllingToDependentValues(SObjectField controlling, SObjectField dependent) {

        Map<String, List<String>> results = new Map<String, List<String>>();

        if (controlling != null && dependent != null) {

            cache = new Map<String, Set<Integer>>();

            List<String> controllingValues = new List<String>();

            for (PicklistEntry pe : controlling.getDescribe().getPicklistValues()) {
                if (pe.isActive()) {
                    results.put(pe.getValue(), new String[] {});
                    controllingValues.add(pe.getValue());
                }
            }

            for (PicklistEntryBean pe : picklistEntryBeans(dependent.getDescribe().getPicklistValues())) {
                if (pe.active) {
                    for (Integer index : validForToIndices(pe.validFor)) {
                        results.get(controllingValues.get(index)).add(pe.value);
                    }
                }
            }

        }

        return results;
    }

    private static Set<Integer> validForToIndices(String validFor) {

        Set<Integer> indices = cache.get(validFor);
        if (indices == null) {
            indices = new Set<Integer>();

            String validForBits = base64ToBits(validFor);
            for (Integer i = validForBits.indexOf('1'); i >= 0; i = validForBits.indexOf('1', i + 1)) {
                indices.add(i);
            }

            cache.put(validFor, indices);
        }

        return indices;
    }

    private static String decimalToBinary(Integer val) {

        String bits = '';
        while (val > 0) {
            Integer remainder = Math.mod(val, 2);
            val = Integer.valueOf(Math.floor(val / 2));
            bits = String.valueOf(remainder) + bits;
        }
        return bits;
    }

    private static String base64ToBits(String validFor) {

        if (String.isEmpty(validFor)) return '';

        String validForBits = '';
        for (Integer i = 0; i < validFor.length(); i++) {
            String thisChar = validFor.mid(i, 1);
            Integer val = BASE_64_CHARS.indexOf(thisChar);
            String bits = decimalToBinary(val).leftPad(6, '0');
            validForBits += bits;
        }
        return validForBits;
    }

    private static PicklistEntryBean[] picklistEntryBeans(List<PicklistEntry> pes) {

        return (List<PicklistEntryBean>) JSON.deserialize(JSON.serialize(pes), List<PicklistEntryBean>.class);
    }


}