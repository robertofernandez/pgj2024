package com.willdom.games.bomberman.gameobjects.bombs
{
    import com.gq.moveobject.Bomb;
    
    public class StopMovingBombsCollisionAction implements BombsCollisionAction
    {
        public function StopMovingBombsCollisionAction()
        {
        }
        
        public function applyToBomb(bomb:Bomb):void
        {
            bomb.stopMoving();
        }
    }
}