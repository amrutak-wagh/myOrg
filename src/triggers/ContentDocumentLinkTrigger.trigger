trigger ContentDocumentLinkTrigger on ContentDocumentLink (before insert,after insert,before delete,after delete,before update,after update) {
    
	if (Trigger.isInsert) {
        if (Trigger.isBefore) {
            // Process before insert
        } else if (Trigger.isAfter) {
            // commented by raza - as it was throughing exception for POC testing
            // Process after insert
            ContentDocumentLinkHandler.updateDocumentCheckbox(trigger.new);
        }        
    }
    else if (Trigger.isDelete) {
        // Process after delete
    }
    else if(Trigger.isUpdate){
        // Process after update
    }
    
}