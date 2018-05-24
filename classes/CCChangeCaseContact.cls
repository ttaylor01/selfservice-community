public with sharing class CCChangeCaseContact {
	private User myUser;
	public Case cs {get;set;}
	public List<Contact> contactlist { get; set; }
	public String contactIdChosen { get; set; }
	public String searchString { get; set; }
	public String retUrl { get; set; }
	public String caseId {get;set;}
	public String listView {get;set;}
	
	public CCChangeCaseContact() {
		retUrl = (String)Apexpages.currentPage().getParameters().get('retUrl');
		caseId = (String)Apexpages.currentPage().getParameters().get('id');
		System.debug('[DEBUG-CCChangeCaseContact.CCChangeCaseContact()]\n=========\nretUrl: ' + retUrl);
    	listView = (String)Apexpages.currentPage().getParameters().get('listView');
		System.debug('[DEBUG-CCChangeCaseContact.CCChangeCaseContact()]\n=========\nlistView: ' + listView);
		cs = [SELECT Id, CaseNumber, Subject, ContactId FROM Case WHERE Id = :caseId LIMIT 1];
		System.debug('[DEBUG-CCChangeCaseContact.CCChangeCaseContact()]\n=========\ncase: ' + cs);
		myUser = [SELECT Id, AccountId, ContactId FROM User WHERE Id = :UserInfo.getUserId()];
		system.debug('\n[DEBUG-CCChangeCaseContact.CCChangeCaseContact]\n=========\n myUser: '+myUser);
		contactlist = [SELECT Id, Name, Account.Name, Email FROM Contact WHERE AccountId = :myUser.AccountId AND Id != :cs.ContactId ORDER BY Name LIMIT 1000];
		system.debug('\n[DEBUG-CCChangeCaseContact.CCChangeCaseContact]\n=========\n contacts: '+contactlist);
	}

	public PageReference doSave() {
		cs.ContactId = contactIdChosen;
		Database.SaveResult sResult = Database.update(cs);
        if (sResult == null || !sResult.isSuccess()) {
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Could not change Contact.'));
            return null;
        }
        PageReference aPage = new PageReference(retUrl);
		aPage.getParameters().put('listView',listView);
        return aPage;
	}

	public PageReference doSearch() {
		system.debug('\n[DEBUG-CCChangeCaseContact.doSearch]\n=========\n searchString: '+searchString);
		String soql = 'SELECT Id, Name, Account.Name, Email FROM Contact ' +
			'WHERE AccountId = \'' + myUser.AccountId + '\' AND Id != \'' + cs.ContactId + '\' ' +
			' AND Name LIKE \'%' + searchString + '%\' ';
		system.debug('\n[DEBUG-CCChangeCaseContact.doSearch]\n=========\n soql: '+soql);
		try {
			contactList = Database.query(soql + ' ORDER BY Name LIMIT 1000');
		} catch (Exception e) {
			system.debug('\n[DEBUG-CCChangeCaseContact.doSearch]\n=========\n Error searching contacts'+e.getMessage());
		}
		system.debug('\n[DEBUG-CCChangeCaseContact.doSearch]\n=========\n contacts: '+contactlist);
		return null;
	}
    
    public PageReference back() {
        PageReference aPage = new PageReference(retUrl);
		aPage.getParameters().put('listView',listView);
        return aPage;
    }     
}