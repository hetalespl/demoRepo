/*	Class for handling inbound emails
	Also contains the proceeding functions to check if the contact exists and others
	
	Version: 1.0	Date: 17-7-14	Author: Saket Joshi
*/

global class EmailHandler implements Messaging.InboundEmailHandler {
     
     /*	Function to actually handle the incoming mail
     	Also checks if the contact with same email address exists and creates a new
     	record for the incoming mail 
     */
      global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
          
          Contact senderContact;
          Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
          
          system.debug(envelope.fromAddress + ' fromadd');
          system.debug(email.fromName + ' fromname');
          
          senderContact = contactExists(envelope.fromAddress);
          
          if(senderContact==null){
            //Logic to create a new contact with the info
            senderContact = createNewContact(email.fromName, envelope.fromAddress);
          }
          
          createEmailRecord(email, envelope, senderContact);          
          //logic to enter the received mail in the resp object
          
          return result;
      }
      
      /*	Function to actually check if the contact exists or not. Accepts the email address as a
      		parameter and returns the object of the contact if yes. Else returns null
      */
      private static Contact contactExists(String emailAddress){
        try{
            List<Contact> lstCon = [SELECT c.Name FROM Contact c WHERE c.Email = :emailAddress];
            if(lstCon.size()!=0)
                return lstCon[0];
            return null;
        }
        catch(QueryException ex){
            system.debug(ex.getMessage());
            return null;
        }
      }
      
      /*	Function to create a new contact with the given name and email address
      		returns the object of the newly created contact
      */
      private Contact createNewContact(String contactName, String contactMail){
        try{
            Contact newCont = new Contact();
            newCont.FirstName = contactName.split(' ')[0];
            newCont.LastName = contactName.split(' ')[1];
            newCont.Email = contactMail;
            
            if(database.insert(newCont).isSuccess())    
            	return newCont;
            return null;
        }   
        catch(DMLException ex){
        	system.debug(ex.getMessage());
            return null;
        }       
      }
      
      /*	Function to create a new email record for each inbound email
      		returns the Id of the newly created mail record
      */
      private String createEmailRecord(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope, Contact sender){
      	try{
      		String body = email.plainTextBody.split('\n', 0)[0];
      		
      		if(!String.isEmpty(body)){
	      		Incoming_Mail__c newMail = new Incoming_Mail__c(Name = email.subject);
	      		newMail.Email_Subject__c = email.subject;
	      		newMail.Email_Body__c = body;
	      		newMail.Sender__c = sender.Id;
      		
      			if(database.insert(newMail).isSuccess()){
      				return newMail.Id;
      			}
      		}
      		return null;
      	}
      	catch(DMLException ex){
      		system.debug(ex.getMessage());
            return null;
      	}
      }
  }