/*	Handler class for the visualforce page
	
	Version: 1.0	Date: 17-7-14	Author: Saket Joshi
*/

public with sharing class goobleController {
	
	public String searchQuery {get;set;}

	public List<DoGoogleCallout.resWrapper> lstResults {get;set;}
	public List<Query_Details__c> lstHistory {get;set;}
	public String hId {get;set;}
	
	public List<DoGoogleCallout.resWrapper> lstHistResults {get;set;}
	
	public goobleController(){
		
	}
	
	public goobleController(List<DoGoogleCallout.resWrapper> wrap){
		this.lstResults = wrap;
	}
	
	/*	Function for searching the query by calling the Http callout function
		Gets the results and stores them in the list lsResutls
	*/
	public void searchForQuery(){		
		DoGoogleCallout obj = new DoGoogleCallout();
		obj.calloutMethod(searchQuery, null, false, false);
		
		lstResults = obj.wrap;
	}
	
	/*	Function to get the top 10 recently created searches today
		Used for implementing the history
	*/
	public void getfetchHistory(){
		lstHistory = [SELECT Query_Text__c FROM Query_Details__c ORDER BY CreatedDate DESC LIMIT 10];
	}
	
	/*	Function to format and get the results from the record of the selected history link
		Stores the resutls in the list lstHistResults as a wrapper
	*/
	public void queryDetails(){		
		List<Query_Result__c> lstRes = [SELECT Result__c FROM Query_Result__c WHERE Parent_Query__c=:hId];
		lstHistResults = new List<DoGoogleCallout.resWrapper>(); 
		
		for(Query_Result__c res:lstRes){
			List<String> oneBlock = res.Result__c.split('\n\n');
			String title,link,descr;
			
			for(String str:oneBlock){
				List<String> sepRes = str.split('\n');
				title=sepRes[0];
				link=sepRes[1];
				descr=sepRes[2];
				
				lstHistResults.add(new DoGoogleCallout.resWrapper(title, link, descr));
			}
		}
	}
	
}