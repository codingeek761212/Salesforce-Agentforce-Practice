public with sharing class AccountEnrollmentForm {
    
     private static Map<String, String> CountryWithCountryCode = new Map<String, String>{
        'Afghanistan' => 'AF',
        'Albania' => 'AL',
        'India' => 'IN'
    };

    private static Map<String, String> StateWithStateCode = new Map<String, String>{
        'Andhra Pradesh' => 'AP',
        'Arunachal Pradesh' => 'AR',
        'Assam' => 'AS',
        'Bihar' => 'BR',
        'Chhattisgarh' => 'CG',
        'Goa' => 'GA',
        'Gujarat' => 'GJ',
        'Haryana' => 'HR',
        'Himachal Pradesh' => 'HP',
        'Jammu and Kashmir' => 'JK',
        'Karnataka' => 'KA',
        'Kerala' => 'KL',
        'Madhya Pradesh' => 'MP',
        'Maharashtra' => 'MH',
        'Manipur' => 'MN'
    };

    @AuraEnabled
    public static String createAccountWithAddresses(String accountDataJson) {
        system.debug('accountDataJSON: '+accountDataJson);
        // Validate input
        if (String.isBlank(accountDataJson)) {
            throw new AuraHandledException('Account data cannot be empty.');
        }
        
        try {
            // Deserialize JSON to wrapper class
            List<AccountDataWrapper> accountDataList = (List<AccountDataWrapper>) JSON.deserialize(accountDataJson, List<AccountDataWrapper>.class);
            system.debug('accountDataList: '+accountDataList[0].Name);
            integer i = 1;
            for(Object obj : accountDataList[0].Addresses)
            {
                system.debug('Address '+i+': '+obj);
            }
            // Validate deserialized data
            if (accountDataList == null || accountDataList.isEmpty()) {
                throw new AuraHandledException('Invalid account data provided.');
            }
            
            AccountDataWrapper accountData = accountDataList[0];
            
            // Validate required fields
            //validateAccountData(accountData);
            
            // Create Account record
            Account newAccount = buildAccountRecord(accountData);
            
            // Insert Account with proper error handling
            Database.SaveResult saveResult = Database.insert(newAccount, true);
            
            if (!saveResult.isSuccess()) {
                String errorMessage = 'Failed to create Account: ';
                for (Database.Error error : saveResult.getErrors()) {
                    errorMessage += error.getMessage() + '; ';
                }
                throw new AuraHandledException(errorMessage);
            }
            
            return saveResult.getId();
            
        } catch (JSONException jsonEx) {
            throw new AuraHandledException('Error parsing account data: ' + jsonEx.getMessage());
    }
    }
    
    private static void validateAccountData(AccountDataWrapper accountData) {
        List<String> validationErrors = new List<String>();
        
        // Validate required fields
        if (String.isBlank(accountData.Name)) {
            validationErrors.add('Account Name is required.');
        }
        
        // Validate email format if provided
        if (String.isNotBlank(accountData.Email) && !isValidEmail(accountData.Email)) {
            validationErrors.add('Invalid email format.');
        }
        
        // Validate phone format if provided
        if (String.isNotBlank(accountData.Phone) && !isValidPhone(accountData.Phone)) {
            validationErrors.add('Invalid phone format.');
        }
        
        // Validate addresses if provided
        if (accountData.addresses != null && accountData.addresses.size() > 4) {
            validationErrors.add('Maximum of 4 addresses allowed.');
        }
        
        // Throw exception if any validation errors exist
        if (!validationErrors.isEmpty()) {
            throw new AuraHandledException(String.join(validationErrors, ' '));
        }
    }
    
    private static Account buildAccountRecord(AccountDataWrapper accountData) {
        Account newAccount = new Account();
        
        // Map basic fields
        newAccount.Name = accountData.Name;
        newAccount.Phone = accountData.Phone;
        
        // Handle optional fields
        if (String.isNotBlank(accountData.Email)) {
            newAccount.Account_Email__c = accountData.Email;
        }
        
        if (String.isNotBlank(accountData.Industry)) {
            newAccount.Industry = accountData.Industry;
        }
        
        if (String.isNotBlank(accountData.Type)) {
            newAccount.Type = accountData.Type;
        }
        String activeAccount = '';
        if(accountData.IsActive = true)
        {
            activeAccount = 'Yes';
        }
        else
        {
            activeAccount = 'No';
        }
        newAccount.Active__c = activeAccount; 
        
        // Map addresses to compound address fields
        if (accountData.addresses != null && !accountData.addresses.isEmpty()) {
            mapAddressesToAccount(newAccount, accountData.addresses);
        }
        
        return newAccount;
    }
    
    private static void mapAddressesToAccount(Account account, List<AddressDataWrapper> addresses) {
        
        // Sort addresses by addressNumber to ensure correct mapping
        addresses.sort();
        
        for (AddressDataWrapper address : addresses) {
            if (address.addressNumber == null || address.addressNumber < 1 || address.addressNumber > 4) {
                continue; // Skip invalid address numbers
            }
            
            switch on address.addressNumber {
                when 1 {
                    setAddressFields(account, address, 1);
                }
                when 2 {
                    setAddressFields(account, address, 2);
                }
                when 3 {
                    setAddressFields(account, address, 3);
                }
                when 4 {
                    setAddressFields(account, address, 4);
                }
            }
        }
    }
    
    private static void setAddressFields(Account account, AddressDataWrapper address, Integer addressNum) {
        
        // Map to the appropriate address fields based on addressNum
        // Adjust field API names based on your actual schema
        
        if (addressNum == 1) {
            // Assuming BillingAddress or ShippingAddress for first address
            account.BillingStreet = address.street;
            account.BillingCity = address.city;
            account.BillingState = address.province;
            account.BillingPostalCode = address.postalCode;
            account.BillingCountry = address.country;
        } else if (addressNum == 2) {
            // Assuming ShippingAddress for second address
            account.ShippingStreet = address.street;
            account.ShippingCity = address.city;
            account.ShippingState = address.province;
            account.ShippingPostalCode = address.postalCode;
            account.ShippingCountry = address.country;
        } else if(addressNum == 3) {
            account.Address_3__Street__s = address.street;
            account.Address_3__City__s = address.city;
            account.Address_3__StateCode__s = StateWithStateCode.get(address.province);
            account.Address_3__PostalCode__s = address.postalCode;
            account.Address_3__CountryCode__s = CountryWithCountryCode.get(address.country);
        }
        else
        {
            account.Address_4__Street__s = address.street;
            account.Address_4__City__s = address.city;
            account.Address_4__StateCode__s = StateWithStateCode.get(address.province);
            account.Address_4__PostalCode__s = address.postalCode;
            account.Address_4__CountryCode__s = CountryWithCountryCode.get(address.country);
        }
    }
    
    private static Boolean isValidEmail(String email) {
        String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$';
        Pattern pattern = Pattern.compile(emailRegex);
        Matcher matcher = pattern.matcher(email);
        return matcher.matches();
    }
    
    
    private static Boolean isValidPhone(String phone) {
        // Remove common formatting characters
        String cleanPhone = phone.replaceAll('[^0-9+]', '');
        // Check if it has at least 10 digits
        return cleanPhone.length() >= 10;
    }
    
    public class AccountDataWrapper implements Comparable {
        @AuraEnabled public String Name {get;set;}
        @AuraEnabled public String Phone {get;set;}
        @AuraEnabled public String Email {get;set;}
        @AuraEnabled public String Industry {get;set;}
        @AuraEnabled public String Type {get;set;}
        @AuraEnabled public Boolean IsActive {get;set;}
        @AuraEnabled public List<AddressDataWrapper> Addresses {get;set;}
        public Integer compareTo(Object compareTo) {
            return 0;
        }
    }
    
    public class AddressDataWrapper implements Comparable {
        @AuraEnabled public String id {get;set;}
        @AuraEnabled public Integer addressNumber {get;set;}
        @AuraEnabled public String street {get;set;}
        @AuraEnabled public String city {get;set;}
        @AuraEnabled public String province {get;set;}
        @AuraEnabled public String postalCode {get;set;}
        @AuraEnabled public String country {get;set;}
        
        public Integer compareTo(Object compareTo) {
            AddressDataWrapper compareToAddr = (AddressDataWrapper)compareTo;
            if (addressNumber == compareToAddr.addressNumber) return 0;
            if (addressNumber > compareToAddr.addressNumber) return 1;
            return -1;
        }
    }
}