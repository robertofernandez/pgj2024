package com.willdom.games.bomberman.position
{
    import com.gq.moveobject.Bomb;
    import com.gq.moveobject.Person;
    import com.gq.system.GameData;
    import com.smartfoxserver.v2.entities.data.SFSObject;
    import com.willdom.games.bomberman.communication.SmartFoxClientSingleton;
    import com.willdom.games.bomberman.usableItems.UsableItemsManager;
    
    import flash.geom.Point;
    
    public class GamePositionPersonWarpActor implements GamePositionActor
    {
        private var positionManager:PositionManager;
        
        public function GamePositionPersonWarpActor(positionManager:PositionManager)
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
            var lastPosition:Point;
            
            var personId:uint;
            var person:Person;
            var bomb:Bomb;
            
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

            if(!positionManager.incompatibleElements(person.objectType, tileX, tileY, previousTileX, previousTileY))
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
                    positionManager.removeObjectFromMap(lastPosition.x, lastPosition.y, person); 
                    GameData.instance.diseaseManager.spread(tileX, tileY);
                    GameData.instance.walkControls[personId].setTilePosition(requestedTile);
                    if(personId == SmartFoxClientSingleton.getInstance().smartFoxClient.myself.id)
                    {
                        GameData.instance.usableItemsManager.consumeItem(UsableItemsManager.ITEM_WARP);
                    }
                }
            }
            
        }
    }
}