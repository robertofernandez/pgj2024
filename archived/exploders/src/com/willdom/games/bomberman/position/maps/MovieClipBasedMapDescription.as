package com.willdom.games.bomberman.position.maps
{
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.DisplayObject;
    import flash.geom.Point;

    public class MovieClipBasedMapDescription implements MapDescription
    {
        public static const HARD_BLOCK_COLOR_VALUE:int = 0x646464;
        public static const BOX_COLOR_VALUE:int = 0xFF0000;
        public static const GRASS_COLOR_VALUE:int = 0x00FF00;
        public static const ITEM_COLOR_VALUE:int = 0x0000FF;
        public static const FIXED_POSITION_FILTER:int = 0x0000FF;
        public static const FIXED_POSITION_VALUE:int = 0x000099;
        public static const RANDOM_POSITION_FILTER:int = 0x00FF00;
        public static const RANDOM_POSITION_VALUE:int = 0x009900;

        protected var data:BitmapData;
        protected var elementsTable:Object;
        
        protected var width:uint;
        protected var height:uint;
        
        private var _mapName:String;
        
        public static function isEmptyCellColor(color:uint):Boolean {
            return (color != HARD_BLOCK_COLOR_VALUE && color != BOX_COLOR_VALUE);
        }
        
        public function MovieClipBasedMapDescription(movieClip:DisplayObject, mapName:String)
        {
            _mapName = mapName;
            elementsTable = new Object();
            elementsTable[BOX_COLOR_VALUE] = CellTypes.BOX;
            elementsTable[HARD_BLOCK_COLOR_VALUE] = CellTypes.HARD_BLOCK;
            elementsTable[ITEM_COLOR_VALUE] = CellTypes.ITEM;
            elementsTable[GRASS_COLOR_VALUE] = CellTypes.EMPTY_CELL;

            width = movieClip.width,
            height = movieClip.height;

            data = new BitmapData(width, height);
            data.draw(movieClip);
        }
        
        public function get mapName():String
        {
            return _mapName;
        }
        
        public function getObjectType(x:Number, y:Number):uint
        {
            var pixelValue:int = data.getPixel(x, y);
            if(elementsTable[pixelValue] != null){
                return elementsTable[pixelValue];
            } else {
                return CellTypes.EMPTY_CELL;
            }
        }
        
        public function getFixedPositions():Array {
            var pointsBlock:Array = new Array();
            for(var x:int=0; x < width; x++)
            {
                for(var y:int=0; y < height; y++)
                {
                    var pixelValue:uint = data.getPixel(x, y);
                    var filteredValue:uint = pixelValue & FIXED_POSITION_FILTER;
                    if(filteredValue == FIXED_POSITION_VALUE)
                    {
                        var block:PointsBlock = new PointsBlock(width,height);
                        block.addPoint(new Point(x,y));    
                        pointsBlock.push(block);
                    }
                }
            }
            
            var tempArray:Array = getFixedOrderOfArray(pointsBlock);
            //pointsBlock.sortOn(["distance", "orderInMatrix"],[Array.DESCENDING|Array.NUMERIC, Array.NUMERIC]);
            
            return tempArray;
        }
        
        private function getFixedOrderOfArray(blocks:Array):Array
        {
            var supArray:Array = new Array();
            var infArray:Array = new Array();
            blocks.sortOn("ySorting", Array.NUMERIC);
            for (var i:int = 0; i < blocks.length; i++) 
            {
                if(i < 4){
                    supArray.push(blocks[i]);
                }else{
                    infArray.push(blocks[i]);
                }
            }
            supArray.sortOn(["distance", "angle"], [Array.DESCENDING | Array.NUMERIC, Array.NUMERIC]);
            infArray.sortOn(["distance", "angle"], [Array.DESCENDING | Array.NUMERIC, Array.NUMERIC]);
            var tempArray:Array = new Array();
            var indexSup:int = 0;
            var indexInf:int = 0;
            for (var j:int = 0; j < blocks.length; j++) 
            {
                if(j%2 == 0){
                    tempArray.push(supArray[indexSup]);
                    indexSup++;
                }else{
                    tempArray.push(infArray[indexInf]);
                    indexInf++;
                }
            }
            
            return tempArray;
        }

        public function getRandomPositions():Array {
            var positions:Array = new Array();
            for(var x:int=0; x < width; x++)
            {
                for(var y:int=0; y < height; y++)
                {
                    var pixelValue:uint = data.getPixel(x, y);
                    var filteredValue:uint = pixelValue & RANDOM_POSITION_FILTER;
                    if(filteredValue == RANDOM_POSITION_VALUE)
                    {
                        positions.push(new Point(x, y));
                    }
                }
            }
            return positions;
        }
    }
}