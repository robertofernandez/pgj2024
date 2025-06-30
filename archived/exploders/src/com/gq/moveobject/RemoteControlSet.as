package com.gq.moveobject
{
    import com.gq.system.GameData;
    import com.smartfoxserver.v2.entities.data.SFSObject;
    import com.willdom.games.bomberman.position.PositionEvent;
    import com.willdom.games.bomberman.position.PositionManager;
    
    import flash.geom.Point;
    
    import com.willdom.games.bomberman.communication.SmartFoxClientSingleton;
    import com.willdom.util.helpers.EventListenerManager;
    import com.willdom.games.bomberman.communication.GameMessage;

    //FUTURE: refactor to reuse code for local control set
    public class RemoteControlSet implements WalkControlSet
    {
        private var _status:String;

        private var nextPosition:Point;
        private var currentPosition:Point;
        private var currentDirection:int;
        private var currentDirectionText:String;

        private var personId:int;
        
        private var futureTilePositions:Array;
        private var currentTilePosition:Point;
        private var nextTilePosition:Point;
        
        public var hasReachedTarget:Boolean;
        
        public static const TILE_SIZE_X:int = GameData.instance.rectWidth;
        public static const TILE_SIZE_Y:int = GameData.instance.rectHeight;

        private var person:Person;
        
        private var speedMultiplier:Number = 1.5;

        public function RemoteControlSet(person:Person)
        {
            if (person != null)
            {
                this.person = person;
                this.personId = int(person.myId);
                futureTilePositions = new Array();
                hasReachedTarget = true;
                EventListenerManager.setListenerTo(GameData.instance.positionManager, PositionEvent.PERSON_POSITION_CONFIRMATION, onPositionConfirmed);
            }
        }
        
        public function setInitialTilePosition(initialPosition:Point):void
        {
            GameData.instance.positionManager.initPersonPosition(initialPosition.x, initialPosition.y, person);
            currentTilePosition = initialPosition;
            nextTilePosition = initialPosition;
            nextPosition = currentPosition;
            currentPosition = new Point((currentTilePosition.x+0.5)*GameData.instance.rectWidth,(currentTilePosition.y+0.5)*GameData.instance.rectWidth+ GameData.instance.upLine);
        }

        public function get currentTile():Point
        {
            return currentTilePosition;
        }

        public function restoreBornTilePosition(bornTile:Point):void {
            futureTilePositions = new Array();
            hasReachedTarget = true;
            currentTilePosition = bornTile;
            nextTilePosition = bornTile;
            currentPosition = new Point((currentTilePosition.x+0.5)*GameData.instance.rectWidth,(currentTilePosition.y+0.5)*GameData.instance.rectWidth+ GameData.instance.upLine);
            nextPosition = currentPosition;
            person.waitingForArriveConfirmation = false;
        }
        
        protected function onPositionConfirmed(event:PositionEvent):void
        {
            if(int(event.userId) == personId) {
                var newTilePosition:Point = new Point(event.tileX, event.tileY);
                futureTilePositions.push(newTilePosition);
                var bombsInTile:Array = GameData.instance.positionManager.bombsInTile(newTilePosition);
                updateSpeed();
            }
        }
        
        private function updateSpeed():void{
            if(futureTilePositions.length < 2) 
            {
                speedMultiplier = 1.5;
            } else if(futureTilePositions.length < 5) 
            {
                speedMultiplier = 3;
            } else {
                speedMultiplier = 6;
            }
        }

        public function getNextPosition(currentDirectionRequested:int):Point 
        {
            if(hasReachedTarget){
                if(futureTilePositions.length == 0) {
                    _status = "stand";
                    return currentPosition;
                } else {
                    calculateNewTarget();
                    return walkToTarget();
                }
            } else {
                return walkToTarget();
            }
            return nextPosition;
        }
        
        private function calculateNewTarget():void 
        {
            nextTilePosition = futureTilePositions[0];
            if(nextTilePosition.x < currentTilePosition.x)
            {
                currentDirection = PositionManager.WEST;
                currentDirectionText = "left";
            } 
            else if(nextTilePosition.x > currentTilePosition.x)
            {
                currentDirection = PositionManager.EAST;
                currentDirectionText = "right";
            } 
            else if(nextTilePosition.y < currentTilePosition.y)
            {
                currentDirection = PositionManager.NORTH;
                currentDirectionText = "up";
            }
            else if(nextTilePosition.y > currentTilePosition.y)
            {
                currentDirection = PositionManager.SOUTH;
                currentDirectionText = "down";
            }
            _status = "walking";
            futureTilePositions.shift();
            updateSpeed();
            nextPosition = new Point((nextTilePosition.x + 0.5) * GameData.instance.rectWidth, (nextTilePosition.y + 0.5) * GameData.instance.rectHeight + GameData.instance.upLine);
            hasReachedTarget = false;
        }
        
        public function setTilePosition(newPosition:Point):void 
        {
            futureTilePositions.splice(0, futureTilePositions.length);
            hasReachedTarget = true;
            GameData.instance.positionManager.initPersonPosition(newPosition.x, newPosition.y, person);
            currentTilePosition = newPosition;
            nextTilePosition = currentTilePosition;
            currentPosition = new Point((currentTilePosition.x + 0.5) * GameData.instance.rectWidth, (currentTilePosition.y + 0.5) * GameData.instance.rectWidth + GameData.instance.upLine);
            nextPosition = currentPosition;
        }
        
        public function resetDirection():void
        {
            futureTilePositions.splice(0);
            _status = "stand";
            currentDirection = PositionManager.NONE;
        }
        
        private function walkToTarget():Point
        {
            var currentX:int = currentPosition.x;
            var currentY:int = currentPosition.y;
            
            switch(currentDirection)
            {
                case PositionManager.WEST:
                {
                    currentX -= stepSizeX;
                    if(currentX <= nextPosition.x)
                    {
                        currentX = nextPosition.x;
                        hasReachedTarget = true;
                    }
                    break;
                }
                case PositionManager.EAST:
                {
                    currentX += stepSizeX;
                    if(currentX >= nextPosition.x)
                    {
                        currentX = nextPosition.x;
                        hasReachedTarget = true;
                    }
                    break;
                }
                case PositionManager.NORTH:
                {
                    currentY -= stepSizeY;
                    if(currentY <= nextPosition.y)
                    {
                        currentY = nextPosition.y;
                        hasReachedTarget = true;
                    }
                    break;
                }
                case PositionManager.SOUTH:
                {
                    currentY += stepSizeY;
                    if(currentY >= nextPosition.y)
                    {
                        currentY = nextPosition.y;
                        hasReachedTarget = true;
                    }
                    break;
                }
                default:
                {
                    break;
                }
            }
            currentPosition = new Point(currentX, currentY);
            if(hasReachedTarget) 
            {
                currentTilePosition = nextTilePosition;
            }
            return currentPosition;
        }
        
        public function get local():Boolean 
        {
            return false;
        }
        
        public function get status():String 
        {
            return _status;
        }
        
        public function get direction():String 
        {
            return currentDirectionText;
        }

        public function dispose():void
        {
            GameData.instance.positionManager.removeEventListener(PositionEvent.PERSON_POSITION_CONFIRMATION, onPositionConfirmed);
        }
        
        public function getPendingPositions():int
        {
            return futureTilePositions.length;
        }
        
        private function get stepSizeX():int 
        {
            return person.speedAll * speedMultiplier;
        }
        
        private function get stepSizeY():int 
        {
            return person.speedAll * speedMultiplier;
        }
    }
}