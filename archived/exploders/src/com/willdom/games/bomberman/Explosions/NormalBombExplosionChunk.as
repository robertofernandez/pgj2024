package com.willdom.games.bomberman.Explosions
{
    import com.gq.moveobject.Bomb;
    import com.willdom.games.bomberman.position.PositionManager;
    
    import flash.geom.Point;

    public class NormalBombExplosionChunk extends ExplosionChunk
    {
        public function NormalBombExplosionChunk(remainingPower:int, isPenetrating:Boolean, originatedByDangerous:Boolean, bomb:Bomb)
        {
            super(NORMAL_BOMB_CHUNK, isPenetrating, bomb);
            this.remainingPower = remainingPower;
            this.originatedByDangerous = originatedByDangerous;
        }
        
        override public function generateChunks(positionManager:PositionManager, explosionArea:ExplosionArea, bomb:Bomb):Array
        {
            var output:Array = new Array();
            if(remainingPower > 0)
            {
                for(var currentDirection:int = PositionManager.WEST; currentDirection <= PositionManager.SOUTH; currentDirection++)
                {
                    var nextTile:Point = PositionManager.getNextTile(parentCell.tilePoint, currentDirection);
                    var chunk:ExplosionChunk = getDirectedChunk(nextTile, currentDirection, positionManager, explosionArea, remainingPower - 1, bomb);
                    if(chunk != null)
                    {
                        output.push(chunk);
                    }
                }
            }
            return output;
        }
    }
}