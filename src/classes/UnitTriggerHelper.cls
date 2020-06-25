/***********************************************************************************************
* Name              : UnitTriggerHelper                                                 
* Description       : UnitTriggerHelper class is a helper class for UnitTrigger.
* Created Date      : 19/05/2019                                                    
* Created By        : Prachi Sinha (prachi.sinha@were4c.com)                                                                                                    
* ----------------------------------------------------------------------------------------------
* VERSION   Developer   Date        Description     Ticket/Reference                                                                    
* 1.0       Prachi      19/05/2019   Created 
* 2.0      Raza         28/07/2019   Update         Map the unit sub category based on the yardi yardi code 
                                                    from the unit sub category
************************************************************************************************/
public with sharing class UnitTriggerHelper{

    /************************************************************************************
    Method  :         populateUnitSubCategory
    Description :     populate unit subcategory lookup field based on the unitsubcategory name field - before insert
    Version :         1.0
                      20 - Update the unit subcategory based on the yardi subcategory code
    ************************************************************************************/
    public static Boolean isUpdate = true;
    public static Boolean isInsert = true;
    public static void populateUnitSubCategory(List<Unit__c> unitList){
      
        List<String> categoryCombination = new List<String>();
         for(Unit__c unit: unitList){
            if(unit.Category_Combination__c  <> null){
                categoryCombination.add(unit.Category_Combination__c);
            }
         }
    
        List<Unit_Sub_Category__c> unitSubcategoryList = [select id, Name,Yardi_SubCategory_Code__c from Unit_Sub_Category__c 
                                                          where Yardi_SubCategory_Code__c in :categoryCombination ];
        Map<String,Id> subcategoryYardiCodeMap = new Map<String,Id>();
        
        //subcategory Yardi Code can never be duplicate
        for(Unit_Sub_Category__c subcategoryRec : unitSubcategoryList){
            subcategoryYardiCodeMap.put(subcategoryRec.Yardi_SubCategory_Code__c,subcategoryRec.Id);
        }
        
        for(Unit__c unitRec: unitList){
            if(unitRec.Category_Combination__c  <> null){
                if(subcategoryYardiCodeMap.get(unitRec.Category_Combination__c ) != null){
                    unitRec.Unit_Sub_Category__c = subcategoryYardiCodeMap.get(unitRec.Category_Combination__c );
                }else{
                    unitRec.addError(label.Unit_Sub_Category_Combination_Not_Found);
                }
            }
        }
    }
    
    /************************************************************************************
    Method  :         populateUnitSubCategoryUpdate 
    Description :     populate UnitSubCategory lookup field based on the UnitSubCategory name field - before update
    Version :         1.0
    ************************************************************************************/
    public static void populateUnitSubCategoryUpdate(List<Unit__c> unitNewList, Map<Id,Unit__c> unitOldMap){
    
        List<Unit__c> unitList = new List<Unit__c>();
        for(Unit__c unitRecord : unitNewList){
            if(unitOldMap.get(unitRecord.Id).Category_Combination__c != unitRecord.Category_Combination__c){
                unitList.add(unitRecord);
            }
        }
        
        if(unitList.size() > 0){
            populateUnitSubCategory(unitList);
        }                
    }
    
}