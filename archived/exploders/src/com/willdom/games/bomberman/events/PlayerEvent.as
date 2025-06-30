package com.willdom.games.bomberman.events
{
    import flash.events.Event;
    
    public class PlayerEvent extends Event
    {
        
        public static const USER_QUIT:String = "userQuit";
        public static const PLAYER_KILL:String = "playerKill";
        public static const PLAYER_SELECTED:String = "playerSelected";
        public static const HOST_DISCONNECTED:String = "hostDisconnected";
        public static const PLAYER_COMMAND:String = "playerCommand";
        
        public function PlayerEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
        {
            super(type, bubbles, cancelable);
        }
    }
}