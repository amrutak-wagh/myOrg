({
    fetchPageLayuts : function(component, event, helper){
        var action = component.get("c.fetchPageLayouts");
        action.setParams({
            recordId: component.get("v.recordId"),
            quoteId: component.get("v.quoteId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if(result != undefined){
					//component.set("v.opportunityLayout", result.opportunityLayout);
                    //component.set("v.quoteLayout", result.quoteLayout);
                    component.set("v.MinStartDate", result.oppInfo.Lease_Start_Date__c);
                    component.set("v.opportunityInfo", result.oppInfo);
                    if(result.quotelineItems != undefined){
                        var excludedUnits = [];
                        for(var i=0; i<result.quotelineItems.length; i++){
                            excludedUnits.push(result.quotelineItems[i].Product2.Unit__r.Id);
                        }
                        component.set("v.excludedUnits", excludedUnits);
                    }
                    helper.hideLoader(component);
                }else{
                    helper.showPageMessage(component, '', 'Error retrieving opportunity info.', 'error');
                    $A.enqueueAction(component.get('c.cancel'));
                }
            }else if (state === "ERROR") {
                var errors = response.getError();
                alert(errors);
                helper.hideLoader(component);
                console.log( errors );
            }
        });
        $A.enqueueAction(action);
    },
    
    getBuildingInfo: function(component, event, helper){
		var action = component.get("c.fetchBuildingInfo");
        action.setParams({
            recordId: component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
				component.set("v.buildingOptions", result);
                component.set("v.selectedBuilding", result[0].value);
            }else if (state === "ERROR") {
                var errors = response.getError();
                alert(errors);
                helper.hideLoader(component);
                console.log( errors );
            }
        });
        $A.enqueueAction(action);
    },
    
    proceedToQuoteInfo: function(component, event, helper){
        helper.showLoader(component);
        component.set("v.step", 2);
        setTimeout(function(){
			helper.hideLoader(component);
        }, 1000);
    },
    
    proceedToItems: function(component, event, helper){
        var isValid = true;
        if(isValid){
            helper.showLoader(component);
            helper.initQLIColumns(component);
            var action = component.get("c.fetchQuoteLineItems");
            action.setParams({
                quoteId: component.get("v.quoteId")
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
					var data = [];
                    var excludedUnits = [];
                    for(var i=0; i<result.length; i++){
                        var obj = {};
                        obj.id = result[i].Id;
                        obj.Name = result[i].Product2.Name;
                        obj.SalesPrice = result[i].UnitPrice;
                        obj.Quantity = result[i].Quantity;
                        obj.TotalPrice = result[i].TotalPrice;
                        excludedUnits.push(result[i].Product2.Unit__r.Id);
                        data.push(obj);
                    }
                    component.set("v.excludedUnits", excludedUnits);
                    component.set("v.quoteLineItems", data);
                    component.set("v.step", 3);            
                    helper.hideLoader(component);
                }else if (state === "ERROR") {
                    var errors = response.getError();
                    alert(errors);
                    helper.hideLoader(component);
                    console.log( errors );
                }
            });
            $A.enqueueAction(action);
        }

    },
    
    initQLIColumns : function(component, event, helper){
        component.set('v.quoteLineItemsColumns', [
            {label: 'Name', fieldName: 'Name', type: 'text'},
            {label: 'Sales Price', fieldName: 'SalesPrice', type: 'currency', cellAttributes: { alignment: 'left' }},
            {label: 'Quantity', fieldName: 'Quantity', type: 'number', cellAttributes: { alignment: 'left' }},
            {label: 'Total Price', fieldName: 'TotalPrice', type: 'currency', cellAttributes: { alignment: 'left' }}
        ]);
    },
        
    proceedToItemsAddition: function(component, event, helper){
        helper.showLoader(component);
        setTimeout(function(){
	        component.set("v.step", 2);            
            helper.hideLoader(component);
        },1000);
    },
    
    doSave: function(component, event, helper){
		var newlyQLI = component.get("v.addedItems");
        var editableInfo = component.get("v.opportunityInfo");
        if(newlyQLI.length == 0){
        	helper.showPageMessage(component, '', 'Please add atleast one quote line item.', 'error');
            return;
        }
        
        helper.showLoader(component);
        var action = component.get("c.save");
        action.setParams({
            opportunityId: component.get("v.recordId"),
            lineItems : newlyQLI,
            oppInfo : editableInfo
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
				if(result == 'SUCCESS'){
                    helper.showPageMessage(component, '', 'Records has been successfully updated.', 'success');
                    $A.enqueueAction(component.get('c.cancel'));
                    //$A.get("e.force:closeQuickAction").fire();
                    $A.get('e.force:refreshView').fire();
                }else{
                    helper.showPageMessage(component, '', result, 'error');
	                helper.hideLoader(component);
                }
            }else if (state === "ERROR") {
                var errors = response.getError();
                alert(errors);
                helper.hideLoader(component);
                console.log( errors );
            }
        });
        $A.enqueueAction(action);
    },
    
    showLoader : function(component) {
        component.set("v.showLoader", true);
    },
    
    hideLoader: function(component){
        component.set("v.showLoader", false);
    },
    
    showPageMessage: function(component, title, message, type){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: title,
            message: message,
            type: type
        });
        toastEvent.fire();
    }
})