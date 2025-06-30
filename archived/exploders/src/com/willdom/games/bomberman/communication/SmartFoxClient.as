package com.willdom.games.bomberman.communication
{
    import com.smartfoxserver.v2.*;
    import com.smartfoxserver.v2.SmartFox;
    import com.smartfoxserver.v2.bitswarm.Message;
    import com.smartfoxserver.v2.core.SFSEvent;
    import com.smartfoxserver.v2.entities.Room;
    import com.smartfoxserver.v2.entities.SFSRoom;
    import com.smartfoxserver.v2.entities.User;
    import com.smartfoxserver.v2.entities.data.SFSArray;
    import com.smartfoxserver.v2.entities.data.SFSObject;
    import com.smartfoxserver.v2.entities.invitation.Invitation;
    import com.smartfoxserver.v2.entities.invitation.InvitationReply;
    import com.smartfoxserver.v2.entities.variables.RoomVariable;
    import com.smartfoxserver.v2.entities.variables.SFSRoomVariable;
    import com.smartfoxserver.v2.entities.variables.SFSUserVariable;
    import com.smartfoxserver.v2.entities.variables.UserVariable;
    import com.smartfoxserver.v2.requests.AdminMessageRequest;
    import com.smartfoxserver.v2.requests.BanMode;
    import com.smartfoxserver.v2.requests.BanUserRequest;
    import com.smartfoxserver.v2.requests.ExtensionRequest;
    import com.smartfoxserver.v2.requests.JoinRoomRequest;
    import com.smartfoxserver.v2.requests.KickUserRequest;
    import com.smartfoxserver.v2.requests.LeaveRoomRequest;
    import com.smartfoxserver.v2.requests.LoginRequest;
    import com.smartfoxserver.v2.requests.MessageRecipientMode;
    import com.smartfoxserver.v2.requests.ModeratorMessageRequest;
    import com.smartfoxserver.v2.requests.ObjectMessageRequest;
    import com.smartfoxserver.v2.requests.PrivateMessageRequest;
    import com.smartfoxserver.v2.requests.PublicMessageRequest;
    import com.smartfoxserver.v2.requests.RoomExtension;
    import com.smartfoxserver.v2.requests.SetRoomVariablesRequest;
    import com.smartfoxserver.v2.requests.SetUserVariablesRequest;
    import com.smartfoxserver.v2.requests.game.CreateSFSGameRequest;
    import com.smartfoxserver.v2.requests.game.InvitationReplyRequest;
    import com.smartfoxserver.v2.requests.game.InviteUsersRequest;
    import com.smartfoxserver.v2.requests.game.SFSGameSettings;
    import com.willdom.games.bomberman.events.MessageEvent;
    import com.willdom.games.bomberman.user.UserLocalProperties;
    import com.willdom.games.explodersmmo.shared.model.CustomLogger;
    
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.sampler.NewObjectSample;
           
    [Event(name="publicMessage", type="jaludo.events.MessageEvent")]
    [Event(name="privateMessage", type="jaludo.events.MessageEvent")]
    [Event(name="systemMessage", type="jaludo.events.MessageEvent")]
    [Event(name="enterRoom", type="jaludo.events.UserEvent")]
    [Event(name="exitRoom", type="jaludo.events.UserEvent")]
    [Event(name="joinRoom", type="jaludo.events.UserEvent")]
    [Event(name="ready", type="jaludo.events.SmartFoxClientEvent")]
    [Event(name="connectionLost", type="jaludo.events.SmartFoxClientEvent")]
    [Event(name="roomLost", type="jaludo.events.RoomEvent")]
    [Event(name="roomAdded", type="jaludo.events.RoomEvent")]
    [Event(name="userCountChange", type="jaludo.events.UserCountEvent")]
    [Event(name="gameReady", type="jaludo.events.MessageEvent")]
    [Event(name="varsChanged", type="jaludo.events.RoomVarsEvent")]
    [Event(name="userVarsChanged", type="jaludo.events.UserVarsEvent")]
    [Event(name="roomCreationError", type="jaludo.events.ErrorEvent")]
    [Event(name="warning", type="jaludo.events.ModeratorEvent")]
    public class SmartFoxClient extends EventDispatcher
    {
        private var _sfs:SmartFox;
        private var _connectionHandler:ConnectionHandler;
        private var _eventProcessor:EventProcessor;
        
        private var _chatRoom:Room;
        private var _gameRoom:Room;
        private var _prevGameRoom:Room;
        
        private var _gameId:int;
        private var playerMessageSequence:Number;
        
        public function get chatRoom():Room { return _chatRoom; }
        public function get gameRoom():Room { return _gameRoom; }
        public function get prevGameRoom():Room { return _prevGameRoom; }
        public function set prevGameRoom(value:Room):void { _prevGameRoom = value; }
        
        public function SmartFoxClient(sfs:SmartFox,room:Room)
        {
            _sfs = sfs;
            _gameRoom = room;
            playerMessageSequence = 1;
            
            _connectionHandler = new ConnectionHandler();
            _eventProcessor = new EventProcessor(_sfs, this);
        }
        
        public function redirectExtensionResponsesTo(listener:EventDispatcher):void
        {
            _eventProcessor.redirectExtensionResponsesTo(listener);
        }
        
        public function reEngageExtensionResponses():void
        {
            _eventProcessor.reEngageExtensionResponses();
        }
        
        public function sendGameRequest(request:String, params:SFSObject = null):void
        {
            if (params == null)
            {
                params = new SFSObject();
            }
            var p:SFSObject = new SFSObject();
            p.putUtfString("r", request);
            p.putSFSObject("p", params);

            _sfs.send( new ExtensionRequest(request, p, _gameRoom));
        }
                
        public function joinWaitingList(isIn:Boolean):void{
            
            var sfsObject:SFSObject = new SFSObject();
            sfsObject.putBool(RequestCodes.IS_IN,isIn);
            SmartFoxClientSingleton.getInstance().smartFoxClient.sendExtensionRequestToGameRoom(RequestCodes.JOIN_WAITING_LIST,sfsObject);
        }
        
        public function getGamePlayersCount():int
        {
            var gamePlayers:uint = 0;
            for (var i:uint = 0; i < _gameRoom.playerList.length; i++)
            {
                if (!(_gameRoom.playerList[i] as User).isSpectator)
                {
                    gamePlayers ++;
                }
            }
            return gamePlayers;
        }
        
        public function sendExtensionRequestToGameRoom(request:String, params:SFSObject):void
        {
            if(gameRoom != null){
                if(params != null)
                {
                    params.putLong("playerSeq", playerMessageSequence++);
                }
                _sfs.send( new ExtensionRequest(request, params, gameRoom));
            }
        }
        
        public function addExtensionResponseListener(listener:Function):void
        {
            _sfs.addEventListener(SFSEvent.EXTENSION_RESPONSE, listener);
        }

        public function removeExtensionResponseListener(listener:Function):void
        {
            _sfs.removeEventListener(SFSEvent.EXTENSION_RESPONSE, listener);
        }
        
        public function leaveRoom():void
        {	
            if(_gameRoom!=null)
            {
                _sfs.send(new LeaveRoomRequest(_gameRoom));
                _gameRoom = null;
            }
        }
        
        public function get myself():User
        {
            return _sfs.mySelf;    
        }
        
        public function getPlayerByName(name:String):User
        {
            return _sfs.userManager.getUserByName(name);
        }

        public function get sfs():SmartFox
        {
            return _sfs;
        }

        public function set sfs(value:SmartFox):void
        {
            _sfs = value;
        }

        
    }
}