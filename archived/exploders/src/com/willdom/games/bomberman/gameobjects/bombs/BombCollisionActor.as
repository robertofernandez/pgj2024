package com.willdom.games.bomberman.gameobjects.bombs
{
    import com.gq.moveobject.Bomb;

    /**
     * Class to apply collision actions to bombs involved in a collision.
     */
    public class BombCollisionActor
    {
        private var collidedBombAction:BombsCollisionAction;
        private var collisionerBombAction:BombsCollisionAction;

        public function BombCollisionActor(collidedBombAction:BombsCollisionAction, collisionerBombAction:BombsCollisionAction)
        {
            this.collidedBombAction = collidedBombAction;
            this.collisionerBombAction = collisionerBombAction;
        }

        public function apply(collidedBomb:Bomb, collisionerBomb:Bomb):void
        {
            collidedBombAction.applyToBomb(collidedBomb);
            collisionerBombAction.applyToBomb(collisionerBomb);
        }
    }
}