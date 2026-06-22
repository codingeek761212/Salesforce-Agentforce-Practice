import { LightningElement, api, wire } from 'lwc';
import ALL_ACCOUNTS_CONTACTS from '@salesforce/apex/APS_AgentforceInteraction_Ctrl.getAllAccountsAndContacts';

export default class AccountsAndContactsAgentforceComp extends LightningElement
{
    @wire(ALL_ACCOUNTS_CONTACTS)
    wiredAccountsAndContacts({ error, data })
    {
        if (data)
        {
            console.log('data', data);
            let arr = data;
            console.log('arr: ', JSON.stringify(arr));
        }
        else if (error)
        {
            console.log('error', error);

        }
    }
}