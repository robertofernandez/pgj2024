package com.willdom.games.bomberman.statemachine
{
    import com.gq.moveobject.Person;
    import com.gq.system.Disease;
    import com.gq.system.GameData;
    import com.gq.system.GameSys;
    import com.gq.system.SoundClass;
    import com.greensock.TweenMax;
    import com.smartfoxserver.v2.entities.data.ISFSArray;
    import com.smartfoxserver.v2.entities.data.SFSObject;
    import com.willdom.games.bomberman.communication.SmartFoxClientSingleton;
    import com.willdom.games.bomberman.consts.ServerMessages;
    import com.willdom.games.bomberman.consts.SkullTypes;
    import com.willdom.games.bomberman.controllers.ConfigController;
    import com.willdom.games.bomberman.events.PlayerEvent;
    import com.willdom.games.bomberman.gameobjects.GameInterfaceManager;
    import com.willdom.games.bomberman.gameobjects.GameObjectsContainer;
    import com.willdom.games.explodersmmo.shared.helpers.StringHelper;
    import com.willdom.games.explodersmmo.shared.model.LocalUser;
    //import com.willdom.games.explodersmmo.shared.tracker.HoneyTrackConstants;
    //import com.willdom.games.explodersmmo.shared.tracker.HoneyTracksHelper;
    import com.willdom.util.helpers.EventListenerManager;
    
    import flash.events.MouseEvent;
    
    /**
     * Game status that represents the stage when game is inside a round.
     */
    public class InRoundStatus extends BasicStatusWithEventHandling
    {
        private static const END_RESULTS_SCREEN_TIME:int = 30;
        private var gameObjectsContainer:GameObjectsContainer;
        
        public function InRoundStatus(gameObjectsContainer:GameObjectsContainer)
        {
            this.gameObjectsContainer = gameObjectsContainer;
        }
        
        override public function init(params:SFSObject):void
        {
            GameData.instance.gameBox.stage.focus = GameData.instance.gameBox;

            registerFunction(ServerMessages.TIME_TICK, onTimeTick);
            registerFunction(ServerMessages.WARNING, onWarning);
            registerFunction(ServerMessages.CANCEL_RANKING, onCancelRanking);
            registerFunction("serverShutdown", onServerShutdonw);
            registerFunction(ServerMessages.DEADLY_BLOCK_SHADOW, onDeadlyBlockShadow);
            registerFunction(ServerMessages.DEADLY_BLOCK_SETTLE, onDeadlyBlockSettle);
            registerFunction(ServerMessages.POSITION_SWITCH, onPositionSwitch);
            registerFunction(ServerMessages.BOMB_SKIN, onBombSkin);

            if(gameObjectsContainer.infoScreen != null)
            {
                gameObjectsContainer.infoScreen.bombTimer.timerMessage.text = 
                    LanguageManager.getInstance().registerTag("_roundNumber", 
                        gameObjectsContainer.infoScreen.bombTimer.timerMessage, "text", "%num%","" + 
                        GameData.instance.currentRound).replace("%total%",GameData.instance.round);
            }
            
            Disease.dispose();
            
            EventListenerManager.setListenerTo(GameData.instance.topSprite, PlayerEvent.PLAYER_COMMAND, onPlayerCommand);
            GameData.instance.currentMap.initDeadlyBlocks();
            GameSys.startPingRequestTimer();
            SoundClass.addMusic( "music", "bg1", 999 );
            GameSys.paused = false;
            GameSys.onReadyScreen = false;
            Person.playersReady();
            Person.resetRoundKillScores();
            Person.startLatencyCheck();
            
            toggleMainClockVisible();
            GameSys.updatePanels();
            if (gameObjectsContainer.lostFocusScreen != null && !SmartFoxClientSingleton.getInstance().smartFoxClient.myself.isSpectatorInRoom(SmartFoxClientSingleton.getInstance().smartFoxClient.gameRoom))
            {
                gameObjectsContainer.lostFocusScreen.page.visible = true;
            }
            if(!SmartFoxClientSingleton.getInstance().smartFoxClient.myself.isSpectatorInRoom(SmartFoxClientSingleton.getInstance().smartFoxClient.gameRoom) && ConfigController.getInstance().gameTestingMode)
            {
                EventListenerManager.removelistenerFrom(GameData.instance.gameBox, MouseEvent.CLICK, playerIsBack);
                SmartFoxClientSingleton.getInstance().smartFoxClient.sendExtensionRequestToGameRoom("setActive", null);
                gameObjectsContainer.warningMessage.visible = false;
            }
            
            if(!SmartFoxClientSingleton.getInstance().smartFoxClient.myself.isSpectator)
            {
                GameData.instance.gameBox.visible = true;
            }
            
            GameData.instance.gameObjectsContainer.inRoundCommunicationBar.setUpRound(GameData.instance.currentRound + 1, GameData.instance.round);
        }
        
        private function onServerShutdonw(params:SFSObject):void
        {
            gameObjectsContainer.onServerShutdown();
        }
        
        private function onWarning(params:SFSObject):void
        {
            if (gameObjectsContainer.lostFocusScreen != null){
                gameObjectsContainer.lostFocusScreen.page.visible = false;
            }
            gameObjectsContainer.warningMessage.visible = true;
            gameObjectsContainer.warningMessage.countDownMessage.text = LanguageManager.getInstance().getAndReplaceText("_backToLobbyCount", "%num%", "" + gameObjectsContainer.warningCounter);
            EventListenerManager.setListenerTo(GameData.instance.gameBox, MouseEvent.CLICK, playerIsBack);
        }
        
        private function onCancelRanking(params:SFSObject):void
        {
            gameObjectsContainer.onCancelRanking();
        }
        
        private function onDeadlyBlockShadow(params:SFSObject):void
        {
            gameObjectsContainer.onDeadlyBlockShadow(params);
        }
        
        private function onDeadlyBlockSettle(params:SFSObject):void
        {
            gameObjectsContainer.onDeadlyBlockSettle(params);
        }
        
        private function onPositionSwitch(params:SFSObject):void
        {
            gameObjectsContainer.onPositionSwitch(params);
        }
        
        private function onBombSkin(params:SFSObject):void
        {
            gameObjectsContainer.onBombSkin(params);
        }
        
        private function playerIsBack(e:MouseEvent):void
        {
            if(!SmartFoxClientSingleton.getInstance().smartFoxClient.myself.isSpectatorInRoom(SmartFoxClientSingleton.getInstance().smartFoxClient.gameRoom))
            {
                SmartFoxClientSingleton.getInstance().smartFoxClient.sendExtensionRequestToGameRoom("setActive", null);
                gameObjectsContainer.warningMessage.visible = false;
            }
        }
        
        private function onTimeTick(params:SFSObject):void
        {
            if (gameObjectsContainer.warningMessage.visible)
            {
                if (gameObjectsContainer.warningCounter > 0)
                {
                    gameObjectsContainer.warningCounter --;
                    gameObjectsContainer.warningMessage.countDownMessage.text = LanguageManager.getInstance().getAndReplaceText("_backToLobbyCount", "%num%", "" + gameObjectsContainer.warningCounter);
                } 
                else 
                {
                    //HoneyTracksHelper.trackFeatureUsage(LocalUser.getInstance().registered, SmartFoxClientSingleton.getInstance().smartFoxClient.myself.isSpectator, HoneyTrackConstants.TRACKERNAME_GAME_LEFT, HoneyTrackConstants.CATEGORY_KICKED_FOR_IDLE);
                    gameObjectsContainer.warningCounter = 10;
                    gameObjectsContainer.warningMessage.visible = false;
                }
            }
            
            GameData.instance.currentTick = params.getInt("counter");
            
            var allDiseases:ISFSArray = params.getSFSArray("disa") ;
            
            if(allDiseases != null && allDiseases.size() > 0)
            {
                
                var diseaseTimer:int;
                var diseaseId:int;
                var diseaseObject:SFSObject;
                var disease:Disease;
                
                for (var j:uint = 0; j < allDiseases.size(); j++)
                {
                    
                    diseaseObject = allDiseases.getElementAt(j);
                    
                    diseaseId = diseaseObject.getInt(ServerMessages.DISEASE_ID);
                    diseaseTimer = diseaseObject.getInt(ServerMessages.DISEASE_TIMER);
                    disease = GameData.instance.diseaseManager.getDiseaseById(diseaseId);
                    
                    if (disease != null){
                        
                        disease.setTimerTick(diseaseTimer);  
                        
                        if(diseaseTimer == 0)
                        {
                            if(disease.overrideEndOfDisease == true)
                            {
                                disease.overrideEndOfDisease = false;
                            }
                            else
                            {
                                if ( disease!=null && disease.type != SkullTypes.DIARRHOEA)
                                {
                                    GameData.instance.diseaseManager.removeDisease(disease);
                                }
                            }
                        }
                        else if(diseaseTimer > disease.prevDiseaseTimer)
                        {
                            if(diseaseTimer > disease.maxDiseaseTimer)
                            {
                                disease.maxDiseaseTimer = diseaseTimer;
                            }
                            disease.overrideEndOfDisease = false;
                        }
                        disease.prevDiseaseTimer = diseaseTimer;
                    } 
                    else 
                    {
                        GameData.instance.diseaseManager.storeTimerTickInAdvance(diseaseId);
                    }
                }
            }
            
            if (params.getBool(ServerMessages.SUDDEN_DEATH_STARTED))
            {
                TweenMax.to(gameObjectsContainer.infoScreen.bombTimer, .5, {alpha:0});
                GameData.instance.onSuddenDeath = true;
                //GameData.instance.suddenDeathMessage.visible = true;
                //GameData.instance.suddenDeathMessage.gotoAndPlay('suddenDeath');
                GameData.instance.gameObjectsContainer.inRoundCommunicationBar.displaySuddenDeathMessage();
                SoundClass.addMusic( "music", "bgspeed" );
            }
            
            if(!GameData.instance.firstTick)
            {
                GameData.instance.firstTick = true;
                GameData.instance.currentLocalTick = GameData.instance.currentTick;
            }
            
            onTimerTick();
        }
        
        private function onTimerTick():void
        {
            GameData.instance.currentLocalTick++;
            if(GameData.instance.currentLocalTick > GameData.instance.time)
            {
                for each(var currentPerson:Person in GameData.instance.playerArr)
                {
                    if(!currentPerson.fire){
                        currentPerson.showDir("stand");
                    }
                }
            }
            else if(((GameData.instance.time) - GameData.instance.currentLocalTick) == END_RESULTS_SCREEN_TIME)
            {
                SoundClass.addMusic( "sound", "sfx_hurryup" );
                gameObjectsContainer.infoScreen.bombTimer.timeTxt.text = StringHelper.timeToClock((GameData.instance.time) - GameData.instance.currentLocalTick -1);
                gameObjectsContainer.markOnClock(GameData.instance.currentLocalTick);
            }
            else if(((GameData.instance.time) - GameData.instance.currentLocalTick) == 10)
            {
                SoundClass.addMusic( "sound", "sfx_clocktick" );
            }
            else if(((GameData.instance.time) - GameData.instance.currentLocalTick) == 0)
            {
                SoundClass.addMusic( "sound", "sfx_roundover" );
                if(!GameData.instance.suddenDeath)
                {
                    gameObjectsContainer.timeOutMessage.visible = true;
                    gameObjectsContainer.timeOutMessage.alpha = 1;
                    TweenMax.to(gameObjectsContainer.timeOutMessage, 0, {delay:3, alpha:0});
                    TweenMax.to(gameObjectsContainer.timeOutMessage, 0, {delay:3, visible:false});
                }
                gameObjectsContainer.infoScreen.bombTimer.timeTxt.text = StringHelper.timeToClock(0);
                gameObjectsContainer.markOnClock(0);
            }
            
            gameObjectsContainer.infoScreen.bombTimer.timeTxt.text = StringHelper.timeToClock((GameData.instance.time) - GameData.instance.currentLocalTick);
            gameObjectsContainer.markOnClock(GameData.instance.currentLocalTick);
            
            if(GameData.instance.time - GameData.instance.currentLocalTick >= 0)
            {
                GameData.instance.gameObjectsContainer.inRoundCommunicationBar.setUpClockTime(StringHelper.timeToClock((GameData.instance.time) - GameData.instance.currentLocalTick));
            }
        }
        
        public function onPlayerCommand(e:PlayerEvent):void
        {
            gameObjectsContainer.warningMessage.visible = false;
            gameObjectsContainer.warningCounter = 10;
            EventListenerManager.removelistenerFrom(GameData.instance.topSprite, PlayerEvent.PLAYER_COMMAND, onPlayerCommand);
        }
        
        public function toggleMainClockVisible(on:Boolean = true):void
        {
            if (on)
            {
                //gameObjectsContainer.infoScreen.bombTimer.visible = true;
                gameObjectsContainer.infoScreen.bombTimer.visible = false;
                gameObjectsContainer.infoScreen.bombTimer.alpha = 0;
                TweenMax.to(gameObjectsContainer.infoScreen.bombTimer, .5, {alpha:1});
            } 
            else 
            {
                gameObjectsContainer.infoScreen.bombTimer.visible = false;
            }
        }
        
        override public function dispose(params:SFSObject):void
        {
            toggleMainClockVisible(false);
            GameInterfaceManager.getInstance().hideDiseaseMessage();
        }
    }
}