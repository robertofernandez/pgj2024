package com.willdom.games.bomberman.position.maps
{
    import com.gq.moveobject.MoveObject;
    import com.gq.moveobject.ObjectHole;
    import com.gq.moveobject.Objects;
    import com.gq.moveobject.Treasure;
    import com.gq.system.GameData;
    
    import flash.geom.Point;

    public class DescriptionBasedMapGenerator implements MapGenerator
    {
        private var mapDescription:MapDescription;
        private var _boxes:Array;
        private var _immediateOpenBoxes:Array;
        private var _itemsPositions:Array;
        private var _alwaysItemBoxes:Array;
        
        public function DescriptionBasedMapGenerator(mapDescription:MapDescription)
        {
            this.mapDescription = mapDescription;
            _boxes = new Array();
            _alwaysItemBoxes = new Array();
            _immediateOpenBoxes = new Array();
        }

        public function generateMap():void
        {
            var itemNumber:int = 0;
            for(var x:int=0; x < GameData.instance.widthNum; x++)
            {
                for(var y:int=0; y < GameData.instance.heightNum; y++)
                {
                    var itemType:uint = mapDescription.getObjectType(x, y);
                    var obj:String;
                    var box:MoveObject;
                    var width:Number;
                    var height:Number;
                    switch (itemType)
                    {
                        case CellTypes.ITEM:
                            if(GameData.DEBUG_MODE)
                            {
                                trace("[com.willdom.games.bomberman.position.maps.DescriptionBasedMapGenerator] adding item to cell <" +x + ", " + y + ">");
                            }
                            obj = "Box" + GameData.instance.mapName + "_1";
                            width = (x + 0.5) * GameData.instance.rectWidth;
                            height =  (y + 0.5) * GameData.instance.rectHeight + GameData.instance.upLine;
                            box = GameData.instance.creater.createObj("person","Objects", obj, width, height, 0, [] ) as Objects;
                            GameData.instance.positionManager.addObjectToMap(x, y, box);
                            _boxes.push(box);
                            //_immediateOpenBoxes.push(box);
                            break;
                        case CellTypes.BOX:
                            if(GameData.DEBUG_MODE)
                            {
                                trace("[com.willdom.games.bomberman.position.maps.DescriptionBasedMapGenerator] adding box to cell <" +x + ", " + y + ">");
                            }
                            obj = "Box" + GameData.instance.mapName + "_1";
                            width = (x + 0.5) * GameData.instance.rectWidth;
                            height =  (y + 0.5) * GameData.instance.rectHeight + GameData.instance.upLine;
                            box = GameData.instance.creater.createObj("person","Objects", obj, width, height, 0, [] ) as Objects;
                            GameData.instance.positionManager.addObjectToMap(x, y, box);
                            _boxes.push(box);
                            break;
                        case CellTypes.HARD_BLOCK:
                            if(GameData.DEBUG_MODE)
                            {
                                trace("[com.willdom.games.bomberman.position.maps.DescriptionBasedMapGenerator] adding hard block to cell <" +x + ", " + y + ">");
                            }

                            var hardBlock:Objects = GameData.instance.creater.createObj( "person",
                                "Objects", 
                                "Box" + GameData.instance.mapName + "_2",
                                (x + 0.5) * GameData.instance.rectWidth,
                                (y + 0.5) * GameData.instance.rectHeight + GameData.instance.upLine, 0, [] ) as Objects;
                            GameData.instance.positionManager.addObjectToMap(x, y, hardBlock);
                            break;
                        case CellTypes.HOLE:
                            if(GameData.DEBUG_MODE)
                            {
                                trace("[com.willdom.games.bomberman.position.maps.DescriptionBasedMapGenerator] hole block to cell <" +x + ", " + y + ">");
                            }
                            
                            var hole:ObjectHole = GameData.instance.creater.createObj( "person",
                                "ObjectHole", 
                                "Box" + GameData.instance.mapName + "_2",
                                (x + 0.5) * GameData.instance.rectWidth,
                                (y + 0.5) * GameData.instance.rectHeight + GameData.instance.upLine, 0, [] ) as ObjectHole;
                            GameData.instance.positionManager.addObjectToMap(x, y, hole);
                            break;
                        case CellTypes.SOFT_BLOCK_RANDOM_ITEM_OPEN:
                            if(GameData.DEBUG_MODE)
                            {
                                trace("[com.willdom.games.bomberman.position.maps.DescriptionBasedMapGenerator] adding box to cell <" +x + ", " + y + ">");
                            }
                            obj = "Box" + GameData.instance.mapName + "_1";
                            width = (x + 0.5) * GameData.instance.rectWidth;
                            height =  (y + 0.5) * GameData.instance.rectHeight + GameData.instance.upLine;
                            box = GameData.instance.creater.createObj("person","Objects", obj, width, height, 0, [] ) as Objects;
                            GameData.instance.positionManager.addObjectToMap(x, y, box);
                            box.open = true;
                            //_boxes.push(box);
                            _alwaysItemBoxes.push(box);
                            _immediateOpenBoxes.push(box);
                            break;
                        case CellTypes.SOFT_BLOCK_ALWAYS_ITEM_CLOSED:
                            if(GameData.DEBUG_MODE)
                            {
                                trace("[com.willdom.games.bomberman.position.maps.DescriptionBasedMapGenerator] adding box to cell <" +x + ", " + y + ">");
                            }
                            obj = "Box" + GameData.instance.mapName + "_1";
                            width = (x + 0.5) * GameData.instance.rectWidth;
                            height =  (y + 0.5) * GameData.instance.rectHeight + GameData.instance.upLine;
                            box = GameData.instance.creater.createObj("person","Objects", obj, width, height, 0, [] ) as Objects;
                            GameData.instance.positionManager.addObjectToMap(x, y, box);
                            _alwaysItemBoxes.push(box);
                            break;
                        default:
                            break;
                    }
                }
            }
        }

        public function get boxes():Array
        {
            return _boxes;
        }
        
        public function get immediateOpenBoxes():Array
        {
            return _immediateOpenBoxes;
        }
        
        public function get alwaysItemBoxes():Array
        {
            return _alwaysItemBoxes;
        }
    }
}