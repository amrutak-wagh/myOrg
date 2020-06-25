({
	doInit : function(component, event, helper) {
        
		var fieldObj = component.get("v.fieldName");
        var sObject = component.get("v.sObject");
        var value = sObject[fieldObj.name];
        component.set("v.value",value);
        component.set("v.label",fieldObj.label);
	}
})