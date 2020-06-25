@isTest
public class LeaseMergerBatchTest {
	@testsetup 
    public static void createData(){
        TestDataFactory.getPriceRuleWithSchedules();
        
        
        Business_Park__c bsp = new Business_Park__c(Name = 'Test',Business_Park_Yardi__c = 'Test');
        insert bsp;
        
        Account acc = new Account(Name='Test Account' , License_Business_Park__c = bsp.Id);
        insert acc;
        
        Contact conObj = new Contact(LastName = 'Test Contact', AccountId = acc.Id);
        insert conObj;
        
        Unit_Category__c uc1 = new Unit_Category__c(Name = 'Office');
        insert uc1;

        Unit_Sub_Category__c usc1 = new Unit_Sub_Category__c(Name = 'Standard Office',Unit_Category__c = uc1.Id);
        insert usc1;
        
        Plot__c plot2 = new Plot__c(Name = 'testPlot2',Plot_Code_YARDI__c = 'pricingEngineTestPlot2',Area_sqft__c = 1100.0,
            					   Business_Park__c = bsp.Id,Plot_Name_YARDI__c = 'pricingEngineTestPlotName123',
            					   Type__c = 'type',Status__c = 'Available - Sale',Sector_Name__c = 'sectorName1');
        insert plot2;
        
        Building__c build1 = new Building__c(Plot__c = plot2.Id,Name = 'Test Build 1' , Business_Park__c = bsp.Id,
                                             Ownership_Type__c = 'TECOM Owned', Development_Status__c = 'Under Development',
                                             Property_Code_YARDI__c ='d3_cb',Property__c ='Parking', Building_Code__c = 'B-P1-1');
        insert build1;
        
        Unit__c un = new Unit__c(Name  ='Test Unit',Area_ft__c = 910,Building__c = build1.Id, Unit_Sub_Category__c = usc1.Id,
                                 Unit_Code_YARDI__c = 'B106',Transactional_Unit__c ='Sqft', Floor_Number__c = 'Fifth Floor', Floor_Type__c = '05');
        insert un;
        
        
        Opportunity parentOpp = new Opportunity(Name = 'Test Opp Parent' , AccountId = acc.Id , StageName = 'New',Type ='New',Lease_End_Date__c = Date.today().addDays(120),
                                         Business_Park__c = bsp.Id , CloseDate = Date.newInstance(2019,7,2),Building_Name__c = 'test',
                                         CurrencyIsoCode = 'AED', Contact__c = conObj.Id,Lease_Start_Date__c = Date.today());
        insert parentOpp;
        
        Opportunity childOpp1 = new Opportunity(Name = 'Test Opp Child1' , AccountId = acc.Id , StageName = 'New',Type ='New',Lease_End_Date__c = Date.today().addDays(120),
                                         Business_Park__c = bsp.Id , CloseDate = Date.newInstance(2019,7,2),Building_Name__c = 'test',Parent_Opportunity__c = parentOpp.Id,
                                         CurrencyIsoCode = 'AED', Contact__c = conObj.Id,Lease_Start_Date__c = Date.today());
        
        insert childOpp1;
        
        Opportunity childOpp2 = new Opportunity(Name = 'Test Opp Child2' , AccountId = acc.Id , StageName = 'New',Type ='New',Lease_End_Date__c = Date.today().addDays(120),
                                         Business_Park__c = bsp.Id , CloseDate = Date.newInstance(2019,7,2),Building_Name__c = 'test1',Parent_Opportunity__c = parentOpp.Id,
                                        CurrencyIsoCode = 'AED', Contact__c = conObj.Id,Lease_Start_Date__c = Date.today());
        
        insert childOpp2;
        
        /*Opportunity childOpp3 = new Opportunity(Name = 'Test Opp Child2' , AccountId = acc.Id , StageName = 'New',Type ='New',Lease_End_Date__c = Date.today().addDays(120),
                                         Business_Park__c = bsp.Id , CloseDate = Date.newInstance(2019,7,2),Building_Name__c = 'test1',Parent_Opportunity__c = parentOpp.Id,
                                         Sub_Type__c = 'Expansion',CurrencyIsoCode = 'AED', Contact__c = conObj.Id,Lease_Start_Date__c = Date.today());
        
        insert childOpp3;
        
        Opportunity childOpp4 = new Opportunity(Name = 'Test Opp Child2' , AccountId = acc.Id , StageName = 'New',Type ='New',Lease_End_Date__c = Date.today().addDays(120),
                                         Business_Park__c = bsp.Id , CloseDate = Date.newInstance(2019,7,2),Building_Name__c = 'test2',
                                         Sub_Type__c = 'Expansion',CurrencyIsoCode = 'AED', Contact__c = conObj.Id,Lease_Start_Date__c = Date.today());
        
        insert childOpp4;*/
        
        Quote parentOppQuote = new Quote(Name = 'Test Quote',OpportunityId = parentOpp.Id,CCL_Sign_Date__c = Date.today(),
                            Status = 'Draft',Type__c = 'Renewal', Proposed_Start_Date__c = Date.today(),
                            Proposed_End_Date__c = Date.today().addDays(90),Lease_Start_Date__c = Date.today(),
                            Pricebook2Id = Test.getStandardPricebookId(),Lease_End_Date__c = Date.today().addDays(90));
        insert parentOppQuote;
        
        Quote childOpp1Quote = new Quote(Name = 'Test Quote',OpportunityId = childOpp1.Id,CCL_Sign_Date__c = Date.today(),
                            Status = 'Draft',Type__c = 'Renewal', Proposed_Start_Date__c = Date.today(),
                            Proposed_End_Date__c = Date.today().addDays(90),Lease_Start_Date__c = Date.today(),
                            Pricebook2Id = Test.getStandardPricebookId(),Lease_End_Date__c = Date.today().addDays(90));
        insert childOpp1Quote;
        
        Quote childOpp2Quote = new Quote(Name = 'Test Quote',OpportunityId = childOpp2.Id,CCL_Sign_Date__c = Date.today(),
                            Status = 'Draft',Type__c = 'Renewal', Proposed_Start_Date__c = Date.today(),
                            Proposed_End_Date__c = Date.today().addDays(90),Lease_Start_Date__c = Date.today(),
                            Pricebook2Id = Test.getStandardPricebookId(),Lease_End_Date__c = Date.today().addDays(90));
        insert childOpp2Quote;
        
        /*Quote childOpp3Quote = new Quote(Name = 'Test Quote',OpportunityId = childOpp3.Id,CCL_Sign_Date__c = Date.today(),
                            Status = 'Draft',Type__c = 'Renewal', Proposed_Start_Date__c = Date.today(),
                            Proposed_End_Date__c = Date.today().addDays(90),Lease_Start_Date__c = Date.today(),
                            Pricebook2Id = Test.getStandardPricebookId(),Lease_End_Date__c = Date.today().addDays(90));
        //insert childOpp3Quote;*/
        
        /*Quote childOpp4Quote = new Quote(Name = 'Test Quote',OpportunityId = childOpp4.Id,CCL_Sign_Date__c = Date.today(),
                            Status = 'Draft',Type__c = 'Renewal', Proposed_Start_Date__c = Date.today(),
                            Proposed_End_Date__c = Date.today().addDays(90),Lease_Start_Date__c = Date.today(),
                            Pricebook2Id = Test.getStandardPricebookId(),Lease_End_Date__c = Date.today().addDays(90));*/
        //insert childOpp4Quote;
        
        Product2 prod = new Product2(Name = 'testProd',isActive = true,Unique_Key__c = 'pricingEngineTestProd',Unit__c = un.Id );
        insert prod;
        
        PricebookEntry pbe = new PricebookEntry(isActive = true,UnitPrice = 100,Product2Id = prod.Id,
                                                Pricebook2Id = Test.getStandardPricebookId(),CurrencyIsoCode = 'AED');
        insert pbe;
        
        //childOpp3.StageName = 'Active';
        //update childOpp3;
        
        //childOpp4.SyncedQuoteId = childOpp4Quote.Id;
        //childOpp4.StageName = 'Active';
        //update childOpp4;
    }
    
    public static testmethod void testMethod1(){
        List<Price_Schedule__c> priceScheduleList = [SELECT Id, Price_Rule__c FROM Price_Schedule__c WHERE Charge_Type__r.Name = 'Rent'];
        List<Quote> parentOppQuote = [Select Id FROM Quote];
        PriceBookEntry pbe = [SELECT Id FROM PriceBookEntry LIMIT 1];
        Product2 prod = [SELECT Id FROM Product2 LIMIT 1];
        List<Opportunity> oppList = [SELECT Id FROM Opportunity];
        /*QuoteLineItem sqftLineItemParentOpp = new QuoteLineItem(
                QuoteId = parentOppQuote[0].Id,
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
                Product2Id = prod.Id,
            	Price_Schedule__c = priceScheduleList[0].Id
        );*/
        //insert sqftLineItemParentOpp;
        oppList[0].SyncedQuoteId = parentOppQuote[0].Id;
        oppList[0].StageName = 'Active';
        update oppList[0];
        
        QuoteLineItem sqftLineItem1 = new QuoteLineItem(
                QuoteId = parentOppQuote[1].Id,
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
                Product2Id = prod.Id,
            	Price_Schedule__c = priceScheduleList[0].Id
        );
        insert sqftLineItem1;
        oppList[1].SyncedQuoteId = parentOppQuote[1].Id;
        oppList[1].StageName = 'Active';
        update oppList[1];
        
        
        
        /*QuoteLineItem sqftLineItem2 = new QuoteLineItem(
                QuoteId = parentOppQuote[3].Id,
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
                Product2Id = prod.Id,
            	Price_Schedule__c = priceScheduleList[0].Id
        );
        insert sqftLineItem2;
        oppList[2].SyncedQuoteId = parentOppQuote[2].Id;
        oppList[2].StageName = 'Active';
        update oppList[2];*/
        Test.startTest();
        Database.executeBatch(new LeaseMergerBatch());
        Test.stopTest();
        System.assertEquals(1, [Select Id from Opportunity WHERE Type = 'Renewal'].size());
    }
    
    public static testmethod void testMethod2(){
        List<Opportunity> oppList = [SELECT Lease_End_Date__c FROM Opportunity];
        for(Opportunity opp : oppList){
            opp.Lease_End_Date__c = opp.Lease_End_Date__c.addDays(1);
        }
        update oppList;
        Test.startTest();
        Database.executeBatch(new LeaseMergerBatch(),1);
        Test.stopTest();
        System.assertEquals(0, [Select Id from Opportunity WHERE Type = 'Renewal'].size());
    }
}