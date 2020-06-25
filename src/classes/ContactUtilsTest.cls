/**
 *  @description Test class for ContactUtils
 *
 *  2019-19-07  Amruta Kumbhakarn
 */
@isTest
public class ContactUtilsTest {
    
    /*This method tests that if contact with Type__c  Billing;Leasing Contact;Licensee Contact;Manager Incharge
	  exist than Type__c can be ''*/
    public static testmethod void testNegativeInsert(){
        Account accIns = new Account(Name = 'Test',Phone='1111111');
        insert accIns;
        Contact conIns = new Contact(LastName = 'Test',AccountId= accIns.id ,Type__c = 'Billing;Leasing Contact;Licensee Contact;Manager Incharge');
        insert conIns;
        List<Contact> conList = new List<Contact>();
        for(integer i = 0 ; i < 100 ; i++){
            Contact conIns1 = new Contact(LastName = 'Test'+i,AccountId= accIns.id);
            conList.add(conIns1);
        }
       	insert conList;
        System.assertEquals([Select id from Contact].size(),101);
    }
    
    /*This method test that no 2 contact of same Type__c can exist on a account*/
    public static testmethod void testPositiveInsert1(){
        Account accIns = new Account(Name = 'Test',Phone='1111111');
        insert accIns;
        Contact conIns = new Contact(LastName = 'Test',AccountId= accIns.id ,Type__c = 'Billing;Leasing Contact;Licensee Contact;Manager Incharge');
        insert conIns;
        List<Contact> conList = new List<Contact>();
        for(integer i = 0 ; i <= 100 ; i++){
            Contact conIns1 = new Contact(LastName = 'Test'+i,AccountId= accIns.id,Type__c='Billing');
            conList.add(conIns1);
        }
        try{
            insert conList;
        }catch(Exception e){
            System.assertEquals(e.getMessage().contains('Contact With Similar Type Value Already Exist for this Account'), true);
        }
    }
    
    /*This method test that you can not update the contacts to have same Type value*/
    public static testmethod void testNegativeUpdate1(){
        Account accIns = new Account(Name = 'Test',Phone='1111111');
        insert accIns;
        Contact conIns = new Contact(LastName = 'Test',AccountId = accIns.id,Type__c ='Billing;Leasing Contact;Licensee Contact;Manager Incharge');
        insert conIns;
        Contact conIns1 = new Contact(LastName = 'Test',AccountId= accIns.id ,Type__c = 'Owner Sales Agent');
        insert conIns1;
        try{
             conIns1.Type__c = 'Billing';
             update conIns1;
        }catch(Exception e){
            System.debug(e.getMessage());
            System.assertEquals(e.getMessage().contains('Contact With Similar Type Value Already Exist for this Account'), true);
        }
    }
    
    /*This method test that no 2 contact of same Type__c can exist on a account*/
    public static testmethod void testPositiveInsert2(){
        Account accIns = new Account(Name = 'Test',Phone='1111111');
        insert accIns;
        Contact conIns = new Contact(LastName = 'Test',AccountId= accIns.id ,Type__c = 'Billing;Leasing Contact;Licensee Contact;Manager Incharge');
        insert conIns;
        Contact conIns1 = new Contact(LastName = 'Test',AccountId= accIns.id ,Type__c = 'Owner Sales Agent');
        insert conIns1;
        List<Contact> conList = new List<Contact>();
        for(integer i = 0 ; i <= 100 ; i++){
            Contact conIns2 = new Contact(LastName = 'Test'+i,AccountId= accIns.id,Type__c='Billing');
            conList.add(conIns2);
        }
        try{
            insert conList;
        }catch(Exception e){
            System.assertEquals(e.getMessage().contains('Contact With Similar Type Value Already Exist for this Account'), true);
        }
    }
}