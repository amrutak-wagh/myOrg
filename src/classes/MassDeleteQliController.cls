/*
 * Author : Raza khan(raza.khan@weare4c.com)
 * Dated: 03-07-2018
 * Deacription: This is controller is for lightning quick action for mass deletion of quoteline items for the given quote. 
 * 
 * 
 * */
public class MassDeleteQliController {
    
    @AuraEnabled
    public static String massQuoteLineItemsDelete(Id quoteId)
    {
        String msg = '';
        try{
            Quote q = [Select id , Status,Soft_Book__c , Level_1_Approver__c, Level_2_Approver__c , Level_3_Approver__c , Level_4_Approver__c ,
                       Level_5_Approver__c , Level_6_Approver__c  from Quote where id =:quoteId limit 1 ];
            if(q.status == 'Draft' && !q.Soft_Book__c){
                delete [Select id from QuotelineItem where quoteId =: quoteId];
                delete [SELECT Id, Quote__c, Name FROM Quote_Revision__c where Quote__c =:quoteId];
                
                q.Level_1_Approver__c = null;
                q.Level_2_Approver__c = null;
                q.Level_3_Approver__c = null;
                q.Level_4_Approver__c = null;
                q.Level_5_Approver__c = null;
                q.Level_6_Approver__c = null;
                q.DOA_Approver__c = null;
                update q;
                msg =  'deleted';
            }else{
                msg = 'not deleted';
            }
        }catch(Exception e){
            msg = e.getMessage();
        }
    return msg;
    }
    
    
    
}