package com.willdom.games.bomberman.position.maps
{
    public class CellTypes
    {
        public static const EMPTY_CELL:uint = 0;
        public static const HARD_BLOCK:uint = 1;
        public static const BOX:uint = 2;
        public static const ITEM:uint = 3;
        public static const HOLE:uint = 4;
        public static const SOFT_BLOCK_ALWAYS_ITEM_CLOSED:uint = 5;
        public static const SOFT_BLOCK_RANDOM_ITEM_OPEN:uint = 7;
        
        public function CellTypes()
        {
        }
    }
}