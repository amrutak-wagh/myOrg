/************************************************************************************
* Name          : PriceRuleCommercialTabController                                                 
* Description   : Controller of PriceRuleCommercialTab.cmp
* Created Date  : 12/07/2019                                                    
* Created By    : 4C - Anshul Garg (anshul.garg@weare4c.com)
* Jira/Req By   :                                                                                                                                           
* -----------------------------------------------------------------------------------------------------------------------
* VERSION   Developer   Date        Description     Ticket/Reference    

************************************************************************************/
public class PriceRuleCommercialTabController {
  	
     /**
     *  @description Saves the selected Record names on Price Rule as semicolon seperated strings
     *  @param  recId					Id of the price rule on which value needs to be saved
     * 			assetNameList			String of name of selected Asset Class records
     * 			categoryNameList		String of name of selected Unit Category records
     * 			subCategoryNameList		String of name of selected Unit Sub Category records
     * 			ownershipValue			String of selected values of ownership type picklist
     *  @return Do not return anything
     */
    @AuraEnabled 
    public static void saveValuesOnPriceRule(Id recId,String assetNameList,String categoryNameList,
                                             	String subCategoryNameList,String ownershipValue){
        Set<String> assetNameSet = !String.isBlank(assetNameList) ? new Set<String>(assetNameList.split(';')) : new Set<String>();
        Set<String> categoryNameSet = !String.isBlank(categoryNameList) ? new Set<String>(categoryNameList.split(';')) : new Set<String>();
        Set<String> subCategoryNameSet = !String.isBlank(subCategoryNameList) ? new Set<String>(subCategoryNameList.split(';')) : new Set<String>();
        System.debug('ownershipValue---'+ownershipValue);
       	ownershipValue = !String.isBlank(ownershipValue) ? ownershipValue.replace(',', ';') : '';                                            
        Price_Rule__c prIns = [SELECT  Id
                               		 , Asset_Class_Value__c
                               		 , Product_Category_Value__c
                               		 , Product_Sub_Category_Value__c
                               		 , Ownership_Status_Value__c
                               FROM  Price_Rule__c
                               WHERE Id = :recId];
        
        prIns.Ownership_Status_Value__c = ownershipValue;
        prIns.Product_Sub_Category_Value__c = String.join(new List<String>(subCategoryNameSet), ';');
        prIns.Product_Category_Value__c = String.join(new List<String>(categoryNameSet), ';');
        prIns.Asset_Class_Value__c = String.join(new List<String>(assetNameSet), ';');
        prIns.Asset_Class_Operator__c = assetNameSet.size() > 1 ? 'include' : 'equal';
        prIns.Product_Category_Operator__c = categoryNameSet.size() > 1 ? 'include' : 'equal';
        prIns.Product_Sub_Category_Operator__c = subCategoryNameSet.size() > 1 ? 'include' : 'equal';
        prIns.Ownership_Status_Operator__c = ownershipValue.split(';').size() > 1 ? 'include' : 'equal';                                            
        update prIns;
    }
    
     /**
     *  @description Pouplates the wrapper with the already selected values on price rule
     *  @param  prId Id of the price rule
     *  @return Wrapper containing list of selected records and ownership value on price rule
     */
    @AuraEnabled
    public static SelectedValue getSelectedValues(Id prId){
        List<Asset_Class__c> assetClassList = new List<Asset_Class__c>();
        List<Unit_Category__c> unitCategoryList = new List<Unit_Category__c>();
        List<Unit_Sub_Category__c> unitSubCatList = new List<Unit_Sub_Category__c>();
        
        Price_Rule__c pr = [SELECT 	Asset_Class_Value__c
                            	   ,Product_Category_Value__c
                            	   ,Ownership_Status_Value__c
                            	   ,Product_Sub_Category_Value__c 
                            FROM Price_Rule__c 
                            WHERE Id = :prId];
        if(!String.isBlank(pr.Asset_Class_Value__c))
        assetClassList = [SELECT Id,Name FROM Asset_Class__c WHERE Name IN :pr.Asset_Class_Value__c.split(';')];
        
        if(!String.isBlank(pr.Product_Category_Value__c))
        unitCategoryList = [SELECT Id,Name FROM Unit_Category__c WHERE Name IN :pr.Product_Category_Value__c.split(';')];
        
        if(!String.isBlank(pr.Product_Sub_Category_Value__c))
        unitSubCatList = [SELECT Id,Name FROM Unit_Sub_Category__c WHERE Name IN :pr.Product_Sub_Category_Value__c.split(';')];
        
        SelectedValue instance = new SelectedValue();
        instance.assetClassList = assetClassList;
        instance.unitCategoryList = unitCategoryList;
        instance.unitSubCatList = unitSubCatList;
        instance.selectedOwnership = !String.isBlank(pr.Ownership_Status_Value__c) ? pr.Ownership_Status_Value__c.split(';') : new List<String>();
        return instance;
    }
    
     /**
     *  @description Describe on Building Object to get the field values and put them in wrapper
     *  @param  
     *  @return List of Wrapper which have value of multiselect picklist
     */
    @AuraEnabled
    public static List<MultiPicklistWrapper> getOwnerShipOptionValue() {
        List<MultiPicklistWrapper> optionsList = new List<MultiPicklistWrapper>();
        Schema.DescribeFieldResult fieldResult = Building__c.Ownership_Type__c.getDescribe();
        List < Schema.PicklistEntry > values = fieldResult.getPicklistValues();
        
        for (Schema.PicklistEntry a: values) {
            MultiPicklistWrapper obj = new MultiPicklistWrapper();
            obj.label = a.getValue();
            obj.value = a.getValue();
            optionsList.add(obj);
        }
        return optionsList;
    }
    
    /*Wrapper to store the picklist options as label and value*/
    public class MultiPicklistWrapper{
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String value;
        public MultiPicklistWrapper(){
            label = '';
            value = '';
        }
    }
    
    /*Wrapper to store the selected value of Asset class,Unit Category,Unit Sub Category and Ownership type */
    public class SelectedValue{
        @AuraEnabled
        public List<Asset_Class__c> assetClassList;
        @AuraEnabled
        public List<Unit_Category__c> unitCategoryList;
        @AuraEnabled
        public List<Unit_Sub_Category__c> unitSubCatList;
        @AuraEnabled
        public List<String> selectedOwnership;
        public SelectedValue(){
            assetClassList = new List<Asset_Class__c>();
            unitCategoryList = new List<Unit_Category__c>();
            unitSubCatList = new List<Unit_Sub_Category__c>();
            selectedOwnership = new List<String>();
        }
    }
}