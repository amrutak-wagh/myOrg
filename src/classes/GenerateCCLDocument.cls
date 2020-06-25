/**
 *  @description Auxiliary functions related to pricing
 *
 *  2019-07-26  Amruta K   Implement calculation of total rates depending on start/end dates
 */
global class GenerateCCLDocument {    
   
    /**
     *  @description Function that create a Document
     * 
     */
    @AuraEnabled
    webservice static String createDocument(Id qouteId) {
               
        List<Quote> qouteLst = 
            [SELECT Id, Status, AccountId, (SELECT Id FROM Payment_Schedules__r)
             FROM Quote
             WHERE Id =: qouteId
             AND Status = 'Approved'];
        
        
		List<Document__c> docLst = new List<Document__c>();
        if(!qouteLst.isEmpty()) {
   
            if(!qouteLst[0].Payment_Schedules__r.isEmpty()) {
                Document__c doc = new Document__c();
                doc.Name = 'Test Provisional Approval Letter ';
                doc.Account__c = qouteLst[0].AccountId;
                doc.Quote__c = qouteId;
                docLst.add(doc);
                insert docLst;
                
                for(Document__c docObj : docLst) {
                    CongaBackground.CongaBackgroundMode(docObj.Id);
                }
                return 'Success';
            }
            else {
                return 'Quote should have one Payment Schedule record to generate CCL document.';
            }
        }
        else {
            return 'Quote should be Approved to generate CCL document.';
        }
    }
}