package com.willdom.games.bomberman.Explosions
{
    import com.gq.moveobject.Bomb;
    import com.willdom.games.bomberman.position.PositionManager;
    
    import flash.geom.Point;

    public class CorridorExplosionChunk extends ExplosionChunk
    {
        public function CorridorExplosionChunk(direction:int, remainingPower:int, isPenetrating:Boolean, bomb:Bomb)
        {
            super(CORRIDOR_CHUNK, isPenetrating, bomb);
            this.direction = direction;
            this.remainingPower = remainingPower;
            
        }
        
        override public function generateChunks(positionManager:PositionManager, explosionArea:ExplosionArea, bomb:Bomb):Array
        {
            var output:Array = new Array();
            if(remainingPower > 0)
            {
                var nextTile:Point = PositionManager.getNextTile(parentCell.tilePoint, direction);
                var chunk:ExplosionChunk = getDirectedChunk(nextTile, direction, positionManager, explosionArea, remainingPower-1, bomb);
                if(chunk != null)
                {
                    output.push(chunk);
                }
            }
            return output;
        }
    }
}