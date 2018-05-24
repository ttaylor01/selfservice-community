@isTest
private class CCTestCaseExtensions {

    static testMethod void testReassignContact() {
        Case case1 = 
            [SELECT Id, CaseNumber, ContactId, Status, RecordTypeId, Send_Survey__c, CreatedDate
             FROM Case WHERE Subject = 'New' LIMIT 1];

        Test.startTest();

		ApexPages.StandardController sc = new ApexPages.StandardController(case1);

		CCReassignCaseContact reassignCaseExt = new CCReassignCaseContact(sc);
		PageReference reassignPageRef = Page.CCReassignCaseContact;
		reassignPageRef.getParameters().put('id', String.valueOf(case1.Id));
		Test.setCurrentPage(reassignPageRef);
		reassignCaseExt.searchString = 'One';
		reassignCaseExt.doSearch();
		reassignCaseExt.doSave();

        Test.stopTest();
	}

    static testMethod void testReopenCase() {
        Case case1 = 
            [SELECT Id, CaseNumber, ContactId, Status, RecordTypeId, Send_Survey__c, CreatedDate
             FROM Case WHERE Subject = 'New' LIMIT 1];

        Test.startTest();

		ApexPages.StandardController sc = new ApexPages.StandardController(case1);
		case1.Status = 'Closed';
		update case1;
		ReOpenCaseExtension reopenCaseExt = new ReOpenCaseExtension(sc);
		reopenCaseExt.comment.CommentBody = 'testing reopen';
		PageReference reopnPageRef = Page.CommunitiesReOpenCase;
		reopnPageRef.getParameters().put('id', String.valueOf(case1.Id));
		Test.setCurrentPage(reopnPageRef);
		reopenCaseExt.doSave();

        Test.stopTest();
	}

    static testMethod void testArchiveCase() {
        Case case1 = 
            [SELECT Id, CaseNumber, ContactId, Status, RecordTypeId, Send_Survey__c, CreatedDate
             FROM Case WHERE Subject = 'New' LIMIT 1];

        Test.startTest();

		ApexPages.StandardController sc = new ApexPages.StandardController(case1);
		case1.Status = 'Closed';
		update case1;
		CommunitiesArchiveCaseExtension archiveCaseExt = new CommunitiesArchiveCaseExtension(sc);
		PageReference archivePageRef = Page.CommunitiesArchiveCase;
		archivePageRef.getParameters().put('id', String.valueOf(case1.Id));
		Test.setCurrentPage(archivePageRef);
		archiveCaseExt.doSave();

        Test.stopTest();
	}

    static testMethod void testCloseWithSurveyCase() {
        Case case1 = 
            [SELECT Id, Subject, Type, OwnerId, CaseNumber, ContactId, Status, RecordTypeId, Send_Survey__c, CreatedDate
             FROM Case WHERE Subject = 'New' LIMIT 1];

        Test.startTest();

		ApexPages.StandardController sc = new ApexPages.StandardController(case1);
		case1.Status = 'Re-opened';
		update case1;
		CaseCloseWithSurvey closeWithSurveyCaseExt = new CaseCloseWithSurvey(sc);
		PageReference closeWithSurveyPageRef = Page.CaseCloseWithSurvey;
		closeWithSurveyPageRef.getParameters().put('id', String.valueOf(case1.Id));
		Test.setCurrentPage(closeWithSurveyPageRef);
		closeWithSurveyCaseExt.getStatusOptions();
		closeWithSurveyCaseExt.doSave();
		closeWithSurveyCaseExt.cs.Status = 'Closed';
		closeWithSurveyCaseExt.doSave();
		closeWithSurveyCaseExt.comment.CommentBody = 'testing close with survey';
		closeWithSurveyCaseExt.doSave();

		case1.Status = 'Re-opened';
		case1.Type = 'ACS Submitted Registrations';
		update case1;
		CaseCloseWithSurvey closeWithSurveyCaseExt2 = new CaseCloseWithSurvey(sc);
		PageReference closeWithSurveyPageRef2 = Page.CaseCloseWithSurvey;
		closeWithSurveyPageRef2.getParameters().put('id', String.valueOf(case1.Id));
		Test.setCurrentPage(closeWithSurveyPageRef2);
		closeWithSurveyCaseExt2.getStatusOptions();
		closeWithSurveyCaseExt2.doSave();
		closeWithSurveyCaseExt2.cs.Status = 'Closed';
		closeWithSurveyCaseExt2.doSave();
		closeWithSurveyCaseExt2.comment.CommentBody = 'testing close without survey';
		closeWithSurveyCaseExt2.doSave();

        Test.stopTest();
	}

    @testSetup static void setup() {
        System.runAs( new User(Id = UserInfo.getUserId()) ) {
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
            insert testAcc;
            
            Contact testcon1 = new Contact();
            testcon1.firstname = 'Contact';
            testcon1.lastname = 'One';
            testcon1.Phone = '7777777777';
            testcon1.MobilePhone = '6666666666';
            testcon1.HomePhone = '5555555555';
            testcon1.OtherPhone = '4444444444';
            testcon1.OtherStreet = 'Other Street';
            testcon1.Salutation = 'Mr.';
            testcon1.MailingCountry = 'United States';
            testcon1.MailingCity = 'Atlanta';
            testcon1.MailingState = 'Georgia';
            testcon1.MailingStreet = '123 lane';
            testcon1.email = 'contact.one@availity.com';
            testcon1.AccountId = testAcc.Id;
            Contact testcon2 = new Contact();
            testcon2.firstname = 'Contact';
            testcon2.lastname = 'Two';
            testcon2.Phone = '7777777777';
            testcon2.MobilePhone = '6666666666';
            testcon2.HomePhone = '5555555555';
            testcon2.OtherPhone = '4444444444';
            testcon2.OtherStreet = 'Other Street';
            testcon2.Salutation = 'Mr.';
            testcon2.MailingCountry = 'United States';
            testcon2.MailingCity = 'Atlanta';
            testcon2.MailingState = 'Georgia';
            testcon2.MailingStreet = '123 lane';
            testcon2.email = 'contact.two@availity.com';
            testcon2.AccountId = testAcc.Id;
			Contact[] contacts = new Contact[] {testcon1, testcon2};
			insert contacts;
    
            String profileName = 'Community User';
            Profile profile = [select Id from Profile where Name=:profileName];
            User user = new User(
                ContactId = testcon1.Id,
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

            RecordType customersupportRT = [SELECT Id, Name FROM RecordType WHERE Name = 'Community Support' LIMIT 1];
            Case cs = new Case();
            cs.RecordTypeId = customersupportRT.Id;
            cs.Status ='New';
            cs.AccountId = testAcc.Id;
            cs.ContactId = testcon1.Id;
            cs.Call_Reason__c = 'Login';
            cs.CID_Identifier__c = '12345';
            cs.Brief_Description__c = '';
            cs.Submission_Method__c = '';
            cs.Payer_Name__c = '';
            cs.Payer_ID__c = '';
            cs.Government_Payer__c = false;
            cs.Provider_Name__c = '';
            cs.NPI_Identifier__c = '';
            cs.Tax_ID__c = '';
            cs.PTAN_Identifier__c = '';
            cs.Atypical_Provider__c = false;
            cs.User_ID__c = 'TestUserId';
            cs.Customer_Reference_Number__c = '';
            cs.Alternate_Email__c = '';
            cs.Alternate_Email_2__c = '';
            cs.New_Payer_Request_Type__c = '';
            // Transaction Information
            cs.EDI_Batch_ID__c = '';
            cs.Patient_Name__c = '';
            cs.Web_Transaction_ID__c = '';
            cs.Member_ID__c = '';
            cs.EDI_Batch_Reject_Reason__c = '';
            cs.Date_of_Service__c = null;
            cs.Charge_Amount__c = null;
            // Check Information
            cs.Check_Date__c = null;
            cs.Check_Number__c = '';
            cs.Check_Amount__c = null;
            // B2B Transaction Information
            cs.B2B_Vendor_Transaction_ID__c = '';
            cs.B2B_transaction_Date__c = null;
            cs.B2B_Time_of_Transaction__c = '';
            cs.B2B_Vendor_Error_Code__c = '';
            // Details
            cs.Subject = 'New';
            cs.Description = 'New Test Subject';
            insert cs;
        }
    }    
}