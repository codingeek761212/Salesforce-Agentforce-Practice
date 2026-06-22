public with sharing class GenericSObjectMultiselectController {
    
    private static final Map<String, List<String>> SOBJECT_FIELD_MAP = new Map<String, List<String>>{
        'Account' => new List<String>{'Id', 'Name', 'Phone', 'Type', 'Industry'},
        'Contact' => new List<String>{'Id', 'FirstName', 'LastName', 'Email'}
    };

    private static final Map<String, String> SOBJECT_SEARCH_FIELD_MAP = new Map<String, String>{
        'Account' => 'Name',
        'Contact' => 'Name'
    };

    @AuraEnabled
    public static List<ResultWrapper> getObjectData(String searchKey, String objectApiName, List<String> selectedIds) {
        system.debug('searchKeyword: '+searchKey);
        system.debug('selectedIds: '+selectedIds);
        system.debug('objectApiName: '+objectApiName);
        
        if (String.isBlank(searchKey) || String.isBlank(objectApiName)) {
            return new List<ResultWrapper>();
        }

        //String objectApiName = objectApiName;
        List<String> fieldsToQuery = SOBJECT_FIELD_MAP.get(objectApiName);
        String searchField = SOBJECT_SEARCH_FIELD_MAP.get(objectApiName);

        if (fieldsToQuery == null || searchField == null) {
            throw new AuraHandledException('Searching on object ' + objectApiName + ' is not supported.');
        }

        SObjectType sObjectType = Schema.getGlobalDescribe().get(objectApiName);
        if (sObjectType == null || !sObjectType.getDescribe().isAccessible()) {
            throw new AuraHandledException('You do not have permission to access the ' + objectApiName + ' object.');
        }

        Map<String, SObjectField> fieldMap = sObjectType.getDescribe().fields.getMap();
        for (String field : fieldsToQuery) {
            if (!fieldMap.containsKey(field.toLowerCase()) || !fieldMap.get(field.toLowerCase()).getDescribe().isAccessible()) {
                throw new AuraHandledException('You do not have permission to access a required field on the ' + objectApiName + ' object.');
            }
        }

        try {
            String searchKeyword = '%' + searchKey + '%'; 
            //List<String> selectedIds = selectedIds != null ? selectedIds : new List<String>();
            String soqlQuery = 'SELECT ' + String.join(fieldsToQuery, ', ') + ' ';
            soqlQuery += 'FROM ' + objectApiName + ' ';
            soqlQuery += 'WHERE ' + searchField + ' LIKE :searchKeyword ';
            
            if (!selectedIds.isEmpty()) {
                soqlQuery += 'AND Id NOT IN :selectedIds ';
            }
            soqlQuery += 'ORDER BY ' + searchField + ' ASC LIMIT 200';

            
            List<SObject> searchResults = Database.query(soqlQuery);
            
            List<ResultWrapper> formattedResults = new List<ResultWrapper>();
            for (SObject sObj : searchResults) {
                if (objectApiName == 'Account') {
                    formattedResults.add(new ResultWrapper((String)sObj.get('Name'), (Id)sObj.get('Id')));
                } else if (objectApiName == 'Contact') {
                    String fullName = (String)sObj.get('FirstName') + ' ' + (String)sObj.get('LastName');
                    formattedResults.add(new ResultWrapper(fullName, (Id)sObj.get('Id')));
                }
            }
            return formattedResults;

        } 
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class InputWrapper {
        @AuraEnabled
        public String searchKey;
        @AuraEnabled
        public String objectApiName;
        @AuraEnabled
        public List<String> selectedIds;
    }
    
    public class ResultWrapper {
        @AuraEnabled public String label;
        @AuraEnabled public String value;
        public ResultWrapper(String label, String value) {
            this.label = label;
            this.value = value;
        }
    }
}