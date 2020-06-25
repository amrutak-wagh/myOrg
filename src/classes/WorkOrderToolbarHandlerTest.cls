/**
*  @description Test class for WorkOrderToolbarHandler
*
*  2019-08-19  Shraddha N    First version
*  
*/

@isTest
public class WorkOrderToolbarHandlerTest {
    
    /*Common WorkOrder test data to be used in test class*/
    public static WorkOrder createWorkOrderData(){
        Test.setMock(HttpCalloutMock.class, new DDAIntegrationServiceRequestMock()); //HttpCalloutMock
        Case caseObject = new Case(Status = 'New');
        insert caseObject;
        Account accountObject = new Account(Name = 'Test',Phone='1111111', Legal_Framework__c = 'Branch of a Foreign Company', Security_Clearance_Date__c = Date.today(), Security_Clearance_Status__c = 'NA', Business_Plan_Request_Date_Approval_Date__c = Date.today());
        insert accountObject;
        Contact contactObject = new Contact(LastName = 'Test',Email = 'test.mail@test.com', isSubmit__c = true, ParentCon__c = true, AccountId= accountObject.Id ,Type__c = 'Billing;Leasing Contact;Licensee Contact;Manager Incharge');
        insert contactObject;
        WorkOrder workOrderObject = new WorkOrder(Status = 'New', 
                                                  Description = 'test Description', 
                                                  AccountId = accountObject.Id, 
                                                  CaseId = caseObject.Id, 
                                                  Skip_Lease_Validation__c = false, 
                                                  Work_Order_Number__c = 1, 
                                                  Account_Type__c = 'Trust Account', 
                                                  Minimum_Required_Share_Capital__c = 10000,
                                                  IsMovedToNextStep__c = true);
        insert workOrderObject;    
        
        Business_Park__c businessParkObject = new Business_Park__c(Name = 'Test BusinessPark',
                                                                   Business_Park_Yardi__c = 'Test Yardi');
        insert businessParkObject;
        
        Opportunity opportunityObject = new Opportunity(Name = 'Test Opportunity',
                                                        AccountId = accountObject.Id,
                                                        Contact__c = contactObject.Id,
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
        
        QuoteLineItem qliObject1 = new QuoteLineItem(QuoteId = quoteObject.Id,
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
                                                     Product2Id = prod.Id,
                                                     Is_Registered_Address__c = TRUE);
        insert qliObject1;
        
        QuoteLineItem qliObject2 = new QuoteLineItem(QuoteId = quoteObject.Id,
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
                                                     Product2Id = prod.Id
                                                    );
        insert qliObject2;
        
        Document__c documentObject = new Document__c(Name = 'Test Document', Work_Order__c = workOrderObject.Id, Is_Mandatory__c = true, File_Attached__c = false);
        insert documentObject;
        
        
        return workOrderObject;
    }
    
    /*Common WorkOrder test data to be used in test class to set errorMessage blank*/
    public static WorkOrder setUpWorkOrderData(){
        Test.setMock(HttpCalloutMock.class, new DDAIntegrationServiceRequestMock()); //HttpCalloutMock
        Case caseObject = new Case(Status = 'New');
        insert caseObject;
        Account accountObject = new Account(Name = 'Test',Phone='1111111', Legal_Framework__c = 'Branch of a Foreign Company', Security_Clearance_Date__c = Date.today(), Security_Clearance_Status__c = 'NA', Business_Plan_Request_Date_Approval_Date__c = Date.today());
        insert accountObject;
        Contact contactObject = new Contact(LastName = 'Test',Email = 'test.mail@test.com', isSubmit__c = true, ParentCon__c = true, AccountId= accountObject.Id ,Type__c = 'Billing;Leasing Contact;Licensee Contact;Manager Incharge');
        insert contactObject;
        WorkOrder workOrderObject = new WorkOrder(Status = 'New', 
                                                  Description = 'test Description', 
                                                  AccountId = accountObject.Id, 
                                                  CaseId = caseObject.Id, 
                                                  Skip_Lease_Validation__c = true, 
                                                  Work_Order_Number__c = 1, 
                                                  Account_Type__c = 'Trust Account', 
                                                  Minimum_Required_Share_Capital__c = 10000,
                                                  IsMovedToNextStep__c = true);
        insert workOrderObject;    
        
        Business_Park__c businessParkObject = new Business_Park__c(Name = 'Test BusinessPark',
                                                                   Business_Park_Yardi__c = 'Test Yardi');
        insert businessParkObject;
        
        Opportunity opportunityObject = new Opportunity(Name = 'Test Opportunity',
                                                        AccountId = accountObject.Id,
                                                        Contact__c = contactObject.Id,
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
        
        Document__c documentObject = new Document__c(Name = 'Test Document', Work_Order__c = workOrderObject.Id, Is_Mandatory__c = true, File_Attached__c = true);
        insert documentObject;
        
        Segment__c segmentObject = new Segment__c(Name = 'Test Segment');
        insert segmentObject;
        
        Activity_Custom__c activityObject = new Activity_Custom__c(Name = 'Test Activity', Segment__c = segmentObject.Id);
        insert activityObject;
        
        Trust_Account_Payment__c trustAccountPaymentObject = new Trust_Account_Payment__c(Work_Order__c = workOrderObject.Id);
        insert trustAccountPaymentObject;
        
        Requested_Licensed_Activity__c reqLicencedActivityObject = new Requested_Licensed_Activity__c(Account__c = workOrderObject.AccountId,
                                                                                                      Activity__c = activityObject.Id,
                                                                                                      Type__c = 'Requested Activity');
        insert reqLicencedActivityObject;
        
        
        return workOrderObject;
    }
    
    /*Common QLI test data to be used in test class*/
    public static QuoteLineItem createQuoteLineItemData(){
        Test.setMock(HttpCalloutMock.class, new DDAIntegrationServiceRequestMock()); //HttpCalloutMock
        Case caseObject = new Case(Status = 'New');
        insert caseObject;
        Account accountObject = new Account(Name = 'Test',Phone='1111111', Legal_Framework__c = 'Branch of a Foreign Company', Security_Clearance_Date__c = Date.today(), Security_Clearance_Status__c = 'NA', Business_Plan_Request_Date_Approval_Date__c = Date.today());
        insert accountObject;
        Contact contactObject = new Contact(LastName = 'Test',Email = 'test.mail@test.com', isSubmit__c = true, ParentCon__c = true, AccountId= accountObject.Id ,Type__c = 'Billing;Leasing Contact;Licensee Contact;Manager Incharge');
        insert contactObject;
        
        Business_Park__c businessParkObject = new Business_Park__c(Name = 'Test BusinessPark',
                                                                   Business_Park_Yardi__c = 'Test Yardi');
        insert businessParkObject;
        
        Opportunity opportunityObject = new Opportunity(Name = 'Test Opportunity',
                                                        AccountId = accountObject.Id,
                                                        Contact__c = contactObject.Id,
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
        
        return qliObject;
    }
    
    // Getting metadata object record
    @testVisible 
    static List<Registration_Request_Status_Setting__mdt> customMetadata { 
        get {
            if ( customMetadata == null )
                customMetadata = [SELECT Id,MasterLabel,DeveloperName,Convert_To_Trust_Account__c,Legal_Framework__c,
                                  Move_To_Next_Status__c,Status__c,Validate_Lease_Items__c
                                  FROM Registration_Request_Status_Setting__mdt]; 
            return customMetadata;
        } 
        set; 
    }
    
    //Method to test getWorkOrderDetails method
    @isTest
    public static void getWorkOrderDetailsTest(){
        WorkOrder woObj = createWorkOrderData();
        
        Test.startTest();
        WorkOrder returnedWoObj = WorkOrderToolbarHandler.getWorkOrderDetails(woObj.Id);
        Test.stopTest();
        
        System.assertEquals(returnedWoObj.Id, woObj.Id, 'Assert to check if inserted and returned WO is same');
    }
    
    //Method to test getQuoteProducts method
    @isTest
    public static void getQuoteProductsTest(){
        WorkOrder woObj = createWorkOrderData();
        Test.startTest();
        List<QuoteLineItem> qliList = WorkOrderToolbarHandler.getQuoteProducts(woObj);
        Test.stopTest();
        
        System.assertEquals(2, qliList.size());
    }
    
    //Method to test if Is_Registered_Address__c in QLI is true in updateRegisteredAddress method
    @isTest
    public static void updateRegisteredAddressTest(){
        QuoteLineItem qliObject = createQuoteLineItemData(); 
        Test.startTest();
        WorkOrderToolbarHandler.updateRegisteredAddress(qliObject.Id);
        Test.stopTest();
        qliObject = [SELECT Is_Registered_Address__c FROM QuoteLineItem WHERE Id = :qliObject.Id];
        System.assertEquals(qliObject.Is_Registered_Address__c, true);
    }
    
    //Method to test if size of List of Registration_Request_Status_Setting__mdt is greater than 0
    @isTest 
    public static void getStatusSettingsTest() {
        Test.startTest();
        List<Registration_Request_Status_Setting__mdt> registrationRequestList = WorkOrderToolbarHandler.getStatusSettings();
        Test.stopTest();
        
        System.assertEquals(registrationRequestList.size()>0, true);
    }
    
    //Method to test sendUpdateToDDATest method where convertToTrust=True, isMoveToNext=True, error message is NOT blank
    // and test if QuoteList is Empty by chnaging account id.
    @isTest 
    public static void sendUpdateToDDATest1() {
        Test.setMock(HttpCalloutMock.class, new DDAIntegrationServiceRequestMock()); //HttpCalloutMock
        Account accountObj = new Account(Name = 'Test Account');
        insert accountObj;
        WorkOrder woObj = createWorkOrderData();
        woObj.AccountId = accountObj.Id;
        update woObj;
        
        Test.startTest();
        String errorMessage = WorkOrderToolbarHandler.sendUpdateToDDA(woObj.Id, True, True);
        Test.stopTest(); 
        
        System.assert(errorMessage.contains('Please attach all mandatory Documents to Work Order.'));
    }
    
    //Method to test sendUpdateToDDATest method where convertToTrust=True and isMoveToNext=False
    @isTest 
    public static void sendUpdateToDDATest2() {
        Test.setMock(HttpCalloutMock.class, new DDAIntegrationServiceRequestMock()); //HttpCalloutMock
        WorkOrder woObj = createWorkOrderData();
        Test.startTest();
        String errorMessage = WorkOrderToolbarHandler.sendUpdateToDDA(woObj.Id, True, False);
        Test.stopTest(); 
        
        System.assert(errorMessage.contains('Please attach all mandatory Documents to Work Order.'));
    }
    
    //Method to test sendUpdateToDDATest method where convertToTrust=False and isMoveToNext=True
    @isTest 
    public static void sendUpdateToDDATest3() {
        Test.setMock(HttpCalloutMock.class, new DDAIntegrationServiceRequestMock()); //HttpCalloutMock
        WorkOrder woObj = createWorkOrderData();
        Test.startTest();
        String errorMessage = WorkOrderToolbarHandler.sendUpdateToDDA(woObj.Id, False, True);
        Test.stopTest(); 
        
        System.assert(errorMessage.contains('Please attach all mandatory Documents to Work Order.'));
    }
    
    //Method to test sendUpdateToDDATest method where convertToTrust=False and isMoveToNext=False
    @isTest 
    public static void sendUpdateToDDATest4() {
        Test.setMock(HttpCalloutMock.class, new DDAIntegrationServiceRequestMock()); //HttpCalloutMock
        
        Id workOrderId = DDAIntegrationServiceRequestMock.workOrderSetUp();
        
        Test.startTest();
        String errorMessage = WorkOrderToolbarHandler.sendUpdateToDDA(workOrderId, False, False);
        Test.stopTest(); 
        
        // System.assert(errorMessage.contains('Please attach all mandatory Documents to Work Order.'));
    }
    
    //Method to test sendUpdateToDDATest method where convertToTrust=True and isMoveToNext=True and error message is blank
    @isTest 
    public static void sendUpdateToDDATest5() {
        Test.setMock(HttpCalloutMock.class, new DDAIntegrationServiceRequestMock()); //HttpCalloutMock
        WorkOrder woObj = setUpWorkOrderData();
        
        Test.startTest();
        String errorMessage = WorkOrderToolbarHandler.sendUpdateToDDA(woObj.Id, True, True);
        Test.stopTest(); 
        
        System.assertEquals(woObj.IsMovedToNextStep__c, TRUE);
        System.assertEquals(woObj.Account_Type__c, 'Trust Account');
        System.assertEquals(String.isBlank(errorMessage), TRUE);
    }
    
    /*  //Method to test if list of Document__c where File_Attached__c = false
@isTest 
public static void isConvertToTrustPossibleTest1() {
WorkOrder woObj = createWorkOrderData();
Test.startTest();
String errorMessage = WorkOrderToolbarHandler.isConvertToTrustPossible(woObj);
Test.stopTest();

System.assert(errorMessage.contains('Please attach all mandatory Documents to Work Order.'));
}

//Method to test isConvertToTrustPossibleTest method - Test 2
@isTest 
public static void isConvertToTrustPossibleTest2() {
Account acc = new Account(Name = 'Test Account');
insert acc;
WorkOrder woObj = createWorkOrderData();
woObj.AccountId = acc.Id;
update woObj;
Test.startTest();
String errorMessage = WorkOrderToolbarHandler.isConvertToTrustPossible(woObj);
Test.stopTest();

System.assert(errorMessage.contains('Please add opportunity to related account.'));
}

//Method to test isMoveToNextPossibleTest method
@isTest 
public static void isMoveToNextPossibleTest() {
WorkOrder woObj = createWorkOrderData();
Test.startTest();
String errorMessage = WorkOrderToolbarHandler.isMoveToNextPossible(woObj);
Test.stopTest();

System.assert(errorMessage.contains('Please attach all mandatory Documents to Work Order.'));
}*/
    
}