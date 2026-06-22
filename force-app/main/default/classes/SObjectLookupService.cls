public with sharing class SObjectLookupService {
    private SobjectLookup_Interface sObjectLookupClass {get; set;}
    public SObjectLookupService(String sObjectName)
    {
        this.sObjectLookupClass = (SobjectLookup_Interface)SObjectLookupInjector.sObjectLookupClass(sObjectName);
    }

    public List<sObject> getSObjectRecords(String searchKey, List<String> selectedIds)
    {
        return this.sObjectLookupClass.getObjectData(searchKey, selectedIds);
    }
}