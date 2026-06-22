import { LightningElement, api, wire } from 'lwc';
import getLayoutData from '@salesforce/apex/DynamicFormController.getLayoutData';

export default class DynamicSObjectForm extends LightningElement
{
    @api objectApiName;
    @api recordId;
    dynamicData = [];
    editMode = false;
    @wire(getLayoutData, { objectApiName: this.objectApiName, recordId: this.recordId })
    wiredLayoutData({ error, data })
    {
        if (data)
        {
            this.dynamicData = data;
            console.log('inside dynamicData', this.dynamicData);
            this.error = undefined;
        }
        else
        {
            this.error = error;
            this.dynamicData = undefined;
        }
    }

    EditForm(event)
    {
        this.editMode = !this.editMode;
    }
}