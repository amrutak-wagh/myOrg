/**
 *  @description Test class for ContentDocumentLinkHandler
 *
 *  2019-13-06  Amruta Kumbhakarn
 */
@isTest
public class ContentDocumentLinkHandlerTest {
   
    /*Test setup to create data for Document,ContentVersion*/
    @testSetup public static void createData() {
        Document__c insDocument = new Document__c(Name= 'Test');
        insert insDocument;
        
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Penguins',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion;
        
        ContentVersion contentVersion1 = new ContentVersion(
            Title = 'Penguins',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion1;
   
    }
    
    /*This method tests if field on the Document__c is updated*/
    public static testmethod void positiveTestMethod(){
        Test.setMock(HttpCalloutMock.class, new DDAIntegrationProcessAttachmentMock());
        List<Document__c> documentList = [SELECT   Id
                                          		  ,File_Attached__c
                                          FROM   Document__C];
                                 
                                          
        
        List<ContentVersion> cvList = [SELECT  Id
                                           	  ,ContentDocumentId 
                                           FROM ContentVersion LIMIT 1];
        
        //create ContentDocumentLink  record 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = documentList[0].Id;
        cdl.ContentDocumentId = cvList[0].ContentDocumentId;
        cdl.shareType = 'V';
        
        Test.startTest();
        insert cdl;
        Test.stopTest();
        
        List<Document__c> updatedDocList = [SELECT   Id
                                     		 ,File_Attached__c
                                     FROM   DOCUMENT__C];
        System.assertEquals(updatedDocList[0].File_Attached__c,True);
    }
    
    public static testmethod void negativeTestMethod(){
       Test.setMock(HttpCalloutMock.class, new DDAIntegrationProcessAttachmentMock()); 
        List<Document__c> documentList = [SELECT   Id
                                          		  ,File_Attached__c
                                          FROM   Document__C];
        
        List<ContentVersion> cvList = [SELECT  Id
                                           	  ,ContentDocumentId 
                                           FROM ContentVersion];
        
        //create ContentDocumentLink  record 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = documentList[0].Id;
        cdl.ContentDocumentId = cvList[0].ContentDocumentId;
        cdl.shareType = 'V';
        
        insert cdl;
        
        List<Document__c> updatedDocList = [SELECT   Id
                                     		 ,File_Attached__c
                                     FROM   DOCUMENT__C];
        
        
        Test.startTest();
        ContentDocumentLink cdl2 = New ContentDocumentLink();
        cdl2.LinkedEntityId = documentList[0].Id;
        cdl2.ContentDocumentId = cvList[1].ContentDocumentId;
        cdl2.shareType = 'V';
        
        insert cdl2;
        Test.stopTest();
        
        List<Document__c> updatedDocListNew = [SELECT   Id
                                     		 ,File_Attached__c
                                     FROM   DOCUMENT__C];
        System.assertEquals(updatedDocList[0].File_Attached__c,updatedDocListNew[0].File_Attached__c);
    }
}