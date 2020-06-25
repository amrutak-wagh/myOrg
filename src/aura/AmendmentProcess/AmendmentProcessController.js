({
    doInit:function(component, event, helper){        
        //First check if there are any quote records associated then proceed.
       var action = component.get("c.getQuoteRecords");
        var actionParams = {
            "recordId" : component.get("v.recordId")
        };

        action.setParams(actionParams);
        action.setCallback(this, function(response){
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                var result = response.getReturnValue();
                if(result > 0){
                    helper.retrieveOpportunityPageLayout(component, helper);
                    component.set('v.quoteLineItemsColumns', [
                        {label: 'Name', fieldName: 'Name', type: 'text'},
                    ]);
                 }else{
                 	helper.showPageMessage(component, '', 'There are no synced quotes associated to opportunity.', 'error');       
                        $A.get("e.force:closeQuickAction").fire();
                 }
            }
        });
        $A.enqueueAction(action);
    },
    getChildOpp:function(component, event, helper){
    	component.set("v.displayChildOpp",true);
        component.set("v.displayOpp",false);
        component.set("v.displayQuoteLine",false);
        component.set("v.displayQuote",false);
        component.set("v.displayRemovedQuoteLine",false);
        helper.retrieveChildOpportunityPageLayout(component, helper);
    },
    getQuote:function(component, event, helper){
        component.set("v.displayOpp",false);
        component.set("v.displayChildOpp",false);
        component.set("v.displayQuote",true);
        component.set("v.displayQuoteLine",false);
       	component.set("v.displayRemovedQuoteLine",false);
        helper.retrieveQuotePageLayout(component,helper);	
    },
    
    getQuoteLineItems:function(component, event, helper){
        var terminationDate = component.get("v.date");
        if(terminationDate == null || terminationDate == ''){
            helper.showPageMessage(component, '', 'Please fill termination date!!', 'error');
            //alert('Please fill termination date!!');
        } else{
            helper.updateQuoteHelper(component);
            
            component.set("v.displayOpp",false);
            component.set("v.displayChildOpp",false);
            component.set("v.displayQuote",false);
            component.set("v.displayQuoteLine",true);
            component.set("v.displayRemovedQuoteLine",false);
            
        	helper.getQuoteLineHelper(component);
        }

    },
    
    getRemovedQLI :function(component, event, helper){
       	helper.getRemovedQuoteLineItemHelper(component,event);
    },
    getSelectedQLI:function(component, event, helper){
        helper.getSelectedQLIHelper(component,event);
        
    },
    
    proceedRemovedQuoteLineItems: function(component, event, helper){
        component.set("v.displayOpp",false);
        component.set("v.displayChildOpp",false);
        component.set("v.displayQuote",false);
        component.set("v.displayQuoteLine",false);
        component.set("v.displayRemovedQuoteLine",true);        
        helper.getRemoveableQuoteLineItems(component);
        //component.set("v.removedQuoteLineItems", component.find("quoteLineItems").getSelectedRows());
    },
    
    updateQuoteLineItemSelection: function(component, event, helper){
        var selectedItems = event.getParam('selectedRows');
        var seletedQLI = [];
        for(var i=0; i<selectedItems.length; i++){
            seletedQLI.push(selectedItems[i].id);
        }
        component.set("v.selectedQuoteLineItems", seletedQLI);
    },
   
    getRemovedQuoteLineItems :function(component, event, helper){
        /*
        component.set("v.displayOpp",false);
        component.set("v.displayChildOpp",false);
        component.set("v.displayQuote",false);
        component.set("v.displayQuoteLine",false);
        component.set("v.displayRemovedQuoteLine",true);
        */
        helper.getRemovedQuoteLineHelper(component,event);
        
    },    
    
    closeWindow:function(component, event, helper){
        console.log('closeWindow called........', component.get("v.recordId"));
        /*var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Success!",
            "message": "The record has been created successfully."
        });
        toastEvent.fire();
        setTimeout(function(){ window.close(); }, 5000);*/
        
         window.close(); 
        
        /*var redirect = $A.get("e.force:navigateToSObject");
        redirect.setParams({ "recordId": component.get("v.recordId"), "isredirect": "true" });
        redirect.fire(); 
        
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
          "url": "/" + component.get("v.recordId")
        });
        urlEvent.fire();*/
    },
    
    backToRemoveQLI : function(component, event, helper){
        debugger;
        component.set("v.displayOpp",false);
        component.set("v.displayChildOpp",false);
        component.set("v.displayQuote",false);
        component.set("v.displayQuoteLine",true);
        component.set("v.displayRemovedQuoteLine",false);
    },
    
    save: function(component, event, helper){
        component.set("v.Spinner", true);         
        var removeableItems = component.get("v.removedQuoteLineItems");
        if(removeableItems.length > 0){
            var removeableIds = [];
            for(var i = 0; i<removeableItems.length; i++){
                removeableIds.push(removeableItems[i].id);
            }
            
            var action = component.get("c.removeSelectedQuoteLineItems");
            action.setParams({
                "selectedQuoteLineItems" : removeableIds.toString()
            });
            
            action.setCallback(this, function(res){
                if(res.getState() === "SUCCESS"){
                    var result = res.getReturnValue();
                    if(result != 'SUCCESS'){
                        helper.showPageMessage(component, '', 'Error while saving.', 'error');                        
                    }else{
                        helper.showPageMessage(component, '', 'Quote line items has been successfully updated.', 'success');
                        $A.get("e.force:closeQuickAction").fire();
                        $A.get('e.force:refreshView').fire();
                    }
                }
            });
            $A.enqueueAction(action); 
        }else{
            
        }
    },

    // this function automatic call by aura:waiting event  
    showSpinner: function(component, event, helper) {
        // make Spinner attribute true for display loading spinner 
        component.set("v.Spinner", true); 
    },
    
    // this function automatic call by aura:doneWaiting event 
    hideSpinner : function(component,event,helper){
        // make Spinner attribute to false for hide loading spinner    
        component.set("v.Spinner", false);
    }    
    
})