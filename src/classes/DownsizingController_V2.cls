/************************************************************************************
* Name          : DownsizingController_V2                                                 
* Description   : Controller class for Downsizing lightning component
* Created Date  : 19/08/2019                                                   
* Created By    : Adeel Ahmad (adeel.ahmad@weare4c.com)
* Jira/Req By   :                                                                                                                                           
* -----------------------------------------------------------------------------------------------------------------------
* VERSION   Developer   Date        Description     Ticket/Reference    
************************************************************************************/
public class DownsizingController_V2 {
    
    /************************************************************************************
    Method      :   getQuoteRecord
    Description :   Method to get quote record associated to opportunity.
    Params      :   OpportunityId
    Created Date:   19/08/2019
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
    Method      :   fetchPageLayouts
    Description :   This method will get the layouts both at once as getting individual increases loading time.
    Params      :   
    Created Date:   19/08/2019
    *************************************************************************************
    */
	@AuraEnabled
    public static PageLayoutWrapper fetchPageLayouts(){
        PageLayoutWrapper wrapper = new PageLayoutWrapper();
        List<String> componentNameList = new List<String>{'Opportunity-Opportunity Layout', 'Quote-Quote Layout'};
		List<Metadata.Metadata> layouts = Metadata.Operations.retrieve(Metadata.MetadataType.Layout, componentNameList);
        wrapper.opportunityLayout = new PageLayout((Metadata.Layout) layouts[0]);
        wrapper.quoteLayout = new PageLayout((Metadata.Layout) layouts[1]);
        return wrapper;
    }
    
    /************************************************************************************
    Method      :   fetchQuoteLineItems
    Description :   It will return quote line items associated to the quote record of opportunity.
    Params      :   QuoteId
    Created Date:   19/08/2019
    *************************************************************************************
    */
    @AuraEnabled
    public static LIST<QuoteLineItem> fetchQuoteLineItems(String quoteId){
        LIST<QuoteLineItem> qli = [SELECT Id,Product2.Name,Quantity, UnitPrice,TotalPrice 
                                   FROM QuoteLineItem 
                                   WHERE QuoteId = :quoteId AND PriceSch_ChargeType__c = 'Rent'];
        return qli; 
    }
    
    /************************************************************************************
    Method      :   save
    Description :   Method to clone opportunity/quote/quotelineitems for downsizing.
    Params      :   opportunityId, terminationDate, removeableQuoteLineItems
    Created Date:   19/08/2019
    *************************************************************************************
    */
    @AuraEnabled
    public static String save(String opportunityId, String terminationDate, String removeableQuoteLineItems){
        String returnStr = '';
        LIST<String> removeableQLI = removeableQuoteLineItems.split(',');
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
            childOpportunity.Sub_Type__c = 'Downsize';
            childOpportunity.Type = 'Amendment';
            childOpportunity.Lease_Start_Date__c = Date.valueOf(terminationDate);
            childOpportunity.Lease_End_Date__c = parentOpportunity.Lease_End_Date__c;
            childOpportunity.Parent_Opportunity__c = parentOpportunity.Id;
            insert childOpportunity;
			            
            //Quote Object
            Quote parentOpportunityQuote = [SELECT Id, AccountId, AdditionalAddress, AdditionalName, BillingAddress, BillingName, Booking_expiry_Date__c, Building__c, Cancellation_Reason__c,
                       Category__c, CCL_Sign_Date__c, ContactId, ContractId, Description, Discount__c, Discount, Discount_Percentage__c, DOA_Approver__c, 
                       DOA_Discount__c, DOA_Discount_percent__c, Email, ExpirationDate, Fax, Grace_Period__c, Grace_Period_Period__c, Grace_Period_Mechanism__c,
                       GrandTotal, Integration_Status__c, Lease_End_Date__c, Lease_Start_Date__c, Legal_Terms_Changed__c, Level_1_Approver__c, Level_2_Approver__c,
                       Level_3_Approver__c, Level_4_Approver__c, Level_5_Approver__c, Level_6_Approver__c, LineItemCount, Manually_submitted__c, Number_Of_Payments__c,
                       OpportunityId, Opportunity_Type__c, Name, QuoteNumber,  Pricebook2Id, IsSyncing, Type__c, Unit_Sub_Category__c,Proposed_Start_Date__c,Proposed_End_Date__c
               FROM Quote WHERE OpportunityId = :opportunityId AND IsSyncing = TRUE];
            
            Quote childQuoteObject = parentOpportunityQuote.clone(false, true);
            childQuoteObject.OpportunityId = childOpportunity.Id;
            childQuoteObject.Termination_Date__c = Date.valueOf(terminationDate);
            childQuoteObject.Previous_Quote__c = parentOpportunityQuote.Id;
            insert childQuoteObject;
            
            LIST<QuoteLineItem> quoteLineItemList = [SELECT Id, ListPrice, 
                                                     QuoteId, Offer_Price__c, Product2Id, Quantity, End_Date__c, UnitPrice,PriceBookEntryId,
                                                     Transaction_Type__c, Start_Date__c, Transactional_Unit__c, Area__c 
                                                     FROM QuoteLineItem WHERE QuoteId = :parentOpportunityQuote.Id 
                                                     AND Id NOT IN:removeableQLI 
                                                     AND PriceSch_ChargeType__c = 'Rent'
                                                   ];
            LIST<QuoteLineItem> insertableQuoteLineItems = new List<QuoteLineItem>();
            for(QuoteLineItem qli : quoteLineItemList){
                QuoteLineItem newQLI = new QuoteLineItem();
                newQLI.UnitPrice = qli.UnitPrice;
                newQLI.QuoteId =  childQuoteObject.Id;
                newQLI.Transaction_Type__c = qli.Transaction_Type__c;//'New'; 
                newQLI.Start_Date__c = qli.Start_Date__c;
                newQLI.End_Date__c = qli.End_Date__c;
                newQLI.Quantity = qli.Quantity;
                newQLI.Product2Id = qli.Product2Id;
                newQLI.PricebookEntryId = qli.PricebookEntryId;
                newQLI.Transactional_Unit__c = qli.Transactional_Unit__c;
                newQLI.Area__c = qli.Area__c;
                insertableQuoteLineItems.add(newQLI);
            } 

            if(insertableQuoteLineItems.size() > 0){ 
                insert insertableQuoteLineItems; 
            }
            
            Case cs = new Case();
            cs.RecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType='Case' and DeveloperName='Lease_Termination' LIMIT 1].Id;
            cs.Type = 'Termination';
            cs.Sub_Type__c = 'Termination with Downsize';
            cs.Opportunity__c = parentOpportunity.Id;
            insert cs;

            returnStr = 'SUCCESS';
        }catch(Exception e){
            returnStr = e.getMessage();
        }
        return returnStr;
    }
    
    /************************************************************************************
    class       :   PageLayoutWrapper
    Description :   Wrapper class to get both page layouts which is quote, opportunity.
    Params      :   
    Created Date:   19/08/2019
    *************************************************************************************
    */
    public class PageLayoutWrapper{
        @AuraEnabled PageLayout quoteLayout {get; set;}
        @AuraEnabled PageLayout opportunityLayout {get; set;}
    }
    
    /************************************************************************************
    class       :   PageLayout
    Description :   Wrapper class for page layout
    Params      :   
    Created Date:   19/08/2019
    *************************************************************************************
    */
    public class PageLayout {
        @AuraEnabled public List<PageLayoutSection> Sections { get; set; }
        public PageLayout() {
            Sections = new List<PageLayoutSection>();
        }
        
        public PageLayout(Metadata.Layout layout) {
            this();
            for (Metadata.LayoutSection section : layout.layoutSections) {
                if (section.style != Metadata.LayoutSectionStyle.CustomLinks) {
                    Sections.add(new PageLayoutSection(section));
                }
            }
        }
    }

    /************************************************************************************
    class       :   PageLayoutSection
    Description :   Wrapper class for page layout sections
    Params      :   
    Created Date:   19/08/2019
    *************************************************************************************
    */
    public class PageLayoutSection {
        @AuraEnabled public List<PageLayoutSectionColumn> Columns { get; set; }
        @AuraEnabled public String Label { get; set; }

        public PageLayoutSection(Metadata.LayoutSection section) {
            Columns = new List<PageLayoutSectionColumn>();
            Label = section.label;
            for (Metadata.LayoutColumn column : section.layoutColumns) {
                Columns.add(new PageLayoutSectionColumn(column));
            }
        }
    }

    /************************************************************************************
    class       :   PageLayoutSectionColumn
    Description :   Wrapper class for page layout sections columns
    Params      :   
    Created Date:   19/08/2019
    *************************************************************************************
    */
    public class PageLayoutSectionColumn {
        @AuraEnabled public List<PageLayoutField> Fields { get; set; }
        public PageLayoutSectionColumn(Metadata.LayoutColumn column) {
            Fields = new List<PageLayoutField>();
            if (column.layoutItems == null) {
                return;
            }
            for (Metadata.LayoutItem item : column.layoutItems) {
                Fields.add(new PageLayoutField(item));
            }
        }
    }
    
    /************************************************************************************
    class       :   PageLayoutField
    Description :   Wrapper class for page layout fields
    Params      :   
    Created Date:   19/08/2019
    *************************************************************************************
    */
    public class PageLayoutField {
        @AuraEnabled public String APIName { get; set; }
        public PageLayoutField(Metadata.LayoutItem item) {
            APIName = item.field;
        }
    }
    
}