global with sharing class CloneUsingWSDL {

	webservice static void insertNewAccount(Account newAccount) {
		try{
			insert newAccount;
		}
		catch (Exception ex) {
			system.debug(ex.getMessage() + ';;;;');
		}
	}

}