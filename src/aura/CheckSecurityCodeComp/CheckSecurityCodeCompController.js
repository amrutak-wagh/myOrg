({
	doInit : function(component, event, helper) {
		helper.helperMethod(component, event, helper);
	},
    checkCodeFromURL : function(component, event, helper){
        component.set("v.load",false);
    	helper.checkCodeFromURLHelper(component, event, helper);// Call helper method
	}
})