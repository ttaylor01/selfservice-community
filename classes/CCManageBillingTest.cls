@isTest(SeeAllData=true)
public with sharing class CCManageBillingTest {

    static testMethod void myUnitTest() {
        Account testAcc;
        Contact testCon;
        Zuora__CustomerAccount__c testBA;
        Zuora__Payment__c testP;
        User testUser;
		System.runAs ( new User(Id = UserInfo.getUserId()) ) {
			testAcc = createAccount();
			testCon = createContact(testAcc);
			testBA = createBillingAccount(testAcc);
			testP = createPayment(testBA);
			testUser = createUser(testCon);
		}
        System.runAs(testUser) {
			Test.setCurrentPageReference(new PageReference('Page.CCManageBilling'));
            system.debug('\n[DEBUG-CCManageBillingTest.myUnitTest()]\n=========\nCurrent User: ' + UserInfo.getUserName());
            system.debug('\n[DEBUG-CCManageBillingTest.myUnitTest()]\n=========\nCurrent Profile: ' + UserInfo.getProfileId());
			System.currentPageReference().getParameters().put('id', testBA.Zuora__Zuora_Id__c);
			System.currentPageReference().getParameters().put('retUrl', '/selfservice/apex/CCBillingAccount');
            CCManageBilling cctest = new CCManageBilling();
            cctest.goBack();
            system.debug('\n[DEBUG-CCManageBillingTest.myUnitTest()]\n=========\nPaymentMethods: ' + cctest.getMethods());
            system.debug('\n[DEBUG-CCManageBillingTest.myUnitTest()]\n=========\nPayments: ' + cctest.getPayments());
            List<CCManageBilling.InvoiceWrapper> invoices = cctest.getInvoices();
            system.debug('\n[DEBUG-CCManageBillingTest.myUnitTest()]\n=========\nInvoices: ' + invoices);
			cctest.sortByPaymentDate();
			cctest.sortByInvoiceDate();
			cctest.sortByPaymentDate();
			cctest.sortByInvoiceDate();
            Zuora__ZInvoice__c t = cctest.total;
            system.debug('\n[DEBUG-CCManageBillingTest.myUnitTest()]\n=========\nInvoice TOTALS: ' + t);

			for(CCManageBilling.InvoiceWrapper i : cctest.getInvoices()) {
				i.selected = true;
			}
            cctest.toggleMakePaymentMode();  // turn on
            cctest.toggleMakePaymentMode();  // turn off

			// no invoice selected
			for(CCManageBilling.InvoiceWrapper i : cctest.getInvoices()) {
				i.selected = false;
			}
            cctest.toggleMakePaymentMode();  // turn on
            cctest.toggleMakePaymentMode();  // turn off
            
			for(CCManageBilling.InvoiceWrapper i : cctest.getInvoices()) {
				i.selected = true;
				i.inputPaymentAmount = 1.0;
			}
            cctest.toggleMakePaymentMode();  // turn on
            system.debug('\n[DEBUG-CCManageBillingTest.myUnitTest()]\n=========\nInvoicePayments: ' + cctest.invoicePayments);
            system.debug('\n[DEBUG-CCManageBillingTest.myUnitTest()]\n=========\nPaymentMethodId: ' + cctest.paymentMethodId);
            cctest.sendPayment();
            cctest.toggleMakePaymentMode();  // turn off

			// invalid input
			for(CCManageBilling.InvoiceWrapper i : cctest.getInvoices()) {
				i.selected = true;
				i.inputPaymentAmount = 1000.00;
			}
            cctest.toggleMakePaymentMode();  // turn on
            system.debug('\n[DEBUG-CCManageBillingTest.myUnitTest()]\n=========\nInvoicePayments: ' + cctest.invoicePayments);
            system.debug('\n[DEBUG-CCManageBillingTest.myUnitTest()]\n=========\nPaymentMethodId: ' + cctest.paymentMethodId);
            cctest.paymentMethodId = '';
            cctest.sendPayment();
            cctest.toggleMakePaymentMode();  // turn off
        }
    }

	public static Account createAccount() {
		Account testAcc = new Account();
		testAcc.Name = 'testAccount';
		testAcc.BillingCity = 'Atlanta';
		testAcc.BillingState = 'GA';
		testAcc.BillingCountry = 'United States';
		testAcc.BillingPostalCode = '12345';
		testAcc.BillingStreet = '123';
		testAcc.ShippingStreet = '123';
		testAcc.ShippingCity = 'Atlanta';
		testAcc.ShippingState	 = 'GA';
		testAcc.ShippingPostalCode = '12345';
		//testAcc.zd_ID__c = '123';
		insert testAcc;
		return testAcc;
	}

	public static Contact createContact(Account account) {
		Contact testcon = new Contact();
		testcon.firstname = 'testconfirst';
		testcon.lastname = 'testconlast';
		testcon.Phone = '7777777777';
		testcon.MobilePhone = '6666666666';
		testcon.HomePhone = '5555555555';
		testcon.OtherPhone = '4444444444';
		testcon.OtherStreet = 'Other Street';
		testcon.Salutation = 'Mr.';
		testcon.MailingCountry = 'United States';
		testCon.MailingCity = 'Atlanta';
		testCon.MailingState = 'Georgia';
		testCon.MailingStreet = '123 lane';
		testcon.email = 'test@test.com';
		testcon.AccountId = account.Id;
		insert testcon;
		return testcon;
	}
	public static Zuora__CustomerAccount__c createBillingAccount(Account testAcc) {
		Zuora__CustomerAccount__c testCA = new Zuora__CustomerAccount__c();
		testCA.Zuora__Zuora_Id__c = 'TestZuoraID';
		testCA.Zuora__Account__c = testAcc.Id;
		insert testCA;
		return testCA;
	}
	public static Zuora__Payment__c createPayment(Zuora__CustomerAccount__c testCA) {
		Zuora__Payment__c testP = new Zuora__Payment__c();
		testP.Zuora__BillingAccount__c = testCA.Id;
		testP.Zuora__Amount__c = 100.00;
		testP.Zuora__InvoiceNumber__c = 'INV000001';
		testP.Name = 'P-111111111';
		testP.Zuora__EffectiveDate__c = Date.today();
		testP.Zuora__Status__c = 'Processed';
		testP.Zuora__PaymentMethod__c = 'CreditCardId';
		insert testP;
		return testP;
	}
	public static User createUser(Contact contact) {
		String profileName = 'Community Provider';
		Profile profile = [select Id from Profile where Name=:profileName];
		User user = new User(
			ContactId = contact.Id,
			Username = 'community.test@availity.com',
			Email = 'community.test@availity.com',
			LastName = 'Community',
			FirstName = 'Test',
			Alias = 'com.test',
			CommunityNickname = 'comm',
			ProfileId = profile.Id,
			LocaleSidKey = 'en_US',
			LanguageLocaleKey = 'en_US',
			TimeZoneSidKey = 'America/Los_Angeles',
			EmailEncodingKey='UTF-8'
		);
		insert user;
		user.IsPortalEnabled = true;
		update user;
		return user;
	}
}