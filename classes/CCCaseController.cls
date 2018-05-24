public virtual class CCCaseController {
	public Contact contact { get; set; }
	public Account acc { get; set; }
	public User user { get; set; }
	public Profile profile { get; set; }
	public Map<Id,RecordType> recordTypes { get; set; }
	public String title { get; set; }
	public String retUrl { get; set; }
	public String listView { get; set; }
	public PageReference goBack { get; set; }
	public Boolean newCase { get; set; }
	public Case cs { get; set; }
	public List<CaseComment> comments { get; set; }
	public List<Attachment> attachments { get; set; }
	public ApexPages.StandardController controller {get;set;}
	public Boolean editMode {get;set;}
	public String recordTypeName {get;set;}
	public String baseUrl ='/selfservice/apex/';

	public CCCaseController(ApexPages.StandardController con) {
		system.debug('\n[DEBUG-CCCaseController.CCCaseController()]\n=========\nStandard Controller: ' + con);
		controller = con;
		retUrl = (String)Apexpages.currentPage().getParameters().get('retUrl');
		System.debug('[DEBUG-CCCaseController.CCCaseController()]\n=========\nretUrl: ' + this.retUrl);
		goBack = Page.CCListCase;
		if(String.isNotBlank(retUrl)) goBack = new PageReference(retUrl);
		listView = (String)Apexpages.currentPage().getParameters().get('listView');
		System.debug('[DEBUG-CCCaseController.CCCaseController()]\n=========\nlistView: ' + listView);
		
		system.debug('\n[DEBUG-CCCaseController.CCCaseController()]\n=========\nCurrent Profile: ' + UserInfo.getProfileId());
		this.user = [Select Id, AccountId, ContactId, Billing_Authorization__c from User Where Id = :UserInfo.getUserId()];
		this.contact = [Select Id, Name from Contact Where Id = :user.ContactId];
		this.acc = [Select Id, Name, Entity_Gen_Key__c, TrackerOrgType__c, Organization_Type__c From Account Where Id = :user.AccountId];
		this.profile = [Select Id, Name from Profile Where Id = :UserInfo.getProfileId()];
		System.debug('[DEBUG-CCCaseController.CCCaseController()]\n=========\nUSER: ' + this.user);
		System.debug('[DEBUG-CCCaseController.CCCaseController()]\n=========\nCONTACT: ' + this.contact);

    	Map<String, CCRecordTypes__c> recordTypeNames = CCRecordTypes__c.getall();
		recordTypes = new Map<Id,RecordType>([SELECT Id, Name FROM RecordType WHERE Name IN :recordTypeNames.keySet()]);
		System.debug('[DEBUG-CCCaseController.CCCaseController()]\n=========\nCASE RECORD TYPES: ' + this.recordTypes);

        editMode = false;
	}

	public PageReference goBack() {
        System.debug('[DEBUG-CCCaseController.goBack()]\n=========\ngoBack: ' + goBack);
 		goBack.setRedirect(true);
		return goBack;
	}

	public PageReference setEdit() {
		editMode = true;
		return null;
    }

	public PageReference cancelEdit() {
		// reset alternate email fields
		editMode = false;
		return null;
    }

	public virtual PageReference saveEdit() {
        if(controller.save() == null) {
	        System.debug('[DEBUG-CCCaseController.saveEdit()]\n=========\nSave Failed');
            return null;
        }

        editMode = false;

		// redirect to detail page
        PageReference aPage = new PageReference(baseUrl+CCRecordTypes__c.getInstance(recordTypename).DetailPage__c);
		aPage.getParameters().put('id',controller.getId());
		aPage.getParameters().put('retUrl',baseUrl+'CCListCase?listView='+listView);
 		aPage.setRedirect(true);
		return aPage;
    }

	public virtual PageReference Save() {
        if(controller.save() == null) {
	        System.debug('[DEBUG-CCCaseController.Save()]\n=========\nSave Failed');
            return null;
        }

		// redirect to detail page
        PageReference aPage = new PageReference(baseUrl+CCRecordTypes__c.getInstance(recordTypename).DetailPage__c);
		aPage.getParameters().put('id',controller.getId());
		aPage.getParameters().put('retUrl','/selfservice/apex/CCListCase?listView='+listView);
 		aPage.setRedirect(true);
		return aPage;
	}

	public virtual PageReference SaveAndAddAttachment() {
        if(controller.save() == null) {
	        System.debug('[DEBUG-CCCaseController.SaveAndAddAttachment()]\n=========\nSave Failed');
            return null;
        }

		// redirect to detail page
		cs.Id = controller.getId();
		return addAttachment();
	}

	public List<CaseComment> getCaseComments() {
		if(comments == null) {
			comments = [
				SELECT Id, CommentBody, CreatedBy.Name, CreatedDate, IsPublished
				FROM CaseComment
				WHERE ParentId = :this.cs.Id AND IsPublished = true
				ORDER BY CreatedDate DESC
			];
		}
		System.debug('[DEBUG-CCCaseController.getCaseComments()]\n=========\ncomments: ' + comments);
		return comments;
	}

	public List<Attachment> getCaseAttachments() {
		if(attachments == null) {
			attachments = [
				SELECT Id, CreatedBy.Name, ParentId, Name, ContentType, LastModifiedDate, IsPrivate FROM Attachment
				WHERE ParentId = :this.cs.Id AND IsPrivate = false
			];
		}
		System.debug('[DEBUG-CCCaseController.getCaseComments()]\n=========\nattachments: ' + attachments);
		return attachments;
	}
	
	public PageReference addAttachment() {
		PageReference aPage = Page.CCAddAttachment;
		aPage.getParameters().put('id',cs.Id);
		aPage.getParameters().put('parentname',cs.CaseNumber);
		aPage.getParameters().put('listView',listView);
		aPage.getParameters().put('retUrl',baseUrl+CCRecordTypes__c.getInstance(recordTypename).DetailPage__c+'?id='+cs.Id);
		return aPage;
	}
	public PageReference addComment() {
		PageReference aPage = Page.CCAddComment;
		aPage.getParameters().put('id',cs.Id);
		aPage.getParameters().put('listView',listView);
		aPage.getParameters().put('retUrl',baseUrl+CCRecordTypes__c.getInstance(recordTypename).DetailPage__c+'?id='+cs.Id);
		return aPage;
	}
	public PageReference closeCase() {
		PageReference aPage = Page.CCCloseCase;
		aPage.getParameters().put('id',cs.Id);
		aPage.getParameters().put('listView',listView);
		aPage.getParameters().put('retUrl',baseUrl+CCRecordTypes__c.getInstance(recordTypename).DetailPage__c+'?id='+cs.Id);
		return aPage;
	}
	public PageReference archiveCase() {
		PageReference aPage = Page.CCArchiveCase;
		aPage.getParameters().put('id',cs.Id);
		aPage.getParameters().put('listView',listView);
		aPage.getParameters().put('retUrl',baseUrl+CCRecordTypes__c.getInstance(recordTypename).DetailPage__c+'?id='+cs.Id);
		return aPage;
	}
	public PageReference reopenCase() {
		PageReference aPage = Page.CCReopenCase;
		aPage.getParameters().put('id',cs.Id);
		aPage.getParameters().put('listView',listView);
		aPage.getParameters().put('retUrl',baseUrl+CCRecordTypes__c.getInstance(recordTypename).DetailPage__c+'?id='+cs.Id);
		return aPage;
	}
	public PageReference changeContact() {
		PageReference aPage = Page.CCChangeCaseContact;
		aPage.getParameters().put('id',cs.Id);
		aPage.getParameters().put('listView',listView);
		aPage.getParameters().put('retUrl',baseUrl+CCRecordTypes__c.getInstance(recordTypename).DetailPage__c+'?id='+cs.Id);
		return aPage;
	}
}