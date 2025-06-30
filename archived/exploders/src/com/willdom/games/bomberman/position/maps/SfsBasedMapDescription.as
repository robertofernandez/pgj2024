package com.willdom.games.bomberman.position.maps
{
    import com.smartfoxserver.v2.entities.data.ISFSArray;
    import com.smartfoxserver.v2.entities.data.SFSArray;

    /**
    * Class to represent map descriptions that can be modified, for example, by data obtained from server. 
    */
    public class SfsBasedMapDescription implements MapDescription
    {
        private var witdh:int;
        private var height:int;
        private var elementsArray:ISFSArray
        private var _mapName:String;

        public function SfsBasedMapDescription(mapName:String, mapDescription:ISFSArray)
        {
            _mapName = mapName;
            elementsArray = mapDescription;

            // current map size is fixed
            setMapSize(17, 15);
        }

        public function setMapSize(witdh:int, height:int):void
        {
            this.witdh = witdh;
            this.height = height;
        }

        public function getObjectType(x:Number, y:Number):uint
        {
            return elementsArray.getInt(x + y * witdh);
        }
        
        public function set mapName(name:String):void
        {
            _mapName = name;
        }

        public function get mapName():String
        {
            return _mapName;
        }
    }
}