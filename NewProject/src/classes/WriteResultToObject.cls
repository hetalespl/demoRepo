/*	Creating and/or updating the record of the query results
	Also calls the controller for creating the pdf of the results
	if the call is made from the apex page
	
	Version: 1.0	Date: 17-7-14	Author: Saket Joshi
*/

public with sharing class WriteResultToObject {

	/*	Function to write the results of the search to the record.
		Accepts the list of wrapper (formatted results), the id of the parent query detail
		and also a boolean to see if it is a new record or not. If it is, we need to create
		If the parent is not a new record, we need to merge the results
		
		Finally, callout to the pdf controller is made and the created pdf is attached to the attachments
		of the parent query detail record.
	*/
	public void writeToObject(List<DoGoogleCallout.resWrapper> resList, String parentID, boolean isNewRecord){
		
		if(isNewRecord){
			//new record, create a new record and add
			Query_Details__c qry = [SELECT Query_Text__c FROM Query_Details__c WHERE Id=:parentId];
			
			String queryResult = '';
			Query_Result__c newObj = new Query_Result__c(Name=qry.Query_Text__c);
			newObj.Parent_Query__c = parentId;
			
			for(DoGoogleCallout.resWrapper wrap:resList){
				queryResult += wrap.title + '\n' + wrap.link + '\n' + wrap.description + '\n\n';
			}
			
			newObj.Result__c = queryResult;
			insert newObj;
		}
		else{
			//existing record, MERGE
			Query_Result__c oldObj = [SELECT q.Result__c FROM Query_Result__c q WHERE q.Parent_Query__c=:parentId];
			for(DoGoogleCallout.resWrapper wrap:resList){
				if(oldObj.Result__c.contains(wrap.title) && oldObj.Result__c.contains(wrap.link)){
					//IT ALREADY CONTAINS THE RESULT, DO NOTHING
				}
				else{
					//IT DOES NOT CONTAIN THE RESULT, APPEND NEW RESULT TO EXISTING
					oldObj.Result__c += '\n' + wrap.title + '\n' + wrap.link + '\n' + wrap.description + '\n\n';
				}
			}
			update oldObj;
		}
		
		PdfController obj = new PdfController(parentId);
		Blob pdfBody;
		
		system.debug(obj.pdfString + 'PDFPDFPDFPDFPDF');
			
		try{
			pdfBody = Blob.toPdf(obj.pdfString);
		}catch (Exception e) {
	    	pdfBody = Blob.valueOf('Exception occured, ghari ja');
	    }
		
		Query_Details__c qry = [SELECT Id, Query_Text__c FROM Query_Details__c WHERE Id=:parentID];
		
		Attachment att = new Attachment();
		att.ParentId = qry.Id;
		att.Name = qry.Query_Text__c + '.pdf';
		att.Body = pdfBody;
		insert att; 
	}	
}