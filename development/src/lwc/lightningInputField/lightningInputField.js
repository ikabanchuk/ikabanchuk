import {LightningElement, api} from 'lwc';
import getValuesPickList from '@salesforce/apex/CommonUtils.getValuesPickList';

export default class LightningInputField extends LightningElement {

    @api objectApiName;
    @api elementId;
    @api elementIdRequired;
    @api fieldName;
    @api fieldLabel;
    @api fieldVariant;
    @api value;
    @api isRequired;
    @api fieldType;

    @api isInputField = false;
    @api isPicklist = false;
    @api isInput = false;
    @api isLabel = false;
    @api isLabelOneLine = false;
    @api isNoLabel = false;
    @api maxLength;
    @api placeholder;

    options;
    isPicklistDisabled = false;
    selectedOption;

    connectedCallback() {
        if (this.isPicklist) {
            getValuesPickList({
                objApiName: this.objectApiName,
                fieldName: this.fieldName
            })
                .then(data => {
                    this.options = data;
                })
                .catch(error => {
                    this.displayError(error);
                });
            /*getFieldLabel({
                objName:   this.objectApiName,
                fieldName: this.fieldName
            })
                .then(data => {
                    this.fieldLabel = data;
                })
                .catch(error => {
                    this.displayError(error);
                });*/
        }
    }

    handleFieldChange(event) {
        console.log(event.target.label);
        const selectedEvent = new CustomEvent('valueselected', {
            detail: event.detail.value
        });
        this.dispatchEvent(selectedEvent);
    }

    handleFieldChangePicklist(event) {
        console.log('target'+event.target.value);
        const selectedEvent = new CustomEvent('picklistvalueselected', {
            detail: event.target.value
        });
        this.dispatchEvent(selectedEvent);
    }


    //TODO: move to utility
    displayError(error) {
        this.error = 'Unknown error';
        if (Array.isArray(error.body)) {
            this.error = error.body.map(e => e.message).join(', ');
        } else if (typeof error.body.message === 'string') {
            this.error = error.body.message;
        }
    }
}