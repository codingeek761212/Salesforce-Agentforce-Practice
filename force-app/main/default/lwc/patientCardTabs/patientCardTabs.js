import { LightningElement, api, track } from 'lwc';
export default class PatientCardTabs extends LightningElement
{
    @track selectedValues = [];

    handleReceivedData(event)
    {
        this.selectedValues = event.detail;
        console.log('The selected values received in the parent are: ', JSON.stringify(this.selectedValues));
    }
}