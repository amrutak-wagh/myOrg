({    
    doInit : function(component, event, helper) {
        helper.getSettings(component, event, helper);
    },
    
    moveToNextStatus : function(component, event, helper){
        helper.moveToNextStep(component, event, helper);
    },
    
    closeModal : function(component, event, helper){
        location.reload();
    },
    
    saveRegAddress : function(component, event, helper){
        //component.set("v.selectRegAddress",false);
        helper.updateRegAddress(component, event, helper);
        //location.reload();
    },
    
    onGroup: function(component, event) {
        var selected = event.getSource().get("v.name");
        component.set("v.selectedUnitId",selected);
    }
})