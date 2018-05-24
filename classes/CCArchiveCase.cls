public with sharing class CCArchiveCase {

	private Case closedCase;
	public String retUrl { get; set; }
	public String caseId {get;set;}
	public String listView {get;set;}
	private ApexPages.StandardController stdController;
	
	public CCArchiveCase(ApexPages.StandardController controller){
		this.stdController = controller;
		this.closedCase = (Case)controller.getRecord();
    	caseId = (String)Apexpages.currentPage().getParameters().get('id');
		System.debug('[DEBUG-CCArchiveCase.CCArchiveCase()]\n=========\nCase Id: ' + caseId);
		retUrl = (String)Apexpages.currentPage().getParameters().get('retUrl');
		System.debug('[DEBUG-CCArchiveCase.CCArchiveCase()]\n=========\nretUrl: ' + retUrl);
    	listView = (String)Apexpages.currentPage().getParameters().get('listView');
		System.debug('[DEBUG-CCArchiveCase.CCArchiveCase()]\n=========\nlistView: ' + listView);
	}

	public PageReference archiveCase() {
		this.closedCase.Status = 'Archived';
		stdController.save();

        PageReference aPage = new PageReference(retUrl);
		aPage.getParameters().put('listView',listView);
        return aPage;
	}
    
}