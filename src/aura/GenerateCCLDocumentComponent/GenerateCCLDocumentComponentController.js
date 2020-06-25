({
	    // Load expenses from Salesforce
    doInit: function(component, event, helper) {
        
        // Create the action
        var action = component.get("c.createDocument");
        //var qouteId = component.get("v.recordId");
        action.setParams({
             qouteId: component.get("v.recordId")
        });
        // Add callback behavior for when response is received
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            if (state === "SUCCESS") {
                //component.set("v.documents", response.getReturnValue());
                var result = response.getReturnValue();
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
    			dismissActionPanel.fire();
                
                if(result == 'Success') {
                    helper.showPageMessage(component, '', 'The CCL Document has been created successfully.', 'success');
                    $A.get('e.force:refreshView').fire();

                }
                else {
                    helper.showPageMessage(component, '', result, 'error');
                }
                
            }
            else {
                console.log("Failed with state: " + state);
            }
        });
        
        
    
        
        // Send action off to be executed
        $A.enqueueAction(action);
    }
})