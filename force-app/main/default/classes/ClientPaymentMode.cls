public class ClientPaymentMode 
{
    private IPaymentService paymentService {get; set;}
    
    public ClientPaymentMode(String paymentMethod)
    {
        this.paymentService = (IPaymentService)PaymentServiceInjector.getPaymentService(paymentMethod);
        
    }
    
    public String makePayment()
    {
        String paymentModeSelected = this.paymentService.initiatePayment();
        system.debug('Customer selected: '+ paymentModeSelected);
        return paymentModeSelected;
    }

}