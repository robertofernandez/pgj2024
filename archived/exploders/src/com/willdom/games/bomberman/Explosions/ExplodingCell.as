package com.willdom.games.bomberman.Explosions
{
    import flash.geom.Point;

    public class ExplodingCell
    {
        private var _tilePoint:Point;
        private var _explosionChunks:Array;
        
        public function ExplodingCell(tilePoint:Point)
        {
            _tilePoint = tilePoint;
            _explosionChunks = new Array();
        }
        
        public function addChunk(chunk:ExplosionChunk):void
        {
            _explosionChunks.push(chunk);
        }
        
        public function containsChunk(direction:int):Boolean
        {
            for each (var chunk:ExplosionChunk in _explosionChunks) 
            {
                if(chunk.direction == direction)
                {
                    return true;
                }
            }
            return false;            
        }
        
        public function containsChunkWithTypeAndDirection(tile:Point, chunckType:int, direction:int):Boolean
        {
            for each (var chunk:ExplosionChunk in _explosionChunks) 
            {
                if(chunk.direction == direction && chunk.chunkType == chunckType)
                {
                    return true;
                }
            }
            return false;
        }
        
        public function containsChunkWithType(tile:Point, chunckType:int):Boolean
        {
            for each (var chunk:ExplosionChunk in _explosionChunks) 
            {
                if(chunk.chunkType == chunckType)
                {
                    return true;
                }
            }
            return false;
        }

        public function get tilePoint():Point
        {
            return _tilePoint;
        }
        
        public function get x():int
        {
            return _tilePoint.x;
        }
        
        public function get y():int
        {
            return _tilePoint.y;
        }

        public function get explosionChunks():Array
        {
            return _explosionChunks;
        }
    }
}