({

	doInit : function(component, event, helper) {
		helper.createCategoryFilter(component, event, helper);
        var addedQLI = component.get("v.newlyItems");
        if(component.get("v.isExpansion") && addedQLI.length > 0){
            component.set("v.lineItemList", addedQLI);
            helper.populateQuoteLinesForExpansion(component, event, helper);
        }
	},
    handleCancel : function(component, event, helper) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
          "recordId": component.get("v.recordId"),
          "slideDevName": "related"
        });
        navEvt.fire();
	},
    subCategoryValues : function(component, event, helper) {
        component.set("v.isWaiting",true);
        helper.getSubCategoryValues(component, event, helper);
	},
    floorForBuilding : function(component, event, helper) {
        component.set("v.isWaiting",true);
        helper.getFloorForBuilding(component, event, helper);
	},
    displayUnits : function(component, event, helper) {
        component.set("v.isWaiting",true);
        helper.findUnits(component, event, helper);
	},
    getfloorValue : function(component, event, helper){
        helper.floorValue(component, event, helper);
    },
    getLineItems : function(component, event, helper){
        component.set("v.isWaiting",true);
        helper.searchLineItems(component, event, helper);
    },
    removeQuoteLines : function(component, event, helper){
        component.set("v.isWaiting",true);
        helper.removeQuoteLines(component, event, helper);
    },
    onSave : function(component, event, helper){
        component.set("v.isWaiting",true);
        helper.onSave(component, event, helper);
    },
    
    updateTotalOfferPrice : function(component, event, helper) {
        component.set("v.isWaiting", true);
        helper.populateTotalOfferPrice(component, event, helper);
    }
})