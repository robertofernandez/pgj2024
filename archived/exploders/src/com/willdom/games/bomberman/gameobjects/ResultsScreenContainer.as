package com.willdom.games.bomberman.gameobjects
{
    import com.gq.moveobject.Person;
    import com.gq.system.GameData;
    import com.gq.system.GameSys;
    import com.greensock.TweenMax;
    import com.smartfoxserver.v2.entities.data.SFSObject;
    import com.willdom.games.bomberman.communication.SmartFoxClientSingleton;
    import com.willdom.games.bomberman.consts.ServerMessages;
    import com.willdom.games.bomberman.gameobjects.items.JoiningPlayer;
    import com.willdom.games.bomberman.rooms.RoomLocalProperties;
    import com.willdom.games.bomberman.user.UserLocalProperties;
    import com.willdom.games.explodersmmo.shared.consts.GameRoomVars;
    import com.willdom.games.explodersmmo.shared.model.LocalUser;
    //import com.willdom.games.explodersmmo.shared.tracker.HoneyTrackConstants;
    //import com.willdom.games.explodersmmo.shared.tracker.HoneyTracks;
    import com.willdom.util.helpers.EventListenerManager;
    
    import flash.display.DisplayObject;
    import flash.display.MovieClip;
    import flash.events.EventDispatcher;
    import flash.events.MouseEvent;

    public class ResultsScreenContainer
    {
        private var gameObjectsContainer:GameObjectsContainer;
        private var _currentResultsScreen:MovieClip;
        private var honeyTracksEndGameResultDispatched:Boolean;
        
        public function ResultsScreenContainer(gameObjectsContainer:GameObjectsContainer)
        {
            this.gameObjectsContainer = gameObjectsContainer;
            honeyTracksEndGameResultDispatched = false;
            EventListenerManager.setListenerTo(gameObjectsContainer.infoWindow.playBtn, MouseEvent.CLICK, toggleWaitingListStatus, false, 0, true);
        }
        
        public function fillTotalScreenTrophies(lastPlayer:Boolean = false,  leap:uint = 0):void
        {
            if(_currentResultsScreen.totalResultsComponent == null)
            {
                showResultsScreen(true, true);
            }
            
            if (JoiningPlayer.getJoiningPlayers() == null)
            {
                showResultsScreen(true, true);
                JoiningPlayer.startRecord();
            } 
            else 
            {
                for (var z:uint = 0; z < 8; z++)
                {
                    cleanTotalResults(GameData.instance.trophies, z);
                }
            }
            
            var gameArray:Array = new Array();
            var playersArrays:Array = new Array();
            var i:int = 0;
            gameArray = (GameData.instance.scores as Array).concat().sortOn('totalScorePoints', Array.DESCENDING | Array.NUMERIC);
            var count:int = 9999;
            var index:int = 0;
            for (var j:int = leap; j < gameArray.length; j++) 
            {
                if(count == gameArray[j].totalScorePoints)
                {
                    playersArrays[index-1].push(gameArray[j]);
                }
                else
                {
                    count = gameArray[j].totalScorePoints;
                    playersArrays.push(new Array());
                    index++;
                    playersArrays[index-1].push(gameArray[j]);
                }
            }
            
            for (var k:int = 0; k < playersArrays.length; k++) 
            {
                playersArrays[k].sortOn('name', Array.DESCENDING);
            }    
            index = 0;
            
            
            var skillPointsDifference:int;
            for (i = 0; i < playersArrays.length; i++)
            {
                for (var i2:int = 0; i2 < playersArrays[i].length; i2++) 
                {
                    _currentResultsScreen.totalResultsComponent["player" + (index+1)].gotoAndStop("endgame_trophies");
                    if(playersArrays[i][i2].name == GameData.instance.myName)
                    {
                        _currentResultsScreen["yellowRow" + (index+1)].visible = true;
                        _currentResultsScreen.totalResultsComponent["player" + (index+1)].playerNameComponent.gotoAndStop("gold");
                        _currentResultsScreen.totalResultsComponent["player" + (index+1)].prevSPBox.gotoAndStop("gold");
                        _currentResultsScreen.totalResultsComponent["player" + (index+1)].newSPBox.gotoAndStop("gold");
                        _currentResultsScreen.totalResultsComponent["player" + (index+1)].skillpointsUnavailable.gotoAndStop("gold");
                    }
                    else
                    {
                        _currentResultsScreen["yellowRow" + (index+1)].visible = false;
                        _currentResultsScreen.totalResultsComponent["player" + (index+1)].playerNameComponent.gotoAndStop("blue");
                        _currentResultsScreen.totalResultsComponent["player" + (index+1)].skillpointsUnavailable.gotoAndStop("normal");
                    }                        
                    skillPointsDifference = (playersArrays[i][i2] as PersonScore).difference;
                    if(GameSys.skillpointsInfoAvailable)
                    {
                        _currentResultsScreen.totalResultsComponent["player" + (index+1)].skillpointsUnavailable.visible = false;
                    }
                    else
                    {
                        LanguageManager.getInstance().registerTag("_bbmSkillpointsUnavailable", _currentResultsScreen.totalResultsComponent["player" + (index+1)].skillpointsUnavailable.textField, "text");
                    }
                    _currentResultsScreen.totalResultsComponent["player" + (index+1)].prevSPBox.textField.text = "" + ((playersArrays[i][i2] as PersonScore).currentSkillPoints - skillPointsDifference);
                    _currentResultsScreen.totalResultsComponent["player" + (index+1)].differenceTxt.text = "" + skillPointsDifference;
                    _currentResultsScreen.totalResultsComponent["player" + (index+1)].newSPBox.textField.text = "" + ((playersArrays[i][i2] as PersonScore).currentSkillPoints);
                    if (skillPointsDifference >= 0)
                    {
                        _currentResultsScreen.totalResultsComponent["player" + (index+1)].difSPBox.gotoAndStop("green");
                    } 
                    else 
                    {
                        _currentResultsScreen.totalResultsComponent["player" + (index+1)].difSPBox.gotoAndStop("red");
                    }
                    var croppedName:String = playersArrays[i][i2].name.substr(0,12);
                    _currentResultsScreen.totalResultsComponent["player" + (index+1)].playerNameComponent.playerNameTxt.text = croppedName;
                    _currentResultsScreen.totalResultsComponent["player" + (index+1)].avatar.gotoAndStop("avatar"+playersArrays[i][i2].avatar);
                    for (var t:uint = 1; t <= (playersArrays[i][i2] as PersonScore).totalTrophies; t++)
                    {
                        _currentResultsScreen.totalResultsComponent["player" + (index+1)].trophies["trophySpot_" + t].gotoAndStop("trophy");
                    }
                    index++;
                }
            }
            displayUsersInRoom(index);
            updateCurrentResultsScreen();
            updateResultsScrollControls();
        }
        
        private function updateResultsScrollControls():void{
            
            var separator:uint = 0;
            if (JoiningPlayer.getJoiningPlayers().length > 0)
            {
                separator = 1;
            }
            var itemsCount:uint = GameData.instance.scores.length + JoiningPlayer.getJoiningPlayers().length + separator;
            
            if (itemsCount > 8)
            {
                _currentResultsScreen.upScroll.visible = true;
                _currentResultsScreen.upScroll.gotoAndStop("normal");
                _currentResultsScreen.downScroll.visible = true;
                _currentResultsScreen.downScroll.gotoAndStop("normal");    
            } 
            else 
            {
                _currentResultsScreen.upScroll.visible = false;
                _currentResultsScreen.downScroll.visible = false;
            }
            
            if (GameData.instance.resultsScrollCount > 0)
            {
                setResultsScrollButtonMode(_currentResultsScreen.upScroll);
                
            } else {
                removeResultsScrollButtonMode(_currentResultsScreen.upScroll);
            }
            
            if (itemsCount - GameData.instance.resultsScrollCount <= 8){
                removeResultsScrollButtonMode(_currentResultsScreen.downScroll);
            } else {
                setResultsScrollButtonMode(_currentResultsScreen.downScroll);
            }
            
        }
        private function setResultsScrollButtonMode(button:MovieClip):void
        {
            button.gotoAndStop("normal");
            button.buttonMode = true;
            EventListenerManager.setListenerTo(button, MouseEvent.MOUSE_OVER, resultsScrollButtonOver);
            EventListenerManager.setListenerTo(button, MouseEvent.MOUSE_DOWN, resultsScrollButtonDown);
            EventListenerManager.setListenerTo(button, MouseEvent.MOUSE_UP, resultsScrollButtonUp);
            EventListenerManager.setListenerTo(button, MouseEvent.MOUSE_OUT, resultsScrollButtonOut);
        }
        
        private function removeResultsScrollButtonMode(button:MovieClip):void{
            button.gotoAndStop("disabled");
            button.buttonMode = false;
            EventListenerManager.removelistenerFrom(button, MouseEvent.MOUSE_OVER, resultsScrollButtonOver);
            EventListenerManager.removelistenerFrom(button, MouseEvent.MOUSE_DOWN, resultsScrollButtonDown);
            EventListenerManager.removelistenerFrom(button, MouseEvent.MOUSE_UP, resultsScrollButtonUp)
            EventListenerManager.removelistenerFrom(button, MouseEvent.MOUSE_OUT, resultsScrollButtonOut);
        }
        
        private function resultsScrollButtonOver(e:MouseEvent):void{
            (e.currentTarget as MovieClip).gotoAndStop("over");
        }
        
        private function resultsScrollButtonDown(e:MouseEvent):void{
            (e.currentTarget as MovieClip).gotoAndStop("down");
        }
        
        private function resultsScrollButtonOut(e:MouseEvent):void{
            (e.currentTarget as MovieClip).gotoAndStop("normal");
        }
        
        private function resultsScrollButtonUp(e:MouseEvent):void{
            (e.currentTarget as MovieClip).gotoAndStop("over");
            if (e.currentTarget == _currentResultsScreen.downScroll)
            {
                var separator:uint = 0;
                if (JoiningPlayer.getJoiningPlayers().length > 0)
                {
                    separator = 1;
                }
                
                if (GameData.instance.scores.length + JoiningPlayer.getJoiningPlayers().length + separator - GameData.instance.resultsScrollCount >= 8){
                    GameData.instance.resultsScrollCount ++;
                    if (GameData.instance.trophies){
                        fillTotalScreenTrophies(false, GameData.instance.resultsScrollCount);
                    } 
                    else
                    {
                        fillTotalScreenScore(false, GameData.instance.resultsScrollCount);
                    }
                }
            } 
            else if (e.currentTarget == _currentResultsScreen.upScroll)
            {
                if (GameData.instance.resultsScrollCount > 0)
                {
                    GameData.instance.resultsScrollCount --;
                    if (GameData.instance.trophies)
                    {
                        fillTotalScreenTrophies(false, GameData.instance.resultsScrollCount);
                    } 
                    else
                    {
                        fillTotalScreenScore(false, GameData.instance.resultsScrollCount);
                    }
                }
            }
        }
        
        public function toggleWaitingListStatus(e:MouseEvent):void
        {
            if((SmartFoxClientSingleton.getInstance().smartFoxClient.myself.properties as UserLocalProperties).isRegistered || 
                SmartFoxClientSingleton.getInstance().smartFoxClient.gameRoom.getVariable( GameRoomVars.FRIENDLY_ROOM ).getBoolValue())
            {
                if ((SmartFoxClientSingleton.getInstance().smartFoxClient.gameRoom.properties as RoomLocalProperties)
                    .waitingList.indexOf(SmartFoxClientSingleton.getInstance().smartFoxClient.myself) > -1)
                {
                    //SmartFoxClientSingleton.getInstance().smartFoxClient.joinWaitingList(false);
                } 
                else 
                {
                    //SmartFoxClientSingleton.getInstance().smartFoxClient.joinWaitingList(true);
                }
                if(GameData.instance.alreadyWinLose)
                {
                    if (GameData.instance.trophies)
                    {
                        fillTotalScreenTrophies(false, GameData.instance.resultsScrollCount);
                    }
                    else
                    {
                        fillTotalScreenScore(false, GameData.instance.resultsScrollCount);
                    }
                }
            } 
            else 
            {
                gameObjectsContainer.infoScreen.spectateBox.x = 303;
                gameObjectsContainer.infoScreen.spectateBox.y = 305;
                gameObjectsContainer.infoScreen.spectateBox.visible = true;
            }
        }
        
        private function displayUsersInRoom(currentIndex:uint):void
        {
            JoiningPlayer.updateJoiningPlayers();
            var currentScrollState:int = GameData.instance.resultsScrollCount - GameData.instance.scores.length;
            for (var z:uint = 0; z < 8; z++)
            {
                cleanTotalResults(GameData.instance.trophies, z);
                if (GameData.instance.scores.length - 1 < z)
                {
                    _currentResultsScreen.totalResultsComponent["player" + (z+1)].visible = false;
                    _currentResultsScreen["yellowRow" + (z+1)].visible = false;
                }
            }
            var lobbyPlayers:Array = JoiningPlayer.getJoiningPlayers();
            var joining:uint = 0;
            for each (var thisPlayer:JoiningPlayer in lobbyPlayers)
            {
                if (thisPlayer.status)
                {
                    joining++;
                }
            }
            if (currentIndex < 8 && currentScrollState < 1 && JoiningPlayer.getJoiningPlayers().length > 0)
            {
                _currentResultsScreen["yellowRow" + (currentIndex+1)].visible = false;
                _currentResultsScreen.totalResultsComponent["player" + (currentIndex+1)].gotoAndStop("endgame_separator");
                LanguageManager.getInstance().registerTag("_spectatorsList", _currentResultsScreen.totalResultsComponent["player" + (currentIndex+1)].separatorTxt, "text", "%num%", "" + joining);
                _currentResultsScreen.totalResultsComponent["player" + (currentIndex+1)].visible = true;
                currentIndex++;
            }
            var joiningCount:uint = 0;
            if (currentScrollState >= 1)
            {
                joiningCount = currentScrollState;
            }
            var currentJoiningPlayer:JoiningPlayer;
            while (currentIndex < 8 && joiningCount < lobbyPlayers.length)
            {
                currentJoiningPlayer = lobbyPlayers[joiningCount];
                _currentResultsScreen["yellowRow" + (currentIndex+1)].visible = false;
                _currentResultsScreen.totalResultsComponent["player" + (currentIndex+1)].gotoAndStop("endgame_score");
                _currentResultsScreen.totalResultsComponent["player" + (currentIndex+1)].playerNameComponent.gotoAndStop("blue");
                _currentResultsScreen.totalResultsComponent["player" + (currentIndex+1)].playerNameComponent.playerNameTxt.text = currentJoiningPlayer.name;
                _currentResultsScreen.totalResultsComponent["player" + (currentIndex+1)].scoreBox.gotoAndStop("outside");
                _currentResultsScreen.totalResultsComponent["player" + (currentIndex+1)].dot.gotoAndStop("green");
                if (currentJoiningPlayer.status){
                    LanguageManager.getInstance().registerTag("_joining",  _currentResultsScreen.totalResultsComponent["player" + (currentIndex+1)].scoreBox.textField, "text");
                } 
                else 
                {
                    LanguageManager.getInstance().registerTag("_waitingToJoin", _currentResultsScreen.totalResultsComponent["player" + (currentIndex+1)].scoreBox.textField, "text");
                }
                if (SmartFoxClientSingleton.getInstance().smartFoxClient.myself.isSpectatorInRoom(SmartFoxClientSingleton.getInstance().smartFoxClient.gameRoom)){
                    if (GameSys.getRematchCount() + (SmartFoxClientSingleton.getInstance().smartFoxClient.gameRoom.properties as RoomLocalProperties).waitingList.length < 2 && 
                        (SmartFoxClientSingleton.getInstance().smartFoxClient.gameRoom.properties as RoomLocalProperties).waitingList.indexOf(SmartFoxClientSingleton.getInstance().smartFoxClient.myself) > -1)
                    {
                        _currentResultsScreen.insufficientPeople.visible = true;
                    }
                    else
                    {
                        _currentResultsScreen.insufficientPeople.visible = false;
                    }
                }
                
                _currentResultsScreen.totalResultsComponent["player" + (currentIndex+1)].prevSPBox.gotoAndStop("normal");
                _currentResultsScreen.totalResultsComponent["player" + (currentIndex+1)].difSPBox.visible = false;
                _currentResultsScreen.totalResultsComponent["player" + (currentIndex+1)].differenceTxt.visible = false;
                _currentResultsScreen.totalResultsComponent["player" + (currentIndex+1)].skillpointsUnavailable.visible = false;
                _currentResultsScreen.totalResultsComponent["player" + (currentIndex+1)].newSPBox.visible = false;
                
                if (currentJoiningPlayer.skillPoints == "Error"){
                    _currentResultsScreen.totalResultsComponent["player" + (currentIndex+1)].prevSPBox.textField.text = "0";
                } 
                else 
                {
                    _currentResultsScreen.totalResultsComponent["player" + (currentIndex+1)].prevSPBox.textField.text = currentJoiningPlayer.skillPoints;
                }
                EventListenerManager.removelistenerFrom(_currentResultsScreen.totalResultsComponent["player" + (currentIndex+1)].scoreBox, MouseEvent.ROLL_OVER, showDialog);
                _currentResultsScreen.totalResultsComponent["player" + (currentIndex+1)].avatar.gotoAndStop("lobby");
                _currentResultsScreen.totalResultsComponent["player" + (currentIndex+1)].visible = true;
                currentIndex++;
                joiningCount++;
            }
        }
        
        /**
         * This function will display the game results in the total scores board. It can be called again whenever an update of this information is needed.
         * The last player argument should be true if you are the last remaining player in the match. If a leap argument is provided, the function will
         * ignore the corresponding number of data items and display only the rest.
         **/
        public function fillTotalScreenScore(lastPlayer:Boolean = false, leap:uint = 0):void
        {
            if(_currentResultsScreen.totalResultsComponent == null)
            {
                showResultsScreen(true);
            }
            
            if (JoiningPlayer.getJoiningPlayers() == null)
            {
                showResultsScreen(true);
                JoiningPlayer.startRecord();
            } 
            else 
            {
                for (var z:uint = 0; z < 8; z++)
                {
                    cleanTotalResults(GameData.instance.trophies, z);
                }
            }
            
            var displayItemsCount:uint = 0;
            var scores:Array = new Array();
            var positions:Array = new Array();
            var i:int = 0;
            var count:int = 9999;
            var index:int = 0;
            var myPosition:int;
            var myPosition2:int;
            scores = (GameData.instance.scores as Array).concat().sortOn('totalScorePoints', Array.DESCENDING | Array.NUMERIC);
            for (var j:int = leap; j < scores.length; j++) 
            {
                if(count == scores[j].totalScorePoints)
                {
                    positions.push(new Array());
                    positions[index].push(scores[j]);
                }
                else
                {
                    count = scores[j].totalScorePoints;
                    positions.push(new Array());
                    positions[index].push(scores[j]);
                }
                index++;
            }
            displayUsersInRoom(index);
            
            GameData.instance.gameObjectsContainer.endMatchResultsScreen.fillTableData(positions);
            
            for (var k:int = 0; k < positions.length; k++) 
            {
                positions[k].sortOn('name', Array.DESCENDING);
            }    
            index = 0;
            for (i = 0; i < positions.length; i++)
            {
                for (var i2:int = 0; i2 < positions[i].length; i2++) 
                {
                    if(_currentResultsScreen.totalResultsComponent["player" + (index+1)].currentFrameLabel != "endgame_separator")
                    {
                        if(positions[i][i2].name == GameData.instance.myName)
                        {
                            _currentResultsScreen["yellowRow" + (index+1)].visible = true;
                            _currentResultsScreen.totalResultsComponent["player" + (index+1)].playerNameComponent.gotoAndStop("gold");
                            _currentResultsScreen.totalResultsComponent["player" + (index+1)].scoreBox.gotoAndStop("gold");
                            _currentResultsScreen.totalResultsComponent["player" + (index+1)].prevSPBox.gotoAndStop("gold");
                            _currentResultsScreen.totalResultsComponent["player" + (index+1)].skillpointsUnavailable.gotoAndStop("gold");
                            _currentResultsScreen.totalResultsComponent["player" + (index+1)].newSPBox.gotoAndStop("gold");
                            myPosition = i;
                            myPosition2 = i2;
                        }
                        else
                        {
                            _currentResultsScreen["yellowRow" + (index+1)].visible = false;
                            _currentResultsScreen.totalResultsComponent["player" + (index+1)].playerNameComponent.gotoAndStop("blue");
                            _currentResultsScreen.totalResultsComponent["player" + (index+1)].scoreBox.gotoAndStop("normal");
                            _currentResultsScreen.totalResultsComponent["player" + (index+1)].prevSPBox.gotoAndStop("normal");
                            _currentResultsScreen.totalResultsComponent["player" + (index+1)].newSPBox.gotoAndStop("normal");
                            _currentResultsScreen.totalResultsComponent["player" + (index+1)].skillpointsUnavailable.gotoAndStop("normal");
                        }                
                        var skillPointsDifference:int = (positions[i][i2] as PersonScore).difference;
                        if(GameSys.skillpointsInfoAvailable){
                            _currentResultsScreen.totalResultsComponent["player" + (index+1)].skillpointsUnavailable.visible = false;
                        }
                        else
                        {
                            LanguageManager.getInstance().registerTag("_bbmSkillpointsUnavailable",  _currentResultsScreen.totalResultsComponent["player" + (index+1)].skillpointsUnavailable.textField, "text");
                        }
                        _currentResultsScreen.totalResultsComponent["player" + (index+1)].prevSPBox.textField.text = "" + ((positions[i][i2] as PersonScore).currentSkillPoints - skillPointsDifference);
                        _currentResultsScreen.totalResultsComponent["player" + (index+1)].differenceTxt.text = "" + skillPointsDifference;
                        _currentResultsScreen.totalResultsComponent["player" + (index+1)].newSPBox.textField.text = "" + ((positions[i][i2] as PersonScore).currentSkillPoints);
                        if (skillPointsDifference >= 0)
                        {
                            _currentResultsScreen.totalResultsComponent["player" + (index+1)].difSPBox.gotoAndStop("green");
                        } 
                        else 
                        {
                            _currentResultsScreen.totalResultsComponent["player" + (index+1)].difSPBox.gotoAndStop("red");
                        }
                        var croppedName:String = (positions[i][i2] as PersonScore).name.substr(0,12);
                        _currentResultsScreen.totalResultsComponent["player" + (index+1)].playerNameComponent.playerNameTxt.text = croppedName;
                        _currentResultsScreen.totalResultsComponent["player" + (index+1)].avatar.gotoAndStop("avatar"+(positions[i][i2] as PersonScore).avatar);
                        _currentResultsScreen.totalResultsComponent["player" + (index+1)].scoreBox.textField.text =  (positions[i][i2] as PersonScore).totalScorePoints;
                        fillScoreDialog(_currentResultsScreen.totalResultsComponent["player" + (index+1)].dialogBox,(positions[i][i2] as PersonScore).totalScore,true);                    
                        if ( (positions[i][i2] as PersonScore).person!=null && (positions[i][i2] as PersonScore).person.rematchAccepted)
                        {
                            _currentResultsScreen.totalResultsComponent["player" + (index+1)].dot.gotoAndStop("green");    
                        } 
                        else 
                        {
                            _currentResultsScreen.totalResultsComponent["player" + (index+1)].dot.gotoAndStop("red");
                        }
                    }
                    
                    index++;
                }
            }
            
            if(!honeyTracksEndGameResultDispatched)
            {
                honeyTracksEndGameResultDispatched = true;
                
                //HoneyTracks.trackFeatureUsage(HoneyTrackConstants.TRACKERNAME_GAME_RESULT, i + "/" + positions.length, ((positions[myPosition][myPosition2] as PersonScore).currentSkillPoints - skillPointsDifference).toString(), null, (positions[myPosition][myPosition2] as PersonScore).difference);
            }
            updateCurrentResultsScreen();
            updateResultsScrollControls();
        }
        
        public function showResultsScreen(endGame:Boolean = false, trophies:Boolean = false):void
        {
            var i:uint;
            GameData.instance.suddenDeathMessage.visible = false;
            TweenMax.to(gameObjectsContainer.infoScreen.bombTimer, .5, {alpha:1});
            
            gameObjectsContainer.warningMessage.visible = false;
            _currentResultsScreen.visible = false;
            if (gameObjectsContainer.lostFocusScreen != null)
            {
                gameObjectsContainer.lostFocusScreen.page.visible = false;
            }
            var container:MovieClip;
            if (endGame)
            {
                for (i = 0; i < Person.allPersons.length; i++)
                {
                    (Person.allPersons[i] as Person).dialogOver.visible = false;
                }
                
                gameObjectsContainer.infoScreen.spectateBox.visible = false;
                
                gameObjectsContainer.timeOutMessage.visible = false;
                _currentResultsScreen.gotoAndStop("endmatch");
                
                gameObjectsContainer.infoWindow.playBtn.x = 566;
                gameObjectsContainer.infoWindow.playBtn.y = 660;
                gameObjectsContainer.infoWindow.playBtn.visible = false;
                
                updateCurrentResultsScreen();
                var r:RoomLocalProperties = (SmartFoxClientSingleton.getInstance().smartFoxClient.gameRoom.properties as RoomLocalProperties);
                if ((GameSys.getRematchCount() + (SmartFoxClientSingleton.getInstance().smartFoxClient.gameRoom.properties as RoomLocalProperties).waitingList.length) > 1)
                {
                    if ((SmartFoxClientSingleton.getInstance().smartFoxClient.myself.properties as UserLocalProperties).isRegistered)
                    {
                        _currentResultsScreen.registrationLayer.visible = false;
                    } 
                    else 
                    {
                        _currentResultsScreen.registrationLayer.registrationPanel.registerBtn.hitArea.buttonMode = true;
                        EventListenerManager.setListenerTo(_currentResultsScreen.registrationLayer.btnClose, MouseEvent.CLICK, closeMe, false, 0, true);
                        _currentResultsScreen.registrationLayer.btnClose.buttonMode = true;
                        LanguageManager.getInstance().registerTag("_registerFree", _currentResultsScreen.registrationLayer.registrationPanel.mainTitle, "text");
                        GameSys.autoResize(_currentResultsScreen.registrationLayer.registrationPanel.mainTitle);
                        LanguageManager.getInstance().registerTag("_ownAvatar", _currentResultsScreen.registrationLayer.registrationPanel.textItem1, "text");
                        GameSys.autoResize(_currentResultsScreen.registrationLayer.registrationPanel.textItem1);
                        LanguageManager.getInstance().registerTag("_recordHighscores", _currentResultsScreen.registrationLayer.registrationPanel.textItem2, "text");
                        GameSys.autoResize(_currentResultsScreen.registrationLayer.registrationPanel.textItem2);
                        _currentResultsScreen.registrationLayer.visible = false;
                        LanguageManager.getInstance().registerTag("_registerNow", _currentResultsScreen.registrationLayer.registrationPanel.registerBtn.buttonTxt, "text");
                        GameSys.autoResize(_currentResultsScreen.registrationLayer.registrationPanel.registerBtn.buttonTxt);
                    }
                    _currentResultsScreen.insufficientPeople.visible = false;
                } 
                else 
                {
                    _currentResultsScreen.registrationLayer.visible = false;
                    EventListenerManager.setListenerTo(_currentResultsScreen.insufficientPeople.hitArea, MouseEvent.CLICK, GameSys.backToLobby, false, 0, true);
                    _currentResultsScreen.insufficientPeople.hitArea.buttonMode = true;
                    EventListenerManager.setListenerTo(_currentResultsScreen.insufficientPeople.btnClose, MouseEvent.CLICK, closeMe, false, 0, true);
                    _currentResultsScreen.insufficientPeople.btnClose.buttonMode = true;
                    LanguageManager.getInstance().registerTag("_tooBad", _currentResultsScreen.insufficientPeople.mainTitle, "text");
                    GameSys.autoResize(_currentResultsScreen.insufficientPeople.mainTitle);
                    LanguageManager.getInstance().registerTag("_notEnoughForRematch", _currentResultsScreen.insufficientPeople.textItem1, "text");
                    GameSys.autoResize(_currentResultsScreen.insufficientPeople.textItem1);
                    LanguageManager.getInstance().registerTag("_backToLobby", _currentResultsScreen.insufficientPeople.buttonTxt, "text");
                    GameSys.autoResize(_currentResultsScreen.insufficientPeople.buttonTxt);
                    _currentResultsScreen.resultsTimer.messagePanel.gotoAndStop("red");
                    LanguageManager.getInstance().registerTag("_backToLobbyResults", _currentResultsScreen.resultsTimer.timerMessage, "text");
                }
                LanguageManager.getInstance().registerTag("_matchScores", _currentResultsScreen.mainTitle, "text");
                LanguageManager.getInstance().registerTag("_matchScore", _currentResultsScreen.scoreLabel, "text");
                LanguageManager.getInstance().registerTag("_difference", _currentResultsScreen.differenceLabel, "text");
                LanguageManager.getInstance().registerTag("_oldSkillPoints", _currentResultsScreen.oldPointsLabel, "text");
                LanguageManager.getInstance().registerTag("_newSkillPoints", _currentResultsScreen.newPointsLabel, "text");
                container = _currentResultsScreen.totalResultsComponent;
            } 
            else 
            {
                _currentResultsScreen.gotoAndStop("endround");
                LanguageManager.getInstance().registerTag("_roundScore", _currentResultsScreen.scoreLabel, "text");
                LanguageManager.getInstance().registerTag("_totalScore", _currentResultsScreen.totalScoreLabel, "text");
                LanguageManager.getInstance().registerTag("_killsB", _currentResultsScreen.killsLabel, "text");
                LanguageManager.getInstance().registerTag("_roundScores", _currentResultsScreen.mainTitle, "text");
                container = _currentResultsScreen.partialResultsComponent;
                GameInterfaceManager.getInstance().toggleTitleScreenTitlePosition(true);
            }
            _currentResultsScreen.resultsTimer.clockWork.gotoAndStop(1);
            _currentResultsScreen.resultsTimer.clockWork.needle.gotoAndStop(1);
            _currentResultsScreen.resultsTimer.timeTxt.text = "00:00";
            GameData.instance.scores.sortOn(["totalScorePoints", "name"], [Array.NUMERIC | Array.DESCENDING, Array.DESCENDING]);
            for (i = 0; i < 8; i++)
            {
                _currentResultsScreen["yellowRow" + (i+1)].visible = false;
                if (i < GameData.instance.scores.length)
                {
                    container["player" + (i+1)].visible = true;
                    container["player" + (i+1)].dot.gotoAndStop("green");
                    if (endGame)
                    {
                        cleanTotalResults(trophies, i);
                    }
                    else
                    {
                        if (!trophies)
                        {
                            container["player" + (i+1)].gotoAndStop("endround_score");
                            container["player" + (i+1)].killsBox.gotoAndStop("normal");
                            container["player" + (i+1)].scoreBox.gotoAndStop("normal");
                            container["player" + (i+1)].totalScoreBox.gotoAndStop("normal");
                            EventListenerManager.setListenerTo(container["player" + (i+1)].scoreBox, MouseEvent.ROLL_OVER, showDialog);
                        }
                        else
                        {
                            container["player" + (i+1)].gotoAndStop("endround_trophies");    
                        }
                        container["player" + (i+1)].dot.visible = false;
                    }
                } 
                else 
                {
                    container["player" + (i+1)].visible = false;
                }
                
            }
            _currentResultsScreen.alpha = 0;
            if (!endGame)
            {
               // _currentResultsScreen.visible = true;
            }
            //TweenMax.to(_currentResultsScreen,1,{delay:.5,alpha:1});
        }
        
        public function fillScoreDialog(dialog:MovieClip,score:Score,isTotal:Boolean,deathPosition:uint=0):void
        {
            LanguageManager.getInstance().registerTag("_killsB", dialog.killsLabel, "text");
            LanguageManager.getInstance().registerTag("_deathsB", dialog.deathsLabel, "text");
            LanguageManager.getInstance().registerTag("_positiveItems", dialog.positiveItemsLabel, "text");
            LanguageManager.getInstance().registerTag("_negativeItems", dialog.negativeItemsLabel, "text");
            LanguageManager.getInstance().registerTag("_total", dialog.totalLabel, "text");
            dialog.killsTxt.text = "+" + score.killsScore;
            dialog.deathsTxt.text = score.deathsScore;
            dialog.positiveItems.text =  "+" + score.itemPlusScore;
            dialog.negativeItems.text =  score.itemMinusScore;
            dialog.totalTxt.text =  score.totalScore;
            if(isTotal)
            {
                LanguageManager.getInstance().registerTag("_totalPositions", dialog.jeGingLabel, "text");
            }
            else
            {
                if(score.alive || deathPosition==0)
                {
                    LanguageManager.getInstance().registerTag("_survivedPlayer", dialog.jeGingLabel, "text");
                }
                else
                {
                    LanguageManager.getInstance().registerTag("_deathPosition", dialog.jeGingLabel, "text", "%num%", "" + deathPosition);
                }
            }
            dialog.positionTxt.text = "+" + score.positionPointsScore;
        }
        
        public function onRematchStatusClick(e:MouseEvent):void
        {
            if (_currentResultsScreen.visible)
            {
                if (Person.getPersonByName(GameData.instance.myName).rematchAccepted)
                {
                    var sfsObject:SFSObject = new SFSObject();
                    sfsObject.putInt(ServerMessages.ROUND_NUMBER,GameData.instance.currentRound);        
                    sfsObject.putInt("pid",SmartFoxClientSingleton.getInstance().smartFoxClient.myself.id);    
                    SmartFoxClientSingleton.getInstance().smartFoxClient.sendExtensionRequestToGameRoom(ServerMessages.DECLINE_REMATCH,sfsObject);
                    Person.getPersonByName(GameData.instance.myName).rematchAccepted = false;
                }
                else
                {
                    var sfsObject2:SFSObject = new SFSObject();
                    sfsObject2.putInt(ServerMessages.ROUND_NUMBER,GameData.instance.currentRound);
                    sfsObject2.putInt("pid",SmartFoxClientSingleton.getInstance().smartFoxClient.myself.id);    
                    SmartFoxClientSingleton.getInstance().smartFoxClient.sendExtensionRequestToGameRoom(ServerMessages.ACCEPT_REMATCH,sfsObject2);
                    Person.getPersonByName(GameData.instance.myName).rematchAccepted = true;
                }
            }
            updateCurrentResultsScreen();
        }
        
        
        //Score tooltip
        private function showDialog(e:MouseEvent):void
        {
            var prevText:String = e.currentTarget.textField.text;
            var higherChild:int = 0;
            var targetChildNum:int = 0;
            var container:MovieClip;
            if (_currentResultsScreen.currentFrameLabel == "endmatch")
            {
                container = _currentResultsScreen.totalResultsComponent;
            }
            else
            {
                container = _currentResultsScreen.partialResultsComponent;
            }
            for (var i:uint = 1; i <= 9; i++)
            {
                for (var j:uint = 0; j < container.numChildren; j++)
                {
                    if (e.currentTarget.parent == container.getChildAt(j))
                    {
                        targetChildNum =  j;
                    }
                    if (container.getChildAt(j) == container["player" + i])
                    {
                        if (j > higherChild)
                        {
                            higherChild = j;
                        }
                    }
                }
            }
            
            if (targetChildNum < higherChild)
            {
                var child1:DisplayObject = container.getChildAt(higherChild);
                var child2:DisplayObject = container.getChildAt(targetChildNum);
                (container as MovieClip).swapChildren(child1, child2);
            }
            
            e.currentTarget.parent.dialogBox.visible = true;
            if ((e.currentTarget as MovieClip).currentFrameLabel == "normal")
            {
                e.currentTarget.gotoAndStop("pressed");
            } else if ((e.currentTarget as MovieClip).currentFrameLabel == "gold") 
            {
                e.currentTarget.gotoAndStop("gold_pressed");                
            }
            e.currentTarget.textField.text = prevText;
            EventListenerManager.setListenerTo((e.currentTarget as EventDispatcher), MouseEvent.ROLL_OUT, hideDialog);
        }
        
        
        private function hideDialog(e:MouseEvent):void
        {
            var prevText:String = e.currentTarget.textField.text;
            e.currentTarget.parent.dialogBox.visible = false;
            if ((e.currentTarget as MovieClip).currentFrameLabel == "pressed")
            {
                e.currentTarget.gotoAndStop("normal");
            } 
            else if ((e.currentTarget as MovieClip).currentFrameLabel == "gold_pressed") 
            {
                e.currentTarget.gotoAndStop("gold");
            }
            e.currentTarget.textField.text = prevText;
            EventListenerManager.setListenerTo((e.currentTarget as EventDispatcher), MouseEvent.ROLL_OUT, hideDialog);
        }
        
        private function cleanTotalResults(trophies:Boolean, index:int):void
        {
            var i:uint = index;
            var container:MovieClip  = _currentResultsScreen.totalResultsComponent;
            if (!trophies)
            {
                container["player" + (i+1)].gotoAndStop("endgame_score");    
                container["player" + (i+1)].scoreBox.gotoAndStop("normal");
                EventListenerManager.setListenerTo(container["player" + (i+1)].scoreBox, MouseEvent.ROLL_OVER, showDialog);
            }
            else
            {
                container["player" + (i+1)].gotoAndStop("endgame_trophies");
            }
            container["player" + (i+1)].dot.visible = true;
            container["player" + (i+1)].newSPBox.gotoAndStop("normal");
            container["player" + (i+1)].prevSPBox.gotoAndStop("normal");
            container["player" + (i+1)].difSPBox.gotoAndStop("green");
            _currentResultsScreen.columnLine1.visible = false;
            _currentResultsScreen.columnLine2.visible = false;
        }
        
        
        public function updateScreenOnDisconnect(name:String):void
        {
            if (_currentResultsScreen.visible && _currentResultsScreen.currentFrameLabel=="endmatch")
            {
                toggleRematchStatusDisplay(name, false);
            }
        }
        
        public function toggleRematchStatusDisplay(playerName:String, status:Boolean = true):void
        {
            if (_currentResultsScreen == false || _currentResultsScreen.currentFrameLabel != "endmatch")
            {
                return;
            }
            var spot:int = 0;
            if (PersonScore.getPersonScoreByName(playerName) != null)
            {
                for each (var thisScore:PersonScore in GameData.instance.scores)
                {
                    if (thisScore.name == playerName)
                    {
                        if (thisScore.person != null)
                        {
                            thisScore.person.rematchAccepted = status;
                        }
                        spot = GameData.instance.scores.indexOf(thisScore);    
                    }
                }
            } 
            else 
            {
                spot = -1;
            }
            var color:String = "green";
            if (!status) 
            {
                color = "red"; 
            }
            if ( spot > -1 && _currentResultsScreen.totalResultsComponent["player"+(spot+1)] != null && _currentResultsScreen.visible)
            {
                _currentResultsScreen.totalResultsComponent["player"+(spot+1)].dot.gotoAndStop(color);
            }
            displayRematchAvailability();
            
            if (GameData.instance.trophies)
            {
                fillTotalScreenTrophies(false, GameData.instance.resultsScrollCount);
            }
            else
            {
                fillTotalScreenScore(false, GameData.instance.resultsScrollCount);
            }
            
        }
        
        public function get currentResultsScreen():MovieClip
        {
            return _currentResultsScreen;
        }
        
        public function set currentResultsScreen(value:MovieClip):void
        {
            _currentResultsScreen = value;
        }
        
        public function updateCurrentResultsScreen():void
        {
            if (!SmartFoxClientSingleton.getInstance().smartFoxClient.myself.isSpectatorInRoom(SmartFoxClientSingleton.getInstance().smartFoxClient.gameRoom))
            {
                if (Person.getPersonByName(GameData.instance.myName) != null && Person.getPersonByName(GameData.instance.myName).rematchAccepted)
                {
                    _currentResultsScreen.spectatorsButton.gotoAndStop("spectate");
                    LanguageManager.getInstance().registerTag("_onlySpectate", _currentResultsScreen.spectatorsButton.spectateButton.mainText, "text");
                }
                else
                {
                    _currentResultsScreen.spectatorsButton.gotoAndStop("rematch");
                    LanguageManager.getInstance().registerTag("_joinRematch", _currentResultsScreen.spectatorsButton.playButton.mainText, "text");
                }
            }
            else
            {
                var rematchCount:int = 0;
                for each( var person:Person in Person.allPersons)
                {
                    if (person.rematchAccepted){
                        rematchCount++;
                    }
                }
                if ((SmartFoxClientSingleton.getInstance().smartFoxClient.gameRoom.properties as RoomLocalProperties).waitingList.indexOf(SmartFoxClientSingleton.getInstance().smartFoxClient.myself) > -1)
                {
                    if(LocalUser.getInstance().registered)
                    {
                        _currentResultsScreen.spectatorsButton.gotoAndStop("spectate");
                    }
                }
                else 
                {
                    if(SmartFoxClientSingleton.getInstance().smartFoxClient.gameRoom.maxUsers > 
                        rematchCount + (SmartFoxClientSingleton.getInstance().smartFoxClient.gameRoom.properties as RoomLocalProperties).waitingList.length)    
                    {
                        _currentResultsScreen.spectatorsButton.gotoAndStop("rematch");
                        LanguageManager.getInstance().registerTag("_joinRematch", _currentResultsScreen.spectatorsButton.playButton.mainText, "text");
                    }
                    else
                    {
                        _currentResultsScreen.spectatorsButton.gotoAndStop("waitingList");
                        LanguageManager.getInstance().registerTag("_joinWaitList", _currentResultsScreen.spectatorsButton.playButton.mainText, "text");
                    }
                }
            }
        }
        public function displayRematchAvailability():void
        {
            
            var vial:Object = SmartFoxClientSingleton.getInstance().smartFoxClient.myself;
            var vial2:Object = Person.getPersonByName(SmartFoxClientSingleton.getInstance().smartFoxClient.myself.name);
            var vial3:Object = SmartFoxClientSingleton.getInstance().smartFoxClient.gameRoom;
            
            if (!(SmartFoxClientSingleton.getInstance().smartFoxClient.myself.isSpectatorInRoom(SmartFoxClientSingleton.getInstance().smartFoxClient.gameRoom)) && Person.getPersonByName(SmartFoxClientSingleton.getInstance().smartFoxClient.myself.name).rematchAccepted && 
                (GameSys.getRematchCount() + (SmartFoxClientSingleton.getInstance().smartFoxClient.gameRoom.properties as RoomLocalProperties).waitingList.length) <= 1 )
            {
                _currentResultsScreen.insufficientPeople.visible = true;
                _currentResultsScreen.registrationLayer.visible = false;
            }
            else 
            {
                _currentResultsScreen.insufficientPeople.visible = false;
                _currentResultsScreen.resultsTimer.messagePanel.gotoAndStop("green");   
            }
            if ((GameSys.getRematchCount() + (SmartFoxClientSingleton.getInstance().smartFoxClient.gameRoom.properties as RoomLocalProperties).waitingList.length) > 1)
            {                
                _currentResultsScreen.resultsTimer.messagePanel.gotoAndStop("green");
                LanguageManager.getInstance().registerTag("_newMatchStartingSoon", _currentResultsScreen.resultsTimer.timerMessage, "text");
            } 
            else 
            {
                _currentResultsScreen.resultsTimer.messagePanel.gotoAndStop("red");
                LanguageManager.getInstance().registerTag("_backToLobbyResults", _currentResultsScreen.resultsTimer.timerMessage, "text");
            }
        }
        
        public function closeMe(e:MouseEvent):void
        {
            e.currentTarget.parent.visible = false;
        }

    }
}