/************************************************************************************
* Name          : ManagePriceRevisionsController                                                 
* Description   : Controller class for Manage Pricing Revision lightning component
* Created Date  : 19/08/2019                                                   
* Created By    : Amruta Kumbhakarn (amruta.kumbhakarn@weare4c.com)
* Jira/Req By   :                                                                                                                                           
* -----------------------------------------------------------------------------------------------------------------------
* VERSION   Developer   Date        Description     Ticket/Reference    
************************************************************************************/
public class ManagePriceRevisionsController {
    
    /************************************************************************************
    Method      :   getLineItemsDetailsByUnitApx
    Description :   Method to get quote line item group by unit related quote paased.
    Params      :   QuoteId
	Return Type :   Return list of UnitLineItemWrapper class
    Created Date:   19/08/2019
    *************************************************************************************
    */
    @AuraEnabled
    public static List<UnitLineItemWrapper> getLineItemsDetailsByUnitApx(Id quoteId) {
        
        Manage_Price_Revision_Setting__c settingObj = 
            Manage_Price_Revision_Setting__c.getValues(UserInfo.getProfileId());
        Map<Id, List<QuoteLineItem>> productIdVsLineItemListMap = new Map<Id, List<QuoteLineItem>>();
        Map<Id, String> productIdVsNameMap = new Map<Id, String>();
        Map<Id, String> productIdVsAreaMap = new Map<Id, String>();
        Map<Id, List<QuoteLineItem>> revisionIdVsLineItemListMap = new Map<Id, List<QuoteLineItem>>();
        Map<Id, Quote_Revision__c> revisionIdVsRevisionMap = new Map<Id, Quote_Revision__c>();
        List<UnitLineItemWrapper> quoteLineItemList = new List<UnitLineItemWrapper> (); 
        List<RevisionLineItemWrapper> revisionquoteLineItemList = new List<RevisionLineItemWrapper> (); 
        
        for(QuoteLineItem itemObj : [SELECT Id, 
                                     Revision_Number__c, 
                                     Type__c, 
                                     Total_Offered_Price__c, 
                                     Total_Best_Rate__c, 
                                     Best_Rate__c, 
                                     Offer_Price__c, 
                                     DOA_Discount2__c,
                                     Product2Id,
                                     Product2.Name,
                                     Product2.Area_ft__c,
                                     Product2.Transaction_Unit__c,
                                     Start_Date__c, 
                                     End_Date__c, 
                                     Transactional_Unit__c,
                                     Area__c,
                                     PriceSch_ChargeType__c,
                                     Transaction_Unit__c,
                                     Price_Schedule__c,
                                     Default_Grace_Period__c,
                                     QuoteId
                                     FROM QuoteLineItem
                                     WHERE QuoteId =: quoteId
                                     AND IsDeleted = false
                                     Order By Revision_Number__c ASC
                                    ]) {
                                        
            if(productIdVsLineItemListMap.containsKey(itemObj.Product2Id)) {
                productIdVsLineItemListMap.get(itemObj.Product2Id).add(itemObj);
            }
            else {
                 productIdVsLineItemListMap.put(itemObj.Product2Id, new List<QuoteLineItem> {itemObj});
                 productIdVsNameMap.put(itemObj.Product2Id, itemObj.Product2.Name);
                 productIdVsAreaMap.put(itemObj.Product2Id, String.valueOf(itemObj.Product2.Area_ft__c) + ' '+ itemObj.Product2.Transaction_Unit__c);
            }
        }
        for(Id productId : productIdVsLineItemListMap.keySet()) {
            List<QuoteLineItem> lineItemList = productIdVsLineItemListMap.get(productId);
            quoteLineItemList.add(new UnitLineItemWrapper(productIdVsNameMap.get(productId),
                                                          productId,
                                                          productIdVsAreaMap.get(productId),
                                                          lineItemList,
                                                          settingObj != null ? settingObj.Allow_To_Edit_Best_Rate__c : false
                                                         )
                                 );
        }
        
        return quoteLineItemList;
    }
    /************************************************************************************
    Method      :   getLineItemsDetailsByRevisionApx
    Description :   Method to get quote line item group by unit related quote paased.
    Params      :   QuoteId
	Return Type :   Return list of UnitLineItemWrapper class
    Created Date:   19/08/2019
    *************************************************************************************
    */
    @AuraEnabled
    public static List<RevisionLineItemWrapper> getLineItemsDetailsByRevisionApx(Id quoteId) {
        
        Manage_Price_Revision_Setting__c settingObj = 
            Manage_Price_Revision_Setting__c.getValues(UserInfo.getProfileId());
        Map<Id, List<QuoteLineItem>> productIdVsLineItemListMap = new Map<Id, List<QuoteLineItem>>();
        Map<Id, String> productIdVsNameMap = new Map<Id, String>();
        Map<Id, String> productIdVsAreaMap = new Map<Id, String>();
        Map<Id, List<QuoteLineItem>> revisionIdVsLineItemListMap = new Map<Id, List<QuoteLineItem>>();
        Map<Id, Quote_Revision__c> revisionIdVsRevisionMap = new Map<Id, Quote_Revision__c>();
        List<UnitLineItemWrapper> quoteLineItemList = new List<UnitLineItemWrapper> (); 
        List<RevisionLineItemWrapper> revisionquoteLineItemList = new List<RevisionLineItemWrapper> (); 
        
        for(QuoteLineItem itemObj : [SELECT Id, 
                                     Revision_Number__c, 
                                     Type__c, 
                                     Total_Offered_Price__c, 
                                     Total_Best_Rate__c, 
                                     Best_Rate__c, 
                                     Offer_Price__c, 
                                     DOA_Discount2__c,
                                     Product2Id,
                                     Product2.Name,
                                     Product2.Area_ft__c,
                                     Product2.Transaction_Unit__c,
                                     Quote_Revision__c,
                                     Start_Date__c, 
                                     End_Date__c, 
                                     Transactional_Unit__c,
                                     Area__c,
                                     PriceSch_ChargeType__c,
                                     Transaction_Unit__c,
                                     Price_Schedule__c,
                                     Default_Grace_Period__c,
                                     QuoteId
                                     FROM QuoteLineItem
                                     WHERE QuoteId =: quoteId
                                     AND Quote_Revision__c != null
                                     AND IsDeleted = false
                                     Order By Revision_Number__c ASC 
                                    ]) {
                                        
             if(revisionIdVsLineItemListMap.containsKey(itemObj.Quote_Revision__c)) {
                 revisionIdVsLineItemListMap.get(itemObj.Quote_Revision__c).add(itemObj);
             }
             else {
                 revisionIdVsLineItemListMap.put(itemObj.Quote_Revision__c, new List<QuoteLineItem> {itemObj});
             }
        }
        revisionIdVsRevisionMap = new Map<Id, Quote_Revision__c> ([SELECT Id, 
                                                                   		  Start_Date__c,
                                                                          End_Date__c,
                                                                          Total_Offered_Price__c,
                                                                          Revision_Number__c
                                                                   FROM Quote_Revision__c
                                                                   WHERE Id IN: revisionIdVsLineItemListMap.keySet()
                                                                  ]);
        for(Id revisionId : revisionIdVsLineItemListMap.keySet()) {
			
			quoteLineItemList = new List<UnitLineItemWrapper> (); 
			productIdVsLineItemListMap = new Map<Id, List<QuoteLineItem>>();
			
            for(QuoteLineItem itemObj : revisionIdVsLineItemListMap.get(revisionId)) {
				
				if(productIdVsLineItemListMap.containsKey(itemObj.Product2Id)) {
					productIdVsLineItemListMap.get(itemObj.Product2Id).add(itemObj);
				}
				else {
					productIdVsLineItemListMap.put(itemObj.Product2Id, new List<QuoteLineItem> {itemObj});
					productIdVsNameMap.put(itemObj.Product2Id, itemObj.Product2.Name);
					productIdVsAreaMap.put(itemObj.Product2Id, String.valueOf(itemObj.Product2.Area_ft__c) + ' '+ itemObj.Product2.Transaction_Unit__c);
				}
			}
			for(Id productId : productIdVsLineItemListMap.keySet()) {
				List<QuoteLineItem> lineItemList = productIdVsLineItemListMap.get(productId);
				quoteLineItemList.add(new UnitLineItemWrapper(productIdVsNameMap.get(productId),
															  productId,
															  productIdVsAreaMap.get(productId),
															  lineItemList,
                                                              settingObj != null ? settingObj.Allow_To_Edit_Best_Rate__c : false
															 )
									 );
			}
			revisionquoteLineItemList.add(new RevisionLineItemWrapper(revisionIdVsRevisionMap.get(revisionId),
																	  quoteLineItemList
																	 )
										 ); 
        }
        
        return revisionquoteLineItemList;
    }
    
    /**
     *  @description Function that return QLI with updated Total offered price rate
     *  @param  lineItem    lineItem to update
     *  @return LineItem wrapper instance.
     */
    @AuraEnabled
    public static QuoteLineItem getTotalOfferedPrice(QuoteLineItem li) {

        List<QuoteLineItem> itemList  = new List<QuoteLineItem>{li};
        PricingUtils.calculateQuoteLineItemTotals(itemList);
        PricingUtils.calculateGraceDiscountsAmount(itemList);
        return itemList[0];
    }
    @AuraEnabled
    public static String saveLineItemApx(List<QuoteLineItem> quoteLineItemList, List<String> qliToBeUpdatedList) {
        
        List<QuoteLineItem> quoteLineToUpdateList = new List<QuoteLineItem>();
        Set<Id> uniqueIdSet = new Set<Id>();
        String returnStr = '';
        for(QuoteLineItem itemObj : quoteLineItemList) { 
            if(!itemObj.Type__c.equalsIgnoreCase('Grace Period') &&
               !uniqueIdSet.contains(itemObj.Id) &&
                qliToBeUpdatedList.contains(itemObj.Id)) {
                quoteLineToUpdateList.add(itemObj);
                uniqueIdSet.add(itemObj.Id);  
            }
        }
        if(!quoteLineToUpdateList.isEmpty()) {
            try {
                system.debug('I am in-----:'+quoteLineToUpdateList);
                update quoteLineToUpdateList;
                returnStr = 'SUCCESS';
            }
            catch(Exception ex) {
                returnStr = ex.getMessage();
            }
        }
        return returnStr;
    }
    
    public class UnitLineItemWrapper {
        
        @AuraEnabled
        public String productName;
        @AuraEnabled
        public String productId;
        @AuraEnabled
        public String unitArea;
        @AuraEnabled
        public List<QuoteLineItem> lineItemList;
        @AuraEnabled
        public Boolean allowBestRateEdit; 
        
        public UnitLineItemWrapper(String productName,  
                                   String productId, 
                                   String unitArea, 
                                   List<QuoteLineItem> lineItemList, 
                                   Boolean allowBestRateEdit) {
        	
            this.productName = productName;
            this.productId = productId;
            this.unitArea = unitArea;
            this.lineItemList = lineItemList;
            this.allowBestRateEdit = allowBestRateEdit;
        }
    }
    
    public class RevisionLineItemWrapper {
        
        @AuraEnabled
        public Quote_Revision__c revisionObj; 
        @AuraEnabled
        public List<UnitLineItemWrapper> unitLineItemList;

        
        public RevisionLineItemWrapper(Quote_Revision__c revisionObj, 
                                       List<UnitLineItemWrapper> unitLineItemList
                                      ) {
        	
            this.revisionObj = revisionObj;
            this.unitLineItemList = unitLineItemList;
        }
        
    }

}