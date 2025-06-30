package com.willdom.games.bomberman.gameobjects.items
{
    public class AbstractItemAmmountDescription implements ItemAmountDescription
    {
        public function AbstractItemAmmountDescription()
        {

        }
        
        public function setValue(itemType:uint,value:uint):void
        {
        }
        
        public function getAmount(itemType:uint):uint
        {
            return 1;
        }
        
        public function get itemsList():Array
        {
            var list:Array=new Array();
            for(var itemType:int=0; itemType < ItemTypes.TOTAL_ITEMS; itemType++)
            {
                for(var itemNumber:int=0; itemNumber < getAmount(itemType); itemNumber++)
                {
                    list.push(itemType);
                }
            }
            return list;
        }
    }
}