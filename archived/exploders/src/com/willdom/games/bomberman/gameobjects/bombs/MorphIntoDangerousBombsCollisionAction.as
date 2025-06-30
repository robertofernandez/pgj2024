package com.willdom.games.bomberman.gameobjects.bombs
{
    import com.gq.moveobject.Bomb;
    
    public class MorphIntoDangerousBombsCollisionAction implements BombsCollisionAction
    {
        public function MorphIntoDangerousBombsCollisionAction()
        {
        }
        
        public function applyToBomb(bomb:Bomb):void
        {
            bomb.morph(new Bomb_3(), Bomb.DANGER_BOMB, 2);
        }
    }
}