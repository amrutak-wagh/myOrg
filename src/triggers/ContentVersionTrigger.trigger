trigger ContentVersionTrigger on ContentVersion (after insert, after update) {
    Set<Id> contentDocumentIds = new Set<Id>();
    for(ContentVersion cv : Trigger.New){
        contentDocumentIds.add(cv.ContentDocumentId);
    }
    DDAIntegration.processAttachment(contentDocumentIds);
}