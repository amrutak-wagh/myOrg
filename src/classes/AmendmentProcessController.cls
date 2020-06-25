/************************************************************************************
* Name          : AmendmentProcessController                                                 
* Description   : Controller of AmendmentProcess.cmp
* Created Date  :                                                    
* Created By    : 4C - Shraddha N (shraddha.naik@weare4c.com)
* Jira/Req By   :                                                                                                                                           
* -----------------------------------------------------------------------------------------------------------------------
* VERSION   Developer   Date        Description     Ticket/Reference    
	1
************************************************************************************/
public class AmendmentProcessController {
    public static List<Opportunity> opportunityList = new List<Opportunity>();
    public static List<Quote> quoteList = new List<Quote>();
    public static List<QuoteLineItem> quoteLineItemList = new List<QuoteLineItem>();
    
    /**Create child Opportunity, Quote reelated to child opportunity and QLIs**/
    @AuraEnabled
    public static Opportunity createChildOpportunity(Id opportunityId){
        System.debug('opportunityId------ ' + opportunityId);
        //Fetch Opportunity record.
        Opportunity parentOpportunityObject = [SELECT Id, AccountId, Amendment_Id__c, Amount, Budget_Confirmed__c, Building_Name__c, Business_Park__c,
                                                       CloseDate, Contact__c, ContactId, ContractId, CurrentGenerators__c, DeliveryInstallationStatus__c, Description,
                                                       Discovery_Completed__c, ForecastCategoryName, Framework_Detail__c, HSE_Clearance_Date__c,
                                                       HSE_Notes__c, HSE_Status__c, Is_renewal__c, LeadSource, Lease_End_Date__c, Lease_Start_Date__c, Lease_Type__c,
                                                       Legal_Framework__c, License_Type__c, Loss_Reason__c, MainCompetitors__c, NextStep, CurrencyIsoCode, Name,
                                                       Opportunity_Type__c, OrderNumber__c, Pricebook2Id, CampaignId, IsPrivate, Probability, 
                                                       Proposed_Booking_Expiry_Extension__c, TotalOpportunityQuantity, Retail_Sales_Category__c, ROI_Analysis_Completed__c,
                                                       Segment__c, Soft_Booking_Extension_Submitted__c, StageName, T_Code__c, TrackingNumber__c, 
                                                       Yardi_Integration_Error_Message__c, Yardi_Integration_Status__c, Yardi_Lease_Status__c 
                                               FROM Opportunity WHERE Id = :opportunityId];
        
        System.debug('parentOpportunityObject------ ' + parentOpportunityObject);
        //create child opportunity record with type = Amendment and Subtype = Downsize
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
                                                             Name = parentOpportunityObject.Name,
                                                             Opportunity_Type__c = parentOpportunityObject.Opportunity_Type__c,
                                                             OrderNumber__c = parentOpportunityObject.OrderNumber__c,
                                                             Parent_Amendment_Id__c = parentOpportunityObject.Amendment_Id__c,
                                                             Parent_Opportunity__c = opportunityId,
                                                             Pricebook2Id = parentOpportunityObject.Pricebook2Id,
                                                             CampaignId = parentOpportunityObject.CampaignId,
                                                             IsPrivate = parentOpportunityObject.IsPrivate,
                                                             Probability = parentOpportunityObject.Probability,
                                                             Proposed_Booking_Expiry_Extension__c = parentOpportunityObject.Proposed_Booking_Expiry_Extension__c,
                                                             Retail_Sales_Category__c = parentOpportunityObject.Retail_Sales_Category__c,
                                                             ROI_Analysis_Completed__c = parentOpportunityObject.ROI_Analysis_Completed__c,
                                                             Segment__c = parentOpportunityObject.Segment__c,
                                                             Soft_Booking_Extension_Submitted__c = parentOpportunityObject.Soft_Booking_Extension_Submitted__c,
                                                             StageName = 'New', //parentOpportunityObject.StageName
                                                             Sub_Type__c = 'Downsize',
                                                             T_Code__c = parentOpportunityObject.T_Code__c,
                                                             TrackingNumber__c = parentOpportunityObject.TrackingNumber__c,
                                                             Type = 'Amendment',
                                                             Yardi_Integration_Error_Message__c = parentOpportunityObject.Yardi_Integration_Error_Message__c,
                                                             Yardi_Integration_Status__c = parentOpportunityObject.Yardi_Integration_Status__c,
                                                             Yardi_Lease_Status__c = parentOpportunityObject.Yardi_Lease_Status__c);
        insert chidlOpportunityObject;
        System.debug('chidlOpportunityObject---------' + chidlOpportunityObject);
        
        //Fetch Synced Quote record related to parent opportunity 
        Quote quoteObject = [SELECT Id, AccountId, AdditionalAddress, AdditionalName, BillingAddress, BillingName, Booking_expiry_Date__c, Building__c, Cancellation_Reason__c,
                       Category__c, CCL_Sign_Date__c, ContactId, ContractId, Description, Discount__c, Discount, Discount_Percentage__c, DOA_Approver__c, 
                       DOA_Discount__c, DOA_Discount_percent__c, Email, ExpirationDate, Fax, Grace_Period__c, Grace_Period_Period__c, Grace_Period_Mechanism__c,
                       GrandTotal, Integration_Status__c, Lease_End_Date__c, Lease_Start_Date__c, Legal_Terms_Changed__c, Level_1_Approver__c, Level_2_Approver__c,
                       Level_3_Approver__c, Level_4_Approver__c, Level_5_Approver__c, Level_6_Approver__c, LineItemCount, Manually_submitted__c, Number_Of_Payments__c,
                       OpportunityId, Opportunity_Type__c, Name, QuoteNumber,  Pricebook2Id, IsSyncing, Type__c, Unit_Sub_Category__c,Proposed_Start_Date__c,Proposed_End_Date__c
               FROM Quote WHERE OpportunityId = :opportunityId AND IsSyncing = TRUE];
        
        //clone quote record and assigned to child opportunity
       if(quoteObject != null){
            Quote childQuoteObject = quoteObject.clone(false,true);
            childQuoteObject.OpportunityId = chidlOpportunityObject.Id;
        
            insert childQuoteObject;
        
        
       
            //Fetch QLI record related to Quote which is related to parent Opportunity
            
            quoteLineItemList = [SELECT Id, ListPrice, QuoteId, Offer_Price__c, Product2Id, Quantity, End_Date__c, UnitPrice,PriceBookEntryId
                                 FROM QuoteLineItem WHERE QuoteId = :quoteObject.Id];
            System.debug('quoteLineItemList============='+quoteLineItemList);
            
            //clone all the QLI records and assigned to Quote record which is related to child opportunity
            List<QuoteLineItem> childQuoteLineItemList = quoteLineItemList.deepClone();
           
            for(QuoteLineItem qliObj : childQuoteLineItemList){
                qliObj.QuoteId = childQuoteObject.Id;
                qliObj.Quantity = 1000;
               /* String quantity = String.valueOf(qliObj.Quantity);
                if(quantity.isNumeric() && quantity.length() < 9 && quantity.containsNone('.')){
                    qliObj.Quantity = qliObj.Quantity;
                } else{
                    qliObj.Quantity = 1000;
                }*/
            }
            insert childQuoteLineItemList;
       }      
        
       return chidlOpportunityObject;
    }
    
    /**Fetch Page Layout of current Page**/
    @AuraEnabled
    public static PageLayout getPageLayoutMetadata(String pageLayoutName) {
        System.debug('pageLayoutName---' + pageLayoutName);
        List<String> componentNameList = new List<String>{pageLayoutName};
		
        if (String.isBlank(pageLayoutName)) {
            return new PageLayout();
        }

        List<Metadata.Metadata> layouts =  
            Metadata.Operations.retrieve(Metadata.MetadataType.Layout, componentNameList);
        System.debug('layouts----' + layouts);

        if (layouts.size() == 1) {
            return new PageLayout((Metadata.Layout) layouts[0]);
        }

        return new PageLayout();
    }

    
    @AuraEnabled
    public static Opportunity getChildOpportunityRecord(Id opportunityId){
       	//Fetch child opportunity record
        Opportunity opportunityObject = [SELECT Id, Parent_Opportunity__c, AccountId, Amendment_Id__c, Amount, Budget_Confirmed__c, Building_Name__c, Business_Park__c, Sub_Type__c, Type,
                                                       CloseDate, Contact__c, ContactId, ContractId, CurrentGenerators__c, DeliveryInstallationStatus__c, Description,
                                                       Discovery_Completed__c, ForecastCategoryName, Framework_Detail__c, HSE_Clearance_Date__c,
                                                       HSE_Notes__c, HSE_Status__c, Is_renewal__c, LeadSource, Lease_End_Date__c, Lease_Start_Date__c, Lease_Type__c,
                                                       Legal_Framework__c, License_Type__c, Loss_Reason__c, MainCompetitors__c, NextStep, CurrencyIsoCode, Name,
                                                       Opportunity_Type__c, OrderNumber__c, Pricebook2Id, CampaignId, IsPrivate, Probability, 
                                                       Proposed_Booking_Expiry_Extension__c, TotalOpportunityQuantity, Retail_Sales_Category__c, ROI_Analysis_Completed__c,
                                                       Segment__c, Soft_Booking_Extension_Submitted__c, StageName, T_Code__c, TrackingNumber__c, 
                                                       Yardi_Integration_Error_Message__c, Yardi_Integration_Status__c, Yardi_Lease_Status__c 
                                               FROM Opportunity WHERE Id = :opportunityId AND Sub_Type__c = 'Downsize' AND Type = 'Amendment'
                           ORDER BY Id DESC LIMIT 1];
         System.debug('opp--------'+ opportunityObject.Parent_Opportunity__c);
        
      
        return opportunityObject;
    }
    
     @AuraEnabled
    public static Quote getQuoteRecord(Id opportunityId){     
        //Fetch Quote record which is related to child opportunity
        Quote quoteObject = [SELECT Id, AccountId, AdditionalAddress, AdditionalName, BillingAddress, BillingName, Booking_expiry_Date__c, Building__c, Cancellation_Reason__c,
                       Category__c, CCL_Sign_Date__c, ContactId, ContractId, Description, Discount__c, Discount, Discount_Percentage__c, DOA_Approver__c, 
                       DOA_Discount__c, DOA_Discount_percent__c, Email, ExpirationDate, Fax, Grace_Period__c, Grace_Period_Period__c, Grace_Period_Mechanism__c,
                       GrandTotal, Integration_Status__c, Lease_End_Date__c, Lease_Start_Date__c, Legal_Terms_Changed__c, Level_1_Approver__c, Level_2_Approver__c,
                       Level_3_Approver__c, Level_4_Approver__c, Level_5_Approver__c, Level_6_Approver__c, LineItemCount, Manually_submitted__c, Number_Of_Payments__c,
                       OpportunityId, Opportunity_Type__c, Name, QuoteNumber, IsSyncing, Type__c, Pricebook2Id, Unit_Sub_Category__c, Termination_Date__c, Phone, Pre_Approval_Allowed__c,
                       Previous_Quote__c, Product_Code__c,Price_List_Number_Of_Payments__c, Proposed_Booking_Expiry_Extension__c, Proposed_Booking_Expiry_Ext_Date__c,
                       Proposed_End_Date__c, Proposed_Grace_Period__c, Proposed_Grace_Period_Months__c, Proposed_Start_Date__c, Quote_Approved_Via_Approval__c, Sales_Type__c,
                       ShippingAddress, ShippingName, ShippingHandling, Soft_Book__c, Soft_Booking_Date_Time__c, Soft_Booking_Extension_Submitted__c, Status, Subtotal,
                       Tax, Total_Best_Rate_Roll_Up_Summary__c, Total_Best_Rate_for_Proposed_GP__c, Total_Charge_Price__c, Total_Discount__c, Total_Discount_percent__c, 
                       Total_Negative_GP_Discount_Amount__c, Total_Offer_Price__c, Total_Offered_Price_Roll_Up_Summary__c, TotalPrice, Total_Quote_Amount__c, 
                       Total_Best_Rate__c, Total_Upselling_Discount_Amount__c, TurnOver_Rent__c, Yardi_Brand_Code__c, Yardi_Customer_Code__c, Yardi_Integration_Error_Message__c,
                       Yardi_Integration_Status__c
               FROM Quote WHERE OpportunityId = :opportunityId LIMIT 1];
       
        
      
        return quoteObject;
    }
    @AuraEnabled
    public static Quote updateQuoteRecord(Id opportunityId, String terminationDate){
        System.debug('terminationDate-----------> ' + Date.valueOf(terminationDate));
        //Fetch Quote record which is related to child opportunity
        Quote quoteObject = [SELECT Id FROM Quote WHERE OpportunityId = :opportunityId LIMIT 1];
       
        quoteObject.Termination_Date__c = Date.valueOf(terminationDate) ;
        update quoteObject;
        return quoteObject;
    }
    
    @AuraEnabled
     public static List<QuoteLineItem> getQuoteLineItemRecord(Id quoteId){
         //Fetch QLI record related to Quote which is related to child Opportunity
         quoteLineItemList = [SELECT Id, ListPrice, QuoteId, Offer_Price__c, Product2Id,Product2.Name, End_Date__c FROM QuoteLineItem WHERE QuoteId = :quoteId];
         System.debug('quoteLineItemList============='+quoteLineItemList);
         
         return quoteLineItemList;
     }
    
    
    @AuraEnabled
     public static List<QuoteLineItem> getRemovedQuoteLineItemList(List<Id> qLIId){
         System.debug('qLIId============='+qLIId);
         List<QuoteLineItem> toRemoveQLI = new List<QuoteLineItem>();
         //fetch all removed QLI records
         quoteLineItemList = [SELECT Id, ListPrice, QuoteId, Offer_Price__c, Product2.Name, End_Date__c, Quote.Termination_Date__c FROM QuoteLineItem WHERE Id IN :qLIId];
         System.debug('RemovedquoteLineItemList============='+quoteLineItemList);
         toRemoveQLI.addAll(quoteLineItemList);
          System.debug('toRemoveQLI============='+toRemoveQLI);
         delete toRemoveQLI;
         return quoteLineItemList;
     }
    
    /* Added by adeel, method to remove the Selected QuoteLine Items 
    *  Passed the list of quotes separated by comma */
    @AuraEnabled
    public static String removeSelectedQuoteLineItems(String selectedQuoteLineItems){
        String returnStr = '';
        LIST<String> selectedLineItems = selectedQuoteLineItems.split(',');
        if(selectedLineItems.size() > 0){
            LIST<QuoteLineItem> qlItems = [SELECT Id FROM QuoteLineItem WHERE Id IN:selectedLineItems];
            try{
                delete qlItems;
                returnStr = 'SUCCESS';
            }catch(Exception e){
                System.debug('@@e='+e);
                returnStr = e.getMessage();
            }
        }
        return returnStr;
    }
    
    /* Added by adeel, method to identify quote records associated to opportunity */
    @AuraEnabled
    public static Decimal getQuoteRecords(String recordId){
        LIST<Quote> quotes = [SELECT Id FROM Quote WHERE OpportunityId = :recordId AND IsSyncing = TRUE];
        return quotes.size();
    }
    
    public class PageLayout {
        @AuraEnabled
        public List<PageLayoutSection> Sections { get; set; }

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

    public class PageLayoutSection {
        @AuraEnabled
        public List<PageLayoutSectionColumn> Columns { get; set; }

        @AuraEnabled
        public String Label { get; set; }

        public PageLayoutSection(Metadata.LayoutSection section) {
            Columns = new List<PageLayoutSectionColumn>();

            Label = section.label;
            
            for (Metadata.LayoutColumn column : section.layoutColumns) {
                Columns.add(new PageLayoutSectionColumn(column));
            }
        }
    }

    public class PageLayoutSectionColumn {
        @AuraEnabled
        public List<PageLayoutField> Fields { get; set; }

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
    
    public class PageLayoutField {
        @AuraEnabled
        public String APIName { get; set; }

        public PageLayoutField(Metadata.LayoutItem item) {
            APIName = item.field;
        }
    }

    
    
   /* public class FieldSetObjectWrapper{
        @AuraEnabled
        public List<Opportunity> opportunityDetailsFieldList{get;set;}
        @AuraEnabled
        public List<Opportunity> leaseDetailsFieldList{get;set;}
        @AuraEnabled
        public List<Opportunity> systemDetailsFieldList{get;set;}
        @AuraEnabled
        public List<Opportunity> integrationDetailsFieldList{get;set;}
        
        @AuraEnabled
        public List<String> mandatoryQuoteInformationFieldList{get;set;}
        @AuraEnabled
        public List<String> quoteInformationFieldList{get;set;}
        @AuraEnabled
        public List<String> pricesAndDatesFieldList{get;set;}
        @AuraEnabled
        public List<String> discountsFieldList{get;set;}
        
        public FieldSetObjectWrapper(){
            opportunityDetailsFieldList = new List<Opportunity>();
            leaseDetailsFieldList = new List<Opportunity>();
            systemDetailsFieldList = new List<Opportunity>();
            integrationDetailsFieldList = new List<Opportunity>();
            
            mandatoryQuoteInformationFieldList = new List<String>();
            quoteInformationFieldList = new List<String>();
            pricesAndDatesFieldList = new List<String>();
            discountsFieldList = new List<String>();
        }
        
    }*/
}