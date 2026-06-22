import { LightningElement, api, track } from 'lwc';

export default class AddressManager extends LightningElement {
  @api addresses = [];
  currentAddressId = null;
  nextAddressNumber = 1;
  nextId = 1;
  showDebugInfo = false;
  debugInfo = '';
  @api editMode = false;

  connectedCallback() {
    // Initialize with one empty address
    this.addNewAddress();
  }

  sendDataToParent()
  {
    console.log('Sending Data to Parent: ', JSON.stringify(this.addresses));
    const custEvent = new CustomEvent('receivedata', {detail: JSON.stringify(this.addresses)});
    this.dispatchEvent(custEvent);
  }

  /**
   * Add a new address to the array
   */
  addNewAddress() {
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
    this.sendDataToParent();
  }

  /*
   * Handle changes to address input fields
   * @param {Event} event - The change event from lightning-input-address
   */
  handleAddressChange(event) {
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
    this.sendDataToParent();

    console.log(`Address ${addressId} updated:`, updatedData);
  }

  /*
   * Handle blur event to track which address is currently being edited
   * @param {Event} event - The blur event from lightning-input-address
   */
  handleAddressBlur(event) {
    const addressId = event.target.getAttribute('data-id');
    this.currentAddressId = addressId;
    console.log(`Currently editing address: ${addressId}`);
  }

  /*
   * Update a specific address in the array
   * @param {string} addressId - The unique ID of the address
   * @param {object} updatedData - The updated address fields
   */
  updateAddressInArray(addressId, updatedData) {
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
  displayAddresses() {
    this.debugInfo = JSON.stringify(this.addresses, null, 2);
    this.showDebugInfo = true;
    console.log('All Stored Addresses:', this.addresses);
  }

  /*
   * Get all addresses (can be called from parent component)
   * @returns {array} Array of all addresses
   */
  getAllAddresses() {
    return this.addresses;
  }

  /*
   * Get the currently edited address
   * @returns {object} The address object currently being edited
   */
  getCurrentAddress() {
    return this.addresses.find(addr => addr.id === this.currentAddressId);
  }

  /*
   * Remove an address from the array by ID
   * @param {string} addressId - The unique ID of the address to remove
   */
  removeAddress(addressId) {
    this.addresses = this.addresses.filter(addr => addr.id !== addressId);
    if (this.currentAddressId === addressId) {
      this.currentAddressId = this.addresses.length > 0 ? this.addresses[0].id : null;
    }
  }
}