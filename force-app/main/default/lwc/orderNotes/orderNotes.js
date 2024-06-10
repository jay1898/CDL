import { LightningElement, api, track } from 'lwc';
import getOrderNotes from '@salesforce/apex/CDL_OrderNotes.getOrderNotes';
import addNotes from '@salesforce/apex/CDL_OrderNotes.addNotes';
import attachmentsList from '@salesforce/apex/CDL_OrderNotes.AttachmentList';
export default class OrderNotes extends LightningElement {
    @api recordId;
    @track existingNotes = '';
    @track formattedNotes = '';
    @track allNotes = [];
    @track inputNotes = '';
    @track value;
    @track spinner = false;
    @track allAttachmentsList = [];
    connectedCallback() {
        this.getAllNotes();
        this.getAllattachments()
    }

    getAllNotes(){
        getOrderNotes({ recordId: this.recordId })
            .then((response) => {
                this.existingNotes = JSON.parse(JSON.stringify(response));
                console.log('Returned response:', this.existingNotes);
                
                // Define a regular expression pattern to capture the data
                const regex = /Comments: ([^]*?)\nUser: (.*?) Time: (.*?)\n\n?/g;

                // Use the matchAll method to find all matches
                const matches = [...this.existingNotes.matchAll(regex)];

                // Process each match and extract the information
                for (const match of matches) {
                    const [, note, userName, dateTime] = match;
                    this.allNotes.push({ note, userName, dateTime });
                }

                console.log('this.allNotes:;', this.allNotes);
            })
            .catch((error) => {
                console.log('Error:', error);
            });
    }

    inputNotess(event)
    {
        this.inputNotes = event.target.value;
    }

    sendNotes()
    {
        const isAllInputsCorrect = [...this.template.querySelectorAll('.noteValid')]
        .reduce((validSoFar, inputField) => {
            inputField.reportValidity();
            if (!inputField.checkValidity()) {
                inputField.focus(); // Set focus on the first invalid input field
            }
            return validSoFar && inputField.checkValidity();
        }, true);
        if (isAllInputsCorrect) {
        console.log('input value',this.inputNotes);
        this.spinner = true;
        addNotes({recordId: this.recordId, addNotes: this.inputNotes})
            .then((response) => {               
                console.log('response', response);
                this.value = '';
                this.allNotes = [];
                this.getAllNotes();
                this.spinner = false;
            })
            .catch((error) => {
                console.log('Error:', error);
                this.spinner = false;
            });
        }
    }

    get sortedNotes() {
        return this.allNotes.sort((a, b) => new Date(b.dateTime) - new Date(a.dateTime));
    }

    getAllattachments() {
        attachmentsList({ OrderId: this.recordId })
            .then((response) => {
                this.allAttachmentsList = JSON.parse(response);
                for(let i=0; i<this.allAttachmentsList.length; i++){
                    this.allAttachmentsList[i].Id = '/servlet/servlet.FileDownload?file='+this.allAttachmentsList[i].Id;
                }
                this.spinner = false;
            })
            .catch((error) => {
                console.log('Error:', error);
                this.spinner = false;
            });
    }
}