package com.willdom.games.bomberman.gameobjects.items
{
    public class AbstractItemAmmountDescriptionWithAmountsArray extends AbstractItemAmmountDescription
    {
        protected var amounts:Array;

        public function AbstractItemAmmountDescriptionWithAmountsArray()
        {
            super();
            amounts = new Array();
        }
        
        override public function setValue(itemType:uint,value:uint):void{
            amounts[itemType] = value;
        }
        
        override public function getAmount(itemType:uint):uint
        {
            return amounts[itemType];
        }
    }
}