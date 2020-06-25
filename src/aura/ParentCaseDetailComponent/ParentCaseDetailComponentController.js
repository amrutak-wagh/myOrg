({
    //Init method - It is called as soon as page is loaded
    //Loads the DisplayContactAndChildComp if 'isloggedIn' is true in URL
    //Loads the CheckSecurityCodeComp otherwise
    //For loading the component generic helper inject method is used
   doInit : function(component, event, helper) {
      	
       var vars = {};
        var parts = window.location.href.replace(/[?&]+([^=&]+)=([^&]*)/gi, function(m,key,value) {
            vars[key] = value;
        });
       
       var loggedInParam = vars['isloggedIn'];
       if(loggedInParam=='true' && loggedInParam!= undefined && loggedInParam != null){
           console.log('--------');
           helper.injectComponent("c:DisplayContactAndChildComp", component, { "recordId" : vars['recordId'].trim()});
       }else{
           console.log('-----Here-----');
           helper.injectComponent("c:CheckSecurityCodeComp", component, {});
       }
               
   },
   // Method is called when user click submit on the CheckSecurityCodeComp Page
   NavigateComponent : function(component,event,helper) {
       helper.injectComponent("c:DisplayContactAndChildComp", component, { "recordId" : event.getParam("recordID")});
   }
})