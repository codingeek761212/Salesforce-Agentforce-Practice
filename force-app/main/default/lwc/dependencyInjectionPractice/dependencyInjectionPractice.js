import { LightningElement, api, wire, track } from 'lwc';
import clientPaymentMode from '@salesforce/apex/CustomerPaymentMode.getPaymentMethod';


export default class DependencyInjectionPractice extends LightningElement {

    selectedPaymentMode = '';
    selectedMode = '';
    buttonGroup = [
        { label: 'Credit Card', key: 'credit', variant: 'brand'},
        { label: 'Debit Card', key: 'debit', variant: 'destructive'},
        { label: 'UPI', key: 'upi', variant: 'neutral' },
        { label: 'Crypto', key: 'crypto', variant: 'inverse' }
    ];

    handlePayment(event)
    {
        this.selectedPaymentMode = event.target.label;
        console.log('selectedPaymentMode: ', this.selectedPaymentMode);
        clientPaymentMode({paymentMethod: this.selectedPaymentMode})
            .then(result => {
                this.selectedMode = result;
        })
        .catch(error => {
            console.log(error);
        });
    }
}