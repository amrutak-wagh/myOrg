/************************************************************************************
* Name          : ExpansionController                                                 
* Description   : Controller class for Expansion lightning component
* Created Date  : 20/08/2019                                                   
* Created By    : Adeel Ahmad (adeel.ahmad@weare4c.com)
* Jira/Req By   :                                                                                                                                           
* -----------------------------------------------------------------------------------------------------------------------
* VERSION   Developer   Date        Description     Ticket/Reference    
************************************************************************************/
public class ExpansionController {
    
    /************************************************************************************
    Method      :   getQuoteRecord
    Description :   Method to get quote record associated to opportunity.
    Params      :   OpportunityId
    Created Date:   20/08/2019
    *************************************************************************************
    */
    @AuraEnabled
    public static Quote getQuoteRecord(String recordId){
        Quote q = new Quote();
        LIST<Quote> quotes = [SELECT Id FROM Quote WHERE OpportunityId = :recordId AND IsSyncing = TRUE LIMIT 1];
        if(quotes.size() > 0){
            q = quotes[0];
        }
        return q;
    }
    
    /************************************************************************************
    Method      :   getBuildingInfo
    Description :   Method to get building information from opportunity.
    Params      :   OpportunityId
    Created Date:   20/08/2019
    *************************************************************************************
    */
    @AuraEnabled
    public static LIST<BuildingOptions> fetchBuildingInfo(String recordId){
        String buildingCode = [SELECT Id,Building_Name__c FROM Opportunity WHERE Id=:recordId].Building_Name__c;
        List<BuildingOptions> options = new LIST<BuildingOptions>();
        for(Building__c b : [SELECT id,Name FROM Building__c WHERE Building_Code__c =:buildingCode]){
            options.add(new BuildingOptions(b.Name, String.valueOf(b.Id)));
        }
        return options;
    }
    
    /************************************************************************************
    Method      :   fetchPageLayouts
    Description :   This method will get the layouts both at once as getting individual increases loading time.
    Params      :   
    Created Date:   20/08/2019
    Updates     :   Remove the page layouts as we no longer needs the layout to show information.
    *************************************************************************************
    */
    @AuraEnabled
    public static PageLayoutWrapper fetchPageLayouts(String recordId, String quoteId){
        PageLayoutWrapper wrapper = new PageLayoutWrapper();
        wrapper.oppInfo = [SELECT Id,Name,Lease_Start_Date__c,Lease_End_Date__c,Expansion_Separate_Amendment_Terms__c  FROM Opportunity WHERE Id=:recordId];
        wrapper.quotelineItems = fetchQuoteLineItems(quoteId);
        return wrapper;
    }
    
    /************************************************************************************
    Method      :   fetchQuoteLineItems
    Description :   It will return quote line items associated to the quote record of opportunity.
    Params      :   QuoteId
    Created Date:   20/08/2019
    *************************************************************************************
    */
    @AuraEnabled
    public static LIST<QuoteLineItem> fetchQuoteLineItems(String quoteId){
        LIST<QuoteLineItem> qli = [SELECT Id,Product2.Name,Quantity, UnitPrice,TotalPrice, 
                                   Product2.Unit__r.Id
                                   FROM QuoteLineItem 
                                   WHERE QuoteId = :quoteId AND PriceSch_ChargeType__c = 'Rent'];
        return qli; 
    }
    
    /************************************************************************************
    Method      :   save
    Description :   Method to clone opportunity/quote/quotelineitems for downsizing.
    Params      :   opportunityId, terminationDate, removeableQuoteLineItems
    Created Date:   20/08/2019
    *************************************************************************************
    */
    @AuraEnabled
    public static String save(String opportunityId, LIST<LineItem> lineItems, Opportunity oppInfo){
        String returnStr = '';
        try{
            Opportunity parentOpportunity = [SELECT Id, AccountId, Amendment_Id__c, Amount, Budget_Confirmed__c, Building_Name__c, Business_Park__c,
                                                       CloseDate, Contact__c, ContactId, ContractId, CurrentGenerators__c, DeliveryInstallationStatus__c, Description,
                                                       Discovery_Completed__c, ForecastCategoryName, Framework_Detail__c, HSE_Clearance_Date__c,
                                                       HSE_Notes__c, HSE_Status__c, Is_renewal__c, LeadSource, Lease_End_Date__c, Lease_Start_Date__c, Lease_Type__c,
                                                       Legal_Framework__c, License_Type__c, Loss_Reason__c, MainCompetitors__c, NextStep, CurrencyIsoCode, Name,
                                                       Opportunity_Type__c, OrderNumber__c, Pricebook2Id, CampaignId, IsPrivate, Probability, 
                                                       Proposed_Booking_Expiry_Extension__c, TotalOpportunityQuantity, Retail_Sales_Category__c, ROI_Analysis_Completed__c,
                                                       Segment__c, Soft_Booking_Extension_Submitted__c, StageName, T_Code__c, TrackingNumber__c, 
                                                       Yardi_Integration_Error_Message__c, Yardi_Integration_Status__c, Yardi_Lease_Status__c 
                                               FROM Opportunity WHERE Id = :opportunityId];
            
            Opportunity childOpportunity = parentOpportunity.clone(false, true, false, false);
            childOpportunity.StageName = 'New';
            childOpportunity.Sub_Type__c = 'Expansion';
            childOpportunity.Type = 'Amendment';
            childOpportunity.Parent_Opportunity__c = parentOpportunity.Id;
            childOpportunity.Lease_Start_Date__c = oppInfo.Lease_Start_Date__c;
            childOpportunity.Amendment_Id__c = null;
            childOpportunity.Parent_Amendment_Id__c = parentOpportunity.Amendment_Id__c;
            childOpportunity.T_Code__c = parentOpportunity.T_Code__c;
            childOpportunity.Expansion_Separate_Amendment_Terms__c = oppInfo.Expansion_Separate_Amendment_Terms__c;
            childOpportunity.Is_Created_From_Component__c = true;
            insert childOpportunity;
            
            Opportunity childOpp = [SELECT Id,Lease_Start_Date__c,Lease_End_Date__c FROM Opportunity where id =:childOpportunity.Id];
                        
            //Quote Object
            Quote parentOpportunityQuote = [SELECT Id, AccountId, AdditionalAddress, AdditionalName, BillingAddress, BillingName, Booking_expiry_Date__c, Building__c, Cancellation_Reason__c,
                       Category__c, CCL_Sign_Date__c, ContactId, ContractId, Description, Discount__c, Discount, Discount_Percentage__c, DOA_Approver__c, 
                       DOA_Discount__c, DOA_Discount_percent__c, Email, ExpirationDate, Fax, Grace_Period__c, Grace_Period_Period__c, Grace_Period_Mechanism__c,
                       GrandTotal, Integration_Status__c, Lease_End_Date__c, Lease_Start_Date__c, Legal_Terms_Changed__c, Level_1_Approver__c, Level_2_Approver__c,
                       Level_3_Approver__c, Level_4_Approver__c, Level_5_Approver__c, Level_6_Approver__c, LineItemCount, Manually_submitted__c, Number_Of_Payments__c,
                       OpportunityId, Opportunity_Type__c, Name, QuoteNumber,  Pricebook2Id, IsSyncing, Type__c, Unit_Sub_Category__c,Proposed_Start_Date__c,Proposed_End_Date__c,
						Payment_Terms__c                                             
               FROM Quote WHERE OpportunityId = :opportunityId AND IsSyncing = TRUE];
            
            Quote childQuoteObject = parentOpportunityQuote.clone(false, true);
            childQuoteObject.OpportunityId = childOpportunity.Id;
            childQuoteObject.Previous_Quote__c = parentOpportunityQuote.Id;
            childQuoteObject.Proposed_Start_Date__c = childOpp.Lease_Start_Date__c;
            childQuoteObject.Proposed_End_Date__c = childOpp.Lease_End_Date__c;
            insert childQuoteObject;
			
            LIST<QuoteLineItem> insertableQuoteLineItems = new LIST<QuoteLineItem>();
            //Populating new quoteId on lineItems
            for(LineItem li : lineItems){
                QuoteLineItem qli = li.quoteLineItem;
                System.debug('@@lineItems='+qli);
                qli.QuoteId = childQuoteObject.Id;
                qli.Transaction_Type__c  = 'New';
                insertableQuoteLineItems.add(qli);
            }
            insert insertableQuoteLineItems;
            
            LIST<QuoteLineItem> insertableQuoteLineItemChargesList = new LIST<QuoteLineItem>();
            for(Integer i = 0; i < insertableQuoteLineItems.size(); i++) {
                lineItems[i].quoteLineItem.Id = insertableQuoteLineItems[i].Id;
                for(QuoteLineItem obj : lineItems[i].chargesRelatedQLIList) {
                    obj.Parent_Quote_Line_Item__c = insertableQuoteLineItems[i].Id;
                    obj.QuoteId = childQuoteObject.Id;
                }
                insertableQuoteLineItemChargesList.addAll(lineItems[i].chargesRelatedQLIList);
            }
            
            if(insertableQuoteLineItemChargesList.size() > 0){
	            insert insertableQuoteLineItemChargesList;                
            }
            returnStr = 'SUCCESS';
        }catch(Exception e){
            returnStr = e.getMessage();
            System.debug('@@returnStr='+returnStr);
        }
        return returnStr;
    }
    
    /************************************************************************************
    class       :   PageLayoutWrapper
    Description :   Wrapper class to get both page layouts which is quote, opportunity.
    Params      :   
    Created Date:   20/08/2019
    *************************************************************************************
    */
    public class PageLayoutWrapper{
        @AuraEnabled Opportunity oppInfo {get; set;}
        @AuraEnabled LIST<QuoteLineItem> quotelineItems {get; set;}
    }
        
    public class BuildingOptions{
        @AuraEnabled public String label {get; set;}
        @AuraEnabled public String value {get; set;}
        
        public BuildingOptions(String label, String value){
            this.label = label;
            this.value = value;
        }
    }
    
    /*Wrapper of Unit name and QLI returned when add is clicked from UI*/
    public class LineItem {
        @AuraEnabled public String unitName {get; set;}
        @AuraEnabled public String unitId {get; set;}
        @AuraEnabled public QuoteLineItem quoteLineItem {get; set;}
        @AuraEnabled public PricingEngine.PricingPackage pricingPackage {get; set;}
        @AuraEnabled public String subCategory {get;set;}
        @AuraEnabled public List<QuoteLineItem> chargesRelatedQLIList {get; set;}
        @AuraEnabled public Integer changedOfferedRate {get; set;}
    }
    
}