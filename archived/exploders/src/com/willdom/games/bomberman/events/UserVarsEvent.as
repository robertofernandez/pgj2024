package com.willdom.games.bomberman.events
{
    import com.smartfoxserver.v2.entities.User;
    
    import flash.events.Event;
    
    public class UserVarsEvent extends Event
    {
        public static const USER_VARS_CHANGED:String = "userVarsChanged";
        
        public var user:User;
        public var vars:Array;
        
        public function UserVarsEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
        {
            super(type, bubbles, cancelable);
        }
    }
}