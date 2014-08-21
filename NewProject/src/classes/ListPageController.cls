/*
	Controller for the list page for accounts
	Author: Saket Jo	Date: 21/08/14
*/
public with sharing class ListPageController {
	
	public String deleteRecId {get;set;}
	public Boolean hasErrors {get;set;}
	private List<String> errorList {get;set;}
	
	public class accountListWrapper {
		public Account acc {get;set;}
		public Boolean selectBox {get;set;}
		
		public accountListWrapper(Account acc) {
			this.acc = acc;
			this.selectBox = false; 
		}
	}
	
	public List<accountListWrapper> lstAccount {get;set;}

	public ListPageController() {
		init();
	}
	
	private void init() {
		errorList = new List<String>();
		hasErrors = false;
		lstAccount = new List<accountListWrapper>();
		for(Account acc : [SELECT Id, Name, Site, BillingState, Phone, Type FROM Account]) {
			lstAccount.add(new accountListWrapper(acc));
		}
	}
	
	public PageReference deleteRecord() {
		Account accDelete = [SELECT Name FROM Account WHERE Id = :deleteRecId];
		try {
			delete(accDelete);
			lstAccount.remove(getListItemPosition(accDelete));
			return null;
		}
		catch(DMLException ex) {
			hasErrors = true;
			errorList.add('Account cannot be deleted');
			refreshPageErrors();
			return null;
		}
		catch(Exception ex) {
			hasErrors = true;
			errorList.add(ex.getMessage());
			refreshPageErrors();
			return null;
		}
	}
	
	private void refreshPageErrors() {
		for(String str : errorList) {
			Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Error, str));
		}
	}
	
	private Integer getListItemPosition(Account acc) {
		Integer location = 0;
		for(accountListWrapper nAccWrap : lstAccount) {
			if(nAccWrap.acc.Id == acc.Id) {
				return location;
			}
			location++;
		}
		return -1;
	}
}