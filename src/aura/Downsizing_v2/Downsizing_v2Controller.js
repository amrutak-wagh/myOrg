({
	doInit : function(component, event, helper) {
        var action = component.get("c.getQuoteRecord");
        action.setParams({
            recordId: component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if(result.Id != undefined){
					component.set("v.quoteId", result.Id);
			        helper.fetchPageLayuts(component, event, helper);
                }else{
                    helper.showPageMessage(component, '', 'There are no synced quotes associated to opportunity.', 'error');
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
    
    next: function(component, event, helper){
        var step = component.get("v.step");
        if(step == 1){
            helper.proceedToQuoteInfo(component, event, helper);
        }else if(step == 2){
            helper.proceedToItemsRemoval(component, event, helper);
        }else if(step == 3){
         	helper.removeQuoteLineItems(component, event, helper);   
        }else{
            helper.doSave(component, event, helper);
        }
    },
    
    back: function(component, event, helper){
        component.set("v.step", component.get("v.step") - 1);
    },
    
    updateRemoveableSelection: function(component, event, helper){
        var selectedItems = event.getParam('selectedRows');
        var seletedQLI = [];
        for(var i=0; i<selectedItems.length; i++){
            seletedQLI.push(selectedItems[i].id);
        }
        component.set("v.removeableQuoteLineItems", seletedQLI);
        component.set("v.selectedQuoteLineItems", selectedItems);
    },
    
    cancel: function(component, event, helper){
        var p = component.get("v.parent");
        if(p != null){
            p.closeModalBox();
            component.set("v.hideModalClass", "slds-hide");            
        }
        $A.get("e.force:closeQuickAction").fire();
    }
})