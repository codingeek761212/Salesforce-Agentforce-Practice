import { LightningElement, api} from 'lwc';

export default class PatientEnrollmentForm extends LightningElement 
{
    @api editMode = false;
    accountName = '';
    accountPhone = '';
    accountEmail = '';
    accountWebsite = '';
    accountIndustry = '';

    editForm(event)
    {
        this.editMode = !this.editMode;
    }

    handleNameChange(event)
    {
        this.accountName = event.target.value;
    }

    handlePhoneChange(event)
    {
        this.accountPhone = event.target.value;
    }

    handleEmailChange(event)
    {
        this.accountEmail = event.target.value;
    }

    handleWebsiteChange(event)
    {
        this.accountWebsite = event.target.value;
    }

    handleIndustryChange(event)
    {
        this.accountIndustry = event.target.value;
    }


}