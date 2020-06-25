/**
 *  @description Test class for WorkOrderRejectedCTRL
 *
 *  2019-16-08  Vaibhavi Kulkarni
 */

@isTest
public class WorkOrderRejectedCtrlTest {
	/*Common test data to be used in test class*/
    @testsetup
    public static void createData(){
        
        Case c = new Case(Status = 'New');
        insert c;
        
        Account accIns = new Account(Name = 'Test',Phone='1111111');
        insert accIns;
        Contact conIns = new Contact(LastName = 'Test',Email = 'vaibhavi.kulkarni@weare4c.com', isSubmit__c = true, ParentCon__c = true, AccountId= accIns.id ,Type__c = 'Billing;Leasing Contact;Licensee Contact;Manager Incharge');
        insert conIns;
        WorkOrder wo = new WorkOrder(Status = 'New', Description = 'test Description', AccountId = accIns.id, CaseId = c.Id,Work_Order_Number__c = 1);
        insert wo;
        WorkOrder wo1 = new WorkOrder(Status = 'New',Description = 'test Description', AccountId = accIns.id ,CaseId = c.Id,Work_Order_Number__c = 2);
        insert wo1;
        WorkOrder wo2 = new WorkOrder(Status = 'In Progress' ,Description = 'test Description', AccountId = accIns.id, CaseId = c.Id,Work_Order_Number__c =3);
        insert wo2;
        
    }
    
    /*Method to test functionality if the contact gets updated to isSubmit = false after email sending*/
    @isTest
    public static void testPositiveSendMailRejected() {
        List<Contact> conLst = [SELECT Id, isSubmit__c FROM Contact];
        List<WorkOrder> workOrderList = [SELECT Id,AccountId,Status,Description, CaseId, Work_Order_Number__c FROM WorkOrder];
        Test.startTest();
        WorkOrderRejectedCTRL.SendMailRejected(workOrderList);
        Test.stopTest();
        List<Contact> conUpdatedlst = [SELECT Id, isSubmit__c FROM Contact];
        System.assertEquals(conUpdatedlst[0].isSubmit__c, false, 'Assert to check if the contact is updated');
    }
    
    /*Method to test functionality if no contacts are matched with criteria as ParentCon__c = true*/
    @isTest
    public static void testNegativeSendMailRejectedWithNoContacts() {
        Contact conObj = [SELECT Id, isSubmit__c, ParentCon__c FROM Contact];
        conObj.ParentCon__c = false;
        update conObj;
        List<WorkOrder> workOrderList = [SELECT Id,AccountId,Status,Description, CaseId, Work_Order_Number__c FROM WorkOrder];
        Test.startTest();
        WorkOrderRejectedCTRL.SendMailRejected(workOrderList);
        Test.stopTest();
        List<Contact> conUpdatedlst = [SELECT Id, isSubmit__c FROM Contact WHERE ParentCon__c = true];
        System.assertEquals(conUpdatedlst.size(), 0, 'Assert to check contact list is empty');
    }
}