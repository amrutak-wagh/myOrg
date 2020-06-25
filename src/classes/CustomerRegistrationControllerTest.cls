/************************************************************************************
* Name          : CustomerRegistrationControllerTest                                                 
* Description   : Test class for 'CustomerRegistrationController'
* Created Date  : 09/06/2019                                                    
* Created By    : 4C - Adeel Ahmad (adeel.ahmad@weare4c.com)
************************************************************************************/
@IsTest
public class CustomerRegistrationControllerTest {
    /*Common test data to be used in test class*/
    @testsetup public static void createTestData(){
        
        Country__c coun = new Country__c(Name  = 'Test Country');
        insert coun;
        
        Account a = new Account(Name = 'Test Account',Proposed_Legal_Form_of_Business__c = 'FZ-LLC Natural Person',License_Type__c = 'DED',
                               Parent_Company_Name__c = 'Test Comp Name',Parent_Company_Registration_Number__c = 'Test Comp Reg Number',
                               Statutory_Seat_Parent_Company__c = coun.Id,Date_of_Incorporation_Parent_Company__c = Date.newInstance(2018, 7, 16),
                               Community_Page_Indicator__c = 2);
        insert a;
        
        Contact c = new Contact(Encrypted_Contact_Id__c = 'TestEncryptedId',Email = 'test@test.com',code__c='12345678',LastName = 'Test',
                               AccountId = a.Id , Registration_Page_Indicator__c = 2);
        insert c;
        Contact memberCon = new Contact(Encrypted_Contact_Id__c = 'TestEncryptedId2',Email = 'test1@test1.com',code__c='123456789',LastName = 'Test1',
                               AccountId = a.Id , Registration_Page_Indicator__c = 3);
        insert memberCon;
        
        Id woRTId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByName().get('DDA Name Reservation').getRecordTypeId();
        WorkOrder wo = new WorkOrder(Proposed_Name_of_Business_1st_choice__c = 'Test Choice 1',Proposed_Name_of_Business_2nd_choice__c = 'Test Choice 2',
                                    Proposed_Name_of_Business_3rd_choice__c = 'Test Choice 3',RecordTypeId = woRTId,ContactId = c.Id);
        insert wo;
        
        Segment__c s =new Segment__c(Name = 'Test Segment');
        insert s;
        
        Activity_Custom__c parentActivity = new Activity_Custom__c(Name  = 'Test Activity',Active__c = True,Segment__c = s.Id);
        insert parentActivity;
        Requested_Licensed_Activity__c childActivity = new Requested_Licensed_Activity__c(Account__c = a.Id,Activity__c = parentActivity.Id,
                                                                                          Type__c = 'Requested Activity',Name = 'Test Requested Activity');
        insert childActivity;
        
        Business_park__c bp = new Business_park__c(Name  ='Test BP');
        insert bp;
        
        Lead l = new Lead(LastName = 'Test Lead',Company ='Test Company',Status ='Closed - Converted',
                         LeadSource = 'Web',Phone = '123456' ,Email = 'test@test.com',License_type__c = 'DED',Business_Park__c =bp.Id);
        
        insert l;
        
        Document__c insDocument = new Document__c(Name= 'Test',Account__c = c.AccountId);
        insert insDocument;
        Document__c insDocumentMember = new Document__c(Name= 'Test',Account__c = c.AccountId,Contact__c = memberCon.Id);
        insert insDocumentMember;
        
        ContentVersion contentVersion1 = new ContentVersion(
            Title = 'Penguins',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion1;
        
    }
    
    //Testmethod to test sendVerificationCode method
    public static testMethod void testsendVerificationCode(){
        Test.startTest();
        Contact c = [SELECT Encrypted_Contact_Id__c from Contact LIMIT 1];
        List<Document__c> documentList = [SELECT   Id
                                          		  ,File_Attached__c
                                          FROM   Document__C];
        Boolean isValid = CustomerRegistrationController.sendVerificationCode(c.Encrypted_Contact_Id__c);
        c = [SELECT Encrypted_Contact_Id__c,Code__c,AccountId from Contact LIMIT 1];
        Test.stopTest();
        
        System.assertEquals(isValid, true);
       	System.assertNotEquals(c.Code__c, NULL);
    }
    
     //Testmethod to test confirmVerificationCode method
    public static testmethod void testconfirmVerificationCode(){
        Contact c = [SELECT Encrypted_Contact_Id__c from Contact LIMIT 1];
        List<Document__c> documentList = [SELECT   Id
                                          		  ,File_Attached__c
                                          FROM   Document__C];
        CustomerRegistrationController.sendVerificationCode(c.Encrypted_Contact_Id__c);
        c = [SELECT Encrypted_Contact_Id__c,Code__c,AccountId from Contact LIMIT 1];
        Test.startTest();
        CustomerRegistrationController.AccountWrapper wrp = CustomerRegistrationController.confirmVerificationCode(c.Encrypted_Contact_Id__c,c.code__c);
        Test.stopTest();
        
        System.assertEquals(wrp.accountId, c.AccountId);
        System.assertEquals(wrp.contactId, c.Id);
    }
    
    //Testmethod to test saveBusinessFormInfo method
    public static testmethod void testsaveBusinessFormInfo(){
        Contact c = [SELECT Encrypted_Contact_Id__c from Contact LIMIT 1];
        List<Document__c> documentList = [SELECT   Id
                                          		  ,File_Attached__c
                                          FROM   Document__C];
        CustomerRegistrationController.sendVerificationCode(c.Encrypted_Contact_Id__c);
        c = [SELECT Encrypted_Contact_Id__c,Code__c,AccountId from Contact LIMIT 1];
        Test.startTest();
        CustomerRegistrationController.AccountWrapper wrp = CustomerRegistrationController.confirmVerificationCode(c.Encrypted_Contact_Id__c,c.code__c);
    	CustomerRegistrationController.saveBusinessFormInfo(String.valueOf(c.Id), String.valueOf(c.AccountId), JSON.serialize(wrp));
        Test.stopTest();
        
        System.assertEquals(wrp.accountId, c.AccountId);
        System.assertEquals(wrp.contactId, c.Id);
    }
    
    //Testmethod to test saveCompanyInfo method
    public static testmethod void testsaveCompanyInfo(){
        Account acc = [SELECT Id, Parent_Company_Name__c, Parent_Company_Registration_Number__c, Statutory_Seat_Parent_Company__c,
                       Date_of_Incorporation_Parent_Company__c
                       FROM Account WHERE Name ='Test Account'];
        Contact c = [SELECT Registration_Page_Indicator__c,Encrypted_Contact_Id__c from Contact LIMIT 1];
        List<Document__c> documentList = [SELECT   Id
                                          		  ,File_Attached__c
                                          FROM   Document__C];
        CustomerRegistrationController.sendVerificationCode(c.Encrypted_Contact_Id__c);
        c = [SELECT Encrypted_Contact_Id__c,Code__c,AccountId from Contact LIMIT 1];
        Test.startTest();
        CustomerRegistrationController.AccountWrapper wrp = CustomerRegistrationController.confirmVerificationCode(c.Encrypted_Contact_Id__c,c.code__c);
    	CustomerRegistrationController.saveCompanyInfo(String.valueOf(c.Id), String.valueOf(c.AccountId), JSON.serialize(wrp));
        Test.stopTest();
        
        c = [SELECT Registration_Page_Indicator__c,Encrypted_Contact_Id__c,Code__c,AccountId from Contact LIMIT 1];
        System.assertEquals(acc.Parent_Company_Name__c, wrp.parentCompanyName);
        System.assertEquals(acc.Parent_Company_Registration_Number__c, wrp.registrationNo);
        System.assertEquals(acc.Statutory_Seat_Parent_Company__c, wrp.selectedtatutorySeat);
        System.assertEquals(acc.Date_of_Incorporation_Parent_Company__c, wrp.dateOfIncorporation);
        System.assertEquals(c.Registration_Page_Indicator__c, 3);
    }
    
    //Testmethod to test saveDocuments method
    public static testmethod void testsaveDocuments(){
        Contact c = [SELECT Registration_Page_Indicator__c,Encrypted_Contact_Id__c,AccountId from Contact LIMIT 1];
        List<Document__c> documentList = [SELECT   Id
                                          		  ,File_Attached__c
                                          FROM   Document__C];
        CustomerRegistrationController.sendVerificationCode(c.Encrypted_Contact_Id__c);
        
        Test.startTest();
    	CustomerRegistrationController.AccountWrapper wrp = CustomerRegistrationController.saveDocuments(String.valueOf(c.Id), String.valueOf(c.AccountId));
        Test.stopTest();
        
        c = [SELECT Registration_Page_Indicator__c,Encrypted_Contact_Id__c,Code__c,AccountId from Contact LIMIT 1];
        System.assertEquals(c.Registration_Page_Indicator__c, 6);
        System.assertEquals(wrp.isValid, true);
    }
    
    //Testmethod to test saveActivities method
    public static testmethod void testsaveActivities(){
        Contact c = [SELECT Encrypted_Contact_Id__c from Contact LIMIT 1];
        List<Document__c> documentList = [SELECT   Id
                                          		  ,File_Attached__c
                                          FROM   Document__C];
        CustomerRegistrationController.sendVerificationCode(c.Encrypted_Contact_Id__c);
        c = [SELECT Registration_Page_Indicator__c,Encrypted_Contact_Id__c,Code__c,AccountId from Contact LIMIT 1];
        Test.startTest();
        CustomerRegistrationController.AccountWrapper wrp = CustomerRegistrationController.confirmVerificationCode(c.Encrypted_Contact_Id__c,c.code__c);
        CustomerRegistrationController.saveActivities(String.valueOf(c.Id), String.valueOf(c.AccountId), JSON.serialize(wrp.activities));
        Test.stopTest();
        
        c = [SELECT Registration_Page_Indicator__c,Encrypted_Contact_Id__c,Code__c,AccountId from Contact LIMIT 1];
		System.assertEquals(c.Registration_Page_Indicator__c, 4);
        System.assertEquals(wrp.accountId, c.AccountId);   
        System.assertEquals(wrp.contactId, c.Id);
    }
    
    //Testmethod to test saveMembersInfo method
    public static testmethod void testsaveMembersInfo(){
        Contact c = [SELECT Encrypted_Contact_Id__c from Contact LIMIT 1];
        List<Document__c> documentList = [SELECT   Id
                                          		  ,File_Attached__c
                                          FROM   Document__C];
        CustomerRegistrationController.sendVerificationCode(c.Encrypted_Contact_Id__c);
        c = [SELECT Registration_Page_Indicator__c,Encrypted_Contact_Id__c,Code__c,AccountId from Contact LIMIT 1];
        Test.startTest();
        CustomerRegistrationController.AccountWrapper wrp = CustomerRegistrationController.confirmVerificationCode(c.Encrypted_Contact_Id__c,c.code__c);
        CustomerRegistrationController.saveMembersInfo(String.valueOf(c.Id), String.valueOf(c.AccountId), JSON.serialize(wrp.members));
        Test.stopTest();
        
        c = [SELECT Registration_Page_Indicator__c,Encrypted_Contact_Id__c,Code__c,AccountId from Contact LIMIT 1];
        System.assertEquals(c.Registration_Page_Indicator__c, 5);
        System.assertEquals(wrp.accountId, c.AccountId);   
        System.assertEquals(wrp.contactId, c.Id);
    }
    
    //Testmethod to test getNewMember method
    public static testmethod void testgetNewMember(){
        Contact c = [SELECT Encrypted_Contact_Id__c from Contact LIMIT 1];
        List<Document__c> documentList = [SELECT   Id
                                          		  ,File_Attached__c
                                          FROM   Document__C];
        CustomerRegistrationController.sendVerificationCode(c.Encrypted_Contact_Id__c);
        c = [SELECT FirstName,LastName,Encrypted_Contact_Id__c,Code__c,AccountId from Contact LIMIT 1];
        Test.startTest();
        CustomerRegistrationController.MemberWrapper memberWrapperObject = CustomerRegistrationController.getNewMember('FZ-LLC Natural Person');
        Test.stopTest();
        
        System.assertNotEquals(memberWrapperObject, NULL);
        System.assertEquals(memberWrapperObject.firstName , '');
        SYstem.assertEquals(memberWrapperObject.lastName , '');
    }
    
    // Method to test submitApplication method
    public static testmethod void testsubmitApplication(){
        Contact c = [SELECT Encrypted_Contact_Id__c from Contact LIMIT 1];
        List<Document__c> documentList = [SELECT   Id
                                          		  ,File_Attached__c
                                          FROM   Document__C];
        CustomerRegistrationController.sendVerificationCode(c.Encrypted_Contact_Id__c);
        c = [SELECT Registration_Page_Indicator__c,Encrypted_Contact_Id__c,Code__c,AccountId from Contact LIMIT 1];
        Test.startTest();
    	CustomerRegistrationController.AccountWrapper wrp = CustomerRegistrationController.submitApplication(String.valueOf(c.Id), String.valueOf(c.AccountId));
        Test.stopTest();
        
        c = [SELECT Registration_Page_Indicator__c,Encrypted_Contact_Id__c,Code__c,AccountId from Contact LIMIT 1];
        System.assertEquals(c.Registration_Page_Indicator__c, 7);
        System.assertEquals(wrp.isValid, True);   
    }
    
    // Method to test getMembers method
    public static testmethod void testgetMembers(){
        Account accountObject = new Account(Name='Test');
        insert accountObject;
        Contact contactObject = [SELECT Registration_Page_Indicator__c,Encrypted_Contact_Id__c,Code__c,AccountId from Contact LIMIT 1];
        
        Test.startTest();
        List<CustomerRegistrationController.MemberWrapper> memberWrapperList = CustomerRegistrationController.getMembers('FZ-LLC Natural Person', contactObject.Id,accountObject.Id);
        Test.stopTest();
        
        System.assertEquals(memberWrapperList.size(), 1);
    }
    // Method to test search method - Test 1
    public static testmethod void testsearch1(){
        String searchTerm = '';
        String icon = '';
        String sObjectName = '';
        Segment__c segmentObject = [SELECT Id, Name FROM Segment__c WHERE Name = 'Test Segment' LIMIT 1];
        Activity_Custom__c activityObject = [SELECT Id, Name, Segment__c FROM Activity_Custom__c WHERE Name = 'Test Activity' LIMIT 1];
        Country__c countryObject = [SELECT Id, Name FROM Country__c  WHERE Name  = 'Test Country' LIMIT 1];
        sObjectName = segmentObject.Id.getSObjectType().getDescribe().getName();
        searchTerm = segmentObject.Name;
        
        Test.startTest();
        List<LookupSearchResult> results = CustomerRegistrationController.search(searchTerm, activityObject.Id, sObjectName, icon, segmentObject.Id, String.valueOf(activityObject.Id));
        Test.stopTest();
        
        System.assertEquals(results.size(), 0);
        
    }
    
    // Method to test search method - Test 2
    public static testmethod void testsearch2(){
        String searchTerm = '';
        String icon = '';
        String sObjectName = '';
        Segment__c segmentObject = [SELECT Id, Name FROM Segment__c WHERE Name = 'Test Segment' LIMIT 1];
        Activity_Custom__c activityObject = [SELECT Id, Name, Segment__c FROM Activity_Custom__c WHERE Name = 'Test Activity' LIMIT 1];
        Country__c countryObject = [SELECT Id, Name FROM Country__c  WHERE Name  = 'Test Country' LIMIT 1];
        sObjectName = activityObject.Id.getSObjectType().getDescribe().getName();
        searchTerm = activityObject.Name;
        
        Test.startTest();
        List<LookupSearchResult> results = CustomerRegistrationController.search(searchTerm, activityObject.Id, sObjectName, icon, segmentObject.Id, String.valueOf(segmentObject.Id));
        Test.stopTest();
        
        System.assertEquals(results.size(), 0);
    }
    
    // Method to test search method - Test 3
    public static testmethod void testsearch3(){
        String searchTerm = '';
        String icon = '';
        String sObjectName = '';
        Segment__c segmentObject = [SELECT Id, Name FROM Segment__c WHERE Name = 'Test Segment' LIMIT 1];
        Activity_Custom__c activityObject = [SELECT Id, Name, Segment__c FROM Activity_Custom__c WHERE Name = 'Test Activity' LIMIT 1];
        
        sObjectName = segmentObject.Id.getSObjectType().getDescribe().getName();
        searchTerm = segmentObject.Name.substring(0,1);
        
        Test.startTest();
        List<LookupSearchResult> results = CustomerRegistrationController.search(searchTerm, activityObject.Id, sObjectName, icon, segmentObject.Id, String.valueOf(segmentObject.Id));
        Test.stopTest();
        
        System.assertEquals(results.size(), 1);
    }
    
    // Method to test search method - Test 4
    public static testmethod void testsearch4(){
        String searchTerm = '';
        String icon = '';
        String sObjectName = '';
        Segment__c segmentObject = [SELECT Id, Name FROM Segment__c WHERE Name = 'Test Segment' LIMIT 1];
        Activity_Custom__c activityObject = [SELECT Id, Name, Segment__c FROM Activity_Custom__c WHERE Name = 'Test Activity' LIMIT 1];
        
        sObjectName = activityObject.Id.getSObjectType().getDescribe().getName();
        searchTerm = activityObject.Name.substring(0,1);
        System.debug('searchTerm==> ' + searchTerm);
        Test.startTest();
        List<LookupSearchResult> results = CustomerRegistrationController.search(searchTerm, activityObject.Id, sObjectName, icon, segmentObject.Id, String.valueOf(segmentObject.Id));
        Test.stopTest();
        
        System.assertEquals(results.size(), 1);
    }
}