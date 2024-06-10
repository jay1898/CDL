import { LightningElement, track } from 'lwc';
import getUsers from '@salesforce/apex/CDL_LeaveManagement.getUserList';
import updateUserStatus from '@salesforce/apex/CDL_LeaveManagement.updateUserStatus';
import getOrders from '@salesforce/apex/CDL_LeaveManagement.getUserOrderList';
import updateOrderOwner from '@salesforce/apex/CDL_LeaveManagement.updateOrderOwner';
export default class LeaveManagement extends LightningElement {
    @track users = [];
    @track allOrders = [];
    @track selectedUserId;
    @track spinner = false;
    @track spinner2 = false;
    @track assignOrder = false;

    connectedCallback() {
        this.spinner = true;
        this.getuserStatus();
        const style = document.createElement('style');
        style.innerText = `.slds-modal__container{
    						width: 95% !important;
    						max-width: 95% !important;

    						max-height: 95% !important;}`;
        setTimeout(function () {
            this.template.querySelector('.overridemodalcss').appendChild(style);
        }.bind(this), 100)
    }

getuserStatus(){
getUsers()
        .then((response) => {           
                this.users = JSON.parse(response);
                this.spinner = false; 
                console.log('User-- ',this.users);            
        })
        .catch((error) => {
            console.log('Error: ', error);
            this.spinner = false;
        });
}

    handleCheckboxChange(event) {
        this.selectedUserId = '';
        let userId = event.target.name;
        const isChecked = event.target.checked;
        this.selectedUserId = userId; 
        console.log('userId ', userId);
        console.log('is checked ', isChecked);
         this.updateUser(userId, isChecked);
    
    }

    updateUser(userId, isChecked) {
        this.spinner = true;
        updateUserStatus({ userId: userId, leaveStatus: isChecked })
        .then((response) => {              
               console.log('response: ', response);  
                this.getuserStatus(); 
                this.assignOrder = response;
                
                this.getAllOrders(userId);
                this.spinner = false;
        })
        
        .catch((error) => {
            console.log('Error: ', error);
            this.spinner = false;
        });
    }
    
    closeModal() {
        this.assignOrder = false;
    } 

    getAllOrders(userId) {
        getOrders({userId: userId})
            .then((response) => {
                this.allOrders = JSON.parse(response);
                console.log('AllOrders ', this.allOrders);
               //this.spinner = false;
            })
            .catch((error) => {
                console.log('Error: ', error);
                //this.spinner = false;
            
            });
    }

    updateOrderDetails(){
        this.spinner2 = true;
        updateOrderOwner({orderList: JSON.stringify(this.allOrders)})
            .then((response) => {                      
                console.log('response ',response);
                if(response == 'success'){
                    console.log('userId ',this.selectedUserId);
                    this.getAllOrders(this.selectedUserId)
                }
                this.spinner2 = false;
            })
            .catch((error) => {
                console.log('Error: ', error); 
                this.spinner2 = false;               
            });
    }
}