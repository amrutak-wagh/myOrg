/************************************************************************************
* Name          : QuoteUnitSelectionAssistantController                                                 
* Description   : Controller of QuoteUnitSelectionAssistant.cmp
* Created Date  : 11/07/2019                                                    
* Created By    : 4C - Anshul Garg (anshul.garg@weare4c.com)
* Jira/Req By   :                                                                                                                                           
* -----------------------------------------------------------------------------------------------------------------------
* VERSION   Developer   Date        Description     Ticket/Reference    

************************************************************************************/
public class QuoteUnitSelectionAssistantController {
    
    public static final String TYPE_NORMAL = 'Normal';
    /**
     *  @description This method creates the wrapper for all the Category and Sub category records
     *  @param  recordId  Record Id of the related Quote
     *  @return List of CategorySubCategoryWrapper Wrapper
     */
    @AuraEnabled
    public static List<CategorySubCategoryWrapper> getCategoryFilter(Id recordId){
        Quote quoteRec = [SELECT  Id,
                                  Account.License_Business_Park__c,
                                  Opportunity.Business_Park__c
                          FROM  Quote
                          WHERE Id =:recordId];
        
        List<Building__c> buildingList = new List<Building__c>();
        Set<Id> buildingIdSet = new Set<Id>();
        List<Plot__c> plotBuildingList = new List<Plot__c>();
        
        if(quoteRec != NULL && quoteRec.Opportunity.Business_Park__c != NULL){
            for(Plot__c plot : [SELECT  Id, (SELECT Id FROM Buildings__r)
                                FROM  Plot__c
                                WHERE Business_Park__c =:quoteRec.Opportunity.Business_Park__c]) {
                for(Building__c bObj : plot.Buildings__r) {
                    buildingIdSet.add(bObj.Id);
                }
            }                       
            buildingList = [SELECT  Id
                            FROM  Building__c
                            WHERE Business_Park__c =:quoteRec.Opportunity.Business_Park__c
                           ];
        }

        for(Building__c buildingInstance : buildingList){
            buildingIdSet.add(buildingInstance.Id);
        }
        
        List<Unit__c> unitList = new List<Unit__c>();
        unitList = [SELECT Id
                          ,Unit_Sub_Category__r.Id
                          ,Unit_Sub_Category__r.Name
                          ,Unit_Sub_Category__r.Unit_Category__r.Id
                          ,Unit_Sub_Category__r.Unit_Category__r.Name
                    FROM  Unit__c
                    WHERE Building__r.Id IN :buildingIdSet];
        
        Set<Id> unitCategoryIdSet = new Set<Id>();
        if(!unitList.isEmpty()){
            for(Unit__c unitIns : unitList){
                unitCategoryIdSet.add(unitIns.Unit_Sub_Category__r.Unit_Category__r.Id);
            }
        }
          
        List<Unit_Category__c> unitCategoryList = new List<Unit_Category__c>();
        if(!unitCategoryIdSet.isEmpty()){
             unitCategoryList = [SELECT  Id
                                        ,Name
                                        ,(SELECT Id,Name FROM Unit_Sub_Categories__r)
                                 FROM  Unit_Category__c
                                 WHERE Id IN :unitCategoryIdSet];
        }
        
        List<CategorySubCategoryWrapper> wrapperList = new List<CategorySubCategoryWrapper>();
        List<QuoteLineItem> qliList = new List<QuoteLineItem>();
        qliList = [SELECT Product2Id FROM QuoteLineItem WHERE QuoteId = :recordId];
        
        Set<Id> productIdSet = new Set<Id>();
        for(QuoteLineItem qli : qliList){
            productIdSet.add(qli.Product2Id);
        }
        
        List<Product2> productList = new List<Product2>();
        productList = [SELECT Building__c,Unit__r.Building__r.Id FROM Product2 WHERE Id IN :productIdSet];
        
        Set<Id> selectedBuild = new Set<Id>();
        Set<Id> selectedUnitsIdSet = new Set<Id>();
        for(Product2 proIns : productList){
            selectedBuild.add(proIns.Unit__r.Building__r.Id);
            selectedUnitsIdSet.add(proIns.Unit__r.Id);
        }
        
        for(Unit_Category__c unitCategory : unitCategoryList){
            CategorySubCategoryWrapper instance = new CategorySubCategoryWrapper();
            instance.unitCategory = unitCategory;
            for(Unit_Sub_Category__c subCategory : unitCategory.Unit_Sub_Categories__r){
                SubCategory scIns = new SubCategory(subCategory.Name,subCategory.Id);
                instance.subCategory.add(scIns);
            }
            instance.buildingIdsList = new List<Id>(selectedBuild);
            instance.unitIdSet = selectedUnitsIdSet;
            wrapperList.add(instance);
        }
        
        return wrapperList;
    }
    
    /**
     *  @description Queries all the building on the basis of selected Unit sub category
     *  @param  subCategoryIdList  List of id of selected Sub Category
     *  @return List of Selected Building in a wrapper
     */
    @AuraEnabled
    public static List<SubCategory> getBuildingList(List<Id> subCategoryIdList){
        
        List<Unit__c> unitList = [SELECT Id
                                        ,Building__r.Id
                                        ,Building__r.Name
                                  FROM Unit__c
                                  WHERE Unit_Sub_Category__c IN :subCategoryIdList];
        
        List<SubCategory> buildingPickList = new List<SubCategory>();
        Set<Id> buildingIdSet = new Set<Id>();
        for(Unit__c unitIns : unitList){
            if(!buildingIdSet.contains(unitIns.Building__r.Id)){
                SubCategory instance = new SubCategory(unitIns.Building__r.Name,unitIns.Building__r.Id);
                buildingPickList.add(instance);
                buildingIdSet.add(unitIns.Building__r.Id);
            }
        }
        
        return buildingPickList;
    }
    
    /**
     *  @description Populates the wrapper with floor number as label and value
     *  @param  bId   Id of selected Building
     *  @return List of SubCategory Wrapper which contains the Floor from selected Building
     */
    @AuraEnabled
    public static List<SubCategory> getFloorList(Id bId){
        
        List<Unit__c> unitList = [SELECT Id
                                        ,Floor_Number__c
                                        ,Floor_Name__c
                                  FROM Unit__c
                                  WHERE Building__c =:bId];
        
        List<SubCategory> floorPickList = new List<SubCategory>();
        Set<String> floorNumberSet = new Set<String>();
        for(Unit__c unitIns : unitList){
            System.debug('unitIns--'+unitIns);
            if(!floorNumberSet.contains(unitIns.Floor_Number__c)){
                if(!String.isBlank(unitIns.Floor_Number__c)){
                    SubCategory instance = new SubCategory(unitIns.Floor_Name__c,unitIns.Floor_Number__c);
                    floorPickList.add(instance);
                    floorNumberSet.add(unitIns.Floor_Number__c);
                }
            }
        }
        
        floorPickList.sort();
        return floorPickList;
    }
    
    /**
     *  @description Performs query on unit on the basis of supplied params
     *  @updates : 21/08/2019 - Adeel Ahmad
     *           : Pass the list of units that are already added to quote from expansion process
     *  @param  bId fromArea toArea floorNumber selectedSubCat buildingOnExistingQLI
     *  @return List of Queried Units
     */
    @AuraEnabled
    public static List<Unit__c> getUnits(String bId,Integer fromArea,Integer toArea,String floorNumber,List<Id> selectedSubCat,List<Id> buildingOnExistingQLI,List<Id> existingUnitIdList, LIST<Id> excludedUnits){
        String query = 'SELECT Id,Unit_Sub_Category__r.Name,Name,Area_ft__c,Building__c FROM Unit__c WHERE Unit_Sub_Category__c IN :selectedSubCat AND Is_Leasable__c = True AND Active__c = True AND Status__c = \'Available\'';
        if(!String.isBlank(bId))query = query + ' AND Building__c =:bId ';
        if(!buildingOnExistingQLI.isEmpty()) query = query + ' AND Building__c  IN :buildingOnExistingQLI ';
        if(!String.isBlank(floorNumber))query = query + 'AND Floor_Number__c =:floorNumber ';
        if(fromArea != Null)query = query + 'AND Area_ft__c >= :fromArea ';
        if(toArea != Null)query = query + 'AND Area_ft__c <= :toArea';
     	if(!existingUnitIdList.isEmpty())query = query + ' AND Id NOT IN :existingUnitIdList';
        if(!excludedUnits.isEmpty())query = query + ' AND Id NOT IN :excludedUnits';
        System.debug('query---'+query);
        List<Unit__c> unitList = Database.query(query);
        System.debug('unitList---'+unitList);
        return unitList;
    }
    
    /**
     *  @description Searches the Line Items
     *  @param  quoteId  Id of the related Quote
     * 			searchTerm  Name of the unit which is added
     * 			lineItemList LineItems List
     *  @return Returns the lineitem wrapper with all the details
     */
    @AuraEnabled
    public static List<LineItem> fetchLineItems(String quoteId, String unitId, List<LineItem> lineItemList){
        List<LineItem> lineItemUpdatedList = search(quoteId,unitId, lineItemList);
      
        return lineItemUpdatedList;
    }
    
     /**
     *  @description Creates the QLI records
     *  @param  lineItemList LineItems List
     *  @return Returns the error message or null
     */
    @AuraEnabled
    public static List<QuoteLineItem> save(List<LineItem> lineItemList){
        List<QuoteLineItem> quoteLineItemList = new List<QuoteLineItem>();
        List<QuoteLineItem> quoteLineItemChargesList = new List<QuoteLineItem>();
        for(LineItem li : lineItemList) {
            quoteLineItemList.add(li.quoteLineItem);
        }
        if(!quoteLineItemList.isEmpty()){
            try {
                Map<Id, QuoteLineItem> rentLineItemsByIds = deleteExistingQLIForPopulateSchedule(quoteLineItemList[0].QuoteId);
                insert quoteLineItemList;
                for(Integer i = 0; i < quoteLineItemList.size(); i++) {
                    lineItemList[i].quoteLineItem.Id = quoteLineItemList[i].Id;
                    for(QuoteLineItem obj : lineItemList[i].chargesRelatedQLIList) {
                        obj.Parent_Quote_Line_Item__c = quoteLineItemList[i].Id;
                    }
                    quoteLineItemChargesList.addAll(lineItemList[i].chargesRelatedQLIList);
                }
                insert quoteLineItemChargesList;
                
                //for(QuoteLineItem rentLineItem : rentLineItemsByIds.values()) {
                //	rentLineItem.Price_Schedule__c = null;
            	//}
            	// Update Rent QLI to assign new price rule with updated values.
            	if(!rentLineItemsByIds.isEmpty()) {
           			return rentLineItemsByIds.values();
                }
                return null;
            } catch (Exception e) {
                throw new AuraHandledException(e.getMessage().contains('Product has already added with same Price schedule.') ? 
                        'Error: Product has already added with same Price schedule.' : e.getMessage() );
                //return ;
            }
        }
        return null;
    }
    
    @AuraEnabled
    public static String updateExistingQLIsApx(List<QuoteLineItem> quoteLineItemList) {
        
		//List<QuoteLineItem> quoteLineItemList = new List<QuoteLineItem>();     
        if(!quoteLineItemList.isEmpty()) {
            for(QuoteLineItem rentLineItem : quoteLineItemList) {
                rentLineItem.Price_Schedule__c = null;
            }
            try {
            	update quoteLineItemList;
                return null;
            }
            catch(Exception ex) {
                return (String.valueOf(ex.getMessage()));
            }
        }
            
         return null;   
    }
    
    public static Map<Id, QuoteLineItem> deleteExistingQLIForPopulateSchedule(String quoteId) {
        
        // Get Quote Line Item for related changed Quote to calculate new price rule for them.
        Map<Id, QuoteLineItem> rentLineItemsByIds = new Map<Id, QuoteLineItem>([
            SELECT Start_Date__c, Product2Id, Transactional_Unit__c, Transaction_Type__c,
            PricebookEntryId, UnitPrice, Area__c, QuoteId, Parent_Quote_Line_Item__c,
            End_Date__c, Quote.Proposed_Start_Date__c, Quote.Proposed_End_Date__c, Price_Schedule__c
            FROM QuoteLineItem
            WHERE QuoteId =: quoteId
            AND Type__c = :TYPE_NORMAL
            AND Parent_Quote_Line_Item__c = null
        ]);
        
        if(!rentLineItemsByIds.isEmpty()) {
            // Delete all quote line items except Rent
            delete [SELECT Id FROM QuoteLineItem WHERE QuoteId =:quoteId AND Parent_Quote_Line_Item__c != null AND Type__c = :TYPE_NORMAL];
            
            // Reset Price Schedule on Rent qlis
            //for(QuoteLineItem rentLineItem : rentLineItemsByIds.values()) {
                //rentLineItem.Price_Schedule__c = null;
            //}
            // Update Rent QLI to assign new price rule with updated values.
           // update rentLineItemsByIds.values();
           return rentLineItemsByIds;
        }
		return rentLineItemsByIds;        
    }
    
     /**
     *  @description Searches the Line Items
     *  @param  quoteId  Id of the related Quote
     * 			searchTerm  Name of the unit which is added
     * 			lineItemList LineItems List
     *  @return Returns the lineitem wrapper with all the details
     */
    @AuraEnabled
    public static List<LineItem> search(String quoteId, String unitId, List<LineItem> lineItemList) {
        if (String.isBlank(quoteId)) {
            throw new AuraHandledException('This component needs the quote id');
        } else if (String.isBlank(unitId)) {
            throw new AuraHandledException('Please, enter a term to search for');
        }

        // Query quote
        List<Quote> quoteList = [
            SELECT  AccountId, Type__c, Status, Proposed_Start_Date__c, Proposed_End_Date__c, Previous_Quote__c, 
                    Pricebook2Id, Pricebook2.Name, Grace_period__c, Grace_Period_Period__c
            FROM    Quote
            WHERE   Id = :quoteId
        ];
        if (!quoteList.isEmpty()) {
            Quote quote = quoteList.get(0);

            validateQuote(quote);
            System.debug('quote---'+quote);
            // Query pricebookentry
            List<PricebookEntry> priceBookEntryList = [
                SELECT  Product2Id, UnitPrice
                FROM    PricebookEntry
                WHERE   Product2.Unit__c = :unitId AND
                        Pricebook2Id = :quote.Pricebook2Id AND
                        IsActive = true
                LIMIT 1
            ];
            if (!priceBookEntryList.isEmpty()) {
                PricebookEntry pbEntry = priceBookEntryList.get(0);

                // Query product
                List<Product2> productList = [
                    SELECT  Name, Transaction_Unit__c, Unit__r.Name, Unit__r.Building__r.Plot__r.Business_Park__c, Unit__r.Building__r.Plot__r.Business_Park__r.Business_Park_Code__c,
                            Unit__r.Building__r.Building_Code__c,  Unit__r.Floor_Type__c, Unit__r.Unit_Sub_Category__c, Unit__r.Unit_Sub_Category__r.Name,
                            Unit__r.Unit_Sub_Category__r.Unit_Category__r.Name, Unit__r.Exclude_DEWA_Charges_Common_Area__c, Unit__r.Exclude_Cooling_Charges__c,
                            Unit__r.Asset_Class_Name__c, Unit__r.Area_ft__c, Unit__r.Building__r.Ownership_Type__c
                    FROM    Product2
                    WHERE   Id = :pbEntry.Product2Id
                ];
                
                if (!productList.isEmpty()) {
                    Product2 product = productList.get(0);

                    Decimal totalLeaseArea = getExistingTotalLeasedArea(quote, lineItemList, product);
                    
                    // Retrieve previous quote line item if quote type is applicable
                    Set<String> applicableQuoteTypes = new Set<String>{'Renewal', 'Expansion', 'Downsize'};
                    List<QuoteLineItem> previousQuoteLines = new List<QuoteLineItem>();
                    if (applicableQuoteTypes.contains(quote.Type__c)) {
                        previousQuoteLines = [
                            SELECT  Best_Rate__c, Price_Schedule__c, Type__c,Offer_Price__c,
                                    Price_Schedule__r.Rate_Cap__c, Quote.Proposed_Start_Date__c
                            FROM    QuoteLineItem 
                            WHERE   QuoteId = :quote.Previous_Quote__c AND
                                    QuoteLineItem.Product2Id = :product.Id AND
                                    Type__c IN ('Normal','Revision')
                            ORDER BY Start_Date__c ASC
                        ];
                    }
                    // Gather information to query pricing engine
                    PricingEngine.Input input = new PricingEngine.Input();
                    input.businessPark = product.Unit__r.Building__r.Plot__r.Business_Park__r.Business_Park_Code__c;
                    input.building = product.Unit__r.Building__r.Building_Code__c;
                    input.floorNumber = product.Unit__r.Floor_Type__c;
                    input.utility = product.Unit__r.Exclude_DEWA_Charges_Common_Area__c ? false : true;
                    input.cooling = product.Unit__r.Exclude_Cooling_Charges__c ? false : true;
                    input.assetClass = product.Unit__r.Asset_Class_Name__c;
                    input.productCategory = product.Unit__r.Unit_Sub_Category__r.Unit_Category__r.Name;
                    input.productSubcategory = product.Unit__r.Unit_Sub_Category__r.Name;
                    input.ownershipStatus = product.Unit__r.Building__r.Ownership_Type__c;
                    input.transactionType = quote.Type__c;
                    input.transactionDate = quote.Proposed_Start_Date__c;
                    input.leaseTerm = String.valueOf(quote.Proposed_Start_Date__c.monthsBetween(quote.Proposed_End_Date__c));
                    input.totalLeasedArea = String.valueOf(totalLeaseArea);
					System.debug('previousQuoteLines---'+previousQuoteLines);
                    if (!previousQuoteLines.isEmpty()) {
                        Decimal initialBestRate = previousQuoteLines.get(0).Best_Rate__c;
                        Decimal lastBestRate = previousQuoteLines.get(previousQuoteLines.size()-1).Best_Rate__c;
                        Decimal lastPassingRate = previousQuoteLines.get(previousQuoteLines.size()-1).Offer_Price__c;
                        Decimal reraIndex = getRERAIndex(product.Unit__r.Building__r.Plot__r.Business_Park__c, 
                                                         quote.Proposed_Start_Date__c, 
                                                         lastBestRate,
                                                         product.Unit__r.Unit_Sub_Category__c);

                        if (initialBestRate != null) input.initialBestRate = String.valueOf(initialBestRate);
                        if (lastBestRate != null) input.lastBestRate = String.valueOf(lastBestRate);
                        if (lastPassingRate != null) input.lastPassingRate = String.valueOf(lastPassingRate);
                        if (reraIndex != null) input.reraIndex = String.valueOf(reraIndex);
                        if (previousQuoteLines.get(0).Price_Schedule__r.Rate_Cap__c != null) input.rentCap = String.valueOf(previousQuoteLines.get(0).Price_Schedule__r.Rate_Cap__c);
                    }

                    List<PricingEngine.PricingPackage> pricingPackages = PricingEngine.getPricingPackages(new List<PricingEngine.Input>{input});
                    PricingEngine.PricingPackage pricingPackage = pricingPackages.get(0);
                    system.debug('pricingPackage======='+pricingPackage);
                    Date qliStartDate; 
                    Date qliEndDate; 
                    if(quote.Proposed_Start_Date__c.monthsBetween(quote.Proposed_End_Date__c) > 12) {
                        qliStartDate = quote.Proposed_Start_Date__c;
                        qliEndDate = quote.Proposed_Start_Date__c.addYears(1);  
                        System.debug('>12');
                    }
                    else {
                        qliStartDate = quote.Proposed_Start_Date__c;
                        qliEndDate = quote.Proposed_End_Date__c;
                        System.Debug('<12');
                    }                    
                    // Generate quote line item
                    QuoteLineItem quoteLineItem = new QuoteLineItem(
                        QuoteId = quoteId,
                        PricebookEntryId = pbEntry.Id,
                        UnitPrice = pbEntry.UnitPrice,
                        Quantity = 1,
                        Area__c = product.Unit__r.Area_ft__c,
                        Best_Rate__c = 0,
                        End_Date__c = qliEndDate,
                        Start_Date__c = qliStartDate,
                        Offer_Price__c = 0,
                        Default_Grace_Period__c = 0,
                        Default_Grace_Period_Format__c = 'days',
                        Default_Grace_Period_Mechanism__c = 'initial',
                        Transactional_Unit__c = product.Transaction_Unit__c                               
                    );
                    

                    List<QuoteLineItem> chargesRelatedQLIList = new List<QuoteLineItem> (); 
                    // Get rent price schedule from pricing package
                    if (pricingPackage.rates != null) {
                        for (Price_Schedule__c rate : pricingPackage.rates) {
                            
                            if (rate.Charge_Type__r.Name == 'Rent') {
                                quoteLineItem.Best_Rate__c = rate.Rate__c;
                                quoteLineItem.Offer_Price__c = rate.Rate__c;
                                quoteLineItem.Default_Grace_Period__c = rate.Grace_Period__c;
                                quoteLineItem.Default_Grace_Period_Format__c = rate.Grace_Period_Format__c;
                                quoteLineItem.Default_Grace_Period_Mechanism__c = rate.Grace_Period_Mechanism__c;
                                quoteLineItem.Price_Schedule__c = rate.Id;  
                                List<QuoteLineItem> itemList  = new List<QuoteLineItem>{quoteLineItem};
                                PricingUtils.calculateQuoteLineItemTotals(itemList);
                                quoteLineItem = itemList[0];
                            }
                            else {

                                QuoteLineItem quoteLineItem1 = new QuoteLineItem(
                                        QuoteId = quoteId,
                                        PricebookEntryId = pbEntry.Id,
                                        UnitPrice = pbEntry.UnitPrice,
                                        Quantity = 1,
                                        Area__c = product.Unit__r.Area_ft__c,
                                        Best_Rate__c = rate.Rate__c,
                                        End_Date__c = qliEndDate,
                                        Start_Date__c = qliStartDate,
                                        Offer_Price__c = rate.Rate__c,
                                        Default_Grace_Period__c = rate.Grace_Period__c,
                                        Default_Grace_Period_Format__c = rate.Grace_Period_Format__c,
                                        Default_Grace_Period_Mechanism__c = rate.Grace_Period_Mechanism__c,
                                        Price_Schedule__c = rate.Id,
                                        Transactional_Unit__c = product.Transaction_Unit__c
                                         //Parent_Quote_Line_Item__c = itemObj.Id
                                    );
                                chargesRelatedQLIList.add(quoteLineItem1);
                            } 
                        }
                    }
                    System.debug('quoteLineItem---'+quoteLineItem.Price_Schedule__c);
                    if(!Test.isRunningTest()){
                        if(quoteLineItem.Price_Schedule__c == Null){
                            throw new AuraHandledException('Quote Line Item do not have Price Schedule');
                        }
                    }
                    
                    // Generate and return line item
                    LineItem lineItem = new LineItem();
                    lineItem.quoteLineItem = quoteLineItem;
                    lineItem.pricingPackage = pricingPackages.get(0);
                    lineItem.unitId = product.Unit__c;//product.Name;
                    lineItem.unitName = product.Name;
                    lineItem.subCategory = product.Unit__r.Unit_Sub_Category__r.Name;
                    lineItem.chargesRelatedQLIList = chargesRelatedQLIList;

                    List<LineItem> lineItemUpdatedList = new List<LineItem>();
                    
                    if(lineItemList != null && 
                       !lineItemList.isEmpty())
                        lineItemUpdatedList = updateSelectedProductsBestRate(quote, lineItemList, totalLeaseArea);

                    lineItemUpdatedList.add(lineItem);
                    //lineItem.TotalPrice = 0;
                    return lineItemUpdatedList;
                }
            } else {
                throw new AuraHandledException('An active pricebook entry could not be found for this product or the quote may not have a pricebook');
            }
        } else {
            throw new AuraHandledException('Quote not found!');
        }
        return null;
    }

    /**
     *  @description remove and update best rate for selected products.
     *  @param  quoteId     Id of quote
     *  @param  lineItemList list of selected line item
     *  @return return list of selected products with updated best rate.
     */
    @AuraEnabled
    public static List<LineItem> removeAndUpdateSelectedProductsBestRate(Id quoteId, List<LineItem> lineItemList) {

        Quote quote = [SELECT  AccountId, Type__c, Status, Proposed_Start_Date__c, Proposed_End_Date__c, Previous_Quote__c, 
                        Pricebook2Id, Pricebook2.Name, Grace_period__c, Grace_Period_Period__c
                       FROM    Quote
                       WHERE   Id = :quoteId
                      ];

        Decimal totalLeaseArea = getExistingTotalLeasedArea(quote, lineItemList, null);

        return (updateSelectedProductsBestRate(quote, lineItemList, totalLeaseArea));

    }

    /**
     *  @description Update best rate for selected products.
     *  @param  quote     instance of quote
     *  @param  lineItemList list of selected line item
     *  @param  totalLeasedArea  Total leased area for quote
     *  @return return list of selected products with updated best rate.
     */
@TestVisible private static List<LineItem> updateSelectedProductsBestRate(Quote quote, List<LineItem> lineItemList, Decimal totalLeasedArea) {

        Set<Id> productIdSet = new Set<Id>();
        List<PricingEngine.PricingPackage> pricingPackages;
        for(LineItem itemObj : lineItemList) {
            productIdSet.add(itemObj.quoteLineItem.PricebookEntryId);
        } 

        Map<Id, PricebookEntry> priceBookEntryMap = new Map<Id, PricebookEntry> ([
                    SELECT  Product2Id, Product2.Name, Product2.Transaction_Unit__c, Product2.Unit__r.Name, Product2.Unit__r.Building__r.Plot__r.Business_Park__c, Product2.Unit__r.Building__r.Plot__r.Business_Park__r.Business_Park_Code__c,
                            Product2.Unit__r.Building__r.Building_Code__c,  Product2.Unit__r.Floor_Type__c, Product2.Unit__r.Unit_Sub_Category__c, Product2.Unit__r.Unit_Sub_Category__r.Name,
                            Product2.Unit__r.Unit_Sub_Category__r.Unit_Category__r.Name, Product2.Unit__r.Exclude_DEWA_Charges_Common_Area__c, Product2.Unit__r.Exclude_Cooling_Charges__c,
                            Product2.Unit__r.Asset_Class_Name__c, Product2.Unit__r.Area_ft__c, Product2.Unit__r.Building__r.Ownership_Type__c
                    FROM    PricebookEntry
                    WHERE   Id IN: productIdSet
                ]);

        Map<Id, List<QuoteLineItem>> productIdVsQLIMap = new Map<Id, List<QuoteLineItem>>();

        for(QuoteLineItem lineItemObj : [SELECT  Best_Rate__c, 
                                                 Price_Schedule__c, Type__c,
                                                 Price_Schedule__r.Rate_Cap__c, 
                                                 Quote.Proposed_Start_Date__c,
                                                 Offer_Price__c,
                                                 QuoteId, 
                                                 Product2Id
                                         FROM    QuoteLineItem 
                                         WHERE   QuoteId =: quote.Previous_Quote__c  AND
                                                 Product2Id IN :productIdSet AND
                                                 Type__c IN ('Normal','Revision')
                                         ORDER BY Start_Date__c ASC
                                       ]) {
                
            if(!productIdVsQLIMap.containsKey(lineItemObj.QuoteId)) {
                productIdVsQLIMap.put(lineItemObj.Product2Id, new List<QuoteLineItem> {lineItemObj});
            }
            else {
                productIdVsQLIMap.get(lineItemObj.Product2Id).add(lineItemObj);
            }
        }

        for(LineItem itemObj : lineItemList) {
             // Gather information to query pricing engine
            PricebookEntry priceBookEntryObj = priceBookEntryMap.get(itemObj.quoteLineItem.PricebookEntryId);
            PricingEngine.Input input = new PricingEngine.Input();
            input.businessPark = priceBookEntryObj.Product2.Unit__r.Building__r.Plot__r.Business_Park__r.Business_Park_Code__c;
            input.building = priceBookEntryObj.Product2.Unit__r.Building__r.Building_Code__c;
            input.floorNumber = priceBookEntryObj.Product2.Unit__r.Floor_Type__c;
            input.utility = priceBookEntryObj.Product2.Unit__r.Exclude_DEWA_Charges_Common_Area__c ? false : true;
            input.cooling = priceBookEntryObj.Product2.Unit__r.Exclude_Cooling_Charges__c ? false : true;
            input.assetClass = priceBookEntryObj.Product2.Unit__r.Asset_Class_Name__c;
            input.productCategory = priceBookEntryObj.Product2.Unit__r.Unit_Sub_Category__r.Unit_Category__r.Name;
            input.productSubcategory = priceBookEntryObj.Product2.Unit__r.Unit_Sub_Category__r.Name;
            input.ownershipStatus = priceBookEntryObj.Product2.Unit__r.Building__r.Ownership_Type__c;
            input.transactionType = quote.Type__c;
            input.transactionDate = quote.Proposed_Start_Date__c;
            input.leaseTerm = String.valueOf(quote.Proposed_Start_Date__c.monthsBetween(quote.Proposed_End_Date__c));
            input.totalLeasedArea = String.valueOf(totalLeasedArea);

            List<QuoteLineItem> previousQuoteLines = productIdVsQLIMap.get(priceBookEntryObj.Product2Id);

            if (previousQuoteLines != null && !previousQuoteLines.isEmpty()) {
                Decimal initialBestRate = previousQuoteLines.get(0).Best_Rate__c;
                Decimal lastBestRate = previousQuoteLines.get(previousQuoteLines.size()-1).Best_Rate__c;
                Decimal lastPassingRate = previousQuoteLines.get(previousQuoteLines.size()-1).Offer_Price__c;
                Decimal reraIndex = getRERAIndex(priceBookEntryObj.Product2.Unit__r.Building__r.Plot__r.Business_Park__c,
                                                 previousQuoteLines.get(0).Quote.Proposed_Start_Date__c, 
                                                 lastBestRate,
                                                 priceBookEntryObj.Product2.Unit__r.Unit_Sub_Category__c);

                if (initialBestRate != null) input.initialBestRate = String.valueOf(initialBestRate);
                if (lastBestRate != null) input.lastBestRate = String.valueOf(lastBestRate);
                if (lastPassingRate != null) input.lastPassingRate = String.valueOf(lastPassingRate);
                if (reraIndex != null) input.reraIndex = String.valueOf(reraIndex);
                if (previousQuoteLines.get(0).Price_Schedule__r.Rate_Cap__c != null) input.rentCap = String.valueOf(previousQuoteLines.get(0).Price_Schedule__r.Rate_Cap__c);
            }

            pricingPackages = PricingEngine.getPricingPackages(new List<PricingEngine.Input>{input});
            

        }

        Integer count = 0;
        for(LineItem itemObj : lineItemList) {

            PricingEngine.PricingPackage pricingPackageObj = pricingPackages[count];
            if (pricingPackageObj.rates != null) {
                for (Price_Schedule__c rate : pricingPackageObj.rates) {
                    if (rate.Charge_Type__r.Name == 'Rent') {
                        itemObj.quoteLineItem.Best_Rate__c = rate.Rate__c;
                        itemObj.quoteLineItem.Offer_Price__c = itemObj.changedOfferedRate != null ? 
                            								   itemObj.changedOfferedRate : rate.Rate__c;
                        itemObj.quoteLineItem.Default_Grace_Period__c = rate.Grace_Period__c;
                        itemObj.quoteLineItem.Default_Grace_Period_Format__c = rate.Grace_Period_Format__c;
                        itemObj.quoteLineItem.Default_Grace_Period_Mechanism__c = rate.Grace_Period_Mechanism__c;
                        itemObj.quoteLineItem.Price_Schedule__c = rate.Id;  

                        List<QuoteLineItem> itemList  = new List<QuoteLineItem>{itemObj.quoteLineItem};
                        PricingUtils.calculateQuoteLineItemTotals(itemList);
                        itemObj.quoteLineItem = itemList[0];
                    }
                }
            }
        }
        return lineItemList;
    }

    /**
     *  @description Validate fields on Quote have values
     *  @param  quote   Quote record
     */
    private static void validateQuote(Quote quote) {
        if (quote.Proposed_End_Date__c == null || quote.Proposed_Start_Date__c == null) {
            throw new AuraHandledException('Please, fill in the quote\'s lease start/end and proposed start date');
        } else if (String.isBlank(quote.Type__c)) {
            throw new AuraHandledException('Please, fill in the quote\'s type');
        }
    }
    
    /**
     *  @description Function that returns the RERA Index for a specific product/date/rate
     *  @param  product     Product to filter by
     *          startDate   Start of the lease
     *          rate        Current rate
     *  @return Decimal with percent increase
     */
    private static Decimal getRERAIndex(String businesPark, Date startDate, Decimal rate, String unitSubCategory){
        if (businesPark != null && startDate != null && unitSubCategory != null) {
            List<Rate_Increase_Index__c> rateIncreaseIndexes = [
                SELECT  Percent_Increase__c
                FROM    Rate_Increase_Index__c 
                WHERE   Business_Park__c = : businesPark AND // product.Unit__r.Building__r.Plot__r.Business_Park__c AND
                        (Unit_Sub_Category__c = null OR Unit_Sub_Category__c = :unitSubCategory) AND //product.Unit__r.Unit_Sub_Category__c AND
                        Effective_Date_From__c <= :startDate AND
                        (Effective_Date_To__c = null OR Effective_Date_To__c >= :startDate) AND
                        (Current_Rate_From__c =null OR Current_Rate_From__c <= :rate) AND
                        (Current_Rate_To__c = null OR Current_Rate_To__c >= :rate)
                LIMIT 1
            ];
            if(!rateIncreaseIndexes.isEmpty()){
                return rateIncreaseIndexes.get(0).Percent_Increase__c;
            }
        }
        return 0;
    }
    /**
     *  @description Function that return QLI with updated Total offered price rate
     *  @param  lineItem    lineItem to update
     *  @return LineItem wrapper instance.
     */
    @AuraEnabled
    public static LineItem getTotalOfferedPrice(LineItem li) {
        System.debug('----li---'+li);
        //LineItem lineItemObj = (LineItem) JSON.deserialize(lineItem, LineItem.class);
        List<QuoteLineItem> itemList  = new List<QuoteLineItem>{li.quoteLineItem};
        PricingUtils.calculateQuoteLineItemTotals(itemList);
        li.quoteLineItem = itemList[0];
        
        return li;
    }
    
    /**
     *  @description Function that total leased area for passed quote and QLI.
     *  @param  quoteObj     Quote instance
     *  @param  lineItemList list fo line items
     *  @param  productObj     instance of product
     *  @return decimal total leased area.
     */
    private static Decimal getExistingTotalLeasedArea(Quote quoteObj, List<LineItem> lineItemList, Product2 productObj) {

        Decimal existingTotalLeasedArea = 0;
        Decimal proposedTotalLeasedArea = 0;
        
        Map<Id, Decimal> accountIdVsTotalLeasedAreaMap = 
                         PricingUtils.getTotalLeaseAreaForEachQuote(new Map<Id, Quote> {quoteObj.Id => quoteObj});

        existingTotalLeasedArea = accountIdVsTotalLeasedAreaMap.containsKey(quoteObj.AccountId) ? 
                                  accountIdVsTotalLeasedAreaMap.get(quoteObj.AccountId) : 0;

        if(lineItemList != null) {
            for(LineItem itemObj : lineItemList) {
                if(itemObj.quoteLineItem.Area__c != null) {
                    proposedTotalLeasedArea += itemObj.quoteLineItem.Area__c;
                }
            }
        }
        if(productObj != null && 
           productObj.Unit__r.Area_ft__c != null)
            proposedTotalLeasedArea += productObj.Unit__r.Area_ft__c;

        for(QuoteLineItem itemObj: [SELECT Id, Area__c
                                    FROM QuoteLineItem
                                    WHERE QuoteId =: quoteObj.Id
                                    AND Type__c = 'Normal'
                                    AND Parent_Quote_Line_Item__c = null
                                  ]) {
            if(itemObj.Area__c != null) {
                proposedTotalLeasedArea += itemObj.Area__c;
            }
        }
        
        return (existingTotalLeasedArea + proposedTotalLeasedArea);
    }
    
    /*Wrapper class to store Category and List of its related sub category*/
    public class CategorySubCategoryWrapper{
        @AuraEnabled
        Unit_Category__c unitCategory{get;set;}
        @AuraEnabled
        List<SubCategory> subCategory{get;set;}
        @AuraEnabled
        List<Id> buildingIdsList{get;set;}
        @AuraEnabled
        Set<Id> unitIdSet{get;set;} 
        public CategorySubCategoryWrapper(){
            unitCategory = new Unit_Category__c();
            subCategory = new List<SubCategory>();
            buildingIdsList = new List<Id>();
            unitIdSet = new Set<Id>();
        }
    }
    
    /*Wrapper class to store sub category in the Label,Value format*/
    public class SubCategory implements Comparable{
        @AuraEnabled
        public String label{get;set;}
        @AuraEnabled
        public String value{get;set;}
        
        public SubCategory(String l,String v){
            label = l;
            value = v;
        }
        public  Integer compareTo(Object compareTo) {
            SubCategory compareToEmp = (SubCategory)compareTo;
            if (value == compareToEmp.value) return 0;
            if (value > compareToEmp.value) return 1;
            return -1;        
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
        //@AuraEnabled public String totalPrice {get;set;}
    }
}