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
                    helper.getBuildingInfo(component, event, helper);
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
            var leaseStartDate = component.find("LeaseStartDate").get("v.value");
            var leaseEndDate = component.find("LeaseEndDate").get("v.value");
            var expansionLeaseTerm = component.get('v.opportunityInfo').Expansion_Separate_Amendment_Terms__c;
            if(leaseStartDate == '' || leaseStartDate == undefined || leaseStartDate == null){
                helper.showPageMessage(component, '', 'Please provide lease start date.', 'error');
                return;
            }
            if(expansionLeaseTerm == '' || expansionLeaseTerm == undefined || expansionLeaseTerm == null) {
                helper.showPageMessage(component, '', 'Please provide Expansion Separate Amendment Terms', 'error');
                return;
            }
            if(leaseStartDate >= leaseEndDate) {
                helper.showPageMessage(component, '', 'Please provide lease start date less than end date.', 'error');
                return;
            }
            component.set("v.pageTitle", "Expansion Process - Add New Units");
            helper.proceedToItemsAddition(component, event, helper);   
        }else{
            helper.doSave(component, event, helper);
        }
    },
    
    back: function(component, event, helper){
        component.set("v.step", component.get("v.step") - 1);
        var step = component.get("v.step");
        if(step == 1){
            component.set("v.pageTitle", "Expansion Process - Opportunity Details");
        }else if(step == 2){
            component.set("v.pageTitle", "Expansion Process - Add New Units");
        }
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