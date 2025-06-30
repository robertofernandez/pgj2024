package com.willdom.games.bomberman.gameobjects
{
    import com.gq.moveobject.DeadlyBlock;
    import com.gq.moveobject.Person;
    import com.gq.moveobject.WalkControlSet;
    import com.gq.system.DiseaseManager;
    import com.gq.system.GameData;
    import com.gq.system.GameSys;
    import com.gq.system.GameTools;
    import com.gq.system.SoundClass;
    import com.gq.ui.FocusBoard;
    import com.gq.ui.InGameUserListManager;
    import com.gq.ui.characterselect.CharacterSelectScreen;
    import com.gq.ui.endmatch.EndMatchAdvertismentScreen;
    import com.gq.ui.endmatch.EndMatchResultsScreen;
    import com.gq.ui.endmatch.EndMatchWinnerScreen;
    import com.gq.ui.endround.EndRoundResultsScreen;
    import com.gq.ui.inround.CommunicationBar;
    import com.gq.ui.inround.EquipmentBar;
    import com.greensock.TweenMax;
    import com.smartfoxserver.v2.entities.Room;
    import com.smartfoxserver.v2.entities.data.ISFSArray;
    import com.smartfoxserver.v2.entities.data.SFSObject;
    import com.smartfoxserver.v2.entities.variables.RoomVariable;
    import com.willdom.games.bomberman.communication.RoomVarsEvent;
    import com.willdom.games.bomberman.communication.SmartFoxClientSingleton;
    import com.willdom.games.bomberman.consts.ServerMessages;
    import com.willdom.games.bomberman.rooms.RoomLocalProperties;
    import com.willdom.games.bomberman.statemachine.StatusManager;
    import com.willdom.games.bomberman.user.UserLocalProperties;
    import com.willdom.games.explodersmmo.shared.consts.GameRoomVars;
    import com.willdom.games.explodersmmo.shared.events.game.GameEndedEvent;
    import com.willdom.games.explodersmmo.shared.helpers.StringHelper;
    import com.willdom.games.explodersmmo.shared.model.LocalUser;
    import com.willdom.games.explodersmmo.shared.model.SoundSettings;
    import com.willdom.util.helpers.EventListenerManager;
    
    import configuration.StageModes;
    
    import flash.display.MovieClip;
    import flash.events.EventDispatcher;
    import flash.events.MouseEvent;
    import flash.geom.Point;
    import flash.geom.Rectangle;

    public class GameObjectsContainer
    {
        public var warningMessage:WarningMessageMC;
        public var warningCounter:int = 10;
        public var lostFocusScreen:FocusBoard;
        public var waitingW:WaitingMC;
        
        //FIXME WHAT??
        public var infoScreen:InfoScreen;
        public var infoWindow:InfoScreen;
        
        public var characterSelectScreen:CharacterSelectScreen
        
        public var inRoundEquipmentBar:EquipmentBar;
        public var inRoundCommunicationBar:CommunicationBar;
        
        public var endRoundResultsScreen:EndRoundResultsScreen;
        public var endMatchWinnerScreen:EndMatchWinnerScreen;
        public var endMatchAdvertismentScreen:EndMatchAdvertismentScreen;
        public var endMatchResultsScreen:EndMatchResultsScreen;
        public var endMatchAuxBackground:MC_EndScreenAuxBackground;
        
        public var resultsScreenContainer:ResultsScreenContainer;
        
        public var timeOutMessage:TimeOutMessageMC;
        
        //These screens are accesed from ending state in case, there are no players to start game
        public var selectionScreen:CharacterSelectionScreenV3;
        public var noPlayersScreen:NoPlayersToPlayMC;
        
        public function GameObjectsContainer()
        {
            warningMessage = new WarningMessageMC();
            warningMessage.x = 172;
            warningMessage.y = 250;
            warningMessage.mainTitle.text = LanguageManager.getInstance().getText("_plaseStart");
            warningMessage.mainTxt.text = LanguageManager.getInstance().getText("_youHaveBeenIdle");
            LanguageManager.getInstance().registerTag("_backToLobbyCount", warningMessage.countDownMessage, "text");
            warningMessage.visible = false;
            warningMessage.closeBtn.buttonMode = true;
            
            timeOutMessage = new TimeOutMessageMC();
            timeOutMessage.visible = false;
            timeOutMessage.alpha = 0;
            timeOutMessage.x += 35;
            timeOutMessage.y = 315;
            
            infoWindow = new InfoScreen();
            infoScreen = infoWindow;
            infoScreen.addChild(timeOutMessage);
            infoScreen.addChild(warningMessage);
            infoScreen.colorLab.visible = false;
            infoScreen.itemsTooltip.visible = false;
            
            waitingW = new WaitingMC;
            
            if (GameData.instance.diseaseManager==null)
            {
                GameData.instance.diseaseManager = new DiseaseManager();
            }
            
            EventListenerManager.setListenerTo(SmartFoxClientSingleton.getInstance().smartFoxClient, RoomVarsEvent.VARS_CHANGED, onRoomVarsChanged);
        }
        
        
        public function init():void
        {
            GameData.instance.infoWindow.addChild(infoWindow);
            infoWindow.name = "infoScreen";
            infoWindow.homeBtn.buttonMode = true;
            infoWindow.soundBtn.buttonMode = true;
            infoWindow.playBtn.buttonMode = true;

            resultsScreenContainer = new ResultsScreenContainer(this);
            
            if( !SmartFoxClientSingleton.getInstance().smartFoxClient.myself.isSpectator ||
                (!SmartFoxClientSingleton.getInstance().smartFoxClient.gameRoom.getVariable(GameRoomVars.FRIENDLY_ROOM).getBoolValue() && 
                    !LocalUser.getInstance().registered) )
            {
                infoWindow.playBtn.visible = false;
            }
            else if(SmartFoxClientSingleton.getInstance().smartFoxClient.myself.isSpectator)
            {
                infoWindow.playBtn.visible = false;
            }
            
            if(SoundSettings.getInstance().masterVolume == 0)
            {
                infoWindow.soundBtn.gotoAndStop("off");
            }
            
            initInfoScreen();
            
            EventListenerManager.setListenerTo(infoWindow.homeBtn, MouseEvent.CLICK, GameSys.backToLobby, false, 0, true);
            EventListenerManager.setListenerTo(infoWindow.soundBtn, MouseEvent.CLICK, onSoundBtnClick, false, 0, true);
        }
        
        public function gameBuild():void
        {
            EventListenerManager.setListenerTo(GameData.instance.Scen.stage, GameEndedEvent.GAME_END_REQUEST, onGameEndedRequest);
            init();
        }
        
        public function startInfoScreen():void
        {
            infoScreen.bombTimer.alpha = 0;
            //infoScreen.bombTimer.visible = true;
            infoScreen.bombTimer.visible = false;
            TweenMax.to(infoScreen.bombTimer, .5, {alpha:1});
            infoScreen.bombTimer.clockWork.gotoAndStop(1);
            infoScreen.bombTimer.clockWork.needle.gotoAndStop(1);
            EventListenerManager.setListenerTo(infoScreen.powerUpBar, MouseEvent.MOUSE_OVER, onMouseOverPowerUpBar);
            infoScreen.itemsTooltip.visible = false;
            infoScreen.bombTimer.timeTxt.text = StringHelper.timeToClock(GameData.instance.time);
            
            markOnClock(0);
            
            infoScreen.powerUpBar.container.power1.lvlMC.visible = false;
            infoScreen.powerUpBar.container.power2.lvlMC.visible = false;
            if( GameData.instance.STAGE_MODE == StageModes.HYPER ) {
                infoScreen.powerUpBar.container.power4.lvlMC.txt.text = "8";
                infoScreen.powerUpBar.container.power4.lvlMC.visible = true;
            }else{
                infoScreen.powerUpBar.container.power4.lvlMC.txt.text = "1";
                infoScreen.powerUpBar.container.power4.lvlMC.visible = false;
            }
            
            
            endMatchAuxBackground = new MC_EndScreenAuxBackground;
            endMatchAuxBackground.visible = false;
            infoScreen.addChild(endMatchAuxBackground);
            
            inRoundEquipmentBar = new EquipmentBar;
            inRoundEquipmentBar.y = 200;
            inRoundEquipmentBar.visible = false;
            inRoundEquipmentBar.resetPowerUps();
            if(!SmartFoxClientSingleton.getInstance().smartFoxClient.myself.isSpectator)
            {
                infoScreen.addChild(inRoundEquipmentBar);
            }
            
            inRoundCommunicationBar = new CommunicationBar;
            inRoundCommunicationBar.x = 10;
            inRoundCommunicationBar.y = -10;
            inRoundCommunicationBar.visible = false;
            infoScreen.addChild(inRoundCommunicationBar);
            
            endRoundResultsScreen = new EndRoundResultsScreen;
            endRoundResultsScreen.x = 36;
            endRoundResultsScreen.y = 35;
            endRoundResultsScreen.hideRoundResults();
            infoScreen.addChild(endRoundResultsScreen);
            
            endMatchWinnerScreen = new EndMatchWinnerScreen;
            endMatchWinnerScreen.x = 5;
            endMatchWinnerScreen.hideWinnerScreen();
            infoScreen.addChild(endMatchWinnerScreen);
            
            endMatchAdvertismentScreen = new EndMatchAdvertismentScreen;
            endMatchAdvertismentScreen.x = 36;
            endMatchAdvertismentScreen.y = 35;
            endMatchAdvertismentScreen.hideAdvertismentScreen();
            infoScreen.addChild(endMatchAdvertismentScreen);
            
            endMatchResultsScreen = new EndMatchResultsScreen;
            endMatchResultsScreen.x = 36;
            endMatchResultsScreen.y = 35;
            endMatchResultsScreen.hideEndResultsScreen();
            infoScreen.addChild(endMatchResultsScreen);

        }
        
        private function onRoomVarsChanged(event:RoomVarsEvent):void
        {
            var room:Room = event.room;
            var vars:Array = event.vars;
            if(room == SmartFoxClientSingleton.getInstance().smartFoxClient.gameRoom && 
                vars.indexOf("waitingList")!=-1 ){
                var roomVar:RoomVariable = room.getVariable("waitingList");
                var enc:Boolean = false;
                if(roomVar != null){
                    var sfsArray:ISFSArray = roomVar.getSFSArrayValue();
                    (SmartFoxClientSingleton.getInstance().smartFoxClient.gameRoom.properties as RoomLocalProperties).waitingList.splice(0,(SmartFoxClientSingleton.getInstance().smartFoxClient.gameRoom.properties as RoomLocalProperties).waitingList.length);
                    for(var i:uint=0;i<sfsArray.size();i++){
                        if(sfsArray.getUtfString(i) == SmartFoxClientSingleton.getInstance().smartFoxClient.myself.name){
                            enc = true;
                        }
                        (SmartFoxClientSingleton.getInstance().smartFoxClient.gameRoom.properties as RoomLocalProperties).waitingList.push(SmartFoxClientSingleton.getInstance().smartFoxClient.gameRoom.getUserByName(sfsArray.getUtfString(i)));
                    }
                    toggleWaitingListBtn(enc);
                }
            }
        }
        
        private function onGameEndedRequest(event:GameEndedEvent):void
        {
            if (GameData.instance.Scen != null && GameData.instance.Scen.stage!=null)
            {
                GameData.instance.Scen.stage.removeEventListener(GameEndedEvent.GAME_END_REQUEST, onGameEndedRequest);
            }
            infoScreen.setChildIndex(infoScreen.menuPopup, infoScreen.numChildren-1);
            infoScreen.menuPopup.visible = true;
            LanguageManager.getInstance().registerTag("_backToLobby",  infoScreen.menuPopup.titleTxt, "text");
            LanguageManager.getInstance().registerTag("_wantQuestion",  infoScreen.menuPopup.message2Txt, "text");
            infoScreen.menuPopup.btnQuit.buttonMode = true;
            LanguageManager.getInstance().registerTag("_surrenderButton",  infoScreen.menuPopup.btnQuit.txt, "text");
            infoScreen.menuPopup.btnResume.buttonMode = true;
            LanguageManager.getInstance().registerTag("_backToGameButton",  infoScreen.menuPopup.btnResume.txt, "text");
            EventListenerManager.setListenerTo(infoScreen.menuPopup.btnQuit, MouseEvent.CLICK, onButtonQuitClick);
            EventListenerManager.setListenerTo(infoScreen.menuPopup.btnResume, MouseEvent.CLICK, onButtonResumeClick);
        }
        
        private function onButtonResumeClick(event:MouseEvent):void
        {
            infoScreen.menuPopup.btnResume.removeEventListener(MouseEvent.CLICK, onButtonResumeClick);
            EventListenerManager.setListenerTo(GameData.instance.Scen.stage, GameEndedEvent.GAME_END_REQUEST, onGameEndedRequest);
            infoScreen.menuPopup.visible = false;
        }
        
        private function onButtonQuitClick(event:MouseEvent):void
        {
            infoScreen.menuPopup.btnQuit.removeEventListener(MouseEvent.CLICK, onButtonQuitClick);
            infoScreen.menuPopup.btnResume.removeEventListener(MouseEvent.CLICK, onButtonResumeClick);
            infoScreen.menuPopup.visible = false;
            GameSys.forceQuit();
        }
        
        
        
        public function markOnClock(time:uint):void
        {
            if (time == 0)
            {
                infoScreen.bombTimer.clockWork.gotoAndStop(1);
                infoScreen.bombTimer.clockWork.needle.gotoAndStop(1);
            } 
            else 
            {
                var timeSpot:uint = Math.floor((130/(GameData.instance.time)) * time);
                infoScreen.bombTimer.clockWork.gotoAndStop(timeSpot);
                infoScreen.bombTimer.clockWork.needle.gotoAndStop(timeSpot);    
            }
        }
        
        private function onMouseOverPowerUpBar(e:MouseEvent):void
        {
            if (infoScreen.itemsTooltip == null)
            {
                return;
            }
            var message:String;
            if (e.target is MovieClip)
            {
                
                switch ((e.target as MovieClip).name)
                {
                    case "item1":
                        message = LanguageManager.getInstance().getText("_bombs");
                        break;
                    
                    case "item2":
                        message = LanguageManager.getInstance().getText("_blastStrength");
                        break;
                    
                    case "item3":
                        message = LanguageManager.getInstance().getText("_speed");
                        break;
                    case "item4":
                        message = LanguageManager.getInstance().getText("_bombKick");
                        break;
                    case "item5":
                        message = LanguageManager.getInstance().getText("_bombChange");
                        break;
                    case "item6":
                        message = LanguageManager.getInstance().getText("_bombType");
                        break;
                }
                
                if (infoScreen.itemsTooltip != null && message != null)
                {
                    infoScreen.itemsTooltip.x = e.target.x + 753 + (Math.floor((e.target as MovieClip).width/2));
                    infoScreen.itemsTooltip.y = 100;
                    //infoScreen.itemsTooltip.visible = true;
                    infoScreen.itemsTooltip.gotoAndStop(1);
                    
                    if (e.target.name == "item6")
                    {
                        infoScreen.itemsTooltip.gotoAndStop("whiteRight");
                    }
                    
                    infoScreen.itemsTooltip.playerName.text = message;
                    
                    var rectArea:Rectangle = new Rectangle(infoScreen.itemsTooltip.playerName.x,infoScreen.itemsTooltip.playerName.y,infoScreen.itemsTooltip.playerName.width, infoScreen.itemsTooltip.playerName.height);
                    
                    if (infoScreen.itemsTooltip.playerName.textHeight > rectArea.height)
                    {
                        if ((infoScreen.itemsTooltip as MovieClip).currentFrameLabel == "whiteRight")
                        {
                            infoScreen.itemsTooltip.gotoAndStop("largeRight");
                        } 
                        else
                        {
                            infoScreen.itemsTooltip.gotoAndStop("large");
                        }
                        infoScreen.itemsTooltip.playerName.text = message;
                    }
                    EventListenerManager.setListenerTo(infoScreen.itemsTooltip, MouseEvent.MOUSE_OUT, onMouseOutItemTooltip, false, 0, true);
                    EventListenerManager.setListenerTo((e.target as EventDispatcher), MouseEvent.ROLL_OUT, onMouseOutItemTooltip);
                }
            }
        }
        
        private function joinWaitlist(e:MouseEvent):void
        {
            InGameUserListManager.getInstance().onWaitingButtonClick(e);
            //SmartFoxClientSingleton.getInstance().smartFoxClient.joinWaitingList(true);
            infoScreen.spectateBox.visible = false;
        }
        
        private function joinSpectatorList(e:MouseEvent):void
        {
            InGameUserListManager.getInstance().onSpectateButtonClick(e);
            //SmartFoxClientSingleton.getInstance().smartFoxClient.joinWaitingList(true);
            infoScreen.spectateBox.visible = false;
        }
        
        private function initInfoScreen():void
        {
            
            if (SmartFoxClientSingleton.getInstance().smartFoxClient.myself.isSpectatorInRoom(SmartFoxClientSingleton.getInstance().smartFoxClient.gameRoom))
            {
                infoScreen.spectateBox.visible = true;
                infoScreen.spectateBox.x = 180;
                infoScreen.spectateBox.y = 250;
                LanguageManager.getInstance().registerTag("_spectateMode",  infoScreen.spectateBox.mainTitle, "text");
                
                var r:RoomVariable = SmartFoxClientSingleton.getInstance().smartFoxClient.gameRoom.getVariable(GameRoomVars.FRIENDLY_ROOM);
                
                if( (SmartFoxClientSingleton.getInstance().smartFoxClient.myself.properties as UserLocalProperties).isRegistered
                    || SmartFoxClientSingleton.getInstance().smartFoxClient.gameRoom.getVariable(GameRoomVars.FRIENDLY_ROOM).getBoolValue()){
                    infoScreen.spectateBox.playButton.visible = true;
                    infoScreen.spectateBox.playButton.buttonMode = true;
                    LanguageManager.getInstance().registerTag("_joinWaitList",  infoScreen.spectateBox.playButton.mainText, "text");
                    infoScreen.spectateBox.playButton.mouseChildren = false;
                    infoScreen.spectateBox.registerButton.visible = false;
                    EventListenerManager.setListenerTo(infoScreen.spectateBox.playButton, MouseEvent.CLICK, joinWaitlist);
                    LanguageManager.getInstance().registerTag("_spectatorsDescription",  infoScreen.spectateBox.mainText, "text");
                }
                else
                {
                    infoScreen.spectateBox.playButton.visible = false;
                    //Registration popup hidden
                    infoScreen.spectateBox.registerButton.visible = false;
                    infoScreen.spectateBox.registerButton.buttonMode = true;
                    LanguageManager.getInstance().registerTag("_registerForFree",  infoScreen.spectateBox.registerButton.mainText, "text");
                    infoScreen.spectateBox.registerButton.mouseChildren = false;
                    LanguageManager.getInstance().registerTag("_spectateMode",  infoScreen.spectateBox.mainTitle, "text");
                    LanguageManager.getInstance().registerTag("_youCanOnlyWatch",  infoScreen.spectateBox.mainText, "text");
                }
                EventListenerManager.setListenerTo(infoScreen.spectateBox.spectateButton, MouseEvent.CLICK, joinSpectatorList);
                EventListenerManager.setListenerTo(infoScreen.spectateBox.closeBtn, MouseEvent.CLICK, closeMe);
                infoScreen.spectateBox.spectateButton.buttonMode = true;
                infoScreen.spectateBox.spectateButton.mouseChildren = false;
                LanguageManager.getInstance().registerTag("_onlySpectate",  infoScreen.spectateBox.spectateButton.mainText, "text");
                infoScreen.spectateBox.closeBtn.buttonMode = true;
            }
            else
            {
                infoScreen.spectateBox.visible = false;
            }
            
            if(SmartFoxClientSingleton.getInstance().smartFoxClient.myself.isSpectator)
            {
                infoWindow.playBtn.gotoAndStop("off");
                infoWindow.playBtn.mainText.text = LanguageManager.getInstance().getText("_onlySpectate");

            }
            else
            {
                infoWindow.playBtn.gotoAndStop("on");
                infoWindow.playBtn.mainText.text = LanguageManager.getInstance().getText("_joinWaitList");
            }
            
            infoScreen.bombTimer.visible = false;
            infoScreen.bombTimer.clockWork.gotoAndStop(1);
            infoScreen.bombTimer.clockWork.needle.gotoAndStop(1);
            infoScreen.powerUpBar.visible = false;
            infoScreen.powerUpBar.mask = infoScreen.playerListComponent.topPanel.mask;
            infoScreen.menuPopup.visible = false;
            infoScreen.playerLagInfo.visible = false;
            infoScreen._buttonMute.buttonMode = true;
        }

        private function onSoundBtnClick(e:MouseEvent):void
        {
            if(SoundSettings.getInstance().masterVolume == 0)
            {
                SoundSettings.getInstance().masterVolume = SoundSettings.getInstance().prevMasterVolume;
                SoundClass.setmusicVolume(SoundSettings.getInstance().masterVolume * SoundSettings.getInstance().gameMusicVolume);
                SoundClass.setsoundVolume(SoundSettings.getInstance().masterVolume * SoundSettings.getInstance().gameSoundVolume);
                e.currentTarget.gotoAndStop("on");
            }
            else
            {
                SoundSettings.getInstance().masterVolume = 0;
                SoundClass.setmusicVolume(0);
                SoundClass.setsoundVolume(0);
                e.currentTarget.gotoAndStop("off");
            }
        }
        
        private function onMouseOutItemTooltip(e:MouseEvent):void
        {
            infoScreen.itemsTooltip.visible = false;
            e.currentTarget.removeEventListener(MouseEvent.MOUSE_OUT, onMouseOutItemTooltip);
        }
        
        public function toggleWaitingListBtn(inWaitingList:Boolean):void
        {
            if(infoWindow != null)
            {
                if(inWaitingList)
                {
                    infoWindow.playBtn.gotoAndStop("off");
                    infoWindow.playBtn.mainText.text = LanguageManager.getInstance().getText("_onlySpectate");
                }
                else
                {
                    infoWindow.playBtn.gotoAndStop("on");
                    infoWindow.playBtn.mainText.text = LanguageManager.getInstance().getText("_joinWaitList");
                }
            }
        }
        
        public function onCancelRanking():void
        {
            GameSys.skillpointsInfoAvailable = false;
            GameData.instance.gameObjectsContainer.infoScreen.playerListComponent.topPanel.skillpointsErrorMessage.nameTxt.text = LanguageManager.getInstance().getText("_skillpointsErrorMessage"); 
            infoScreen.playerListComponent.topPanel.skillpointsErrorMessage.visible = true;
            EventListenerManager.setListenerTo(infoScreen.playerListComponent.topPanel.skillpointsErrorMessage, MouseEvent.MOUSE_OVER,overSkillpointsError);
            EventListenerManager.setListenerTo(infoScreen.playerListComponent.topPanel.skillpointsErrorMessage, MouseEvent.MOUSE_OUT,outSkillpointsError);
        }
        
        public function onServerShutdown():void
        {
            GameData.instance.gameObjectsContainer.infoScreen.playerListComponent.topPanel.skillpointsErrorMessage.nameTxt.text = LanguageManager.getInstance().getText("_shutdownMessage");
            infoScreen.playerListComponent.topPanel.skillpointsErrorMessage.visible = true;
        }
        
        private function overSkillpointsError(evt:MouseEvent):void{
            infoScreen.playerListComponent.topPanel.skillpointsErrorMessage.skillpointsErrorTooltip.visible = true;
        }
        
        private function outSkillpointsError(evt:MouseEvent):void{
            infoScreen.playerListComponent.topPanel.skillpointsErrorMessage.skillpointsErrorTooltip.visible = false;
        }
        
        public function onLostFocus():void
        {
            if(!lostFocusScreen && GameData.instance.currentGameStatus != StatusManager.END_ROUND_STATUS && GameData.instance.currentGameStatus != StatusManager.END_MATCH_STATUS){
                lostFocusScreen = GameTools.createPage( FocusBoard) as FocusBoard;
                LanguageManager.getInstance().registerTag("_focusScreenMessage",  lostFocusScreen.page.titleTxt, "text");
                if(lostFocusScreen.page.buttonTxt!=null){
                    LanguageManager.getInstance().registerTag("_keepPlaying",  lostFocusScreen.page.buttonTxt, "text");
                }
                lostFocusScreen.page.x += 9;
                lostFocusScreen.page.y += 25;
                lostFocusScreen.page.visible = false;
                if (!warningMessage.visible && !SmartFoxClientSingleton.getInstance().smartFoxClient.myself.isSpectatorInRoom(SmartFoxClientSingleton.getInstance().smartFoxClient.gameRoom)){
                    lostFocusScreen.page.visible = true;
                }
            }
        }
        
        public function onGainFocus():void
        {
            if(lostFocusScreen != null){
                lostFocusScreen.removeMe();
            }
            lostFocusScreen = null;
        }
        
        
        
        
        public function onDeadlyBlockShadow(params:SFSObject):void
        {
            var tiles:ISFSArray = params.getSFSArray("pos");
            var thisShadowTile:SFSObject;
            var shadowX:int = 0;
            var shadowY:int = 0;
            for (var arrayPosition:int = 0; arrayPosition < tiles.size(); arrayPosition++)
            {
                thisShadowTile = tiles.getElementAt(arrayPosition);
                shadowX = thisShadowTile.getInt("x");
                shadowY = thisShadowTile.getInt("y");
                if (DeadlyBlock.getBlockSpot(shadowX, shadowY) != null)
                {
                    DeadlyBlock.getBlockSpot(shadowX, shadowY).startFall(1500);
                }
            }
        }
        
        public function onDeadlyBlockSettle(params:SFSObject):void
        {
            var tileSpots:ISFSArray = params.getSFSArray("pos");
            var thisTile:SFSObject;
            var x:int = 0;
            var y:int = 0;
            var thisBlock:DeadlyBlock;
            for (var arrayPosition:int = 0; arrayPosition < tileSpots.size(); arrayPosition++)
            {
                thisTile = tileSpots.getElementAt(arrayPosition);
                x = thisTile.getInt("x");
                y = thisTile.getInt("y");
                thisBlock = DeadlyBlock.getBlockSpot(x, y);
                if (thisBlock != null)
                {
                    if (params.getBool(ServerMessages.DEADLY_BLOCK_IS_FINAL))
                    {
                        thisBlock.setFinal();
                    }
                    thisBlock.id = params.getInt("fid");
                    thisBlock.endFall();
                }
            }
        }
        
        public function onPositionSwitch(params:SFSObject):void
        {
            var person1:Person = Person.getPersonByName(params.getUtfString("fst"));
            var person2:Person = Person.getPersonByName(params.getUtfString("scd"));
            
            var currentTile:Point = (GameData.instance.walkControls[int(person1.myId)] as WalkControlSet).currentTile; 
            var randomPersonTile:Point = (GameData.instance.walkControls[int(person2.myId)] as WalkControlSet).currentTile; 
            GameData.instance.positionManager.removeObjectFromMap(currentTile.x,currentTile.y,person1);
            GameData.instance.walkControls[int(person1.myId)].resetDirection();
            GameData.instance.positionManager.removeObjectFromMap(randomPersonTile.x,randomPersonTile.y,person2);
            GameData.instance.walkControls[int(person2.myId)].resetDirection();
            
            var prevConfirmedPosition:Point = new Point(person1.confirmedPosition.x,person1.confirmedPosition.y);
            GameData.instance.walkControls[int(person1.myId)].setTilePosition(person2.confirmedPosition.clone());
            
            person1.confirmedPosition.x = person2.confirmedPosition.x;
            person1.confirmedPosition.y = person2.confirmedPosition.y;
            
            GameData.instance.walkControls[int(person2.myId)].setTilePosition(prevConfirmedPosition.clone());
            person2.confirmedPosition.x = prevConfirmedPosition.x;
            person2.confirmedPosition.y = prevConfirmedPosition.y;
            
            person1.invincible = false;
            person2.invincible = false; 
            person1.endPortal();
            person2.endPortal();
        }
        
        public function onBombSkin(params:SFSObject):void
        {
            (GameData.instance["controlWho" + params.getUtfString("myId")] as Person).setBombSkin(params.getBool("state"));
        }
        
        public function closeMe(e:MouseEvent):void
        {
            e.currentTarget.parent.visible = false;
        }
        
        public function buildCharacterSelectDependencies():void
        {
            characterSelectScreen = new CharacterSelectScreen;
            characterSelectScreen.hideCharacterScreen();
            GameData.instance.playerSelectionWindow.addChild(characterSelectScreen);
        }
        
        public function buildEndMatchDependencies():void
        {
            if(endMatchAuxBackground == null)
            {
                endMatchAuxBackground = new MC_EndScreenAuxBackground;
            }
            infoScreen.addChild(endMatchAuxBackground);
            
            endRoundResultsScreen = new EndRoundResultsScreen;
            endRoundResultsScreen.x = 36;
            endRoundResultsScreen.y = 35;
            endRoundResultsScreen.hideRoundResults();
            infoScreen.addChild(endRoundResultsScreen);
            
            endMatchWinnerScreen = new EndMatchWinnerScreen;
            endMatchWinnerScreen.x = 5;
            endMatchWinnerScreen.hideWinnerScreen();
            infoScreen.addChild(endMatchWinnerScreen);
            
            endMatchAdvertismentScreen = new EndMatchAdvertismentScreen;
            endMatchAdvertismentScreen.x = 36;
            endMatchAdvertismentScreen.y = 35;
            endMatchAdvertismentScreen.hideAdvertismentScreen();
            infoScreen.addChild(endMatchAdvertismentScreen);
            
            endMatchResultsScreen = new EndMatchResultsScreen;
            endMatchResultsScreen.x = 36;
            endMatchResultsScreen.y = 35;
            endMatchResultsScreen.hideEndResultsScreen();
            infoScreen.addChild(endMatchResultsScreen);
        }
    }
}