import { LightningElement, api, track, wire } from 'lwc';
import ALLACCOUNTDETAILS from '@salesforce/apex/APS_AgentforceInteraction_Ctrl.getAllAccountsAndContacts';

export default class AddressCompPractice extends LightningElement {
    @api recordId;
    @api modalOpen;
    allAccountsAndContacts;

    @wire(ALLACCOUNTDETAILS)
    allAccountsAndContacts({ data, error })
    {
        if(data)
        {
            this.allAccountsAndContacts = data;
            console.log('The data is: ', JSON.stringify(this.allAccountsAndContacts));
            this.error = undefined; 
        }
        else
        {
            this.error = error;
            this.data = undefined;  
        }
    }

    handleModal(event)
    {
        this.modalOpen = !this.modalOpen;
    }

    closeModal(event)
    {
        this.handleModal();
    }

}