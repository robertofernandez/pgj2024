package com.gq.moveobject
{
    import com.gq.system.GameData;
    import com.greensock.TweenMax;
    import com.smartfoxserver.v2.entities.data.SFSObject;
    import com.willdom.games.bomberman.communication.GameMessage;
    import com.willdom.games.bomberman.communication.SmartFoxClientSingleton;
    import com.willdom.games.bomberman.consts.ServerMessages;
    import com.willdom.games.bomberman.gameobjects.bombs.BombManager;
    import com.willdom.games.bomberman.position.PositionEvent;
    import com.willdom.games.bomberman.position.PositionManager;
    import com.willdom.util.helpers.EventListenerManager;
    
    import flash.display.MovieClip;
    import flash.events.Event;
    import flash.geom.ColorTransform;
    import flash.geom.Point;

    public class LocalWalkControlSet implements WalkControlSet
    {
        public var hasReachedTarget:Boolean;
        public var targetConfirmed:Boolean;
        public var serialNumber:uint;
        private var nextTilePosition:Point;
        private var nextPosition:Point;
        private var currentTilePosition:Point;
        private var currentPosition:Point;
        private var currentDirection:int;
        private var _lastDirection:int;
        public static const TILE_SIZE_X:int = GameData.instance.rectWidth;
        public static const TILE_SIZE_Y:int = GameData.instance.rectHeight;

        private var person:Person;

        public function LocalWalkControlSet(person:Person)
        {
            this.person = person;
            hasReachedTarget = true;
            targetConfirmed = false;
            _lastDirection = PositionManager.NONE;
            currentDirection = PositionManager.NONE;
            serialNumber = 0;
            EventListenerManager.setListenerTo(GameData.instance.positionManager, PositionEvent.PERSON_POSITION_CONFIRMATION, onPositionConfirmed);
            EventListenerManager.setListenerTo(GameData.instance.positionManager, PositionEvent.PERSON_POSITION_CANCELATION, onPositionCanceled);
            EventListenerManager.setListenerTo(GameData.instance.positionManager, PositionEvent.PERSON_START_MOVING_CONFIRMATION, onStartWalkConfirmed);
            EventListenerManager.setListenerTo(GameData.instance.positionManager, PositionEvent.PERSON_START_MOVING_CANCELATION, onStartWalkCanceled);
            if(GameData.DEBUG_MODE || GameData.SHOW_ELEMENTS){
                EventListenerManager.setListenerTo(person._this, Event.ADDED_TO_STAGE, onPersonAddedToStage);
            }
        }
        
        public function get currentTile():Point {
            return currentTilePosition;
        }
        
        public function setInitialTilePosition(initialPosition:Point):void {
            setTilePosition(initialPosition);
        }
        
        public function resetDirection():void{
            currentDirection = PositionManager.NONE;
        }
        
        public function setTilePosition(newPosition:Point):void {
            hasReachedTarget = true;
            targetConfirmed = true;
            GameData.instance.positionManager.initPersonPosition(newPosition.x, newPosition.y, person);
            currentTilePosition = newPosition;
            nextTilePosition = currentTilePosition;
            currentPosition = new Point((currentTilePosition.x + 0.5) * GameData.instance.rectWidth, (currentTilePosition.y + 0.5) * GameData.instance.rectWidth + GameData.instance.upLine);
            nextPosition = currentPosition;
            person.waitingForArriveConfirmation = false;
        }

        public function restoreBornTilePosition(bornTile:Point):void {
            hasReachedTarget = true;
            targetConfirmed = true;
            currentTilePosition = bornTile;
            nextTilePosition = currentTilePosition;
            currentPosition = new Point((currentTilePosition.x+0.5)*GameData.instance.rectWidth,(currentTilePosition.y+0.5)*GameData.instance.rectWidth+ GameData.instance.upLine);
            nextPosition = currentPosition;
        }

        public function get local():Boolean {
            return true;
        }

        public function get status():String {
            if(currentDirection == PositionManager.NONE){
                return 'stand';
            } else {
                return 'walking';
            }
        }
        
        public function get direction():String
        {
            switch(currentDirection)
            {
                case PositionManager.WEST:
                {
                    return "left";
                }
                case PositionManager.EAST:
                {
                    return "right";
                }
                case PositionManager.NORTH:
                {
                    return "up";
                }
                case PositionManager.SOUTH:
                {
                    return "down";
                }
                default:
                {
                    return "none";
                }
            }
        }
        
        public function get directionInt():int
        {
            return currentDirection;
        }
        
        public function get lastDirection():int
        {
            return _lastDirection;
        }
        
        private function onPositionConfirmed(event:PositionEvent):void
        {
            if(GameData.DEBUG_MODE){
                trace("[com.gq.moveobject.LocalWalkControlSet] position confirmed, not waiting for arrive");
            }
            person.waitingForArriveConfirmation = false;
            if(event.userId == this.person.myId) {
                confirmTarget();
            }
        }
        
        private function onPositionCanceled(event:PositionEvent):void
        {
            person.waitingForArriveConfirmation = false;
            if(GameData.DEBUG_MODE){
                trace("[com.gq.moveobject.LocalWalkControlSet] cancel walking, incompatible element ahead (not waiting for arrive now)");
            }
            //TODO: Check if it's necessary to check this:
            if(event.userId == this.person.myId) {
                cancelTarget(event.tileX,event.tileY);
            }
        }
        
        private function confirmTarget(): void
        {
            targetConfirmed = true;
        }
        
        private function cancelTarget(prevPositionX:uint, prevPositionY:uint): void
        {
            if(GameData.DEBUG_MODE)
            {
                trace("[com.gq.moveobject.LocalWalkControlSet] target canceled");
            }
            setTilePosition(new Point(prevPositionX, prevPositionY));
        }

        public function getNextPosition(currentDirectionRequested:int):Point
        {
            /*if(GameData.DEBUG_MODE)
            {
                trace("[com.gq.moveobject.LocalWalkControlSet] getting next position");
            }*/

            if(hasReachedTarget)
            {
                
                if(person.engagedByMine)
                {
                    if(!person.engagingMine.hasSentTriggerMessage){
                        person.engagingMine.hasSentTriggerMessage = true;
                        var params:SFSObject = new SFSObject();
                        params.putLong("bombId", person.engagingMine.bombId);
                        params.putInt(ServerMessages.ROUND_NUMBER,GameData.instance.currentRound);
                        SmartFoxClientSingleton.getInstance().smartFoxClient.sendExtensionRequestToGameRoom(BombManager.BLOW_MINE, params);
                    }
                    return currentPosition;
                }
                if(targetConfirmed)
                {
                    if(GameData.DEBUG_MODE){
                    //    trace("[com.gq.moveobject.LocalWalkControlSet] Target confirmed");
                    }
                    calculateNewTarget(currentDirectionRequested);
                    return walkToTarget();
                }
                else
                {    if(GameData.DEBUG_MODE){
                        trace("[com.gq.moveobject.LocalWalkControlSet] Target not confirmed");
                    }
                    return currentPosition;
                }
            }
            else
            {
                return walkToTarget();
            }
        }

        private function calculateNewTarget(currentDirectionRequested:int):void
        {
            if(person.waitingForStartConfirmation || person.waitingForArriveConfirmation){
                if(GameData.DEBUG_MODE){
                    trace("[com.gq.moveobject.LocalWalkControlSet] Waiting for start or arrive confirmation");
                }
                return;
            }
            currentDirection = currentDirectionRequested;
            if(currentDirectionRequested == PositionManager.NONE)
            {
                if(GameData.DEBUG_MODE){
                //    trace("[com.gq.moveobject.LocalWalkControlSet] No key pressed");
                }
                return;
            }
            else
            {
                _lastDirection = currentDirectionRequested;
            }
            if(GameData.DEBUG_MODE){
                trace("[com.gq.moveobject.LocalWalkControlSet] request move, setting target reached to false (will update position until target reached again)");
            }
            hasReachedTarget = false;
            targetConfirmed = false;
            var proposedPosition:Point = getRequestedPosition(currentDirectionRequested);
            person.waitingForStartConfirmation = true;
            person.waitingForArriveConfirmation = true;
            GameData.instance.positionManager.requestMove(person, currentTilePosition, proposedPosition, currentDirectionRequested, ObjectType.PERSON, serialNumber++);
        }

        private function onStartWalkConfirmed(event:PositionEvent):void {
            if(GameData.DEBUG_MODE){
                trace("[com.gq.moveobject.LocalWalkControlSet] start walking to <" + event.tileX + ", " + event.tileY+"> confirmed, not waiting for start");
            }
            person.waitingForStartConfirmation = false;
            if(event.userId == this.person.myId) {
                nextTilePosition = new Point(event.tileX, event.tileY);
                nextPosition = new Point((nextTilePosition.x + 0.5) * GameData.instance.rectWidth, (nextTilePosition.y + 0.5) * GameData.instance.rectHeight + GameData.instance.upLine);

                var bombsInTile:Array = GameData.instance.positionManager.bombsInTile(nextTilePosition);
                if(bombsInTile.length > 0){
                    for each(var bomb:Bomb in bombsInTile)
                    {
                        if(bomb.isMine && bomb.isActive)
                        {
                            bomb.isTriggered = true;
                            person.engagedByMine = true;
                            person.engagingMine = bomb;
                        }
                    }
                }
            }
        }

        private function onStartWalkCanceled(event:PositionEvent):void {
            if(GameData.DEBUG_MODE){
                trace("[com.gq.moveobject.LocalWalkControlSet] start walking canceled, not waiting for start nor arrive");
            }
            person.waitingForStartConfirmation = false;
            person.waitingForArriveConfirmation = false;
            if(event.userId == this.person.myId) {
                hasReachedTarget = true;
                targetConfirmed = true;
            }
        }

        private function getRequestedPosition(requestedDirection:int):Point {
            return PositionManager.getNextTile(currentTilePosition, requestedDirection);
        }

        private function walkToTarget():Point
        {
            if(hasReachedTarget || person.waitingForStartConfirmation)
            {
                return currentPosition;
            }

            var currentX:int = currentPosition.x;
            var currentY:int = currentPosition.y;

            switch(currentDirection)
            {
                case PositionManager.WEST:
                {
                    currentX -= person.speedAll;
                    if(currentX <= nextPosition.x){
                        currentX = nextPosition.x;
                        hasReachedTarget = true;
                    }
                    break;
                }
                case PositionManager.EAST:
                {
                    currentX += person.speedAll;//STEP_SIZE_X;
                    if(currentX >= nextPosition.x){
                        currentX = nextPosition.x;
                        hasReachedTarget = true;
                    }
                    break;
                }
                case PositionManager.NORTH:
                {
                    currentY -= person.speedAll;//STEP_SIZE_Y;
                    if(currentY <= nextPosition.y){
                        currentY = nextPosition.y;
                        hasReachedTarget = true;
                    }
                    break;
                }
                case PositionManager.SOUTH:
                {
                    currentY += person.speedAll;//STEP_SIZE_Y;
                    if(currentY >= nextPosition.y){
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
            if(hasReachedTarget) {
                currentTilePosition = nextTilePosition;
                if(GameData.DEBUG_MODE){
                    trace("[com.gq.moveobject.LocalWalkControlSet] target reached, now in: <" + currentTilePosition.x + ", " + currentTilePosition.y+">");
                }
            }
            return currentPosition;
        }

        public function dispose():void{
            GameData.instance.positionManager.removeEventListener(PositionEvent.PERSON_POSITION_CONFIRMATION, onPositionConfirmed);
            GameData.instance.positionManager.removeEventListener(PositionEvent.PERSON_POSITION_CANCELATION, onPositionCanceled);
            GameData.instance.positionManager.removeEventListener(PositionEvent.PERSON_START_MOVING_CONFIRMATION, onStartWalkConfirmed);
            GameData.instance.positionManager.removeEventListener(PositionEvent.PERSON_START_MOVING_CANCELATION, onStartWalkCanceled);
        }
        
        /**
         * Function to show persons in stage. Used for debuging purposes.
         */
        private function onPersonAddedToStage(e:Event):void {
            EventListenerManager.setListenerTo(GameData.instance.positionManager, "objectAdded", showItemsInMap);
            EventListenerManager.setListenerTo(GameData.instance.positionManager, "objectRemoved", showItemsInMap);
            EventListenerManager.setListenerTo(GameData.instance.positionManager, "objectAdded", showItemsInMap);
            EventListenerManager.setListenerTo(GameData.instance.positionManager, "objectRemoved", showItemsInMap);
        }

        private function showItemsInMap(e:Event):void {
            for each(var mark:MovieClip in GameData.instance.objectsMarks)
            {
                if(mark.parent != null)
                {
                    //removeMarkFromMap(mark);
                    mark.parent.removeChild(mark);
                }
            }
            GameData.instance.objectsMarks = new Array();
            showObjectsInMap(MoveObject.PERSON, 0, 20, 240);
            showObjectsInMap(MoveObject.TREASURE, 0, 125, 240);
            showObjectsInMap(MoveObject.BOMB, 124, 0, 240);
            showObjectsInMap(MoveObject.KICKER, 0, 240, 40);
        }

        private function showObjectsInMap(objectType:uint, red:Number, green:Number, blue:Number):void {
            try{
                var pointsWithPersons:Array = GameData.instance.positionManager.getPointsWithObjectsOnStage(objectType);
                for each(var point:Point in pointsWithPersons){
                    var mark:Mark_1 = new Mark_1();
                    mark.x = (point.x + 0.5) * GameData.instance.rectWidth;
                    mark.y = (point.y + 0.5) * GameData.instance.rectHeight + GameData.instance.upLine;
                    mark.transform.colorTransform = new ColorTransform(0, 0, 0, 1, red, green, blue);
                    GameData.instance.objectsMarks.push(mark);
                    mark.alpha = 0.4;
                    person._this.parent.addChild(mark);
                }
            } catch(e:Error){
                
            }
        }
    }
}