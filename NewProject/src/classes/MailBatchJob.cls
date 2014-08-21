global class MailBatchJob implements Database.Batchable<SObject>, Database.Stateful{

	global String query;
	
	global MailBatchJob(){
		this.query = 'SELECT Sender__c, Email_Body__c, Email_Subject__c FROM Incoming_Mail__c WHERE CreatedDate=Today ORDER BY CreatedDate DESC';
	}
	
	global Database.Querylocator start(Database.BatchableContext BC){
		return Database.getQueryLocator(query);
	}
	
	global void execute(Database.BatchableContext BC, List<SObject> scope){
		
		List<Messaging.SingleEmailMessage> lstMail = new List<Messaging.SingleEmailMessage>();
		Contact relatedCont;
		Query_Result__c relatedRes;
		List<Contact> mailCon = [SELECT FirstName, LastName, Email FROM Contact];
		List<Query_Result__c> res = [SELECT q.Result__c,  q.Parent_Query__c, q.Parent_Query__r.Incoming_Mail__c From Query_Result__c q];
		
		for(Sobject obj:scope){
			Incoming_Mail__c mail = (Incoming_Mail__c)obj;
			
			
			for(Contact con:mailCon){
				if(con.ID == mail.Id){
					relatedCont = con;
				}
			}
			
			for(Query_Result__c tempRes:res){
				if(tempRes.Parent_Query__r.Incoming_Mail__c == mail.Id){
					relatedRes=tempRes;
				}
			}		
		
			List<Attachment> att = [SELECT Body FROM Attachment WHERE parentID = :relatedRes.Parent_Query__c];
			
			Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
	    	attach.setContentType('application/pdf');
	    	attach.setFileName('Search Results.pdf');
	    	attach.setInline(false);
	    	attach.Body = att[0].Body;
	
	    	Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
	    	email.setToAddresses(new String[] { 'saket.joshi92@gmail.com' });
	    	email.setSubject('Results of your search');
	    	email.setHtmlBody('PFA the results of your search query');
	    	email.setFileAttachments(new Messaging.EmailFileAttachment[] { attach });
	    	
	    	lstMail.add(email);
		}
		
    	Messaging.sendEmail( lstMail );
	}
	
	global void finish(Database.BatchableContext BC){
	
	}

}