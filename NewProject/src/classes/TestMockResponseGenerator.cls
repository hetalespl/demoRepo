/*	Class for creating a mock http callout response
	Since http callouts cannot be done through test methods
	
	Version: 1.0	Date: 17-7-14	Author: Saket Joshi
*/


@isTest
global with sharing class TestMockResponseGenerator implements HttpCalloutMock {
	
	/*	Responds with a hardcoded response recieved for facebook
		Also checks if the response is Ok and whether the request method is GET
	*/
	 global HTTPResponse respond(HTTPRequest req) {
	 	
	 	String responseFacebook = '<!doctype html><html itemscope="" itemtype="http://schema.org/WebPage"' +  
	 	'About 5,650,000,000 results</div><li class="g"><h3 class="r"><a href="/url?q=https://www.facebook.com/">Welcome to <b>Facebook</b> - Log In, Sign Up or Learn More</a></h3><div class="s">' + 
	 	'<cite>https://www.<b>facebook</b>.com/</cite></div></div><span class="st"><b>Facebook</b> is a social utility that connects people with friends and others who work<br> ' + 
		', study and live around them. People use <b>Facebook</b> to keep up with...</span>';
	 	
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        System.assertEquals('GET', req.getMethod());
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setBody(responseFacebook);
        res.setStatusCode(200);
        return res;
    }

}