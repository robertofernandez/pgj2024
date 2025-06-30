package com.willdom.games.bomberman.usableItems
{
    import com.gq.system.GameData;

    public class UsableItemWarp extends UsableItem
    {
        public function UsableItemWarp(uses:int, type:String)
        {
            super(uses, type);
        }
        
        public override function useItem():void
        {
            GameData.instance.positionManager.requestWarpMove();
        }
    }
}