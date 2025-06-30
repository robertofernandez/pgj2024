package com.willdom.games.bomberman.position
{
    import com.gq.moveobject.Bomb;
    import com.gq.moveobject.MoveObject;
    import com.gq.moveobject.Person;
    import com.gq.system.GameData;
    import com.smartfoxserver.v2.entities.data.SFSObject;
    
    import flash.geom.Point;
    
    public class GamePositionBombKickActor implements GamePositionActor
    {
        private var positionManager:PositionManager;
        
        public function GamePositionBombKickActor(positionManager:PositionManager)
        {
            this.positionManager = positionManager;
        }
        
        public function execute(data:SFSObject):void
        {
            var movementId:Number;
            
            var absoluteSerial:uint;
            var tileX:uint;
            var tileY:uint;
            var previousTileX:uint;
            var previousTileY:uint;
            var requestedTile:Point;
            var previousTile:Point;    
            var nextTile:Point;
            var requestedDirection:int;
            
            var personId:uint;
            var person:Person;
            var bomb:Bomb;
            
            if(!positionManager.paused)
            {
                absoluteSerial = data.getLong('serial');
                tileX = data.getInt("xt");
                tileY = data.getInt("yt");
                previousTileX = data.getInt("xtp");
                previousTileY = data.getInt("ytp");
                personId = data.getInt("personId");
                person = Person.getPersonById(personId);
                requestedTile = new Point(tileX, tileY);
                previousTile = new Point(previousTileX, previousTileY);
                
                if(person==null)
                {
                    return;
                }
                
                if(GameData.DEBUG_MODE)
                {
                    trace("[com.willdom.games.bomberman.position.PositionManager] kick confirmation at <" + tileX + ", " + tileY + ">");
                }
                requestedDirection = data.getInt("dir");
                nextTile = PositionManager.getNextTile(requestedTile, requestedDirection);
                if(!positionManager.canBeReservedByBomb(nextTile)) 
                {
                    if(GameData.DEBUG_MODE)
                    {
                        trace("[com.willdom.games.bomberman.position.PositionManager] element in tile or out of bounds");
                    }
                    nextTile = null;
                }
                if(nextTile != null)
                {
                    if(GameData.DEBUG_MODE)
                    {
                        trace("[com.willdom.games.bomberman.position.PositionManager] kicking bomb from tile <" + requestedTile.x + ", " + requestedTile.y + "> to <"+nextTile.x + ", " + nextTile.y +">. New owner is " + person.currentName);
                    }
                    for each(var auxBomb:Bomb in positionManager.bombsInTile(requestedTile)) 
                    {
                        positionManager.removeObjectFromMap(tileX, tileY, auxBomb);
                        positionManager.addObjectToMap(nextTile.x, nextTile.y, auxBomb);
                        auxBomb.setCurrentPosition(nextTile);
                        auxBomb.addTargetPoint(new Point(nextTile.x, nextTile.y));
                        auxBomb.tilePoint = nextTile;
                        auxBomb.movingDirection = requestedDirection;
                        auxBomb.owner = person;
                        movementId = data.getLong("movementId");
                        auxBomb.updateMovementSequenceWithId(movementId);
                    }
                }
                if(personId == GameData.instance.myId)
                {
                    if(nextTile != null)
                    {
                        positionManager.sendStartMovingConfirmationEvent(tileX, tileY, absoluteSerial);
                        positionManager.requestMoveAfterKicking(Person.getPersonById(personId), previousTile, requestedTile, requestedDirection, MoveObject.PERSON, absoluteSerial);
                    } 
                    else 
                    {
                        positionManager.sendStartMovingCancelationEvent(previousTileX, previousTileY, absoluteSerial);
                    }
                }
            }
        }
    }
}