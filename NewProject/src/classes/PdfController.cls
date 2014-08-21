/*	Class that contains the method to create the pdf string
	String is created in the constructor itself.
	Contains basic html coding. The constructor accepts Id of the parent record for the specific query
	Fetches the results and then formats it based on the newlines encountered
	
	Version: 1.0	Date: 17-7-14	Author: Saket Joshi
*/


public with sharing class PdfController {
	
	public static final String FORM_HTML_START = '<HTML><BODY>';
    public static final String FORM_HTML_END = '</BODY></HTML>';
	
	public List<DoGoogleCallout.resWrapper> lstResults {get;set;}
	
	public String pdfString;
	
	public PdfController(String pId){
		
		pdfString = '' + FORM_HTML_START;
				
		List<Query_Result__c> lstRes = [SELECT Result__c FROM Query_Result__c WHERE Parent_Query__c=:pId];
		lstResults = new List<DoGoogleCallout.resWrapper>(); 
		
		for(Query_Result__c res:lstRes){
			List<String> oneBlock = res.Result__c.split('\n\n');
			String title,link,descr;
			
			for(String str:oneBlock){
				List<String> sepRes = str.split('\n');
				title=sepRes[0];
				pdfString += '<H3>' + title + '</H3><br>';
				
				link=sepRes[1];
				pdfString += '<H2><a href=' + link + '>' + link + '</a></H2><br>';
				
				descr=sepRes[2];
				pdfString += '<H2>' + descr + '</H2><br><br>';
				
				lstResults.add(new DoGoogleCallout.resWrapper(title, link, descr));
			}
		}
		pdfString += FORM_HTML_END;
		
		system.debug(pdfString + '212131313');
	}	
}