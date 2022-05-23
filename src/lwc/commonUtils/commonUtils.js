import { ShowToastEvent } from 'lightning/platformShowToastEvent'

const showToast = (title, message, variant) => {
    console.log('Common Utils ====> showToast');
    //variant: info (default), success, warning and error
    const event = new ShowToastEvent({
        title: title,
        message: message,
        variant: variant
    });
    return event;
};
export { showToast };

/**
 * @param variant: success, info, warning, error
 * @param mode: dismissable, pester, sticky
 * */
const dispatchToast = (title, message, variant, mode) => {
    console.log('Common Utils ====> dispatchToast');
    dispatchEvent(new ShowToastEvent({
        title: title,
        message: message,
        variant: variant,
        mode: mode
    }));
};
export { dispatchToast };

const getToday = () => {
    let today = new Date();
    return today.toISOString()
};

export { getToday };

const displayError = (error) => {
    var error = 'Unknown error';
    if (Array.isArray(error.body)) {
        this.error = error.body.map(e => e.message).join(', ');
    } else if (typeof error.body.message === 'string') {
        this.error = error.body.message;
    }
}

export { displayError };