public class PaymentServiceInjector 
{
    public static Object getPaymentService(String paymentMethod)
    {
        Type t;
        Map<String, String> serviceNameToClassName = new Map<String, String>();
        for(PaymentMethodToApex__mdt payMethod : [select Id, DeveloperName, Payment_Method__c, APEX_Class_Service__c 
                                                  from PaymentMethodToApex__mdt])
        {
            serviceNameToClassName.put(payMethod.Payment_Method__c, payMethod.APEX_Class_Service__c);
        }
        System.debug('serviceNameToClassName: '+serviceNameToClassName);
        String className = serviceNameToClassName.get(paymentMethod);
        if(className != null)
        {
            t = Type.forName(className);
        }
        return t.newInstance();
    }

}