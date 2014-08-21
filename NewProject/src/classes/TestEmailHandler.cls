/*	Test class for inbound email handler
	Actually, the whole program runs from this class. So eventually, it is a test class
	that tests all the other classes as well
	
	All methods check if the incoming mail, new query, results of the query and the contact
	records have been created with the appropriate values
	
	Version: 1.0	Date: 17-7-14	Author: Saket Joshi
*/

@isTest
public with sharing class TestEmailHandler {
	
	/*	FIRST SCENARIO:
		NEW CONTACT, NEW QUERY
		SeeAllData not used because we want everything to be newly created
	*/
	@isTest static void testNewContNewQuery(){
		
		String mailBody = 'Search Facebook';
		String mailFrom = 'Test Class';
		String mailSub = 'facebook';
		String mailAdd = 'testclass@saketsjo.com';
		
		Messaging.InboundEmail email = new Messaging.InboundEmail() ;
  		Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();

	  	// setup the data for the email
		email.subject = mailSub;
	  	email.fromname = mailFrom;
	  	email.plainTextBody = mailBody;
	  	env.fromAddress = mailAdd;	  	
	  	
	  	test.startTest();
	  	test.setMock(HttpCalloutMock.class, new TestMockResponseGenerator());
	  	
	  	EmailHandler handler = new EmailHandler();
	  	handler.handleInboundEmail(email, env);
	  	test.stopTest();
	  	
		Contact newCon = [SELECT Name, FirstName, LastName, Email FROM Contact];
		
		system.assertEquals(newCon.FirstName + ' ' + newCon.LastName, mailFrom);
		system.assertEquals(newCon.Email, mailAdd);
		
		Incoming_Mail__c newMail = [SELECT Email_Body__c, Email_Subject__c, Sender__c FROM Incoming_Mail__c];
		system.assertEquals(newMail.Email_Body__c, mailBody);
		
		Query_Details__c newQuery = [SELECT Query_Text__c, Incoming_Mail__c FROM Query_Details__c];
		system.assertEquals(newQuery.Query_Text__c, mailBody);
		system.assertEquals(newQuery.Incoming_Mail__c, newMail.Id);
		
		Query_Result__c newRes = [SELECT Result__c, Parent_Query__c FROM Query_Result__c];
		system.assertEquals(newRes.Parent_Query__c, newQuery.Id);
		
		Attachment newAtt = [SELECT Name FROM Attachment WHERE parentId=:newQuery.Id];
		system.assertEquals(newAtt.Name, newQuery.Query_Text__c + '.pdf');
	}
	
	/*	SECOND SCENARIO:
		NEW CONTACT, EXISTING QUERY
		SeeAllData used because we are creating a duplicate entry
	*/
	@isTest(SeeAllData=true)
	static void testNewContSameQuery(){
		String mailBody = 'reference';
		String mailFrom = 'Test Class';
		String mailSub = 'reference';
		String mailAdd = 'testclass@saketsjo.com';
		
		Messaging.InboundEmail email = new Messaging.InboundEmail() ;
  		Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();

	  	// setup the data for the email
		email.subject = mailSub;
	  	email.fromname = mailFrom;
	  	email.plainTextBody = mailBody;
	  	env.fromAddress = mailAdd;	  	
	  	
	  	test.startTest();
	  	test.setMock(HttpCalloutMock.class, new TestMockResponseGenerator());
	  	
	  	EmailHandler handler = new EmailHandler();
	  	handler.handleInboundEmail(email, env);
	  	test.stopTest();
	  	
	  	Contact newCon = [SELECT Name, FirstName, LastName, Email FROM Contact WHERE Email=:mailAdd];
		
		system.assertEquals(newCon.FirstName + ' ' + newCon.LastName, mailFrom);
		system.assertEquals(newCon.Email, mailAdd);
		
		Incoming_Mail__c newMail = [SELECT Email_Body__c, Email_Subject__c, Sender__c FROM Incoming_Mail__c WHERE Sender__c=:newCon.Id];
		system.assertEquals(newMail.Email_Body__c, mailBody);
		
		Query_Details__c newQuery = [SELECT Query_Text__c, Incoming_Mail__c FROM Query_Details__c WHERE Query_Text__c =:mailBody];
		system.assertEquals(newQuery.Query_Text__c, mailBody);
		
		Query_Result__c newRes = [SELECT Result__c, Parent_Query__c FROM Query_Result__c WHERE Parent_Query__c=:newQuery.Id];
		system.assertEquals(newRes.Parent_Query__c, newQuery.Id);
		
		List<Attachment> newAtt = [SELECT Name FROM Attachment WHERE parentId=:newQuery.Id];
		system.assertEquals(newAtt[0].Name, newQuery.Query_Text__c + '.pdf');
	}
	
	
	/*	THIRD SCENARIO:
		EXISTING CONTACT, NEW QUERY
		SeeAllData used because we are creating a duplicate entry
	*/
	@isTest(SeeAllData=true)
	static void testSameContNewQuery(){
		String mailBody = 'Code Coverage';
		String mailFrom = 'Saket Joshi';
		String mailSub = 'Code Coverage';
		String mailAdd = 'saket.joshi@eternussolutions.com';
		
		Messaging.InboundEmail email = new Messaging.InboundEmail() ;
  		Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();

	  	// setup the data for the email
		email.subject = mailSub;
	  	email.fromname = mailFrom;
	  	email.plainTextBody = mailBody;
	  	env.fromAddress = mailAdd;	  	
	  	
	  	test.startTest();
	  	test.setMock(HttpCalloutMock.class, new TestMockResponseGenerator());
	  	
	  	EmailHandler handler = new EmailHandler();
	  	handler.handleInboundEmail(email, env);
	  	test.stopTest();
	  	
	  	Contact newCon = [SELECT Name, FirstName, LastName, Email FROM Contact WHERE Email=:mailAdd];
		system.assertEquals(newCon.FirstName + ' ' + newCon.LastName, mailFrom);
		system.assertEquals(newCon.Email, mailAdd);
		
		Incoming_Mail__c newMail = [SELECT Email_Body__c, Email_Subject__c, Sender__c FROM Incoming_Mail__c WHERE Email_Body__c=:mailBody];
		system.assertEquals(newMail.Email_Body__c, mailBody);
		
		Query_Details__c newQuery = [SELECT Query_Text__c, Incoming_Mail__c FROM Query_Details__c WHERE Incoming_Mail__c =:newMail.Id];
		system.assertEquals(newQuery.Query_Text__c, mailBody);
		
		Query_Result__c newRes = [SELECT Result__c, Parent_Query__c FROM Query_Result__c WHERE Parent_Query__c=:newQuery.Id];
		system.assertEquals(newRes.Parent_Query__c, newQuery.Id);
		
		List<Attachment> newAtt = [SELECT Name FROM Attachment WHERE parentId=:newQuery.Id];
		system.assertEquals(newAtt[0].Name, newQuery.Query_Text__c + '.pdf');
	}
	
	
	/*	FINAL SCENARIO:
		EXISTING CONTACT, EXISTING QUERY
		SeeAllData used because we are creating a duplicate entry
	*/
	@isTest(SeeAllData=true)
	static void testSameContSameQuery(){
		String mailBody = 'reference';
		String mailFrom = 'Saket Joshi';
		String mailSub = 'reference';
		String mailAdd = 'saket.joshi@eternussolutions.com';
		
		Messaging.InboundEmail email = new Messaging.InboundEmail() ;
  		Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();

	  	// setup the data for the email
		email.subject = mailSub;
	  	email.fromname = mailFrom;
	  	email.plainTextBody = mailBody;
	  	env.fromAddress = mailAdd;	  	
	  	
	  	test.startTest();
	  	test.setMock(HttpCalloutMock.class, new TestMockResponseGenerator());
	  	
	  	EmailHandler handler = new EmailHandler();
	  	handler.handleInboundEmail(email, env);
	  	test.stopTest();
	  	
	  	Contact newCon = [SELECT Name, FirstName, LastName, Email FROM Contact WHERE Email=:mailAdd];		
		system.assertEquals(newCon.FirstName + ' ' + newCon.LastName, mailFrom);
		system.assertEquals(newCon.Email, mailAdd);
		
		List<Incoming_Mail__c> newMail = [SELECT Email_Body__c, Email_Subject__c, Sender__c FROM Incoming_Mail__c WHERE Email_Body__c=:mailBody];
		system.assertEquals(newMail[0].Email_Body__c, mailBody);
		
		Query_Details__c newQuery = [SELECT Query_Text__c, Incoming_Mail__c FROM Query_Details__c WHERE Query_Text__c =:mailBody];
		system.assertEquals(newQuery.Query_Text__c, mailBody);
		
		Query_Result__c newRes = [SELECT Result__c, Parent_Query__c FROM Query_Result__c WHERE Parent_Query__c=:newQuery.Id];
		system.assertEquals(newRes.Parent_Query__c, newQuery.Id);
		
		List<Attachment> newAtt = [SELECT Name FROM Attachment WHERE parentId=:newQuery.Id];
		system.assertEquals(newAtt[0].Name, newQuery.Query_Text__c + '.pdf');
	}
}