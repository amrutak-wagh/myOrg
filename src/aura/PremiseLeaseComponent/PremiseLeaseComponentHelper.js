({
	checkForValidOppAndExecuteBatchHelper : function(component, event, helper) {
		 // Create the action
        var action = component.get("c.checkForValidOppAndExecuteBatch");
        //var qouteId = component.get("v.recordId");
        action.setParams({
             opportunityId: component.get("v.recordId")
        });
        // Add callback behavior for when response is received
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            if (state === "SUCCESS") {
                
                var result = response.getReturnValue();
                component.set("v.isOpenFlow", false);
                
                if(result == 'Success') {
                    helper.showPageMessage(component, '', 'Renewal Opportunity created Successfully.', 'success');
                    $A.get('e.force:refreshView').fire();
                }
                else {
                    //component.set('v.renewalProcessStatusMsg', result);
                    helper.showPageMessage(component, '', result, 'error');
                }   
                helper.hideLoader(component);
            }
            else {
                console.log("Failed with state: " + state);
            }
        });
        // Send action off to be executed
        $A.enqueueAction(action);
	},
    
    showPageMessage: function(component, title, message, type){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: title,
            message: message,
            type: type
        });
        toastEvent.fire();
    },
    
    showLoader : function(component) {
        component.set("v.showLoader", true);
    },
    
    hideLoader: function(component){
        component.set("v.showLoader", false);
    }
})