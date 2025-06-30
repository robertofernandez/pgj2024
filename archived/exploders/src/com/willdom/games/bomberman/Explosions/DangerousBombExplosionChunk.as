package com.willdom.games.bomberman.Explosions
{
    import com.gq.moveobject.Bomb;
    import com.willdom.games.bomberman.position.PositionManager;
    
    import flash.geom.Point;

    public class DangerousBombExplosionChunk extends ExplosionChunk
    {
        public function DangerousBombExplosionChunk(bomb:Bomb)
        {
            super(DANGEROUS_BOMB_CHUNK, false, bomb);
            this.direction = PositionManager.NONE;
        }

        override public function generateChunks(positionManager:PositionManager, explosionArea:ExplosionArea, bomb:Bomb):Array
        {
            var output:Array = new Array();
            var tilePoints:Array = positionManager.getSquareExplosionArea(parentCell.tilePoint);
            
            for each(var currentTilePoint:Point in tilePoints)
            {
                var chunk:ExplosionChunk = getSpottedChunk(currentTilePoint, positionManager, explosionArea, bomb);
                if(chunk != null)
                {
                    output.push(chunk);
                }
            }
            return output;
        }
    }
}