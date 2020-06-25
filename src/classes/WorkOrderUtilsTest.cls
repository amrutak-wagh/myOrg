/**
 *  @description Test class for ContactUtils
 *
 *  2019-26-07  Anshul Garg
 */
@isTest
public class WorkOrderUtilsTest {
	
    /*Common test data to be used in test class*/
    @testsetup
    public static void createData(){
        Case c = new Case(Status = 'New');
        insert c;
        WorkOrder wo = new WorkOrder(Status = 'New',CaseId = c.Id,Work_Order_Number__c = 1);
        insert wo;
        WorkOrder wo1 = new WorkOrder(Status = 'New',CaseId = c.Id,Work_Order_Number__c = 2);
        insert wo1;
        WorkOrder wo2 = new WorkOrder(Status = 'In Progress' ,CaseId = c.Id,Work_Order_Number__c =3);
        insert wo2;
    }
    
    /*Method to test functionality when WorkOrder throws error if approval is not done sequentially*/
    public static testmethod void positivecheckWorkOrderSequence(){
        WorkOrder wo =[SELECT Status FROM WorkOrder WHERE Status = 'In Progress' LIMIT 1];
        wo.status = 'Approved';
        Test.startTest();
        try{
            update wo;
        }catch(Exception e){
            System.assertEquals(e.getMessage().contains('The work orders has to be approved or rejected sequentially. Please approve or reject previous work orders first.'), true);
        }
        Test.stopTest();
        
    }
    
    /*Method to test functionality when WorkOrder do not throw error if they are approced sequentially*/
    public static testmethod void negativecheckWorkOrderSequence(){
        WorkOrder wo =[SELECT Status FROM WorkOrder WHERE  Work_Order_Number__c = 1  LIMIT 1];
        wo.status = 'Approved';
        WorkOrder wo1 =[SELECT Status FROM WorkOrder WHERE  Work_Order_Number__c = 2  LIMIT 1];
        wo1.status = 'Approved';
        Test.startTest();
            update wo;
            update wo1;
        Test.stopTest();
        System.assertEquals('Approved', [SELECT Status FROM WorkOrder WHERE  Work_Order_Number__c = 1  LIMIT 1].Status);
        System.assertEquals('Approved', [SELECT Status FROM WorkOrder WHERE Work_Order_Number__c = 2  LIMIT 1].Status);
        
    }
}