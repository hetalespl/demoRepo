/*	Class for making the Http Callout to Google.com
	to get the results of the specified query
	
	Version: 1.0	Date: 17-7-14	Author: Saket Joshi
*/

public with sharing class DoGoogleCallout {

    //Wrapper class that stores all the info for a specific search result
    public class resWrapper{
        public String title {get;set;}
        public String link {get;set;}
        public String description {get;set;}
        
        public resWrapper(String t, String l, String d){
            this.title = t;
            this.link = l;
            this.description = d;
        }
    }
    
    public List<resWrapper> wrap;
    
    public DoGoogleCallout(){
        
    }

    /*	@future method for doing the http callout to google, accepts search string, Id of the query detail record
    	boolean value as new record or not (if a new record, we have to create a new record for the respective result, else merge it)
    	also accepts a boolean to check if the call is made from apex or a visualforce page. if from apex, we need to create the pdf
    	and attach it to the respective query detail record
    */
    @future (callout=true)
    public static void doCallout(String queryRecordToSearch, String parentId, boolean newRecord, boolean fromApex){
        DoGoogleCallout obj = new DoGoogleCallout();
        obj.calloutMethod(queryRecordToSearch, parentId, newRecord, fromApex);      
    }
    
    /*	Actual method for callout, separated since we need to use same method for visualforce and apex as well
    */
    public void calloutMethod(String queryRecordToSearch, String parentId, boolean newRecord, boolean fromApex){
        wrap = new List<resWrapper>();
        
        String responseString;
        Httprequest request = new Httprequest();
        request.setHeader('Content-type', 'application/x-www-form-urlencoded');
        request.setMethod('GET');
        request.setEndpoint('https://www.google.com/search?q=' + Encodingutil.urlEncode(queryRecordToSearch, 'UTF-8'));
        
        Http http = new Http();
        
        try{
            Httpresponse response = http.send(request);
            responseString = response.getBody();
        }
        catch(Exception ex){
            
        }
        
        List<String> resList = responseString.split('<h3 class="r">');
        resList.remove(0);
        for(String str:resList){            
            if(str.contains('<cite>') && str.contains('<span class="st">')){
                
                String link,descr,title;
                Integer startA = str.indexOf('<a');
                Integer endA = str.indexOf('">');
                
                String remStr = str.substring(startA,endA + 2);
                str = str.replace(remStr,'');
                
                Integer slashA = str.indexOf('</a>'); 
                title = str.substring(0,slashA).replaceAll('<b>','').replaceAll('</b>','');
                
                Integer startC = str.indexOf('<cite>');
                Integer endC = str.indexOf('</cite>');
                
                if(startC < endC || startC!=-1 || endC!=-1 || startC!=endC){            
                
                    link = str.substring(startC+6,endC).replaceAll('<b>','').replaceAll('</b>','');
                    if(!(link.startsWith('http://') || link.startsWith('https://')))
                        link = 'http://' + link;
                        
                    str = str.replace(str.substring(startC, endC + 7), '');
                    
                    Integer startD = str.indexOf('<span class="st">');
                    str = str.replace(str.substring(0,startD),'');
                    Integer endD = str.indexOf('</span>');
                
                    descr = str.substring(17,endD).replaceAll('<b>','').replaceAll('</b>','').replaceAll('&nbsp;','').replaceAll('<br>','').replaceAll('&middot;','').replaceAll('&#39;','\'').replaceAll('&#124;','|').replaceAll('&amp;','&');
                    
                }
                
                if(link!=null){
                    wrap.add(new resWrapper(title, link, descr));
                    system.debug(title + '------' + link + '--------' + descr);
                }
            }
        }
        
        if(fromApex){
            WriteResultToObject obj = new WriteResultToObject();
            obj.writeToObject(wrap, parentId, newRecord);
        }
    }
}