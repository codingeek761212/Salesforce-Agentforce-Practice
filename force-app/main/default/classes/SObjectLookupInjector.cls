public with sharing class SObjectLookupInjector {
    
    public static Object sObjectLookupClass(String sObjectName)
    {
        Type classType;
        Map<String, String> sObjectNameToApexClass = new Map<String, String>();
        for(Lookup_Object_to_Apex_Class__mdt sObjectToApexClass : [Select Id, DeveloperName, Object_Name__c, Class_Name_for_Lookup_Object__c from Lookup_Object_to_Apex_Class__mdt with SECURITY_ENFORCED])
        {
            sObjectNameToApexClass.put(sObjectToApexClass.Object_Name__c, sObjectToApexClass.Class_Name_for_Lookup_Object__c);
        }

        if(sObjectNameToApexClass.containsKey(sObjectName))
        {
            String className = sObjectNameToApexClass.get(sObjectName);
            classType = Type.forName(className);
        }
        else
        {
            classType = null;
        }
        return classType.newInstance();
    }
}