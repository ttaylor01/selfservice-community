public with sharing class ReOpenCaseExtension {
	private Case closedCase;
	private ApexPages.StandardController stdController;
	public CaseComment comment { get; set; }
	public Boolean canReopen { get; set; }
	
	public ReOpenCaseExtension(ApexPages.StandardController controller){
		this.stdController = controller;
		this.closedCase = (Case)controller.getRecord();
		this.closedCase.Status = 'Re-opened';
		this.closedCase.no_more_comments__c = false;
		this.comment = new CaseComment(ParentId = controller.getId());
		
		Case myCase = [SELECT Id,ClosedDate FROM Case WHERE Id = :controller.getId()];
		Long dtClosed = myCase.ClosedDate.getTime();
		Long dtCurrent = DateTime.now().getTime();
		Long milliseconds = dtCurrent - dtClosed;
		Long seconds = milliseconds / 1000;
		Long minutes = seconds / 60;
		Long hours = minutes / 60;
		Long days = hours / 24;
		system.debug('\n[DEBUG-ReOpenCaseExtension.ReOpenCaseExtension]\n=========\n seconds:minutes:hours:days: '+seconds+':'+minutes+':'+hours+':'+days);
		if(days >= 14) {
			canReopen = false;
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Cases cannot be re-opened beyond 14 days of case closure. Please open a new case.'));
		} else {
			canReopen = true;
		}
	}

	public PageReference doSave() {
		if(comment.CommentBody=='') {
			comment.CommentBody.addError('Please provide a reason for ReOpening this case');
			return null;
		}
		PageReference ret = stdController.save();
		insert comment;
		return ret;
	}

}