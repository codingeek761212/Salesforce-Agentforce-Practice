import { LightningElement, api, wire, track} from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import ACCOUNT_OBJECT from '@salesforce/schema/Account';
import INDUSTRY_FIELD from '@salesforce/schema/Account.Industry';
import TYPE_FIELD from '@salesforce/schema/Account.Type';
import CreateAccount from '@salesforce/apex/AccountEnrollmentForm.createAccountWithAddresses'; 

export default class AccountForm extends NavigationMixin(LightningElement) 
{
    accountName = '';
    accountPhone = '';
    accountEmail = '';
    accountIndustry = '';
    accounType = '';
    isActive = false;
    @track industryOptions = [];
    @track typeOptions = [];
    @track addresses = [];
    currentAddressId = null;
    nextAddressNumber = 1;
    nextId = 1;
    showDebugInfo = false;
    debugInfo = '';
    accountId = '';
    @track finalAccountData = [];


    @wire(getObjectInfo, { objectApiName: ACCOUNT_OBJECT })
    objectInfo;

    // Get picklist values for the Industry field
    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: INDUSTRY_FIELD
    })
    industryPicklistHandler({ data, error }) {
        if (data) {
            // Map picklist values to combobox format
            this.industryOptions = data.values.map(item => ({
                label: item.label,
                value: item.value
            }));
        } else if (error) {
            console.error('Error fetching picklist values:', error);
        }
    }

    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: TYPE_FIELD
    })
    typePicklistHandler({ data, error }) {
        if (data) {
            // Map picklist values to combobox format
            this.typeOptions = data.values.map(item => ({
                label: item.label,
                value: item.value
            }));
        } else if (error) {
            console.error('Error fetching picklist values:', error);
        }
    }

    handleNameChange(event)
    {
        this.accountName = event.target.value;
        console.log('Account Name: ', this.accountName);
    }

    handleEmailChange(event)
    {
        this.accountEmail = event.target.value;
        console.log('Account Email: ', this.accountEmail);
    }

    handlePhoneChange(event)
    {
        this.accountPhone = event.target.value;
        console.log('Account Phone: ', this.accountPhone);
    }

    handleIndustryChange(event)
    {
        this.accountIndustry = event.target.value;
        console.log('Account Industry: ', this.accountIndustry);
    }
    
    handleTypeChange(event)
    {
        this.accountType = event.target.value;
        console.log('Account Type: ', this.accountType);
    }

    handleAccountActiveChange(event)
    {
        this.isActive = event.target.checked;
        console.log('Account Active: ', this.isActive);
    }

    connectedCallback() 
    {
    // Initialize with one empty address
        this.addNewAddress();
    }

    addNewAddress() 
    {
        if (this.nextAddressNumber <= 4)
        {
            const newAddress = {
            id: `address_${this.nextId}`,
            addressNumber: this.nextAddressNumber,
            street: '',
            city: '',
            province: '',
            postalCode: '',
            country: ''
            };

            this.addresses = [...this.addresses, newAddress];
            this.currentAddressId = newAddress.id;
            this.nextId++;
            this.nextAddressNumber++;
            console.log('Address Number: ', this.nextAddressNumber);
        }
        else
        {
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'Maximum 4 addresses allowed!',
                variant: 'error'
            });
            this.dispatchEvent(event);
        }
    }

    /*
    * Handle changes to address input fields
    * @param {Event} event - The change event from lightning-input-address
    */
    handleAddressChange(event) 
    {
        const addressId = event.target.getAttribute('data-id');
        this.currentAddressId = addressId;

        // Get the updated address values from the component
        const addressComponent = event.target;
        const updatedData = {
        street: addressComponent.street,
        city: addressComponent.city,
        province: addressComponent.province,
        postalCode: addressComponent.postalCode,
        country: addressComponent.country
        };

        // Update the address in the array
        this.updateAddressInArray(addressId, updatedData);

        console.log(`Address ${addressId} updated:`, updatedData);
    }

    /*
    * Handle blur event to track which address is currently being edited
    * @param {Event} event - The blur event from lightning-input-address
    */
    handleAddressBlur(event) 
    {
        const addressId = event.target.getAttribute('data-id');
        this.currentAddressId = addressId;
        console.log(`Currently editing address: ${addressId}`);
    }

    /*
    * Update a specific address in the array
    * @param {string} addressId - The unique ID of the address
    * @param {object} updatedData - The updated address fields
    */
    updateAddressInArray(addressId, updatedData) 
    {
        const addressIndex = this.addresses.findIndex(addr => addr.id === addressId);

        if (addressIndex !== -1) {
        // Create a new address object to trigger reactivity
        const updatedAddress = {
            ...this.addresses[addressIndex],
            ...updatedData
        };

        // Create a new array to trigger the template update
        this.addresses = [
            ...this.addresses.slice(0, addressIndex),
            updatedAddress,
            ...this.addresses.slice(addressIndex + 1)
        ];
        }
    }

    /**
     * Display all stored addresses in the debug info section
     */
    displayAddresses() 
    {
        this.debugInfo = JSON.stringify(this.addresses, null, 2);
        this.showDebugInfo = true;
        console.log('All Stored Addresses:', this.addresses);
    }

    /*
    * Get all addresses (can be called from parent component)
    * @returns {array} Array of all addresses
    */
    getAllAddresses() 
    {
        return this.addresses;
    }

    /*
    * Get the currently edited address
    * @returns {object} The address object currently being edited
    */
    getCurrentAddress() 
    {
        return this.addresses.find(addr => addr.id === this.currentAddressId);
    }

    saveAccountRecord(event)
    {
        let obj = {
            Name: this.accountName,
            Phone: this.accountPhone,
            Email: this.accountEmail,
            Type: this.accountType,
            Industry: this.accountIndustry,
            IsActive: this.isActive,
            Addresses: this.addresses
        }
        this.finalAccountData = [...this.finalAccountData, obj];
        console.log('Final Data: ', JSON.stringify(this.finalAccountData));
        this.addresses.forEach((address) => 
        {
            console.log('Address: ', address.city);
        });

        CreateAccount({ accountDataJson: JSON.stringify(this.finalAccountData) })
            .then(result => 
            {
                console.log('Account created successfully: ', result);  
                this.accountId = result;

                const event = new ShowToastEvent({
                    title: 'Success',
                    message: 'Account created successfully!',
                    variant: 'success'
                });
                this.dispatchEvent(event);

                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: this.accountId,
                        objectApiName: 'Account',
                        actionName: 'view'
                    }
                });
                this.showDebugInfo = false;
                this.accountName = '';
                this.accountPhone = '';
                this.accountEmail = '';
                this.accountType = '';
                this.accountIndustry = '';
                this.isActive = false;
                this.addresses = [];
                this.nextId = 0;
                this.nextAddressNumber = 1; 
                this.finalAccountData = [];
                this.addNewAddress();
                
            })
            .catch(error => 
            {
                console.error('Error creating account: ', error);
            });
    }


}