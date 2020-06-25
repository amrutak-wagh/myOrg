/************************************************************************************
* Name          : ContactUtils                                                 
* Description   : Utility class on Contact Object Trigger
* Created Date  : 09/07/2019                                                    
* Created By    : 4C - Amruta Kumbhakarn (amruta.kumbhakarn@weare4c.com)
* Jira/Req By   :                                                                                                                                           
* -----------------------------------------------------------------------------------------------------------------------
* VERSION   Developer   Date        Description     Ticket/Reference    
	2.0     Raza        15/07/2019  Update contacts validition that it should not allow duplicate role for billing, leasing and licensing only
************************************************************************************/
public class ContactUtils {
    
    /**
     *  @description Validates the contact and add error message whenever New contact of same type is added to Account
     *  @param  newList List of new Contacts that trigger will pass
     * 			oldMap  Map of Id of contacts and its old instance before update
     *  @return Do not return anything
     * Updated by: Raza - Update contacts validition that it should not allow role duplicate for billing, leasing and licensing only
     */
    private static set<String> contactTypes = new Set<String>{'Leasing Contact', 'Billing', 'Licensing Contact'};
	public static void validateContactType(List<Contact> newList,Map<Id,Contact> oldMap){
        /*Set<Id> accountIdSet = new Set<Id>();
        Set<Id> contactIdSet = new Set<Id>();
        for(Contact con : newList){
            if(con.AccountId != Null){
                accountIdSet.add(con.AccountId);
                if(con.Id != Null){
                    contactIdSet.add(con.Id);
                }
            }
        }
        
        List<Contact> listContact = [Select   Id
                                     		, Type__c
                                     		, AccountId 
                                     FROM  Contact 
                                     WHERE AccountId IN : accountIdSet 
                                     AND ID NOT IN :contactIdSet];
        
        
        Map<Id,List<Contact>> accountIdContactList = new Map<Id,List<Contact>>();
        Map<Id,Set<String>> idTypeSetMap = new Map<Id,Set<String>>();
        for(Contact con : listContact){
            if(con.Type__c != Null){
                if(!idTypeSetMap.containsKey(con.AccountId)){
                    Set<String> typeSet = new Set<String>();
                    typeSet.addAll(con.Type__c.split(';'));
                    idTypeSetMap.put(con.AccountId,typeSet);
                }else{
                    Set<String> typeSet = new Set<String>();
                    typeSet.addAll(con.Type__c.split(';'));
                    if(!typeSet.isEmpty()){
                        idTypeSetMap.get(con.AccountId).addAll(typeSet);
                    }
                } 
            }
            
        }
        
        for(Contact con : newList){
            List<String> typeValuesList = new List<String>();
            typeValuesList = con.Type__c != Null ? con.Type__c.split(';') : typeValuesList; 
            if(idTypeSetMap.containsKey(con.AccountId)){
                for(String s : typeValuesList){
                    if( !idTypeSetMap.isEmpty() && idTypeSetMap.get(con.AccountId).contains(s)){
                        con.addError(Label.Contact_Type_Error_Message);
                    }
                }                                                        
            }   
        }*/
        
        Set<Id> accountIdSet = new Set<Id>();
        Set<Id> contactIdSet = new Set<Id>();
        for(Contact con : newList){
                accountIdSet.add(con.AccountId);
            if(con.id != null)
                contactIdSet.add(con.id);
                
            }
        
        
        List<Contact> listContact = [Select   Id
                                     		, Type__c
                                     		, AccountId 
                                     FROM  Contact 
                                     WHERE AccountId IN : accountIdSet 
                                     AND ID NOT IN :contactIdSet];
        Map<Id, Set<String>> accountContactRoles = new Map<Id, Set<String>>();
        for(Contact con: listContact)
        {
            Set<String> contRoles = accountContactRoles.get(con.accountid);
            if(contRoles == null)
            {
                contRoles = new Set<String>();
                accountContactRoles.put(con.AccountId, contRoles);
            }
            if(con.Type__c != null)
            {
                for(string cr: con.Type__c.split(';') )
                {
                    if(contactTypes.contains(cr))
                    {
                        contRoles.add(cr);
                    }
                }
            }
            
        }
        
        for(contact c: newList)
        {
            if(c.Type__c != null){
                Set<String> contactRoles = accountContactRoles.get(c.AccountId);
                if( contactRoles != null){
                for(String contRole: c.Type__c.split(';'))
                {
                    if(contactRoles.contains(contRole))
                    {
                        c.addError(Label.Contact_Type_Error_Message);
                        break;
                    }
                }
            }
            }
        }
        
    
        
        
    }
    
    /**
     *  @description This method accepts the list of updated contacts and pass it to updateContactEncryptedId method if Encrypted_Contact_Id__c is Null
     *  @param  newList List of new Contacts that trigger will pass
     *  @return Do not return anything
     */
    public static void updateContact(LIST<Contact> newList){
        LIST<Contact> updateables = new LIST<Contact>();
        for(Contact c : newList){
        	if(String.isBlank(c.Encrypted_Contact_Id__c)){
        		updateables.add(c);
        	}
        }

        if(updateables.size() > 0){
        	updateContactEncryptedId(updateables);
        }
    }
	
    /**
     *  @description This method updates the Encrypted_Contact_Id__c field on newly created Contacts
     *  @param  updateables List of new Contacts in which Encrypted_Contact_Id__c is Null
     *  @return Do not return anything
     */
    
    private static void updateContactEncryptedId(LIST<Contact> updateables){
    	LIST<Contact> contactsToUpdate = [SELECT Id FROM Contact WHERE Id IN:updateables];
    	if(contactsToUpdate.size() > 0){
	        Blob privateKey = EncodingUtil.base64Decode('046QdQEH24AgGafkkot8gg==');
	    	for(Contact c : contactsToUpdate){
	    		c.Encrypted_Contact_Id__c = EncodingUtil.urlEncode(EncodingUtil.base64Encode(Crypto.encryptWithManagedIV('AES128', privateKey, Blob.valueOf('003Q000001Jt1sDIAR'))),'UTF-8');
	    	}
    		upsert contactsToUpdate;
    	}

    }
}