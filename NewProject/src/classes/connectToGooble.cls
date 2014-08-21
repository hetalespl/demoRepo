global with sharing class connectToGooble {

	webservice static void cloneViaSoap(String accountID) {
		String session_ID;
		partnerSoapSforceCom.Soap myPartnerSoap;
		myPartnerSoap = new partnerSoapSforceCom.Soap();//partner wsdl consume
		partnerSoapSforceCom.LoginResult partnerLoginResult = myPartnerSoap.login('sj@goobleforce.com','gooble1238yiWURfLCjCaPMAXtjOMpOzfR');
		session_ID = partnerLoginResult.sessionId;
		
		Http http = new Http();
		HttpRequest req = new HttpRequest();
		req.setEndpoint('https://ap1.salesforce.com/services/Soap/c/31.0/');
		req.setMethod('POST');
		req.setHeader('Content-Type', 'text/xml; charset=utf-8');
		req.SetHeader('SOAPAction','""'); 
						
		String bodyStart = '<?xml version="1.0" encoding="utf-8"?>' +
		+'<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:enterprise.soap.sforce.com" xmlns:urn1="urn:sobject.enterprise.soap.sforce.com" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">'
		+'<soap:Header><urn:SessionHeader><urn:sessionId>' + session_ID +'</urn:sessionId></urn:SessionHeader></soap:Header>'
		+'<soap:Body><urn:create><urn:sObject xsi:type="urn1:Account">';
		
		String fieldEntries = '';
		
		Map<String, Schema.Sobjectfield> accountFields = Account.SobjectType.getDescribe().fields.getMap();
		Set<String> fieldNames = accountFields.keyset();
		
		Integer temp = 1;
    	String queryStr = 'SELECT ';
	    for(String fName:fieldNames){
	       	if(temp!=1){
	       		if(fName != 'BillingAddress')
	       			if(fName != 'ShippingAddress')
	       				queryStr = queryStr + ', ' + fName;
	       	}
	       	else{
	       		queryStr = queryStr + fName;
	       	}
	       	temp++;
	    }
	    queryStr = queryStr + ' FROM Account WHERE Id = \'' + accountID + '\'';
	    Account nAccount = Database.query(queryStr);

		for(String fName:fieldNames){
	       	if(fName != 'BillingAddress' && fName != 'ShippingAddress' && accountFields.get(fName).getDescribe().isUpdateable()) {
	       		String fData = String.valueOf(nAccount.get(fName));
	       		
	       		Schema.Displaytype typeData = accountFields.get(fName).getDescribe().getType() ;
	       		if(fData != null)
	       		{
	       			fData = fData.replaceAll('\n', ' ').replaceAll('\r', ' ');
	       			if(typeData == Schema.Displaytype.Double || typeData == Schema.Displaytype.Currency) {
		       			fieldEntries += '<' + fName + ' xsd:type="double">' + fData + '</' + fName + '>';
		       		}
		       		else if(typeData == Schema.Displaytype.Integer || typeData == Schema.Displaytype.Percent
		       			 || typeData == Schema.Displaytype.Phone || typeData == Schema.Displaytype.Boolean
		       			 || typeData == Schema.Displaytype.String || typeData == Schema.Displaytype.Email) {
		       			fieldEntries += '<' + fName + ' xsd:type="string">' + fData + '</' + fName + '>';
		       		}
		       		else if(typeData == Schema.Displaytype.Date) {
		       			fieldEntries += '<' + fName + ' xsd:type="date">' + fData + '</' + fName + '>';
		       		}
		       		else if(typeData == Schema.Displaytype.Datetime) {
		       			fieldEntries += '<' + fName + ' xsd:type="dateTime">' + fData + '</' + fName + '>';
		       		}
		       		else if(typeData == Schema.Displaytype.Picklist) {
		       			if(!fName.equalsIgnoreCase('type'))
		       				fieldEntries += '<' + fName + ' xsd:type="string">' + fData + '</' + fName + '>';
		       			else
		       				fieldEntries += '<' + fName.toUpperCase() + ' xsd:type="string">' + fData + '</' + fName.toUpperCase() + '>';
		       		}
		       		else if(typeData == Schema.Displaytype.Time) {
						fieldEntries += '<' + fName + ' xsd:type="time">' + fData + '</' + fName + '>';
					}
	       		}
	      	}
	    }
		String bodyEnd = '</urn:sObject></urn:create>'
		+'</soap:Body></soap:Envelope>';
		
		req.setBody(bodyStart + fieldEntries + bodyEnd);		
		HTTPResponse res = http.send(req);
		system.debug(res.getBody());
	}
	
}