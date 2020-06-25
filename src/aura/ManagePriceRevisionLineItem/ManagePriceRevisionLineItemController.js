({
	 displayLineItem : function(component, event, helper) {
        var elementList = component.find('panelDiv');
        for(var cmp in elementList) {
            $A.util.toggleClass(elementList[cmp], 'slds-show');  
            $A.util.toggleClass(elementList[cmp], 'slds-hide');  
        }
	}
})