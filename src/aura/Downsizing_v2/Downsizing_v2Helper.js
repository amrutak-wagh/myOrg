({
    fetchPageLayuts : function(component, event, helper){
        var action = component.get("c.fetchPageLayouts");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if(result != undefined){
					component.set("v.opportunityLayout", result.opportunityLayout);
                    component.set("v.quoteLayout", result.quoteLayout);
                    helper.hideLoader(component);
                }else{
                    helper.showPageMessage(component, '', 'No page layouts found.', 'error');
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
    
    proceedToQuoteInfo: function(component, event, helper){
        helper.showLoader(component);
        component.set("v.step", 2);
        setTimeout(function(){
			helper.hideLoader(component);
        }, 1000);
    },
    
    proceedToItemsRemoval: function(component, event, helper){
        var isValid = true;
        var terminationDateInput = component.find("terminationDate");
        if(!terminationDateInput.get("v.validity").valid){
            terminationDateInput.showHelpMessageIfInvalid();                
            isValid = false;
        }
        
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
                    for(var i=0; i<result.length; i++){
                        var obj = {};
                        obj.id = result[i].Id;
                        obj.Name = result[i].Product2.Name;
                        obj.SalesPrice = result[i].UnitPrice;
                        obj.Quantity = result[i].Quantity;
                        obj.TotalPrice = result[i].TotalPrice;
                        data.push(obj);
                    }
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
    
    initRemoveableQLIColumns : function(component, event, helper){
        component.set('v.removeableQuoteLineItemsColumns', [
            {label: 'Name', fieldName: 'Name', type: 'text'},
            {label: 'Sales Price', fieldName: 'SalesPrice', type: 'currency', cellAttributes: { alignment: 'left' }},
            {label: 'Quantity', fieldName: 'Quantity', type: 'number', cellAttributes: { alignment: 'left' }},
            {label: 'Total Price', fieldName: 'TotalPrice', type: 'currency', cellAttributes: { alignment: 'left' }},
            {label: 'Termination Date', fieldName: 'TerminationDate', type: 'date', cellAttributes: { alignment: 'left' }} 
        ]);
    },
    
    removeQuoteLineItems: function(component, event, helper){
        helper.initRemoveableQLIColumns(component, event, helper);
        helper.showLoader(component);
        setTimeout(function(){
            var data = [];
            var removeableItems = component.get("v.selectedQuoteLineItems");
            if(removeableItems != null){
                for(var i=0; i<removeableItems.length; i++){
                    var obj = {};
                    obj.id = removeableItems[i].id;
                    obj.Name = removeableItems[i].Name;
                    obj.SalesPrice = removeableItems[i].SalesPrice;
                    obj.Quantity = removeableItems[i].Quantity;
                    obj.TotalPrice = removeableItems[i].TotalPrice;
                    obj.TerminationDate = component.get("v.terminationDate");
                    data.push(obj);
                }
            }
            component.set("v.selectedQuoteLineItems", data);
	        component.set("v.step", 4);            
            helper.hideLoader(component);
        },1000);
    },
    
    doSave: function(component, event, helper){
        helper.showLoader(component);
        
        var selectedQuotes = [];
        var selectedQuoteLineItems = component.get("v.selectedQuoteLineItems");
        for(var i=0; i<selectedQuoteLineItems.length; i++){
            selectedQuotes.push(selectedQuoteLineItems[i].id);
        }

        var action = component.get("c.save");
        action.setParams({
            opportunityId: component.get("v.recordId"),
            terminationDate : component.get("v.terminationDate"),
            removeableQuoteLineItems : selectedQuotes.toString()       
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