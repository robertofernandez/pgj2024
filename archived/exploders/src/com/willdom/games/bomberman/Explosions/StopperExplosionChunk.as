package com.willdom.games.bomberman.Explosions
{
    import com.gq.moveobject.Bomb;
    import com.willdom.games.bomberman.position.PositionManager;

    public class StopperExplosionChunk extends ExplosionChunk
    {
        public function StopperExplosionChunk(direction:int, isPenetrating:Boolean, bomb:Bomb)
        {
            super(STOPPER_CHUNK, isPenetrating, bomb);
            this.direction = direction;
        }
        
        override public function generateChunks(positionManager:PositionManager, explosionArea:ExplosionArea, bomb:Bomb):Array
        {
            return new Array();
        }
    }
}