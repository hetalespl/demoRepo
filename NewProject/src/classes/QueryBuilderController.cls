public with sharing class QueryBuilderController {
    
    public String selectedObject {get;set;}
    public List<SelectOption> selectedFields {get;set;}
    public List<SelectOption> queryFields {get;set;}
    public String noRecords {get;set;}
    public String sortOrder {get;set;}
    public String queryString {get;set;}
    
    public List<Sobject> queryResult {get;set;}
    
    public QueryBuilderController(){
        queryFields = new List<SelectOption>();
    }
    
    public List<Selectoption> getAllObjectsList(){
        
        List<Selectoption> retList = new List<Selectoption>();
        
        retList.add(new Selectoption('Select object', 'Select object'));
        Map<String, Schema.SObjectType> objects = Schema.getGlobalDescribe();
        Schema.DescribeSObjectResult objInfo = null;
        
        for (Schema.SObjectType obj : objects.values()) {
            objInfo = obj.getDescribe();
            retList.add(new Selectoption(objInfo.getName(), objInfo.getLabel()));
        }
        retList.sort();
        
        return retList;
    }
    
    public List<Selectoption> getallFields(){
        List<Selectoption> retList = new List<Selectoption>();
        retList.add(new Selectoption('Nothing selected', 'Select an object'));
        
        if(selectedObject!=null){
            
            retList.clear();
            //queryFields.clear();  
            Schema.Sobjecttype obj = Schema.getGlobalDescribe().get(selectedObject);
            
            Map<String, Schema.SObjectField> fieldMap = obj.getDescribe().fields.getMap();
            
            Schema.DescribeFieldResult fieldInfo = null;
            for (Schema.SObjectField field : fieldMap.values()) {
                fieldInfo = field.getDescribe();
                retList.add(new SelectOption(fieldInfo.getName(),fieldInfo.getLabel()));
            }
        }
        retList.sort();
        
        return retList;
    }
    
    public List<Selectoption> getlstRecordNumbers(){
        List<Selectoption> retOptions = new List<Selectoption> ();
        
        retOptions.add(new Selectoption('500', '500'));
        retOptions.add(new Selectoption('1000', '1000'));
        retOptions.add(new Selectoption('5000', '5000'));
        retOptions.add(new Selectoption('50000', '50000'));
        
        return retOptions;
    }
    
    public List<SelectOption> getlstSortOrder(){
        List<Selectoption> retOptions = new List<Selectoption> ();
        
        retOptions.add(new Selectoption('ASC', 'Ascending'));
        retOptions.add(new Selectoption('DESC', 'Descending'));
        
        return retOptions;
    }
    
    public Pagereference searchQuery(){
        
        if(selectedObject!=null){
            if(queryFields.size()!=0){
                if(sortOrder!=null){
                    queryString = 'SELECT ';
            
                    Integer counter = 0;
                    for(Selectoption opt:queryFields){
                        if(counter != queryFields.size()-1)
                            queryString = queryString + opt.getValue() + ' ,';
                        else
                            queryString = queryString + opt.getValue();
                            
                        counter++;
                    }
                    queryString += ' FROM ' + selectedObject + ' ORDER BY ' + queryFields[0].getValue() + ' ' + sortOrder + ' LIMIT ' + noRecords;
                    
                    queryResult = database.query(queryString);
                    if(queryResult.size()==0){
                        Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Query returned no results'));
                    }
                }
                else
                	Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Sort order is not selected'));
            }
            else
            	Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'No field selected'));
        }
        return null;
    }
}