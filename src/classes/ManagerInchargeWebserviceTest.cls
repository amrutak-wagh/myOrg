/**
*  @description Test class for LicenseRegistrationWebservice
*
*  2019-08-22  Shraddha N    First version
*  
*/

@isTest
public class ManagerInchargeWebserviceTest  {
    
    /*Common test data to be used in test class*/
    @testSetup
    static void testData(){
        
        Account accountObject = new Account(Name = 'Test Account',
                                            Phone='1111111', 
                                            Legal_Framework__c = 'Branch of a Foreign Company', 
                                            Security_Clearance_Date__c = Date.today(), 
                                            Security_Clearance_Status__c = 'NA', 
                                            Business_Plan_Request_Date_Approval_Date__c = Date.today(),
                                            ORACLE_PARTY_ID__c = '1234');
        insert accountObject;
        Contact contactObject = new Contact(LastName = 'Test Contact',
                                            Email = 'test.mail@test.com', 
                                            isSubmit__c = true, 
                                            ParentCon__c = true, 
                                            AccountId= accountObject.Id ,
                                            Type__c = 'Licensing Contact',
                                            DDA_Manger_Id__c = 'M-1234',
                                            Signature_Document_Id__c = 'S-123');
        insert contactObject;
        
        Country__c countryObject = new Country__c(Name = 'Test UK');
        insert countryObject;
        
        Document__c documentObject = new Document__c(Name = 'Test Document', Is_Mandatory__c = true, File_Attached__c = false);
        insert documentObject;
        
        ContentVersion contentVersionObject = new ContentVersion(Title = 'Test ContentVersion',
                                                                 PathOnClient = '/testPath/',
                                                                 VersionData = EncodingUtil.base64Decode('Test version'));
        insert contentVersionObject;
    }
    
    //Method to test pushContacts method
    @isTest
    public static void pushContactsTest(){
        List<ManagerInchargeWebservice.Identity> identityList = new List<ManagerInchargeWebservice.Identity>();
        
        Account accountObject = [SELECT Id, Name, ORACLE_PARTY_ID__c FROM Account WHERE Name = 'Test Account' LIMIT 1];
        Contact contactObject = [SELECT FirstName,LastName, Phone, Middle_Name__c, Middle_Name_Arabic__c, Arabic_Full_Name__c,
                                 MobilePhone, Email, DDA_Manger_Id__c, Nationality__c, AccountId, Type__c, Client_Profile_Status__c
                                 FROM Contact LIMIT 1];
        Country__c countryObject = [SELECT Id, Name FROM Country__c LIMIT 1];
        
        List<String> orcIds = New List<String>();
        orcIds.add(accountObject.ORACLE_PARTY_ID__c);
        List<String> orcNotPresent = new List<String>();
        orcNotPresent.add('12234');
        
        ManagerInchargeWebservice.Identity identityObject = new ManagerInchargeWebservice.Identity();
        identityObject.arabic_name = 'test';
        identityObject.email= 'test@gmail.com';
        identityObject.managerIdentityId= contactObject.DDA_Manger_Id__c;
        identityObject.middleName = 'TestMiddleName';
        identityObject.middleNameArabic = 'TestmiddleNameArabic';
        identityObject.mobile= ' 7851285313';
        identityObject.name='testName';
        identityObject.nationality=countryObject.Name;
        identityObject.orcIds=orcIds;
        identityObject.phone= '723663571';
        
		identityList.add(identityObject);
        
        Test.startTest();
        ManagerInchargeWebservice.RequestResponse response1 =  ManagerInchargeWebservice.pushContacts(identityList);
        
        identityObject.orcIds=orcNotPresent;
        identityList.add(identityObject);
        ManagerInchargeWebservice.RequestResponse response2 =  ManagerInchargeWebservice.pushContacts(identityList);
        Test.stopTest();
        
        System.assertNotEquals(NULL, response1);
        System.assertNotEquals(NULL, response2);
        System.assertEquals(TRUE, response1.success);
        System.assertEquals(FALSE, response2.success);
        System.assertEquals('', response1.errorMessage);
        System.assertNotEquals('', response2.errorMessage);
    }
    
    //Method to test pushContacts method if ORC not present 
    @isTest
    public static void pushContactsTestNonOcr(){
        List<ManagerInchargeWebservice.Identity> identityList = new List<ManagerInchargeWebservice.Identity>();
        
        Account accountObject = [SELECT Id, Name, ORACLE_PARTY_ID__c FROM Account WHERE Name = 'Test Account' LIMIT 1];
        Contact contactObject = [SELECT FirstName,LastName, Phone, Middle_Name__c, Middle_Name_Arabic__c, Arabic_Full_Name__c,
                                 MobilePhone, Email, DDA_Manger_Id__c, Nationality__c, AccountId, Type__c, Client_Profile_Status__c
                                 FROM Contact LIMIT 1];
        Country__c countryObject = [SELECT Id, Name FROM Country__c LIMIT 1];
        
        List<String> orcIds = New List<String>();
        orcIds.add(accountObject.ORACLE_PARTY_ID__c);
        List<String> orcNotPresent = new List<String>();
        orcNotPresent.add('12234');
        
        ManagerInchargeWebservice.Identity identityObject = new ManagerInchargeWebservice.Identity();
        identityObject.arabic_name = 'test';
        identityObject.email= 'test@gmail.com';
        //identityObject.managerIdentityId= contactObject.DDA_Manger_Id__c;
        identityObject.middleName = 'TestMiddleName';
        identityObject.middleNameArabic = 'TestmiddleNameArabic';
        identityObject.mobile= ' 7851285313';
        identityObject.name='testName';
        identityObject.nationality=countryObject.Name;
        identityObject.orcIds=orcIds;
        identityObject.phone= '723663571';
        
		identityList.add(identityObject);
        
        Test.startTest();
        ManagerInchargeWebservice.RequestResponse response1 =  ManagerInchargeWebservice.pushContacts(identityList);
        
        //identityObject.orcIds=orcNotPresent;
        //identityList.add(identityObject);
        ManagerInchargeWebservice.RequestResponse response2 =  ManagerInchargeWebservice.pushContacts(identityList);
        Test.stopTest();
        
        System.assertNotEquals(NULL, response1);
        System.assertNotEquals(NULL, response2);
    }
    
    //Method to test pushLicAttachment method
    @isTest
    public static void pushLicAttachmentTest(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ManagerInchargeWebserviceMock()); //HttpCalloutMock
        List<ManagerInchargeWebservice.Attach> attachList = new List<ManagerInchargeWebservice.Attach>();
        
        Account accountObject = [SELECT Id, Name, ORACLE_PARTY_ID__c FROM Account WHERE Name = 'Test Account' LIMIT 1];
        Document__c documentObject = [SELECT Name FROM Document__c WHERE Name = 'Test Document' LIMIT 1];
       
        
        ManagerInchargeWebservice.Attach attachObject = new ManagerInchargeWebservice.Attach();
        attachObject.base64String = 'Test string';
        attachObject.documentName = documentObject.Name;
        attachObject.docFileName = 'Test_File';
        //attachObject.identityId = 'M-1234';
        attachObject.orcId = accountObject.ORACLE_PARTY_ID__c;
        
        ManagerInchargeWebservice.Attach attachObject2 = new ManagerInchargeWebservice.Attach();
        attachObject2.orcId = '1234';
        
		attachList.add(attachObject);    
        
        
        ManagerInchargeWebservice.RequestResponse response1 = ManagerInchargeWebservice.pushLicAttachment(attachList);
        ManagerInchargeWebservice.RequestResponse response3 = ManagerInchargeWebservice.pushIdentityAttachment(attachList);
        attachList.add(attachObject2);
        ManagerInchargeWebservice.RequestResponse response2 = ManagerInchargeWebservice.pushLicAttachment(attachList);
        ManagerInchargeWebservice.RequestResponse response4 = ManagerInchargeWebservice.pushIdentityAttachment(attachList);
        Test.stopTest();
        
        System.assertNotEquals(NULL, response1);
        System.assertNotEquals(NULL, response2);
        System.assertNotEquals(NULL, response3);
        System.assertNotEquals(NULL, response4);
        System.assertEquals(TRUE, response1.success);
        System.assertEquals(FALSE, response2.success);
        System.assertEquals('', response1.errorMessage);
        System.assertNotEquals('', response2.errorMessage);
    }
    
    //Method to test pushIdentityAttachment method
   /* @isTest
    public static void pushIdentityAttachmentTest(){
       Test.setMock(HttpCalloutMock.class, new DDAIntegrationMock()); //HttpCalloutMock
        List<ManagerInchargeWebservice.Attach> attachList = new List<ManagerInchargeWebservice.Attach>();
        
        Account accountObject = [SELECT Id, Name, ORACLE_PARTY_ID__c FROM Account WHERE Name = 'Test Account' LIMIT 1];
        Document__c documentObject = [SELECT Name FROM Document__c WHERE Name = 'Test Document' LIMIT 1];
       
        ManagerInchargeWebservice.Attach attachObject = new ManagerInchargeWebservice.Attach();
        attachObject.base64String = 'Test string';
        attachObject.documentName = documentObject.Name;
        attachObject.docFileName = 'Test_File';
       // attachObject.identityId = 'M-1234';
        attachObject.orcId = accountObject.ORACLE_PARTY_ID__c;
        
        ManagerInchargeWebservice.Attach attachObject2 = new ManagerInchargeWebservice.Attach();
        attachObject2.orcId = '1234';
        
		attachList.add(attachObject);    
        
        Test.startTest();
        ManagerInchargeWebservice.RequestResponse response1 = ManagerInchargeWebservice.pushIdentityAttachment(attachList);
        attachList.add(attachObject2);
        ManagerInchargeWebservice.RequestResponse response2 = ManagerInchargeWebservice.pushIdentityAttachment(attachList);
        Test.stopTest();
        
        System.assertNotEquals(NULL, response1);
        System.assertNotEquals(NULL, response2);
        System.assertEquals(TRUE, response1.success);
        System.assertEquals(FALSE, response2.success);
        System.assertEquals('', response1.errorMessage);
        System.assertNotEquals('', response2.errorMessage);
    }*/
}