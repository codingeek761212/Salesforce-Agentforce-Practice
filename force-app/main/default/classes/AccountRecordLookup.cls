public with sharing class AccountRecordLookup implements SObjectLookup_Interface{
    
    public List<Account> getObjectData(String searchKey, List<String> selectedIds)
    {
        try
        {
            String nameToSearch = '%' + searchKey + '%';
            List<Account> accounts = [SELECT Id, Name, Phone, Industry, Type from Account where Name LIKE: nameToSearch AND Id NOT IN: selectedIds];
            return accounts;
        }
        catch(Exception e)
        {
            throw new AuraHandledException(e.getMessage());
        }
    }
}