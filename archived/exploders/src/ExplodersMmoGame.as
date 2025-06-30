package
{
    import com.gq.system.DocumentClass;
    import com.gq.system.GameData;
    import com.gq.system.GameSys;
    import com.gq.ui.InGameChatManager;
    import com.gq.ui.InGameUserListManager;
    import com.smartfoxserver.v2.SmartFox;
    import com.smartfoxserver.v2.core.SFSEvent;
    import com.smartfoxserver.v2.entities.Room;
    import com.smartfoxserver.v2.entities.User;
    import com.smartfoxserver.v2.entities.data.SFSObject;
    import com.smartfoxserver.v2.entities.variables.UserVariable;
    import com.smartfoxserver.v2.requests.JoinRoomRequest;
    import com.smartfoxserver.v2.requests.LoginRequest;
    import com.willdom.games.bomberman.communication.SmartFoxClientSingleton;
    import com.willdom.games.bomberman.consts.PlayerVars;
    import com.willdom.games.bomberman.events.MessageEvent;
    import com.willdom.games.bomberman.rooms.RoomLocalProperties;
    import com.willdom.games.bomberman.user.UserLocalProperties;
    import com.willdom.games.explodersmmo.shared.consts.SharedVars;
    import com.willdom.games.explodersmmo.shared.events.LobbyGameCommunicationEvent;
    import com.willdom.games.explodersmmo.shared.events.LobbyGameStartedEvent;
    import com.willdom.games.explodersmmo.shared.events.game.GameEndedEvent;
    import com.willdom.games.explodersmmo.shared.model.CustomLogger;
    import com.willdom.games.explodersmmo.shared.model.LocalUser;
    import com.willdom.games.explodersmmo.shared.model.RoomBasicInfo;
    import com.willdom.games.explodersmmo.shared.stats.StatsManager;
    //import com.willdom.games.explodersmmo.shared.tracker.HoneyTrackConstants;
    //import com.willdom.games.explodersmmo.shared.tracker.HoneyTracksHelper;
    import com.willdom.util.helpers.EventListenerManager;
    
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.system.Security;
    
    [SWF(width="1006",height="700")]
    public class ExplodersMmoGame extends Sprite
    {
        private var sfs:SmartFox;
        private var bomberman:DocumentClass;
        
        private var roomToJoin:RoomBasicInfo;
        private var userPassword:String = "";
        private var chatServerUsername:String;
        private var asSpectator:Boolean;
        private var gameSource:String;
        
        private var gameLayer:Sprite;
        private var chatLayer:Sprite;
        
        public function ExplodersMmoGame()
        {
            CustomLogger.getInstance().log("Game instantiated");
            Security.allowDomain("*");
            Security.allowInsecureDomain("*");
            addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
            addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
            
            gameLayer = new Sprite;
            chatLayer = new Sprite;
            
            addChild(gameLayer);
            addChild(chatLayer);
        }
        
        protected function onAddedToStage(event:Event):void
        {
            CustomLogger.getInstance().log("Game added to Stage");
            this.stage.addEventListener(LobbyGameCommunicationEvent.INIT_GAME, onLoad, false, 0, true);
        }
        
        
        protected function onLoad(event:LobbyGameStartedEvent):void
        {
            sfs = new SmartFox();
            sfs.connect(event.ip, event.port);
            sfs.addEventListener(SFSEvent.CONNECTION, onSFSConnection, false, 0, true);
            sfs.addEventListener(SFSEvent.LOGIN, onSFSLogin, false, 0, true);
            sfs.addEventListener(SFSEvent.ROOM_JOIN, onRoomJoined, false, 0, true);
            sfs.addEventListener(SFSEvent.USER_ENTER_ROOM, onUserEnterRoom, false, 0, true);
            sfs.addEventListener(SFSEvent.USER_VARIABLES_UPDATE, onUserVariablesUpdate, false, 0, true);
            sfs.addEventListener(SFSEvent.LOGIN_ERROR, onSFSLoginError, false, 0, true);
            sfs.addEventListener(SFSEvent.ROOM_JOIN_ERROR, onRoomJoinError, false, 0, true);
            
            asSpectator = event.asSpectator;
            gameSource = event.source;
            sfs.addEventListener(SFSEvent.USER_EXIT_ROOM, onUserExitRoom, false, 0, true);
            sfs.addEventListener(SFSEvent.CONNECTION_LOST, onConnectionLost, false, 0, true);
            
            userPassword = event.roomPassword;
            roomToJoin = new RoomBasicInfo(event.roomId, "", event.roomPassword, event.zone);
            chatServerUsername = event.username;
        }
        
        protected function onUserVariablesUpdate(event:SFSEvent):void
        {
            updateUserLocalProperties(event.params.user);
        }
        
        protected function onSFSConnection(event:SFSEvent):void
        {
            if(event.params.success)
            {
                CustomLogger.getInstance().log("2Digit Country ISO Code: " + SharedVars.geoLocation2DigitIso);
                
                CustomLogger.getInstance().log("Game connection success");
                var params:SFSObject = new SFSObject();
                params.putInt("roomId",roomToJoin.id);
                params.putUtfString("nationality", SharedVars.geoLocation2DigitIso);
                sfs.send(new LoginRequest(chatServerUsername, userPassword, roomToJoin.zone,params));
            }
            else
            {
                CustomLogger.getInstance().log("Game connection fail");
                var e:GameEndedEvent = new GameEndedEvent(GameEndedEvent.GAME_ENDED_FORCED, true, true);
                e.source = gameSource;
                this.dispatchEvent(e);
            }
        }
        
        private function onSFSLogin(event:SFSEvent):void
        {
            sfs.send(new JoinRoomRequest(roomToJoin.id,roomToJoin.password,-1,asSpectator));
        }
        
        private function onSFSLoginError(event:SFSEvent):void
        {
            var e:GameEndedEvent = new GameEndedEvent(GameEndedEvent.GAME_ENDED_FORCED, true, true);
            e.source = gameSource;
            this.dispatchEvent(e);
        }
        
        private function onRoomJoinError(event:SFSEvent):void
        {
            var e:GameEndedEvent = new GameEndedEvent(GameEndedEvent.GAME_ENDED_FORCED, true, true);
            e.source = gameSource;
            this.dispatchEvent(e);
        }
        
        private function onRoomJoined(event:SFSEvent):void
        {
            event.params.room.properties = new RoomLocalProperties();
            var variables:Array;
            var arr:Array;
            
            SmartFoxClientSingleton.getInstance().init(sfs,event.params.room);
            init();
            
            for each(var u:User in (event.params.room as Room).userList)
            {
                updateUserLocalProperties(u);
            }
            //wouterB: Remove Honeytracks
            //HoneyTracksHelper.trackFeatureUsage(LocalUser.getInstance().registered, SmartFoxClientSingleton.getInstance().smartFoxClient.myself.isSpectator, HoneyTrackConstants.TRACKERNAME_GAME_ENTERED, gameSource);
            
            GameSys.gameSource = gameSource;
            this.stage.dispatchEvent(new LobbyGameCommunicationEvent(LobbyGameCommunicationEvent.GAME_LOADED));
        }
        
        private function init():void
        {
            bomberman = new DocumentClass();
            gameLayer.addChild(bomberman);
            
            InGameUserListManager.getInstance().initialize();
            chatLayer.addChild(InGameUserListManager.getInstance());
            InGameChatManager.getInstance().initialize();
            chatLayer.addChild(InGameChatManager.getInstance());
            
            var gameBox:Sprite = new Sprite();
            gameBox.graphics.beginFill(0xFF0011, 0);
            gameBox.graphics.drawRect(0, 0, 772, 701);
            gameBox. graphics.endFill();
            gameBox.alpha = 1;
            gameBox.visible = false;
            gameBox.addEventListener(MouseEvent.CLICK, onMouseClickGameBox);
            chatLayer.addChild(gameBox);
            GameData.instance.gameBox = gameBox;
            
            EventListenerManager.setListenerTo(bomberman, MessageEvent.GAME_RESTART, onGameRestart);
        }
        
        protected function onMouseClickGameBox(event:MouseEvent):void
        {
            GameData.instance.gameBox.stage.focus = GameData.instance.gameBox;
        }
        
        protected function onUserEnterRoom(event:SFSEvent):void
        {
            if(event.params.room == SmartFoxClientSingleton.getInstance().smartFoxClient.gameRoom)
            {
                updateUserLocalProperties(event.params.user);
            }
        }
        
        private function updateUserLocalProperties(user:User):void
        {
            var properties:UserLocalProperties = new UserLocalProperties();
            var userVariable:UserVariable = user.getVariable(PlayerVars.SKILL_POINTS_INFO);
            
            if(userVariable != null)
            {
                properties.skillPointsInfo = userVariable.getSFSObjectValue();
            }
            
            userVariable = user.getVariable(PlayerVars.AVATAR_INFO);
            if(userVariable != null)
            {
                properties.avatarInfo = userVariable.getSFSObjectValue();
            }
            
            userVariable = user.getVariable(PlayerVars.REGISTERED);
            if(userVariable != null)
            {
                properties.isRegistered = userVariable.getBoolValue();
            }
            
            userVariable = user.getVariable(PlayerVars.NATIONALITY);
            if(userVariable != null)
            {
                properties.nationality = userVariable.getStringValue();
            }
            
            user.properties = properties;
            
            if(user.id == SmartFoxClientSingleton.getInstance().smartFoxClient.myself.id)
            {
                GameData.instance.iAmSpectating = sfs.mySelf.isSpectator;
                InGameUserListManager.getInstance().onMySelfEnterRoom(user, properties);
            }
            
            InGameUserListManager.getInstance().onUserEnterRoom(user, properties);
        }
        
        protected function onUserExitRoom(event:SFSEvent):void
        {
            var uV:UserVariable;
            
            if(event.params.room == SmartFoxClientSingleton.getInstance().smartFoxClient.gameRoom && event.params.user == sfs.mySelf)
            {
                if(stage != null && bomberman != null && !GameData.instance.afterCharSelectStatus)
                {
                    var e:GameEndedEvent = new GameEndedEvent(GameEndedEvent.GAME_ENDED_FORCED, true, true);
                    this.dispatchEvent(e);
                    dispose();
                }
            }
        }
        
        protected function onConnectionLost(event:SFSEvent):void
        {
            if(stage != null && bomberman != null)
            {
                var e:GameEndedEvent = new GameEndedEvent(GameEndedEvent.GAME_ENDED_FORCED, true, true);
                dispatchEvent(e);
                dispose();
            }
        }
        
        protected function onGameRestart(e:Event):void
        {
            dispose(true);
            init();
        }
        
        protected function onRemovedFromStage(event:Event):void
        {
            if(SmartFoxClientSingleton.getInstance().smartFoxClient != null)
            {
                SmartFoxClientSingleton.getInstance().smartFoxClient.sfs.disconnect();
            }
            dispose();
        }
        
        private function dispose(reMatch:Boolean = false):void
        {
            if(bomberman != null)
            {
                GameSys.removeStage();
                gameLayer.removeChild(bomberman);
                EventListenerManager.dispose();
                
                bomberman = null;
                GameData.instance.gameBox.parent.removeChild(GameData.instance.gameBox);
                GameData.instance.gameBox = null;
                StatsManager.instance.resetStats();
            }
            if(!reMatch)
            {
                InGameChatManager.getInstance().resetComponents();
                InGameUserListManager.getInstance().resetComponents();
                InGameUserListManager.getInstance().onExitGame();
            }
            else
            {
                InGameUserListManager.getInstance().resetComponents(true);
            }
            
            // Dispose and delete the game screens
            if(GameData.instance.gameObjectsContainer.endRoundResultsScreen != null)
            {
                GameData.instance.gameObjectsContainer.endRoundResultsScreen.dispose();
                GameData.instance.gameObjectsContainer.endRoundResultsScreen = null;
            }
            else if(GameData.instance.gameObjectsContainer.endMatchWinnerScreen != null)
            {
                GameData.instance.gameObjectsContainer.endMatchWinnerScreen.dispose();
                GameData.instance.gameObjectsContainer.endMatchWinnerScreen = null;
            }
            else if(GameData.instance.gameObjectsContainer.endMatchAdvertismentScreen != null)
            {
                GameData.instance.gameObjectsContainer.endMatchAdvertismentScreen.dispose();
                GameData.instance.gameObjectsContainer.endMatchAdvertismentScreen = null;
            }
            else if(GameData.instance.gameObjectsContainer.endMatchResultsScreen != null)
            {
                GameData.instance.gameObjectsContainer.endMatchResultsScreen.dispose();
                GameData.instance.gameObjectsContainer.endMatchResultsScreen = null
            }
            
            SmartFoxClientSingleton.getInstance().smartFoxClient.prevGameRoom = null;
        }
    }
}