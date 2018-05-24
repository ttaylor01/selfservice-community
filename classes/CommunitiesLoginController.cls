/**
 * An apex page controller that exposes the site login functionality
 */
global with sharing class CommunitiesLoginController {

    global String username {get; set;}
    global String password {get; set;}
    global CommunitiesLoginController () {}
    
    global PageReference login() {
        return Site.login(username, password, null);
    }

    // Code we will invoke on page load.
    global PageReference forwardToAuthPage() {
    	String startUrl = System.currentPageReference().getParameters().get('startURL');
    	String displayType = System.currentPageReference().getParameters().get('display');
        return Network.forwardToAuthPage(startUrl, displayType);
    }
/*
	global PageReference forwardToCustomAuthPage() {
		String customHomePage = '/_ui/knowledge/ui/KnowledgeHome';
		if (UserInfo.getUserType().equals('Guest')) {
			return new PageReference('/CustomCommunitiesLogin');
		} else {
			return new PageReference(customHomePage);
		}
	}
*/
}