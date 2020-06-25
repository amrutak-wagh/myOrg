/**
 *  @description Test class for WorkOrderToolbarHandler
 *
 *  2019-09-11  Amruta K    First version
 *  
 */
@isTest
public class PremiseLeaseComponentControllerTest {
    /*Common test data to be used in test class*/
	@testSetup
    public static void testDataSetup(){
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
                                                         CloseDate = System.today(),
                                                         Type = 'New',
                                                         Lease_End_Date__c = Date.today().addDays(120)
                                                        );
        insert opportunityObject;
        
        Quote quoteObject = new Quote(Name = 'Test Quote',
                                     Proposed_Start_Date__c = System.today(),
                                     Proposed_End_Date__c = System.today().addDays(2),
                                     Type__c = 'Expansion',
                                     Pricebook2Id = Test.getStandardPricebookId(),
                                     OpportunityId = opportunityObject.Id);
        insert quoteObject;
        
        opportunityObject.StageName = 'Active';
		update opportunityObject;      
    }
    
    //Method to test if any child opportunity of Type 'Renewal' is present
    @isTest
    public static void checkForValidOppAndExecuteBatchTest4(){
        List<Opportunity> opportunityList = [SELECT Id, 
                                             StageName, 
                                             Lease_End_Date__c, 
                                             CloseDate,
                                             Business_Park__c,
                                             Name,
                                             SyncedQuoteId
                                             FROM Opportunity
                                             WHERE Name = 'Test Opportunity'
                                            ];
        
        Opportunity childOpportunity = new Opportunity();
        childOpportunity = opportunityList[0].clone(false,false);
        childOpportunity.Type = 'Renewal';
       	childOpportunity.StageName = 'New';
        childOpportunity.Parent_Opportunity__c = opportunityList[0].Id;
        insert childOpportunity;
        
        Test.startTest();
        String resultMessage = PremiseLeaseComponentController.checkForValidOppAndExecuteBatch(opportunityList[0].Id);
        Test.stopTest();
        
        System.assertEquals(resultMessage, 'Renewal Opportunity is already present.');
    }
    
    //Method to test if all the criterias are met
    @isTest
    public static void checkForValidOppAndExecuteBatchTest5(){
        List<Opportunity> opportunityList = [SELECT Id, 
                                             StageName, 
                                             Lease_End_Date__c, 
                                             SyncedQuoteId,
                                             (SELECT Id FROM Opportunities__r WHERE Type = 'Renewal' AND  StageName != 'Cancelled')
                                             FROM Opportunity
                                             WHERE Name = 'Test Opportunity'
                                            ];
        
        Quote quoteOject = [SELECT Id FROM Quote WHERE OpportunityId = :opportunityList[0].Id LIMIT 1];
        opportunityList[0].SyncedQuoteId = quoteOject.Id;
        update opportunityList[0];
        
        Test.startTest();
        String resultMessage = PremiseLeaseComponentController.checkForValidOppAndExecuteBatch(opportunityList[0].Id);
        Test.stopTest();
        
        List<Opportunity> opprenewalList = [SELECT Id
                                            FROM Opportunity
                                            WHERE Type = 'Renewal'
                                          ];

        System.assertEquals(resultMessage, 'Success');
        System.assertEquals(opprenewalList.size(), 1);
    }
}