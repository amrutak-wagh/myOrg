/**
 *  @description Test class for CourierDocCollection
 *
 *  2019-08-21  Shraddha N    First version
 *  
 */
@isTest
public class CourierDocCollectionTest {
	/*Common test data to be used in test class*/
    @testSetup
    static void setUp(){
       // Test.setMock(HttpCalloutMock.class, new CourierDocCollectionMock()); //HttpCalloutMock
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
                                                                         Integration_Status__c = 'Ready',
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
    
    //Method to test getOpNoSchedules method
    @isTest
    static void getOpNoSchedulesTest1(){
        Quote quoteObject = [SELECT Id,Account.ORACLE_PARTY_ID__c,Opportunity.AG_Number__c,Status,Payment_Terms__r.No_of_Installments__c,Category__c 
                                  FROM Quote WHERE Name = 'Test Quote 1' LIMIT 1];
        
       
        RestResponse res = new RestResponse();
        RestRequest req = new RestRequest();
        
        req.params.put('oracleId', '1234');
        req.httpMethod = 'Get';
		req.addHeader('Content-Type', 'application/json'); // Add a JSON Header as it is validated
        req.requestURI = '/services/apexrest/cdcollection/all' ;
        
        RestContext.request = req;
		RestContext.response = res;
        
        Test.startTest();
        CourierDocCollection.getOpNoSchedules();
        Test.stopTest();
		
        System.assertNotEquals(res, null);
       
    }
    
     @isTest
    static void getOpNoSchedulesTest2(){
        Quote quoteObject = [SELECT Id,Account.ORACLE_PARTY_ID__c,Opportunity.AG_Number__c,Status,Payment_Terms__r.No_of_Installments__c,Category__c 
                                  FROM Quote WHERE Name = 'Test Quote 1' LIMIT 1];
        
       
        RestResponse res = new RestResponse();
        RestRequest req = new RestRequest();
        
        req.params.put('oracleId', '1234');
        req.httpMethod = 'Get';
		req.addHeader('Content-Type', 'application/json'); // Add a JSON Header as it is validated
        req.requestURI = '/services/apexrest/cdcollection/all' ;
        
        RestContext.request = req;
		RestContext.response = res;
        
        Test.startTest();
        req.params.put('oracleId', '');
        CourierDocCollection.getOpNoSchedules();
        Test.stopTest();

        System.assertNotEquals(res, null);
    }
    //Method to test createDocCollServReq method
    @isTest
    static void createDocCollServReqTest(){
        
        Courier_Request__c courierRequestObject = [SELECT Account_Name__c, Agreement_Num__c, Airway_Bill_Number__c, AXS_Request_Id__c, Building_Name__c,
                                                   Contact_Name__c, CreatedById, CurrencyIsoCode, Delivery_Location__c, Delivery_Zone__c, Document_Type__c,
                                                   Empost_Sticker__c, Envelope_Sticker__c, Integration_Error_Message__c, Integration_Status__c, LastModifiedById,
                                                   Last_Updated_On__c, Name, Notes__c, Number_Of_Cheques__c, Oracle_Party_ID__c, OwnerId, Reference_Mobile__c,
                                                   Service_Request_Number__c, Source_System__c, Status__c FROM Courier_Request__c WHERE Status__c = 'Out For Collection' LIMIT 1];
        
        CourierDocCollection.SRRequest sRRequestObj = new CourierDocCollection.SRRequest();
        sRRequestObj.SRN = courierRequestObject.Service_Request_Number__c;
        sRRequestObj.AWB = courierRequestObject.Airway_Bill_Number__c;
        sRRequestObj.delStatus = courierRequestObject.Status__c;
        sRRequestObj.sourceSystem = courierRequestObject.Source_System__c;
        sRRequestObj.timeStamp = '2019';
        sRRequestObj.acName = courierRequestObject.Account_Name__c;
        sRRequestObj.conName = courierRequestObject.Contact_Name__c;
        sRRequestObj.oracleId = courierRequestObject.Oracle_Party_ID__c;
        sRRequestObj.docType = courierRequestObject.Document_Type__c;
        sRRequestObj.refMobile = courierRequestObject.Reference_Mobile__c;
        sRRequestObj.delZone = courierRequestObject.Delivery_Zone__c;
        sRRequestObj.bldngName = courierRequestObject.Building_Name__c;
        sRRequestObj.delLoc = courierRequestObject.Delivery_Location__c;
        sRRequestObj.notes = courierRequestObject.Notes__c;
        sRRequestObj.axsReqId = courierRequestObject.AXS_Request_Id__c;
        sRRequestObj.agNo = courierRequestObject.Agreement_Num__c;
        sRRequestObj.noCheques = String.valueOf(courierRequestObject.Number_Of_Cheques__c);
        
        List<CourierDocCollection.SRRequest> sRRequestList = new List<CourierDocCollection.SRRequest>();
        sRRequestList.add(sRRequestObj);
        
        CourierDocCollection courierDocCollectionObj = new CourierDocCollection();
        courierDocCollectionObj.reqs = sRRequestList;
        String sRRequestObjjsonMsg = Json.serialize(courierDocCollectionObj);
        
        CourierDocCollection.SRRequest sRRequestObj2 = new CourierDocCollection.SRRequest();
        List<CourierDocCollection.SRRequest> sRRequestList2 = new List<CourierDocCollection.SRRequest>();
        sRRequestList2.add(sRRequestObj2);
        
        courierDocCollectionObj.reqs = sRRequestList2;
        String sRRequestObjjsonMsg2 = Json.serialize(courierDocCollectionObj);
        
        
        RestResponse res = new RestResponse();
        RestRequest req = new RestRequest();
        Test.startTest();
        req.httpMethod = 'POST';
		req.addHeader('Content-Type', 'application/json'); // Add a JSON Header as it is validated
        req.requestURI = '/services/apexrest/cdcollection' ;
        req.requestBody = Blob.valueof(sRRequestObjjsonMsg);
        
        RestContext.request = req;
		RestContext.response = res;
        
        System.debug('REQUEST-------> ' + req);
        
        
        CourierDocCollection.createDocCollServReq();
        
        req.httpMethod = 'POST';
		req.addHeader('Content-Type', 'application/json'); // Add a JSON Header as it is validated
        req.requestURI = '/services/apexrest/cdcollection' ;
        req.requestBody = Blob.valueof(sRRequestObjjsonMsg2);
        
        RestContext.request = req;
		RestContext.response = res;
       
        CourierDocCollection.createDocCollServReq();
        Test.stopTest();
        
        System.assertNotEquals(NULL, req);
        System.assertNotEquals(NULL, courierDocCollectionObj.reqs);
       	System.assertEquals(1, sRRequestList.size());
        System.assertEquals(1, sRRequestList2.size());
        System.assertNotEquals(NULL, sRRequestObjjsonMsg);
        System.assertNotEquals(NULL, sRRequestObjjsonMsg2);
    }
}