/*
* TRIGGER TO CREATE A NEW QUERY OBJECT ON CREATION
* OF THE INCOMING_EMAIL RECORD
* IF THE QUERY DOES NOT EXIST, CREATE A NEW
* RECORD OF QUERY_DETAILS, ELSE DIRECTLY DO A HTTP CALLOUT
*/

trigger NewQueryObjectTrigger on Incoming_Mail__c (after insert) {
	
	if(trigger.isAfter && trigger.isInsert){
		NewQueryObjectHandler handlerObj = new NewQueryObjectHandler();
		handlerObj.onCreateNewEmail(trigger.new);
	}
	
}