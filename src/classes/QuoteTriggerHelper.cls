/*
 * Created by: Raza khan (raza.khan@weare4c.com)
 * Dated:      29/07/2019
 * Description: This controller is for helper methodd for quote trigger 
 * 
 * 
 * */
public class QuoteTriggerHelper {
    
    public static void isStatusDraft(List<Quote> newList, map<Id, Quote> oldMap)
    {
        List<Id> quoteIds = new List<Id>();
        for(Quote q: newList)
        {
			if(q.status != oldmap.get(q.id).status && (q.status == 'Draft' && oldmap.get(q.id).status == 'Approved' ))
            {
                quoteIds.add(q.id);
            }
        }
        if(!quoteIds.isempty())
        {
            dletePaymentScheule(quoteIds);
        }
    }
    
    public static void dletePaymentScheule(List<Id> quoteIds)
    {
        List<Payment_Schedule__c> pSchedule = [Select id, Quote__c  from Payment_Schedule__c where Quote__c in: quoteIds ];
        if(pSchedule != null)
        {
            delete pSchedule;
        }
    }
    
    // 31/07/2019 - Adeel Ahmad
    // Reinitialize approver fields if certain fields on quetes gets changed
    // 04/08/2019 - Raza khan
    // Update the fields of grace period trigger the DOA 
    public static void reinitializeApprover(List<Quote> newList, map<Id, Quote> oldMap){
        SET<Id> updateableQuoteIds = new SET<Id>();
        for(Quote q: newList){
            if(q.Payment_Terms__c  != oldMap.get(q.Id).Payment_Terms__c ||
               q.Proposed_Start_Date__c != oldMap.get(q.Id).Proposed_Start_Date__c ||
               q.Proposed_End_Date__c  != oldMap.get(q.Id).Proposed_End_Date__c ||
               q.Grace_Period__c  != oldMap.get(q.Id).Grace_Period__c  ||
               q.Grace_Period_Period__c !=  oldMap.get(q.Id).Grace_Period_Period__c ||
               q.Grace_Period_Mechanism__c != oldMap.get(q.Id).Grace_Period_Mechanism__c
              ){
                  updateableQuoteIds.add(q.Id);
              }
        }
        if(updateableQuoteIds.size() > 0){
            DOAUtils.populateApprover(updateableQuoteIds);
        }
    }

}