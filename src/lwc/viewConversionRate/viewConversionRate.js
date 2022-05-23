import {api, LightningElement, wire} from 'lwc';
import getConversionRate from '@salesforce/apex/ViewConversionRateController.getConversionRate';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import CURRENCY_ISO_CODE from '@salesforce/schema/Opportunity.CurrencyIsoCode';
import AMOUNT from '@salesforce/schema/Opportunity.Amount';
import OPPORTUNITY_NAME from '@salesforce/schema/Opportunity.Name';

const FIELDS = [
    'Opportunity.CurrencyIsoCode',
    'Opportunity.Amount',
    'Opportunity.Name'];

export default class viewConversionRate extends LightningElement {

    @api recordId;

    @api baseCode;
    @api componentMainLogo;
    @api componentTitle;

    error;
    record;
    isLoading = false;

    currencyIsoCode;
    amount;
    opportunityName;
    conversionRate;
    conversionRateAmount;

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })opportunity({ error, data }) {
        if (data) {
            this.record = data;
            this.currencyIsoCode = this.record ? getFieldValue(this.record, CURRENCY_ISO_CODE) : '';
            this.amount = this.record ? getFieldValue(this.record, AMOUNT) : '';
            this.opportunityName = this.record ? getFieldValue(this.record, OPPORTUNITY_NAME) : '';
            if (this.validateParameters()) {
                /*setTimeout(function(){
                    this.getAmountConversionRate();
                    alert('--');
                }, 1000);*/
                this.getAmountConversionRate();
            }
            this.error = undefined;
        } else if (error) {
            this.error = error;
        }
    }

    validateParameters() {
        if (this.currencyIsoCode == '' || this.amount == '' || this.opportunityName == '') {
            this.error = 'Please, validate amount and currency set up of the opportunity.';
            return false;
        }
        return true;
    }

    getAmountConversionRate() {

        this.isLoading = true;
        getConversionRate({
            opportunityId: this.recordId,
            baseCode: this.baseCode,
            opportunityCurrency: this.currencyIsoCode
        })
            .then(result => {
                this.isLoading = false;
                if (result[0] == 'success') {
                    this.conversionRate = result[1];
                    this.conversionRateAmount = result[2];
                } else {

                   this.error = result[1];
                }
            })
            .catch(error => {
                this.isLoading = false;
                this.error = error;
                return undefined;
            });
    }
}