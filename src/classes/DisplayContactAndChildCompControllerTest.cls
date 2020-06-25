/**
 *  @description Test Class for DisplayContactAndChildCompController class
 *
 *  Amruta Kumbhakarn
*/
@isTest
public class DisplayContactAndChildCompControllerTest {
    
    /*Test data to create test data for Contacts,its related Cases,Work Orders related to contact and child Work orders required for different scenarios*/
    @testSetup public static void createContacts() {
        
        //Test data to create 100 contacts
		List<Contact> listContact = new List<Contact>();
        
        for(Integer i=0 ; i<100 ; i++){
            
            Contact testContact = new Contact(LastName = 'test' + String.valueOf(i),Encrypted_Contact_Id__c = String.valueOf(i*i));
            listContact.add(testContact);
            
        }
    	insert listContact;
        
        //Test data to create 1 case for each created contact
        List<Case> listCase = new List<Case>();
        for(Contact ins : listContact){
            
            Case testCase = new Case(Status = 'New',ContactId = ins.id);
            listCase.add(testCase);
            
        }
        insert listCase;
        
        
        List<Contact> listExpectedContactFirst = [Select id,(Select id,ContactId from Cases) from contact where Encrypted_Contact_Id__c = '25'];
        List<Contact> listExpectedContactSecond = [Select id,(Select id,ContactId from Cases) from contact where Encrypted_Contact_Id__c = '36'];
        List<Contact> listExpectedContactThird = [Select id,(Select id,ContactId from Cases) from contact where Encrypted_Contact_Id__c = '49'];
        List<Contact> listExpectedContactFourth = [Select id,(Select id,ContactId from Cases) from contact where Encrypted_Contact_Id__c = '64'];
        
        //Test data to create Test data for WorkOrder,25 each for 4 contacts and related case
        List<WorkOrder> listWorkOrder = new List<WorkOrder>();
        for(Integer i=0 ; i<25 ; i++){
            
            WorkOrder testWO = new WorkOrder( CaseId = listExpectedContactFirst[0].Cases[0].id
                                             ,ContactId = listExpectedContactFirst[0].Id
                                             ,Subject = 'test');
            listWorkOrder.add(testWO);
            
        }
        
        WorkOrder testWORejected = new WorkOrder( Status = 'Rejected'
                                                 ,CaseId = listExpectedContactFirst[0].Cases[0].id
                                                 ,ContactId = listExpectedContactFirst[0].Id
                                                 ,Subject = 'test'
                                                 ,Description='Test');
        listWorkOrder.add(testWORejected);
        
        for(Integer i=0 ; i<25 ; i++){
            
            WorkOrder testWO = new WorkOrder( CaseId = listExpectedContactSecond[0].Cases[0].id
                                             ,ContactId = listExpectedContactSecond[0].Id
                                             ,Subject = 'test');
            listWorkOrder.add(testWO);
            
        }
        
        for(Integer i=0 ; i<25 ; i++){
            
            WorkOrder testWO = new WorkOrder( CaseId = listExpectedContactThird[0].Cases[0].id
                                             ,ContactId = listExpectedContactThird[0].Id
                                             ,Subject = 'test');
            listWorkOrder.add(testWO);
            
        }
        
        for(Integer i=0 ; i<25 ; i++){
            
            WorkOrder testWO = new WorkOrder( Status = 'Rejected'
                                             ,CaseId = listExpectedContactFourth[0].Cases[0].id
                                             ,ContactId = listExpectedContactFourth[0].Id
                                             ,Subject = 'test'
                                             ,Description = 'Test');
            listWorkOrder.add(testWO);
            
        }
        insert listWorkOrder;
        
        //Test data to create child WOs for WorkOrder whose contact's encrypted id is 25
        List<WorkOrder> listParentWO = [SELECT  CaseId
                                         	   ,ContactId
                                        	   ,RecordTypeId 
                                        FROM  WorkOrder 
                                        WHERE Contact.Encrypted_Contact_Id__c = '25' ];
        
        List<WorkOrder> childWO = new List<WorkOrder>();
        
        for(WorkOrder ins : listParentWO){
            
            WorkOrder testWO = new WorkOrder( Status ='New'
                                             ,CaseId = listExpectedContactFirst[0].Cases[0].id
                                             ,ContactId = listExpectedContactFirst[0].Id
                                             ,Subject = 'test'
                                             ,ParentWorkOrderId = ins.id
                                             ,Description = 'Test');
            childWO.add(testWO);
            
        }
        insert childWO;
        
        //Test data to create further more childs for WorkOrder
        List<WorkOrder> listWoWithParents = [SELECT  CaseId
                                             		,ContactId
                                             		,RecordTypeId 
                                             FROM  WorkOrder 
                                             WHERE ParentWorkOrderId != null 
                                             AND   Contact.Encrypted_Contact_Id__c = '25' 
                                             LIMIT 10];
        
        List<WorkOrder> childToChildWO = new List<WorkOrder>();
        
        for(WorkOrder ins : listWoWithParents){
            
            WorkOrder testWO = new WorkOrder( Status ='Rejected'
                                             ,CaseId = listExpectedContactFirst[0].Cases[0].id
                                             ,ContactId = listExpectedContactFirst[0].Id
                                             ,Subject = 'test'
                                             ,ParentWorkOrderId = ins.id
                                             ,Description = 'Test');
            childToChildWO.add(testWO);
            
            WorkOrder siblingWO = new WorkOrder( Status ='Rejected'
                                                ,CaseId = listExpectedContactFirst[0].Cases[0].id
                                                ,ContactId = listExpectedContactFirst[0].Id
                                                ,Subject = 'test'
                                                ,ParentWorkOrderId = ins.id
                                                ,Description = 'Test');
            childToChildWO.add(siblingWO);
            
        }
        insert childToChildWO;
        
        
    }
    
    /*Test method to test the function writtent to get field description from meta data*/
    public static testmethod void testgetFields(){
        String objectApiName = 'Case';
        String nameFieldSet = Label.CaseFieldSetName;
        DisplayContactAndChildCompController.getFields(objectApiName,nameFieldSet);
    }
    
    /*Test method to check cases and WOs for contact which has multiple child ,child to child WorkOrders*/
    public static testmethod void testgetCaseRecord1(){
        String encodedURLCode = '25';
        test.startTest();
        Contact responseContact = CheckSecurityCodeCompController.verifyContact(encodedURLCode);
        String serializedResponse = DisplayContactAndChildCompController.getCaseRecord(responseContact.Cases[0].id);
        //DisplayContactAndChildCompController.FieldSetSobjectRecordWrapper instance = (DisplayContactAndChildCompController.FieldSetSobjectRecordWrapper)JSON.deserializeStrict(serializedResponse, DisplayContactAndChildCompController.FieldSetSobjectRecordWrapper.class);
    	System.assert(serializedResponse!=null, '');
    }
    
    /*Test method to check the cases and WOs for the contact which has WOs up to single level*/
    public static testmethod void testgetCaseRecord2(){
        String encodedURLCode = '36';
        test.startTest();
        Contact responseContact = CheckSecurityCodeCompController.verifyContact(encodedURLCode);
        String serializedResponse = DisplayContactAndChildCompController.getCaseRecord(responseContact.Cases[0].id);
        //DisplayContactAndChildCompController.FieldSetSobjectRecordWrapper instance = (DisplayContactAndChildCompController.FieldSetSobjectRecordWrapper)JSON.deserializeStrict(serializedResponse, DisplayContactAndChildCompController.FieldSetSobjectRecordWrapper.class);
    	System.assert(serializedResponse!=null, '');
    }
    
    /*Test method to check the cases and WOs for the contact which has WOs for no level*/
    public static testmethod void testgetCaseRecord3(){
        String encodedURLCode = '49';
        test.startTest();
        Contact responseContact = CheckSecurityCodeCompController.verifyContact(encodedURLCode);
        String serializedResponse = DisplayContactAndChildCompController.getCaseRecord(responseContact.Cases[0].id);
        //DisplayContactAndChildCompController.FieldSetSobjectRecordWrapper instance = (DisplayContactAndChildCompController.FieldSetSobjectRecordWrapper)JSON.deserializeStrict(serializedResponse, DisplayContactAndChildCompController.FieldSetSobjectRecordWrapper.class);
    	System.assert(serializedResponse!=null, '');
    }
}