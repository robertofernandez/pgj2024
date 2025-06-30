package com.willdom.games.bomberman.events
{
    import com.smartfoxserver.v2.entities.Room;
    import com.smartfoxserver.v2.entities.User;
    import com.smartfoxserver.v2.entities.data.SFSObject;
    
    import flash.events.Event;
    
    public class MessageEvent extends Event
    {
        public static const PUBLIC_MESSAGE:String = "publicMessage";
        public static const PRIVATE_MESSAGE:String  = "privateMessage";
        public static const SYSTEM_MESSAGE:String = "systemMessage";
        public static const GAME_MESSAGE:String = "gameMessage";
        public static const GAME_START:String = "gameStart";
        public static const GAME_REMATCH_STARTED:String = "gameRematch";
        public static const GAME_RESTART:String = "gameRestart";
        public static const GENERIC_MESSAGE:String = "genericMessage";
        public static const GAME_READY:String = "gameReady";
        public static const SEED_VALUE:String = "seedValue";
        public static const GAME_SURRENDER:String = "gameSurrender";
        public static const BEGIN_GAME:String = "beginGame";
        public static const END_GAME:String = "endGame";
        public static const SYNC_FINISHED:String = "syncSpecFinished";
        
        public var sender:User;
        public var message:String;
        public var room:Room;
        public var params:SFSObject;
        
        public function MessageEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
        {
            super(type, bubbles, cancelable);
        }
        
        override public function clone():Event
        {
            var e:MessageEvent = new MessageEvent(this.type);
            e.message = this.message;
            e.sender = this.sender;
            e.params = this.params;
            e.room = this.room;
            
            return e;
        }
    }
}