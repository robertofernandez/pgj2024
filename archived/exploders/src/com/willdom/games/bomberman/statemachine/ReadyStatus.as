package com.willdom.games.bomberman.statemachine
{
    import com.gq.moveobject.DeadlyBlock;
    import com.gq.moveobject.Person;
    import com.gq.system.GameData;
    import com.gq.system.GameSys;
    import com.gq.system.SoundClass;
    import com.gq.ui.InGameUserListManager;
    import com.gq.ui.ReadyScreen;
    import com.smartfoxserver.v2.entities.data.ISFSArray;
    import com.smartfoxserver.v2.entities.data.ISFSObject;
    import com.smartfoxserver.v2.entities.data.SFSObject;
    import com.willdom.games.bomberman.communication.SmartFoxClientSingleton;
    import com.willdom.games.bomberman.config.GameConfigManager;
    import com.willdom.games.bomberman.consts.ServerMessages;
    import com.willdom.games.bomberman.gameobjects.GameInterfaceManager;
    import com.willdom.games.bomberman.gameobjects.GameObjectsContainer;
    import com.willdom.games.bomberman.position.maps.SfsBasedMapDescription;
    import com.willdom.games.explodersmmo.shared.consts.SharedVars;
    import com.willdom.games.explodersmmo.shared.helpers.StringHelper;
    import com.willdom.games.explodersmmo.shared.model.CustomLogger;
    import com.willdom.util.helpers.EventListenerManager;
    
    import flash.events.Event;
    import flash.events.TimerEvent;
    import flash.geom.Point;
    import flash.utils.Timer;
    
    public class ReadyStatus extends BasicStatusWithEventHandling
    {
        private var readyTimer:Timer;
        private var readyScreen:ReadyScreen;
        private var gameObjectsContainer:GameObjectsContainer;
        private var _initialized:Boolean = false;
        
        public function ReadyStatus(gameObjectsContainer:GameObjectsContainer)
        {
            this.gameObjectsContainer = gameObjectsContainer;
            
            readyTimer = new Timer(1000, 2);
        }
        
        override public function init(params:SFSObject):void
        {
            EventListenerManager.setListenerTo(readyTimer, TimerEvent.TIMER, onReadyTimerTick, false, 0, true);
            
            if(params.getInt("rnm") == 1)
            {
                var mapDescription:SfsBasedMapDescription = new SfsBasedMapDescription(params.getUtfString("mapName"),params.getSFSArray("mapDescription"));
                GameSys.updateBuildParams(mapDescription);
                GameSys.Build();
            }
            GameInterfaceManager.getInstance().toggleTitleScreenTitlePosition(false);
            
            var playersPositionsMap:Object = new Object();
            var playersPositions:ISFSArray = params.getSFSArray("ppos");
            var playerName:String;
            
            for(var j:int = 0; j < playersPositions.size(); j++)
            {
                var playerPosition:ISFSObject = playersPositions.getSFSObject(j);
                if(GameData.DEBUG_MODE)
                {
                    trace(playerPosition.getDump());
                }
                playerName = playerPosition.getUtfString("pname");
                playersPositionsMap[playerName] = new Point(playerPosition.getInt("x"), playerPosition.getInt("y"));
            }
            if(SmartFoxClientSingleton.getInstance().smartFoxClient.myself.isSpectatorInRoom(SmartFoxClientSingleton.getInstance().smartFoxClient.gameRoom))
            {
                if(GameData.instance.gameSync)
                {
                    GameConfigManager.getInstance().extendedContainer = false;   
                }else
                {
                    GameData.instance.syncExtendedContainer = false;   
                }
            }
            else
            {
                
                GameConfigManager.getInstance().extendedContainer = false;
            }
            
            
            if(params.getInt("rnm") == 1)
            {
                CustomLogger.getInstance().log("[ReadyStatus] game start (building map)");
                var array:ISFSArray = params.getSFSArray("pairs");
                var playerData:ISFSObject;
                var index:int;
                var selectedPlayer:int;
                
                for(var i:uint=0;i<array.size();i++)
                {
                    playerData = array.getSFSObject(i);
                    playerName = playerData.getUtfString("name");
                    index =  GameData.instance.playerNames.indexOf(playerName);
                    if (index > -1)
                    {
                        GameData.instance.userIds[playerName] = playerData.getInt("pid");
                        
                        selectedPlayer = playerData.getInt("avid");
                        if(SharedVars.characterReplacements[selectedPlayer] != null)
                        {
                            selectedPlayer = int(SharedVars.characterReplacements[selectedPlayer]);
                        }
                        GameData.instance.playerInforArr[index][1] = selectedPlayer;
                        InGameUserListManager.getInstance().onCharacterSelected( playerData.getInt("pid"), playerData.getInt("avid"));
                    }
                }

                GameSys.GameStart(playersPositionsMap);
                gameObjectsContainer.startInfoScreen();
            }
            else
            {
                if(GameData.instance.currentRound < GameData.instance.round && GameData.instance.playerNames.length > 1)
                {
                    readyTimer.reset();
                    readyTimer.start();
                }
                
                onGameStarted(playersPositionsMap);
            }
            DeadlyBlock.eraseDeadlyBlocks();
            GameData.instance.diseaseManager.removeAllDiseases();
            GameSys.onReadyScreen = true;
            Person.toggleVisible(true);
            GameData.instance.endingState = false;
            
            InGameUserListManager.getInstance().onRoundStart();
            GameData.instance.gameObjectsContainer.inRoundEquipmentBar.visible = true;
            GameData.instance.gameObjectsContainer.inRoundCommunicationBar.visible = true;
            GameData.instance.gameObjectsContainer.inRoundCommunicationBar.resetComponent(StringHelper.timeToClock(GameData.instance.time), GameData.instance.currentRound + 1, GameData.instance.round);
            GameData.instance.gameObjectsContainer.inRoundCommunicationBar.displayReadyGoMessage();
        }
        
        private function onReadyTimerTick(e:TimerEvent):void
        {
            switch(readyTimer.currentCount)
            {
                case 2:
                    var sfsObject:SFSObject = new SFSObject();
                    sfsObject.putInt(ServerMessages.ROUND_NUMBER,GameData.instance.currentRound);
                    SmartFoxClientSingleton.getInstance().smartFoxClient.sendExtensionRequestToGameRoom("roundRestart", sfsObject);
                    break;
            }
        }
        
        private function onGoMessage(e:Event):void
        {
            if (readyScreen != null && readyScreen.page != null && readyScreen.page.goMessage != null)
            {
                LanguageManager.getInstance().registerTag("_gameRoundGoMessage", readyScreen.page.goMessage, "text");
                readyScreen.page.removeEventListener("goMessage", onGoMessage);
                if ( !SoundClass.deactivateSound )
                {                
                    SoundClass.addMusic("sound", "stinger_go", 1);
                }
            }
        }
        
        private function onGameStarted(playersPositions:Object, evt:TimerEvent=null):void
        {
            if(GameData.instance.currentRound < GameData.instance.round && GameData.instance.playerNames.length > 1) 
            {
                CustomLogger.getInstance().log("Starting game with players positions: " + playersPositions.toString());
                GameData.instance.gameObjectsContainer.markOnClock(0);
                GameData.instance.gameObjectsContainer.infoScreen.bombTimer.timeTxt.text = StringHelper.timeToClock((GameData.instance.time));
                GameData.instance.positionManager.pause();
                GameSys.paused = true;
                GameData.instance.positionManager.restoreMap();
                
                if(GameData.instance.controls != null)
                {
                    if(!GameData.instance.controls.removed)
                    {
                        GameData.instance.controls.cleanInputArray();
                    }
                }
                var playerIndex:int;
                for(playerIndex = 0; playerIndex < GameData.instance.playerNames.length; playerIndex++)
                {
                    var person:Person = GameData.instance.playerArr[playerIndex] as Person;
                    if(person != null)
                    {
                        var respawnPoint:Point = playersPositions[person.myName] as Point;
                        if(respawnPoint != null)
                        {
                            person.respawn(respawnPoint);                     
                        }
                    }
                }
                GameData.instance.endingState = false;
                GameData.instance.positionManager.resume();
                GameData.instance.alreadyWinLose = false;
                GameData.instance.roundOver = false;
                GameData.instance.restartPlayers = 0;
                GameData.instance.firstTick = false;
                GameData.instance.currentLocalTick = 0;
                GameData.instance.currentTick = 0;
                GameSys.resetPlayerAvatars();
                if(GameData.instance.controls != null)
                {
                    GameData.instance.controls.activateListeners();
                }
                if(GameData.instance.gameObjectsContainer.infoScreen != null)
                {
                    GameData.instance.gameObjectsContainer.infoScreen.playerLagInfo.visible = false;
                    GameData.instance.gameObjectsContainer.infoScreen.bombTimer.timerMessage.text = LanguageManager.getInstance().getAndReplaceText("_roundNumber","%num%",""+GameData.instance.currentRound).replace("%total%",GameData.instance.round);
                }
                
                GameSys.paused = false;
            }
        }
        
        override public function dispose(params:SFSObject):void
        {
            readyTimer.reset();
        }
    }
}