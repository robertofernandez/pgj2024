package com.willdom.games.bomberman.position{
    
    import flash.events.Event;
    
    public class PositionEvent extends Event{
        //TODO: check if we need serial in event
        public var serialNumber:uint;
        public var tileX:uint;
        public var tileY:uint;
        public var userId:String;
        
        public static const PERSON_POSITION_CONFIRMATION:String="personPositionConfirmation";
        public static const PERSON_POSITION_CANCELATION:String="personPositionCancelation";
        public static const PERSON_START_MOVING_CONFIRMATION:String="personStartMovingConfirmation";
        public static const PERSON_START_MOVING_CANCELATION:String="personStartMovingCancelation";

        public function PositionEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
        {
            super(type, bubbles, cancelable);
        }
    }
}