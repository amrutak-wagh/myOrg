/*Class is apex controller for the CheckSecurityCodeComp Lightning Comp*/

public class CheckSecurityCodeCompController {
    
    /******Method accepts the security code entered by user and encrypted code from URL.
	  	   Method returns the id of the code related to Contact if code and encrypted code matches from Contact
    	   Method is called from CheckSecurityCodeCompHelper ***********************************************************/
	@AuraEnabled
    public static Contact verifyContact(String encodedURLCode){
        System.debug('============'+encodedURLCode);
        Contact[] contactRecs = new List<Contact>();
        if(!String.isBlank(encodedURLCode)){
            contactRecs = [SELECT  Id
                       		  ,Code__c
                       		  ,Encrypted_Contact_Id__c
                         	  ,(Select Id 
                                FROM cases) 
                       FROM  Contact 
                       WHERE Encrypted_Contact_Id__c=:encodedURLCode];
        }else{
            return null;
        }
        return !contactRecs.isEmpty() ? contactRecs[0] : null;
    }
    
}