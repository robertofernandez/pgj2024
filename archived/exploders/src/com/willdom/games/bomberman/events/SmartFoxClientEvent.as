package com.willdom.games.bomberman.events
{
    import com.smartfoxserver.v2.entities.Room;
    
    import flash.events.Event;
    
    public class SmartFoxClientEvent extends Event
    {
        public static const READY:String = "ready";
        public static const CONNECTION_LOST:String = "connectionLost";
        
        public var chatRoom:Room;
        public var reason:String;
        
        public function SmartFoxClientEvent(type:String = READY, bubbles:Boolean=false, cancelable:Boolean=false)
        {
            super(type, bubbles, cancelable);
        }
    }
}