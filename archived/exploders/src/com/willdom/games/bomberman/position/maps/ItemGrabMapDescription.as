package com.willdom.games.bomberman.position.maps
{
    import com.gq.system.GameData;
    import com.gq.system.Map;
    
    import flash.display.DisplayObject;

    public class ItemGrabMapDescription extends MovieClipBasedMapDescription
    {
        public function ItemGrabMapDescription(displayObject:DisplayObject, mapName:String)
        {
            super(displayObject, mapName);
        }
        
        override public function getRandomPositions():Array {
            return getFixedPositions();
        }
    }
}