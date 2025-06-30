package com.willdom.games.bomberman.gameobjects.items
{
    public interface ItemAmountDescription
    {
        
        function setValue(itemType:uint,value:uint):void;
         
        function getAmount(itemType:uint):uint;

        function get itemsList():Array;
    }
}