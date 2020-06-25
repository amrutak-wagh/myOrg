public with sharing class PrintCustomerApplicationCtrl {
	public CustomerRegistrationController.AccountWrapper info {get; set;}
	public PrintCustomerApplicationCtrl() {
		info = CustomerRegistrationController.getAccountInfo('003Q000001Jt1sDIAR');
	}
}