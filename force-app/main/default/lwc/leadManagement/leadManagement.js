import { LightningElement, track } from 'lwc';
import getOrders from '@salesforce/apex/CDL_LeadManagement.getOrderLit';
export default class LeadManagement extends LightningElement {
    @track allOrders = []; //Records to be displayed on the page
    @track orderItems = []; //Records to be displayed on the page
    @track recordsPerOerderStatus = 'All';
    @track recordsPerOerderDays = 'All';
    @track spinner = false;
    @track orderItemSpinner = false;
    @track collectAllOrders = [];
    @track varifiedOrderDetails = [];
    @track selectedOrderNumber;
    @track orderUrl;
    @track followupItems = [];
    @track latestfollowupItem = '';
    @track NewfollowupItem = '';
    @track followUpComment = '';
    @track newFollouptime = '';
    @track isVisibleOrderdetails = true;
    @track allFolloupsByStatus = [];
    @track sendorderid = '';
    @track isLastfollowupPending = true;

    //Pagination
    pageSizeOptions = [5, 10, 25, 50, 75, 100]; //Page size options
    records = []; //All records available in the data table
    columns = []; //columns information available in the data table
    totalRecords = 0; //Total no.of records
    pageSize; //No.of records to be displayed per page
    totalPages; //Total no.of pages
    pageNumber = 1; //Page number

    //modal
    orderDetailsModal = false;
    //abandonedOrderDetailsModal = false;
    infoModal = false;
    @track selectedOrderIndex;

    orderId;
    orderAmount;
    paymentStatus;
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
    

    connectedCallback() {
        this.spinner = true;
        this.getAllOrders();
        //this.getAllFollowupsdata();
    }

    getAllOrders() {
        getOrders({ orderStatus: this.recordsPerOerderStatus, orderDays: this.recordsPerOerderDays })
            .then((response) => {
                this.records = JSON.parse(response);
                //this.collectAllOrders= this.records;
                this.totalRecords = JSON.parse(response).length; // update total records count
                this.pageSize = this.pageSizeOptions[0]; //set pageSize with default value as first option
                this.paginationHelper(); // call helper menthod to update pagination logic
                //this.allOrders = JSON.parse(response);
                this.spinner = false;
            })
            .catch((error) => {
                console.log('Error:', error);
                this.spinner = false;
            });
    }
    
    get filterOptions() {
        return [
            { label: "All", value: "All" },
            { label: "Abandoned", value: "Abandoned" },
            { label: "Confirm", value: "Confirm" },
            { label: "Voided", value: "voided" },
            { label: "Out For Delivery", value: "Out for Delivery" }
        ];
    }

    get filterbyDays() {
        return [
            { label: "All", value: "All" },
            { label: "ToDay", value: "today" },
            { label: "YesterDay", value: "yesterday" },
            { label: "Last 3 Months", value: "30" },
            { label: "Last 6 Months", value: "180" },
            { label: "Last 1 Year", value: "365" }
        ];
    }

    get paymentfilterOptions() {
        return [
            { label: "All", value: "All" },
            { label: "Paid", value: "paid" },
            { label: "Pending", value: "pending" },
            { label: "Voided", value: "voided" }
        ];
    }

    handlefilterChange(event) {
        //this.pageNumber = 1;
        this.recordsPerOerderStatus = event.target.value;
        this.spinner = true;
        this.getAllOrders();
    }

    handleDaysfilterChange(event) {
        this.recordsPerOerderDays = event.target.value;
        this.spinner = true;
        this.getAllOrders();
    }

    get bDisableFirst() {
        return this.pageNumber == 1;
    }
    get bDisableLast() {
        return this.pageNumber == this.totalPages;
    }
    handleRecordsPerPage(event) {
        this.pageSize = event.target.value;
        this.paginationHelper();
    }
    previousPage() {
        this.pageNumber = this.pageNumber - 1;
        this.paginationHelper();
    }
    nextPage() {
        this.pageNumber = this.pageNumber + 1;
        this.paginationHelper();
    }
    firstPage() {
        this.pageNumber = 1;
        this.paginationHelper();
    }
    lastPage() {
        this.pageNumber = this.totalPages;
        this.paginationHelper();
    }
    // JS function to handel pagination logic
    paginationHelper() {
        this.allOrders = [];
        //this.collectAllOrders = [];
        // calculate total pages
        this.totalPages = Math.ceil(this.totalRecords / this.pageSize);
        // set page number
        if (this.pageNumber <= 1) {
            this.pageNumber = 1;
        } else if (this.pageNumber >= this.totalPages) {
            this.pageNumber = this.totalPages;
        }
        // set records to display on current page
        for (let i = (this.pageNumber - 1) * this.pageSize; i < this.pageNumber * this.pageSize; i++) {
            if (i === this.totalRecords) {
                break;
            }
            this.allOrders.push(this.records[i]);
        }
    }

    closeModal() {
        this.orderDetailsModal = false;
        //this.abandonedOrderDetailsModal = false;
        this.infoModal = false;
        this.selectedOrderIndex = '';
    }

    getVerificationDetails(event) {
        
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

        this.selectedOrderIndex = parseInt(event.target.dataset.index);
        //let row = this.allOrders[this.selectedOrderIndex].Id;
        this.sendorderid = this.allOrders[this.selectedOrderIndex].Id;
        console.log('selected order Id', this.sendorderid);
        this.orderDetailsModal = true;
    }


    handleKeywordChange(event) {
        const searchKey = event.target.value.toLowerCase();
        this.collectAllOrders = this.allOrders;

        if (searchKey) {
            let searchRecords = [];

            for (let record of this.records) {
                let valuesArray = Object.values(record);
                let found = false;

                // Search in the main record
                for (let val of valuesArray) {
                    let strVal = String(val);
                    if (strVal.toLowerCase().includes(searchKey)) {
                        found = true;
                        break;
                    }
                }

                // If not found in the main record, search in the related Account__r object
                if (!found && record.Account__r) {
                    let accountValues = Object.values(record.Account__r);
                    for (let val of accountValues) {
                        let strVal = String(val);
                        if (strVal.toLowerCase().includes(searchKey)) {
                            found = true;
                            break;
                        }
                    }
                }

                if (found) {
                    searchRecords.push(record);
                }
            }

            this.allOrders = searchRecords;
        } else {
            this.pageSize = this.pageSize;
            this.paginationHelper();
        }
    }

    viewInfoModal() {
        this.infoModal = true;
    }

    goToAccount(event) {
        this.selectedOrderIndex = '';
        this.selectedOrderIndex = parseInt(event.target.dataset.index);
        let row = this.allOrders[this.selectedOrderIndex];
        this.orderUrl = window.location.origin + '/' + row.Account__r.Id;
        window.open(this.orderUrl, "_blank");

    }

}