package com.willdom.games.bomberman.events
{
    import com.smartfoxserver.v2.entities.Room;
    import com.smartfoxserver.v2.entities.User;
    
    import flash.events.Event;
    
    public class UserEvent extends Event
    {
        public static const JOIN_ROOM:String = "joinRoom";
        public static const ENTER_ROOM:String = "enterRoom";
        public static const EXIT_ROOM:String = "exitRoom";
        public static const JOIN_MONITOR_ROOM:String = "joinMonitorRoom";
        public static const JOIN_MATCHMAKING_ROOM:String = "joinMatchMakingRoom";
        
        public var user:User;
        public var room:Room;
        
        public function UserEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
        {
            super(type, bubbles, cancelable);
        }
        
        override public function clone():Event
        {
            var e:UserEvent = new UserEvent(this.type);
            e.room = this.room;
            e.user = this.user;
            
            return e;
        }
    }
}