/*
 * Created by : Raza Khan (raza.khan@weare4c.com)
 * Description: This utility is for containing all logic related to DOA Process.
 * Dated: 09/07/2019
 * 
 * 
 * */
public with sharing class DOAUtils {

    private static Map<Id, Quote> cachedQuotesByIds = new Map<Id, Quote>();

       /*
        * Method : isApproverPopulationRequired
        * Description: This method is validating whether the update made on the quote should trigger the DOA 
        * Approvers population logic 
        * 
        * */
    public static void isApproverPopulationRequired(Map<Id,Quote> oldMap,Map<Id,Quote> newMap)
    {
        Set<Id> updatedQuotes = new Set<Id>();
        
        for(Quote q: newMap.values())
        {
            if (q.IsSyncing != true && q.status == 'Draft' &&
                (q.Proposed_Grace_Period__c!=oldMap.get(q.Id).Proposed_Grace_Period__c
                 || q.Proposed_Grace_Period_Months__c!=oldMap.get(q.Id).Proposed_Grace_Period_Months__c 
                 || q.Payment_Terms__c != oldMap.get(q.Id).Payment_Terms__c
                 || q.Proposed_Start_Date__c!=oldMap.get(q.Id).Proposed_Start_Date__c
                 || q.Proposed_End_Date__c!=oldMap.get(q.Id).Proposed_End_Date__c
                // || q.Lease_Start_Date__c != oldMap.get(q.id).Lease_Start_Date__c
                // || q.Lease_End_Date__c != oldMap.get(q.id).Lease_End_Date__c
                )
               )
            {
                updatedQuotes.add(q.id);
            }
            
        }
        if(!updatedQuotes.isempty())
            populateApprover(updatedQuotes);
    }
    public static void updateDoAproversQli(List<QuoteLineItem> lineItems, map<Id,QuoteLineItem> oldmap)
    {
        Set<Id>  quoteIds = new Set<Id>();
        for(QuoteLineItem qli: lineItems)
        {
            if(qli.Offer_Price__c != oldmap.get(qli.id).Offer_Price__c ||
              qli.Best_Rate__c != oldmap.get(qli.id).Best_Rate__c)
            {
                quoteIds.add(qli.quoteid);
            }
        }
        if(!quoteIds.isempty()){
            populateApprover(quoteIds);
        }
    }
    
    /*
     * Method : populateApprover
     * Description: This method is calculating the DOA discount on the quote line items and populating the DOA 
     *              Approvers on the Quote record using the DOA matrix
     * 
     * */
    public static void populateApprover(Set<Id> quotes){
        List<Quote> proposals = [
                Select  Price_List_Number_Of_Payments__c,Proposed_Grace_Period__c,Unit_Sub_Category__c,
                        Proposed_Grace_Period_Months__c,Status,Discount__c,Proposed_Start_Date__c,
                        Proposed_End_Date__c,Opportunity.Lease_Start_Date__c,Opportunity.Lease_End_Date__c,
                        Id,Name,Opportunity.Pricebook2Id,Pricebook2Id, Opportunity.Type, Category__c,
                        Payment_Terms__c,DOA_Discount_Roll_Up_Summary__c ,DOA_Discount_percent__c ,Discount,
                        Opportunity.Business_Park__c, Opportunity.Recordtype.name,Number_Of_Payments__c, DOA_Approver__c,
                        Level_1_Approver__c, Level_2_Approver__c, Level_3_Approver__c, Level_4_Approver__c, Level_5_Approver__c, Level_6_Approver__c,
                        (Select Id,Type__c,Price_Schedule__r.Payment_Term__c,Best_Rate__c,Total_Best_Rate__c,Area_ft__c,
                                List_Price_Rate__c,Offered_Price_Rate__c,Total_List_Price__c,TotalPrice,Product2.Id,
                                Product2.Name,Product2.Unit__r.Building__r.Name,Default_Grace_Period__c,Default_Grace_Period_Months__c,
                                Discount,Product2.Unit_Sub_Category__r.Unit_Category__r.Name,Product2.Unit_Sub_Category__r.Name,
                                Grace_Period_Discount__c,Default_GP_Discount_Amount__c,Transaction_Unit__c
                         from QuoteLineItems)
                from Quote
                where Id in:quotes
                AND Status = 'Draft'
        ];
        
        Set<String> leaseTypes = new Set<String>();
        Set<String> opportuntiyTypes = new Set<String>();
        Set<Id> businessParks = new Set<Id>();
        
        Map<id,Payment_Term__c> paymentTerms = new Map<id,Payment_Term__c>();
        for(Quote proposal : proposals){
            for(QuoteLineItem qLine : proposal.QuoteLineItems){
                if(qLine.Type__c == 'Normal' && qLine.Price_Schedule__c != null){
                    paymentTerms.put(qLine.Price_Schedule__r.Payment_Term__c,null);
                }
            }
            leaseTypes.add(proposal.Opportunity.Type);
            opportuntiyTypes.add(proposal.Opportunity.RecordType.Name);
            businessParks.add(proposal.Opportunity.Business_Park__c);
        }

        if (!paymentTerms.isEmpty()) {
            paymentTerms = new Map<Id, Payment_Term__c>([SELECT id, Name,Number_Of_Payments__c FROM Payment_Term__c WHERE Id IN :paymentTerms.keySet()]);
        }
        
        List<DOA_Approver__c> approversList= [SELECT Lease_Type__c ,Business_Park__c, DOA_Discount_Amount_To__c,DOA_Discount_Amount_From__c,Opportunity_Type__c,Additional_Payment_From__c, Additional_Payment_To__c, IsDeleted, Discount_Percent_From__c, Discount_Percent_To__c, Level_1_Approver__c, Level_2_Approver__c, Level_3_Approver__c, Level_4_Approver__c, Level_5_Approver__c, Level_6_Approver__c ,Unit_Category__c ,Unit_Sub_Category__c  
                                              FROM DOA_Approver__c WHERE IsDeleted=false AND Lease_Type__c IN :leaseTypes AND Business_Park__c IN :businessParks AND Opportunity_Type__c IN :opportuntiyTypes  
                                              Order By Unit_Sub_Category__c,Unit_Category__c desc];
        
        Map<Id, Quote> quotesToUpdate = new Map<Id, Quote>();
        for(Quote proposal: proposals){
            Boolean approversDefined=false;
            decimal additionalPayments= 0;
            if(proposal.QuoteLineItems.size()>0){
               // proposal.Category__c = proposal.QuoteLineItems.get(0).Product2.Unit_Sub_Category__r.Unit_Category__r.Name;
            }
            if(proposal.Payment_Terms__c!=null )
            {
               // System.debug('no_of_installments__c:'+paymentTerms.get(proposal.Payment_Terms__c).no_of_installments__c+' Price_List_Number_Of_Payments__c:' +proposal.Price_List_Number_Of_Payments__c );
                additionalPayments= (paymentTerms.get(proposal.Payment_Terms__c) != null? paymentTerms.get(proposal.Payment_Terms__c).Number_Of_Payments__c:0) - (proposal.Number_Of_Payments__c != null?proposal.Number_Of_Payments__c:0);

                String oldDOAApprover = proposal.DOA_Approver__c;
                String oldLevel1Approver = proposal.Level_1_Approver__c;
                String oldLevel2Approver = proposal.Level_2_Approver__c;
                String oldLevel3Approver = proposal.Level_3_Approver__c;
                String oldLevel4Approver = proposal.Level_4_Approver__c;
                String oldLevel5Approver = proposal.Level_5_Approver__c;
                String oldLevel6Approver = proposal.Level_6_Approver__c;
				
                proposal.DOA_Approver__c = null;
                proposal.Level_1_Approver__c=null;
                proposal.Level_2_Approver__c=null;
                proposal.Level_3_Approver__c=null;
                proposal.Level_4_Approver__c=null;
                proposal.Level_5_Approver__c=null;
                proposal.Level_6_Approver__c=null;
               
                for (DOA_Approver__c approver:approversList){
                    if( (approver.Opportunity_Type__c == proposal.Opportunity.RecordType.Name) &&
                       (approver.Lease_Type__c == proposal.Opportunity.Type) &&
                        (approver.Business_Park__c == proposal.opportunity.business_park__c || proposal.opportunity.business_park__c== null ) &&
                        //(approver.Unit_Sub_Category__c==proposal.Unit_Sub_Category__c  || (approver.Unit_Sub_Category__c==null)) &&
                        ((approver.Additional_Payment_From__c<=additionalPayments || approver.Additional_Payment_From__c==null) &&
                         (approver.Additional_Payment_To__c>=additionalPayments || approver.Additional_Payment_To__c==null)) &&
                        ((approver.DOA_Discount_Amount_From__c  <= proposal.DOA_Discount_Roll_Up_Summary__c || approver.DOA_Discount_Amount_From__c ==null)
                         && (approver.DOA_Discount_Amount_To__c >= proposal.DOA_Discount_Roll_Up_Summary__c || approver.DOA_Discount_Amount_To__c ==null)) &&
                        ((approver.Discount_Percent_From__c   <= proposal.DOA_Discount_percent__c  || approver.Discount_Percent_From__c  ==null)
                         && (approver.Discount_Percent_To__c  >= proposal.DOA_Discount_percent__c  || approver.Discount_Percent_To__c  ==null))
                    )
                    {
                        System.debug('match found:');
                        approversDefined=true;
                        proposal.DOA_Approver__c = approver.Id;
                        proposal.Level_1_Approver__c=approver.Level_1_Approver__c;
                        proposal.Level_2_Approver__c=approver.Level_2_Approver__c;
                        proposal.Level_3_Approver__c=approver.Level_3_Approver__c;
                        proposal.Level_4_Approver__c=approver.Level_4_Approver__c;
                        proposal.Level_5_Approver__c=approver.Level_5_Approver__c;
                        proposal.Level_6_Approver__c=approver.Level_6_Approver__c;
                        break;
                    }
                }

                // Only update quote if any of the values changed
                if (oldDOAApprover != proposal.DOA_Approver__c ||
                    oldLevel1Approver != proposal.Level_1_Approver__c ||
                    oldLevel2Approver != proposal.Level_2_Approver__c ||
                    oldLevel3Approver != proposal.Level_3_Approver__c ||
                    oldLevel4Approver != proposal.Level_4_Approver__c ||
                    oldLevel5Approver != proposal.Level_5_Approver__c ||
                    oldLevel6Approver != proposal.Level_6_Approver__c)
                {
                    quotesToUpdate.put(proposal.Id, proposal);
                }
            }
        }
        if(!quotesToUpdate.isEmpty())
           update quotesToUpdate.values();
    }
    
    
    
    /*
* Updated By: Raza khan (raza.khan@weare4c.com)
* Dated:      22 June, 2019
* Description: This method is for reseting the approvers when the quote is once rejected and updated by admin back to 
*              draft for making updates on it.
* 
* */
    public static void resetApprover(List<Quote> newQuotes, map<Id, Quote> oldMap)
    {
        
        for(Quote q: newQuotes)
        {
            if(q.status != oldmap.get(q.id).status && q.status == 'Draft' && oldMap.get(q.id).status == 'Rejected'){
                
                q.Level_1_Approver__c = null;
                q.Level_2_Approver__c = null;
                q.Level_3_Approver__c = null;
                q.Level_4_Approver__c = null;
                q.Level_5_Approver__c = null;
                q.Level_6_Approver__c = null;
                q.DOA_Approver__c = null;
            }
            
        }
    }
       
        /*
     * Updated By: Raza khan (raza.khan@weare4c.com)
     * Dated:  22 June, 2019
     * Description: The method s for implementing a validation for quote line items that are associated 
     *  to under approval quotes.
     * 
     * */
    public static void restrictDeletionUnderApprovalLineItems(List<QuoteLineItem> oldLineItems)
    {

         Map<Id, Quote> quoteMap = getQuotes(oldLineItems);
        
        for(QuoteLineItem qi: oldLineItems)
        {
            if(quoteMap.get(qi.QuoteId).status == 'Under Approval' )
            {
                qi.addError(label.Under_Approval_Quote_Line_Items_Validation );
            }
        }
        
        
    }
    /*
    * Updated by: Raza Khan (raza.khan@weare4c.com)
    * Description: The method is for validating the quote line items that have updated while the quote in under approval.
    *
    */
    public static void restrictUpdateUnderApproval(Map<Id,QuoteLineItem> newMap, Map<Id, QuoteLineItem> oldMap)
    {
        Set<String> qLineItemFields = getAllFields();
        List<QuoteLineItem> updatedLineItems = new List<QuoteLineItem>();
        for(QuoteLineItem qli: newMap.values())
        {
            for(String f: qLineItemFields)
            {
                if(qli.get(f)!= oldMap.get(qli.Id).get(f) )
                {
                    updatedLineItems.add(qli);
                    break;
                }
            }
        }

        if (!updatedLineItems.isEmpty()) {
            Map<Id, Quote> quoteMap = getQuotes(updatedLineItems);
            for (QuoteLineItem li : updatedLineItems) {
                if (quoteMap.get(li.QuoteId).Status == 'Under Approval') {
                    li.addError(Label.Under_Approval_Quote_Line_Items_Validation);
                }

            }
        }

    }
    /*
    * Updated by: Raza khan (raza.khan@weare4c.com)
    * Description: The method id for the quote map for the given line items.
    */
    private static Map<Id,Quote> getQuotes(List<QuoteLineItem> lineItems)
    {
        Set<Id> quoteIds = new Set<Id>();
        for(QuoteLineItem qi: lineItems)
        {
            if (!cachedQuotesByIds.containsKey(qi.QuoteId)) {
                quoteIds.add(qi.QuoteId);
            }
        }

        if (!quoteIds.isEmpty()) {
            for (Quote q : [Select id, Status from quote where id in :quoteIds]) {
                cachedQuotesByIds.put(q.id, q);
            }
        }
        return cachedQuotesByIds;
    }

    /*
    * Updated by: Raza khan (raza.khan@weare4c.com)
    * Description: The method id for the fieldsmap for the quote line items.
    */
    private static Set<String> getAllFields()
    {
        Map<String, Schema.SObjectField> soFields = Schema.SObjectType.QuoteLineItem.fields.getMap(); 
        return soFields.keySet();
    }

    public static void updatDefaultGracePeriodForQLI(Set<Id> quoteIdSet) {

        List<QuoteLineItem> quoteLineItemList = [SELECT Id, QuoteId, Total_Offered_Price__c, Price_Schedule__c, Default_Grace_Period__c
                                                 FROM QuoteLineItem
                                                 WHERE QuoteId IN :quoteIdSet
                                                 AND Type__c IN ('Normal','Revision')
                                                ];

        if(!quoteLineItemList.isEmpty()) {

            PricingUtils.calculateGraceDiscountsAmount(quoteLineItemList);
            update quoteLineItemList;
        }
    }

}