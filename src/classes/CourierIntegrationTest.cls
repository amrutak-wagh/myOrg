@IsTest
public class CourierIntegrationTest {
    @testSetup
    static void createTestData() {
        Account accountObject = new Account(Name = 'Test',Phone='1111111', Legal_Framework__c = 'Branch of a Foreign Company', Security_Clearance_Date__c = Date.today(), Security_Clearance_Status__c = 'NA', Business_Plan_Request_Date_Approval_Date__c = Date.today(),ORACLE_PARTY_ID__c = '1234');
        insert accountObject;
        Contact contactObject = new Contact(LastName = 'Test',Email = 'test.mail@test.com', isSubmit__c = true, ParentCon__c = true, AccountId= accountObject.Id ,Type__c = 'Billing;Leasing Contact;Licensee Contact;Manager Incharge');
        insert contactObject;
        
        Unit_Category__c unitCategoryObject = new Unit_Category__c(Name = 'Office');
        insert unitCategoryObject;

        Unit_Sub_Category__c unitSubCategoryObject = new Unit_Sub_Category__c(Name = 'Standard Office',Unit_Category__c = unitCategoryObject.Id);
        insert unitSubCategoryObject;
        
        Business_Park__c businessParkObject = new Business_Park__c(Name = 'Test BusinessPark',
                                                                                Business_Park_Yardi__c = 'Test Yardi');
        insert businessParkObject;
        
        Opportunity opportunityObject = new Opportunity(Name = 'Test Opportunity',
                                                        AccountId = accountObject.Id,
                                                        Contact__c = contactObject.Id,
                                                        Business_Park__c = businessParkObject.Id,
                                                        StageName = 'New',
                                                        CloseDate = System.today(),
                                                        Type = 'New'
                                                       );
        insert opportunityObject;
        
        Payment_Term__c paymentTermObject = new Payment_Term__c(Name = 'Test Payment Term',
                                                               Number_Of_Payments__c = 2);
        insert paymentTermObject;
        
        Quote quoteObject = new Quote(Name = 'Test Quote 1',
                                      Proposed_Start_Date__c = System.today(),
                                      Proposed_End_Date__c = System.today().addDays(2),
                                      Type__c = 'Expansion',
                                      Payment_Terms__c = paymentTermObject.Id,
                                      Proposed_Grace_Period__c = 12,
                                      Proposed_Grace_Period_Months__c = 3,
                                      OpportunityId = opportunityObject.Id,
                                      Number_Of_Payments__c = 10,
                                      Status = 'CCL Acceptance');
        insert quoteObject;
        
       	Courier_Request__c courierRequestObject = new Courier_Request__c(Account_Name__c = 'Test Account',
                                                                         Agreement_Num__c = 'Ag:1,Ag:2,Ag:3',
                                                                         Airway_Bill_Number__c = 'Airway-123',
                                                                         Building_Name__c = 'Test Building',
                                                                         Contact_Name__c = 'Test Contact',
                                                                         Delivery_Location__c = 'Test Delivery Location',
                                                                         Delivery_Zone__c = 'D3',
                                                                         Document_Type__c = 'Lease Document Delivery',
                                                                         Integration_Error_Message__c = 'Test Integration Error',
                                                                         Integration_Status__c = 'Success',
                                                                         Last_Updated_On__c = System.today(),
                                                                         Notes__c = 'Test Notes',
                                                                         Number_Of_Cheques__c = 7,
                                                                         Oracle_Party_ID__c = '1234',
                                                                         Reference_Mobile__c = '1234',
                                                                         Service_Request_Number__c = '12345',
                                                                         Source_System__c = 'Test Source System',
                                                                         Status__c = 'Out For Collection');
        insert courierRequestObject;
    }
	@isTest
    public static void testUpdateCourierServReq() {
		Courier_Request__c courierRequestObject = [SELECT Account_Name__c, Agreement_Num__c, Airway_Bill_Number__c, AXS_Request_Id__c, Building_Name__c,
                                                   Contact_Name__c, CreatedById, CurrencyIsoCode, Delivery_Location__c, Delivery_Zone__c, Document_Type__c,
                                                   Empost_Sticker__c, Envelope_Sticker__c, Integration_Error_Message__c, Integration_Status__c, LastModifiedById,
                                                   Last_Updated_On__c, Name, Notes__c, Number_Of_Cheques__c, Oracle_Party_ID__c, OwnerId, Reference_Mobile__c,
                                                   Service_Request_Number__c, Source_System__c, Status__c FROM Courier_Request__c WHERE Status__c = 'Out For Collection' LIMIT 1];
        
        CourierIntegration.SRRequest sRRequestObj = new CourierIntegration.SRRequest();
        sRRequestObj.SRN = courierRequestObject.Service_Request_Number__c;
        sRRequestObj.AWB = courierRequestObject.Airway_Bill_Number__c;
        sRRequestObj.delStatus = courierRequestObject.Status__c;
        sRRequestObj.sourceSystem = courierRequestObject.Source_System__c;
        sRRequestObj.status = courierRequestObject.Status__c;
        sRRequestObj.timeStamp = '2019';
        
        List<CourierIntegration.SRRequest> sRRequestList = new List<CourierIntegration.SRRequest>();
        sRRequestList.add(sRRequestObj);
        
        CourierIntegration courierIntegrationObj = new CourierIntegration();
        courierIntegrationObj.reqs = sRRequestList;
        String sRRequestObjjsonMsg = Json.serialize(courierIntegrationObj);
        
        RestResponse res = new RestResponse();
        RestRequest req = new RestRequest();
        
        req.httpMethod = 'POST';
		req.addHeader('Content-Type', 'application/json'); 
        req.requestURI = '/services/apexrest/csrupdate/all' ;
        req.requestBody = Blob.valueof(sRRequestObjjsonMsg);
        RestContext.request = req;
		RestContext.response = res;
        Test.startTest();
        CourierIntegration.updateCourierServReq();
        Test.stopTest();
        List<Courier_Request__c> crLst = [SELECT Id, Name, Status__c,Integration_Status__c FROM Courier_Request__c];
        System.assertNotEquals(crLst[0].Integration_Status__c, courierRequestObject.Integration_Status__c, 'Check if Courier_Request__c is updated or not');
        System.assertEquals('Ready',crLst[0].Integration_Status__c);
    }
    
    //Test if no Courier_Request__c records found
    @isTest
    public static void testNegativeUpdateCourierServReq() {
        Courier_Request__c courierRequestObject = [SELECT Account_Name__c, Agreement_Num__c, Airway_Bill_Number__c, AXS_Request_Id__c, Building_Name__c,
                                                   Contact_Name__c, CreatedById, CurrencyIsoCode, Delivery_Location__c, Delivery_Zone__c, Document_Type__c,
                                                   Empost_Sticker__c, Envelope_Sticker__c, Integration_Error_Message__c, Integration_Status__c, LastModifiedById,
                                                   Last_Updated_On__c, Name, Notes__c, Number_Of_Cheques__c, Oracle_Party_ID__c, OwnerId, Reference_Mobile__c,
                                                   Service_Request_Number__c, Source_System__c, Status__c FROM Courier_Request__c WHERE Status__c = 'Out For Collection' LIMIT 1];
        courierRequestObject.Service_Request_Number__c = '';
        update courierRequestObject;
        CourierIntegration.SRRequest sRRequestObj = new CourierIntegration.SRRequest();
        sRRequestObj.SRN = courierRequestObject.Service_Request_Number__c;
        sRRequestObj.AWB = courierRequestObject.Airway_Bill_Number__c;
        sRRequestObj.delStatus = courierRequestObject.Status__c;
        sRRequestObj.sourceSystem = courierRequestObject.Source_System__c;
        sRRequestObj.status = courierRequestObject.Status__c;
        sRRequestObj.timeStamp = '2019';
        List<CourierIntegration.SRRequest> sRRequestList = new List<CourierIntegration.SRRequest>();
        CourierIntegration.SRResponse srResponseObj = new CourierIntegration.SRResponse();
        sRRequestList.add(sRRequestObj);
        CourierIntegration courierIntegrationObj = new CourierIntegration();
        courierIntegrationObj.reqs = sRRequestList;
        String sRRequestObjjsonMsg = Json.serialize(courierIntegrationObj);
        
        RestResponse res = new RestResponse();
        RestRequest req = new RestRequest();
        
        req.httpMethod = 'POST';
		req.addHeader('Content-Type', 'application/json');
        req.requestURI = '/services/apexrest/csrupdate/all';
        req.requestBody = Blob.valueof(sRRequestObjjsonMsg);
        RestContext.request = req;
		RestContext.response = res;
        Test.startTest();
        CourierIntegration.updateCourierServReq();
        Test.stopTest();
        List<Courier_Request__c> crLst = [SELECT Id, Name, Status__c,Integration_Status__c FROM Courier_Request__c WHERE Integration_Status__c = 'Ready'];
        //System.assertEquals('DE_01',srResponseObj.respCode);
        System.assertEquals(crLst.size(), 0);
    }
}