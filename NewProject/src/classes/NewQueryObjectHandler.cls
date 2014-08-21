/*	Handler class for trigger on create new email record
	Creates the new query details record if required and calls the
	Http callout function with @future annotation
	
	Version: 1.0	Date: 17-7-14	Author: Saket Joshi
*/

public with sharing class NewQueryObjectHandler {

	/*	First checks if the incoming query is existing or not. If existing, directly calls the callout method
		Else first creates the new query details record and then calls the function
	*/
    public void onCreateNewEmail(List<Incoming_Mail__c> lstNewObject){
        
        boolean isNewRecord = false;
        Incoming_Mail__c newObj = lstNewObject.get(0);
        String queryId = checkQueryExists(newObj);
        
        if(queryId!=null){
            //logic for query already existing, get the query, parse it, update the resp results and send the pdf
            system.debug('existing query 5555555');
        }
        else{
            //logic for new query record. after this, http callout and update the result, send the pdf
            queryId = createNewQueryRecord(newObj);
            isNewRecord = true;
        }
	    
	    DoGoogleCallout.doCallout(newObj.Email_Body__c, queryId, isNewRecord, true);
    }
    
    /*	Checks if the query detail record already exists or not
    	If exists, returns the Id of that record. Else returns null
    */
    private String checkQueryExists(Incoming_Mail__c incomingMail){
        try{
            List<Query_Details__c> lstCheckExists = [SELECT Id FROM Query_Details__c WHERE Query_Text__c = :incomingMail.Email_Body__c];
            if(lstCheckExists.size()!=0)
                return lstCheckExists.get(0).Id;
            return null;
        }
        catch(QueryException ex){
            system.debug(ex.getMessage());
            return null;
        }
    }
    
    /*	Creates a new query detail record. Accepts the incoming mail record as a parameter
    	On creation, returns the Id of the newly created record. If fails, returns null
    */
    private String createNewQueryRecord(Incoming_Mail__c inboundMail){
        try{
            Query_Details__c queryObj = new Query_Details__c(Name=inboundMail.Name);
            queryObj.Query_Text__c = inboundMail.Email_Body__c;
            queryObj.Incoming_Mail__c = inboundMail.Id;
            
            if(database.insert(queryObj).isSuccess())
                return queryObj.Id;
            return null;
             
        }
        catch(DMLException ex){
            system.debug(ex.getMessage());
            return null;
        }
    }
}