/**
 *  @description Test class for TerminationProcessController
 *
 *  2019-09-05     First version
 *  
 */

@isTest
public class TerminationProcessContractControllerTest {
	/*Common test data to be used in test class*/
    @testSetup
    public  static void setUp(){
        Account accountObject = new Account(Name = 'Test',Phone='1111111', Legal_Framework__c = 'Branch of a Foreign Company', Security_Clearance_Date__c = Date.today(), Security_Clearance_Status__c = 'NA', Business_Plan_Request_Date_Approval_Date__c = Date.today());
        insert accountObject;
        Contact contactObject = new Contact(LastName = 'Test',Email = 'vaibhavi.kulkarni@weare4c.com', isSubmit__c = true, ParentCon__c = true, AccountId= accountObject.Id ,Type__c = 'Billing;Leasing Contact;Licensee Contact;Manager Incharge');
        insert contactObject;
       
        Business_Park__c businessParkObject = new Business_Park__c(Name = 'Test BusinessPark',
                                                                                Business_Park_Yardi__c = 'Test Yardi');
        insert businessParkObject;
        
        Opportunity opportunityObject = new Opportunity(Name = 'Test Opportunity 1',
                                                        AccountId = accountObject.Id,
                                                        Contact__c = contactObject.Id,
                                                        Business_Park__c = businessParkObject.Id,
                                                        StageName = 'New',
                                                        CloseDate = System.today(),
                                                        Type = 'New'
                                                       );
        insert opportunityObject;
        Opportunity opportunityObject2 = new Opportunity(Name = 'Test Opportunity 2',
                                                        AccountId = accountObject.Id,
                                                        Contact__c = contactObject.Id,
                                                        Business_Park__c = businessParkObject.Id,
                                                        StageName = 'New',
                                                        CloseDate = System.today(),
                                                        Type = 'New'
                                                       );
        insert opportunityObject2;
         Quote quoteObject = new Quote(Name = 'Test Quote 1',
                                      Status= 'Draft',
                                      Proposed_Start_Date__c = System.today(),
                                      Proposed_End_Date__c = System.today().addDays(2),
                                      Type__c = 'Expansion',
                                      Proposed_Grace_Period__c = 12,
                                      Proposed_Grace_Period_Months__c = 3,
                                      OpportunityId = opportunityObject.Id,
                                      Number_Of_Payments__c = 10
                                     );
        insert quoteObject;
        
        Contract contractObject = New Contract(AccountId=accountObject.Id,
                                               Contact__c=contactObject.Id,
                                               Opportunity__c = opportunityObject.Id,
                                               Quote__c=quoteObject.Id,
                                               CurrencyIsoCode='',
                                               Status='Draft',
                                               StartDate=System.today(),
                                               ContractTerm=4);
        insert contractObject;
        
        
    }
    
    //Method to test getContractDetailApcx method
    @isTest
    public static void getContractDetailApcxTest(){
        Opportunity opportunityObject1 = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity 1' LIMIT 1];
        List<Contract> contractList = [SELECT Id FROM Contract LIMIT 1];
        //system.debug('contractList========='+contractList);
        Test.startTest();
        Id i = TerminationProcessContractController.getContractDetailApcx(contractList[0].Id);
        Test.stopTest();
   		system.assertEquals(opportunityObject1.Id, i);
        //system.assertNotEquals(null, opportunityObject2.Id);
    }
    
    @isTest
    public static void getContractDetailApcxTestNegative(){
        Opportunity opportunityObject1 = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity 1' LIMIT 1];
        //List<Contract> contractList = [SELECT Id FROM Contract LIMIT 1];
        //system.debug('contractList========='+contractList);
        Test.startTest();
        Id i = TerminationProcessContractController.getContractDetailApcx(null);
        Test.stopTest();
   		system.assertEquals(null, i);
        //system.assertNotEquals(null, opportunityObject2.Id);
    }
}