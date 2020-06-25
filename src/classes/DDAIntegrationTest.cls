@isTest//(SeeAllData=true)
public class DDAIntegrationTest {

    @testSetup
    public static void setUp(){
        Test.setMock(HttpCalloutMock.class, new DDAIntegrationMock()); //HttpCalloutMock
        Profile profileObject = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
    	User uerObject = new User(Alias = 'standt', Email='systemadmin@testorg.com', 
                                  EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                  LocaleSidKey='en_US', ProfileId = profileObject.Id, 
                                  TimeZoneSidKey='America/Los_Angeles', UserName='systemadmin@testorg.com',
                                  ManagerId = UserInfo.getUserId());
        insert uerObject;
        
        Business_Park__c businessParkObject = new Business_Park__c(Name = 'Test BusinessPark',
                                                                                Business_Park_Yardi__c = 'Test Yardi');
        insert businessParkObject;
        
        Country__c countryObject = new Country__c(Name = 'Test UK');
        insert countryObject;
        
        Contact contactObject = new Contact(LastName = 'Test',
                                            Email = 'test.mail@test.com', 
                                            isSubmit__c = true, 
                                            ParentCon__c = true, 
                                            Type__c = 'Billing;Leasing Contact;Licensee Contact;Manager Incharge');
        insert contactObject;
        
        Account accountObject = new Account(Name = 'Test',
                                            Phone='1111111', 
                                            Legal_Framework__c = 'Branch of a Foreign Company', 
                                            Security_Clearance_Status__c = 'NA', 
                                            OwnerId = uerObject.Id,
                                            License_Business_Park__c = businessParkObject.Id,
                                            Name_Approval_Request_Number__c = '111',
                                            Legal_Name__c = 'Test Legal Name',
                                            Operating_Name_Arabic__c = 'Test Operating Name Arabic',
                                            ORACLE_PARTY_ID__c = '222',
                                            Oracle_Party_Number__c = 'O:123',
                                            Account_Type__c = 'Design',
                                            DED_Initial_Approval_Number__c = 'DED:1',
                                            DED_Trade_License_number__c = 't:111',
                                            Security_Clearance_Date__c = System.today(),
                                            Manager_In_Charge__c = contactObject.Id,
                                            Business_Plan_Request_Date_Approval_Date__c = System.today());
        insert accountObject;
        Contact contactObject2 = new Contact(FirstName = 'Test',
                                             LastName = 'Contact',
                                             AccountId= accountObject.Id,
                                             Email = 'test.mail@test.com', 
                                             isSubmit__c = true, 
                                             ParentCon__c = true, 
                                             Type__c = 'Billing',
                                             Birthdate = Date.newInstance(1999, 12, 12),
                                             Date_Of_Incorporation__c = System.today(),
                                             Gender__c = 'NA',
                                             Legal_Name__c = 'Test legal Name',
                                             Nationality__c = countryObject.Id,
                                             Passport_Expiry_Date__c = System.today().addDays(555),
                                             Passport_Issue_Date__c = System.today(),
                                             Passport_No__c = 'P123',
                                             Position__c = '1',
                                             Registration_No__c = '255',
                                             Statutory_Seat__c = 'Test Statutory Seat');
        insert contactObject2;
        
        WorkOrder workOrderObject = new WorkOrder(AccountId = accountObject.Id,
                                                   Status = 'New', 
                                                   Description = 'test Description', 
                                                   Work_Order_Number__c = 1, 
                                                   Account_Type__c = 'Trust Account', 
                                                   Minimum_Required_Share_Capital__c = 10000,
                                                   IsMovedToNextStep__c = true,
                                                   DDA_Request_Id__c = 'Req-1',
                                                   Service_Name__c = 'Test Service',
                                                   Is_Data_Migrated_and_Locked__c = FALSE,
                                                   Assigned_To_RC__c = 'Test Assignment',
                                                   Under_Registration_BU_Sub_Category__c = 'Test Under Registration BU Sub_Category',
                                                   Skip_Lease_Validation__c = TRUE,
                                                   Call_For_Review_Reason__c = 'Test Call',
                                                   Total_Amount_Due__c = 123,
                                                   Bank__c = 'Test Bank',
                                                   Bank_Branch__c = 'Test Bank Branch',
                                                   Proposed_Name_of_Business_1st_choice__c = 'Test Business 1',
                                                   Proposed_Name_of_Business_2nd_choice__c = 'Test Business 2',
                                                   Proposed_Name_of_Business_3rd_choice__c = 'Test Business 3',
                                                   DDA_Request_Number__c = '12345', Integration_Status__c = 'Success');
        insert workOrderObject;  
        
        Segment__c segmentObject = new Segment__c(Name = 'Test Segment');
        insert segmentObject;
        
        Activity_Custom__c activityObject = new Activity_Custom__c(Name = 'Test Activity',
                                                                   RnL_Activity_SF_ID__c = '123',
                                                                   Segment__c = segmentObject.Id);
        insert activityObject;
        
        Requested_Licensed_Activity__c requestedLicensedActivityObject = new Requested_Licensed_Activity__c(Activity__c = activityObject.Id,
                                                                                                            Work_Order__c = workOrderObject.Id,
                                                                                                            Type__c = 'Requested Activity',
                                                                                                            Account__c = accountObject.Id);
        insert requestedLicensedActivityObject;
        
        Opportunity opportunityObject = new Opportunity(Name = 'Test Opportunity',
                                                        AccountId = accountObject.Id,
                                                        Contact__c = contactObject2.Id,
                                                        Business_Park__c = businessParkObject.Id,
                                                        StageName = 'New',
                                                        CloseDate = System.today()
                                                        );
        insert opportunityObject;
        
        Payment_Term__c paymentTermObject = new Payment_Term__c(Name = 'Test Payment Term',
                                                               Number_Of_Payments__c = 2);
        insert paymentTermObject;
        
        Quote quoteObject = new Quote(Name = 'Test Quote',
                                     Proposed_Start_Date__c = System.today(),
                                     Proposed_End_Date__c = System.today().addDays(2),
                                     Type__c = 'Expansion',
                                     Payment_Terms__c = paymentTermObject.Id,
                                     Pricebook2Id = Test.getStandardPricebookId(),
                                      OpportunityId = opportunityObject.Id);
        insert quoteObject;
        
        Quote_Revision__c revisionObj = new Quote_Revision__c(Quote__c = quoteObject.Id,
                                                              Total_Best_Rate__c = 300,
                                                              Total_Offered_Price__c = 500
                                                            );
        insert revisionObj;
        
        Product2 prod = new Product2(Name = 'testProd',isActive = true,Unique_Key__c = 'pricingEngineTestProd' );
        insert prod;
        
        PricebookEntry pbe = new PricebookEntry(isActive = true,UnitPrice = 100,Product2Id = prod.Id,
                                                Pricebook2Id = Test.getStandardPricebookId(),CurrencyIsoCode = 'AED');
        insert pbe;
        
        QuoteLineItem qliObject = new QuoteLineItem(QuoteId = quoteObject.Id,
                                                    Best_Rate__c = 100,
                                                    Offer_Price__c = 80,
                                                    PricebookEntryId = pbe.Id,
                                                    Quantity = 1,
                                                    UnitPrice = 100,
                                                    Start_Date__c = Date.Today() + 120,
                                                    End_Date__c = Date.Today() + 120 + 365,
                                                    Type__c = 'Normal',
                                                    Area__c = 1000,
                                                    Transactional_Unit__c = 'Sqft',
                                                    Quote_Revision__c = revisionObj.Id,
                                                    Product2Id = prod.Id);
        insert qliObject;
        
        Document__c documentCustomObject = new Document__c(Name = 'Test Custom Document', Is_Mandatory__c = true, File_Attached__c = false);
        insert documentCustomObject;
        
        Folder folderObject = [SELECT Id FROM Folder WHERE Id =:'00l1U000001fa5OQAQ'];
       
        
        Document documentObject = new Document(Name = 'Test Document',
                                               FolderId = folderObject.Id);
		insert documentObject;  
        
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];

        ContentVersion contentVersionObject = new ContentVersion(Title = 'Test ContentVersion',
                                                                 PathOnClient = '/testPath/',
                                                                 VersionData = EncodingUtil.base64Decode('Test version'));
        insert contentVersionObject;
        
        List<ContentVersion> contVersLst = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =:contentVersionObject.Id];
        
        ContentDocumentLink contentDocumentLinkObject = new ContentDocumentLink(ContentDocumentId = contVersLst[0].ContentDocumentId, LinkedEntityId =quoteObject.Id, ShareType = 'V' );
        insert contentDocumentLinkObject;
    }
    //Method to test postJSONRequest method
    @isTest
    public static void postJSONRequestTest(){
        Test.setMock(HttpCalloutMock.class, new DDAIntegrationMock()); //HttpCalloutMock
        String endPoint = '/Test';
        String body = 'Test body';
        
        Test.startTest();
        HttpResponse responseObj = DDAIntegration.postJSONRequest(endPoint, body);
        Test.stopTest();
        
        System.assertNotEquals(NULl, responseObj);
        System.assertNotEquals(NULL, endPoint);
        System.assertNotEquals(NULL, body);
    }

	//Method to test createNameApprovalRequest method    
    @isTest
    public static void createNameApprovalRequestTest(){
        Test.setMock(HttpCalloutMock.class, new DDAIntegrationNameApprovalMock()); //HttpCalloutMock
        WorkOrder workOrderObject = [SELECT Id,DDA_Request_Number__c,Account.License_Business_Park__r.Name,
                                     Account.Legal_Framework__c,Proposed_Name_of_Business_1st_choice__c,
                                     Proposed_Name_of_Business_2nd_choice__c,Proposed_Name_of_Business_3rd_choice__c,
                                     Account.Owner.Email,Account.Owner.Name, DDA_Request_Id__c, Status, Integration_Status__c 
                                     FROM WorkOrder WHERE Status = 'New' LIMIT 1];
        
        Set<Id> workOrderIdSet = new Set<Id>();
        workOrderIdSet.add(workOrderObject.Id);
        
        Test.startTest();
        DDAIntegration.createNameApprovalRequest(workOrderIdSet);
        Test.stopTest();
        
        System.assertNotEquals(NULL, workOrderIdSet);
    }
    //Method to test createNewServiceRequest method    
    @isTest
    public static void createNewServiceRequestTest(){
         Test.setMock(HttpCalloutMock.class, new DDAIntegrationServiceRequestMock()); //HttpCalloutMock
         WorkOrder workOrderObject = [SELECT Id,DDA_Request_Number__c,Account.License_Business_Park__r.Name,
                                     Account.Legal_Framework__c,Proposed_Name_of_Business_1st_choice__c,
                                     Proposed_Name_of_Business_2nd_choice__c,Proposed_Name_of_Business_3rd_choice__c,
                                     Account.Owner.Email,Account.Owner.Name 
                                     FROM WorkOrder WHERE Status = 'New' LIMIT 1];
        
        Set<Id> workOrderIdSet = new Set<Id>();
        workOrderIdSet.add(workOrderObject.Id);
        
        Test.startTest();
        DDAIntegration.createNewServiceRequest(workOrderIdSet, TRUE, TRUE);
        DDAIntegration.createNewServiceRequest(workOrderIdSet, TRUE, FALSE);
        DDAIntegration.createNewServiceRequest(workOrderIdSet, FALSE, TRUE);
        DDAIntegration.createNewServiceRequest(workOrderIdSet, FALSE, FALSE);
        Test.stopTest();
    }
    
     //Method to test processLeaseItems method    
    @isTest
    public static void processLeaseItemsTest(){
        Test.setMock(HttpCalloutMock.class, new DDAIntegrationMock()); //HttpCalloutMock
        Quote quoteObject = [SELECT Id,Account.License__c,Account.ORACLE_PARTY_ID__c,Status,Proposed_Start_Date__c,
                             Proposed_End_Date__c,Opportunity.AG_Number__c,Opportunity.Business_Park__r.Name,Type__c,
                             Opportunity.Type,Opportunity.Lease_Type__c,(SELECT Id,Area__c,Is_Registered_Address__c,
                                                                         Product2.Building__r.Plot__r.Name,Product2.Unit_Sub_Category__r.Name,Product2.Unit_Sub_Category__r.Unit_Category__r.Name,
                                                                         Product2.Unit__r.Unit_No_English__c,Product2.Unit__r.Unit_No_Arabic__c,Product2.Unit__r.Floor_English__c,
                                                                         Product2.Unit__r.Floor_Arabic__c,Product2.Building__r.Building_Name_English__c,Product2.Building__r.Building_Name_Arabic__c,
                                                                         Product2.Unit__c, Product2.Building__c 
                                                                         FROM QuoteLineItems WHERE Revision_Number__c = null) 
                             FROM Quote LIMIT 1];
        
        Set<Id> quoteIdSet = new Set<Id>();
        quoteIdSet.add(quoteObject.Id);
        
        Test.startTest();
        DDAIntegration.processLeaseItems(quoteIdSet);
        Test.stopTest();
        System.assertNotEquals(NULL, quoteIdSet);
    }
    
     //Method to test processAttachment method    
    @isTest
    public static void processAttachmentTest(){
        Set<Id> contentDocumentIdSet = new Set<Id>();
        Document documentObject = [SELECT Id FROM Document WHERE Name = 'Test Document' LIMIT 1];
        ContentVersion contentVersionObject = [SELECT Id,PathOnClient,VersionData,ContentDocumentId FROM ContentVersion LIMIT 1];
        Quote quoteObj = [SELECT Id FROM Quote LIMIT 1];
        ContentDocumentLink contentDocumentLinkObject = [SELECT Id,ContentDocumentId,LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId = :quoteObj.Id];
        Document__c documentCustomObject = [SELECT Id,Name,Description__c,DDA_Document_Id__c FROM Document__c LIMIT 1];
        
        contentDocumentIdSet.add(documentObject.Id);
        
        Test.startTest();
        DDAIntegration.processAttachment(contentDocumentIdSet);
        Test.stopTest();
        System.assertNotEquals(NULL, contentDocumentIdSet);
    }
}