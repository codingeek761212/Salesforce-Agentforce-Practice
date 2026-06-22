public with sharing class DynamicFormController {
    
    public class DataWrapper{
        @AuraEnabled public string iconName;
        @AuraEnabled public List<String> fieldsName;
        @AuraEnabled public string runTimeRecordId;
        @AuraEnabled public string objectAPIName;
    }

    @auraenabled(cacheable = true)
    public static DataWrapper getLayoutData(String objectApiName,string recordId){
        DataWrapper wrapperInstance = new DataWrapper();
        List<Dynamic_Form_Layout_Generator__mdt> mdtInstance = [select Id, Object_Name__c, Icon_Name__c, Lookup_Field_API_Name__c,Field_API_Names__c from Dynamic_Form_Layout_Generator__mdt where Object_Name__c =:objectApiName LIMIT 1];
        system.debug('mdtInstance: '+mdtInstance);
        wrapperInstance.iconName = mdtInstance[0].Icon_Name__c;
        wrapperInstance.objectAPIName = mdtInstance[0].Object_Name__c;
        if(String.isNotBlank(mdtInstance[0].Lookup_Field_API_Name__c)){
            String runTimeQuery = 'select id from '+ mdtInstance[0].Object_Name__c + '  where '+ mdtInstance[0].Lookup_Field_API_Name__c +' =:recordId LIMIT 1';
            system.debug(runtimequery);
            List<sobject> objInstance = database.query(runtimequery);
            if(!objInstance.isEmpty()){
                wrapperInstance.runTimeRecordId = objInstance[0].Id;
            }
        }else{
            wrapperInstance.runTimeRecordId = recordId;
        }
        wrapperInstance.fieldsName = (mdtInstance[0].Field_API_Names__c).split(',');
        
        return wrapperInstance;
    }
}