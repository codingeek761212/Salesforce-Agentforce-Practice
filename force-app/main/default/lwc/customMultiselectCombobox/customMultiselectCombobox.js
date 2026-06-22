import { LightningElement, api, track } from 'lwc';
import searchRecords from '@salesforce/apex/SObjectLookupDataReturner.getObjectRecords';

export default class CustomMultiselectCombobox extends LightningElement {
    @api objectApiName = '';
    
    // Use private properties for internal state
    @track selectedValues = [];
    @track allFetchedValues = [];
    @track selectedIds = [];
    searchKey = '';
    lookupObjectOptions = [
        { label: 'Account', value: 'Account' },
        { label: 'Contact', value: 'Contact' },
        { label: 'Opportunity', value: 'Opportunity' }
    ];


    handleSelectedObject(event)
    {
        this.objectApiName = event.target.value;
        console.log('Selected Object:', this.objectApiName);
        this.selectedValues = [];
        this.selectedIds = [];
        this.searchKey = '';
        this.allFetchedValues = [];
        this.closeDropdown();
    }
    // Debouncing properties
    delayTimeout;

    handleSearchValue(event) {
        // Clear the previous timeout to reset the timer
        window.clearTimeout(this.delayTimeout);
        
        const currentSearchKey = event.target.value;
        console.log('Current Search Key: ', currentSearchKey);
        
        // --- DEBOUNCING ---
        // Wait 300ms after the user stops typing before calling Apex
        this.delayTimeout = setTimeout(() => {
            this.searchKey = currentSearchKey;
            console.log('Final Search Key: ', currentSearchKey);
            
            // Guard clause to prevent calls with no input
            if (!this.objectApiName || this.searchKey.length < 2) {
                this.allFetchedValues = [];
                // Additionally, close the dropdown if the search key is cleared
                this.closeDropdown();
                return;
            }

            // The original fetchData logic was commented out, using the direct call
            searchRecords({ searchKey: this.searchKey, objectApiName: this.objectApiName, selectedIds: this.selectedIds })
            .then(result => {
                this.allFetchedValues = result;
                console.log('Fetched Values: ', JSON.stringify(this.allFetchedValues));

                if (this.allFetchedValues.length > 0) {
                    this.openDropdown();
                } else {
                    this.closeDropdown();
                }
            })
            .catch(error => {
                console.error('Error fetching data: ', error);
                this.allFetchedValues = []; // Clear results on error
                this.closeDropdown();
            });

        }, 200); // 300ms delay
    }

    // Helper method to open the dropdown
    openDropdown() {
        const dropdown = this.template.querySelector(".slds-dropdown-trigger_click");
        if (dropdown) {
            dropdown.classList.add("slds-is-open");
        }
    }

    closeDropdown() {
        const dropdown = this.template.querySelector(".slds-dropdown-trigger_click");
        if (dropdown) {
            dropdown.classList.remove("slds-is-open");
        }
    }
    
    selectOption(event) {
        let id = event.currentTarget.dataset.id;
        let name = event.currentTarget.dataset.name;
        
        // Prevent adding the same item twice
        if (!this.selectedIds.includes(id)) {
            this.selectedValues = [...this.selectedValues, { label: name, value: id }];
            this.selectedIds = [...this.selectedIds, id];
        }
        this.closeDropdown();
        this.sendDataToParent();
        this.searchKey = '';
        this.allFetchedValues = [];
    }

    removeSelectedValue(event) {
        const removedId = event.target.name;
        this.selectedValues = this.selectedValues.filter(item => item.value !== removedId);

        this.selectedIds = this.selectedIds.filter(id => id !== removedId);
        this.sendDataToParent();
    }

    get areValuesSelected() {
        return this.selectedValues.length > 0;
    }

    sendDataToParent()
    {
        const custEvent = new CustomEvent('receivedata', {detail: this.selectedValues});
        this.dispatchEvent(custEvent);
    }
}