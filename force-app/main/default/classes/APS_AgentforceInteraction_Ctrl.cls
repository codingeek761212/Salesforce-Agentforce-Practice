public class APS_AgentforceInteraction_Ctrl 
{
    @AuraEnabled(cacheable=true)
    public static User getLoggedInUser()
    {
        return [Select Id, Name, Email from User where Id =:UserInfo.getUserId()];
    }
    
    
    @AuraEnabled(cacheable=true)
    public static List<AccountAndRelatedContacts> getAllAccountsAndContacts()
    {
        Map<String, List<AccountAndRelatedContacts>> mapOfAccounts = new Map<String, List<AccountAndRelatedContacts>>();
        List<AccountAndRelatedContacts> accountsAndContacts = new List<AccountAndRelatedContacts>();
        Set<Id> accountIds = new Set<Id>();
        Map<String, List<ContactPointAddress>> accountToAddresses = new Map<String, List<ContactPointAddress>>();
        List<Account> accountList = [select Id, Name, (Select Id, Name from Contacts) from Account];
        for(Integer i = 0; i < accountList.size(); i++)
        {
            system.debug('accountList: '+ accountList[i]);
            system.debug('accounts ContactList: ' + accountList[i].contacts);
        }
        for(Account acc : accountList)
        {
            accountIds.add(acc.Id);
        }
        List<ContactPointAddress> conPointAddresses = [SELECT Id, Address, AddressType, Parent.Id from ContactPointAddress where Parent.Id IN: accountIds];
        for(ContactPointAddress address : conPointAddresses)
        {
            if(accountToAddresses.containskey(address.Parent.Id))
            {
                accountToAddresses.get(address.Parent.Id).add(address);
            }
            else
            {
                accountToAddresses.put(address.Parent.Id, new List<ContactPointAddress>{address});
            }
        }
        system.debug('accountToAddresses: '+accountToAddresses);
        
        for(Account acc : accountList)
        {
            AccountAndRelatedContacts tempWrapperObj = new AccountAndRelatedContacts();
            tempWrapperObj.accountId = acc.Id;
            tempWrapperObj.accountName = acc.name;
            tempWrapperObj.contactsList = acc.contacts;
            tempWrapperObj.contactPointAddresses = accountToAddresses.get(acc.id);
            accountsAndContacts.add(tempWrapperObj);
        }
        for(AccountAndRelatedContacts obj: accountsAndContacts)
        {
            system.debug('Account details: '+JSON.serialize(obj));
        }
        return accountsAndContacts;
    }
    
    public class AccountAndRelatedContacts
    {
        @AuraEnabled
        public String accountId;
        @AuraEnabled
        public String accountName;
        @AuraEnabled
        public List<Contact> contactsList = new List<Contact>();
        @AuraEnabled
        public List<ContactPointAddress> contactPointAddresses = new List<ContactPointAddress>();
    }

}