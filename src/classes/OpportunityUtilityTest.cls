/**
 *  @description Test class for OpportunityUtility
 *
 *  2019-08-29  Anshul G    First version
 *  
 */
@isTest
public class OpportunityUtilityTest {
    //Common test data to be used in test class
    @testSetup
    public static void testDataSetUp(){
        Account accountObject = new Account(Name = 'Test Account 1',Phone='1111111', Legal_Framework__c = 'Branch of a Foreign Company', Security_Clearance_Date__c = Date.today(), Security_Clearance_Status__c = 'NA', Business_Plan_Request_Date_Approval_Date__c = Date.today());
        insert accountObject;
        Account accountObject2 = new Account(Name = 'Test Account 2',Phone='1111111', Legal_Framework__c = 'Branch of a Foreign Company', Security_Clearance_Date__c = Date.today(), Security_Clearance_Status__c = 'NA', Business_Plan_Request_Date_Approval_Date__c = Date.today());
        insert accountObject2;
        Account accountObject3 = new Account(Name = 'Test Account 3',Phone='1111111', Legal_Framework__c = 'Branch of a Foreign Company', Security_Clearance_Date__c = Date.today(), Security_Clearance_Status__c = 'NA', Business_Plan_Request_Date_Approval_Date__c = Date.today());
        insert accountObject3;
        
        Contact contactObject = new Contact(LastName = 'Test Contact 1',Email = 'test.mail@test.com', isSubmit__c = true, ParentCon__c = true, AccountId= accountObject.id ,Type__c = 'Manager Incharge');
        insert contactObject;
        Contact contactObject2 = new Contact(LastName = 'Test Contact 2',Email = 'test.mail1@test.com', isSubmit__c = true, ParentCon__c = true, AccountId= accountObject2.id ,Type__c = 'Billing',Is_Billing_Contact__c = TRUE);
        insert contactObject2;
        
        Business_Park__c businessParkObject = new Business_Park__c(Name = 'Test BusinessPark',
                                                                   Business_Park_Yardi__c = 'Test Yardi');
        insert businessParkObject;
        
        Opportunity opportunityObject1 = new Opportunity(Name = 'Test Opportunity',
                                                         AccountId = accountObject.Id,
                                                         Contact__c = contactObject.Id,
                                                         Business_Park__c = businessParkObject.Id,
                                                         StageName = 'New',
                                                         CloseDate = System.today()
                                                         
                                                        );
        insert opportunityObject1;
        
        Quote quoteObject1 = new Quote(Name = 'Test Quote',
                                       Proposed_Start_Date__c = System.today(),
                                       Proposed_End_Date__c = System.today().addDays(2),
                                       Pricebook2Id = Test.getStandardPricebookId(),
                                       OpportunityId = opportunityObject1.Id);
        insert quoteObject1;
        
        Opportunity opportunityObject2 = new Opportunity(Name = 'Test Opportunity 2',
                                                         AccountId = accountObject.Id,
                                                         Contact__c = contactObject.Id,
                                                         Business_Park__c = businessParkObject.Id,
                                                         StageName = 'New',
                                                         CloseDate = System.today()
                                                        );
        insert opportunityObject2;
        
        Quote quoteObject2 = new Quote(Name = 'Test Quote',
                                       Proposed_Start_Date__c = System.today(),
                                       Proposed_End_Date__c = System.today().addDays(2),
                                       Pricebook2Id = Test.getStandardPricebookId(),
                                       OpportunityId = opportunityObject2.Id);
        insert quoteObject2;
        
        opportunityObject2.StageName = 'Negotiation';
        opportunityObject2.Type = 'Renewal';
        update opportunityObject2;
        
    }
    
    //Method to test validateOpportunityStatusChange method - Positive Testing
    @isTest
    public static void validateOpportunityStatusChangePositiveTest(){
        String errorMessage = '';  
        Test.startTest();
        Opportunity opportunityObject1 = [SELECT Id, Type, StageName FROM Opportunity WHERE Name = 'Test Opportunity' LIMIT 1];
        Case caseObject = new Case(Status = 'Finance Approved', Opportunity__c = opportunityObject1.Id);
        insert caseObject;   
        
        opportunityObject1.StageName = 'Negotiation';
        opportunityObject1.Type = 'Renewal';
        try{
             update opportunityObject1;
        } catch(Exception e){
            errorMessage = e.getMessage();
        }
        Test.stopTest();
       System.assertEquals(errorMessage.contains('Stage of this opportunity can not be changed as it have In Progess Case Termination') , TRUE);
    }
    
    //Method to test validateOpportunityStatusChange method- Negative Testing
    @isTest
    public static void validateOpportunityStatusChangeNegativeTest(){
        String errorMessage = '';  
        Test.startTest();        
        Opportunity opportunityObject1 = [SELECT Id, Type, StageName FROM Opportunity WHERE Name = 'Test Opportunity' LIMIT 1];
        Case caseObject = new Case(Status = 'New', Opportunity__c = opportunityObject1.Id);
        insert caseObject;   
        
        opportunityObject1.StageName = 'Negotiation';
        opportunityObject1.Type = 'Renewal';
        
       try{
             update opportunityObject1;
        } catch(Exception e){
            errorMessage = e.getMessage();
        }
        Test.stopTest();
        
       System.assertEquals(errorMessage.contains('Stage of this opportunity can not be changed as it have In Progess Case Termination') , FALSE);
       
    }
    
    //Method to test checkContactRoleAgainstAccount method- Positive Testing
    @isTest
    public static void checkContactRoleAgainstAccountPositiveTest(){
        String errorMessage = '';        
        Account accountObject = [SELECT Id FROM Account WHERE Name = 'Test Account 1' LIMIT 1];
        Contact contactObject = [SELECT Id FROM Contact WHERE LastName = 'Test Contact 2' LIMIT 1];
        Opportunity opportunityObject = [SELECT Id, Type, StageName, AccountId, Contact__c FROM Opportunity WHERE Name = 'Test Opportunity 2' LIMIT 1];
		
		Test.startTest();        
        opportunityObject.AccountId = accountObject.Id;
        opportunityObject.Contact__c = contactObject.Id;
        try{
            update opportunityObject;
        }  catch(Exception e){
            errorMessage = e.getMessage();
        }
        Test.stopTest();
        
        System.assertEquals(errorMessage.contains(System.Label.Account_Related_Contact_Role), TRUE);
    }
    
    //Method to test checkContactRoleAgainstAccount method- Negative Testing
    @isTest
    public static void checkContactRoleAgainstAccountNegativeTest(){
        String errorMessage = '';  
        Account accountObject = [SELECT Id FROM Account WHERE Name = 'Test Account 2' LIMIT 1];
        Contact contactObject = [SELECT Id FROM Contact WHERE LastName = 'Test Contact 2' LIMIT 1];
          
        Opportunity opportunityObject = [SELECT Id, Type, StageName, AccountId, Contact__c FROM Opportunity WHERE Name = 'Test Opportunity' LIMIT 1];
        
        Test.startTest();
        opportunityObject.AccountId = accountObject.Id;
        opportunityObject.Contact__c = contactObject.Id;
      
        try{
            update opportunityObject;
        }  catch(Exception e){
            errorMessage = e.getMessage();
        }
        Test.stopTest();
        
        System.assertEquals(errorMessage.contains(System.Label.Account_Related_Contact_Role), FALSE);
    }
}