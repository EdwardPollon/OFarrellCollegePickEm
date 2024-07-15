import { LightningElement,api } from 'lwc';
import importBowlGames from '@salesforce/apex/CollegeFootballCallout.importBowlGames';
import updateBowlGames from '@salesforce/apex/CollegeFootballCallout.updateBowlGames';

export default class ImportBowlGames extends LightningElement {
    @api
    recordId;
    importDisabled = false;

    importBowlGames() {
        importBowlGames({yearId: this.recordId});
        this.importDisabled = true;
    }

    updateBowlGames() {
        
    }
}