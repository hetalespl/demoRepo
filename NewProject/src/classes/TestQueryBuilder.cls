@isTest
public class TestQueryBuilder{
    public static testmethod void testQuery(){
        
        List<Account> lstAcc = new List<Account>();
        for(Integer i=0;i<199;i++){
            Account newAcc = new Account(Name='newAcc' + String.valueOf(i));
            newAcc.Email__c = 'email' + String.valueOf(i) + '@gmail.com';
        }
        insert lstAcc;
        
        List<Contact> lstCont = new List<Contact>();
        for(Integer i=0;i<199;i++){
            Contact newCnt = new Contact(LastName = 'newCnt' + String.valueOf(i));
            newCnt.Email = 'emailCnt' + String.valueOf(i) + 'gmail.com';
            newCnt.Phone = String.valueOf(i);            
        }
        insert lstCont;
        
        PageReference ref = Page.Query_Builder;
        test.setCurrentPage(ref);
        
        QueryBuilderController controller = new QueryBuilderController();
        
        List<SelectOption> objList = controller.getAllObjectsList();
        Map<String, Schema.SObjectType> objects = Schema.getGlobalDescribe();
        system.assertEquals(objects.size(), objList.size()-1);
        
        controller.selectedObject = 'Account';
        
        Map<String, Schema.SObjectField> lstFields = Schema.SObjectType.Account.fields.getMap();
        List<SelectOption> lstAccFields = controller.getallFields();
        system.assertEquals(lstFields.size(), lstAccFields.size());
        
        controller.selectedObject = 'Contact';
        List<SelectOption> lstContFields = controller.getallFields();
        
        controller.queryFields.add(lstContFields.get(3));
        controller.queryFields.add(lstContFields.get(5));
        controller.queryFields.add(lstContFields.get(4));
        
        controller.noRecords = controller.getlstRecordNumbers().get(2).getValue();
        controller.sortOrder = controller.getlstSortOrder().get(0).getValue();
        
        String field1 = lstContFields.get(3).getValue();
        String field2 = lstContFields.get(5).getValue();
        String field3 = lstContFields.get(4).getValue();
        
        String query = 'SELECT ' + field1 + ' ,' + field2 + ' ,' + field3  + ' FROM Contact ORDER BY ' +
            field1 + ' ASC LIMIT 5000';
        
        String checkQuery = 'SELECT Birthdate ,CreatedById ,CleanStatus FROM Contact ORDER BY Birthdate ASC LIMIT 5000';
        system.assertEquals(checkQuery, query);
        
        List<Sobject> lstResults = Database.query(checkQuery);
        
        controller.searchQuery();
        
        system.assertEquals(lstResults.size(), controller.queryResult.size());
    }
}