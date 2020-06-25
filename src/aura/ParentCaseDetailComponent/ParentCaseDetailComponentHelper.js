({
    //Method to load the component
 	injectComponent: function (name, target, attributes) {
        if(!attributes){
            attributes = {}; 
        }
        $A.createComponent(name, attributes , function (contentComponent, status, error) {
            if (status === "SUCCESS") {
                target.set('v.body', contentComponent);
            } else {
                throw new Error(error);
            }
        });
    }
})