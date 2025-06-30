package com.willdom.games.bomberman.gameobjects.items
{
    public class EmptyItemAmountDescription implements ItemAmountDescription
    {
        public function EmptyItemAmountDescription()
        {
        }
        
        public function getAmount(itemType:uint):uint
        {
            return 0;
        }
        
        public function get itemsList():Array
        {
            return new Array();
        }
    }
}