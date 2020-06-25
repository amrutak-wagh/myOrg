({
	getLineItemsDetailsBySelectedFilter : function(component, event, helper, selectedFilter) {
		helper.showLoader(component);
        component.set("v.allQuoteLineItemList", []);
        component.set("v.changedLineItemList", []);
        var action;
        if(selectedFilter == 'UnitProduct') {
            action = component.get("c.getLineItemsDetailsByUnitApx");
        }
        else if(selectedFilter == 'Revision') {
            action = component.get("c.getLineItemsDetailsByRevisionApx");
        }
        action.setParams({
            quoteId: component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
				console.log('result', result);
				if(result && result !=null && result.length > 0){

                    component.set("v.totalPages", Math.ceil(result.length/component.get("v.pageSize")));
                    component.set("v.allQuoteLineItemList", result);
                    component.set("v.currentPageNumber", 1);
                    helper.buildData(component, helper);
                    
                }else{

                }
            } else if (state === "ERROR") {
                var errors = response.getError();
                alert(errors);
                helper.hideLoader(component);
                console.log( errors );
            }
            helper.hideLoader(component);
        });
        $A.enqueueAction(action);
        
	},
    
    /*
     * this function will build table data
     * based on current page selection
     * */
    buildData : function(component, helper) {
        var data = [];
        //component.set("v.quoteLineItemList", []);
        var pageNumber = component.get("v.currentPageNumber");
        var pageSize = component.get("v.pageSize");
        var allData = component.get("v.allQuoteLineItemList");
        var x = (pageNumber-1) * pageSize;
        
        //creating data-table data
        for(; x<(pageNumber)*pageSize; x++){
            if(allData[x]){
            	data.push(allData[x]);
            }
        }
        component.set("v.quoteLineItemList", data);
        
        helper.generatePageList(component, pageNumber);
    },
    
    updateMainList : function(component, helper) {
        var currentData = component.get("v.quoteLineItemList");
        var pageNumber = component.get("v.currentPageNumber");
        var pageSize = component.get("v.pageSize");
        var allData = component.get("v.allQuoteLineItemList");
        var x = (pageNumber-1) * pageSize;
        
        //creating data-table data
        for(; x<(pageNumber)*pageSize; x++){
            if(currentData[x]){
            	allData[x] = currentData[x];
            }
        }
        component.set("v.allQuoteLineItemList", allData);
    },
    
    /*
     * this function generate page list
     * */
    generatePageList : function(component, pageNumber){
        component.set("v.pageList", []);
        pageNumber = parseInt(pageNumber);
        var pageList = [];
        var totalPages = component.get("v.totalPages");
        for(var counter = 1; counter <= (totalPages); counter++){
        	pageList.push(counter);
        }
        component.set("v.pageList", pageList);
    },
    
    saveLineItemHelper : function(component, event, helper) {
        helper.showLoader(component);
        var selectedFilter = component.get('v.selectedFilterValue');
        var action;
        var allQuoteLineItemList = component.get("v.allQuoteLineItemList");
        var changedLineItemList = component.get('v.changedLineItemList'); 
        console.log('changedLineItemList------------',changedLineItemList);
        var quoteLineItemList = [];
        if(selectedFilter == 'UnitProduct') {
            for(var i = 0; i < allQuoteLineItemList.length; i++) {
                quoteLineItemList.push.apply(quoteLineItemList, allQuoteLineItemList[i].lineItemList);
            }
        }
        else if(selectedFilter == 'Revision') {
            for(var i = 0; i < allQuoteLineItemList.length; i++) {
                var unitList = allQuoteLineItemList[i].unitLineItemList;
                for(var j = 0; j < unitList.length; j++) {
                    quoteLineItemList.push.apply(quoteLineItemList, unitList[j].lineItemList);
                }
            }
        }
        action = component.get("c.saveLineItemApx");
        action.setParams({
            quoteLineItemList : quoteLineItemList,
            qliToBeUpdatedList : changedLineItemList
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();

				if(result == 'SUCCESS') {
                    helper.showPageMessage(component, '', 'Records has been successfully updated.', 'success');
                    component.set("v.currentPageNumber", 1);
                    helper.getLineItemsDetailsBySelectedFilter(component, event, helper, selectedFilter);
                    //helper.buildData(component, helper);
                    component.set('v.changesMade', false);
                }
                else{
					helper.showPageMessage(component, '', result, 'error');
                }
            } else if (state === "ERROR") {
                var errors = response.getError();
                helper.showPageMessage(component, '', errors, 'error');
                console.log( errors ); 
            }
            helper.hideLoader(component);
        });
        $A.enqueueAction(action);
        
    },
    
    showLoader : function(component) {
        component.set("v.showLoader", true);
    },
    
    hideLoader: function(component){
        component.set("v.showLoader", false);
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