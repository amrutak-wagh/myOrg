public without sharing class NewRenewIntegrationIntegrationUtil {
    
    public static void sendApprovedQuote(List<Quote> quotes, map<Id, Quote> oldmap)
    {
        List<Id> approvedQuotes = new List<Id>();
        for(Quote q: quotes)
        {
            if(q.status != oldmap.get(q.id).status && q.status == 'Approved')
            {
                approvedQuotes.add(q.id);
            }
        }
        if(!approvedQuotes.isEmpty())
        {
            sendNewLeaseToYardi(approvedQuotes);
        }
    }
    public static void sendCclSignedQuote(List<Quote> quotes, map<Id, Quote> oldmap)
    {
        List<Id> approvedQuotes = new List<Id>();
        for(Quote q: quotes)
        {
            if(q.status != oldmap.get(q.id).status && q.status == 'Accepted')
            {
                approvedQuotes.add(q.id);
            }
        }
        if(!approvedQuotes.isEmpty())
        {
            sendNewLeaseToYardi(approvedQuotes);
        }
    }
    
    public static void sendHSEStatus(List<Opportunity> newOpps, Map<Id,Opportunity> oldmap)
    {
        List<Id> oppIds = new List<Id>();
        for(Opportunity opp: newOpps)
        {
            if(opp.HSE_Status__c  != oldmap.get(opp.id).HSE_Status__c ||
              opp.HSE_Clearance_Date__c  != oldmap.get(opp.id). HSE_Clearance_Date__c )
            {
                oppIds.add(opp.id);
            }
        }
      
        if(!oppIds.isempty())
        {
            sendHseStatusToYardi(oppIds);
        }
        
    }
    
    @future(callout = true)
    public static void sendHseStatusToYardi(List<Id> opportuntyIds ){
        
        NewRenewLeaseIntegration.hseOpportunityStatus(opportuntyIds);
    }
    
    @future(callout=true)
    public static void sendNewLeaseToYardi(List<Id> quoteIds)
    {
        NewRenewLeaseIntegration.sendLeaseToOIC(quoteIds);
    }

}