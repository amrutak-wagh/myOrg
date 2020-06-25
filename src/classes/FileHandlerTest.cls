@istest
public class FileHandlerTest {
    private static Id accountId;
    
    @testsetup
    private static void testData()
    {
        TestDataFactory.getAccountWithContact();
        accountId = [Select id from account where name like'%test account%' limit 1].id;
        Document__c doc = new Document__c(name = 'Test 1', Account__c = accountId);
        Document__c doc1 = new Document__c(name = 'Test 2', Account__c = accountId);
        insert new List<Document__c>{doc, doc1};
            
            
            }
    
    @istest
    private static void posFileTest()
    {
        String jsonreq = '{"Params":{"ParentId":"'+accountId+'","FileName":"test file","FileType":"jpg","Base64String":"1257782001-snbjhsoasjl","Category":"Legal","Description":"testing"}}';
        Map<String, String> mparams= new Map<String, String>{'ParentId'=>accountId,
            'FileName'=> 'test file','FileType'=>'jpg','Base64String'=>EncodingUtil.base64encode(blob.valueOf('1257782001-snbjhsoasjl')),'Category'=>'Legal','Description'=>'testing'
            };
                Test.setMock(HttpCalloutMock.class, new DDAIntegrationMock());
        // Test.setMock(HttpCalloutMock.class, new NewRenewLeaseMockResponse(''));
        
        test.startTest();
        FilesHandler.doPost(mparams);
        test.stopTest();
        
    }
    @istest
    private static void getFileTest()
    {	
        
        // Document__c doc = new Document__c(name = 'Test 1', Public_link__c = 'test.com',Category__c= 'Legal',Description__c='test');
        //insert doc;
        // Document__c query = [SELECT   Id, Name,Public_link__c,Category__c, Description__c FROM Document__c  Where Id =:doc.Id];
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/files/'; 
        req.addParameter('Id', accountId);
        req.httpMethod = 'GET'; 
        RestContext.request = req;
        
        RestContext.response = res;
        
        //Test.setMock(HttpCalloutMock.class, new DDAIntegrationMock());
        Test.setMock(HttpCalloutMock.class, new NewRenewLeaseMockResponse(''));
        
        test.startTest();
        FilesHandler.doGet();
        test.stopTest();
        
    }
    @istest
    private static void getAllDocuments()
    {
        test.startTest();
        FilesHandler.getAllDocuments('ParentId');
        test.stopTest();
    }
}