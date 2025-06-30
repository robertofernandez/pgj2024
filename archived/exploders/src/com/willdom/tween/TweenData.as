package com.willdom.tween
{
    import flash.display.MovieClip;
    
    public class TweenData
    {
        private var _initialValue:Number;
        private var _finalValue:Number;
        private var _target:Object;
        private var _property:String;
        private var _currentVel:Number;
        private var _running:Boolean;
        
        public function TweenData(finalValue:Number, target:Object, property:String)
        {
            if (property == "frame" && target is MovieClip)
            {
                this._initialValue = (target as MovieClip).currentFrame;
            }
            else
            {
                this._initialValue = target[property];
            }
            this._target = target;
            this._property = property;
            this._finalValue = finalValue;
        }
        
        public function get running():Boolean
        {
            return _running;
        }
        
        public function set running(value:Boolean):void
        {
            _running = value;
        }
        
        public function get initialValue():Number
        {
            return _initialValue;
        }
        
        public function get finalValue():Number
        {
            return _finalValue;
        }
        
        public function get property():String
        {
            return _property;
        }
        
        public function get currentVel():Number
        {
            return _currentVel;
        }
        
        public function set currentVel(value:Number):void
        {
            _currentVel = value;
        }
        
        public function get target():Object
        {
            return _target;
        }
        
        
    }
}