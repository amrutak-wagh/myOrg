/************************************************************************************
* Name          : DisplayContactAndChildCompController                                                 
* Description   : Controller of DisplayContactAndChildComp.cmp
* Created Date  :                                                    
* Created By    : 4C - Amruta K (amruta.kumbhakarn@weare4c.com)
* Jira/Req By   :                                                                                                                                           
* -----------------------------------------------------------------------------------------------------------------------
* VERSION   Developer   Date        Description     Ticket/Reference    

************************************************************************************/
public class DisplayContactAndChildCompController {
    /** CONSTANT Variables used throughout the class **/
    public static final String WO_STATUS_TO_SHOW_BUTTON = 'Rejected';
   	public static final String JSON_MAP_KEY = 'isbutton';
    public static final String JSON_MAP_VALUE_SHOW = 'slds-show';
    public static final String JSON_MAP_VALUE_HIDE = 'slds-hide';
    
    /**
     *  @description Performs the description on the Fiels set
     *  @param  objectApiName  Name of the object
     * 			nameFieldSet  Name of the  field set passed from Component
     *  @return Returns the List of fields from Field set with information
     */
    public static List<Schema.FieldSetMember> getFields(String objectApiName,String nameFieldSet) {
        
        SObjectType objToken = Schema.getGlobalDescribe().get(objectApiName);
        Schema.DescribeSObjectResult d = objToken.getDescribe();
        
        return  d.FieldSets.getMap().get(nameFieldSet).getFields();
    }
    
    /**
     *  @description Creates the map of String,Object for Case with all the child WOs
     *  @param  recordId  Id of the case record
     *  @return Returns the serialized string with all the information
     */
    @AuraEnabled
    public static String getCaseRecord(Id recordId){
        
        String caseFieldSetName = Label.CaseFieldSetName;
        String workOrderFieldSetName = Label.WorkOrderFieldSetName;
        FieldSetSobjectRecordWrapper instanceWrapper = new FieldSetSobjectRecordWrapper();
        String query = 'SELECT ';
        
        List<Schema.FieldSetMember> listFieldSetMembersCase = getFields('Case',caseFieldSetName);
        for(Schema.FieldSetMember f : listFieldSetMembersCase) {
            query += f.getFieldPath() + ', ';
            Schema.DescribeSObjectResult res = Schema.getGlobalDescribe().get('Case').getDescribe(); 
        	Map<String, Schema.FieldSet> fieldSetMap= res.fieldSets.getMap();
            Schema.DescribeFieldResult dfr = res.fields.getMap().get(f.getFieldPath()).getDescribe();
           	instanceWrapper.listFsmCase.add(dfr.name);
        }
        
        query += '(SELECT ';
        
        List<Schema.FieldSetMember> listFieldSetMembersWorkOrders = getFields('WorkOrder',workOrderFieldSetName);
        for(Schema.FieldSetMember f : listFieldSetMembersWorkOrders) {
            query += f.getFieldPath() + ', ';
            Schema.DescribeSObjectResult res = Schema.getGlobalDescribe().get('WorkOrder').getDescribe(); 
        	Map<String, Schema.FieldSet> fieldSetMap= res.fieldSets.getMap();
            Schema.DescribeFieldResult dfr = res.fields.getMap().get(f.getFieldPath()).getDescribe();
            instanceWrapper.listFsmWorkOrder.add(dfr);
        }
        
        query += 'Id,ParentWorkOrderId,RecordTypeId FROM WorkOrders),Account.Owner.Name,Account.Owner.Email,Account.Owner.Phone FROM Case WHERE ID='+'\''+recordId +'\'';
        
        Case caseRec = Database.query(query);
        instanceWrapper.caseInstance = caseRec;
        Map<Id,List<WorkOrder>> woVsWorkOrsChildrenMap = new Map<Id,List<WorkOrder>>();
        Map<Id,WorkOrder> mapIdWorkOrder = new Map<Id,WorkOrder>();
        
        Set<Id> setIdWorkOrs = new Set<Id>();
        
        for(WorkOrder workOrder:caseRec.WorkOrders){
            if(workOrder.ParentWorkOrderId == Null)
            	setIdWorkOrs.add(workOrder.Id);   
            
            mapIdWorkOrder.put(workOrder.Id, workOrder);
            instanceWrapper.mapIdRecordTypeId.put(workOrder.Id, workOrder.RecordTypeId);
        }
        System.debug('==========='+instanceWrapper.mapIdRecordTypeId);
        for(WorkOrder workOrder:caseRec.WorkOrders){
            if(workOrder.ParentWorkOrderId !=null){
                if(!woVsWorkOrsChildrenMap.containsKey(workOrder.ParentWorkOrderId)){
                    woVsWorkOrsChildrenMap.put(workOrder.ParentWorkOrderId, new List<WorkOrder>{workOrder}) ;
                }else{
                    woVsWorkOrsChildrenMap.get(workOrder.ParentWorkOrderId).add(workOrder);
                }
            }
        }
        
        for(Id workOrderId: setIdWorkOrs){
            //if(!masterRecordKeeper.keyset().contains(wo.Id)){
                Map<String,Object> mapJSONParam = new Map<String,Object>();
                WorkOrder wo = mapIdWorkOrder.get(workOrderId);
            	String workOrderToShowButton = 'Rejected';
                for(DescribeFieldResult dfr :instanceWrapper.listFsmWorkOrder){
                    mapJSONParam.put(dfr.name,wo.get(dfr.name));
                }
                if(wo.status == WO_STATUS_TO_SHOW_BUTTON){
                    mapJSONParam.put(JSON_MAP_KEY,JSON_MAP_VALUE_SHOW);
                }else{
                    mapJSONParam.put(JSON_MAP_KEY,JSON_MAP_VALUE_HIDE); 
                }
                mapJSONParam.put('id',wo.id);
            
                if(woVsWorkOrsChildrenMap.containsKey(wo.Id)){
                    if(!woVsWorkOrsChildrenMap.get(wo.Id).isEmpty()){
                        List<WorkOrder> childrenList = new List<WorkOrder>();
                        mapJSONParam.put('_children',getChildrenRecursively(wo,instanceWrapper, woVsWorkOrsChildrenMap));
                    }  
                }
                
                instanceWrapper.listmapWrapper.add(mapJSONParam);    
           // }
        }
        //instanceWrapper.mapIdRecordTypeId = masterRecordKeeper;
        
        return JSON.serialize(instanceWrapper);
    }
    
    /*Wrapper class to store field describe and generic map to display tree*/
    public class FieldSetSobjectRecordWrapper{
        @AuraEnabled
        public List<String> listFsmCase{get;set;}
        @AuraEnabled
        public List<DescribeFieldResult> listFsmWorkOrder{get;set;}
        @AuraEnabled
        public Case caseInstance {get;set;}
        @AuraEnabled
        public List<Map<String,Object>> listmapWrapper{get;set;}
        @AuraEnabled
        public Map<Id,Id> mapIdRecordTypeId{get;set;}
        public FieldSetSobjectRecordWrapper(){
            caseInstance = new Case();
            listFsmCase = new List<String>();
            listFsmWorkOrder = new List<DescribeFieldResult>();
            listmapWrapper = new List<Map<String,Object>>();
            mapIdRecordTypeId = new Map<Id,Id>();
        }
    }
    
    /**
     *  @description This method is a recursive method written to create Map of String,Object up to any level deep
     *  @param  parentWO Parent WO on which recursive method is called
     * 			instanceWrapper Wrapper instance of FieldSetSobjectRecordWrapper 
     * 			woVsWorkOrsChildrenMap  This map stores the work order id and its children Work orders in list
     *  @return Returns the Map of String,Object
     */
    public static List<Map<String,Object>> getChildrenRecursively(WorkOrder parentWO, FieldSetSobjectRecordWrapper instanceWrapper, Map<Id, List<WorkOrder>> woVsWorkOrsChildrenMap){
        
        List<WorkOrder> listChildrenWO = new List<WorkOrder>();
        List<Map<String,Object>> listInnerMap = new List<Map<String,Object>>();
        String workOrderToShowButton = 'Rejected';
        listChildrenWO = woVsWorkOrsChildrenMap.get(parentWO.Id) !=null ? woVsWorkOrsChildrenMap.get(parentWO.Id) : new List<WorkOrder>();//Database.query('Select ' + fields + ' FROM WorkOrder WHERE ParentWorkOrderId = '+'\''+WO.id+'\'');
        
        if(!listChildrenWO.isEmpty()){
            for(Workorder childWO : listChildrenWO){
                Map<String,Object> innerMap = new Map<String,Object>();
                for(DescribeFieldResult dfr :instanceWrapper.listFsmWorkOrder){
                    innerMap.put(dfr.name,childWO.get(dfr.name));
                } 
                if(childWO.status == WO_STATUS_TO_SHOW_BUTTON){
                    innerMap.put(JSON_MAP_KEY,JSON_MAP_VALUE_SHOW);
                }else{
                    innerMap.put(JSON_MAP_KEY,JSON_MAP_VALUE_HIDE); 
                }
                innerMap.put('id',childWO.id);
                
                List<WorkOrder> listchildWO = woVsWorkOrsChildrenMap.get(childWO.Id) !=null ? woVsWorkOrsChildrenMap.get(childWO.Id) : new List<WorkOrder>();//Database.query('Select ' + fields + ' FROM WorkOrder WHERE ParentWorkOrderId = '+'\''+ins.id+'\'');
                if(!listchildWO.isEmpty()){
                    innerMap.put('_children',getChildrenRecursively(childWO,instanceWrapper, woVsWorkOrsChildrenMap));
                }
                
                listInnerMap.add(innerMap);
            }
        }
        
        return listInnerMap;
    }
}