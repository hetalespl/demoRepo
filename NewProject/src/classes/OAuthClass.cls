global class OAuthClass {
	
	private static Map<String, Schema.Sobjectfield> accountFields = Account.SobjectType.getDescribe().fields.getMap();
	private static Set<String> fieldNames = accountFields.keyset();
	
	public class OAuth2{
		public String id{get;set;}
		public String issued_at{get;set;}
		public String instance_url{get;set;}
		public String signature{get;set;}
		public String access_token{get;set;}
		
		private String getJsonStringForAccount(Account accountToParse) {
			
			Integer temp = fieldNames.size()-1;
			
			String jsonQuery = '{"accountInfo":[';
			String fieldsArray = ', "fieldNames":[';
			
			for(String fName:fieldNames){
	        	if(fName != 'BillingAddress' && fName != 'ShippingAddress' && accountFields.get(fName).getDescribe().isUpdateable()) {
	        		if(temp != 0) {
	        			jsonQuery += '"' + accountToParse.get(fName) + '",';
	        			fieldsArray += '"' + fName + '",';
	        		}
	        		else {
	        			jsonQuery += '"' + accountToParse.get(fName) + '"]';
	        			fieldsArray += '"' + fName + '"]}';
	        		}
	        	}
	        	temp--;
	        }
	        jsonQuery = jsonQuery.replaceAll('\n', '\\n').replaceAll('\r', '\\r');
	        
	        return jsonQuery + fieldsArray;
		}    
	}
	
	webservice static void getAuthenticated(String accountID) {
		
		String clientId = '3MVG9Y6d_Btp4xp4yQ7t1fmD1EJsw0UHQrHR_6vqFxM06b_.3bcaS0useDacIffJtKxUH4VtooL3lYNB7YX5d';
		String clientSecret = '5256923586084196263';
		String username='sj@goobleforce.com';
		String password='gooble1238yiWURfLCjCaPMAXtjOMpOzfR';
		
		String reqbody = 'grant_type=password&client_id='+clientId+'&client_secret='+clientSecret+'&username='+username+'&password='+password;
		
		Http h = new Http();
		HttpRequest req = new HttpRequest();
		req.setBody(reqbody);
		req.setMethod('POST');
		req.setEndpoint('https://ap1.salesforce.com/services/oauth2/token');
		
		HttpResponse res = h.send(req);
		system.debug(res.getBody());
		OAuth2 objAuthenticationInfo = (OAuth2)JSON.deserialize(res.getbody(), OAuth2.class);
		//RequestWrapper reqst=new RequestWrapper();
		
		if(objAuthenticationInfo.access_token!=null){
		
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
			
			Http h1 = new Http();
			HttpRequest req1 = new HttpRequest();
			req1.setHeader('Authorization','Bearer ' + objAuthenticationInfo.access_token);
			req1.setHeader('Content-Type','application/json');
			req1.setHeader('accept','application/json');
			
			if(nAccount != null) {
				req1.setBody(objAuthenticationInfo.getJsonStringForAccount(nAccount));//Send JSON body
			}
			req1.setMethod('POST');
			req1.setEndpoint('https://ap1.salesforce.com/services/apexrest/AccountClone');//URL will be your Salesforce REST API end point where you will do POST,PUT,DELETE orGET
			HttpResponse res1 = h1.send(req1);
			
		}
	}
}