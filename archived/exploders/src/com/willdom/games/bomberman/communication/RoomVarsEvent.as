package com.willdom.games.bomberman.communication
{
    import com.smartfoxserver.v2.entities.Room;
    
    import flash.events.Event;
    
    public class RoomVarsEvent extends Event
    {
        public static const VARS_CHANGED:String = "varsChanged";
        
        public var room:Room;
        public var vars:Array;
        
        public function RoomVarsEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
        {
            super(type, bubbles, cancelable);
        }
    }
}