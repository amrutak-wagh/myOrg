({
    // Calls the helper method to initialize the page for showing case and WorkOrder details
	doInit : function(component, event, helper) {
		helper.initCaseDetails(component, event, helper);
	},
    //Calls the helper method to show the New WorkOrder Window when the Resubmit button is clicked
    createWorkOrderRecord:function(component, event, helper){
        helper.createWorkOrderRecordHelper(component, event, helper);
	}
})