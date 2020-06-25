({
	callExpansionProcess : function(component, event, helper) {

        component.set("v.runProcess", 'Expansion');
        component.set("v.isOpenComponent", true);
	},
    
    callDownsizingProcess : function(component, event, helper) {
        
        component.set("v.runProcess", 'Downsizing');
        component.set("v.isOpenComponent", true);
    },
    
    callAssignmentProcess : function(component, event, helper) {

         // Find the component whose aura:id is "flowData"
        component.set("v.isOpenFlow", true);
        component.set("v.runProcess", 'Assignment');
        var flow = component.find("assignmentFlow");
        var inputVariables = [
            {
                name : "recordId",
                type : "String",
                value : component.get("v.recordId")
            }
        ];
        // In that component, start your flow. Reference the flow's Unique Name.
        flow.startFlow("Create_Case", inputVariables );
    },
    
     callRenewalProcess : function(component, event, helper) {
        
          // Find the component whose aura:id is "flowData"
        component.set("v.isOpenFlow", true);
        helper.showLoader(component);
        
        component.set("v.runProcess", 'Renewal');
        var flow = component.find("renewalFlow");
        var inputVariables = [
            {
                name : "recordId",
                type : "String",
                value : component.get("v.recordId")
            }
        ];
        // In that component, start your flow. Reference the flow's Unique Name.
        //flow.startFlow("Create_Renewal_Opp_on_Button_Click", inputVariables );
        helper.checkForValidOppAndExecuteBatchHelper(component, event, helper);
    },
 
     callTerminationProcess : function(component, event, helper) {
        component.set("v.runProcess", 'Termination');
        component.set("v.isOpenComponent", true);
    },
 
    /*callModificationProcess : function(component, event, helper) {
        
        // Find the component whose aura:id is "flowData"
        component.set("v.isOpenFlow", true);
        component.set("v.runProcess", 'Modification');
        var flow = component.find("modificationFlow");
        var inputVariables = [
            {
                name : "recordId",
                type : "String",
                value : component.get("v.recordId")
            }
        ];
        // In that component, start your flow. Reference the flow's Unique Name.
        flow.startFlow("Create_Opportunity_with_Type_Modification", inputVariables );
    }, */
 
    closeCmpModel : function(component, event, helper) {
        component.set("v.isOpenComponent", false);
    },
    
     closeModel : function(component, event, helper) {
        component.set("v.isOpenFlow", false);
    },

    closeModalBox: function(component, event, helper){
        component.set("v.isOpenComponent", false);
        component.set("v.isOpenFlow", false);
    }
})