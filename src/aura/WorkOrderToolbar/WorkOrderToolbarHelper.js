({
    loadData : function(component, event, helper) {
        var wo = component.get("v.workOrderRecord");
        component.set("v.msg","alksnflkasdnflkasjdf");
        if((wo.Account.Legal_Framework__c!='Freelancer') && (!wo.IsMovedToNextStep__c) && (wo.Status=='Call for Review' ||wo.Status=='Draft' || wo.Status=='Bank Letter Issued')){
            if(wo.Account.Security_Clearance_Status__c=='Approved' && wo.Account.Business_Plan_Request_Date_Approval_Date__c!=null){
                component.set("v.IsMoveToNextVisible",true);
            }
        }else if((wo.Account.Legal_Framework__c=='Freelancer') && (!wo.IsMovedToNextStep__c) && (wo.Status=='Call for Review' || wo.Status=='Payment Completed' || wo.Status=='Bank Letter Issued')){
            if(wo.Account.Security_Clearance_Status__c=='Approved'){
                component.set("v.IsMoveToNextVisible",true);
            }
        }else{
            component.set("v.IsMoveToNextVisible",false);
        }
    },
    
    getData : function(component, event, helper) {
		var action = component.get("c.getWorkOrderDetails");
        action.setParams({
            "workOrderId": component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var wOrder = response.getReturnValue();
            component.set("v.workorder",wOrder);
            this.showHideButtons(component, event, helper);
        });
        $A.enqueueAction(action);
    },
    
    getSettings : function(component, event, helper) {
		var action = component.get("c.getStatusSettings");
        action.setCallback(this, function(response) {
            var res = response.getReturnValue();
            component.set("v.settings",res);
            this.getData(component, event, helper);
        });
        $A.enqueueAction(action);
    },
    
    showHideButtons : function(component, event, helper){
        var wOrder = component.get("v.workorder");
        var allSettings = component.get("v.settings");
        var statusSetting;
        for (var i = 0; i < allSettings.length; i++) {
            statusSetting = allSettings[i];
            var legalFramework = ""+statusSetting.Legal_Framework__c;
            if(statusSetting.Status__c === wOrder.Status && legalFramework.includes(wOrder.Account.Legal_Framework__c)){
                break;
            }
        }
        
        if(wOrder.IsMovedToNextStep__c!=true){
            if(wOrder.Account.Security_Clearance_Status__c==='Approved' && wOrder.Account.Business_Plan_Request_Date_Approval_Date__c != 'undefined'){
                component.set("v.IsMoveToNextVisible",statusSetting.Move_To_Next_Status__c);
            }
        }
        
        if(wOrder.IsMovedToNextStep__c != true && wOrder.Account_Type__c === 'Trust Account' && wOrder.Trust_Account_Payments_Received__c <  wOrder.Minimum_Required_Share_Capital__c){
            component.set("v.IsMoveToNextVisible",false);
        }
        
        if(wOrder.IsMovedToNextStep__c != true && statusSetting.Convert_To_Trust_Account__c && wOrder.Account_Type__c != 'Trust Account'){            
            component.set("v.IsConvertTrustAccountVisible",true);
        }
    },
    
    moveToNextStep : function(component, event, helper) {
		var action = component.get("c.sendUpdateToDDA");
        var wOrder = component.get("v.workorder");
        action.setParams({
            "workOrderId": wOrder.Id,
            "convertToTrust" : false,
            "isMoveToNext" : true
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                //location.reload();
                var errorMessage = ""+response.getReturnValue();
                if(errorMessage === ""){
                    //component.set("v.msg","No error message.");
                    location.reload();
                }else{
                    if(errorMessage.includes("registered")){
                        this.getUnits(component, event, helper);
                    }
                    component.set("v.msg",errorMessage);
                    //component.set("v.IsMoveToNextVisible",false);
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    convertToTrust : function(component, event, helper) {
		var action = component.get("c.sendUpdateToDDA");
        var wOrder = component.get("v.workorder");
        action.setParams({
            "workOrderId": wOrder.Id,
            "convertToTrust" : true,
            "isMoveToNext" : false
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                //location.reload();
                var errorMessage = ""+response.getReturnValue();
                if(errorMessage === ""){
                    component.set("v.msg","No error message.");
                }else{
                    component.set("v.msg",errorMessage);
                    //component.set("v.IsConvertTrustAccountVisible",false);
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    getUnits : function(component, event, helper) {
		var action = component.get("c.getQuoteProducts");
        var wOrder = component.get("v.workorder");
        action.setParams({
            "workOrder": wOrder
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                component.set("v.units",response.getReturnValue());
                component.set("v.selectRegAddress",true);
            }
        });
        $A.enqueueAction(action);
    },
    
    updateRegAddress : function(component, event, helper) {
        var action = component.get("c.updateRegisteredAddress");
        var unitId = component.get("v.selectedUnitId");
        action.setParams({
            "qLineId": unitId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                component.set("v.msg","");
                component.set("v.successMsg","Registered address is updated.");
                component.set("v.selectRegAddress",false);
            }
        });
        $A.enqueueAction(action);
    }
})