package com.willdom.games.bomberman.gameobjects.bombs
{
    import com.gq.moveobject.Bomb;
    
    public class DissapearBombsCollisionAction implements BombsCollisionAction
    {
        public function DissapearBombsCollisionAction()
        {
        }
        
        public function applyToBomb(bomb:Bomb):void
        {
            bomb.silentExplosion();
        }
    }
}