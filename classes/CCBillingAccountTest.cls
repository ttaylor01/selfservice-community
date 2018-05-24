@isTest(SeeAllData=true)
public with sharing class CCBillingAccountTest {

    static testMethod void testBillingAccountSelect() {
        // TO DO: implement unit test
        Account testAcc;
        Contact testCon;
        Zuora__CustomerAccount__c testBA;
        User testUser;
        
        // Test with no billing accounts
		System.runAs ( new User(Id = UserInfo.getUserId()) ) {
	        testAcc = createAccount();
	        testCon = createContact(testAcc);
	        testUser = createUser(testCon);
		}
        System.runAs(testUser) {
            system.debug('\n[DEBUG-CCBillingAccountTest.myUnitTest()]\n=========\nCurrent User: ' + UserInfo.getUserName());
            system.debug('\n[DEBUG-CCBillingAccountTest.myUnitTest()]\n=========\nCurrent Profile: ' + UserInfo.getProfileId());

			Test.setCurrentPageReference(new PageReference('Page.CCBillingAccountSelect'));
            CCBillingAccountSelect ccBillingAccountSelect = new CCBillingAccountSelect();
            ccBillingAccountSelect.validateAndRedirect();
//            ccBillingAccountSelect.gotoBillingAccount();
        }

		// Add Billing Account and retest
		System.runAs ( new User(Id = UserInfo.getUserId()) ) {
	        testBA = createBillingAccount(testAcc);
			Zuora__ZInvoice__c testI = createInvoice(testBA);
		}
        System.runAs(testUser) {
			Test.setCurrentPageReference(new PageReference('Page.CCBillingAccountSelect'));
            CCBillingAccountSelect ccBillingAccountSelect = new CCBillingAccountSelect();
            ccBillingAccountSelect.validateAndRedirect();
        }

		System.runAs ( new User(Id = UserInfo.getUserId()) ) {
			String profileName = 'Community HeW';
			Profile profile = [select Id from Profile where Name=:profileName];
			testUser.profileId = profile.Id;
			update testUser;
		}
		System.runAs(testUser) {
			system.debug('\n[DEBUG-CCBillingAccountTest.myUnitTest()]\n=========\nCurrent User: ' + UserInfo.getUserName());
			system.debug('\n[DEBUG-CCBillingAccountTest.myUnitTest()]\n=========\nCurrent Profile HeW?: ' + UserInfo.getProfileId());
			Test.setCurrentPageReference(new PageReference('Page.CCBillingAccountSelect'));
			CCBillingAccountSelect ccBillingAccountSelect = new CCBillingAccountSelect();
			ccBillingAccountSelect.validateAndRedirect();
		}
    }

    static testMethod void testBillingAccount() {
        // TO DO: implement unit test
        Account testAcc;
        Contact testCon;
        Zuora__CustomerAccount__c testBA;
        User testUser;
		Zuora__ZInvoice__c testI;
		System.runAs ( new User(Id = UserInfo.getUserId()) ) {
	        testAcc = createAccount();
	        testCon = createContact(testAcc);
	        testBA = createBillingAccount(testAcc);
			testI = createInvoice(testBA);
	        testUser = createUser(testCon);
		}
        System.runAs(testUser) {
            system.debug('\n[DEBUG-CCBillingAccountTest.myUnitTest()]\n=========\nCurrent User: ' + UserInfo.getUserName());
            system.debug('\n[DEBUG-CCBillingAccountTest.myUnitTest()]\n=========\nCurrent Profile: ' + UserInfo.getProfileId());

			Test.setCurrentPageReference(new PageReference('Page.CCBillingAccount'));
            CCBillingAccount ccBillingAccount = new CCBillingAccount();
            if(ccBillingAccount.zBillingAccount.defaultPayment) {}
            if(ccBillingAccount.zBillingAccount.defaultCreditCard) {}
            if(ccBillingAccount.zBillingAccount.paymentMethodString != null) {}
            
            system.debug('\n[DEBUG-CCBillingAccountTest.myUnitTest()]\n========= getMethods()');
            ccBillingAccount.getMethods();
            ccBillingAccount.getStates();

            // Test toggle page modes
			System.currentPageReference().getParameters().put('contactType', 'BillTo');
            ccBillingAccount.toggleEditContactMode();  // turn on
            ccBillingAccount.toggleEditContactMode();  // turn off
			System.currentPageReference().getParameters().remove('contactType');
			System.currentPageReference().getParameters().put('contactType', 'SoldTo');
            ccBillingAccount.toggleEditContactMode();  // turn on
            ccBillingAccount.toggleEditContactMode();  // turn off
            ccBillingAccount.toggleEditAccountMode();  // turn on
            ccBillingAccount.toggleEditAccountMode();  // turn off

			// test edit contact
			System.currentPageReference().getParameters().remove('contactType');
			System.currentPageReference().getParameters().put('contactType', 'BillTo');
            ccBillingAccount.toggleEditContactMode();  // turn on
            ccBillingAccount.editBillingContact();
            // test bad input
			System.currentPageReference().getParameters().remove('contactType');
			System.currentPageReference().getParameters().put('contactType', 'SoldTo');
            ccBillingAccount.toggleEditContactMode();  // turn on
            ccBillingAccount.editBillingContact();

			// test edit account        
            ccBillingAccount.toggleEditAccountMode();  // turn on
            ccBillingAccount.editBillingAccount();  // turn on

			ccBillingAccount.cancelEditAccountMode();

			// Test with passed account Id
			System.currentPageReference().getParameters().put('id', 'TestZuoraID');
            ccBillingAccount = new CCBillingAccount();
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
		testCA.AvailityLineOfBusiness__c = 'HeW';
		testCA.Zuora__Status__c = 'Active';
		testCA.Zuora__LastInvoiceDate__c = Date.today();
		insert testCA;
		return testCA;
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
			EmailEncodingKey='UTF-8',
			Billing_Authorization__c = true
		);
		insert user;
		user.IsPortalEnabled = true;
		update user;
		return user;
	}
	public static Zuora__ZInvoice__c createInvoice(Zuora__CustomerAccount__c testCA) {
		Zuora__ZInvoice__c testI = new Zuora__ZInvoice__c();
		testI.Zuora__Zuora_Id__c = 'InvoiceId';
		testI.Zuora__Balance2__c = 100.00;
		testI.Zuora__TotalAmount__c = 100.00;
		testI.Name = 'I-000000001';
		insert testI;
		return testI;
	}
}