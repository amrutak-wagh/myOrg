/**
 *  @description Test class for DOAUtils
 *
 *  2019-08-21  Shraddha N    First version
 *  
 */
@isTest
public class DOAUtilsTest {

    /*Common test data to be used in test class*/
    @testSetUp
    public static void setUp(){
        Id devRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Premise Lease Opportunity').getRecordTypeId();
        Test.setMock(HttpCalloutMock.class, new DDAIntegrationMock()); //HttpCalloutMock
        
        Profile profileObject = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
    	User uerObject = new User(Alias = 'standt', Email='systemadmin@testorg.com', 
                                  EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                  LocaleSidKey='en_US', ProfileId = profileObject.Id, 
                                  TimeZoneSidKey='America/Los_Angeles', UserName='systemadmin@testorg.com',
                                  ManagerId = UserInfo.getUserId());
        insert uerObject;
        

        Case caseObject = new Case(Status = 'New');
        insert caseObject;
        Account accountObject = new Account(Name = 'Test',Phone='1111111', Legal_Framework__c = 'Branch of a Foreign Company', Security_Clearance_Date__c = Date.today(), Security_Clearance_Status__c = 'NA', Business_Plan_Request_Date_Approval_Date__c = Date.today());
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
                                                        Type = 'New',
                                                        RecordTypeId = devRecordTypeId
                                                       );
        insert opportunityObject;
        
        Payment_Term__c paymentTermObject1 = new Payment_Term__c(Name = 'Test Payment Term',
                                                               Number_Of_Payments__c = 2);
        insert paymentTermObject1;
        
        Payment_Term__c paymentTermObject2 = new Payment_Term__c(Name = 'Test Payment Term 2',
                                                               Number_Of_Payments__c = 3);
        insert paymentTermObject2;
        
        DOA_Approver__c doaApproverObject = new DOA_Approver__c(Lease_Type__c = opportunityObject.Type,
                                                                Business_Park__c = businessParkObject.Id,
                                                                Opportunity_Type__c = 'Premise Lease Opportunity',                                                                Additional_Payment_From__c = 3,
                                                                Level_1_Approver__c = uerObject.Id,
                                                                Level_2_Approver__c = uerObject.Id,
                                                                Level_3_Approver__c = uerObject.Id,
                                                                Level_4_Approver__c = uerObject.Id,
                                                                Level_5_Approver__c = uerObject.Id,
                                                                Level_6_Approver__c = uerObject.Id,
                                                                Unit_Category__c = unitCategoryObject.Id,
                                                                Unit_Sub_Category__c = unitSubCategoryObject.Id);
        insert doaApproverObject;
        
        Quote quoteObject = new Quote(Name = 'Test Quote 1',
                                      Status= 'Draft',
                                      Proposed_Start_Date__c = System.today(),
                                      Proposed_End_Date__c = System.today().addDays(20),
                                      Type__c = 'Expansion',
                                      Payment_Terms__c = paymentTermObject1.Id,
                                      Pricebook2Id = Test.getStandardPricebookId(),
                                      Proposed_Grace_Period__c = 12,
                                      Proposed_Grace_Period_Months__c = 3,
                                      OpportunityId = opportunityObject.Id,
                                      Number_Of_Payments__c = 10,
                                      DOA_Approver__c = doaApproverObject.Id,
                                      Level_1_Approver__c = uerObject.Id,
                                      Level_2_Approver__c = uerObject.Id,
                                      Level_3_Approver__c = uerObject.Id,
                                      Level_4_Approver__c = uerObject.Id,
                                      Level_5_Approver__c = uerObject.Id,
                                      Level_6_Approver__c = uerObject.Id);
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
        
        TestDataFactory.getPriceRuleWithSchedules();
        
        List<Price_Schedule__c> priceScheduleList = [SELECT Id, Price_Rule__c FROM Price_Schedule__c WHERE Charge_Type__r.Name = 'Rent'];
        priceScheduleList[0].Payment_Term__c = paymentTermObject1.Id;
        update priceScheduleList;
        
        QuoteLineItem qliObject = new QuoteLineItem(QuoteId = quoteObject.Id,
                                                    Price_Schedule__c = priceScheduleList[0].Id,
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
      
    }
    
    //Method to test isApproverPopulationRequired method
    @isTest
    public static void isApproverPopulationRequiredTest1(){
        Map<Id,Quote> quoteIdVsQuoteOldMap = new Map<Id,Quote>();
        Map<Id,Quote> quoteIdVsQuoteNewMap = new Map<Id,Quote>();
        
        Payment_Term__c paymentTermObject = [SELECT Id, Number_Of_Payments__c FROM Payment_Term__c WHERE  Name = 'Test Payment Term 2'];
        List<Quote> quoteList = [SELECT Proposed_Grace_Period__c, Proposed_Grace_Period_Months__c, IsSyncing, Status,
                                  Payment_Terms__c, Proposed_Start_Date__c, Proposed_End_Date__c
                                  FROM Quote WHERE Name = 'Test Quote 1'];
        
        for(Quote quoteObject : quoteList){
            quoteIdVsQuoteOldMap.put(quoteObject.Id, quoteObject);
            Quote quoteObject2 = quoteObject.clone(true,true);
            quoteObject2.Proposed_Grace_Period__c = 11;
            quoteIdVsQuoteNewMap.put(quoteObject2.Id, quoteObject2);
        }
        
        Test.startTest();
        DOAUtils.isApproverPopulationRequired(quoteIdVsQuoteOldMap, quoteIdVsQuoteNewMap);
        Test.stopTest();
        
        for(Quote quoteObject : [SELECT Id, 
                                  		 Level_1_Approver__c,
                                 		 Level_2_Approver__c,
                                 		 Level_3_Approver__c,
                                         Level_4_Approver__c, 
                                         Level_5_Approver__c,
                                 		 Level_6_Approver__c
                                 FROM Quote
                                 WHERE ID IN: quoteList
                                 ]){
			System.assertEquals(quoteObject.Level_1_Approver__c, NULL);
            System.assertEquals(quoteObject.Level_2_Approver__c, NULL);
            System.assertEquals(quoteObject.Level_3_Approver__c, NULL);
        	System.assertEquals(quoteObject.Level_4_Approver__c, NULL);
            System.assertEquals(quoteObject.Level_5_Approver__c, NULL);
            System.assertEquals(quoteObject.Level_6_Approver__c, NULL);
    	}
         
    }
    
    //Method to test isApproverPopulationRequired method
    @isTest
    public static void isApproverPopulationRequiredTest2(){
        Map<Id,Quote> quoteIdVsQuoteOldMap = new Map<Id,Quote>();
        Map<Id,Quote> quoteIdVsQuoteNewMap = new Map<Id,Quote>();
        
        Payment_Term__c paymentTermObject = [SELECT Id, Number_Of_Payments__c FROM Payment_Term__c WHERE  Name = 'Test Payment Term 2'];
        List<Quote> quoteList = [SELECT Proposed_Grace_Period__c, Proposed_Grace_Period_Months__c, IsSyncing, Status,
                                  Payment_Terms__c, Proposed_Start_Date__c, Proposed_End_Date__c
                                  FROM Quote WHERE Name = 'Test Quote 1'];
        
        for(Quote quoteObject : quoteList){
            quoteIdVsQuoteOldMap.put(quoteObject.Id, quoteObject);
            Quote quoteObject2 = quoteObject.clone(true,true);
            quoteObject2.Proposed_Grace_Period_Months__c = 6;
            quoteIdVsQuoteNewMap.put(quoteObject2.Id, quoteObject2);
        }
        
        Test.startTest();
        DOAUtils.isApproverPopulationRequired(quoteIdVsQuoteOldMap, quoteIdVsQuoteNewMap);
        Test.stopTest();
        
        for(Quote quoteObject : [SELECT Id, 
                                  		 Level_1_Approver__c,
                                 		 Level_2_Approver__c,
                                 		 Level_3_Approver__c,
                                         Level_4_Approver__c, 
                                         Level_5_Approver__c,
                                 		 Level_6_Approver__c
                                 FROM Quote
                                 WHERE ID IN: quoteList
                                 ]){
			System.assertEquals(quoteObject.Level_1_Approver__c, NULL);
            System.assertEquals(quoteObject.Level_2_Approver__c, NULL);
            System.assertEquals(quoteObject.Level_3_Approver__c, NULL);
        	System.assertEquals(quoteObject.Level_4_Approver__c, NULL);
            System.assertEquals(quoteObject.Level_5_Approver__c, NULL);
            System.assertEquals(quoteObject.Level_6_Approver__c, NULL);  
    	}
    }
    
    //Method to test isApproverPopulationRequired method
    @isTest
    public static void isApproverPopulationRequiredTest3(){
        Map<Id,Quote> quoteIdVsQuoteOldMap = new Map<Id,Quote>();
        Map<Id,Quote> quoteIdVsQuoteNewMap = new Map<Id,Quote>();
        
        Payment_Term__c paymentTermObject = [SELECT Id, Number_Of_Payments__c FROM Payment_Term__c WHERE  Name = 'Test Payment Term 2'];
        List<Quote> quoteList = [SELECT Proposed_Grace_Period__c, Proposed_Grace_Period_Months__c, IsSyncing, Status,
                                  Payment_Terms__c, Proposed_Start_Date__c, Proposed_End_Date__c
                                  FROM Quote WHERE Name = 'Test Quote 1'];
        
        for(Quote quoteObject : quoteList){
            quoteIdVsQuoteOldMap.put(quoteObject.Id, quoteObject);
            Quote quoteObject2 = quoteObject.clone(true,true);
            quoteObject2.Payment_Terms__c = paymentTermObject.Id;
            quoteIdVsQuoteNewMap.put(quoteObject2.Id, quoteObject2);
        }
        
        Test.startTest();
        DOAUtils.isApproverPopulationRequired(quoteIdVsQuoteOldMap, quoteIdVsQuoteNewMap);
        Test.stopTest();
        
        for(Quote quoteObject : [SELECT Id, 
                                  		 Level_1_Approver__c,
                                 		 Level_2_Approver__c,
                                 		 Level_3_Approver__c,
                                         Level_4_Approver__c, 
                                         Level_5_Approver__c,
                                 		 Level_6_Approver__c
                                 FROM Quote
                                 WHERE ID IN: quoteList
                                 ]){
			System.assertEquals(quoteObject.Level_1_Approver__c, NULL);
            System.assertEquals(quoteObject.Level_2_Approver__c, NULL);
            System.assertEquals(quoteObject.Level_3_Approver__c, NULL);
        	System.assertEquals(quoteObject.Level_4_Approver__c, NULL);
            System.assertEquals(quoteObject.Level_5_Approver__c, NULL);
            System.assertEquals(quoteObject.Level_6_Approver__c, NULL);
    	}
    }
    
  
    //Method to test updateDoAproversQli method
    @isTest
    public static void updateDoAproversQliTest(){
        map<Id,QuoteLineItem> qliMap = new map<Id,QuoteLineItem>();
        List<QuoteLineItem> lineItems = new List<QuoteLineItem>();
        Quote quoteObject = [SELECT Proposed_Grace_Period__c, Proposed_Grace_Period_Months__c, IsSyncing, Status,
                                  Payment_Terms__c, Proposed_Start_Date__c, Proposed_End_Date__c
                                  FROM Quote WHERE Name = 'Test Quote 1' LIMIT 1];
        
        List<QuoteLineItem> qliList = [SELECT Offer_Price__c, Best_Rate__c FROM QuoteLineItem WHERE QuoteId = :quoteObject.Id];
        
        for(QuoteLineItem qliObj : qliList){
            qliMap.put(qliObj.Id, qliObj);
            qliObj.Offer_Price__c = 50;
            lineItems.add(qliObj);
        }
        update lineItems;
        
        Test.startTest();
        DOAUtils.updateDoAproversQli(lineItems, qliMap);
        Test.stopTest();
        
        for(Quote quoteObj : [SELECT Id, 
                                  		 Level_1_Approver__c,
                                 		 Level_2_Approver__c,
                                 		 Level_3_Approver__c,
                                         Level_4_Approver__c, 
                                         Level_5_Approver__c,
                                 		 Level_6_Approver__c
                                 FROM Quote
                                 WHERE ID =: quoteObject.Id
                                 ]){
			System.assertEquals(quoteObj.Level_1_Approver__c, NULL);
            System.assertEquals(quoteObj.Level_2_Approver__c, NULL);
            System.assertEquals(quoteObj.Level_3_Approver__c, NULL);
        	System.assertEquals(quoteObj.Level_4_Approver__c, NULL);
            System.assertEquals(quoteObj.Level_5_Approver__c, NULL);
            System.assertEquals(quoteObj.Level_6_Approver__c, NULL);
    	}
    }
    
    //Method to test populateApprover method
    @isTest 
    public static void populateApproverTest(){
        Set<Id> quoteIdSet = new Set<Id>();
        
        Opportunity opportunityObject = [SELECT Type FROM Opportunity WHERE Name = 'Test Opportunity' LIMIT 1];
        Unit_Category__c unitCategoryObject = [SELECT Id FROM Unit_Category__c WHERE Name = 'Office' LIMIT 1];
        Unit_Sub_Category__c unitSubCategoryObject = [SELECT Id FROM Unit_Sub_Category__c WHERE Name = 'Standard Office' LIMIT 1];
        Business_Park__c businessParkObject = [SELECT Id FROM Business_Park__c WHERE Name = 'Test BusinessPark' LIMIT 1];
        
        DOA_Approver__c doaApproverObject = new DOA_Approver__c(Lease_Type__c = opportunityObject.Type,
                                                                Business_Park__c = businessParkObject.Id,
                                                                Opportunity_Type__c = 'Premise Lease Opportunity',                                                                Additional_Payment_From__c = 3,
                                                                Unit_Category__c = unitCategoryObject.Id,
                                                                Unit_Sub_Category__c = unitSubCategoryObject.Id);
        insert doaApproverObject;
        doaApproverObject.Additional_Payment_From__c = NULL;
        update doaApproverObject;
       
        List<Quote> quoteList = [SELECT Proposed_Grace_Period__c, Proposed_Grace_Period_Months__c, IsSyncing, Status,
                                  Payment_Terms__c, Proposed_Start_Date__c, Proposed_End_Date__c, DOA_Approver__c
                                  FROM Quote WHERE Name = 'Test Quote 1'];
        
        for(Quote quoteObject : quoteList){
            quoteObject.DOA_Approver__c = doaApproverObject.Id;
           
            quoteIdSet.add(quoteObject.Id);
        }
        
        Test.startTest();
        DOAUtils.populateApprover(quoteIdSet);
        Test.stopTest();
        
        for(Quote quoteObj : [SELECT Id, 
                                  		 Level_1_Approver__c,
                                 		 Level_2_Approver__c,
                                 		 Level_3_Approver__c,
                                         Level_4_Approver__c, 
                                         Level_5_Approver__c,
                                 		 Level_6_Approver__c
                                 FROM Quote
                                 WHERE ID IN: quoteList
                                 ]){
			System.assertEquals(quoteObj.Level_1_Approver__c, NULL);
            System.assertEquals(quoteObj.Level_2_Approver__c, NULL);
            System.assertEquals(quoteObj.Level_3_Approver__c, NULL);
        	System.assertEquals(quoteObj.Level_4_Approver__c, NULL);
            System.assertEquals(quoteObj.Level_5_Approver__c, NULL);
            System.assertEquals(quoteObj.Level_6_Approver__c, NULL);
    	}
        
    }
    
    //Method to test resetApprover method
    @isTest
    public static void resetApproverTest(){
        Map<Id,Quote> quoteIdVsQuoteMap = new Map<Id,Quote>();
        List<Quote> oldQuoteList = new  List<Quote>();
        List<Quote> newQuoteList = new List<Quote>();
        Quote quoteObject = [SELECT Proposed_Grace_Period__c, Proposed_Grace_Period_Months__c, IsSyncing, Status,
                             Payment_Terms__c, Proposed_Start_Date__c, Proposed_End_Date__c
                             FROM Quote WHERE Name = 'Test Quote 1'];
        
        newQuoteList.add(quoteObject);
        for(Quote quoteObj : newQuoteList){
            Quote quoteObject2 = new Quote();
            quoteObject2 = quoteObj.clone(true,true);
            quoteObject2.status = 'Rejected';
            quoteIdVsQuoteMap.put(quoteObject2.Id, quoteObject2);
        }
        
        Test.startTest();
        DOAUtils.resetApprover(newQuoteList, quoteIdVsQuoteMap);
        Test.stopTest();
        
         for(Quote quoteObj : [SELECT Id, 
                                  		 Level_1_Approver__c,
                                 		 Level_2_Approver__c,
                                 		 Level_3_Approver__c,
                                         Level_4_Approver__c, 
                                         Level_5_Approver__c,
                                 		 Level_6_Approver__c,
                               			 DOA_Approver__c
                                 FROM Quote
                                 WHERE ID IN: newQuoteList
                                 ]){
			System.assertEquals(quoteObj.Level_1_Approver__c, NULL);
            System.assertEquals(quoteObj.Level_2_Approver__c, NULL);
            System.assertEquals(quoteObj.Level_3_Approver__c, NULL);
        	System.assertEquals(quoteObj.Level_4_Approver__c, NULL);
            System.assertEquals(quoteObj.Level_5_Approver__c, NULL);
            System.assertEquals(quoteObj.Level_6_Approver__c, NULL);
            System.assertEquals(quoteObj.DOA_Approver__c, NULL);
    	}
        
    }
    
    //Method to test restrictDeletionUnderApprovalLineItems method
    @isTest
    public static void restrictDeletionUnderApprovalLineItemsTest(){
        Quote quoteObject = [SELECT Proposed_Grace_Period__c, Proposed_Grace_Period_Months__c, IsSyncing, Status,
                                  Payment_Terms__c, Proposed_Start_Date__c, Proposed_End_Date__c
                                  FROM Quote WHERE Name = 'Test Quote 1' LIMIT 1];
        
        quoteObject.Status = 'Under Approval';
        update quoteObject;
        
        List<QuoteLineItem> qliList = [SELECT QuoteId,Offer_Price__c, Best_Rate__c FROM QuoteLineItem WHERE QuoteId = :quoteObject.Id];
       
        Test.startTest();
        DOAUtils.restrictDeletionUnderApprovalLineItems(qliList);
        Test.stopTest();
        
        System.assertNotEquals(null, qliList);
        System.assertEquals(quoteObject.Id, qliList[0].QuoteId);
    }
    
    //Method to test restrictUpdateUnderApproval method
    @isTest
    public static void restrictUpdateUnderApprovalTest(){
        Map<Id,QuoteLineItem> qliIdVsQLINewMap = new Map<Id,QuoteLineItem>();
        Map<Id, QuoteLineItem> qliIdVsQLIOldMap = new Map<Id,QuoteLineItem>();
        
        Quote quoteObject = [SELECT Proposed_Grace_Period__c, Proposed_Grace_Period_Months__c, IsSyncing, Status,
                                  Payment_Terms__c, Proposed_Start_Date__c, Proposed_End_Date__c
                                  FROM Quote WHERE Name = 'Test Quote 1' LIMIT 1];
        
        List<QuoteLineItem> qliList = [SELECT QuoteId, IsDeleted, LineNumber, CurrencyIsoCode, CreatedDate, CreatedById, LastModifiedDate, 
                                       Offer_Price__c, LastModifiedById, SystemModstamp, LastViewedDate, LastReferencedDate,
                                       PricebookEntryId, OpportunityLineItemId, Quantity, UnitPrice, Discount, Description, ServiceDate,
                                       Product2Id, SortOrder, ListPrice, Subtotal, TotalPrice, Start_Date__c, End_Date__c, Price_Schedule__c,
                                       Charge_Code__c, Quote_Revision__c, Area__c, Transactional_Unit__c, Default_Grace_Period__c, Default_Grace_Period_Format__c,
                                       Default_Grace_Period_Mechanism__c, Proration_Method__c, Yardi_Integration_Status__c, Yardi_Integration_Error_Message__c,
                                       Product_Code__c, Parent_Quote_Line_Item__c, Type__c, No_of_Beds__c, Transaction_Unit__c, List_Price_Rate__c,
                                       Area_ft__c,Additional_GP_Discount_Amount__c, Asset_Class__c, Best_Rate__c, Best_Rate_for_Proposed_GP__c,
                                       PriceSch_ChargeType__c, Default_GP_Discount_Amount__c, Default_Grace_Period_Months__c,
                                       DOA_Discount2__c, DOA_Discount_Amount__c, Grace_Period_Discount__c, Grace_Period_Value__c, Is_Registered_Address__c,
                                       Negative_GP_Discount_Amount__c, Offer_Best_Discount_Amount__c, Grace_Period__c, Grace_Period_Format__c, Grace_Period_Mechanism__c,
                                       Offered_Price_Rate__c, Payment_Term_Yardi_Code__c, Product_Active__c, Related_Grace_Period__c, Revision_Number__c, Sub_Category__c,
                                       Total_Best_Rate__c, TOTAL_Discount__c, Total_List_Price__c, Total_Offered_Price__c, Transaction_Type__c, Unit_Name__c, 
                                       Upselling_Discount_Amount__c, Yardi_Charge_Code__c, Yardi_Unit_ID__c, Yardi_Code__c, Charge_Type__c
                                       FROM QuoteLineItem WHERE QuoteId = :quoteObject.Id];
       	
        quoteObject.Status = 'Under Approval';
        update quoteObject;
        Boolean error = false;
        
        Test.startTest();
        try {
            update qliList;
        } 
        catch(Exception ex) {
            error = true;
        }
        
        Test.stopTest();
        
        System.assertEquals(error, false);
    }
    
    //Method to test updatDefaultGracePeriodForQLI method
    @isTest
    public static void updatDefaultGracePeriodForQLITest(){
        List<QuoteLineItem> updatedQLIList = new List<QuoteLineItem>();
        Set<Id> quoteIdSet = new Set<Id>();
        
        List<Quote> quoteList = [SELECT Proposed_Grace_Period__c, Proposed_Grace_Period_Months__c, IsSyncing, Status,
                                  Payment_Terms__c, Proposed_Start_Date__c, Proposed_End_Date__c
                                  FROM Quote WHERE Name = 'Test Quote 1'];
        List<QuoteLineItem> qliList = [SELECT QuoteId, Type__c, Offer_Price__c, Best_Rate__c FROM QuoteLineItem WHERE QuoteId = :quoteList[0].Id];

        for(QuoteLineItem qliObj : qliList){
            qliObj.Type__c = 'Normal';
            //updatedQLIList.add(qliObj);
        }
        update qliList;
        
        for(QuoteLineItem qliObj : qliList){
            quoteIdSet.add(qliObj.QuoteId);
        }
        
        Test.startTest();
        DOAUtils.updatDefaultGracePeriodForQLI(quoteIdSet);
        Test.stopTest();
        
        List<QuoteLineItem> qliUpdatedList = [SELECT QuoteId, Default_GP_Discount_Amount__c, Additional_GP_Discount_Amount__c, Best_Rate__c FROM QuoteLineItem WHERE QuoteId = :quoteList[0].Id];

        for(QuoteLineItem lineObj : qliUpdatedList) {
            System.assertEquals(lineObj.Default_GP_Discount_Amount__c, 0);
            System.assertEquals(lineObj.Additional_GP_Discount_Amount__c, 0);
        }
    }
}