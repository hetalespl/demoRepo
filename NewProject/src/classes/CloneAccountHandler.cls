@RestResource(urlMapping='/AccountClone/*')
global with sharing class CloneAccountHandler {

    @httpPost
    global static void insertAccount(String[] accountInfo, String[] fieldNames) {
        
        Map<String, Schema.Sobjectfield> accountFields = Account.SobjectType.getDescribe().fields.getMap();
        
        Account nAccount = new Account();
        
        for(Integer i=0; i<accountInfo.size();i++) {
            system.debug(fieldNames[i] + ')))))');
            Schema.Displaytype typeData = accountFields.get(fieldNames[i]).getDescribe().getType();
            
            if(accountInfo[i] != 'null' && typeData != Schema.Displaytype.Reference) {
                
                if(typeData == Schema.Displaytype.Double || typeData == Schema.Displaytype.Currency)
                    nAccount.put(fieldNames[i], Double.valueOf(accountInfo[i]));
                    
                else if(typeData == Schema.Displaytype.Integer || typeData == Schema.Displaytype.Percent)
                    nAccount.put(fieldNames[i], Integer.valueOf(accountInfo[i]));
                    
                else if(typeData == Schema.Displaytype.Date)
                    nAccount.put(fieldNames[i], Date.valueOf(accountInfo[i]));
                    
                else if(typeData == Schema.Displaytype.Datetime)
                    nAccount.put(fieldNames[i], Datetime.valueOf(accountInfo[i]));
                    
                else if(typeData == Schema.Displaytype.Time) {
                    String[] timeArray = accountInfo[i].split(':');
                    nAccount.put(fieldNames[i], Time.newInstance(Integer.valueOf(timeArray[0]), Integer.valueOf(timeArray[1]),
                            Integer.valueOf(timeArray[2]), Integer.valueOf(timeArray[3])));
                }
                
                else
                    nAccount.put(fieldNames[i], accountInfo[i]);
            }
        }       
        Database.insert(nAccount, true);
    }

}