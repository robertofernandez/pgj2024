package com.willdom.games.bomberman.gameobjects.bombs
{
    import com.gq.moveobject.Bomb;
    import com.willdom.games.bomberman.position.PositionManager;

    public class BombCollisionManager
    {
        public static const BOMB_MOVING:int = 0;
        public static const BOMB_STAYING:int = 1;
        
        private var collisionActors:Object;
        
        public function BombCollisionManager()
        {
            collisionActors = new Object();
        }
        
        public function registerActions(collisionerBombType:String, collisionedBombType:String, collisionerBombState:int, collisionerBombAction:BombsCollisionAction, collisionedBombAction:BombsCollisionAction):void
        {
            collisionActors[collisionerBombType + "_" + collisionedBombType + "_" + collisionerBombState] = new BombCollisionActor(collisionedBombAction, collisionerBombAction);
        }
        
        public function registerActor(collisionerBombType:String, collisionedBombType:String, collisionerBombState:int, bombCollisionActor:BombCollisionActor):void
        {
            collisionActors[collisionerBombType + "_" + collisionedBombType + "_" + collisionerBombState] = bombCollisionActor;
        }
        
        private function getActor(collisionerBombType:String, collisionedBombType:String, collisionerBombState:int):BombCollisionActor
        {
            return collisionActors[collisionerBombType + "_" + collisionedBombType + "_" + collisionerBombState] as BombCollisionActor;
        }
        
        public function apply(collisionerBomb:Bomb, collisionedBomb:Bomb):void
        {
            if(collisionerBomb == null || collisionerBomb == null || collisionedBomb.fire || collisionerBomb.fire)
            {
                return;
            }
            var movingStatus:int = BOMB_MOVING;
            if(collisionedBomb.movingDirection == PositionManager.NONE)
            {
                movingStatus = BOMB_STAYING;
            }
            var actor:BombCollisionActor = getActor(collisionerBomb.bombType, collisionedBomb.bombType, movingStatus);
            if(actor != null)
            {
                actor.apply(collisionedBomb, collisionerBomb); 
            }
        }
    }
}