package com.gq.system
{
    import com.gq.effects.*;
    import com.gq.moveobject.*;
    import com.gq.ui.*;
    import com.greensock.TweenMax;
    import com.smartfoxserver.v2.core.SFSEvent;
    import com.smartfoxserver.v2.entities.SFSUser;
    import com.smartfoxserver.v2.entities.User;
    import com.smartfoxserver.v2.entities.data.ISFSObject;
    import com.smartfoxserver.v2.entities.data.SFSObject;
    import com.smartfoxserver.v2.entities.variables.UserVariable;
    import com.willdom.games.bomberman.communication.SmartFoxClientSingleton;
    import com.willdom.games.bomberman.config.GameConfigManager;
    import com.willdom.games.bomberman.consts.ServerMessages;
    import com.willdom.games.bomberman.controllers.ConfigController;
    import com.willdom.games.bomberman.events.MessageEvent;
    import com.willdom.games.bomberman.events.PersonEvent;
    import com.willdom.games.bomberman.events.UserEvent;
    import com.willdom.games.bomberman.gameobjects.GameInterfaceManager;
    import com.willdom.games.bomberman.gameobjects.PersonScore;
    import com.willdom.games.bomberman.gameobjects.Score;
    import com.willdom.games.bomberman.gameobjects.items.JoiningPlayer;
    import com.willdom.games.bomberman.position.maps.MapDescription;
    import com.willdom.games.bomberman.position.maps.SfsBasedMapDescription;
    import com.willdom.games.bomberman.statemachine.StatusManager;
    import com.willdom.games.bomberman.user.UserLocalProperties;
    import com.willdom.games.explodersmmo.shared.consts.SharedVars;
    import com.willdom.games.explodersmmo.shared.events.game.GameEndedEvent;
    import com.willdom.games.explodersmmo.shared.model.CustomLogger;
    import com.willdom.games.explodersmmo.shared.model.LocalUser;
    import com.willdom.games.explodersmmo.shared.model.SoundSettings;
    //import com.willdom.games.explodersmmo.shared.tracker.HoneyTrackConstants;
    //import com.willdom.games.explodersmmo.shared.tracker.HoneyTracksHelper;
    import com.willdom.tween.Tween;
    import com.willdom.util.helpers.EventListenerManager;
    
    import configuration.StageModes;
    
    import flash.display.*;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.events.TimerEvent;
    import flash.filters.ColorMatrixFilter;
    import flash.filters.GlowFilter;
    import flash.geom.ColorTransform;
    import flash.geom.Point;
    import flash.media.SoundMixer;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFormat;
    import flash.utils.Timer;
    import flash.utils.getTimer;
            
    public class GameSys
    {
        static private const SELECTION_PANEL_MAX_ITEMS:uint = 9;
        
        static public var counter:uint;
        static private var clockTween:Tween;
        static private var noPlayersTimer:Timer;
        static private var pingRequest:Timer;
        static private var mode:String = "";
        static private var playersQty:uint = 21;
        static private var lastPosition:uint = 0;
        
        static public var onReadyScreen:Boolean = false;
        static public var paused:Boolean;
        static public var gameSource:String;
        
        static private var playerListComponentItems:Array;
        static public var skillpointsInfoAvailable:Boolean = true;
        
        static private var tickDisplayRunning:Boolean = false;
        
        static private var currentClockTween:TweenMax;
        static private var currentNeedleTween:TweenMax;
        
        static public var playersLeftDuringCharacterSelect:Array = new Array();
        
        static private var seed:int;
        static private var mapDescription:SfsBasedMapDescription;

        static public function createGame ():void
        {
            GameData.instance.gameType = "play";
            EventListenerManager.setListenerTo(SmartFoxClientSingleton.getInstance().smartFoxClient, UserEvent.ENTER_ROOM, onUserEnterRoom,false,0,true);
            EventListenerManager.setListenerTo(SmartFoxClientSingleton.getInstance().smartFoxClient, UserEvent.EXIT_ROOM, onExitRoomEvent,false,0,true);
            EventListenerManager.setListenerTo(SmartFoxClientSingleton.getInstance().smartFoxClient, SFSEvent.CONNECTION_LOST, onConnectionLostEvent,false,0,true);
            GameData.instance.firstTick = false;
            paused = false;
            playerListComponentItems = new Array();
        }
                
        static public function Build():void
        {
            GameData.instance.serverMessagesHandler.initialize();
            GameData.instance.initMapData(mapDescription);
            GameData.instance.gameSeed = seed;
            generateMap(seed, mapDescription);
            GameData.instance.diseaseManager.startTingling();

            GameInterfaceManager.getInstance().build();
            JoiningPlayer.stopRecord();
            EventListenerManager.setListenerTo(GameData.instance.Scen.stage, Event.ENTER_FRAME, enterframe );
        }
        
        static public function buildStage():void
        {        
            creatObject("Scen", "topSprite" );
            creatObject("Scen", "bottomSprite" );
            creatObject("topSprite", "gameContainer" );
            creatObject("Scen", "roundWindow" );
            creatObject("Scen", "totalWindow" );
            creatObject("Scen", "infoWindow" );
            creatObject("Scen", "playerSelectionWindow" );
            creatObject("Scen", "noPlayersWindow" );
            GameData.instance.topSprite.x = 75;
            GameData.instance.topSprite.y = 138;
            //GameData.instance.topSprite.y = 154;
            creatObject("gameContainer", "bgContainer" );
            creatObject("gameContainer", "suddenDeathSprite" );
            creatObject("gameContainer", "effectContainer" );
            creatObject("gameContainer", "moveObjectContainer" );
            creatObject("moveObjectContainer", "bottomObjectContainer" );
            creatObject("moveObjectContainer", "personContainer" );
            creatObject("moveObjectContainer", "topObjectContainer" );

            for( var i:uint = 0; i < 16; i++ )
            {
                creatObject("personContainer", "Container_" + String(i));
            }
            GameData.instance.suddenDeathMessage = new SuddenDeathMessage;
            GameData.instance.suddenDeathMessage.x = 242;
            GameData.instance.suddenDeathMessage.y = -215;
            GameData.instance.suddenDeathMessage.gotoAndStop(1);
            GameData.instance.suddenDeathMessage.visible = false;
            GameData.instance.suddenDeathSprite.addChild(GameData.instance.suddenDeathMessage);
            var topSprite:Sprite = GameData.instance.topSprite;
            var newMask:Sprite = new Sprite();
            newMask.graphics.beginFill(0x000000);
            newMask.graphics.drawRect(-66,-113,760,660);
            newMask.graphics.endFill();
            GameData.instance.topObjectContainer.addChild(newMask);
            GameData.instance.topObjectContainer.mask = newMask;
            GameData.instance.gameObjectsContainer.gameBuild();
        }
        
        static public function creatObject ( who:String, which:String ):void
        {
            GameData.instance[which] = new Sprite();
            GameData.instance[which].mouseEnabled = false;
            GameData.instance[who].addChild (GameData.instance[which]);
        }
        
        static public function initGameVisualResources():void
        {
            GameData.instance.current_score = GameData.instance.total_score;
            GameData.instance.creater = new MonsterCreater();
            clockTween = new Tween();
            
            noPlayersTimer = new Timer(1000);
            
            buildStage();
            
            InitialInterface();
            
            if(GameData.instance.STAGE_MODE == StageModes.PENGUIN)
            {
                SoundClass.addMusic( "music", "bg2", 999 );
            }
            else
            {
                SoundClass.addMusic( "music", "roundresults", 999 );
            }
        }
        
        static private function generateMap(seed:int, mapDescription:MapDescription):void
        {
            createGameMap(seed, mapDescription);
        }
        
        static private function InitialInterface ():void
        {
            EventListenerManager.setListenerTo(GameData.instance.serverMessagesHandler, SFSEvent.EXTENSION_RESPONSE, onExtensionResponse);
        }
        
        static public function GameStart(playersPositionsMap:Object):void
        {
            GameData.instance.Scen.stage.focus = GameData.instance.gameBox;
            GameSys.createPlayers(playersPositionsMap);
            GameData.instance.isPlay = true;
            var myId:Number=GameData.instance.myId;
            createPlayersList();
            GameData.instance.gameStarted = true;
            if(GameData.DEBUG_MODE)
            {
                trace("[com.gq.system.GameSys] at moment of creation of controls, players array contains: " + GameData.instance.playerNames.length);
            }
            GameData.instance.firstTick = false;
            
            //----------------------- Fin de rediseño---------------------------------------------------
            if (!SmartFoxClientSingleton.getInstance().smartFoxClient.myself.isSpectatorInRoom(SmartFoxClientSingleton.getInstance().smartFoxClient.gameRoom))
            {
                var person:Person = Person.getPersonById(GameData.instance.myId);
                var myInitialPoint:Point = playersPositionsMap[person.myName] as Point;
                if(GameData.DEBUG_MODE)
                {
                    trace("Initializing " + person.myName + " at <" + myInitialPoint.x + ", " + myInitialPoint.y + ">");
                }
                var localControlSet:LocalWalkControlSet = new LocalWalkControlSet(person);
                localControlSet.setInitialTilePosition(myInitialPoint);
                person.confirmedPosition = new Point();
                person.confirmedPosition.x = myInitialPoint.x;
                person.confirmedPosition.y = myInitialPoint.y;
                
                GameData.instance.walkControls[GameData.instance.myId] = localControlSet;
            }
            for(var playerIndex:int=0; playerIndex < GameData.instance.playerInforArr.length; playerIndex++){
                if(SmartFoxClientSingleton.getInstance().smartFoxClient.myself.isSpectatorInRoom(SmartFoxClientSingleton.getInstance().smartFoxClient.gameRoom) || GameData.instance.myName != (Person.getPersonById(playerIndex) as Person).myName)
                {
                    // TODO use another var cause overriding is obscure
                    person = Person.getPersonById(playerIndex);
                    var playerInitialPoint:Point = playersPositionsMap[person.myName] as Point;
                    
                    if(playerInitialPoint != null){
                        if(GameData.DEBUG_MODE)
                        {
                            trace("Initializin " + person.myName + " at <" + playerInitialPoint.x + ", " + playerInitialPoint.y + ">");
                        }
                        var initialX:Number = playerInitialPoint.x; 
                        var initialY:Number = playerInitialPoint.y;
                        if (person != null){
                            var remoteControlSet:RemoteControlSet = new RemoteControlSet(person);
                            remoteControlSet.setInitialTilePosition(new Point(initialX, initialY));
                            person.confirmedPosition = new Point();
                            person.confirmedPosition.x = initialX;
                            person.confirmedPosition.y = initialY;
                            GameData.instance.walkControls[playerIndex] = remoteControlSet;
                            if (SmartFoxClientSingleton.getInstance().smartFoxClient.gameRoom.getUserByName(person.myName) == null)
                            {
                                person.rematchAccepted = false;
                            }
                        }
                    }else{
                        person._this.visible = false;
                    }
                }
            }
            
            if( !GameConfigManager.getInstance().showingChat)
            {
                GameData.instance.gameBox.stage.focus = null;
            }
            
            if (SmartFoxClientSingleton.getInstance().smartFoxClient.gameRoom.playerList.indexOf(SmartFoxClientSingleton.getInstance().smartFoxClient.myself) > -1)
            {
                var name:String = GameData.CHARACTER_NAMES[(Person.getPersonByName(SmartFoxClientSingleton.getInstance().smartFoxClient.myself.name).myAvatar-1)];
            }
        }
        
        protected static function onExtensionResponse(e:SFSEvent):void
        {
            var playerId:uint;
            var params:SFSObject = e.params.params as SFSObject;
            var i:int = 0;
            
            if(e.params.cmd == ServerMessages.KICKED_FOR_IDLING)
            {                
                GameInterfaceManager.getInstance().showSubmessage(LanguageManager.getInstance().getAndReplaceText("_kickForIdling", "%player%", params.getUtfString(ServerMessages.PLAYER_NAME)), PersonScore.getPersonScoreByName(params.getUtfString(ServerMessages.PLAYER_NAME)).avatar);
            }
            else if (e.params.cmd == MessageEvent.GAME_REMATCH_STARTED)
            {
                var document:DisplayObjectContainer = GameData.instance.Scen;
                var ev:MessageEvent = new MessageEvent(MessageEvent.GAME_RESTART, true);
                
                //HoneyTracksHelper.trackFeatureUsage(LocalUser.getInstance().registered, SmartFoxClientSingleton.getInstance().smartFoxClient.myself.isSpectator, HoneyTrackConstants.TRACKERNAME_GAME_ENTERED, HoneyTrackConstants.SUBCATEGORY_REMATCH);
                
                document.dispatchEvent(ev);
                GameSys.removeStage();
                document = null;
            }
            else if (e.params.cmd == ServerMessages.ROUND_TRIP_TIME_MEASSURE && SmartFoxClientSingleton.getInstance().smartFoxClient.gameRoom != null)
            {
                var playerName:String = params.getUtfString("player");
                var thisPerson:Person = Person.getPersonByName(playerName);
                var roundTripValue:int;
                
                if (thisPerson != null)
                {
                    if (thisPerson.latency > 0)
                    {
                        roundTripValue = Math.floor(thisPerson.latency * GameData.ROUND_TRIP_ALPHA + (1 - GameData.ROUND_TRIP_ALPHA) * params.getInt("ping"));
                    } 
                    else 
                    {
                        roundTripValue = params.getInt("ping");
                        
                    }
                    if (playerName == GameData.instance.myName){
                        GameData.instance.latencyValue = getTimer() - params.getInt("latencyTime");
                    }
                    thisPerson.latency = roundTripValue;
                    updatePlayerLatencyStatus(thisPerson, roundTripValue);
                    
                    InGameUserListManager.getInstance().updatePingIcon(thisPerson.userId, roundTripValue);
                }
                else if (SmartFoxClientSingleton.getInstance().smartFoxClient.gameRoom.getUserByName(playerName)!= null && SmartFoxClientSingleton.getInstance().smartFoxClient.gameRoom.getUserByName(playerName).isSpectatorInRoom(SmartFoxClientSingleton.getInstance().smartFoxClient.gameRoom)) 
                {
                   
                    if ((SmartFoxClientSingleton.getInstance().smartFoxClient.gameRoom.getUserByName(playerName).properties as UserLocalProperties).ping > 0)
                    {
                        roundTripValue = Math.floor((SmartFoxClientSingleton.getInstance().smartFoxClient.gameRoom.getUserByName(playerName).properties as UserLocalProperties).ping * GameData.ROUND_TRIP_ALPHA + (1 - GameData.ROUND_TRIP_ALPHA) * params.getInt("ping"));
                    } 
                    else 
                    {
                        roundTripValue = params.getInt("ping");
                    }
                    if (playerName == GameData.instance.myName){
                        GameData.instance.latencyValue = getTimer() - params.getInt("latencyTime");
                    }
                    roundTripValue = Math.floor((SmartFoxClientSingleton.getInstance().smartFoxClient.gameRoom.getUserByName(playerName).properties as UserLocalProperties).ping * GameData.ROUND_TRIP_ALPHA + (1 - GameData.ROUND_TRIP_ALPHA) * params.getInt("ping"));
                    (SmartFoxClientSingleton.getInstance().smartFoxClient.gameRoom.getUserByName(playerName).properties as UserLocalProperties).ping = roundTripValue;        
                }
            }
            else if (e.params.cmd == ServerMessages.SCORE_UPDATE)
            {
                checkPlayersListForcedInitCondition();
                var scoreObj:ISFSObject = params.getSFSObject(ServerMessages.SCORE_OBJECT);
                
                if(!GameData.instance.gameStarted && GameData.instance.leaveScoreReduction==0)
                {
                    var totalScoreObj:ISFSObject = scoreObj.getSFSObject(ServerMessages.MATCH_SCORE_INFO_PARAM);
                    GameData.instance.leaveScoreReduction = totalScoreObj.getInt(ServerMessages.LEAVE_PARAM);
                }
                var personScore:PersonScore = PersonScore.getPersonScoreByName(params.getUtfString(ServerMessages.PLAYER_NAME));
                setRoundAndTotalScore(scoreObj,personScore);
            }
            else if (e.params.cmd == ServerMessages.USER_LEAVE)
            {
                if (Person.getPersonByName(params.getUtfString("pname")) != null)
                {
                    onUserExitRoom(params.getUtfString("pname"));
                }
                
                InGameUserListManager.getInstance().onUserExitRoom(params.getInt("pid"))
            }
            else if (e.params.cmd == "inGameMessage")
            {
                var sender:String = params.getUtfString("sender");
                var message:String = params.getUtfString("message");
                var avatar:String = params.getUtfString("avatar");
                InGameChatManager.getInstance().addMessage(sender, message, avatar);
            }
        }
        
        public static function setRoundAndTotalScore(scoreObj:ISFSObject,personScore:PersonScore):void
        {
            var roundScoreObj:ISFSObject = scoreObj.getSFSObject(ServerMessages.ROUND_SCORE_INFO_PARAM);
            var score:Score = new Score(roundScoreObj,scoreObj.getBool(ServerMessages.ALIVE));
            
            if(personScore!=null)
            {
                personScore.roundKills = roundScoreObj.getInt( ServerMessages.NUMBER_OF_KILLS_PARAM );
                personScore.totalKills += roundScoreObj.getInt( ServerMessages.NUMBER_OF_KILLS_PARAM );
                personScore.deathPosition = roundScoreObj.getInt(ServerMessages.POSITION_PARAM);
                personScore.currentScore = score;
            }
            var totalScoreObj:ISFSObject = scoreObj.getSFSObject(ServerMessages.MATCH_SCORE_INFO_PARAM);
            var totalScore:Score = new Score(totalScoreObj,scoreObj.getBool(ServerMessages.ALIVE));
            if(personScore!=null)
            {
                personScore.totalScore = totalScore;
                updatePanels();
            }
        }
        
        public static function onSoundBtnClick(e:MouseEvent):void
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
        
        public static function forceQuit(disconnected:Boolean = false):void
        {
            GameSys.removeStage();
            if(disconnected)
            {
				//wouterB: Remove Honeytracks
                //HoneyTracksHelper.trackFeatureUsage(LocalUser.getInstance().registered, SmartFoxClientSingleton.getInstance().smartFoxClient.myself.isSpectator, HoneyTrackConstants.TRACKERNAME_ERROR, HoneyTrackConstants.CATEGORY_DISCONNECTED_FROM_SERVER);
            }
            else
            {
                var e:GameEndedEvent = new GameEndedEvent(GameEndedEvent.GAME_ENDED, false, true);
                GameData.instance.Scen.dispatchEvent(e);
            }
            disposeAllChildrenAndRemove(GameData.instance.Scen);
            GameData.instance.Scen = null;
        }
        
        public static function addPowerUp(powerUp:String, playerID:String):void
        {
            if(GameData.instance.myName != (playerID)) return;
            switch(powerUp)
            {
                case "specialBomb":
                    GameData.instance.gameObjectsContainer.infoScreen.powerUpBar.container.power3.gotoAndStop("normal");
                    GameData.instance.gameObjectsContainer.inRoundEquipmentBar.updateKickIcon();
                    break;
                case "bouncingBomb":
                    GameData.instance.gameObjectsContainer.infoScreen.powerUpBar.container.power6.gotoAndStop("bouncing");
                    GameData.instance.gameObjectsContainer.inRoundEquipmentBar.updateBombIcon("bouncing");
                    break;
                case "spikeBomb":
                    GameData.instance.gameObjectsContainer.infoScreen.powerUpBar.container.power6.gotoAndStop("spike");
                    GameData.instance.gameObjectsContainer.inRoundEquipmentBar.updateBombIcon("spike");
                    break;
                case "bomb_change":
                    GameData.instance.gameObjectsContainer.infoScreen.powerUpBar.container.power5.gotoAndStop("normal");
                    GameData.instance.gameObjectsContainer.inRoundEquipmentBar.updateDisuiseIcon();
                    break;
                case "dangerBomb":
                    GameData.instance.gameObjectsContainer.infoScreen.powerUpBar.container.power6.gotoAndStop("danger");
                    GameData.instance.gameObjectsContainer.inRoundEquipmentBar.updateBombIcon("danger");
                    break;
                case "mine":
                    GameData.instance.gameObjectsContainer.infoScreen.powerUpBar.container.power6.gotoAndStop("faded");
                    GameData.instance.gameObjectsContainer.inRoundEquipmentBar.updateBombIcon("faded");
                    break;
                case "powerBomb":
                    GameData.instance.gameObjectsContainer.infoScreen.powerUpBar.container.power6.gotoAndStop("power");
                    GameData.instance.gameObjectsContainer.inRoundEquipmentBar.updateBombIcon("power");
                    break;
                case "updateBombNum":
                    if(GameData.instance.gameObjectsContainer.infoScreen == null) return;
                    if(Person.getPersonByName(playerID)!=null && Person.getPersonByName(playerID).maxBombsAllowed > 1)
                    {
                        GameData.instance.gameObjectsContainer.infoScreen.powerUpBar.container.power1.lvlMC.visible = true;
                        GameData.instance.gameObjectsContainer.infoScreen.powerUpBar.container.power1.lvlMC.txt.text = String(Person.getPersonByName(playerID).maxBombsAllowed);
                        GameData.instance.gameObjectsContainer.inRoundEquipmentBar.updateBombsAmount(Person.getPersonByName(playerID).maxBombsAllowed);
                    }
                    else if(Person.getPersonByName(playerID)!=null && Person.getPersonByName(playerID).maxBombsAllowed <= 1)
                    {
                        GameData.instance.gameObjectsContainer.infoScreen.powerUpBar.container.power1.lvlMC.visible = false;
                        GameData.instance.gameObjectsContainer.infoScreen.powerUpBar.container.power1.lvlMC.txt.text = String(Person.getPersonByName(playerID).maxBombsAllowed);
                        GameData.instance.gameObjectsContainer.inRoundEquipmentBar.updateBombsAmount(Person.getPersonByName(playerID).maxBombsAllowed);
                    }
                    break;
                case "updatePower":
                    if(GameData.instance.gameObjectsContainer.infoScreen == null) return;
                    if(Person.getPersonByName(playerID)!=null && Person.getPersonByName(playerID).power > 1)
                    {
                        GameData.instance.gameObjectsContainer.infoScreen.powerUpBar.container.power2.lvlMC.visible = true;
                        GameData.instance.gameObjectsContainer.infoScreen.powerUpBar.container.power2.lvlMC.txt.text = String(Person.getPersonByName(playerID).power);
                        GameData.instance.gameObjectsContainer.inRoundEquipmentBar.updateFirePowerAmount(Person.getPersonByName(playerID).power);
                    }
                    else if(Person.getPersonByName(playerID)!=null && Person.getPersonByName(playerID).power <= 1)
                    {
                        GameData.instance.gameObjectsContainer.infoScreen.powerUpBar.container.power2.lvlMC.visible = false;
                        GameData.instance.gameObjectsContainer.infoScreen.powerUpBar.container.power2.lvlMC.txt.text = String(Person.getPersonByName(playerID).power);
                        GameData.instance.gameObjectsContainer.inRoundEquipmentBar.updateFirePowerAmount(Person.getPersonByName(playerID).power);
                    }
                    break;
                case "updateSpeed":
                    if(GameData.instance.gameObjectsContainer.infoScreen == null) return;
                    if(Person.getPersonByName(playerID)!=null && Person.getPersonByName(playerID).speedAll > 7)
                    {
                        GameData.instance.gameObjectsContainer.infoScreen.powerUpBar.container.power4.lvlMC.visible = true;
                        GameData.instance.gameObjectsContainer.infoScreen.powerUpBar.container.power4.lvlMC.txt.text = String(Person.getPersonByName(playerID).speed-6);
                        GameData.instance.gameObjectsContainer.inRoundEquipmentBar.updateSpeedAmount(Person.getPersonByName(playerID).speed-6);
                    }
                    else if(Person.getPersonByName(playerID)!=null && Person.getPersonByName(playerID).speedAll <= 7)
                    {
                        GameData.instance.gameObjectsContainer.infoScreen.powerUpBar.container.power4.lvlMC.visible = false;
                        GameData.instance.gameObjectsContainer.infoScreen.powerUpBar.container.power4.lvlMC.txt.text = String(Person.getPersonByName(playerID).speed-6);
                        GameData.instance.gameObjectsContainer.inRoundEquipmentBar.updateSpeedAmount(Person.getPersonByName(playerID).speed-6);
                    }
                    break;
            }
        }
        
        static public function resetPowerUp():void
        {
            GameData.instance.gameObjectsContainer.infoScreen.powerUpBar.container.power1.lvlMC.txt.text = "1";
            GameData.instance.gameObjectsContainer.infoScreen.powerUpBar.container.power1.lvlMC.visible = false;
            GameData.instance.gameObjectsContainer.infoScreen.powerUpBar.container.power2.lvlMC.txt.text = "1";
            GameData.instance.gameObjectsContainer.infoScreen.powerUpBar.container.power2.lvlMC.visible = false;
            if( GameData.instance.STAGE_MODE == StageModes.HYPER ) 
            {
                GameData.instance.gameObjectsContainer.infoScreen.powerUpBar.container.power4.lvlMC.txt.text = "8";
                GameData.instance.gameObjectsContainer.infoScreen.powerUpBar.container.power4.lvlMC.visible = true;
            }
            else
            {
                GameData.instance.gameObjectsContainer.infoScreen.powerUpBar.container.power4.lvlMC.txt.text = "1";
                GameData.instance.gameObjectsContainer.infoScreen.powerUpBar.container.power4.lvlMC.visible = false;
            }            
            GameData.instance.gameObjectsContainer.infoScreen.powerUpBar.container.power3.gotoAndStop("faded");
            GameData.instance.gameObjectsContainer.infoScreen.powerUpBar.container.power5.gotoAndStop("faded");
            GameData.instance.gameObjectsContainer.infoScreen.powerUpBar.container.power6.gotoAndStop("faded");
            
            GameData.instance.gameObjectsContainer.inRoundEquipmentBar.resetPowerUps();
        }
        
        static public function resetPlayerAvatars():void
        {
            for(var i:int = 0; i < GameData.instance.playerNames.length; i++)
            {
                if(GameData.instance.infoScreenId[i] != null)
                {
                    var avatar:MovieClip = playerListComponentItems[i].character as MovieClip;
                    avatar.transform.colorTransform = new ColorTransform();
                }
            }    
        }
        
        static public function createGameMap(seed:int, mapDescription:MapDescription):void
        {
            GameData.instance.mapName = GameData.instance.STAGE_MODE;
            GameData.instance.currentMap = new Map(seed, mapDescription);
            var topMap:MovieClip = new TopMap();
            topMap.y=GameData.instance.upLine;
            topMap.gotoAndStop(GameData.instance.mapName);
            var lastLine:MovieClip = new BottomMc();
            lastLine.gotoAndStop(GameData.instance.mapName);
            lastLine.y=GameData.instance.upLine;
            lastLine.alpha = 0.65;
            
            GameData.instance.bgContainer.addChild(GameData.instance.currentMap.page );
            GameData.instance.topSprite.addChild(topMap);
            GameData.instance.Container_15.addChild( lastLine );
            
            GameData.instance.currentMap.page.gotoAndStop( GameData.instance.mapName );
            var mapFilter:GlowFilter = new GlowFilter(0x000000, 1, 30, 30, 1, 1, true);
            GameData.instance.topSprite.filters = [mapFilter];
        }

        static public function addEffects( who:Sprite, Name:String, index:String, _x:Number, _y:Number, _z:Number, _scaleX:int = 1, rot:Number = 0, colorMatrixFilter:ColorMatrixFilter = null, xOffset:int = 0, yOffset:int = 0):Effects
        {
            var tempClass:Class = GameTools.createClass( "com.gq.effects." + Name );
            var mc:Effects = new tempClass();
            GameTools.pushArr ( GameData.instance.actionArr, mc );
            if( who == GameData.instance.personContainer )
            {
                GameTools.pushArr ( GameData.instance.objectArr, mc );
                GameData.instance.idIndex ++;
                mc.myID = GameData.instance.idIndex;
            }
            
            mc.createEffect ( who, index, _x, _y, _z );
            mc._this.scaleX = _scaleX;
            if(colorMatrixFilter != null)
            {
                (mc._this as MovieClip).filters = [colorMatrixFilter];
            }
            mc._this.rotation = rot;
            mc._this.x += xOffset;
            mc._this.y += yOffset;
            return mc;
        }

        static private function enterframe( evt:Event ):void
        {
            if( !GameData.instance.isPausing )
            {
                updataEvent();
            }
            
            if (clockTween != null)
            {
                clockTween.update();
            }
        }

        static private function updataEvent():void
        {
            moveAction( GameData.instance.actionArr );
            removeAction( GameData.instance.removeArr );
            for each(var person:Person in Person.allPersons){
                if (person.outline != null && person.outline.mc.visible){
                    person.outline.updateOutlineVisual();
                }
                
            }
        }
        
        static public function triggerUpdataEvent():void
        {
            updataEvent();
        }
        
        static private function judgeIfAddInScreen( distance:Number ):void
        {
            GameData.instance.objInScreenArr = [];
            for( var i:int = GameData.instance.objectArr.length - 1; i >= 0 ; i-- )
            {
                var tempMc:* = GameData.instance.objectArr[i];
                if( GameTools.ifOutScreen( tempMc.myX, tempMc.myY + tempMc.myZ, distance ) )
                {
                    if( !tempMc.notAdd )
                    {
                        tempMc.removeMc();
                        GameTools.unPushArr( GameData.instance.actionArr, tempMc );
                    }
                }
                else
                {
                    GameTools.pushArr( GameData.instance.objInScreenArr, tempMc );
                    if( tempMc.notAdd )
                    {
                        tempMc.addMc();
                        GameTools.pushArr( GameData.instance.actionArr, tempMc );
                    }
                }
            }
        }
        
        static public function forceRemoveArray():void{
            removeAction(GameData.instance.removeArr);
        }
        
        static private function removeAction( arr:Array ):void
        {
            if(arr!=null){
                for( var i:int = arr.length - 1; i >= 0; i-- )
                {
                    arr[i].removeMe();
                    GameTools.unPushArr( arr, arr[i] );
                }
                arr = [];
            }
            
        }
        
        static private function moveAction( who:Array ):void
        {
            
            for( var i:uint = 0; who!= null && i < who.length; i++ )
            {
                who[i].updataEvent();
            }
        }
        
        static private function lastPlayerDisconnect():void
        {
            paused = true;
            if(GameData.instance.controls != null)
            {
                if(!GameData.instance.controls.removed)
                {
                    GameData.instance.controls.deactivateListeners();
                }
            }
            GameData.instance.positionManager.pause();
            GameData.instance.currentLocalTick = 0;
            GameData.instance.currentTick = 0;
            GameData.instance.alreadyWinLose = false;
        }

        static private function hasDuplicatedAvatar(id:int):Boolean
        {
            for(var i:uint=0;i<GameData.instance.playerInforArr.length;i++)
            {
                if(i!=id && GameData.instance.playerInforArr[i][1]==GameData.instance.playerInforArr[id][1]){
                    return true;
                }
            }
            return false;
        }
        
        static private function onUserEnterRoom(evt:UserEvent):void{
            if(evt.room == SmartFoxClientSingleton.getInstance().smartFoxClient.gameRoom)
            {
                if (JoiningPlayer.getJoiningPlayers() != null && GameData.instance.currentGameStatus == StatusManager.END_MATCH_STATUS)
                {
                    if (GameData.instance.trophies)
                    {
                        GameData.instance.gameObjectsContainer.resultsScreenContainer.fillTotalScreenTrophies(false, GameData.instance.resultsScrollCount);
                    } 
                    else
                    {
                        GameData.instance.gameObjectsContainer.resultsScreenContainer.fillTotalScreenScore(false, GameData.instance.resultsScrollCount);
                    }
                }
            }
        }
        
        static private function onExitRoomEvent(e:UserEvent):void
        {
            CustomLogger.getInstance().log("User exit room event: "+ e.user.name + "; id = " + e.user.id + "; my id= " 
                + SmartFoxClientSingleton.getInstance().smartFoxClient.myself.id);
            if(e.user.id == SmartFoxClientSingleton.getInstance().smartFoxClient.myself.id)
            {
                forceQuit(false);
            }
        }
        
        static private function onConnectionLostEvent(e:SFSEvent):void
        {
            forceQuit(true);
        }
        
        static public function onUserExitRoom(userName:String):void
        {
            CustomLogger.getInstance().log("User exit room: "+ userName);
            var p:Person = Person.getPersonByName(userName);
            if(p!=null)
            {
                CustomLogger.getInstance().log("User exit room (p!=null): "+ userName);
                p.rematchAccepted = false;
                GameInterfaceManager.getInstance().showSubmessage(LanguageManager.getInstance().getAndReplaceText("_disconnectedMessage","%player%",p.myName), p.myAvatar,null,false,"");
                var avatarName:String = "avatar" + p.myAvatar;
                var personName:String = p.myName;
                var arrayPosition:int = GameData.instance.scores.indexOf(p.score);
                var thisPanel:PlayerInfoPanel = playerListComponentItems[arrayPosition];
                var panelBackground:MovieClip = GameData.instance.gameObjectsContainer.infoScreen.playerListComponent.panelsHolder["panelBackground_" + (arrayPosition + 1)];    
                p.finalDelete();
                var positionTxt:String = thisPanel.positionTxt.text;
                var scoreTxt:String = thisPanel.scoreTxt.text;
                thisPanel.gotoAndStop("disabled");
                thisPanel.nameTxt.text = personName;
                thisPanel.character.gotoAndStop(avatarName);
                thisPanel.skillPointsTxt.visible = false;
                thisPanel.skillPointsField.visible = false;
                thisPanel.skillPointsHitArea.visible = false;
                thisPanel.positionTxt.text = positionTxt;
                thisPanel.scoreTxt.text = scoreTxt;
                thisPanel.pingSymbol.gotoAndStop("door");
                thisPanel.pingTxt.visible = false;
                panelBackground.gotoAndStop("blue");
                blackAndWhite(thisPanel.character, true);
                thisPanel.character.alpha = 0.5;
                if(GameData.instance.isRematching)
                {
                    GameData.instance.gameObjectsContainer.resultsScreenContainer.toggleRematchStatusDisplay(userName);
                }
                else if(GameData.instance.alreadyWinLose)
                {
                    GameData.instance.gameObjectsContainer.resultsScreenContainer.updateScreenOnDisconnect(userName);
                }
                if(userName == GameData.instance.myName &&
                GameData.instance.serverMessagesHandler.isSynchronized())
                {
                    forceQuit();
                }
            }
            removePlayerFromArrays(userName);
            updatePanels();
            
        }
        
        static private function removePlayerFromArrays(name:String):void
        {
            var playerId:int = GameData.instance.playerNames.indexOf(name);
            if(playerId!=-1)
            {
                GameData.instance.playerInforArr.splice(playerId,1);
                GameData.instance.idArr.splice(playerId,1);
                GameData.instance.playerNames.splice(playerId,1);
                GameData.instance.infoScreenId.splice(playerId,1);
                for(var it:uint=0;it<GameData.instance.playerInforArr.length;it++)
                {
                    GameData.instance.playerInforArr[it][0]=it;
                }
            }
        }
        
        static public function removeStage():void
        {
            if (currentClockTween != null)
            {
                currentClockTween.kill();
                currentClockTween = null;
            }
            if (currentNeedleTween != null)
            {
                currentNeedleTween.kill();
                currentNeedleTween = null;
            }
            
            SmartFoxClientSingleton.getInstance().smartFoxClient.removeExtensionResponseListener(onExtensionResponse);
            SoundClass.setVolume(0);
            SoundMixer.stopAll();
            if(GameData.instance.positionManager!=null)
            {
                GameData.instance.positionManager.dispose();
                GameData.instance.bombManager.dispose();
                for each (var walkControl:WalkControlSet in GameData.instance.walkControls)
                {
                    walkControl.dispose();
                }
            }
            for(var i:uint=0;i<GameData.instance.walkControls.length;i++)
            {
                SmartFoxClientSingleton.getInstance().smartFoxClient.removeEventListener(MessageEvent.GAME_MESSAGE, GameData.instance.walkControls[i].onGameMessage);                
            }
            Disease.dispose();
            DiseaseTimer.dispose();
            stopPingRequestTimer();
            Person.cleanLatencyCheck();
                  
            GameData.instance.isPlay = false;
            if(GameData.instance.Scen != null)
            {    
                if(GameData.instance.Scen.stage != null)
                {
                    GameData.instance.Scen.stage.removeEventListener ( Event.ENTER_FRAME, enterframe );
                }
                GameData.instance.Scen.mask = null;
            }

            if(GameData.instance.controls != null)
            {
                if(!GameData.instance.controls.removed)
                {
                    GameData.instance.controls.removeMe();
                }
            }

            Person.allPersons.splice(0);
            GameData.instance.scores.splice(0);

            GameData.instance.playersCreated = false;
            if (pingRequest != null)
            {
                pingRequest.stop();
                pingRequest = null;
            }
            SmartFoxClientSingleton.getInstance().smartFoxClient.reEngageExtensionResponses();            
            Login.deleteInstance();
        }

        /**
         * Creation of players.
         */
        public static function createPlayers(playersPositionsMap:Object):void
        {
            for(var i:int = 0; i < GameData.instance.playerInforArr.length; i++ )
            {
                var playerName:String = GameData.instance.playerNames[i] as String;
                var spawnPoint:Point = playersPositionsMap[playerName] as Point;
                if(spawnPoint == null)
                {
                    // to initialize game even is round never starts
                    spawnPoint = new Point(0, 0);
                }
                if(GameData.DEBUG_MODE)
                {
                    trace("creating player " + playerName + " at <" + spawnPoint.x + ", " + spawnPoint.y + ">");
                }
                createPlayer(spawnPoint, String(GameData.instance.playerInforArr[i][0]), GameData.instance.playerInforArr[i][1], playerName);
            }
            GameData.instance.playersCreated = true;
        }
        
        private static function createPlayer(position:Point, playerId:String, avatarId:uint, playerName:String):Person
        {
            var mode:String = "";
            var createdPerson:Person = GameData.instance.creater.createObj("person", "Person", "Person" + mode + "_" +
                avatarId, (position.x + 0.5) * GameData.instance.rectWidth,
                (position.y + 0.5) * GameData.instance.rectHeight + GameData.instance.upLine, 0, []) as Person;
            
            GameData.instance["controlWho" + playerId] = createdPerson;
            (GameData.instance["controlWho" + playerId] as Person).myId = playerId;
            (GameData.instance["controlWho" + playerId] as Person).myAvatar = avatarId;
            (GameData.instance["controlWho" + playerId] as Person).myName = playerName;
            (GameData.instance["controlWho" + playerId] as Person).userId = GameData.instance.userIds[playerName];
            (GameData.instance["controlWho" + playerId] as Person).score.avatar = avatarId;
            (GameData.instance["controlWho" + playerId] as Person).score.name = playerName;
            if(SmartFoxClientSingleton.getInstance().smartFoxClient.getPlayerByName(playerName)!=null){
                var u:User = (SmartFoxClientSingleton.getInstance().smartFoxClient.getPlayerByName(playerName)as User);
                (GameData.instance["controlWho" + playerId] as Person).score.isRegistered = ((SmartFoxClientSingleton.getInstance().smartFoxClient.getPlayerByName(playerName)as User).properties as UserLocalProperties).isRegistered;
                (GameData.instance["controlWho" + playerId] as Person).user = SmartFoxClientSingleton.getInstance().smartFoxClient.getPlayerByName(playerName);
                (GameData.instance["controlWho" + playerId] as Person).userId = SmartFoxClientSingleton.getInstance().smartFoxClient.getPlayerByName(playerName).id;
                (GameData.instance["controlWho" + playerId] as Person).score.userId = SmartFoxClientSingleton.getInstance().smartFoxClient.getPlayerByName(playerName).id;
                (GameData.instance["controlWho" + playerId] as Person).score.loadFullAvatar();
            }
            
            (GameData.instance["controlWho" + playerId] as Person).showDialogOver();
            
            if(String(GameData.instance.myId) == playerId)
            {
                GameData.instance.controls = new Ctrl(GameData.instance.gameBox, GameData.instance.controlWho1);
                GameData.instance.controls.gameObjectsContainer = GameData.instance.gameObjectsContainer;
            }
            return createdPerson;
        }

        
        
        //Redesign for V3
        static public function createPlayersList():void
        {
            var playersListOrder:Array = sortPlayersOrderByScore();
            GameData.instance.gameObjectsContainer.infoScreen.skillpointsTooltip.visible = false;
            GameData.instance.gameObjectsContainer.infoScreen.playerListComponent.mask = GameData.instance.gameObjectsContainer.infoScreen.playerListComponent.maskMC;
            GameData.instance.gameObjectsContainer.infoScreen.playerListComponent.topPanel.skillpointsErrorMessage.visible = false;
            //LanguageManager.getInstance().registerTag("_skillpointsErrorMessage", GameData.instance.gameObjectsContainer.infoScreen.playerListComponent.topPanel.skillpointsErrorMessage.nameTxt, "text");
            LanguageManager.getInstance().registerTag("_skillpointsErrorTooltip", GameData.instance.gameObjectsContainer.infoScreen.playerListComponent.topPanel.skillpointsErrorMessage.skillpointsErrorTooltip.nameTxt, "text");
            GameData.instance.gameObjectsContainer.infoScreen.playerListComponent.topPanel.skillpointsErrorMessage.skillpointsErrorTooltip.visible = false;
            GameData.instance.gameObjectsContainer.infoScreen.playerListComponent.topPanel.nameTxt.text = GameData.instance.myName;
            if(!SmartFoxClientSingleton.getInstance().smartFoxClient.myself.isSpectatorInRoom(SmartFoxClientSingleton.getInstance().smartFoxClient.gameRoom))
            {
                GameData.instance.gameObjectsContainer.infoScreen.playerListComponent.topPanel.character.gotoAndStop("avatar" + (Person.getPersonByName(GameData.instance.myName) as Person).myAvatar);
                GameData.instance.gameObjectsContainer.infoScreen.playerListComponent.topPanel.character.visible = true;
                GameData.instance.gameObjectsContainer.infoScreen.playerListComponent.topPanel.emptyPerson.visible = false;
            }
            else
            {
                GameData.instance.gameObjectsContainer.infoScreen.playerListComponent.topPanel.character.stop();
                GameData.instance.gameObjectsContainer.infoScreen.playerListComponent.topPanel.character.visible = false;
                GameData.instance.gameObjectsContainer.infoScreen.playerListComponent.topPanel.emptyPerson.visible = true;
            }
            if ((SmartFoxClientSingleton.getInstance().smartFoxClient.myself.properties as UserLocalProperties).isRegistered && ConfigController.getInstance().allowRankedGames )
            {
                GameData.instance.gameObjectsContainer.infoScreen.playerListComponent.topPanel.gotoAndStop("ranked");
                GameData.instance.gameObjectsContainer.infoScreen.playerListComponent.topPanel.activeSinceTxt.text = LanguageManager.getInstance().registerTag("_LeaderBoardActiveSinceMessage", GameData.instance.gameObjectsContainer.infoScreen.playerListComponent.topPanel.activeSinceTxt, "text") + " " + (SmartFoxClientSingleton.getInstance().smartFoxClient.myself.properties as UserLocalProperties).activationDay
                    + "/" + (SmartFoxClientSingleton.getInstance().smartFoxClient.myself.properties as UserLocalProperties).activationMonth
                    + "/" + (SmartFoxClientSingleton.getInstance().smartFoxClient.myself.properties as UserLocalProperties).activationYear;
                GameData.instance.gameObjectsContainer.infoScreen.playerListComponent.topPanel.rankedTxt.text = LanguageManager.getInstance().registerTag("_ingameRankingMessage", GameData.instance.gameObjectsContainer.infoScreen.playerListComponent.topPanel.rankedTxt, "text") + " " + (SmartFoxClientSingleton.getInstance().smartFoxClient.myself.properties as UserLocalProperties).rankingStr;
                GameData.instance.gameObjectsContainer.infoScreen.playerListComponent.topPanel.skillPointsTxt.text = LanguageManager.getInstance().registerTag("_ingameSkillpointsMessage", GameData.instance.gameObjectsContainer.infoScreen.playerListComponent.topPanel.skillPointsTxt, "text") + " " + (SmartFoxClientSingleton.getInstance().smartFoxClient.myself.properties as UserLocalProperties).pointsStr;
            } 
            else 
            {
                GameData.instance.gameObjectsContainer.infoScreen.playerListComponent.topPanel.gotoAndStop("guest");
                LanguageManager.getInstance().registerTag("_guestTopMessage", GameData.instance.gameObjectsContainer.infoScreen.playerListComponent.topPanel.guestMessageTxt, "text");
            }
            for(var i:int = 0; i < playersListOrder.length; i++)
            {
                GameData.instance.infoScreenId[i]=i;
                var thisPanel:PlayerInfoPanel = new PlayerInfoPanel();
                var panelBackground:MovieClip = GameData.instance.gameObjectsContainer.infoScreen.playerListComponent.panelsHolder["panelBackground_" + (i+1)];
                EventListenerManager.setListenerTo(thisPanel.skillPointsHitArea, MouseEvent.MOUSE_OVER, showSkillPointsTooltip);
                thisPanel.skillpointsTooltip.visible = false;
                LanguageManager.getInstance().registerTag("_skillpointsHover", thisPanel.skillpointsTooltip.skillPointsTxt, "text");
                if(SmartFoxClientSingleton.getInstance().smartFoxClient.gameRoom!=null)
                {
                    if (thisUser != null)
                    {
                        thisPanel.skillPointsTxt.text = "" + (thisUser.properties as UserLocalProperties).pointsStr;
                        thisPanel.flag.gotoAndStop((thisUser.properties as UserLocalProperties).nationality);
                        if (!(thisUser.properties as UserLocalProperties).isRegistered) 
                        {
                            thisPanel.skillPointsTxt.visible = false;
                            thisPanel.skillPointsField.visible = false;
                            thisPanel.skillPointsHitArea.visible = false;
                        }
                    }
                }
                if((playersListOrder[i] as PersonScore).name == GameData.instance.myName)
                {
                    thisPanel.gotoAndStop("yellow");
                    panelBackground.gotoAndStop("yellow");
                    thisPanel.skillPointsField.gotoAndStop("yellow");
                }
                else
                {
                    thisPanel.gotoAndStop("normal");
                    panelBackground.gotoAndStop("blue");
                    thisPanel.skillPointsField.gotoAndStop("blue");
                }
                if (GameData.instance.trophies)
                {
                    thisPanel.scoreTxt.x = thisPanel.trophy.x + 26;
                } 
                else 
                {
                    thisPanel.trophy.visible = false;
                }
                thisPanel.character.gotoAndStop("avatar" + String((playersListOrder[i] as PersonScore).avatar));
                if (lastPosition != i+1)
                {
                    thisPanel.positionTxt.text = "" + (i+1);
                    lastPosition = i+1;
                }  
                else 
                {
                    thisPanel.positionTxt.text = "";
                }
                thisPanel.nameTxt.text = (playersListOrder[i] as PersonScore).name;
                thisPanel.scoreTxt.text = "0";
                thisPanel.pingSymbol.gotoAndStop("veryHigh");
                thisPanel.pingTxt.text = "";
                thisPanel.y = GameData.instance.gameObjectsContainer.infoScreen.playerListComponent.panelsHolder["panelBackground_" + (i+1)].y;    
                thisPanel.x = GameData.instance.gameObjectsContainer.infoScreen.playerListComponent.panelsHolder["panelBackground_" + (i+1)].x;
                var thisUser:User = SmartFoxClientSingleton.getInstance().smartFoxClient.getPlayerByName((playersListOrder[i] as PersonScore).name);

                if (thisUser != null)
                {
                    thisPanel.skillPointsTxt.text = "" + (thisUser.properties as UserLocalProperties).pointsStr;
                    thisPanel.flag.gotoAndStop((thisUser.properties as UserLocalProperties).nationality);
                    if(SmartFoxClientSingleton.getInstance().smartFoxClient.gameRoom!=null)
                    {
                            thisPanel.skillPointsTxt.text = "" + (thisUser.properties as UserLocalProperties).pointsStr;
                            if (!(thisUser.properties as UserLocalProperties).isRegistered) 
                            {
                                thisPanel.skillPointsTxt.visible = false;
                                thisPanel.skillPointsField.visible = false;
                                thisPanel.skillPointsHitArea.visible = false;
                            }
                        
                    }
                }
                GameData.instance.gameObjectsContainer.infoScreen.playerListComponent.panelsHolder.addChild(thisPanel);
                playerListComponentItems.push(thisPanel);
            }
        }
        
        private static function blackAndWhite(target:DisplayObject, enabled:Boolean):void
        {
            var rc:Number = 1/3;
            var gc:Number = 1/3;
            var bc:Number = 1/3;
            var cmf:ColorMatrixFilter = new ColorMatrixFilter([rc, gc, bc, 0, 0, rc, gc, bc, 0, 0, rc, gc, bc, 0, 0, 0, 0, 0, 1, 0]);
            if (enabled) 
            {
                target.filters = [cmf];
            } 
            else 
            {
                target.filters = [];
            }
        }
        
        public static function updatePanels(renew:Boolean = false):void
        {
            if (SmartFoxClientSingleton.getInstance().smartFoxClient.gameRoom.playerList.indexOf(SmartFoxClientSingleton.getInstance().smartFoxClient.myself) > -1)
            {
//                GameData.instance.gameObjectsContainer.infoScreen.playerListComponent.topPanel.character.gotoAndStop("avatar" + (Person.getPersonByName(GameData.instance.myName) as Person).myAvatar);
            }
            sortPlayersOrderByScore();
            var lastRank:int = 0;
            while (GameData.instance.scores.length < playerListComponentItems.length)
            {
                var vial:Object = GameData.instance.scores;
                GameData.instance.gameObjectsContainer.infoScreen.playerListComponent.panelsHolder["panelBackground_" + (playerListComponentItems.length)].gotoAndStop("empty");
                playerListComponentItems.pop().visible = false;
            }
            for(var i:uint=0;i < GameData.instance.scores.length;i++)
            {
                var thisPanel:PlayerInfoPanel = playerListComponentItems[i];
                var thisPersonScore:PersonScore = GameData.instance.scores[i];
                var panelBackground:MovieClip = GameData.instance.gameObjectsContainer.infoScreen.playerListComponent.panelsHolder["panelBackground_" + (i + 1)];
                
                if(thisPersonScore.person == null)
                {
                    thisPanel.gotoAndStop("disabled");
                    thisPanel.pingSymbol.gotoAndStop("door");
                    thisPanel.pingTxt.visible = false;
                    panelBackground.gotoAndStop("blue");
                    thisPanel.skillPointsTxt.visible = false;
                    thisPanel.skillPointsField.visible = false;
                    thisPanel.skillPointsHitArea.visible = false;
                    
                    InGameUserListManager.getInstance().onUserExitRoom(thisPersonScore.userId);
                }
                else
                {
                    thisPanel.pingTxt.visible = true;
                    
                    if(thisPersonScore.person.user != null)
                    {
                        if((thisPersonScore.person.user.properties as UserLocalProperties).nationality != null)
                        {
                            thisPanel.flag.gotoAndStop((thisPersonScore.person.user.properties as UserLocalProperties).nationality);
                        }
                    }
                    else
                    {
                        thisPanel.flag.gotoAndStop("undefined");
                    }
                    
                    if (thisPersonScore.person.fire && !renew)
                    {
                        thisPanel.gotoAndStop("disabled");
                        panelBackground.gotoAndStop("blue");
                        thisPanel.skillPointsField.gotoAndStop("blue");    
                        blackAndWhite(thisPanel.character, true);
                        thisPanel.character.alpha = 0.5;
                        updatePlayerLatencyStatus(thisPersonScore.person, thisPersonScore.person.latency);
                        
                        InGameUserListManager.getInstance().updatePingIcon(thisPersonScore.person.userId, thisPersonScore.person.latency);
                        InGameUserListManager.getInstance().onUserKilled(thisPersonScore.userId);
                    } 
                    else 
                    {
                        if(thisPersonScore.name == GameData.instance.myName)
                        {
                            thisPanel.gotoAndStop("yellow");
                            panelBackground.gotoAndStop("yellow");
                            thisPanel.skillPointsField.gotoAndStop("yellow");
                            thisPanel.skillPointsField.visible = true;
                            blackAndWhite(thisPanel.character, false);
                            thisPanel.character.alpha = 1;
                            updatePlayerLatencyStatus(thisPersonScore.person, thisPersonScore.person.latency);
                            
                            InGameUserListManager.getInstance().updatePingIcon(thisPersonScore.person.userId, thisPersonScore.person.latency);
                        }
                        else
                        {
                            if (thisPersonScore.person!=null && thisPersonScore.person.hasTimedOut)
                            {
                                thisPanel.gotoAndStop("issues");
                                panelBackground.gotoAndStop("empty");
                                thisPanel.character.alpha = 0.5;
                                blackAndWhite(thisPanel.character, false);
                            }
                            else 
                            {
                                thisPanel.gotoAndStop("normal");
                                panelBackground.gotoAndStop("blue");
                                thisPanel.skillPointsField.visible = true;
                                thisPanel.skillPointsField.gotoAndStop("blue");
                                blackAndWhite(thisPanel.character, false);
                                thisPanel.character.alpha = 1;
                                updatePlayerLatencyStatus(thisPersonScore.person, thisPersonScore.person.latency);
                                
                                InGameUserListManager.getInstance().updatePingIcon(thisPersonScore.person.userId, thisPersonScore.person.latency);
                            }
                        }
                    }
                    if(thisPanel.skillPointsField!=null)
                    {
                        thisPanel.skillPointsTxt.visible = true;
                        thisPanel.skillPointsField.visible = true;
                        thisPanel.skillPointsHitArea.visible = true;
                        var user:User = SmartFoxClientSingleton.getInstance().smartFoxClient.getPlayerByName(thisPersonScore.name);
                        if(user != null)
                        {
                            var uv:UserVariable = user.getVariable("latency");
                            if(uv!=null)
                            {
                                updatePlayerLatencyStatus(thisPersonScore.person,uv.getIntValue());
                                
                                InGameUserListManager.getInstance().updatePingIcon(thisPersonScore.person.userId, uv.getIntValue());
                            }
                        }
                    }
                }
                if (GameData.instance.trophies)
                {
                    thisPanel.scoreTxt.x = thisPanel.trophy.x + 26;
                    thisPanel.scoreTxt.text = "" + thisPersonScore.totalTrophies;
                } 
                else 
                {
                    thisPanel.scoreTxt.text = "" + thisPersonScore.totalScorePoints;
                }
                thisPanel.nameTxt.text = thisPersonScore.name;
                if (thisPersonScore.ranking != lastRank)
                {
                    thisPanel.positionTxt.text = "" + thisPersonScore.ranking;
                    lastRank = thisPersonScore.ranking;
                } 
                else 
                {
                    thisPanel.positionTxt.text = "";
                }
                thisPanel.character.gotoAndStop("avatar" + thisPersonScore.avatar);
                if(SmartFoxClientSingleton.getInstance().smartFoxClient.gameRoom!=null)
                {
                    var thisPlayer:User = SmartFoxClientSingleton.getInstance().smartFoxClient.gameRoom.getUserByName(thisPersonScore.name);
                    if (thisPlayer != null)
                    {
                        thisPanel.skillPointsTxt.text = "" + (thisPlayer.properties as UserLocalProperties).pointsStr;    
                        if (!(thisPlayer.properties as UserLocalProperties).isRegistered) 
                        {
                            thisPanel.skillPointsTxt.visible = false;
                            thisPanel.skillPointsField.visible = false;
                            thisPanel.skillPointsHitArea.visible = false;
                        }
                    }
                }
                InGameUserListManager.getInstance().updateUserScoresAndPositions(thisPersonScore);
            }
            
            InGameUserListManager.getInstance().orderListByPosition(GameData.instance.scores);
        }
        
        
        private static function updatePlayerLatencyStatus(player:Person, latency:int):void
        {
            if (player == null)
            {
                return;
            }
            player.refreshLatencyCheck();
            if (player.hasTimedOut)
            {
                player.hasTimedOut = false;
                updatePanels();
            }
            var infoPanelId:int = sortPlayersOrderByScore().indexOf(player.score);
            if(infoPanelId != -1)
            {
                if (latency <= 40)
                {
                    playerListComponentItems[infoPanelId].pingSymbol.gotoAndStop("veryHigh");
                } 
                else if (latency <= 80) 
                {
                    playerListComponentItems[infoPanelId].pingSymbol.gotoAndStop("high");
                } 
                else if (latency <= 160) 
                {
                    playerListComponentItems[infoPanelId].pingSymbol.gotoAndStop("low");
                } 
                else 
                {
                    playerListComponentItems[infoPanelId].pingSymbol.gotoAndStop("veryLow");
                }
                if (latency > 0)
                {
                    playerListComponentItems[infoPanelId].pingTxt.text = "" + latency;
                }
            }
        }
         
        //FIXME move to corresponding states
        public static function backToLobby(e:MouseEvent):void
        {
            var screen:String;
            if(GameData.instance.currentGameStatus == StatusManager.CHARACTER_SELECT_STATUS)
            {
                screen = "characterSelectScreen";
                //HoneyTracksHelper.trackFeatureUsage(LocalUser.getInstance().registered, SmartFoxClientSingleton.getInstance().smartFoxClient.myself.isSpectator, HoneyTrackConstants.TRACKERNAME_GAME_LEFT, HoneyTrackConstants.SUBCATEGORY_CHARACTER_SELECT_SCREEN);
            }
            if(GameData.instance.currentGameStatus == StatusManager.IN_ROUND_STATUS)
            {
                screen = "gamePlayRound" + GameData.instance.currentRound.toString();
                //HoneyTracksHelper.trackFeatureUsage(LocalUser.getInstance().registered, SmartFoxClientSingleton.getInstance().smartFoxClient.myself.isSpectator, HoneyTrackConstants.TRACKERNAME_GAME_LEFT, HoneyTrackConstants.SUBCATEGORY_GAME_PLAY_ROUND_SCREEN, GameData.instance.currentRound.toString());
            }
            else if(GameData.instance.currentGameStatus == StatusManager.END_ROUND_STATUS)
            {
                screen = "roundResultRound" + GameData.instance.currentRound.toString();
                //HoneyTracksHelper.trackFeatureUsage(LocalUser.getInstance().registered, SmartFoxClientSingleton.getInstance().smartFoxClient.myself.isSpectator, HoneyTrackConstants.TRACKERNAME_GAME_LEFT, HoneyTrackConstants.SUBCATEGORY_ROUND_RESULT_ROUND_SCREEN, GameData.instance.currentRound.toString());
            }
            if(GameData.instance.currentGameStatus == StatusManager.END_MATCH_STATUS)
            {
                screen = "endScreen";
                //HoneyTracksHelper.trackFeatureUsage(LocalUser.getInstance().registered, SmartFoxClientSingleton.getInstance().smartFoxClient.myself.isSpectator, HoneyTrackConstants.TRACKERNAME_GAME_LEFT, HoneyTrackConstants.SUBCATEGORY_END_SCREEN);
            }
            /*Refactor change
            if(winnersScreen.parent != null)
            {
                screen = "advertisment";
                HoneyTracksHelper.trackFeatureUsage(LocalUser.getInstance().registered, SmartFoxClientSingleton.getInstance().smartFoxClient.myself.isSpectator, 
                                                    HoneyTrackConstants.TRACKERNAME_GAME_LEFT, HoneyTrackConstants.SUBCATEGORY_AVERTISMENT_SCREEN);
            }
            */
            forceQuit(false);
        }
        
        public static function startPingRequestTimer():void
        {
            if(pingRequest == null)
            {
                pingRequest = new Timer(2500);
                EventListenerManager.setListenerTo(pingRequest, TimerEvent.TIMER, onPingRequestTimer);
            }
            sendRoundTripRequest();
            pingRequest.start();
            Person.startLatencyCheck();
            EventListenerManager.setListenerTo(GameData.instance.Scen, "timedOut", onPersonTimedOut);
        }
        
        private static function onPersonTimedOut(e:PersonEvent):void{
            updatePanels();
        }
        
        private static function sendRoundTripRequest():void
        {
            try
            {
                var sfsObject:SFSObject = new SFSObject();
                sfsObject.putInt("latencyTime", getTimer());
                sfsObject.putInt("ping", Math.floor(GameData.instance.latencyValue));
                sfsObject.putUtfString("player", GameData.instance.myName);
                var vial:Object = SmartFoxClientSingleton.getInstance().smartFoxClient.myself;
                var vial2:Object = Person.getPersonByName(SmartFoxClientSingleton.getInstance().smartFoxClient.myself.name);
                var vial3:Object = SmartFoxClientSingleton.getInstance().smartFoxClient.gameRoom;
    
                if (!SmartFoxClientSingleton.getInstance().smartFoxClient.myself.isSpectatorInRoom(SmartFoxClientSingleton.getInstance().smartFoxClient.gameRoom) && Person.getPersonByName(GameData.instance.myName).fire)
                {
                    sfsObject.putBool("dead", true);
                }
                SmartFoxClientSingleton.getInstance().smartFoxClient.sendExtensionRequestToGameRoom(ServerMessages.ROUND_TRIP_TIME_MEASSURE, sfsObject);
            }
            catch(error:Error)
            {
                //If the round is closed round trip request shouldn't be sent
            }
        }
        
        private static function stopPingRequestTimer():void
        {
            if (pingRequest != null)
            {
                pingRequest.stop();
                pingRequest.removeEventListener(TimerEvent.TIMER, onPingRequestTimer);
                Person.stopLatencyCheck();
            }
        }
        
        private static function onPingRequestTimer(e:TimerEvent):void
        {
            sendRoundTripRequest();
        }
        
        public static function sortPlayersOrderByScore(partialScore:Boolean = false):Array
        {
            var sortedList:Array = new Array();
            var criterion:String;
            
            if (partialScore)
            {
                criterion = "currentRoundScore";
            }
            else
            {
                criterion = "totalScorePoints";
            }
            
            GameData.instance.scores.sortOn([criterion, "name"], [Array.NUMERIC | Array.DESCENDING, Array.DESCENDING]);
            
            if (GameData.instance.scores.length == 0)
            {
                return GameData.instance.scores;
            }
            
            var lastScore:int = (GameData.instance.scores[0] as PersonScore).totalScorePoints;
            var lastRank:int = 1;
            
            (GameData.instance.scores[0] as PersonScore).ranking = 1;
            for (var i:uint = 1; i < GameData.instance.scores.length; i++)
            {
                var thisPersonScore:PersonScore = GameData.instance.scores[i];
                if (thisPersonScore.totalScorePoints == lastScore)
                {
                    thisPersonScore.ranking = lastRank;
                }
                else
                {
                    thisPersonScore.ranking = ++lastRank;
                }
            }
            
            return GameData.instance.scores;
        }
        
        private static function showSkillPointsTooltip(e:MouseEvent):void
        {
            var p:Point = e.currentTarget.parent.localToGlobal(new Point(e.currentTarget.x, e.currentTarget.y));
            GameData.instance.gameObjectsContainer.infoScreen.skillpointsTooltip.visible = true;
            if(p.x + GameData.instance.gameObjectsContainer.infoScreen.skillpointsTooltip.width > SharedVars.STAGE_WIDTH)
            {
                p.x = SharedVars.STAGE_WIDTH - GameData.instance.gameObjectsContainer.infoScreen.skillpointsTooltip.width;
            }
            GameData.instance.gameObjectsContainer.infoScreen.skillpointsTooltip.x = p.x ;
            GameData.instance.gameObjectsContainer.infoScreen.skillpointsTooltip.y = p.y - GameData.instance.gameObjectsContainer.infoScreen.skillpointsTooltip.height;
            EventListenerManager.setListenerTo((e.currentTarget as MovieClip), MouseEvent.MOUSE_OUT, hideSkillPointsTooltip);
        }
        
        private static function hideSkillPointsTooltip(e:MouseEvent):void
        {
            GameData.instance.gameObjectsContainer.infoScreen.skillpointsTooltip.visible = false;
            (e.currentTarget as MovieClip).removeEventListener(MouseEvent.MOUSE_OUT, hideSkillPointsTooltip);
        }
        
        public static function autoResize(textField:TextField):void
        {
            var horizontalScroll:Number = textField.scrollH;
            var verticalScroll:Number = textField.scrollV;
            var verticalMax:Number = textField.maxScrollV;
            var resizeData:AutoResizeData = AutoResizeData.getData(textField);
            if (resizeData == null)
            {
                resizeData = new AutoResizeData(textField);
            }
            var format:TextFormat = resizeData.textFormat;
            format.leading = 0;
            textField.multiline = true;
            format.size = resizeData.fontSize;
            textField.defaultTextFormat = format;
            textField.setTextFormat(format);
            
            while (textField.textHeight > resizeData.rectArea.height)
            {
                format.size = int(format.size) - 1;
                textField.autoSize = TextFieldAutoSize.CENTER;
                textField.setTextFormat(format);
            }
            
        }
        
        public static function closeMe(e:MouseEvent):void
        {
            e.currentTarget.parent.visible = false;
        }
        
        public static function getRematchCount():uint
        {
            var rematchCount:uint = 0;
            var thisUser:SFSUser;
            for each( var user:SFSUser in SmartFoxClientSingleton.getInstance().smartFoxClient.gameRoom.playerList)
            {
                if (Person.getPersonByName(user.name) != null)
                {
                    if  ((Person.getPersonByName(user.name) as Person).rematchAccepted)
                    {
                        rematchCount ++;
                    }
                } 
            }
            return rematchCount;
        }
        
        public static function disposeAllChildrenAndRemove(target:DisplayObjectContainer):void{
            
            if (target is DisplayObjectContainer)
            {
                var thisComponent:DisplayObjectContainer;
            }
            
            if(thisComponent != null && thisComponent.numChildren > 0){
                
                while (target.numChildren > 0)
                {
                    disposeAllChildrenAndRemove(thisComponent.getChildAt(0) as DisplayObjectContainer);
                }
                
            }
            else
            {
                if (target!= null && target.parent != null){
                    
                    target.parent.removeChild(target);
                }
            }
        }

        public static function checkPlayersListForcedInitCondition():void{
            if (SmartFoxClientSingleton.getInstance().smartFoxClient.gameRoom.playerList.length < 2 && !GameData.instance.playersCreated)
            {
                GameSys.createPlayers(new Object());
                createPlayersList();
            }
        }
        
        public static function setBuildParams(seed:int, mapDescription:SfsBasedMapDescription):void
        {
            GameSys.seed = seed;
            GameSys.mapDescription= mapDescription;
        }
        
        public static function updateBuildParams(mapDescription:SfsBasedMapDescription):void
        {
            GameSys.mapDescription= mapDescription;
        }

    }
}
