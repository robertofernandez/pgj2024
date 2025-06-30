package com.willdom.games.bomberman.statemachine
{
    import com.smartfoxserver.v2.entities.data.SFSObject;
    
    import flash.utils.Dictionary;
    
    public class BasicStatusWithEventHandling implements Status
    {
        private var _handlers:Dictionary;
        
        public function BasicStatusWithEventHandling()
        {
            _handlers = new Dictionary();
        }
        
        public function init(params:SFSObject):void
        {
            throw new Error("Subclasses must override this function");
        }
        
        /**
        * @param type String representing the , func:Function
        */
        public function registerFunction(type:String, func:Function):void
        {
            _handlers[type] = func;
        }
        
        public function handleMessage(type:String, params:SFSObject):void
        {
            if(_handlers[type] != null)
            {
                (_handlers[type] as Function).call(null,params);
            }
        }
        
        public function dispose(params:SFSObject):void
        {
            throw new Error("Subclasses must override this function");
        }
    }
}