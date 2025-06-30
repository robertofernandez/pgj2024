package com.willdom.games.bomberman.Explosions
{
    import com.gq.moveobject.Bomb;
    import com.willdom.games.bomberman.position.PositionManager;
    
    import flash.geom.Point;

    public class ExplosionChunk
    {
        public static const NORMAL_BOMB_CHUNK:int = 0;
        public static const CORRIDOR_CHUNK:int = 1;
        public static const STOPPER_CHUNK:int = 2;
        public static const DANGEROUS_BOMB_CHUNK:int = 3;
        
        public var direction:int;
        public var explosionDirection:int;
        public var remainingPower:int;
        public var parentCell:ExplodingCell;
        public var activeDirections:Array;
        private var _chunkType:int;
        public var originatedByDangerous:Boolean;
        private var _isPenetrating:Boolean;
        protected var _generatorBomb:Bomb;
        
        public function ExplosionChunk(chunkType:int, isPenetrating:Boolean, bomb:Bomb):void
        {
            _chunkType = chunkType;
            activeDirections = new Array();
            _isPenetrating = isPenetrating;
            _generatorBomb = bomb;
        }
        
        public function get generatorBomb():Bomb{
            return _generatorBomb;
        }
        
        public function get isPenetrating():Boolean
        {
            return _isPenetrating;
        }
        
        public function generateChunks(positionManager:PositionManager, explosionArea:ExplosionArea, bomb:Bomb):Array
        {
            throw new Error("ExplosionChunk is an abstract class. Override this method in subclasses");
        }
        
        public function setCoordinatesAndAddChunkToExplosionArea(targetTile:Point, explosionArea:ExplosionArea):void
        {
            var targetCell:ExplodingCell;
            if(explosionArea.containsTile(targetTile))
            {
                targetCell = explosionArea.getCellInTile(targetTile);
            }
            else
            {
                targetCell = new ExplodingCell(targetTile);
                explosionArea.addCell(targetCell);
            }
            targetCell.addChunk(this);
            parentCell = targetCell;
        }

        public function get chunkType():int
        {
            return _chunkType;
        }
        
        public function generateDirectedChunk(tilePoint:Point, inputDirection:int, positionManager:PositionManager, remainingPower:int, bomb:Bomb):ExplosionChunk
        {
            if(positionManager.isTileEmpty(tilePoint.x, tilePoint.y))
            {
                return new CorridorExplosionChunk(inputDirection, remainingPower, _isPenetrating, bomb);
            }
            else
            {
                var newBomb:Bomb = positionManager.nonMineBombInTile(tilePoint);
                if(newBomb == null)
                {
                    if(!_isPenetrating && positionManager.stoppersInTile(tilePoint) || positionManager.hardBlocksInTile(tilePoint))
                    {
                        return  new StopperExplosionChunk(inputDirection, _isPenetrating, bomb);
                    }
                    else
                    {
                        return new CorridorExplosionChunk(inputDirection, remainingPower, _isPenetrating, bomb);
                    }
                }
                else
                {
                    //TODO: do this afterwards
                    newBomb.silentExplosion();
                    if(newBomb.bombType == Bomb.DANGER_BOMB){
                        return new DangerousBombExplosionChunk(newBomb);
                    }
                    else if(newBomb.bombType == Bomb.SPIKE_BOMB)
                    {
                        return new NormalBombExplosionChunk(newBomb.area, true, false, newBomb);
                    }
                    else
                    {
                        return new NormalBombExplosionChunk(newBomb.area, false, false, newBomb);
                    }
                }
            }
        }

        public function generateSpottedChunk(tilePoint:Point, positionManager:PositionManager, bomb:Bomb):ExplosionChunk
        {
            if(positionManager.isTileEmpty(tilePoint.x, tilePoint.y))
            {
                return new StopperExplosionChunk(PositionManager.NONE, false, bomb);
            }
            else
            {
                var newBomb:Bomb = positionManager.nonMineBombInTile(tilePoint);
                if(newBomb == null)
                {
                    return new StopperExplosionChunk(PositionManager.NONE, false, bomb);
                }
                else
                {
                    //TODO: do this afterwards
                    newBomb.silentExplosion();
                    if(newBomb.bombType == Bomb.DANGER_BOMB)
                    {
                        return new DangerousBombExplosionChunk(newBomb);
                    }
                    else if(newBomb.bombType == Bomb.SPIKE_BOMB)
                    {
                        return new NormalBombExplosionChunk(newBomb.area, true, true, newBomb);
                    }
                    else
                    {
                        return new NormalBombExplosionChunk(newBomb.area, false, true, newBomb);
                    }
                }
            }
        }
        
        public function getDirectedChunk(inputTilePoint:Point, inputDirection:int, positionManager:PositionManager, explosionArea:ExplosionArea, remainingPower:int, bomb:Bomb):ExplosionChunk
        {
            if(!PositionManager.tileOuttOfBounds(inputTilePoint))
            {
                var explodingCell:ExplodingCell = explosionArea.getCellInTile(inputTilePoint);
                if(explodingCell == null || (!explodingCell.containsChunkWithTypeAndDirection(inputTilePoint, CORRIDOR_CHUNK, direction) &&
                    !explodingCell.containsChunkWithTypeAndDirection(inputTilePoint, CORRIDOR_CHUNK, (direction+2)%4) &&
                    !explodingCell.containsChunkWithType(inputTilePoint, NORMAL_BOMB_CHUNK) &&
                    !explodingCell.containsChunkWithType(inputTilePoint, DANGEROUS_BOMB_CHUNK)))
                {
                    var chunk:ExplosionChunk = generateDirectedChunk(inputTilePoint, inputDirection, positionManager, remainingPower, bomb);
                    chunk.setCoordinatesAndAddChunkToExplosionArea(inputTilePoint, explosionArea);
                    return chunk;
                }
            }
            return null;
        }

        public function getSpottedChunk(inputTilePoint:Point, positionManager:PositionManager, explosionArea:ExplosionArea, bomb:Bomb):ExplosionChunk
        {
            if(!PositionManager.tileOuttOfBounds(inputTilePoint))
            {
                var explodingCell:ExplodingCell = explosionArea.getCellInTile(inputTilePoint);
                if(explodingCell == null || (!explodingCell.containsChunkWithType(inputTilePoint, DANGEROUS_BOMB_CHUNK)))
                {
                    var chunk:ExplosionChunk = generateSpottedChunk(inputTilePoint, positionManager, bomb);
                    chunk.setCoordinatesAndAddChunkToExplosionArea(inputTilePoint, explosionArea);
                    return chunk;
                }
            }
            return null;
        }
    }
}