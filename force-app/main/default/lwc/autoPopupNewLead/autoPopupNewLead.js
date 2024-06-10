import { LightningElement, track, api } from 'lwc';
import getOrders from '@salesforce/apex/CDL_LeadManagement.getnewOrderList';
import verifiedOrder from '@salesforce/apex/CDL_LeadManagement.verifiedOrder';
import updateOrderDetails from '@salesforce/apex/CDL_LeadManagement.updateOrderDetails';
import getOrderItem from '@salesforce/apex/CDL_LeadManagement.orderItemList';
import getfollowupItems from '@salesforce/apex/CDL_LeadManagement.followupItemsList';
import getLatestfollowupItem from '@salesforce/apex/CDL_LeadManagement.latestfollowupItem';
import UpdateFollowUpIsVerified from '@salesforce/apex/CDL_LeadManagement.UpdateFollowUpIsVerified';
import voidOrder from '@salesforce/apex/CDL_LeadManagement.voidOrder';

export default class AutoPopupNewLead extends LightningElement {
    @api orderid;
    @track currentStage = 'Waiting...';
    @track allOrders = []; //Records to be displayed on the page
    @track orderItems = []; //Records to be displayed on the page
    @track callStatus = 'Pending';
    @track recordsPerOerderStatus = 'All';
    @track recordsPerOerderDays = 'All';
    @track spinner = false;
    @track orderItemSpinner = false;
    @track collectAllOrders = [];
    @track varifiedOrderDetails = [];
    @track selectedOrderNumber;
    @track orderUrl;
    @track followupItems = [];
    @track latestfollowupItem = {};
    @track NewfollowupItem = '';
    @track followUpComment = '';
    @track newFollouptime = '';
    @track isVisibleOrderdetails = true;
    @track allFolloupsByStatus = [];
    @track selectedOrderId = '';
    @track isLastfollowupPending = true;
    @track followUpVisible = false;
    @track setDefaultTime;
    @track skipOrderIds = [];
    @track intialComment = false;
    @track isVisibleVarifiedButton = false;
    

    //modal
    orderDetailsModal = false;
    infoModal = false;
    @track selectedOrderIndex;

    orderId;
    orderName;
    orderAmount;
    paymentStatus;
    phoneNumber;
    //billing data
    billingStreet;
    billingCity;
    billingZipCode;
    billingState;
    billingCountry;

    //Shipping data
    shippingStreet;
    shippingCity;
    shippingZipCode;
    shippingState;
    shippingCountry;

    get callStatusOption() {
        return [
            { label: "Pending", value: "Pending" },
            { label: "Customer Not Received", value: "Customer Not Received" },
            { label: "Done", value: "Done" },
            
        ];
    }

    connectedCallback() {
        console.log('get selected orderid--',this.orderid);
        this.setDefaultTime = new Date().toISOString();
        this.spinner = true;
        this.getAllOrders();
    }

    getAllOrders() {
        this.spinner = true; 
        getOrders({orderId:this.orderid})
            .then((response) => {
            
                const parsedResponse = JSON.parse(response);
                if(parsedResponse.orderList.length === 0)
                {
                    this.isVisibleOrderdetails = false;
                    
                }else{            
                    this.allOrders = parsedResponse.orderList;                      
                    this.spinner = false;
                    this.getVerificationDetails();
                    
                }
                
            })
            .catch((error) => {
                console.log('Error:', error);
                this.spinner = false;
            });
    }

    getVerificationDetails() {
        this.isVisibleOrderdetails = true;
        this.followUpComment = '';
        const style = document.createElement('style');
        style.innerText = `.slds-modal__container{
    						width: 95% !important;
    						max-width: 95% !important;

    						max-height: 95% !important;}`;
        setTimeout(function () {
            this.template.querySelector('.overridemodalcss').appendChild(style);
        }.bind(this), 100)

        this.varifiedOrderDetails = [];
        this.selectedOrderIndex = '0';
        let row = this.allOrders[this.selectedOrderIndex];
        
        this.selectedOrderId = row.Id;
        if (row.isVerified__c) {
            this.isVisibleVarifiedButton = false;
        }else{
            this.isVisibleVarifiedButton = true;
        }
        this.currentStage = row.Order_Delivery_Status__c;
        this.selectedOrderNumber = row.Name;
        this.phoneNumber = row.Account__r.Phone__c;
        this.callStatus = row.Call__c;
        this.varifiedOrderDetails = this.allOrders[this.selectedOrderIndex];
        this.orderId = row.Id;
        this.orderName = 'Go to Order: '+row.Name;
        this.orderAmount = row.Grand_Total__c;
        this.paymentStatus = row.Payment_Status__c;
        this.billingStreet = row.Billing_Street__c;
        this.billingCity = row.Billing_City__c;
        this.billingZipCode = row.Billing_PostalCode__c;
        this.billingState = row.Billing_State__c;
        this.billingCountry = row.Billing_Country__c;

        this.shippingStreet = row.Shipping_Street__c;
        this.shippingCity = row.Shipping_City__c;
        this.shippingZipCode = row.Shipping_PostalCode__c;
        this.shippingState = row.Shipping_State__c;
        this.shippingCountry = row.Shipping_Country__c;

        this.newFollouptime = row.Next_FollowUp_Time__c;    

        this.orderItemSpinner = true;
        getOrderItem({ OrderId: row.Id })
            .then((response) => {
                this.orderItemSpinner = false;
                this.orderItems = [];
                this.orderItems = JSON.parse(response);
            })
            .catch((error) => {
                this.orderItemSpinner = false;
                console.log('Error:', error);
            });
        ;
        getfollowupItems({ OrderId: row.Id })
            .then((response) => {
                this.followupItems = [];
                this.followupItems = JSON.parse(response);
                if(this.followupItems.length === 0){
                    this.followUpVisible = false; 
                }else{
                    this.followUpVisible = true; 
                }
            })
            .catch((error) => {
                console.log('Error:', error);
            });
        getLatestfollowupItem({ OrderId: row.Id })
            .then((response) => {
                if(response != null)
                {
                    this.latestfollowupItem = '';
                    this.latestfollowupItem = JSON.parse(response);
                    
                    if (this.latestfollowupItem.Comment__c != null && this.latestfollowupItem.Comment__c != '') {
                        this.isLastfollowupPending = false;
                    }
                    else { this.isLastfollowupPending = true; }
                }else{
                    
                    this.intialComment = true; 
                }
            })
            .catch((error) => {
                console.log('Error:', error);
            });
        this.orderDetailsModal = true;
        
    }
     
    redirectToOrder() {
        let row = this.allOrders[0];
        console.log('rowId', window.location.origin);
        this.orderUrl = window.location.origin + '/' + row.Id;
        window.open(this.orderUrl, "_blank");

    }
    updateOrderDetails(){
        console.log('JSON.stringify(this.varifiedOrderDetails):;', JSON.stringify(this.varifiedOrderDetails));
        this.spinner = true;
        updateOrderDetails({ orderDetails: JSON.stringify(this.varifiedOrderDetails) })
            .then((response) => {
                console.log('response:;', response);
                this.getAllOrders();
                this.spinner = false;
            })
            .catch((error) => {
                console.log('Error:', error);
                this.spinner = false;
            });
    }
    orderVerified() {
        
         this.spinner = true;
        verifiedOrder({ orderDetails: JSON.stringify(this.varifiedOrderDetails) })
            .then((response) => {
                console.log('response:;', response);
                this.getAllOrders();
                this.spinner = false;
            })
            .catch((error) => {
                console.log('Error:', error);
                this.spinner = false;
            });
    }

    orderVoided() {
            this.spinner = true;
            voidOrder({ orderId: this.orderid })
                .then(result => {
                    this.getAllOrders();
                    this.spinner = false;
                    console.log('Order voided successfully',result);
                })
                .catch(error => {
                    console.error('Error voiding order:', error);
                    this.spinner = false;    
                });
        }
    
    UpdateFollowUpDetails() {
        
        const isIsuredCorrect = [...this.template.querySelectorAll('.organizeNameValid')]
        .reduce((validSoFar, inputField) => {
            inputField.reportValidity();
            if (!inputField.checkValidity()) {
                inputField.focus(); // Set focus on the first invalid input field
            }
            return validSoFar && inputField.checkValidity();
        }, true);
        if (isIsuredCorrect) {
        
        this.latestfollowupItem.Comment__c = this.followUpComment;
        this.latestfollowupItem.Order__c = this.selectedOrderId;
        this.followUpComment = '';
        //console.log('this.latestfollowupItem;', JSON.stringify(this.latestfollowupItem));
        UpdateFollowUpIsVerified({ folloupItemdetail: JSON.stringify(this.latestfollowupItem),nextFollowUpTime: this.newFollouptime,intialComment:this.intialComment})
            .then((response) => {
                this.getAllOrders();     
            })
            .catch((error) => {           
                console.log('Error:', error);
            }); 
       
            
        }
        
    }

    verifiedOrderSave(event) {
        this.varifiedOrderDetails[event.target.name] = event.target.value;
    }

    handleInputChange(event) {
        // Update the inputValue property with the value from the input field
        this.followUpComment = event.target.value;
    }
    handleInputTimeChange(event) {
        // Update the inputValue property with the value from the input field
        let originalDate = new Date(event.target.value);

        // Convert the Date object to the desired format
        this.newFollouptime = originalDate.toISOString().slice(0, -5) + '.000+0000';
        console.log('newFollouptime--'+this.newFollouptime);
    }

    handlefilterChange(event) {
        this.callStatus = event.target.value;
       
    }

    getDefaultDateTime() {
        // Get today's date
        let today = new Date();

        // Set the time to 5:30 PM
        today.setHours(17);
        today.setMinutes(30);
        today.setSeconds(0);
        today.setMilliseconds(0);

        // Format the date to be compatible with lightning-input
        return today.toISOString();
    }
}