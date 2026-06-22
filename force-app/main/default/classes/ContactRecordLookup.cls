public with sharing class ContactRecordLookup  implements SObjectLookup_Interface
{
    public List<sObject> getObjectData(String searchKey, List<String> selectedIds)
    {
        try
        {
            String nameToSearch = '%' + searchKey + '%';
            List<Contact> contacts = [SELECT Id, Name, Email, Phone from Contact where Name LIKE: nameToSearch AND Id NOT IN: selectedIds];
            return (List<sObject>)contacts;
        }
        catch(Exception e)
        {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
}