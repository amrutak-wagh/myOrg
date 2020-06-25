public class GetChildOpportunity {
    public static List<Opportunity> opportunityList = new List<Opportunity>();
    public static List<Quote> quoteList = new List<Quote>();
    public static List<QuoteLineItem> quoteLineItemList = new List<QuoteLineItem>();
    
	@AuraEnabled
    public static Opportunity createAndGetChildOpportunity(Id opportunityId){
        System.debug('opportunityId------ ' + opportunityId);
        Opportunity parentOpportunityObject = [SELECT Id, AccountId, Amendment_Id__c, Amount, Budget_Confirmed__c, Building_Name__c, Business_Park__c,
                                                       CloseDate, Contact__c, ContactId, ContractId, CurrentGenerators__c, DeliveryInstallationStatus__c, Description,
                                                       Discovery_Completed__c, ForecastCategoryName, Framework_Detail__c, HSE_Clearance_Date__c,
                                                       HSE_Notes__c, HSE_Status__c, Is_renewal__c, LeadSource, Lease_End_Date__c, Lease_Start_Date__c, Lease_Type__c,
                                                       Legal_Framework__c, License_Type__c, Loss_Reason__c, MainCompetitors__c, NextStep, CurrencyIsoCode, Name,
                                                       RecordTypeId, Opportunity_Type__c, OrderNumber__c, Pricebook2Id, CampaignId, IsPrivate, Probability, 
                                                       Proposed_Booking_Expiry_Extension__c, TotalOpportunityQuantity, Retail_Sales_Category__c, ROI_Analysis_Completed__c,
                                                       Segment__c, Soft_Booking_Extension_Submitted__c, StageName,  T_Code__c, TrackingNumber__c, 
                                                       Yardi_Integration_Error_Message__c, Yardi_Integration_Status__c, Yardi_Lease_Status__c 
                                               FROM Opportunity WHERE Id = :opportunityId];
        
		Opportunity chidlOpportunityObject = new Opportunity(AccountId = parentOpportunityObject.AccountId,
                                                             Amendment_Id__c = parentOpportunityObject.Amendment_Id__c,
                                                             Amount = parentOpportunityObject.Amount,
                                                             Budget_Confirmed__c = parentOpportunityObject.Budget_Confirmed__c,
                                                             Building_Name__c = parentOpportunityObject.Building_Name__c,
                                                             Business_Park__c = parentOpportunityObject.Business_Park__c,
                                                             CloseDate = parentOpportunityObject.CloseDate,
                                                             Contact__c = parentOpportunityObject.Contact__c,
                                                             ContractId = parentOpportunityObject.ContractId,
                                                             ContactId = parentOpportunityObject.ContactId,
                                                             CurrentGenerators__c = parentOpportunityObject.CurrentGenerators__c,
                                                             DeliveryInstallationStatus__c = parentOpportunityObject.DeliveryInstallationStatus__c,
                                                             Description = parentOpportunityObject.Description,
                                                             Discovery_Completed__c = parentOpportunityObject.Discovery_Completed__c,
                                                             ForecastCategoryName = parentOpportunityObject.ForecastCategoryName,
                                                             Framework_Detail__c = parentOpportunityObject.Framework_Detail__c,
                                                             HSE_Clearance_Date__c = parentOpportunityObject.HSE_Clearance_Date__c,
                                                             HSE_Notes__c = parentOpportunityObject.HSE_Notes__c,
                                                             HSE_Status__c = parentOpportunityObject.HSE_Status__c,
                                                             Is_renewal__c = parentOpportunityObject.Is_renewal__c,
                                                             LeadSource = parentOpportunityObject.LeadSource,
                                                             Lease_End_Date__c = parentOpportunityObject.Lease_End_Date__c,
                                                             Lease_Start_Date__c = parentOpportunityObject.Lease_Start_Date__c,
                                                             Lease_Type__c = parentOpportunityObject.Lease_Type__c,
                                                             Legal_Framework__c = parentOpportunityObject.Legal_Framework__c,
                                                             License_Type__c = parentOpportunityObject.License_Type__c,
                                                             Loss_Reason__c = parentOpportunityObject.Loss_Reason__c,
                                                             MainCompetitors__c = parentOpportunityObject.MainCompetitors__c,
                                                             NextStep = parentOpportunityObject.NextStep,
                                                             CurrencyIsoCode = parentOpportunityObject.CurrencyIsoCode,
                                                             Name = parentOpportunityObject.Name + 'Downsizing amendment opportunity',
                                                             RecordTypeId = parentOpportunityObject.RecordTypeId,
                                                             Opportunity_Type__c = parentOpportunityObject.Opportunity_Type__c,
                                                             OrderNumber__c = parentOpportunityObject.OrderNumber__c,
                                                             Parent_Amendment_Id__c = parentOpportunityObject.Amendment_Id__c,
                                                             Parent_Opportunity__c = parentOpportunityObject.Id,
                                                             Pricebook2Id = parentOpportunityObject.Pricebook2Id,
                                                             CampaignId = parentOpportunityObject.CampaignId,
                                                             IsPrivate = parentOpportunityObject.IsPrivate,
                                                             Probability = parentOpportunityObject.Probability,
                                                             Proposed_Booking_Expiry_Extension__c = parentOpportunityObject.Proposed_Booking_Expiry_Extension__c,
                                                             Retail_Sales_Category__c = parentOpportunityObject.Retail_Sales_Category__c,
                                                             ROI_Analysis_Completed__c = parentOpportunityObject.ROI_Analysis_Completed__c,
                                                             Segment__c = parentOpportunityObject.Segment__c,
                                                             Soft_Booking_Extension_Submitted__c = parentOpportunityObject.Soft_Booking_Extension_Submitted__c,
                                                             StageName = parentOpportunityObject.StageName,
                                                            
                                                             Sub_Type__c = 'Downsize',
                                                             T_Code__c = parentOpportunityObject.T_Code__c,
                                                             TrackingNumber__c = parentOpportunityObject.TrackingNumber__c,
                                                             Type = 'Amendment',
                                                             Yardi_Integration_Error_Message__c = parentOpportunityObject.Yardi_Integration_Error_Message__c,
                                                             Yardi_Integration_Status__c = parentOpportunityObject.Yardi_Integration_Status__c,
                                                             Yardi_Lease_Status__c = parentOpportunityObject.Yardi_Lease_Status__c);
        insert chidlOpportunityObject;
        
       
        Opportunity opp = [SELECT Id, Parent_Opportunity__c, AccountId, Amendment_Id__c, Amount, Budget_Confirmed__c, Building_Name__c, Business_Park__c, Sub_Type__c, Type,
                                                       CloseDate, Contact__c, ContactId, ContractId, CurrentGenerators__c, DeliveryInstallationStatus__c, Description,
                                                       Discovery_Completed__c, ForecastCategoryName, Framework_Detail__c, HSE_Clearance_Date__c,
                                                       HSE_Notes__c, HSE_Status__c, Is_renewal__c, LeadSource, Lease_End_Date__c, Lease_Start_Date__c, Lease_Type__c,
                                                       Legal_Framework__c, License_Type__c, Loss_Reason__c, MainCompetitors__c, NextStep, CurrencyIsoCode, Name,
                                                       RecordTypeId, Opportunity_Type__c, OrderNumber__c, Pricebook2Id, CampaignId, IsPrivate, Probability, 
                                                       Proposed_Booking_Expiry_Extension__c, TotalOpportunityQuantity, Retail_Sales_Category__c, ROI_Analysis_Completed__c,
                                                       Segment__c, Soft_Booking_Extension_Submitted__c, StageName,  T_Code__c, TrackingNumber__c, 
                                                       Yardi_Integration_Error_Message__c, Yardi_Integration_Status__c, Yardi_Lease_Status__c 
                                               FROM Opportunity WHERE Parent_Opportunity__c = :parentOpportunityObject.Id AND Sub_Type__c = 'Downsize' AND Type = 'Amendment'
                           ORDER BY Id DESC LIMIT 1];
         System.debug('opp--------'+ opp.Parent_Opportunity__c);
        
         Quote quoteObject = [SELECT Id, AccountId, AdditionalAddress, AdditionalName, BillingAddress, BillingName, Booking_expiry_Date__c, Building__c, Cancellation_Reason__c,
                       Category__c, CCL_Sign_Date__c, ContactId, ContractId, Description, Discount__c, Discount, Discount_Percentage__c, DOA_Approver__c, 
                       DOA_Discount__c, DOA_Discount_percent__c, Email, ExpirationDate, Fax, Grace_Period__c, Grace_Period_Period__c, Grace_Period_Mechanism__c,
                       GrandTotal, Integration_Status__c, Lease_End_Date__c, Lease_Start_Date__c, Legal_Terms_Changed__c, Level_1_Approver__c, Level_2_Approver__c,
                       Level_3_Approver__c, Level_4_Approver__c, Level_5_Approver__c, Level_6_Approver__c, LineItemCount, Manually_submitted__c, Number_Of_Payments__c,
                       OpportunityId, Opportunity_Type__c, Name, QuoteNumber, RecordTypeId, Pricebook2Id, IsSyncing, Type__c, Unit_Sub_Category__c,Proposed_Start_Date__c,Proposed_End_Date__c
               FROM Quote WHERE OpportunityId = :opportunityId AND IsSyncing = TRUE];
        
        Quote childQuoteObject = quoteObject.clone(false,true);
        childQuoteObject.OpportunityId = opp.Id;
       
        insert childQuoteObject;
       
        quoteLineItemList = [SELECT Id, ListPrice, QuoteId, Offer_Price__c, Product2Id, Quantity, End_Date__c, UnitPrice,PriceBookEntryId
                             FROM QuoteLineItem WHERE QuoteId = :quoteObject.Id];
        System.debug('quoteLineItemList============='+quoteLineItemList);
        
        List<QuoteLineItem> childQuoteLineItemList = quoteLineItemList.deepClone();
       
        for(QuoteLineItem qliObj : childQuoteLineItemList){
            qliObj.QuoteId = childQuoteObject.Id;
            qliObj.Quantity = 1000;
           /* String quantity = String.valueOf(qliObj.Quantity);
            if(quantity.isNumeric() && quantity.length() < 9 && quantity.containsNone('.')){
                qliObj.Quantity = qliObj.Quantity;
            } else{
                qliObj.Quantity = null;
            }*/
        }
         insert childQuoteLineItemList;
                
        
       	return opp;
    }
    
     @AuraEnabled
    public static Quote getQuoteRecord(Id opportunityId){
        Quote quoteObject = [SELECT Id, AccountId, AdditionalAddress, AdditionalName, BillingAddress, BillingName, Booking_expiry_Date__c, Building__c, Cancellation_Reason__c,
                       Category__c, CCL_Sign_Date__c, ContactId, ContractId, Description, Discount__c, Discount, Discount_Percentage__c, DOA_Approver__c, 
                       DOA_Discount__c, DOA_Discount_percent__c, Email, ExpirationDate, Fax, Grace_Period__c, Grace_Period_Period__c, Grace_Period_Mechanism__c,
                       GrandTotal, Integration_Status__c, Lease_End_Date__c, Lease_Start_Date__c, Legal_Terms_Changed__c, Level_1_Approver__c, Level_2_Approver__c,
                       Level_3_Approver__c, Level_4_Approver__c, Level_5_Approver__c, Level_6_Approver__c, LineItemCount, Manually_submitted__c, Number_Of_Payments__c,
                       OpportunityId, Opportunity_Type__c, Name, QuoteNumber, RecordTypeId, IsSyncing, Type__c, Unit_Sub_Category__c
               FROM Quote WHERE OpportunityId = :opportunityId];
        //System.debug('quoteList============='+quoteList[0]);
        
      
        return quoteObject;
    }
    
    @AuraEnabled
     public static List<QuoteLineItem> getQuoteLineItemRecord(Id quoteId){
         quoteLineItemList = [SELECT Id, ListPrice, QuoteId, Offer_Price__c, Product2Id, End_Date__c, Quantity,PricebookEntryId, UnitPrice FROM QuoteLineItem WHERE QuoteId = :quoteId];
         System.debug('quoteLineItemList============='+quoteLineItemList);
         List<QuoteLineItem> childQuoteLineItemList = quoteLineItemList.deepClone();
         insert childQuoteLineItemList;
         return quoteLineItemList;
     }
    
    @AuraEnabled
     public static List<QuoteLineItem> getRemovedQuoteLineItemList(String qLIId){
         Type idArrayType = Type.forName('List<String>');
         List<String> wrapperList = (List<String>) JSON.deserialize(qLIId, idArrayType);
         quoteLineItemList = [SELECT Id, ListPrice, QuoteId, Offer_Price__c, Product2Id, End_Date__c FROM QuoteLineItem WHERE Id IN :wrapperList];
         System.debug('quoteLineItemList============='+quoteLineItemList);
         return quoteLineItemList;
     }
}