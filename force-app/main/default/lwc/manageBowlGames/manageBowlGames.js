import { LightningElement, api, wire } from 'lwc';
import importBowlGames from '@salesforce/apex/CollegeFootballCallout.importBowlGames';
import updateBowlGames from '@salesforce/apex/CollegeFootballCallout.updateBowlGames';
import deleteBowlGames from '@salesforce/apex/BowlGameUtil.deleteBowlGames';
import {getRecord, getFieldValue } from 'lightning/uiRecordApi';
import BOWL_GAMES_IMPORTED_FIELD from '@salesforce/schema/Year__c.Bowl_Games_Imported__c';

export default class ImportBowlGames extends LightningElement {
    @api
    recordId;
    canDeleteBowlGames;
    @wire(getRecord, { 
        recordId: '$recordId', 
        fields: [BOWL_GAMES_IMPORTED_FIELD] 
    })
    year;

    get bowlGamesImported() {
        return getFieldValue(this.year.data, BOWL_GAMES_IMPORTED_FIELD);
    }

    get cantDeleteBowlGames() {
        return getFieldValue(this.year.data, BOWL_GAMES_IMPORTED_FIELD) ? false : true;
    }

    importBowlGames() {
        importBowlGames({yearId: this.recordId});
        window.location.reload();
    }

    updateBowlGames() {
        updateBowlGames({yearId: this.recordId});
        window.location.reload();
    }
    
    importBowlGames() {
        importBowlGames({yearId: this.recordId});
        window.location.reload();
    }

    deleteBowlGames(){
        deleteBowlGames({yearId: this.recordId});
        window.location.reload();
    }
}