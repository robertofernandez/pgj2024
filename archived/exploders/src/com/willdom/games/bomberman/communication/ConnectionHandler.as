package com.willdom.games.bomberman.communication
{
    import com.smartfoxserver.v2.SmartFox;
    import com.smartfoxserver.v2.core.SFSEvent;
    import com.smartfoxserver.v2.entities.data.SFSObject;
    import com.smartfoxserver.v2.requests.LoginRequest;
    import com.smartfoxserver.v2.requests.SubscribeRoomGroupRequest;
    import com.willdom.games.bomberman.communication.SmartFoxClientSingleton;
    import com.willdom.games.bomberman.config.GameConfigManager;
    import com.willdom.games.explodersmmo.shared.model.LocalUser;
    
    public class ConnectionHandler
    {
        private var _sfs:SmartFox;
        private var _desiredUserName:String;
        private var _desiredPassword:String;
        private var _gameId:int;
        private var _configUrl:String;
        
        private var reconnecting:Boolean = false;
        
        public function ConnectionHandler()
        {
        }
        
        public function connect(sfs:SmartFox, username:String, password:String, gameId:int, url:String):void
        {
            _gameId = gameId;
            _sfs = sfs;
            
            _desiredUserName = username;
            _desiredPassword = password;

            _configUrl = url;
            
            // Add SFS2X event listeners
            _sfs.addEventListener(SFSEvent.CONNECTION, onConnection);
            _sfs.addEventListener(SFSEvent.CONNECTION_LOST, onConnectionLost);
            _sfs.addEventListener(SFSEvent.CONFIG_LOAD_SUCCESS, onConfigLoadSuccess);
            _sfs.addEventListener(SFSEvent.CONFIG_LOAD_FAILURE, onConfigLoadFailure);
            
            trace("SmartFox API: " + _sfs.version)
            
            _sfs.loadConfig(_configUrl)
        }
                
        private function onConnection(evt:SFSEvent):void
        {
            if (evt.params.success)
            {
                trace("Connection Success!")
                reconnecting = false;
                Login();
            }
            else
            {
                trace("Connection Failure: " + evt.params.errorMessage)
                SmartFoxClientSingleton.getInstance().smartFoxClient.dispatchEvent( new SFSEvent(SFSEvent.LOGIN_ERROR,null) );
            }
        }
        
        private function onConnectionLost(evt:SFSEvent):void
        { 
            trace("Connection was lost. Reason: " + evt.params.reason)
            if(reconnecting){
                _sfs.loadConfig(_configUrl);
            }
        }
        
        private function onConfigLoadSuccess(evt:SFSEvent):void
        {
            trace("Config load success!")
            trace("Server settings: " + _sfs.config.host + ":" + _sfs.config.port)
        }
        
        private function onConfigLoadFailure(evt:SFSEvent):void
        {
            trace("Config load failure!!!")
            _sfs.connect("192.168.1.18", 9933);
            
            // _sfs.connect("willdom.dyndns-server.com", 9933);
        }
        
        private function Login():void
        {    
            _sfs.addEventListener(SFSEvent.LOGIN, onLogin);
            _sfs.addEventListener(SFSEvent.LOGIN_ERROR, onLoginError);
            
            var params:SFSObject = new SFSObject();
            params.putInt(ParamCodes.GAME_ID, _gameId);
            params.putUtfString(ParamCodes.TOKEN, LocalUser.getInstance().token);
            params.putUtfString(ParamCodes.HASH, LocalUser.getInstance().hash);
            
            _sfs.send( new LoginRequest(_desiredUserName,_desiredPassword,GameConfigManager.getInstance().sharedZone, params));
            
        }
        
        public function retryLogin():void{
            
            reconnecting = true;
            _sfs.disconnect();
        }
        
        private function onLogin(e:SFSEvent):void
        {
            _sfs.addEventListener(SFSEvent.ROOM_JOIN_ERROR, onRoomJoinError);
            _sfs.send(new SubscribeRoomGroupRequest("game_" + _gameId.toString()));
        }
        
        private function onLoginError(e:SFSEvent):void
        {
            trace("Login Error");
            SmartFoxClientSingleton.getInstance().smartFoxClient.dispatchEvent( e.clone() );
        }
        
        private function onRoomJoinError(e:SFSEvent):void
        {
            SmartFoxClientSingleton.getInstance().smartFoxClient.dispatchEvent( e.clone() );
        }
    }
}