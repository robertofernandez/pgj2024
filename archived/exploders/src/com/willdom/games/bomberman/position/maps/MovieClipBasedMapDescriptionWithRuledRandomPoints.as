package com.willdom.games.bomberman.position.maps
{
    import flash.display.DisplayObject;
    import flash.geom.Point;
    
    public class MovieClipBasedMapDescriptionWithRuledRandomPoints extends MovieClipBasedMapDescription
    {
        private var cachedRandomPositions:Array;
        
        public function MovieClipBasedMapDescriptionWithRuledRandomPoints(movieClip:DisplayObject, mapName:String)
        {
            super(movieClip, mapName);
        }
        
        override public function getRandomPositions():Array {
            if(cachedRandomPositions != null){
                return cachedRandomPositions;
            }
            var pointsBlock:Array = new Array();
            for(var y:int=0; y < height; y++)
            {
                for(var x:int=0; x < width; x++)
                {
                    var pixelValue:uint = data.getPixel(x, y);
                    if(isEmptyCellColor(pixelValue))
                    {
                        if(!checkBlocks(x,y,pointsBlock)){
                            pointsBlock.push(checkAdjacentTiles(x,y));
                        }
                    }
                }
            }
            
            cachedRandomPositions = filterPositions(pointsBlock);

            return cachedRandomPositions;
        }
        
        private function filterPositions(pointsBlock:Array):Array
        {
            var output:Array = new Array();
            for (var i:int = 0; i < pointsBlock.length; i++) 
            {
                if((pointsBlock[i] as PointsBlock).size > 2){
                    output.push(pointsBlock[i] as PointsBlock);
                }
            }
            return output;
        }
        
        private function checkBlocks(x:int, y:int, blocks:Array):Boolean
        {
            for each (var block:PointsBlock in blocks){
                if(block.contains(new Point(x,y))){
                    return true;
                }
            }
            return false;
        }
        
        private function checkAdjacentTiles(x:int, y:int):PointsBlock
        {
            var block:PointsBlock = new PointsBlock(width,height);
            block.addPoint(new Point(x,y));            
            
            check(x+1,y,block);
            check(x-1,y,block);
            check(x,y+1,block);
            check(x,y-1,block);
                
            return block;
        }
        
        private function check(x:int, y:int, block:PointsBlock):void
        {
            if(x >= width || y >= height || x < 0 || y < 0){
                return;
            }
            var pixelValue:uint = data.getPixel(x, y);
            if(isEmptyCellColor(pixelValue))
            {
                if(block.contains(new Point(x,y))){
                    return;
                }else{
                    block.addPoint(new Point(x,y));
                    check(x+1,y,block);
                    check(x-1,y,block);
                    check(x,y+1,block);
                    check(x,y-1,block);
                }
            }
        }
    }
}