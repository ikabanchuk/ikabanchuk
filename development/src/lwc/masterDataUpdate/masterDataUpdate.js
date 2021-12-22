import {LightningElement, api, wire} from 'lwc';
//import getAddresses from '@salesforce/apex/MasterDataUpdateController.getAddresses';

const accountAddressColumns = [
    {label: 'Sell Id', fieldName: 'SellIdText', type: 'text'},
    {label: 'Address Type', fieldName: 'description', type: 'text'},
    {label: 'Account Name', fieldName: 'accountName', type: 'text'},
    {label: 'Account Name Add-On', fieldName: 'accountNameAddOn', type: 'text'},
    {label: 'Street', fieldName: 'street1', type: 'text'},
    {label: 'Zip Code', fieldName: 'zipCode', type: 'text'},
    {label: 'City', fieldName: 'city', type: 'text'},
    {label: 'Province', fieldName: 'province', type: 'text'},
    {label: 'Country', fieldName: 'country', type: 'text'},
];

const debtorAddressColumns = [
    {label: 'Name', fieldName: 'Name', type: 'text'},
    {label: 'Debtor Number', fieldName: 'description', type: 'text'},
    {label: 'Account Name', fieldName: 'accountName', type: 'text'},
    {label: 'Account Name Add-On', fieldName: 'accountNameAddOn', type: 'text'},
    {label: 'Street 1', fieldName: 'street1', type: 'text'},
    {label: 'Street 2', fieldName: 'street2', type: 'text'},
    {label: 'Zip Code', fieldName: 'zipCode', type: 'text'},
    {label: 'City', fieldName: 'city', type: 'text'},
    {label: 'Province', fieldName: 'province', type: 'text'},
    {label: 'Country', fieldName: 'country', type: 'text'},
];

export default class masterDataUpdate extends LightningElement {

    @api recordId;
    isLegalAddress;
    accountAddressColumns = accountAddressColumns;
    accountTypeLegalAddress = 'Legal Address';
    accountTypeVisitorAddress = 'Visitor Address';

    adresses = [];
    adressesMap = [];
    accountAddresses = [];
    accountAddressesTransformed = [];

    /*@wire(getAddresses, { opportunityRecordId: '$recordId'})
    getAddresses({ error, data }) {

        this.adressesMap=data;
        console.log('___________ adressesMap'+this.adressesMap);

        if (data) {
            for (let key in data) {
                if (data.hasOwnProperty(key)) {
                    //this.adressesMap.push({value:data[key], key:key});


                    if (key == 'Account') this.accountAddresses.push({value:data[key]});
                }
            }
            let preparedAddresses = [];
            this.accountAddresses.forEach(address => {
                console.log('___________ forEach > accountAddresses > address >'+address);
                console.log('___________ forEach > accountAddresses > address.accountName >'+address.accountName);
                console.log('___________ forEach > accountAddresses > address[0] >'+address[0]);
                let preparedAddress = {};
                preparedAddress.SellIdText = address.sellId;
                preparedAddress.description = address.description;
                preparedAddress.accountName = address.accountName;
                preparedAddress.accountNameAddOn = address.accountNameAddOn;
                preparedAddress.zipCode = address.zipCode;
                preparedAddress.city = address.city;
                preparedAddress.province = address.province;
                preparedAddress.country = address.country;
                // and so on for other fields
                preparedAddresses.push(preparedAddress);
                console.log('___________ forEach > accountAddresses > preparedAddresses >'+preparedAddresses);
            });
            this.accountAddressesTransformed = preparedAddresses;

            console.log(data);
            console.log(error);
            //this.adresses = data;

        } else if(error) {
            this.error = error;
            window.console.log(error);
        }


    }*/

    handleVerify(event) {
        console.log(event.target.label);
    }

    handleCancel(event) {
        console.log(event.target.label);
        var close = true;
        const closeclickedevt = new CustomEvent('closeclicked', {
            detail: { close },
        });
        this.dispatchEvent(closeclickedevt);
    }

    handleValueSelected(event) {

        console.log('>>>> MDU: handleValueSelected : >>>> '+event.target.label);
    }

    handlePicklistValueSelected(event) {

        console.log('>>>> MDU: handlePicklistValueSelected : >>>> '+event.detail);
    }
}


/*const accountAddressColumns = [
    {label: 'Sell Id', fieldName: 'SellIdText__c', type: 'text'},
    //{label: 'Address Type', fieldName: 'description', type: 'currency', typeAttributes: { currencyCode: 'EUR', step: '0.001'}},
    {label: 'Account Name', fieldName: 'Name', type: 'text'},
    {label: 'Account Name Add-On', fieldName: 'AccountAddOn__c', type: 'text'},
    {label: 'Street', fieldName: 'BillingStreet', type: 'text'},
    {label: 'Zip Code', fieldName: 'BillingPostalCode', type: 'text'},
    {label: 'City', fieldName: 'BillingCity', type: 'text'},
    {label: 'Province', fieldName: 'BillingState', type: 'text'},
    {label: 'Country', fieldName: 'BillingCountry', type: 'text'},
];

const debtorAddressColumns = [
    {label: 'Name', fieldName: 'Name', type: 'text'},
    {label: 'Debtor Number', fieldName: 'DebtorNumber__c', type: 'text'},
    {label: 'Account Name', fieldName: 'DebtorAccountName__c', type: 'text'},
    {label: 'Account Name Add-On', fieldName: 'DebtorAccountNameAddon__c', type: 'text'},
    {label: 'Street 1', fieldName: 'DebtorStreet__c', type: 'text'},
    {label: 'Street 2', fieldName: 'DebtorStreet2__c', type: 'text'},
    {label: 'Zip Code', fieldName: 'DebtorZipCode__c', type: 'text'},
    {label: 'City', fieldName: 'DebtorCity__c', type: 'text'},
    {label: 'Province', fieldName: 'DebtorStateProvince__c', type: 'text'},
    {label: 'Country', fieldName: 'DebtorCountry__c', type: 'text'},
];*/