package com.willdom.games.bomberman.events
{
    import com.gq.moveobject.Person;
    
    import flash.events.Event;
    
    public class PersonEvent extends Event
    {
        
        public static const TIMED_OUT:String = "timedOut";
        
        public var person:Person;
        
        public function PersonEvent(type:String, person:Person, bubbles:Boolean=false, cancelable:Boolean=false)
        {
            super(type, bubbles, cancelable);
            
            this.person = person;
            
        }
    }
}