@isTest
public class CheckSecurityCodeCompControllerTest {
    
    /*Test Setup method to create test data for Contacts used in Test class*/
	@testSetup public static void createContacts() {
        
		List<Contact> listContact = new List<Contact>();
        
        for(Integer i=0 ; i<100 ; i++){
            
            Contact testContact = new Contact(LastName = 'test' + String.valueOf(i),Encrypted_Contact_Id__c = String.valueOf(i*i));
            listContact.add(testContact);
            
        }
        
    	insert listContact;    
    }
    
    /*Test method to check if encrypted code matches on the contact*/
    public static testmethod void testverifyContactPositive(){
    	
        String encodedURLCode = '25';
        test.startTest();
        Contact responseContact = CheckSecurityCodeCompController.verifyContact(encodedURLCode);
        test.stopTest();
        Contact[] conRec = [SELECT Id FROM Contact WHERE Encrypted_Contact_Id__c='25'];
        System.assertEquals(conRec[0].id,responseContact.id);
        
    }
    
    /*Test method to check if encrypted code do not matches on the contact*/
    public static testmethod void testverifyContactNegative(){
    	
        String encodedURLCode = '%%%%%';
        test.startTest();
        Contact responseContact = CheckSecurityCodeCompController.verifyContact(encodedURLCode);
        test.stopTest();
        System.assertEquals(null, responseContact);
        
    }
    
    /*Test method to check if encrypted code is ' ' on the contact*/
    public static testmethod void testverifyContactWhenCodeisEmpty(){
        
        String encodedURLCode = '';
        test.startTest();
        Contact responseContact = CheckSecurityCodeCompController.verifyContact(encodedURLCode);
        test.stopTest();
        System.assertEquals(null, responseContact);
        
    }
}