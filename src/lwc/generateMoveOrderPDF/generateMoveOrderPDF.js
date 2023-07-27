/**
 CREATED BY: Eugene Lanets on 04/10/2023.
 AT REQUEST OF: FHP_Partial
 DESCRIPTION:
 */
import {LightningElement, wire, api, track} from 'lwc';
import getPreview from '@salesforce/apex/el_MoveOrderPDF.previewPDF';
import save from '@salesforce/apex/el_MoveOrderPDF.savePDF';
import deletePreviewRecord from '@salesforce/apex/el_MoveOrderPDF.deletePreview';
import getRecord from '@salesforce/apex/el_MoveOrderPDF.getRecord';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import {loadStyle} from "lightning/platformResourceLoader";
import modal from '@salesforce/resourceUrl/cssStyle';
import { CloseActionScreenEvent } from 'lightning/actions';
import { CurrentPageReference } from 'lightning/navigation';

export default class GenerateMoveOrderPdf extends LightningElement {
    @api recordId;
    @api displayOnPage;

    connectedCallback() {
        console.log('===============');
        console.log(this.displayOnPage);
        console.log(Date.now());
        console.log(this.template.querySelector('.header'));
        Promise.all([
            loadStyle(this, modal)
        ])
    }

    renderedCallback() {
        if(this.displayOnPage) {
            this.template.querySelector('.header[c-generateMoveOrderPDF_generateMoveOrderPDF]').style = "position: unset !important;";
        }
    }


    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        console.log('this.');
        console.log(currentPageReference);
        if (currentPageReference  && this.displayOnPage) {
            this.recordId = currentPageReference.attributes.recordId;
            console.log(this.recordId);
        }
    }

    @track url = '';
    closeQuickAction() {
        if(this.previewId){
            this.deletePreview();
        }
        this.dispatchEvent(new CloseActionScreenEvent());
    }
    previewPDF = false;

    previewId;
    generateLink() {
        getPreview({recordId: this.recordId})
            .then(result => {
                console.log(result);
                this.url = `/servlet/servlet.FileDownload?file=${result}`;
                this.previewId = result;
                setTimeout(()=>{
                    this.previewPDF = true;
                }, 2000)

            })
            .catch(error=>{
                this.notification('Error', error.body ? error.body.message: error.message, 'Error');
            })
    }

    @wire(getRecord, { recordId: '$recordId'})
    wiredRecord({ error, data }) {
        console.log('this.recordId');
        console.log(this.recordId);
        if (data) {
            this.generateLink();
        } else if (error) {
            console.log(error);
            this.notification('Error', error.body ? error.body.message: error.message, 'Error');
        }
    }



    saveFile(){
        save({recordId : this.recordId})
            .then( fileName =>{
                this.notification('Success', `File "${fileName}" saved successfully!`, 'Success');
                this.closeQuickAction();
            })
            .catch(error=>{
                this.notification('Error', error.body ? error.body.message: error.message, 'Error');
            })
    }

    deletePreview(){
        deletePreviewRecord({previewId : this.previewId})
            .then(() =>{
                console.log('Preview Deleted!');
            })
            .catch(error=>{
                this.notification('Error', error.body ? error.body.message: error.message, 'Error');
            })
    }



    notification(title, msg, variant){
        const evt = new ShowToastEvent({
            title: title,
            message: msg,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }

}