package com.willdom.games.bomberman.gameobjects.bombs
{
    import com.gq.moveobject.Bomb;
    
    public class BounceBombsCollisionAction implements BombsCollisionAction
    {
        public function BounceBombsCollisionAction()
        {
        }
        
        public function applyToBomb(bomb:Bomb):void
        {
            bomb.switchDirection();
        }
    }
}