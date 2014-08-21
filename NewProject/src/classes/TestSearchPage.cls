/*	Test class for the visualforce page
	
	Version: 1.0	Date: 17-7-14	Author: Saket Joshi
*/

@isTest
public with sharing class TestSearchPage {

	/*	First we pass a value to the search string and perform the callout
		Next we perform the callout and check if the size of the results is not zero
		
		Next test, we fetch the history and assert that size is not zero. It wont
		since we are using SeeAllData=true
		
		Finally, we populate the history result list with the values of the first history
		record results. And assert that the size is not equal to zero
	*/
	
	@isTest(SeeAllData=true)
	public static void testPage(){
		
		Pagereference ref = Page.GoobleForce;
		Test.startTest();
		Test.setCurrentPage(ref);
		test.setMock(HttpCalloutMock.class, new TestMockResponseGenerator());
		Test.stopTest();
		
		goobleController obj = new goobleController();
		obj.searchQuery  ='facebook';
		
		obj.searchForQuery();
		system.assertNotEquals(obj.lstResults.size(),0);
		
		obj.getfetchHistory();
		system.assertNotEquals(obj.lstHistory.size(), 0);
		
		obj.hId = obj.lstHistory[0].Id;
		obj.queryDetails();
		
		system.assertNotEquals(obj.lstHistResults.size(),0);
	}
	
}