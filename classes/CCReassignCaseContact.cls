public with sharing class CCReassignCaseContact {
	private ApexPages.StandardController stdController;
	private User myUser;
	private Case myCase;
	public List<Contact> contactlist { get; set; }
	public String contactIdChosen { get; set; }
	public String searchString { get; set; }
	
	public CCReassignCaseContact(ApexPages.StandardController controller) {
		this.stdController = controller;
		myUser = [SELECT Id, AccountId, ContactId FROM User WHERE Id = :UserInfo.getUserId()];
		system.debug('\n[DEBUG-CCReassignCaseContact.CCReassignCaseContact]\n=========\n myUser: '+myUser);
		myCase = [SELECT Id,ContactId FROM Case WHERE Id = :controller.getId()];
		system.debug('\n[DEBUG-CCReassignCaseContact.CCReassignCaseContact]\n=========\n myCase: '+myCase);
		contactlist = [SELECT Id, Name, Account.Name, Email FROM Contact WHERE AccountId = :myUser.AccountId AND Id != :myCase.ContactId ORDER BY Name LIMIT 1000];
		system.debug('\n[DEBUG-CCReassignCaseContact.CCReassignCaseContact]\n=========\n contacts: '+contactlist);
	}

	public PageReference doSave() {
		Case updateCase = (Case)stdController.getRecord();
		system.debug('\n[DEBUG-CCReassignCaseContact.doSave]\n=========\n myCase: '+updateCase);
		updateCase.ContactId = contactIdChosen;
		system.debug('\n[DEBUG-CCReassignCaseContact.doSave]\n=========\n myCase: '+updateCase);
		PageReference ret = stdController.save();
		return ret;
	}

	public PageReference doSearch() {
		system.debug('\n[DEBUG-CCReassignCaseContact.doSearch]\n=========\n searchString: '+searchString);
		String soql = 'SELECT Id, Name, Account.Name, Email FROM Contact ' +
			'WHERE AccountId = \'' + myUser.AccountId + '\' AND Id != \'' + myCase.ContactId + '\' ' +
			' AND Name LIKE \'%' + searchString + '%\' ';
		system.debug('\n[DEBUG-CCReassignCaseContact.doSearch]\n=========\n soql: '+soql);
		try {
			contactList = Database.query(soql + ' ORDER BY Name LIMIT 1000');
		} catch (Exception e) {
			system.debug('\n[DEBUG-CCReassignCaseContact.doSearch]\n=========\n Error searching contacts'+e.getMessage());
		}
		system.debug('\n[DEBUG-CCReassignCaseContact.doSearch]\n=========\n contacts: '+contactlist);
		return null;
	}
}