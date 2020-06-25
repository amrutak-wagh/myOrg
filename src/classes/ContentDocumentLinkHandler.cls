/************************************************************************************
* Name          : ContentDocumentLinkHandler                                                 
* Description   : Handler on ContentDocumentLink Object Trigger
* Created Date  : 13/06/2019                                                    
* Created By    : 4C - Amruta Kumbhakarn (amruta.kumbhakarn@weare4c.com)
* Jira/Req By   :                                                                                                                                           
* -----------------------------------------------------------------------------------------------------------------------
* VERSION   Developer   Date        Description     Ticket/Reference                                                                    
************************************************************************************/
public class ContentDocumentLinkHandler {
    
    /**
     *  @description Updates the File_Attached__c field of Document__c parent object
     *  @param  triggerNew List of new ContentDocumentLink that trigger will pass
     *  @return Do not return anything
     */
    public static void updateDocumentCheckbox(List<ContentDocumentLink> triggerNew){
        
        Schema.DescribeSObjectResult doc = Document__c.sObjectType.getDescribe();
        String keyPrefix = doc.getKeyPrefix();
        Set<Id> documentIdSet = new Set<Id>();
        for(ContentDocumentLink instance : triggerNew){
            if(String.valueOf(instance.LinkedEntityId).startsWith(keyPrefix)){
                documentIdSet.add(instance.LinkedEntityId);                
            }
        }
        
        List<Document__c> documentToUpdateList = new List<Document__c>();
        documentToUpdateList = [SELECT   ID,File_Attached__c
                                FROM   Document__c
                                WHERE  Id IN :documentIdSet
                                AND    File_Attached__c = FALSE];
        if(!documentToUpdateList.isEmpty()){
            for(Document__c instance : documentToUpdateList){
                instance.File_Attached__c = TRUE;
            }
            update documentToUpdateList;
        }
    }    
}