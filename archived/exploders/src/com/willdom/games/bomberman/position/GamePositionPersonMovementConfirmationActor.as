package com.willdom.games.bomberman.position
{
    import com.gq.moveobject.Bomb;
    import com.gq.moveobject.Person;
    import com.gq.moveobject.WalkControlSet;
    import com.gq.system.GameData;
    import com.smartfoxserver.v2.entities.data.SFSObject;
    
    import flash.geom.Point;
    
    public class GamePositionPersonMovementConfirmationActor implements GamePositionActor
    {
        private var positionManager:PositionManager;
        
        public function GamePositionPersonMovementConfirmationActor(positionManager:PositionManager)
        {
            this.positionManager = positionManager;
        }
        
        public function execute(data:SFSObject):void
        {
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
            
            var lastPosition:Point;
            
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
            
            
            if(previousTile.x == person.confirmedPosition.x && previousTile.y == person.confirmedPosition.y)
            {
                trace("prevX: " + previousTile.x + " - prevY: " + previousTile.y + " - confirmX: " + person.confirmedPosition.x + " - confirmY: " + person.confirmedPosition.y);
                if(GameData.DEBUG_MODE)
                {
                    trace("[com.willdom.games.bomberman.position.PositionManager] person position confirmation received: from <" + previousTileX +", " +previousTileY +"> to <" + tileX + ", " + tileY + ">");
                }
                if(positionManager.incompatibleElements(person.objectType, tileX, tileY, previousTileX, previousTileY))
                {
                    trace("[com.willdom.games.bomberman.position.PositionManager] incompatible elements moving person to <" + tileX + ", " + tileY + ">, should go back to <" + previousTileX + ", " + previousTileY + ">");
                    positionManager.sendPositionCancelationEvent(new Point(previousTileX,previousTileY), absoluteSerial, personId);
                }
                else
                {
                    var tile:Point = new Point(tileX,tileY);
                    bomb = positionManager.bombInTile(tile);
                    if(bomb == null)
                    {
                        if(GameData.DEBUG_MODE)
                        {
                            trace("[com.willdom.games.bomberman.position.PositionManager] adding person to <" + tileX + ", " + tileY + ">");
                        }
                        positionManager.addObjectToMap(tileX, tileY, person);
                        lastPosition = person.confirmedPosition;
                        person.confirmedPosition = new Point(tileX,tileY);
                        
                        positionManager.getItemsFromTile(tileX, tileY, person);
                        if(GameData.DEBUG_MODE)
                        {
                            trace("[com.willdom.games.bomberman.position.PositionManager] removing person from <" + previousTileX + ", " + previousTileY + ">");
                        }
                        positionManager.removeObjectFromMap(previousTile.x, previousTile.y, person); 
                        GameData.instance.diseaseManager.spread(tileX, tileY);
                        positionManager.sendPositionConfirmationEvent(requestedTile, data.getLong("serial"), data.getInt("personId"));
                    }
                    else
                    {
                        // implicit kick
                        if(bomb.movingDirection == PositionManager.NONE)
                        {
                            bomb.reEnableLastMovement();
                        }
                        
                        requestedDirection = data.getInt("dir");
                        nextTile = PositionManager.getNextTile(requestedTile, requestedDirection);
                        if(nextTile != null)
                        {
                            nextTile = PositionManager.getNextTile(nextTile, requestedDirection);
                        }
                        
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
                            positionManager.removeObjectFromMap(tileX, tileY, bomb);
                            positionManager.addObjectToMap(nextTile.x, nextTile.y, bomb);
                            bomb.setCurrentPosition(nextTile);
                            bomb.addTargetPoint(new Point(nextTile.x, nextTile.y));
                            bomb.tilePoint = nextTile;
                            bomb.movingDirection = requestedDirection;
                            bomb.owner = person;
                            positionManager.addObjectToMap(tileX, tileY, person);
                            person.confirmedPosition = new Point(tileX,tileY);
                            positionManager.getItemsFromTile(tileX, tileY, person);
                            if(GameData.DEBUG_MODE)
                            {
                                trace("[com.willdom.games.bomberman.position.PositionManager] removing person from <" + previousTileX + ", " + previousTileY + ">");
                            }
                            positionManager.removeObjectFromMap(previousTileX, previousTileY, person); 
                            GameData.instance.diseaseManager.spread(tileX, tileY);
                            positionManager.sendPositionConfirmationEvent(requestedTile, data.getLong("serial"), data.getInt("personId"));
                        }
                        else
                        {
                            positionManager.sendPositionCancelationEvent(new Point(previousTileX,previousTileY), absoluteSerial, personId);
                        }
                    }
                }
            }
        }
    }
}