({
	getContractDetails : function(component, event, helper) {
		//component.set("v.isOpenFlow",true);
        var action = component.get("c.getContractDetailApcx");
        action.setParams({
            contractId: component.get("v.recordId")     
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
				if(result){
                    
					var flow = component.find("terminationFlow");
                    var inputVariables = [
                        {
                            name : "recordId",
                            type : "String",
                            value : component.get("v.recordId")
                        },
                        {
                            name : "oppRecId",
                            type : "String",
                            value : result
                        }
                    ];
                    // In that component, start your flow. Reference the flow's Unique Name.
                    
                    flow.startFlow("Lease_Termination_Case_Validation", inputVariables );
                }else{
                    var flow = component.find("terminationFlow");
                    var inputVariables = [
                        
                        {
                            name : "oppRecId",
                            type : "String",
                            value : component.get("v.recordId")
                        }
                    ];
                    // In that component, start your flow. Reference the flow's Unique Name.
                    
                    flow.startFlow("Lease_Termination_Case_Validation", inputVariables );
                    /*helper.showPageMessage(component, '', 'No contract record found for this Opportunity.', 'error');
                    $A.get("e.force:closeQuickAction").fire();
                    $A.get('e.force:refreshView').fire();*/
                }
            }else if (state === "ERROR") {
                var errors = response.getError();
                alert(errors);
                console.log( errors );
            }
        });
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
    }
})