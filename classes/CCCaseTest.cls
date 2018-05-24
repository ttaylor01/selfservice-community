@isTest
private class CCCaseTest {

    static testMethod void testCaseList() {
        Account testAcc = [SELECT Id FROM Account WHERE Name='testAccount' LIMIT 1];
        Contact testCon = [SELECT Id FROM Contact WHERE Email = 'community.test@availity.com' LIMIT 1];
        User testUser = [SELECT Id FROM User WHERE UserName = 'community.test@availity.com' LIMIT 1];
        System.runAs(testUser) {
            Test.startTest();
            
            Test.setCurrentPageReference(new PageReference('Page.CCListCase'));
            CCListCase ccList = new CCListCase();
            system.debug('\n[DEBUG-CCCaseTest.testCaseList()]\n=========\nViews: ' + ccList.getViews());
            ccList.refreshList();
            List<Case> caseList = ccList.getCases();
            system.debug('\n[DEBUG-CCCaseTest.testCaseList()]\n=========\nCases: ' + caseList);
            ccList.listView = 'Closed';
            ccList.refreshList();
            caseList = ccList.getCases();
            system.debug('\n[DEBUG-CCCaseTest.testCaseList()]\n=========\nCases: ' + caseList);
            cclist.searchStr = 'ab';
            cclist.refreshList();
            ccList.searchStr = 'Test';
            cclist.refreshList();
            caseList = ccList.getCases();
            ccList.searchStr = 'Test Subject';
            cclist.refreshList();
            caseList = ccList.getCases();
            system.debug('\n[DEBUG-CCCaseTest.testCaseList()]\n=========\nCases: ' + caseList);
            cclist.SortField = 'CaseNumber';
            cclist.SortToggle();
            cclist.refreshPageSize();
            cclist.reset();
            caseList = ccList.getCases();
            cclist.recordTypeId = caseList[0].RecordTypeId;
            cclist.selectedId = caseList[0].Id;
            cclist.gotoCaseDetail();

            ccList.createNewCase();
            
            Test.stopTest();
        }
    }

    static testMethod void testCaseCreate() {
        Account testAcc = [SELECT Id FROM Account WHERE Name='testAccount' LIMIT 1];
        Contact testCon = [SELECT Id FROM Contact WHERE Email = 'community.test@availity.com' LIMIT 1];
        User testUser = [SELECT Id FROM User WHERE UserName = 'community.test@availity.com' LIMIT 1];
        System.runAs(testUser) {
            Test.startTest();
            
            Test.setCurrentPageReference(new PageReference('Page.CCCase'));
            System.currentPageReference().getParameters().put('listView', 'Open');
            System.currentPageReference().getParameters().put('retUrl', '/selfservice/apex/CCListCase');
			apexPages.StandardController stdCon = new apexPages.StandardController(new Case());
            CCCase ccCase = new CCCase(stdCon);
//            ccCase.getNewPayerRequestTypes();
            ccCase.setEditVisibility();
            ccCase.cs.Call_Reason__c = 'Auth/Referral';
            ccCase.cs.Submission_Method__c = 'B2B';
            ccCase.setEditVisibility();
            ccCase.cs.Call_Reason__c = 'Claims';
            ccCase.cs.Brief_Description__c = 'Batch Reject';
            ccCase.cs.Submission_Method__c = 'B2B';
            ccCase.setEditVisibility();
            ccCase.cs.Brief_Description__c = 'Claim Reject';
            ccCase.setEditVisibility();
            ccCase.cs.Brief_Description__c = 'EOB Denial';
            ccCase.setEditVisibility();
            ccCase.cs.Brief_Description__c = 'Other';
            ccCase.setEditVisibility();
            ccCase.cs.Brief_Description__c = 'Missing Response';
            ccCase.setEditVisibility();
            ccCase.cs.Call_Reason__c = 'Claim Status';
            ccCase.cs.Brief_Description__c = 'Error Message';
            ccCase.setEditVisibility();
            ccCase.cs.Call_Reason__c = 'E&B';
            ccCase.cs.Brief_Description__c = 'Error Message';
            ccCase.setEditVisibility();
            ccCase.cs.Call_Reason__c = 'ERA';
            ccCase.cs.Brief_Description__c = 'Data Issues';
            ccCase.setEditVisibility();
            ccCase.cs.Brief_Description__c = 'Enrollment';
            ccCase.setEditVisibility();
            ccCase.cs.Brief_Description__c = 'ERA Restore Request';
            ccCase.setEditVisibility();
            ccCase.cs.Brief_Description__c = 'Other';
            ccCase.setEditVisibility();
            ccCase.cs.Brief_Description__c = 'Missing ERA';
            ccCase.setEditVisibility();
            ccCase.cs.Call_Reason__c = 'Forms';
            ccCase.cs.Brief_Description__c = '835 Enrollment';
            ccCase.setEditVisibility();
            ccCase.cs.Brief_Description__c = 'Billing Service Provider Access';
            ccCase.setEditVisibility();
            ccCase.cs.Brief_Description__c = 'Other';
            ccCase.setEditVisibility();
            ccCase.cs.Brief_Description__c = 'Org Identifier Change';
            ccCase.setEditVisibility();
            ccCase.cs.Brief_Description__c = 'Org Type Change';
            ccCase.setEditVisibility();
            ccCase.cs.Brief_Description__c = 'PAA / PCA Change';
            ccCase.setEditVisibility();
            ccCase.cs.Brief_Description__c = 'Service Termination Form';
            ccCase.setEditVisibility();
            ccCase.cs.Call_Reason__c = 'FTP';
            ccCase.setEditVisibility();
            ccCase.cs.Call_Reason__c = 'Login';
            ccCase.setEditVisibility();
            ccCase.cs.Call_Reason__c = 'Remittance Viewer';
            ccCase.cs.Brief_Description__c = 'Additional Payers';
            ccCase.setEditVisibility();
            ccCase.cs.Brief_Description__c = 'Billing Service';
            ccCase.setEditVisibility();
            ccCase.cs.Brief_Description__c = 'Check Validation';
            ccCase.setEditVisibility();
            ccCase.cs.Brief_Description__c = 'Data Issues';
            ccCase.setEditVisibility();
            ccCase.cs.Brief_Description__c = 'Missing ERA';
            ccCase.setEditVisibility();
            ccCase.cs.Brief_Description__c = 'User Role Access';
            ccCase.setEditVisibility();
            ccCase.cs.Call_Reason__c = 'New Payer Request';
            ccCase.setEditVisibility();
            ccCase.cs.Government_Payer__c = true;
            ccCase.setEditVisibility();
            
            ccCase.payerVisibility = true;
            ccCase.providerVisibility = true;
            ccCase.providerNameVisibility = true;
            ccCase.provIdVisibility = true;
            ccCase.ptanVisibility = true;
            ccCase.loginVisibility = true;
            ccCase.transactionVisibility = true;
            ccCase.batchIdVisibility = true;
            ccCase.patientVisibility = true;
            ccCase.webIdVisibility = true;
            ccCase.memberVisibility = true;
            ccCase.rejectVisibility = true;
            ccCase.svcDateVisibility = true;
            ccCase.chargeAmtVisibility = true;
            ccCase.checkVisibility = true;
            ccCase.b2bVisibility = true;
            ccCase.requireBriefDescription = 'true';
            ccCase.requireSubmissionMethod = 'true';
            ccCase.cs.Call_Reason__c = '';
            ccCase.cs.Brief_Description__c = '';
            ccCase.cs.Submission_Method__c = '';
            ccCase.cs.Alternate_Email__c = 'foobar';
            ccCase.cs.Alternate_Email_2__c = 'foobar';
            ccCase.validate();

            ccCase.payerVisibility = false;
            ccCase.providerVisibility = false;
            ccCase.providerNameVisibility = false;
            ccCase.provIdVisibility = false;
            ccCase.ptanVisibility = false;
            ccCase.loginVisibility = false;
            ccCase.transactionVisibility = false;
            ccCase.batchIdVisibility = false;
            ccCase.patientVisibility = false;
            ccCase.webIdVisibility = false;
            ccCase.memberVisibility = false;
            ccCase.rejectVisibility = false;
            ccCase.svcDateVisibility = false;
            ccCase.chargeAmtVisibility = false;
            ccCase.checkVisibility = false;
            ccCase.b2bVisibility = false;
            ccCase.requireBriefDescription = '';
            ccCase.requireSubmissionMethod = '';
            ccCase.cs.Subject = 'new case';
            ccCase.cs.Description = 'new case';
            ccCase.cs.Call_Reason__c = 'Login';
            ccCase.cs.Alternate_Email__c = 'foobar';
            ccCase.cs.Alternate_Email_2__c = '';
            ccCase.save();
            ccCase.cs.Alternate_Email__c = 'foobar@example.com';
            ccCase.save();

            ccCase.cs.Subject = 'new case with attachment';
            ccCase.SaveAndAddAttachment();

			ccCase.goBack();
            
            Test.stopTest();
        }
    }

    static testMethod void testCaseDetail() {
        Contact testCon = [SELECT Id FROM Contact WHERE Email = 'community.test@availity.com' LIMIT 1];
        User testUser = [SELECT Id FROM User WHERE UserName = 'community.test@availity.com' LIMIT 1];
        Case testCase = 
            [SELECT Id,
                CaseNumber, Call_Reason__c, Brief_Description__c, Submission_Method__c,
                Payer_Name__c, Payer_ID__c, Government_Payer__c, Provider_Name__c,
                NPI_Identifier__c, Tax_ID__c, PTAN_Identifier__c, Atypical_Provider__c,
                User_ID__c, Customer_Reference_Number__c, Alternate_Email__c, Alternate_Email_2__c,
                New_Payer_Request_Type__c, EDI_Batch_ID__c, Patient_Name__c, Web_Transaction_ID__c,
                Member_ID__c, EDI_Batch_Reject_Reason__c, Date_of_Service__c, Charge_Amount__c,
                Check_Date__c, Check_Number__c, Check_Amount__c, B2B_Vendor_Transaction_ID__c,
                B2B_transaction_Date__c, B2B_Time_of_Transaction__c, B2B_Vendor_Error_Code__c,
                Subject, Description, CID_Identifier__c, ContactId, Status, RecordTypeId
             FROM Case WHERE Subject = 'New' LIMIT 1];
        System.runAs(testUser) {
            Test.startTest();
            
            Test.setCurrentPageReference(new PageReference('Page.CCCaseDetail'));
            System.currentPageReference().getParameters().put('id', testCase.Id);
            System.currentPageReference().getParameters().put('listView', 'Open');
            System.currentPageReference().getParameters().put('retUrl', '/selfservice/apex/CCListCase');
			apexPages.StandardController stdCon = new apexPages.StandardController(testCase);
            CCCase ccCase = new CCCase(stdCon);
            ccCase.setEdit();
            ccCase.cancelEdit();
            ccCase.setEdit();
            ccCase.cs.Alternate_Email__c = 'foobar';
            ccCase.saveEdit();
            ccCase.cs.Alternate_Email__c = 'foobar@example.com';
            ccCase.saveEdit();

            // Test Attachments
            List<Attachment> attachments = ccCase.getCaseAttachments();
            system.debug('\n[DEBUG-CCCaseTest.testCaseDetail()]\n=========\nAttachments: ' + attachments);
            PageReference pageRef = ccCase.addAttachment();
            system.debug('\n[DEBUG-CCCaseTest.testCaseDetail()]\n=========\nAddAttachment PageRef: ' + pageRef);
            Test.setCurrentPageReference(pageRef);
            CCAddAttachment ccAddAttachment = new CCAddAttachment();
            Blob csvFileBody = Blob.valueOf('Test File Body');
            ccAddAttachment.fileBody = csvFileBody;
            ccAddAttachment.fileName = 'Test Filename';
            pageRef = ccAddAttachment.processUpload();
            pageRef = ccAddAttachment.back();

            // Test Comments
            List<CaseComment> comments = ccCase.getCaseComments();
            system.debug('\n[DEBUG-CCCaseTest.testCaseDetail()]\n=========\nCaseComments: ' + comments);
            pageRef = ccCase.addComment();
            system.debug('\n[DEBUG-CCCaseTest.testCaseDetail()]\n=========\nAddComment PageRef: ' + pageRef);
            Test.setCurrentPageReference(pageRef);
            CCAddComment ccAddComment = new CCAddComment();
            pageRef = ccAddComment.save();
            ccAddComment.body = 'Test Comment';
            pageRef = ccAddComment.save();
            pageRef = ccAddComment.back();

            // Test other navigation buttons
            pageRef = ccCase.closeCase();
            system.debug('\n[DEBUG-CCCaseTest.testCaseDetail()]\n=========\ncloseCase PageRef: ' + pageRef);
            pageRef = ccCase.archiveCase();
            system.debug('\n[DEBUG-CCCaseTest.testCaseDetail()]\n=========\narchiveCase PageRef: ' + pageRef);
            pageRef = ccCase.reopenCase();
            system.debug('\n[DEBUG-CCCaseTest.testCaseDetail()]\n=========\nreopenCase PageRef: ' + pageRef);
            pageRef = ccCase.changeContact();
            system.debug('\n[DEBUG-CCCaseTest.testCaseDetail()]\n=========\nchangeContact PageRef: ' + pageRef);

			ccCase.goBack();

            Test.stopTest();
        }
    }

    static testMethod void testOtherCaseRelatedFunctions() {
        Contact testCon = [SELECT Id FROM Contact WHERE Email = 'community.test@availity.com' LIMIT 1];
        User testUser = [SELECT Id FROM User WHERE UserName = 'community.test@availity.com' LIMIT 1];
        Case testCase = 
            [SELECT Id,
                CaseNumber, Call_Reason__c, Brief_Description__c, Submission_Method__c,
                Payer_Name__c, Payer_ID__c, Government_Payer__c, Provider_Name__c,
                NPI_Identifier__c, Tax_ID__c, PTAN_Identifier__c, Atypical_Provider__c,
                User_ID__c, Customer_Reference_Number__c, Alternate_Email__c, Alternate_Email_2__c,
                New_Payer_Request_Type__c, EDI_Batch_ID__c, Patient_Name__c, Web_Transaction_ID__c,
                Member_ID__c, EDI_Batch_Reject_Reason__c, Date_of_Service__c, Charge_Amount__c,
                Check_Date__c, Check_Number__c, Check_Amount__c, B2B_Vendor_Transaction_ID__c,
                B2B_transaction_Date__c, B2B_Time_of_Transaction__c, B2B_Vendor_Error_Code__c,
                Subject, Description, CID_Identifier__c, ContactId, Status, RecordTypeId
             FROM Case WHERE Subject = 'New' LIMIT 1];
        System.runAs(testUser) {
            Test.startTest();

            // Test Close Case
            Test.setCurrentPageReference(new PageReference('Page.CCCloseCase'));
            System.currentPageReference().getParameters().put('id', testCase.Id);
            System.currentPageReference().getParameters().put('listView', 'Open');
            System.currentPageReference().getParameters().put('retUrl', '/selfservice/apex/CCListCase');
            CCCloseCase ccCloseCase = new CCCloseCase();
            PageReference pageRef = ccCloseCase.save();
            ccCloseCase.body = 'Test Close Case Comment';
            pageRef = ccCloseCase.save();
            pageRef = ccCloseCase.back();

            // Test Archive Case
            Test.setCurrentPageReference(new PageReference('Page.CCArchiveCase'));
            System.currentPageReference().getParameters().put('id', testCase.Id);
            System.currentPageReference().getParameters().put('listView', 'Open');
            System.currentPageReference().getParameters().put('retUrl', '/selfservice/apex/CCListCase');
			apexPages.StandardController stdCon = new apexPages.StandardController(testCase);
            CCArchiveCase ccArchiveCase = new CCArchiveCase(stdCon);
            pageRef = ccArchiveCase.archiveCase();

            // Test Reopen Case
            Test.setCurrentPageReference(new PageReference('Page.CCReopenCase'));
            System.currentPageReference().getParameters().put('id', testCase.Id);
            System.currentPageReference().getParameters().put('listView', 'Open');
            System.currentPageReference().getParameters().put('retUrl', '/selfservice/apex/CCListCase');
            CCReopenCase ccReopenCase = new CCReopenCase();
            pageRef = ccReopenCase.save();
            ccReopenCase.body = 'Test Reopen Case Comment';
            pageRef = ccReopenCase.save();
            pageRef = ccReopenCase.back();

            // Test Change Contact
            Test.setCurrentPageReference(new PageReference('Page.CCChangeCaseContact'));
            System.currentPageReference().getParameters().put('id', testCase.Id);
            System.currentPageReference().getParameters().put('listView', 'Open');
            System.currentPageReference().getParameters().put('retUrl', '/selfservice/apex/CCListCase');
            CCChangeCaseContact ccChangeCaseContact = new CCChangeCaseContact();
            ccChangeCaseContact.searchString = 'Tim';
            ccChangeCaseContact.doSearch();
            ccChangeCaseContact.contactIdChosen = testCase.ContactId;
            ccChangeCaseContact.doSave();
            ccChangeCaseContact.back();
           
            Test.stopTest();
        }
    }

    static testMethod void testSelectCaseType() {
        Contact testCon = [SELECT Id FROM Contact WHERE Email = 'community.test@availity.com' LIMIT 1];
        User testUser = [SELECT Id FROM User WHERE UserName = 'community.test@availity.com' LIMIT 1];
        RecordType customersupportRT = [SELECT Id, Name FROM RecordType WHERE Name = 'Community Support' LIMIT 1];
        System.runAs(testUser) {
            Test.startTest();
            
            Test.setCurrentPageReference(new PageReference('Page.CCSelectCaseType'));
            System.currentPageReference().getParameters().put('listView', 'Open');
            System.currentPageReference().getParameters().put('retUrl', '/selfservice/apex/CCListCase');
            CCSelectCaseType ccTest = new CCSelectCaseType();
            ccTest.getRecordTypeOptions();
            ccTest.getCaseTypes();
            ccTest.recordTypeId = customersupportRT.Id;
            ccTest.createCase();

			ccTest.back();

            Test.stopTest();
        }
    }

    static testMethod void testNewPayerRequestCreate() {
        Account testAcc = [SELECT Id FROM Account WHERE Name='testAccount' LIMIT 1];
        Contact testCon = [SELECT Id FROM Contact WHERE Email = 'community.test@availity.com' LIMIT 1];
        User testUser = [SELECT Id FROM User WHERE UserName = 'community.test@availity.com' LIMIT 1];
        System.runAs(testUser) {
            Test.startTest();
            
            Test.setCurrentPageReference(new PageReference('Page.CCNewPayerRequest'));
            System.currentPageReference().getParameters().put('listView', 'Open');
            System.currentPageReference().getParameters().put('retUrl', '/selfservice/apex/CCListCase');
			apexPages.StandardController stdCon = new apexPages.StandardController(new Case());
            CCNewPayerRequest ccCase = new CCNewPayerRequest(stdCon);
            ccCase.getNewPayerTransactions();
            ccCase.getPayerStates();

			ccCase.cs.Payer_ID__c = '';
            ccCase.cs.Payer_Name__c = '';
            ccCase.cs.New_Payer_Transaction__c = '';
            ccCase.cs.Subject = '';
            ccCase.cs.Description = '';
            ccCase.cs.Alternate_Email__c = 'foobar';
            ccCase.cs.Alternate_Email_2__c = 'foobar';
            ccCase.validate();

			ccCase.cs.Payer_Name__c = 'TEST PAYER NAME';
            ccCase.cs.Subject = 'new payer request';
            ccCase.cs.Description = 'new payer request';
            ccCase.cs.New_Payer_Transaction__c = '270';
            ccCase.cs.Alternate_Email__c = 'foobar';
            ccCase.cs.Alternate_Email_2__c = '';
            ccCase.save();
            ccCase.cs.Alternate_Email__c = 'foobar@example.com';
            ccCase.save();

            ccCase.cs.Subject = 'new case with attachment';
            ccCase.SaveAndAddAttachment();

			ccCase.goBack();
            
            Test.stopTest();
        }
    }

    static testMethod void testNewPayerRequestDetail() {
        Contact testCon = [SELECT Id FROM Contact WHERE Email = 'community.test@availity.com' LIMIT 1];
        User testUser = [SELECT Id FROM User WHERE UserName = 'community.test@availity.com' LIMIT 1];
        Case testCase = 
            [SELECT Id,
                CaseNumber, Payer_Name__c, Payer_ID__c, Alternate_Email__c, Alternate_Email_2__c,
                New_Payer_Transaction__c, Address__c, City__c, State__c, Zip_Code__c, Payer_States__c,
                Subject, Description, CID_Identifier__c, ContactId, Status, RecordTypeId
             FROM Case WHERE Subject = 'New Payer Request' LIMIT 1];
        System.runAs(testUser) {
            Test.startTest();
            
            Test.setCurrentPageReference(new PageReference('Page.CCNewPayerRequestDetail'));
            System.currentPageReference().getParameters().put('id', testCase.Id);
            System.currentPageReference().getParameters().put('listView', 'Open');
            System.currentPageReference().getParameters().put('retUrl', '/selfservice/apex/CCListCase');
			apexPages.StandardController stdCon = new apexPages.StandardController(testCase);
            CCNewPayerRequest ccCase = new CCNewPayerRequest(stdCon);
            ccCase.setEdit();
            ccCase.cancelEdit();
            ccCase.setEdit();
            ccCase.cs.Alternate_Email__c = 'foobar';
            ccCase.saveEdit();
            ccCase.cs.Alternate_Email__c = 'foobar@example.com';
            ccCase.saveEdit();

            // Test Attachments
            List<Attachment> attachments = ccCase.getCaseAttachments();
            system.debug('\n[DEBUG-CCCaseTest.testNewPayerRequestDetail()]\n=========\nAttachments: ' + attachments);
            PageReference pageRef = ccCase.addAttachment();
            system.debug('\n[DEBUG-CCCaseTest.testNewPayerRequestDetail()]\n=========\nAddAttachment PageRef: ' + pageRef);

            // Test Comments
            List<CaseComment> comments = ccCase.getCaseComments();
            system.debug('\n[DEBUG-CCCaseTest.testNewPayerRequestDetail()]\n=========\nCaseComments: ' + comments);
            pageRef = ccCase.addComment();
            system.debug('\n[DEBUG-CCCaseTest.testNewPayerRequestDetail()]\n=========\nAddComment PageRef: ' + pageRef);

            // Test other navigation buttons
            pageRef = ccCase.closeCase();
            system.debug('\n[DEBUG-CCCaseTest.testNewPayerRequestDetail()]\n=========\ncloseCase PageRef: ' + pageRef);
            pageRef = ccCase.archiveCase();
            system.debug('\n[DEBUG-CCCaseTest.testNewPayerRequestDetail()]\n=========\narchiveCase PageRef: ' + pageRef);
            pageRef = ccCase.reopenCase();
            system.debug('\n[DEBUG-CCCaseTest.testNewPayerRequestDetail()]\n=========\nreopenCase PageRef: ' + pageRef);
            pageRef = ccCase.changeContact();
            system.debug('\n[DEBUG-CCCaseTest.testNewPayerRequestDetail()]\n=========\nchangeContact PageRef: ' + pageRef);

			ccCase.goBack();

            Test.stopTest();
        }
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
            testcon.email = 'community.test@availity.com';
            testcon.AccountId = testAcc.Id;
            insert testcon;
    
            String profileName = 'Community User';
            Profile profile = [select Id from Profile where Name=:profileName];
            User user = new User(
                ContactId = testcon.Id,
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

            RecordType newpayerrequestRT = [SELECT Id, Name FROM RecordType WHERE Name = 'New Payer Request' LIMIT 1];
            RecordType customersupportRT = [SELECT Id, Name FROM RecordType WHERE Name = 'Community Support' LIMIT 1];
            Case cs = new Case();
            cs.RecordTypeId = customersupportRT.Id;
            cs.Status ='New';
            cs.AccountId = testAcc.Id;
            cs.ContactId = testCon.Id;
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
            CaseComment comment = new CaseComment(ParentId=cs.Id,CommentBody='New Case Comment');
            insert comment;
            Attachment attachment = new Attachment();
            attachment.Name='Test Attachment';
            Blob bodyBlob=Blob.valueOf('Test Attachment Body');
            attachment.body=bodyBlob;
            attachment.parentId=cs.id;
            insert attachment;
            
            cs = new Case();
            cs.RecordTypeId = customersupportRT.Id;
            cs.Status='Closed';
            cs.AccountId = testAcc.Id;
            cs.ContactId = testCon.Id;
            cs.CID_Identifier__c = '12345';
            cs.Call_Reason__c = 'Login';
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
            cs.Subject = 'Closed';
            cs.Description = 'Closed Test Subject';
            insert cs;
            
            cs = new Case();
            cs.RecordTypeId = newpayerrequestRT.Id;
            cs.Status='New';
            cs.AccountId = testAcc.Id;
            cs.ContactId = testCon.Id;
            cs.CID_Identifier__c = '12345';
            cs.Payer_Name__c = '';
            cs.Payer_ID__c = '';
            cs.Alternate_Email__c = '';
            cs.Alternate_Email_2__c = '';
            cs.Subject = 'New Payer Request';
            cs.Description = 'New Payer Request Description';
            insert cs;
            comment = new CaseComment(ParentId=cs.Id,CommentBody='New Case Comment');
            insert comment;
            attachment = new Attachment();
            attachment.Name='Test Attachment';
            bodyBlob=Blob.valueOf('Test Attachment Body');
            attachment.body=bodyBlob;
            attachment.parentId=cs.id;
            insert attachment;
            
            CCRecordTypes__c ccRT = new CCRecordTypes__c();
            ccRt.Name = 'Community Support';
            ccRt.RecordTypeId__c = customersupportRT.Id;
            ccRt.RecordTypeName__c = 'Community Support';
            ccRt.NewPage__c = 'CCCase';
            ccRT.DetailPage__c = 'CCCaseDetail';
            ccRT.RecordTypeName__c = 'Community Support';
            ccRT.RecordTypeDescription__c = 'Community Support';
            insert ccRt;
            ccRT = new CCRecordTypes__c();
            ccRt.Name = 'New Payer Request';
            ccRt.RecordTypeId__c = newpayerrequestRT.Id;
            ccRt.RecordTypeName__c = 'Add a Payer';
            ccRt.NewPage__c = 'CCNewPayerRequest';
            ccRT.DetailPage__c = 'CCNewPayerRequestDetail';
            ccRT.RecordTypeName__c = 'New Payer Request';
            ccRT.RecordTypeDescription__c = 'New Payer Request';
            insert ccRt;
        }
    }    
}