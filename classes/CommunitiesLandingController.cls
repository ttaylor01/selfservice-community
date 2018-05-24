/**
 * An apex page controller that takes the user to the right start page based on credentials or lack thereof
 */
public with sharing class CommunitiesLandingController {
    
    public CommunitiesLandingController() {}

    // Code we will invoke on page load.
    public PageReference forwardToStartPage() {
        return Network.communitiesLanding();
    }
/*

    // previous version.
    public PageReference forwardToStartPage() {
		// Will return HomePage for the current user profile.
		// If no custom setting is defined for the current users's profile, the org default HomePage is returned.
		String customHomePage = '/' + CC_App_Settings__c.getInstance(UserInfo.getProfileId()).HomePage__c;
		// Default start page
		PageReference forwardToPage = new PageReference(customHomePage);
		if (UserInfo.getUserType().equals('Guest')) {
			forwardToPage = new PageReference('/CCLoginRouting');
		} else {
			forwardToPage = new PageReference(customHomePage);
		}

		return forwardToPage;
    }
*/
    
}