package com.gq.moveobject
{
    public class SkullBuffs
    {
        
        private var _speed:Number;
        private var _maxBomb:uint;
        private var _power:uint;
        private var _type:String;
        
        public var isActive:Boolean;
        
        public function SkullBuffs()
        {
            isActive = false;
        }
        
        public function resetBuffs():void
        {
            speed = 0;
            maxBomb = 0;
            power = 0;
        }
        
        public function deactivateBuff():void{
            
            if(speed == 0 && maxBomb == 0 && power == 0){
                isActive = false;
            }
            
        }

        public function get speed():Number
        {
            return _speed;
        }

        public function set speed(value:Number):void
        {
            _speed = value;
        }

        public function get power():uint
        {
            return _power;
        }

        public function set power(value:uint):void
        {
            _power = value;
        }

        public function get maxBomb():uint
        {
            return _maxBomb;
        }

        public function set maxBomb(value:uint):void
        {
            _maxBomb = value;
        }

        public function get type():String
        {
            return _type;
        }
        
        public function set type(value:String):void
        {
            _type = value;
        }
    }
}