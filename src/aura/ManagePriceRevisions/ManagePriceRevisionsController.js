({
    doInit : function(component, event, helper) {
        helper.getLineItemsDetailsBySelectedFilter(component, event, helper, 'UnitProduct');
    },
    
    getLineItemsDetails : function(component, event, helper) {
        component.set("v.quoteLineItemList", []);
        var selectedFilter = component.get('v.selectedFilterValue');
        if(selectedFilter) {
            helper.getLineItemsDetailsBySelectedFilter(component, event, helper, selectedFilter);
        }
        else {
            component.set('v.quoteLineItemList', []);
        }	
	},
    
    next : function(component, event, helper) {
		helper.updateMainList(component, helper);        
        var pageNumber = component.get("v.currentPageNumber");
        component.set("v.currentPageNumber", pageNumber+1);
        helper.buildData(component, helper);
    },
    
    previous : function(component, event, helper) {  
        helper.updateMainList(component, helper);  
        var pageNumber = component.get("v.currentPageNumber");
        component.set("v.currentPageNumber", pageNumber-1);
        helper.buildData(component, helper);
    },
    
    navigateToPage : function(component, event, helper) {
        helper.updateMainList(component, helper);  
        component.set("v.currentPageNumber", parseInt(event.target.name));
        helper.buildData(component, helper);
    },
    
    cancel: function(component, event, helper){
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
          "recordId": component.get("v.recordId"),
          "slideDevName": "related"
        });
        navEvt.fire();
    },
    
    saveLineItem : function(component, event, helper) {
        
        var changesMade = component.get('v.changesMade');
        if(changesMade) {
            helper.saveLineItemHelper(component, event, helper);
        }
	}	
})