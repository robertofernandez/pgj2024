package com.willdom.games.bomberman.usableItems
{
    public class UsableItem
    {
        protected var _usesLeft:int;
        protected var _type:String;
        
        public function UsableItem(uses:int, type:String)
        {
            _usesLeft = uses;
            _type = type;
        }
        
        public function get usesLeft():int
        {
            return _usesLeft;
        }
        
        public function get type():String
        {
            return _type;
        }
        
        public function useItem():void
        {
            
        }
        
        public function consumeItem():void
        {
            _usesLeft--;
        }
    }
}