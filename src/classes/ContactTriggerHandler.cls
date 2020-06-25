public class ContactTriggerHandler {
    
    public static void handleBeforeInsert(List<Contact> newList, Map<Id, Contact> oldMap){
        ContactUtils.validateContactType(newList,oldMap);
    }
    
    public static void handleBeforeUpdate( List<Contact> newList, Map<Id, Contact> oldMap){
        ContactUtils.validateContactType(newList,oldMap);
    }

    public static void handleAfterInsert(List<Contact> newList){
        ContactUtils.updateContact(newList);
    }  
}