package com.willdom.tween
{
    import flash.events.Event;

    public class TweenEvent extends Event
    {
        public static const COMPLETE:String = "complete";
        
        public var params:Object;
        
        public function TweenEvent(type:String,bubbles:Boolean=false,cancelable:Boolean=false, params:Object = null)
        {
            this.params = params;
            super(type,bubbles,cancelable);
        }
    }
}