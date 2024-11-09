import { LightningElement, wire } from 'lwc';
import getAccountName from '@salesforce/apex/accountnameclass.getAccountName';
import USER_ID from '@salesforce/user/Id';

export default class Account_name extends LightningElement {
    accountName;

    connectedCallback() {
        getAccountName({ userId: USER_ID })
            .then(result => {
                //console.log('result', result);
                this.accountName = result;
            })
            .catch(error => {
                console.error('Error fetching account name', error);
            });
        
        // Moved console.log inside the then function
        //console.log('user', USER_ID);
    }
}