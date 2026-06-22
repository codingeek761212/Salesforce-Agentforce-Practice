public with sharing class SObjectLookupDataReturner {
    
    @AuraEnabled
    public static List<OutputWrapper> getObjectRecords(String searchKey, String objectApiName, List<String> selectedIds){
        try 
        {
            SObjectLookupService sObjectLookupService = new SObjectLookupService(objectApiName);
            List<SObject> sObjectRecords = sObjectLookupService.getSObjectRecords(searchKey, selectedIds);
            List<OutputWrapper> formattedResults = new List<OutputWrapper>();
            
            system.debug('sObjectRecords: '+(String)sObjectRecords[0].get('Name'));
            for(sObject sObj: sObjectRecords)
            {
                OutputWrapper obj = new OutputWrapper();
                obj.label = (String)sObj.get('Name');
                obj.value = (Id)sObj.get('Id');
                formattedResults.add(obj);
            }
            return formattedResults;
        } 
        catch (Exception e) 
        {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public Class OutputWrapper
    {
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String value;
    }
}