package com.willdom.games.bomberman.position
{
    import com.gq.moveobject.Bomb;
    import com.gq.system.GameData;
    import com.smartfoxserver.v2.entities.data.SFSObject;
    
    import flash.geom.Point;

    public class GamePositionMovementConfirmationActor implements GamePositionActor
    {
        private var positionManager:PositionManager;
        
        public function GamePositionMovementConfirmationActor(positionManager:PositionManager)
        {
            this.positionManager = positionManager;
        }
        
        public function execute(data:SFSObject):void
        {
            var movementId:Number;
            var nextTile:Point;
            var bomb:Bomb;
            var objectId:int = data.getLong("objectId");
            movementId = data.getLong("movementId");
            
            if(GameData.DEBUG_MODE)
            {
                trace("[com.willdom.games.bomberman.position.PositionManager] movement confirmation for object: " + objectId + "(" + movementId + ")");
            }
            
            bomb = GameData.instance.bombManager.confirmMovement(objectId, movementId);
            
            if(bomb == null)
            {
                if(GameData.DEBUG_MODE)
                {
                    trace("[com.willdom.games.bomberman.position.PositionManager] bomb not confirmed");
                }
                return;
            }
            
            if(!bomb.isMovementEnabled(movementId))
            {
                if(GameData.DEBUG_MODE)
                {
                    trace("[com.willdom.games.bomberman.position.PositionManager] bomb movement not enabled");
                }
                return;
            }
            
            if(!bomb.fire)
            {
                nextTile = PositionManager.getNextTile(bomb.tilePoint, bomb.movingDirection);
                
                if(positionManager.holeBlockInTile(bomb.tilePoint))
                {
                    positionManager.removeObjectFromMap(bomb.tilePoint.x, bomb.tilePoint.y, bomb);
                    bomb.silentExplosion();
                }
                else
                {
                    if(positionManager.canBeReservedByBomb(nextTile))
                    {
                        if(GameData.DEBUG_MODE)
                        {
                            trace("[com.willdom.games.bomberman.position.PositionManager] confirmed movement " + movementId);
                        }
                        positionManager.removeObjectFromMap(bomb.tilePoint.x, bomb.tilePoint.y, bomb);
                        bomb.setCurrentPosition(nextTile);
                        bomb.addTargetPoint(new Point(nextTile.x, nextTile.y));
                        bomb.tilePoint = nextTile;
                        positionManager.addObjectToMap(nextTile.x, nextTile.y, bomb);
                    }
                    else
                    {
                        var collidingBomb:Bomb = positionManager.nonMineBombInTile(nextTile);
                        if(collidingBomb == null)
                        {
                            if(bomb.bombType == Bomb.BOUNCING_BOMB)
                            {
                                bomb.switchDirection();
                            } 
                            else
                            {
                                if(GameData.DEBUG_MODE)
                                {
                                    trace("[com.willdom.games.bomberman.position.PositionManager] canceling movement " + movementId);
                                }
                                bomb.movingDirection = PositionManager.NONE;
                                bomb.cancelMovement(movementId);
                            }
                        }
                        else
                        {
                            GameData.instance.bombManager.applyCollisionActions(bomb, collidingBomb);
                        }
                    }
                }
            }
            else
            {
                if(GameData.DEBUG_MODE)
                {
                    trace("[com.willdom.games.bomberman.position.PositionManager] bomb already fired");
                }
                bomb.cancelMovement(movementId);
            }
        }
    }
}