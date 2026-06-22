public class CustomerPaymentMode 
{
    @AuraEnabled
    public static String getPaymentMethod(String paymentMethod)
    {
        ClientPaymentMode abc = new ClientPaymentMode(paymentMethod);
        String customerPaymentMode = abc.makePayment();
        return customerPaymentMode;
    }

}