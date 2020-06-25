/************************************************************************************
* Name          : PriceRulePhysicalTabController                                                 
* Description   : Controller of PriceRulePhysicalTab.cmp
* Created Date  : 11/07/2019                                                    
* Created By    : 4C - Anshul Garg (anshul.garg@weare4c.com)
* Jira/Req By   :                                                                                                                                           
* -----------------------------------------------------------------------------------------------------------------------
* VERSION   Developer   Date        Description     Ticket/Reference    

************************************************************************************/
public class PriceRulePhysicalTabController {
	
    /**
     *  @description Fetches all the Business Park from the database and store them in Map
     *  @param  
     *  @return Searilized string of map which have Business Park
     */
    @AuraEnabled
    public static String getBusinessParkList(){
        Map<Id,Integer> plotBuildingCountMap = new Map<Id,Integer>();
        List<Plot__c> plotList = new List<Plot__c>();
        List<Business_Park__c> businessParkList = new List<Business_Park__c>();
        List<Map<String,Object>> businessParkMapList = new List<Map<String,Object>>();
        Set<Id> plotIdSet = new Set<Id>();

        businessParkList = [SELECT   Id
                            		,Name
                            		,Business_Park_Code__c
                            		,(SELECT Id FROM Buildings__r)
                            		,(SELECT Id FROM Plots__r) 
                            FROM Business_Park__c
                            WHERE Business_Park_Code__c != NULL];
        
        for(Business_Park__c bp : businessParkList){
            if(!bp.Plots__r.isEmpty()){
                for(Plot__c p : bp.Plots__r){
                    plotIdSet.add(p.Id);
                }
            }
        }
        
        plotList = [SELECT 	 Id
                    		,(SELECT Id FROM Buildings__r) 
                    FROM Plot__c];
        
        for(Plot__c p : plotList){
            if(!p.Buildings__r.isEmpty()){
                plotBuildingCountMap.put(p.Id,p.Buildings__r.size());
            }
        }
        
        for(Business_Park__c bp : businessParkList){
            Map<String,Object> coulmnValueMap = new Map<String,Object>();
            coulmnValueMap.put('id',bp.id);
            coulmnValueMap.put('name',bp.name);
            coulmnValueMap.put('code',bp.Business_Park_Code__c);
            if(!bp.Buildings__r.isEmpty()){
                coulmnValueMap.put('_children',new List<Map<String,Object>>());
            }else{
                if(!bp.Plots__r.isEmpty()){
                    for(Plot__c p : bp.Plots__r){
                        if(plotBuildingCountMap.containsKey(p.Id)){
                            coulmnValueMap.put('_children',new List<Map<String,Object>>());
                        }
                    }
                }
            }
            businessParkMapList.add(coulmnValueMap);
        }
        system.debug('businessParkMapList----'+businessParkMapList);
        return JSON.serialize(businessParkMapList);
    }
    
    /**
     *  @description Fetches all the Building related to business park and plots related to it
     *  @param  Id Recieves the Id of business park for which building has to be returned
     *  @return Searilized string of map which have Buildings
     */
    @AuraEnabled
    public static String getBuildings(Id bpId){
        Map<String,Object> businessParkIdBuildingMap = new Map<String,Object>();
        List<Building__c> buildingList = new List<Building__c>();
        List<Plot__c> plotList = new List<Plot__c>();
		List<Map<String,String>> coulmnValueMapList = new List<Map<String,String>>();
        Set<Id> plotIdSet = new Set<Id>();
        
        plotList = [SELECT Id FROM Plot__c where Business_Park__r.Id = :bpId];
        
        if(!plotList.isEmpty()){
            for(Plot__c p : plotList){
                plotIdSet.add(p.Id);
            }
        }
        
        buildingList = [SELECT 	 Id
                        		,Name
                        		,Building_Code__c 
                        FROM  Building__c 
                        WHERE (Business_Park__c = :bpId OR Plot__r.Id IN :plotIdSet)
                       	AND Building_Code__c != NULL];
        
        for(Building__c build : buildingList){
            Map<String,String> coulmnValueMap = new Map<String,String>();
            coulmnValueMap.put('id',build.Id);
            coulmnValueMap.put('name',build.Name);
            coulmnValueMap.put('code',build.Building_Code__c);
            coulmnValueMapList.add(coulmnValueMap);
        }
        businessParkIdBuildingMap.put(String.valueOf(bpId),coulmnValueMapList);
        return JSON.serialize(businessParkIdBuildingMap);
    }
    
    /**
     *  @description Saves The 
     *  @param  Id 					  Recieves the Id of Price Rule for which Business Park and Buildings are saved
     * 			selectedBusinessPark  semicolon seperated code of all the selected Business park
     * 			selectedBuilding  	  semicolon seperated code of all the selected buildings
     *  @return Do not return anything
     */
    @AuraEnabled 
    public static void saveValuesOnPriceRule(Id recId,String selectedBusinessPark,String selectedBuilding){
        Set<String> buildingCodeSet = new Set<String>(selectedBuilding.split(';'));
        System.debug('buildingCodeSet---'+buildingCodeSet);
        Set<String> businessCodeSet = new Set<String>();
        if(!String.isBlank(selectedBusinessPark))businessCodeSet.addAll(selectedBusinessPark.split(';'));
        System.debug('businessCodeSet----'+businessCodeSet);
        System.debug('businessCodeSet--size--'+businessCodeSet.size());
        Price_Rule__c prIns = [SELECT  Id
                               , Business_Park_Value__c
                               , Building_Value__c
                               FROM  Price_Rule__c
                               WHERE Id = :recId];
        List<Building__c> selectedBuildingList = [SELECT Id
                                                  , Business_Park__r.Name
                                                  , Business_Park__r.Id
                                                  , Business_Park__r.Business_Park_Code__c
                                                  FROM  Building__c
                                                  WHERE Building_Code__c IN :buildingCodeSet];
        if(!selectedBuildingList.isEmpty()){
            for(Building__c build : selectedBuildingList){
                if(build.Business_Park__r.Business_Park_Code__c != NULL)
                businessCodeSet.add(build.Business_Park__r.Business_Park_Code__c);
            }
        }
        System.debug('businessCodeSet----'+businessCodeSet);
        System.debug('businessCodeSet--size--'+businessCodeSet.size());
        prIns.Business_Park_Value__c = String.join(new List<String>(businessCodeSet),';').removeEnd(';');
        prIns.Building_Value__c =  selectedBuilding;
        prIns.Building_Operator__c = selectedBuilding.split(';').size() > 1 ? 'include' : 'equal';
        prIns.Business_Park_Operator__c = businessCodeSet.size() > 1 ? 'include' : 'equal';
        update prIns;
        
    }
    
    /**
     *  @description Finds out the id of selected building and business park on Price Rule
     *  @param  prId Recieves the Id of Price Rule 
     *  @return Return the list of string of of Ids of saved Business park and building on Price Rule
     */
    @AuraEnabled
    public static List<String> getSelectedRowsId(Id prId){
        List<String> selectedRowsList = new List<String>();
        List<Business_Park__c> bpList = new list<Business_Park__c>();
        List<Building__c> buildList = new list<Building__c>();
        
        Price_rule__c pr = [SELECT 	Business_Park_Value__c 
                            	   ,Building_Value__c 
                            FROM Price_rule__c 
                            WHERE Id =:prId];
        
        if(!String.isBlank(pr.Business_Park_Value__c)){
            List<String> bpCodeList = new List<String>();
            bpCodeList = pr.Business_Park_Value__c.split(';');
            bpList = [SELECT Id from Business_Park__c where Business_Park_Code__c IN :bpCodeList];
        }
        if(!String.isBlank(pr.Building_Value__c)){
            List<String> buildCodeList = new List<String>();
            buildCodeList = pr.Building_Value__c.split(';');
            buildList = [SELECT Id from Building__c where Building_Code__c IN :buildCodeList];
        }
        
        for(Building__c build : buildList){
            selectedRowsList.add(String.valueOf(build.Id));
        }
        for(Business_Park__c bp : bpList){
            selectedRowsList.add(String.valueOf(bp.Id));
        }
        
        return selectedRowsList;
    }
}