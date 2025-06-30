package com.willdom.games.bomberman.statemachine
{
    import com.gq.moveobject.Person;
    import com.gq.system.DiseaseTimer;
    import com.gq.system.GameData;
    import com.gq.system.GameSys;
    import com.gq.system.SoundClass;
    import com.greensock.TweenMax;
    import com.greensock.easing.Linear;
    import com.smartfoxserver.v2.entities.data.ISFSArray;
    import com.smartfoxserver.v2.entities.data.SFSObject;
    import com.smartfoxserver.v2.entities.variables.RoomVariable;
    import com.willdom.games.bomberman.communication.SmartFoxClientSingleton;
    import com.willdom.games.bomberman.consts.ServerMessages;
    import com.willdom.games.bomberman.gameobjects.GameInterfaceManager;
    import com.willdom.games.bomberman.gameobjects.GameObjectsContainer;
    import com.willdom.games.bomberman.gameobjects.PersonScore;
    import com.willdom.games.explodersmmo.shared.consts.GameRoomVars;
    import com.willdom.games.explodersmmo.shared.helpers.StringHelper;
    
    public class EndRoundStatus extends BasicStatusWithEventHandling
    {
        private static const ROUND_RESULTS_TIME:int = 5;
        
        private var currentClockTween:TweenMax;
        private var currentNeedleTween:TweenMax;
        private var gameObjectsContainer:GameObjectsContainer;
        public var endRoundScreen:EndRoundScreenMC;
        
        public function EndRoundStatus(gameObjectsContainer:GameObjectsContainer)
        {
            this.gameObjectsContainer = gameObjectsContainer;
            
            endRoundScreen = new EndRoundScreenMC();
            endRoundScreen.x = -30;
            endRoundScreen.y = 130;
            endRoundScreen.visible = false;
            
            gameObjectsContainer.infoScreen.addChildAt(endRoundScreen, gameObjectsContainer.infoScreen.getChildIndex(gameObjectsContainer.infoScreen.spectateBox)-1);
        }
        
        override public function init(params:SFSObject):void
        {
            var i:int;

            registerFunction(ServerMessages.END_ROUND_TIMER_TICK, onEndRoundTimerTick);
            endRoundScreen.gotoAndStop("endround");
            gameObjectsContainer.resultsScreenContainer.currentResultsScreen = endRoundScreen;
            
            GameData.instance.diseaseManager.removeAllDiseases();
            GameData.instance.positionManager.destroyTreasures();
            if (!SmartFoxClientSingleton.getInstance().smartFoxClient.myself.isSpectatorInRoom(SmartFoxClientSingleton.getInstance().smartFoxClient.gameRoom) &&
                !Person.getPersonByName(GameData.instance.myName).fire)
                GameData.instance.diseaseManager.removeAllDiseases();
            
            var sfsArray:ISFSArray = params.getSFSArray(ServerMessages.PLAYERS_INFO_PARAM);
            
            if(sfsArray!=null)
            {
                var personScore:PersonScore;
                for(i=0;i<sfsArray.size();i++)
                {
                    personScore = PersonScore.getPersonScoreByName( sfsArray.getSFSObject(i).getUtfString(ServerMessages.PLAYER_NAME) );
                    if(personScore!=null)
                    {
                        GameSys.setRoundAndTotalScore(sfsArray.getSFSObject(i), personScore);
                    }
                }
                
                sfsArray = params.getSFSArray(ServerMessages.PLAYERS_SKILLPOINTS_INFO_PARAM);
                
                var roomVar:RoomVariable = SmartFoxClientSingleton.getInstance().smartFoxClient.gameRoom.getVariable( GameRoomVars.FRIENDLY_ROOM );
                
                if(roomVar!=null && !roomVar.getBoolValue())
                {
                    if( sfsArray != null )
                    {
                        if(sfsArray.size() == 0)
                        {
                            GameSys.skillpointsInfoAvailable = false;
                        }
                        else
                        {
                            GameSys.skillpointsInfoAvailable = true;
                        }
                        for(i=0;i<sfsArray.size();i++)
                        {
                            personScore = PersonScore.getPersonScoreByName( sfsArray.getSFSObject(i).getUtfString(ServerMessages.PLAYER_NAME) );
                            if(personScore!=null){
                                personScore.currentSkillPoints = sfsArray.getSFSObject(i).getLong(ServerMessages.POINTS_PARAM);
                                personScore.ranking = sfsArray.getSFSObject(i).getLong(ServerMessages.RANKING_PARAM);
                                personScore.difference = sfsArray.getSFSObject(i).getLong(ServerMessages.DIFFERENCE_PARAM);
                            }
                        }
                    }
                }
            }
            GameData.instance.gameBox.visible = false;
            GameSys.forceRemoveArray();
            
            if(GameData.instance.gameObjectsContainer.endRoundResultsScreen != null)
            {
                GameData.instance.gameObjectsContainer.endRoundResultsScreen.showRoundResults();
            }
            endRound();
        }
        
        private function onEndRoundTimerTick(params:SFSObject):void
        {
            onEndRoundTick(params.getInt("counter"));
        }
        
        
        private function onEndRoundTick(tick:int):void
        {
            GameData.instance.gameObjectsContainer.endRoundResultsScreen.updateTimer(ROUND_RESULTS_TIME - tick);
        }
        
        public function endRound():void 
        {
            if(!SmartFoxClientSingleton.getInstance().smartFoxClient.myself.isSpectatorInRoom(SmartFoxClientSingleton.getInstance().smartFoxClient.gameRoom) && 
                !Person.getPersonByName(GameData.instance.myName).fire && 
                GameData.instance.diseaseManager.getDiseasesByPerson(Person.getPersonByName(GameData.instance.myName)).length > 0){
            }
            Person.stopLatencyCheck();
            GameData.instance.roundOver = true;
            gameObjectsContainer.infoScreen.bombTimer.timerMessage.text = LanguageManager.getInstance().getAndReplaceText("_roundNumber","%num%",""+ GameData.instance.currentRound).replace("%total%",GameData.instance.round);
            missionComplete();
        }
        
        public function missionComplete():void
        {
            if(GameData.instance.controls != null)
            {
                GameData.instance.controls.deactivateListeners();
            }
            
            var count:int = 0;
            for each(var person:Person in GameData.instance.playerArr)
            {
                if(!person.fire)
                {
                    
                    person.showDir("stand");
                    person.score.totalTrophies++;
                    person.score.currentTrophies++;
                    person.trophieList[GameData.instance.currentRound] = "filled";
                }else{
                    person.can_action = false;
                    person.trophieList[GameData.instance.currentRound] = "empty";
                }                
            }
            GameData.instance.positionManager.pause();
            GameSys.paused = true;
            GameData.instance.currentLocalTick = 0;
            GameData.instance.currentTick = 0;
            GameData.instance.onSuddenDeath = false;
            
            GameInterfaceManager.getInstance().deleteFlaggedSubmessages();
            
            gameObjectsContainer.infoScreen.bombTimer.timeTxt.text = StringHelper.timeToClock((GameData.instance.time));
            DiseaseTimer.dispose();
            
            if(GameData.instance.currentRound < GameData.instance.round && GameData.instance.playerNames.length > 1){
                showRoundResults();
            }
        }
        
        private function showRoundResults():void
        {
            if(GameData.instance.alreadyWinLose) return;
            
            SoundClass.addMusic( "music", "roundresults", 999 );
            GameData.instance.scoreTimer = GameData.SCORE_SHOW_TIMER;
            var i:int = 0;
            if(GameData.instance.trophies)
            {
                fillRoundDataTrophies();
            }
            else
            {    
                fillRoundDataScore();
            }
        }
        
        private function fillRoundDataScore():void
        {    
            //SHOW END RESULT
            gameObjectsContainer.resultsScreenContainer.showResultsScreen();
            
            var roundArray:Array = new Array();
            var totalArray:Array = new Array();
            var playersArrays:Array = new Array();
            var i:int = 0;
            
            roundArray = (GameData.instance.scores as Array).concat().sortOn('currentRoundScore', Array.DESCENDING | Array.NUMERIC);
            totalArray = (GameData.instance.scores as Array).concat().sortOn('totalScorePoints', Array.DESCENDING | Array.NUMERIC);
            
            var count:int = 9999;
            var index:int = 0;
            
            for (var j:int = 0; j < roundArray.length; j++) 
            {
                if(count == roundArray[j].currentRoundScore)
                {
                    playersArrays[index-1].push(roundArray[j]);
                }
                else
                {
                    count = roundArray[j].currentRoundScore;
                    playersArrays.push(new Array());
                    index++;
                    playersArrays[index-1].push(roundArray[j]);
                }
            }
            count = 9999;
            index = 0;
            for (var m:int = 0; m < totalArray.length; m++)
            {
                if(count == totalArray[m].totalScorePoints)
                {
                    totalArray[m].ranking = index;
                }
                else
                {
                    count = totalArray[m].totalScorePoints;
                    index++;
                    totalArray[m].ranking = index;
                }
            }
            
            if(GameData.instance.gameObjectsContainer.endRoundResultsScreen != null)
            {
                GameData.instance.gameObjectsContainer.endRoundResultsScreen.fillTableData(playersArrays);
            }
            
            for (var k:int = 0; k < playersArrays.length; k++) 
            {
                playersArrays[k].sortOn('name', Array.DESCENDING);
            }
            
            index = 0;
            
            for (i = 0; i < playersArrays.length; i++) 
            {
                for (var i2:int = 0; i2 < playersArrays[i].length; i2++) 
                {
                    var personScore:PersonScore = playersArrays[i][i2] as PersonScore;
                    
                    if((playersArrays[i][i2] as PersonScore).name == GameData.instance.myName)
                    {
                        endRoundScreen["yellowRow" + (index+1)].visible = true;
                        endRoundScreen.partialResultsComponent["player" + (index+1)].scoreBox.gotoAndStop("gold");
                        endRoundScreen.partialResultsComponent["player" + (index+1)].totalScoreBox.gotoAndStop("gold");
                        endRoundScreen.partialResultsComponent["player" + (index+1)].killsBox.gotoAndStop("gold");
                        endRoundScreen.partialResultsComponent["player" + (index+1)].playerNameComponent.gotoAndStop("gold");
                    }
                    else
                    {
                        endRoundScreen["yellowRow" + (index+1)].visible = false;
                        endRoundScreen.partialResultsComponent["player" + (index+1)].playerNameComponent.gotoAndStop("blue");
                    }
                    
                    var croppedName:String = (playersArrays[i][i2] as PersonScore).name.substr(0,12);
                    
                    endRoundScreen.partialResultsComponent["player" + (index+1)].playerNameComponent.playerNameTxt.text = (playersArrays[i][i2] as PersonScore).name;
                    endRoundScreen.partialResultsComponent["player" + (index+1)].avatar.gotoAndStop("avatar"+(playersArrays[i][i2] as PersonScore).avatar);
                    endRoundScreen.partialResultsComponent["player" + (index+1)].scoreBox.textField.text =  (playersArrays[i][i2] as PersonScore).currentRoundScore;
                    endRoundScreen.partialResultsComponent["player" + (index+1)].totalScoreBox.textField.text =  (playersArrays[i][i2] as PersonScore).totalScorePoints;
                    endRoundScreen.partialResultsComponent["player" + (index+1)].killsBox.textField.text = (playersArrays[i][i2] as PersonScore).roundKills;
                    
                    if((playersArrays[i][i2] as PersonScore).deathPosition==Person.allPersons.length)
                    {
                        gameObjectsContainer.resultsScreenContainer.fillScoreDialog(endRoundScreen.partialResultsComponent["player" + (index+1)].dialogBox,(playersArrays[i][i2] as PersonScore).currentScore,false);                
                    }
                    else
                    {
                        gameObjectsContainer.resultsScreenContainer.fillScoreDialog(endRoundScreen.partialResultsComponent["player" + (index+1)].dialogBox,(playersArrays[i][i2] as PersonScore).currentScore,false,(playersArrays[i][i2] as PersonScore).deathPosition);
                    }
                    index++;
                    
                    GameSys.updatePanels();
                }
                
                try
                {
                    GameData.instance.gameObjectsContainer.endRoundResultsScreen.showRows();
                }
                catch(e:Error)
                {
                
                }
            }
        }
        
        private function fillRoundDataTrophies():void
        {
            gameObjectsContainer.resultsScreenContainer.showResultsScreen(false,true);
            
            var roundArray:Array = new Array();
            var totalArray:Array = new Array();
            var playersArrays:Array = new Array();
            var i:int = 0;
            
            roundArray = (GameData.instance.scores as Array).concat().sortOn('currentTrophies', Array.DESCENDING | Array.NUMERIC);
            totalArray = (GameData.instance.scores as Array).concat().sortOn('totalScorePoints', Array.DESCENDING | Array.NUMERIC);
            
            var count:int = 9999;
            var index:int = 0;
            
            for (var j:int = 0; j < roundArray.length; j++) 
            {
                if(count == roundArray[j].currentTrophies)
                {
                    playersArrays[index-1].push(roundArray[j]);
                }
                else
                {
                    count = roundArray[j].currentTrophies;
                    playersArrays.push(new Array());
                    index++;
                    playersArrays[index-1].push(roundArray[j]);
                }
            }
            count = 9999;
            index = 0;
            
            for (var m:int = 0; m < totalArray.length; m++)
            {
                
                if(count == totalArray[m].totalTrophies)
                {
                    totalArray[m].ranking = index;
                }
                else
                {
                    count = totalArray[m].totalTrophies;
                    index++;
                    totalArray[m].ranking = index;
                }
            }
            
            for (var k:int = 0; k < playersArrays.length; k++) 
            {
                playersArrays[k].sortOn('name', Array.DESCENDING);
            }
            
            index = 0;
            var playerListOrder:Array = new Array();
            
            for (i = 0; i < playersArrays.length; i++) 
            {
                for (var i2:int = 0; i2 < playersArrays[i].length; i2++) 
                {
                    endRoundScreen.partialResultsComponent["player" + (index+1)].gotoAndStop("endround_trophies");
                    
                    if(playersArrays[i][i2].name == GameData.instance.myName)
                    {
                        endRoundScreen["yellowRow" + (index+1)].visible = true;
                        endRoundScreen.partialResultsComponent["player" + (index+1)].playerNameComponent.gotoAndStop("gold");
                    }
                    else
                    {
                        endRoundScreen["yellowRow" + (index+1)].visible = false;
                        endRoundScreen.partialResultsComponent["player" + (index+1)].playerNameComponent.gotoAndStop("blue");
                    }
                    var croppedName:String = playersArrays[i][i2].name.substr(0,12);
                    endRoundScreen.partialResultsComponent["player" + (index+1)].playerNameComponent.playerNameTxt.text = croppedName;
                    endRoundScreen.partialResultsComponent["player" + (index+1)].avatar.gotoAndStop("avatar"+(playersArrays[i][i2] as PersonScore).avatar);
                    endRoundScreen.partialResultsComponent["player" + (index+1)].killsText.text = (playersArrays[i][i2] as PersonScore).roundKills;
                    
                    for (var t:uint = 1; t <= (playersArrays[i][i2] as PersonScore).totalTrophies; t++)
                    {
                        endRoundScreen.partialResultsComponent["player" + (index+1)].trophies["trophySpot_" + t].gotoAndStop("trophy");
                    }
                    
                    index++;
                    GameSys.updatePanels();
                }
            }
        }
        
        override public function dispose(params:SFSObject):void
        {
            endRoundScreen.visible = false;
            GameSys.updatePanels(true);
            
            if(GameData.instance.gameObjectsContainer.endRoundResultsScreen != null)
            {
                GameData.instance.gameObjectsContainer.endRoundResultsScreen.hideRoundResults();
            }
        }
    }
}