import { LightningElement, track, wire, api} from 'lwc';
import getCurrentParticipantsPicks from '@salesforce/apex/PickManager.getCurrentParticipantsPicks';
import deletePickHandler from '@salesforce/apex/PickManager.deletePickHandler';
import insertPickData from '@salesforce/apex/PickManager.savePickData';
import getTeams from '@salesforce/apex/PickManager.getTeams';
import getBowlGames from '@salesforce/apex/PickManager.getBowlGames';
import getBowlGameName from '@salesforce/apex/PickManager.getBowlGameName';
import validatePasscode from '@salesforce/apex/PickManager.validatePasscode';
import getCurrentParticipantId from '@salesforce/apex/PickManager.getCurrentParticipantId';
import getCurrentParticipantFirstName from '@salesforce/apex/PickManager.getCurrentParticipantFirstName';
import getActiveYearId from '@salesforce/apex/PickManager.getActiveYearId';
import getAvailablePointValues from '@salesforce/apex/PickManager.getAvailablePointValues';
import getAvailableBowlGames from '@salesforce/apex/PickManager.getAvailableBowlGames';

export default class MultiRecordCreation extends LightningElement {
    @track pickDataWrp;
    @track blankRow = [];
    @track disabledCheckbox = true;
    @track validPasscode = false;
    @track index = 0;
    @track selectedParticipant;
    @track participantId;
    @track participantFirstName;
    @track welcomeMessage;
    @track currentYearId;
    @track teamOptions;
    @track gameOptions;
    @track pointOptions;

    @wire(getActiveYearId)
    wiredYear({error,data}){
        if(data){
            this.currentYearId = data;
            if(this.currentYearId !== undefined){
                this.pickDataWrp = [];
            } else{
                this.blankRow = []; 
                this.index = 0;
                this.pickDataWrp = [];
            }
        }else if(error){
            window.alert(JSON.stringify(error));
        }
    }

    // @wire(getTeams, {yrId: '$currentYearId'})
    // wiredTeams({error, data}) {
    //     if(data){
    //         let options = [];
    //         console.log('teams: ' + data);

    //         for (var key in data) {
    //             options.push({ label: data[key], value: data[key] });
    //         }
    //         this.teamOptions = options;
    //     }else if(error){
    //         window.alert(JSON.stringify(error));
    //     }
    // }

    // @wire(getBowlGames, {yrId: '$currentYearId'})
    // wiredGames({error, data}) {
    //     if(data){
    //         let options = [];
    //         console.log('Bowl Games: ' + data);

    //         for (var key in data) {
    //             options.push({ label: data[key].Name, value: data[key].Id });
    //         }
    //         this.gameOptions = options;
    //         console.log('gameOptions: ' + this.gameOptions);
    //     }else if(error){
    //         window.alert(JSON.stringify(error));
    //     }
    // }

    handlePasscodeChange(event){
        let passcodeInput = event.target.value;
        validatePasscode({passcode: event.target.value}).then(result => {
            console.log('valid passcode entered?: ' + result);
            this.validPasscode = result;
            if(this.validPasscode === true){
                this.addRow();
                console.log('passcode passed to get user: ' + passcodeInput);
                getCurrentParticipantId({passcode: passcodeInput}).then(result => {
                    console.log('participant Id: ' + result);
                    this.participantId = result;
                    getCurrentParticipantFirstName({participantId: this.participantId}).then(result => {
                        console.log('participant first name: ' + result);
                        this.participantFirstName = result;
                        this.setWelcomeMessage(this.participantFirstName);
                        }).catch(error => {
                            window.alert(JSON.stringify(error));
                        })
                    getAvailablePointValues({yrId: this.currentYearId, participantId: this.participantId}).then(result => {
                        console.log('point values returned: ' + result);
                        if(result){
                            let options = [];            
                            for (var i=0 ; i<result.length ; i++) {
                                options.push({ label: result[i], value: result[i] });
                            }
                            this.pointOptions = options;
                        } else if(error){
                            window.alert(JSON.stringify(error));
                        }
                    }).catch(error => {
                        window.alert(JSON.stringify(error));
                    })
                    getAvailableBowlGames({yrId: this.currentYearId, participantId: this.participantId}).then(result => {
                        console.log('bowl games returned: ' + result);
                        if(result){
                            let options = [];            
                            for (var i=0 ; i<result.length ; i++) {
                                options.push({ label: result[i].Name, value: result[i].Id });
                            }
                            this.gameOptions = options;
                        } else if(error){
                            window.alert(JSON.stringify(error));
                        }
                    }).catch(error => {
                        window.alert(JSON.stringify(error));
                    })
                    getCurrentParticipantsPicks({yrId : this.currentYearId, participantId : this.participantId}).then(result => {
                        this.pickDataWrp = result;
                        this.index = result.length;
                    }).catch(error => {
                        console.log(error);
                    })
                }).catch(error => {
                    window.alert(JSON.stringify(error));
                })
                console.log('current year id: ' + this.currentYearId);
            }
        }).catch(error => {
            window.alert(JSON.stringify(error));
        })
    }

    deleteRecord(event){
        const selectedPick = this.pickDataWrp[event.target.value];
        //window.alert(JSON.stringify(this.pickDataWrp) + ' & ' + event.target.value + ' & ' + JSON.stringify(selectedPick));
        deletePickHandler({pickId: selectedPick.Id, yrId: selectedPick.Year__c}).then(result => {
            this.pickDataWrp = result;
        }).catch(error => {
            window.alert(JSON.stringify(error));
        })
    }

    addRow(event){
        this.index++;
        let i = this.index;
        let newPick = new Object();
        let blankRow = this.blankRow;
        newPick.Id = i;
        newPick.isChecked = false;
        blankRow.push(newPick);
        this.blankRow = blankRow; 
    }

    setWelcomeMessage(firstName){
        this.welcomeMessage = 'Hey ' + firstName + '! Place your picks below.'
    }

    // addFirstRow(){
    //     this.index++;
    //     let i = this.index;
    //     let newPick = new Object();
    //     let blankRow = this.blankRow;
    //     newPick.Id = i;
    //     newPick.isChecked = false;
    //     blankRow.push(newPick);
    //     this.blankRow = blankRow; 
    // }

    removeRow(event){
        const eventName = event.target.name;
        let blankRow = this.blankRow;
        if(eventName === 'multipleRowRemoval'){
            for(let i = 0; i < blankRow.length; i++){
                if(blankRow[i].isChecked){
                    blankRow.splice(i, 1);
                    i--;
                }
            }
        }else{
            blankRow.splice(event.target.value, 1);
        }
        this.blankRow = blankRow;
    }

    setWinner(event){
        const eventName = event.target.name;
        let blankRow = this.blankRow;
        blankRow[eventName].WinnerId = event.target.value;
        this.blankRow = blankRow;
    }

    setGame(event){
        const eventName = event.target.name;
        console.log('bowlGameId: ' + event.target.value);
        let blankRow = this.blankRow;
        blankRow[eventName].GameId = event.target.value;
        getBowlGameName({bowlGameId: event.target.value}).then(result => {
            console.log('result: ' + result);
            blankRow[eventName].GameName = result;
        }).catch(error => {
            window.alert(JSON.stringify(error));
        })
        this.blankRow = blankRow;
        getTeams({yrId: this.currentYearId, gameId: event.target.value}).then(result => {
            if(result){
                let options = [];
                console.log('Teams playing in the ' + blankRow[eventName].GameName + ' bowl game: ' + result);
    
                for (var i=0 ; i<result.length ; i++) {
                    options.push({ label: result[i], value: result[i] });
                }
                this.teamOptions = options;
            } else if(error){
                window.alert(JSON.stringify(error));
            }
        }).catch(error => {
            window.alert(JSON.stringify(error));
        })
    }

    setAssignedPoints(event){
        const eventName = event.target.name;
        let blankRow = this.blankRow;
        blankRow[eventName].AssignedPoints = event.target.value;
        this.blankRow = blankRow;
    }

    saveData(event){
        let blankRow = this.blankRow;
        let pickDataList = [];
        for(let i = 0; i < blankRow.length; i++){
            if(blankRow[i] !== undefined){
                let pickData = new Object();
                pickData.Year__c = this.currentYearId;
                pickData.Participant__c = this.participantId;
                pickData.Bowl_Game__c = blankRow[i].GameId;
                pickData.Bowl_Game_Name__c = blankRow[i].GameName;
                pickData.Winner__c = blankRow[i].WinnerId;
                pickData.Assigned_Points__c = blankRow[i].AssignedPoints;
                pickDataList.push(pickData);
            }
        }
        if(pickDataList.length > 0){
            insertPickData({pickDataString: JSON.stringify(pickDataList)}).then(result => {
                let newPickList = this.pickDataWrp;
                for(let i = 0; i < result.length; i++){
                    if(result[i] !== undefined){
                        let pickRecord = {'sobjectType' : 'Pick__c'};
                        pickRecord.Id = result[i].Id;
                        pickRecord.Winner__c = result[i].Winner__c;
                        pickRecord.Assigned_Points__c = result[i].Assigned_Points__c;
                        pickRecord.Bowl_Game__c = result[i].Bowl_Game__c;
                        pickRecord.Bowl_Game_Name__c = result[i].Bowl_Game_Name__c;
                        pickRecord.Year__c = this.currentYearId;
                        pickRecord.Participant__c = this.participantId;
                        newPickList.push(pickRecord);
                    }
                }
                console.log('pickDataWrap: ' + this.pickDataWrap);
                this.pickDataWrp = newPickList;
                this.blankRow = []; 
                this.index = newPickList.length;
                getAvailablePointValues({yrId: this.currentYearId, participantId: this.participantId}).then(result => {
                    console.log('point values returned: ' + result);
                    if(result){
                        let options = [];            
                        for (var i=0 ; i<result.length ; i++) {
                            options.push({ label: result[i], value: result[i] });
                        }
                        this.pointOptions = options;
                    } else if(error){
                        window.alert(JSON.stringify(error));
                    }
                }).catch(error => {
                    window.alert(JSON.stringify(error));
                })
                getAvailableBowlGames({yrId: this.currentYearId, participantId: this.participantId}).then(result => {
                    console.log('bowl games returned: ' + result);
                    if(result){
                        let options = [];            
                        for (var i=0 ; i<result.length ; i++) {
                            options.push({ label: result[i].Name, value: result[i].Id });
                        }
                        this.gameOptions = options;
                    } else if(error){
                        window.alert(JSON.stringify(error));
                    }
                }).catch(error => {
                    window.alert(JSON.stringify(error));
                })
                //ADD LOGIC HERE TO REMOVE THE SELECTED BOWL GAME FROM THE LIST OF GAMES
            }).catch(error => {
                window.alert('Please contact system admin: ' + JSON.stringify(error));
            })
        }else{
            window.alert('Please select any row to insert data.');
        }
    }

    setCheckBox(event){
        let blankrow = this.blankRow;
        if(blankrow[event.target.name].isChecked){
            blankrow[event.target.name].isChecked = false;
        }else{
            blankrow[event.target.name].isChecked = true;
        }
        this.blankRow = blankrow;
    }
}