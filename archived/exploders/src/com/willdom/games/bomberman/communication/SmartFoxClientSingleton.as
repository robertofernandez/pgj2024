package com.willdom.games.bomberman.communication
{
    import com.smartfoxserver.v2.SmartFox;
    import com.smartfoxserver.v2.entities.Room;

    public class SmartFoxClientSingleton
    {

        protected static var _instance:SmartFoxClientSingleton = new SmartFoxClientSingleton();
        private var _smartFoxClient:SmartFoxClient;
        public function get smartFoxClient():SmartFoxClient { return _smartFoxClient; }
        public function set smartFoxClient(value:SmartFoxClient):void {
            if (_smartFoxClient != null)
                throw new Error("sfs can be set only one time.");
            _smartFoxClient = value;
        }
        
        public function SmartFoxClientSingleton()
        {
            if (_instance != null )
            {
                throw new Error( "Only one InviteController instance should be instantiated" );
            } 
        }
        
        public function init(sfs:SmartFox,room:Room):void
        {
            _smartFoxClient = new SmartFoxClient(sfs,room);
        }
        
        public static function getInstance():SmartFoxClientSingleton
        {
            return _instance;
        }
    }
}