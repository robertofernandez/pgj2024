package com.willdom.games.bomberman.communication
{
    import flash.events.Event;
    
    public class SoundEvent extends Event
    {
        
        public static const SOUND_CHANGED:String = "soundChanged";
        public static const MUSIC_CHANGED:String = "musicChanged";
        
        public var state:Boolean;
        
        public function SoundEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
        {
            super(type, bubbles, cancelable);
        }
    }
}