@isTest(SeeAllData=true)
public with sharing class CCViewInvoiceTest {

    static testMethod void myUnitTest() {
        Account testAcc = createAccount();
        Contact testCon = createContact(testAcc);
        Zuora__CustomerAccount__c testBA = createBillingAccount(testAcc);
        Zuora__ZInvoice__c testI = createInvoice(testBA);
        User testUser = createUser(testCon);
        System.runAs(testUser) {
			Test.setCurrentPageReference(new PageReference('Page.CCManageBilling'));
			System.currentPageReference().getParameters().put('invId', testI.Zuora__Zuora_Id__c);
            CCViewInvoice cctest = new CCViewInvoice();
            system.debug('\n[DEBUG-CCManageBillingTest.myUnitTest()]\n=========\ntotalAmount: ' + cctest.totalAmount);
            system.debug('\n[DEBUG-CCManageBillingTest.myUnitTest()]\n=========\ntaxAmount: ' + cctest.taxAmount);
            system.debug('\n[DEBUG-CCManageBillingTest.myUnitTest()]\n=========\nsubTotalAmount: ' + cctest.subTotalAmount);
            for(CCViewInvoice.InvoiceItems i : cctest.invoiceItems) {
	            system.debug('\n[DEBUG-CCManageBillingTest.myUnitTest()]\n=========\n chargeAmount: ' + i.chargeAmount);
	            system.debug('\n[DEBUG-CCManageBillingTest.myUnitTest()]\n=========\n serviceEndDate: ' + i.serviceEndDate);
	            system.debug('\n[DEBUG-CCManageBillingTest.myUnitTest()]\n=========\n serviceStartDate: ' + i.serviceStartDate);
	            system.debug('\n[DEBUG-CCManageBillingTest.myUnitTest()]\n=========\n unitPrice: ' + i.unitPrice);
	            system.debug('\n[DEBUG-CCManageBillingTest.myUnitTest()]\n=========\n taxAmount: ' + i.taxAmount);
            }
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
	public static Zuora__ZInvoice__c createInvoice(Zuora__CustomerAccount__c testCA) {
		Zuora__ZInvoice__c testI = new Zuora__ZInvoice__c();
		testI.Zuora__Zuora_Id__c = 'InvoiceId';
		testI.Zuora__Balance2__c = 100.00;
		testI.Name = 'I-000000001';
		insert testI;
		return testI;
	}
	public static User createUser(Contact contact) {
		String profileName = 'Community HeW';
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