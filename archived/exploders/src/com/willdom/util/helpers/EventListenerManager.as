package com.willdom.util.helpers
{
    import flash.events.EventDispatcher;

    public class EventListenerManager
    {
        
        private static var allListeners:Array = [];
        
        public function EventListenerManager()
        {        
        }
        
        public static function setListenerTo(target:EventDispatcher, event:String, listener:Function, useCapture:Boolean = false, priority:int = 0, weakReference:Boolean = true):void
        {
            target.addEventListener(event, listener, useCapture, priority, weakReference);
            allListeners.push({target:target, event:event, listener:listener});
        }
        
        public static function removelistenerFrom(target:EventDispatcher, event:String, listener:Function):void
        {
            for (var i:uint = 0; i < allListeners.length; i++)
            {
                if(allListeners[i].target == target && allListeners[i].event == event && allListeners[i].listener == listener)
                {
                    target.removeEventListener(event, listener);
                    allListeners.splice(i,1);
                }                
            }
        }
        
        public static function hasEventListener(target:EventDispatcher, type:String):Boolean
        {
            for (var i:uint = 0; i < allListeners.length; i++)
            {
                if(allListeners[i].target == target)
                {
                    if(target.hasEventListener(type))
                    {
                        return true;
                    }
                }
            }
            
            return false;
        }
        
        public static function dispose():void
        {
            
            while(allListeners.length>0)
            {
                var thisListener:Object = allListeners.pop();
                
                if ((thisListener.target as EventDispatcher).hasEventListener(thisListener.event))
                {
                    (thisListener.target as EventDispatcher).removeEventListener(thisListener.event, thisListener.listener);
                }
            }
        }
    }
}