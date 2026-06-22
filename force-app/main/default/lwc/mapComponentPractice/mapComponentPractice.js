import { LightningElement, wire, api } from 'lwc';
import { getRelatedListRecords } from 'lightning/uiRelatedListApi';

export default class MapComponentPractice extends LightningElement 
{
    @api recordId;
    records = [];
    shippingAddress;
    billingAddress;
    @wire(getRelatedListRecords, {
    parentRecordId: '$recordId',
    relatedListId: 'ContactPointAddresses',
    fields: ['ContactPointAddress.Name','ContactPointAddress.Id', 'ContactPointAddress.Street','ContactPointAddress.City','ContactPointAddress.State','ContactPointAddress.PostalCode','ContactPointAddress.Country', 'ContactPointAddress.AddressType']
    })
    listInfo({ error, data }) {
        if (data) {
            this.records = data.records;
            //console.log('records in mapController: ', this.records);
            this.records.forEach((obj) =>{
                if(obj.fields.AddressType.value == 'Shipping')
                {
                    this.shippingAddress = '' + obj.fields.Street.value + ', ' + obj.fields.City.value + ', ' + obj.fields.State.value + ', ' + obj.fields.PostalCode.value + ', ' + obj.fields.Country.value;
                }
                else if(obj.fields.AddressType.value == 'Billing')
                {
                    this.billingAddress = '' + obj.fields.Street.value + ', ' + obj.fields.City.value + ', ' + obj.fields.State.value + ', ' + obj.fields.PostalCode.value + ', ' + obj.fields.Country.value;
                }
                //console.log('shippingAddress in mapController: ', this.shippingAddress);
                //console.log('billingAddress: ', this.billingAddress);
                //console.log('obj: ', obj);
            })
            this.error = undefined;
        } 
        else if (error) {
            this.error = error;
            this.records = undefined;
        }
    }
}