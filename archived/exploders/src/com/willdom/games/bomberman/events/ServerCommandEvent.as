package com.willdom.games.bomberman.events
{
    import com.smartfoxserver.v2.entities.data.ISFSObject;
    import com.smartfoxserver.v2.entities.data.SFSObject;
    
    import flash.events.Event;
    
    public class ServerCommandEvent extends Event
    {
        public static const INSTRUCTION:String = "sie";
        
        public var command:String;
        public var params:ISFSObject;
        
        public function ServerCommandEvent(command:String, params:ISFSObject, type:String = INSTRUCTION, bubbles:Boolean=false, cancelable:Boolean=false)
        {
            this.command = command;            
            this.params = params;
            super(type, bubbles, cancelable);
        }
    }
}