package com.willdom.games.bomberman.position
{
    
    import com.gq.moveobject.Bomb;
    import com.gq.moveobject.LocalWalkControlSet;
    import com.gq.moveobject.MoveObject;
    import com.gq.moveobject.ObjectHole;
    import com.gq.moveobject.Objects;
    import com.gq.moveobject.Person;
    import com.gq.moveobject.Treasure;
    import com.gq.system.DiseaseManager;
    import com.gq.system.GameData;
    import com.gq.system.GameSys;
    import com.smartfoxserver.v2.core.SFSEvent;
    import com.smartfoxserver.v2.entities.data.SFSObject;
    import com.willdom.games.bomberman.Explosions.DangerousBombExplosionChunk;
    import com.willdom.games.bomberman.Explosions.ExplodingCell;
    import com.willdom.games.bomberman.Explosions.ExplosionArea;
    import com.willdom.games.bomberman.Explosions.ExplosionChunk;
    import com.willdom.games.bomberman.Explosions.NormalBombExplosionChunk;
    import com.willdom.games.bomberman.communication.GameMessage;
    import com.willdom.games.bomberman.communication.SmartFoxClientSingleton;
    import com.willdom.games.bomberman.consts.ServerMessages;
    import com.willdom.games.bomberman.events.PlayerEvent;
    import com.willdom.util.helpers.EventListenerManager;
    
    import configuration.StageModes;
    
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.geom.Point;
    import flash.sampler.NewObjectSample;
    import flash.sampler.stopSampling;
    import flash.utils.Dictionary;
    import flash.utils.getTimer;
    
    [Event(name="personPositionConfirmation", type="com.willdom.games.bomberman.position.PositionEvent")]
    [Event(name="personPositionCancelation", type="com.willdom.games.bomberman.position.PositionEvent")]
    [Event(name="personStartMovingConfirmation", type="com.willdom.games.bomberman.position.PositionEvent")]
    [Event(name="personStartMovingCancelation", type="com.willdom.games.bomberman.position.PositionEvent")]
    
    public class PositionManager extends EventDispatcher
    {
        public static const NONE:int = -1;
        public static const WEST:int = 0;
        public static const NORTH:int = 1;
        public static const EAST:int = 2;
        public static const SOUTH:int = 3;
        
        public static const BOMB_PERIOD:int = 95;
        
        public static const PERSON_POSITION_CONFIRMATION:String = "ppok";
        public static const SET_BOMB:String = "setBomb";
        public static const KICK_BOMB:String = "kickBomb";
        public static const MOVEMENT_CONFIRMATION:String = "movementConfirmation";
        public static const MOVEMENT_WARP:String = "warp";
        
        private var initialMap:Array;
        private var map:Array;
        private var treasures:Array;
        
        public var paused:Boolean = false;
        public var positionActorsMap:Dictionary;
        
        public function PositionManager():void
        {
            if(GameData.DEBUG_MODE)
            {
                trace("[com.willdom.games.bomberman.position.PositionManager] initializing map");
            }
            
            map = new Array(GameData.instance.widthNum);
            treasures = new Array();
            initialMap = new Array(GameData.instance.widthNum);
            
            for(var i:uint;i<map.length;i++)
            {
                map[i]=new Array(GameData.instance.heightNum);
                initialMap[i]=new Array(GameData.instance.heightNum);
            }
            
            EventListenerManager.setListenerTo(GameData.instance.serverMessagesHandler, SFSEvent.EXTENSION_RESPONSE, onExtensionResponse);
            
            positionActorsMap = new Dictionary;
            positionActorsMap[MOVEMENT_CONFIRMATION] = new GamePositionMovementConfirmationActor(this);
            positionActorsMap[PERSON_POSITION_CONFIRMATION] = new GamePositionPersonMovementConfirmationActor(this);
            positionActorsMap[KICK_BOMB] = new GamePositionBombKickActor(this);
            positionActorsMap[MOVEMENT_WARP] = new GamePositionPersonWarpActor(this);
        }
        
        public static function getNextTile(currentTilePosition:Point, direction:int, steps:int = 1):Point
        {
            if(GameData.DEBUG_MODE)
            {
                trace("[com.willdom.games.bomberman.position.PositionManager] calculating next tile for point <" +
                    currentTilePosition.x + ", " + currentTilePosition.y + "> in direction " + direction);
            }
            
            switch(direction)
            {
                case PositionManager.WEST:
                {
                    return new Point(currentTilePosition.x - steps, currentTilePosition.y);
                }
                case PositionManager.EAST:
                {
                    return new Point(currentTilePosition.x + steps, currentTilePosition.y);
                }
                case PositionManager.NORTH:
                {
                    return new Point(currentTilePosition.x, currentTilePosition.y - steps);
                }
                case PositionManager.SOUTH:
                {
                    return new Point(currentTilePosition.x, currentTilePosition.y + steps);
                }
                default:
                {
                    return new Point(currentTilePosition.x, currentTilePosition.y);
                }
            }
        }
        
        /**
         * 
         * @return Next tile point in direction if it is inside map. Null if it is not.
         */
        public static function getNextTileInsideMap(currentTilePosition:Point, direction:int, steps:int = 1):Point
        {
            var output:Point = getNextTile(currentTilePosition, direction, steps);
            if(tileOuttOfBounds(output))
            {
                return null;
            }
            else
            {
                return output;
            }
        }
        
        public static function getDirection(currentTilePosition:Point, nextTilePosition:Point):int{
            if(nextTilePosition.x < currentTilePosition.x){
                return PositionManager.WEST;
            } else if(nextTilePosition.x > currentTilePosition.x){
                return PositionManager.EAST;
            } else if(nextTilePosition.y < currentTilePosition.y){
                return PositionManager.NORTH;
            } else if(nextTilePosition.y > currentTilePosition.y){
                return PositionManager.SOUTH;
            } else {
                return PositionManager.NONE;
            }
        }
        
        private function onExtensionResponse(e:SFSEvent):void 
        {
            var data:SFSObject = e.params["params"] as SFSObject;
            
            if(positionActorsMap[e.params["cmd"]] != null)
            {
                positionActorsMap[e.params["cmd"]].execute(data);
            }
        }
        
        public function pause():void {
            paused = true;
            //SmartFoxClientSingleton.getInstance().smartFoxClient.removeEventListener(MessageEvent.GAME_MESSAGE, onGameMessage);
        }
        
        public function resume():void {
            paused = false;
            //EventListenerManager.setListenerTo(SmartFoxClientSingleton.getInstance().smartFoxClient, MessageEvent.GAME_MESSAGE, onGameMessage);
        }
        
        public function dispose():void {
            //SmartFoxClientSingleton.getInstance().smartFoxClient.removeEventListener(MessageEvent.GAME_MESSAGE, onGameMessage);
            SmartFoxClientSingleton.getInstance().smartFoxClient.removeExtensionResponseListener(onExtensionResponse);
        }
        
        private function tileContainsBomb(requestedTile:Point):Boolean
        {
            if(GameData.DEBUG_MODE)
            {
                trace("[com.willdom.games.bomberman.position.PositionManager] checking tile <"+requestedTile.x + ", " + requestedTile.y+"> for bombs");
            }
            var tileX:Number = requestedTile.x;
            var tileY:Number = requestedTile.y;
            if(map[tileX][tileY] == null){
                return false;
            }
            for each(var moveObject:MoveObject in map[tileX][tileY] as Array){
                //TODO: check why this is happening at rematch
                if(moveObject == null){
                    continue;
                }
                if(moveObject.objectType == MoveObject.BOMB){
                    if((moveObject as Bomb).isMine)
                    {
                        return false;
                    } else
                    {
                        return true;
                    }
                }
            }
            return false;
        }
        
        public function bombsInTile(requestedTile:Point):Array
        {
            return typedObjectsInTile(requestedTile, MoveObject.BOMB);
        }
        
        public function nonMineBombInTile(requestedTile:Point):Bomb
        {
            var tempArray:Array = bombsInTile(requestedTile);
            for (var i:int = 0; i < tempArray.length; i++) 
            {
                if(!(tempArray[i] as Bomb).isMine){
                    return tempArray[i];
                }
            }
            return null;
            
        }
        
        public function noVisibleElementsInTile(requestedTile:Point):Boolean {
            if(GameData.DEBUG_MODE)
            {
                trace("[com.willdom.games.bomberman.position.PositionManager] checking tile <"+requestedTile.x + ", " + requestedTile.y+"> for non-visible elements");
            }
            
            if(isTileEmpty(requestedTile.x, requestedTile.y)){
                return true;
            } else {
                for each(var moveObject:MoveObject in map[requestedTile.x][requestedTile.y] as Array){
                    if(moveObject == null){
                        continue;
                    }
                    if(moveObject.objectType == MoveObject.BOMB)
                    {
                        if(!(moveObject as Bomb).isMine)
                        {
                            return false;
                        }
                    } else {
                        return false;
                    }
                }
                return true;
            }
        }
        
        
        public function typedObjectsInTile(requestedTile:Point, objectType:uint):Array
        {
            if(GameData.DEBUG_MODE)
            {
                trace("[com.willdom.games.bomberman.position.PositionManager] checking tile <"+requestedTile.x + ", " + requestedTile.y+"> for objects of type " + objectType);
            }
            
            var output:Array = new Array();
            var tileX:Number = requestedTile.x;
            var tileY:Number = requestedTile.y;
            if(tileX < 0 || tileY < 0 || tileX >= GameData.instance.widthNum || tileY >= GameData.instance.heightNum){
                return output;
            }
            if(map[tileX][tileY] == null){
                return output;
            }
            for each(var moveObject:MoveObject in map[tileX][tileY] as Array){
                //TODO: check why this is happening at rematch
                if(moveObject == null){
                    continue;
                }
                if(moveObject.objectType == objectType) {
                    output.push(moveObject);
                }
            }
            return output;
        }
        
        public function bouncingBombInTile(requestedTile:Point):Bomb
        {
            var tileX:Number = requestedTile.x;
            var tileY:Number = requestedTile.y;
            if(tileX < 0 || tileY < 0 || tileX >= GameData.instance.widthNum || tileY >= GameData.instance.heightNum){
                return null;
            }
            if(map[tileX][tileY] == null){
                return null;
            }
            for each(var moveObject:MoveObject in map[tileX][tileY] as Array){
                //TODO: check why this is happening at rematch
                if(moveObject == null){
                    continue;
                }
                if(moveObject.objectType == MoveObject.BOMB && (moveObject as Bomb).bombType == Bomb.BOUNCING_BOMB) {
                    return (moveObject as Bomb);
                }
            }
            return null;
        }
        
        public function bombInTile(requestedTile:Point):Bomb
        {
            var tileX:Number = requestedTile.x;
            var tileY:Number = requestedTile.y;
            if(tileX < 0 || tileY < 0 || tileX >= GameData.instance.widthNum || tileY >= GameData.instance.heightNum){
                return null;
            }
            if(map[tileX][tileY] == null){
                return null;
            }
            for each(var moveObject:MoveObject in map[tileX][tileY] as Array){
                //TODO: check why this is happening at rematch
                if(moveObject == null){
                    continue;
                }
                if(moveObject.objectType == MoveObject.BOMB && (moveObject as Bomb).bombType != Bomb.MINE)
                {
                    return (moveObject as Bomb);
                }
            }
            return null;
        }
        
        public function notDangerousBombInTile(requestedTile:Point):Bomb
        {
            var tileX:Number = requestedTile.x;
            var tileY:Number = requestedTile.y;
            if(tileX < 0 || tileY < 0 || tileX >= GameData.instance.widthNum || tileY >= GameData.instance.heightNum){
                return null;
            }
            if(map[tileX][tileY] == null){
                return null;
            }
            for each(var moveObject:MoveObject in map[tileX][tileY] as Array){
                //TODO: check why this is happening at rematch
                if(moveObject == null){
                    continue;
                }
                if(moveObject.objectType == MoveObject.BOMB && (moveObject as Bomb).bombType != Bomb.DANGER_BOMB) {
                    return (moveObject as Bomb);
                }
            }
            return null;
        }
        
        public function getObjectsInTile(requestedTile:Point):Array
        {
            if(GameData.DEBUG_MODE)
            {
                trace("[com.willdom.games.bomberman.position.PositionManager] getting objects in tile <"+requestedTile.x + ", " + requestedTile.y+">");
            }
            
            var tileX:Number = requestedTile.x;
            var tileY:Number = requestedTile.y;
            return map[tileX][tileY] as Array;
        }
        
        public function getEmptyTile(tileX:Number, tileY:Number):Point
        {
            if(GameData.DEBUG_MODE)
            {
                trace("[com.willdom.games.bomberman.position.PositionManager] getting empty tile next to <"+ tileX + ", " + tileY+">");
            }
            
            while(!isTileEmpty(tileX, tileY)) {
                tileX++;
                if(tileX >= GameData.instance.widthNum){
                    tileX = 0;
                    tileY++;
                    tileY %= GameData.instance.heightNum;
                }
            }
            return new Point(tileX, tileY);
        }
        
        public function isTileEmpty(tileX:Number, tileY:Number):Boolean
        {
            if(GameData.DEBUG_MODE)
            {
                trace("[com.willdom.games.bomberman.position.PositionManager] is tile <"+ tileX + ", " + tileY+"> empty?");
            }
            
            return (map[tileX][tileY] == null || (map[tileX][tileY] as Array).length == 0);
        }
        
        public function stoppersInTile(requestedTile:Point):Boolean
        {
            if(GameData.DEBUG_MODE)
            {
                trace("[com.willdom.games.bomberman.position.PositionManager] getting stoppers in tile <"+requestedTile.x + ", " + requestedTile.y+">");
            }
            
            var tileX:Number = requestedTile.x;
            var tileY:Number = requestedTile.y;
            if(map[tileX][tileY] == null)
            {
                return false;
            }
            
            for each(var moveObject:MoveObject in map[tileX][tileY] as Array)
            {
                //TODO: check why this is happening at rematch
                if(moveObject == null)
                {
                    continue;
                }
                if(moveObject.stopsExplosionCategory == MoveObject.STOPS_EXPLOSION)
                {
                    return true;
                }
            }
            return false;
        }
        
        public function hardBlocksInTile(requestedTile:Point):Boolean
        {
            if(GameData.DEBUG_MODE)
            {
                trace("[com.willdom.games.bomberman.position.PositionManager] getting stoppers in tile <"+requestedTile.x + ", " + requestedTile.y+">");
            }
            
            var tileX:Number = requestedTile.x;
            var tileY:Number = requestedTile.y;
            if(map[tileX][tileY] == null)
            {
                return false;
            }
            
            for each(var moveObject:MoveObject in map[tileX][tileY] as Array)
            {
                //TODO: check why this is happening at rematch
                if(moveObject == null)
                {
                    continue;
                }
                if(moveObject.objectType == MoveObject.BOX)
                {
                    if((moveObject as Objects).isHardBlock())
                    {
                        return true;
                    }
                }
            }
            return false;
        }
        
        public function holeBlockInTile(requestedTile:Point):Boolean
        {
            if(GameData.DEBUG_MODE)
            {
                trace("[com.willdom.games.bomberman.position.PositionManager] getting stoppers in tile <"+requestedTile.x + ", " + requestedTile.y+">");
            }
            
            var tileX:Number = requestedTile.x;
            var tileY:Number = requestedTile.y;
            if(map[tileX][tileY] == null)
            {
                return false;
            }
            
            for each(var moveObject:MoveObject in map[tileX][tileY] as Array)
            {
                //TODO: check why this is happening at rematch
                if(moveObject == null)
                {
                    continue;
                }
                if(moveObject.objectType == MoveObject.HOLE)
                {
                    if((moveObject as ObjectHole).isHole())
                    {
                        return true;
                    }
                }
            }
            return false;
        }
        
        private function getOppositeDirection(dir:int):int
        {
            return (dir + 2) % 4;
        }
        
        public function getComposedExplosionArea(bomb:Bomb):ExplosionArea
        {
            var explosionArea:ExplosionArea = new ExplosionArea();
            var activeChunks:Array = new Array();
            var initialChunk:ExplosionChunk = new NormalBombExplosionChunk(bomb.area, false, false, bomb);
            if(bomb.bombType == Bomb.DANGER_BOMB)
            {
                initialChunk = new DangerousBombExplosionChunk(bomb);
            }
            else if(bomb.bombType == Bomb.SPIKE_BOMB)
            {
                initialChunk = new NormalBombExplosionChunk(bomb.area, true, false, bomb);
            }
            initialChunk.setCoordinatesAndAddChunkToExplosionArea(bomb.tilePoint, explosionArea);
            
            activeChunks.push(initialChunk);
            
            while(activeChunks.length > 0)
            {
                var currentChunk:ExplosionChunk = activeChunks.pop();
                var generatedChunks:Array = currentChunk.generateChunks(this, explosionArea, currentChunk.generatorBomb);
                for each (var newChunk:ExplosionChunk in generatedChunks) 
                {
                    activeChunks.push(newChunk);
                }
            }
            return explosionArea;
        }
        
        public function getCrossExplosionArea(requestedDirection:int, requestedTile:Point, limit:int):Array
        {
            if(GameData.DEBUG_MODE)
            {
                trace("[com.willdom.games.bomberman.position.PositionManager] getting cross explosion area in tile <"+requestedTile.x + ", " + requestedTile.y+">");
            }
            
            var processedTile:Point = requestedTile;
            var reservedTiles:Array = new Array();
            reservedTiles.push(requestedTile);
            for(var i:int=0;i<limit;i++)
            {
                if(GameData.DEBUG_MODE){
                    trace("[com.willdom.games.bomberman.position.PositionManager] processing tile");
                }
                
                processedTile = getNextTile(processedTile, requestedDirection);
                if(tileOuttOfBounds(processedTile))
                {
                    if(GameData.DEBUG_MODE){
                        trace("[com.willdom.games.bomberman.position.PositionManager] stoppers in tile or out of bounds");
                    }
                    break;
                } else if (stoppersInTile(processedTile)){
                    reservedTiles.push(processedTile);
                    if(GameData.DEBUG_MODE){
                        trace("[com.willdom.games.bomberman.position.PositionManager] adding tile <"+processedTile.x + ", " + processedTile.y+">");
                    }
                    break;
                }
                reservedTiles.push(processedTile);
                
                if(GameData.DEBUG_MODE){
                    trace("[com.willdom.games.bomberman.position.PositionManager] adding tile <"+processedTile.x + ", " + processedTile.y+">");
                }
            }
            
            if(GameData.DEBUG_MODE){
                trace("[com.willdom.games.bomberman.position.PositionManager] explosion area for direction: " + requestedDirection + ", turned out results: " + reservedTiles.length);
            }
            return reservedTiles;
        }
        
        public function getSquareExplosionArea(requestedTile:Point):Array
        {
            if(GameData.DEBUG_MODE)
            {
                trace("[com.willdom.games.bomberman.position.PositionManager] getting square explosion area for tile <"+requestedTile.x + ", " + requestedTile.y+">");
            }
            var processedTile:Point;
            var reservedTiles:Array = new Array();
            for(var i:int=-2; i<=2; i++)
            {
                for(var j:int=-2; j<=2; j++)
                {
                    processedTile = new Point(requestedTile.x + i, requestedTile.y + j);
                    if(tileOuttOfBounds(processedTile))
                    {
                        continue;
                    } else if (stoppersInTile(processedTile)){
                        reservedTiles.push(processedTile);
                        continue;
                    }
                    reservedTiles.push(processedTile);
                }
            }
            
            return reservedTiles;
        }
        
        
        public function incompatibleElements(objectType:uint, tileX:uint, tileY:uint, previousTileX:uint, previousTileY:uint):Boolean {
            if(GameData.DEBUG_MODE){
                trace("[com.willdom.games.bomberman.position.PositionManager] processing tile <" + tileX + ", " + tileY + ">");
            }
            var objectsInTile:Array = map[tileX][tileY] as Array;
            if(objectsInTile == null) {
                if(GameData.DEBUG_MODE){
                    trace("[com.willdom.games.bomberman.position.PositionManager] tile unset <" + tileX + ", " + tileY + ">");
                }
                return false;
            }
            for each(var moveObject:MoveObject in objectsInTile){
                //TODO: check why this is happening at rematch
                if(moveObject == null){
                    if(GameData.DEBUG_MODE){
                        trace("[com.willdom.games.bomberman.position.PositionManager] null element at <" + tileX + ", " + tileY + ">");
                    }
                    continue;
                }
                if(!moveObject.isCompatible(objectType, new Point(tileX, tileY), new Point(previousTileX, previousTileY))){
                    if(GameData.DEBUG_MODE){
                        trace("[com.willdom.games.bomberman.position.PositionManager] incompatible element at <" + tileX + ", " + tileY + "> (type " + moveObject.objectType + " with " + objectType + ") - " +objectsInTile.length +".");
                    }
                    return true;
                }
            }
            if(GameData.DEBUG_MODE){
                trace("[com.willdom.games.bomberman.position.PositionManager] tile <" + tileX + ", " + tileY + "> free");
            }
            return false;
        }
        
        public function requestMove(person:Person, prevTile:Point, requestedTile:Point, requestedDirection:int, objectType:uint, serialNumber:uint):void {
            if(GameData.DEBUG_MODE){
                trace("[com.willdom.games.bomberman.position.PositionManager] requesting to move from <" + prevTile.x + ", " + prevTile.y + "> to <" + requestedTile.x + ", " + requestedTile.y + ">.");
            }
            var absoluteSerial:uint = serialNumber * 100 + GameData.instance.myId;
            
            if(tileOuttOfBounds(requestedTile) || incompatibleElements(person.objectType, requestedTile.x, requestedTile.y, prevTile.x, prevTile.y)) {
                if(GameData.DEBUG_MODE){
                    trace("[com.willdom.games.bomberman.position.PositionManager] won't to move from <" + prevTile.x + ", " + prevTile.y + "> to <" + requestedTile.x + ", " + requestedTile.y + "> (incompatibility)");
                }
                dispatchEvent(getStartMovingCancelationEvent(prevTile.x, prevTile.y, serialNumber));
                return;
            }
            
            var params:SFSObject;
            var message:GameMessage;
            if(tileContainsBomb(requestedTile)) {
                var bouncingBomb:Bomb = bouncingBombInTile(requestedTile);
                if(person.objectType == MoveObject.PERSON && bouncingBomb == null)
                {
                    if(GameData.DEBUG_MODE){
                        trace("[com.willdom.games.bomberman.position.PositionManager] won't to move from <" + prevTile.x + ", " + prevTile.y + "> to <" + requestedTile.x + ", " + requestedTile.y + "> (bomb)");
                    }
                    dispatchEvent(getStartMovingCancelationEvent(prevTile.x, prevTile.y, serialNumber));
                    //TODO: finish flow and remove returns to make it clear
                    return;
                }
                else
                {
                    if(GameData.DEBUG_MODE)
                    {
                        trace("[com.willdom.games.bomberman.position.PositionManager] kicking bomb by walking from <" + prevTile.x + ", " + prevTile.y + "> to <" + requestedTile.x + ", " + requestedTile.y + ">");
                    }
                    params = new SFSObject();
                    params.putLong("serial", absoluteSerial);
                    params.putInt("personId", int(person.myId));
                    params.putInt("xtp",prevTile.x);
                    params.putInt("ytp",prevTile.y);
                    params.putInt("xt", requestedTile.x);
                    params.putInt("yt", requestedTile.y);
                    params.putInt("dir", requestedDirection);
                    
                    var bomb:Bomb = bombInTile(requestedTile);
                    
                    params.putLong("movementId", bomb.currentMovementId + 1);
                    params.putLong("objectId", bomb.bombId);
                    params.putLong("period", BOMB_PERIOD);
                    params.putLong("ttl", 18);
                    params.putInt(ServerMessages.ROUND_NUMBER,GameData.instance.currentRound);
                    
                    SmartFoxClientSingleton.getInstance().smartFoxClient.sendExtensionRequestToGameRoom(KICK_BOMB, params);
                }
            } else {
                if(GameData.DEBUG_MODE){
                    trace("[com.willdom.games.bomberman.position.PositionManager] moving from <" + prevTile.x + ", " + prevTile.y + "> to <" + requestedTile.x + ", " + requestedTile.y + ">");
                }
                params = new SFSObject();
                params.putLong("serial", absoluteSerial);
                //TODO Check if this.person.myId is equal to Game.data.instance.myId 
                params.putInt("personId", GameData.instance.myId);
                params.putInt("xtp",prevTile.x);
                params.putInt("ytp",prevTile.y);
                params.putInt("xt", requestedTile.x);
                params.putInt("yt", requestedTile.y);
                params.putInt("dir", requestedDirection);
                params.putInt(ServerMessages.ROUND_NUMBER,GameData.instance.currentRound);
                
                SmartFoxClientSingleton.getInstance().smartFoxClient.sendExtensionRequestToGameRoom(PERSON_POSITION_CONFIRMATION, params);
                dispatchEvent(getStartMovingConfirmationEvent(requestedTile.x, requestedTile.y, serialNumber));
            }
        }
        
        public function requestMoveAfterKicking(person:Person, prevTile:Point, requestedTile:Point, requestedDirection:int, objectType:uint, serialNumber:uint):void {
            if(GameData.DEBUG_MODE){
                trace("[com.willdom.games.bomberman.position.PositionManager] requesting to move (after kicking) from <" + prevTile.x + ", " + prevTile.y + "> to <" + requestedTile.x + ", " + requestedTile.y + ">.");
            }
            var absoluteSerial:uint = serialNumber * 100 + GameData.instance.myId;
            var params:SFSObject = new SFSObject();
            params.putLong("serial", absoluteSerial);
            params.putInt("personId", GameData.instance.myId);
            params.putInt("xtp",prevTile.x);
            params.putInt("ytp",prevTile.y);
            params.putInt("xt", requestedTile.x);
            params.putInt("yt", requestedTile.y);
            params.putInt(ServerMessages.ROUND_NUMBER,GameData.instance.currentRound);
            
            SmartFoxClientSingleton.getInstance().smartFoxClient.sendExtensionRequestToGameRoom(PERSON_POSITION_CONFIRMATION, params);
        }
        
        public function requestWarpMove():void 
        {
            var localWalkControlSet:LocalWalkControlSet = GameData.instance.walkControls[GameData.instance.myId];
            var currentPoint:Point = localWalkControlSet.currentTile;
            var nextNextPoint:Point = getNextTileInsideMap(currentPoint, localWalkControlSet.lastDirection, 3);
            var nextPoint:Point = getNextTileInsideMap(currentPoint, localWalkControlSet.lastDirection, 2);
            var params:SFSObject;
            var absoluteSerial:uint = (localWalkControlSet.serialNumber++) * 100 + GameData.instance.myId;
            
            if(nextNextPoint != null)
            {
                if(!incompatibleElements(MoveObject.PERSON, nextNextPoint.x, nextNextPoint.y, currentPoint.x, currentPoint.y))
                {
                    params = new SFSObject();
                    params.putLong("serial", absoluteSerial);
                    params.putInt("personId", GameData.instance.myId);
                    params.putInt("xtp",currentPoint.x);
                    params.putInt("ytp",currentPoint.y);
                    params.putInt("xt", nextNextPoint.x);
                    params.putInt("yt", nextNextPoint.y);
                    params.putInt("dir", localWalkControlSet.lastDirection);
                    params.putInt(ServerMessages.ROUND_NUMBER,GameData.instance.currentRound);
                    SmartFoxClientSingleton.getInstance().smartFoxClient.sendExtensionRequestToGameRoom(MOVEMENT_WARP, params);
                    return;
                }
            }
            
            if(nextPoint != null)
            {
                if(!incompatibleElements(MoveObject.PERSON, nextPoint.x, nextPoint.y, currentPoint.x, currentPoint.y))
                {
                    params = new SFSObject();
                    params.putLong("serial", absoluteSerial);
                    params.putInt("personId", GameData.instance.myId);
                    params.putInt("xtp",currentPoint.x);
                    params.putInt("ytp",currentPoint.y);
                    params.putInt("xt", nextPoint.x);
                    params.putInt("yt", nextPoint.y);
                    params.putInt("dir", localWalkControlSet.lastDirection);
                    params.putInt(ServerMessages.ROUND_NUMBER,GameData.instance.currentRound);
                    SmartFoxClientSingleton.getInstance().smartFoxClient.sendExtensionRequestToGameRoom(MOVEMENT_WARP, params);
                    return;
                }
            }
        }
        
        private function getMaxMovementLength(requestedTile:Point, requestedDirection:int):uint
        {
            var nextTile:Point = getNextTile(requestedTile, requestedDirection);
            var maxMovements:uint=0;
            while(canBeReservedByBomb(nextTile)) {
                maxMovements++;
                nextTile = getNextTile(nextTile, requestedDirection);
            }

            return maxMovements;
        }
        
        public function canBeReservedByBomb(tile:Point):Boolean
        {
            return tile != null && (!(boxInTile(tile) || tileOuttOfBounds(tile) || incompatibleElements(MoveObject.BOMB, tile.x, tile.y, tile.x, tile.y)));
        }
        
        public function moveItem(requestedTile:Point, requestedDirection:int):void {
            if(GameData.DEBUG_MODE){
                trace("[com.willdom.games.bomberman.position.PositionManager] move item at <" + requestedTile.x + ", " + requestedTile.y + ">");
            }
            var processedTile:Point = requestedTile;
            var reservedTiles:Array = new Array();
            for(;;)
            {
                if(GameData.DEBUG_MODE){
                    trace("[com.willdom.games.bomberman.position.PositionManager] processing tile");
                }
                processedTile = getNextTile(processedTile, requestedDirection);
                if(tileOuttOfBounds(processedTile) ||
                    !noVisibleElementsInTile(processedTile)) {
                    if(GameData.DEBUG_MODE){
                        trace("[com.willdom.games.bomberman.position.PositionManager] element in tile or out of bounds");
                    }
                    break;
                }
                reservedTiles.push(processedTile);
            }

            var finalTile:Point = reservedTiles[reservedTiles.length-1];

            if(reservedTiles.length > 0){
                if(GameData.DEBUG_MODE){
                    trace("[com.willdom.games.bomberman.position.PositionManager] moving item from tile <" + requestedTile.x + ", " + requestedTile.y + "> to <"+finalTile.x + ", " + finalTile.y +">");
                }
                
                for each(var item:Treasure in typedObjectsInTile(requestedTile, MoveObject.TREASURE)) {
                    removeObjectFromMap(requestedTile.x, requestedTile.y, item);
                    addObjectToMap(finalTile.x, finalTile.y, item);
                    item.targetPoint = new Point((finalTile.x+0.5)*GameData.instance.rectWidth,(finalTile.y+0.5)*GameData.instance.rectWidth+ GameData.instance.upLine);
                    item.currentTile = finalTile;
                    item.movingDirection = requestedDirection;
                }
            }
        }
        
        public function sendStartMovingConfirmationEvent(tileX:uint, tileY:uint, serialNumber:uint):void
        {
            dispatchEvent(getStartMovingConfirmationEvent(tileX, tileY, serialNumber));
        }
        
        private function getStartMovingConfirmationEvent(tileX:uint, tileY:uint, serialNumber:uint):PositionEvent
        {
            return getPositionEvent(PositionEvent.PERSON_START_MOVING_CONFIRMATION, tileX, tileY, serialNumber);
        }
        
        public function sendStartMovingCancelationEvent(previousTileX:uint, previousTileY:uint, serialNumber:uint):void
        {
            dispatchEvent(getStartMovingCancelationEvent(previousTileX, previousTileY, serialNumber));
        }
        
        private function getStartMovingCancelationEvent(tileX:uint, tileY:uint, serialNumber:uint):PositionEvent
        {
            return getPositionEvent(PositionEvent.PERSON_START_MOVING_CANCELATION, tileX, tileY, serialNumber);
        }
        
        private function getPositionEvent(type:String, tileX:uint, tileY:uint, serialNumber:uint):PositionEvent
        {
            var output:PositionEvent = new PositionEvent(type);
            output.tileX = tileX;
            output.tileY = tileY;
            output.serialNumber = serialNumber;
            output.userId = ""+GameData.instance.myId;
            return output;
        }
        
        public function sendPositionConfirmationEvent(requestedTile:Point, serial:Number, personId:int):void
        {
            dispatchEvent(createPositionConfirmationEvent(requestedTile, serial, personId));
        }
        
        public function createPositionConfirmationEvent(requestedTile:Point, absoluteSerial:uint, myId:uint):PositionEvent
        {
            var positionEvent:PositionEvent = new PositionEvent(PositionEvent.PERSON_POSITION_CONFIRMATION);
            positionEvent.tileX = requestedTile.x;
            positionEvent.tileY = requestedTile.y;
            positionEvent.serialNumber = absoluteSerial;
            positionEvent.userId = ""+myId;
            return positionEvent;
        }
        
        public function sendPositionCancelationEvent(previousTile:Point, absoluteSerial:int, personId:int):void
        {
            dispatchEvent(createPositionCancelationEvent(previousTile, absoluteSerial, personId));
        }
        
        public function createPositionCancelationEvent(previousTile:Point, absoluteSerial:uint, myId:uint):PositionEvent
        {
            var positionEvent:PositionEvent = new PositionEvent(PositionEvent.PERSON_POSITION_CANCELATION);
            positionEvent.tileX = previousTile.x;
            positionEvent.tileY = previousTile.y;
            positionEvent.serialNumber = absoluteSerial;
            positionEvent.userId = ""+myId;
            return positionEvent;
        }
        
        public function addObjectToMap(tileX:uint, tileY:uint, moveObject:MoveObject):void
        {
            if(GameData.DEBUG_MODE || GameData.SHOW_ELEMENTS)
            {
                //trace("[com.willdom.games.bomberman.position.PositionManager] adding " + getObjectString(moveObject) + " at " + getTileString(tileX, tileY) + "; before in tile: " + getRemainingElementsString(map[tileX][tileY] as Array));
                trace("agregando objeto del mapa" + " - tileX: " + tileX + " tileY: " + tileY);
                dispatchEvent(new Event("objectAdded"));
            }

            if(map[tileX][tileY] == null)
            {
                map[tileX][tileY] = new Array();
            }
            if((map[tileX][tileY] as Array).indexOf(moveObject) < 0)
            {
                (map[tileX][tileY] as Array).push(moveObject);
                if(moveObject is Treasure){
                    treasures.push(moveObject);
                }
            }
            if(GameData.DEBUG_MODE){
                trace("[com.willdom.games.bomberman.position.PositionManager] added " + getObjectString(moveObject) + " at " + getTileString(tileX, tileY) + "; then in tile: " + getRemainingElementsString(map[tileX][tileY] as Array));
            }
        }
        
        public function getItemsFromTile(tileX:uint, tileY:uint, person:Person):void
        {
            for(var i:uint=0;i<(map[tileX][tileY] as Array).length;i++)
            {
                if(map[tileX][tileY][i] is Treasure)
                {
                    (map[tileX][tileY][i] as Treasure).itemCaught(person);
                    removeObjectFromMap(tileX,tileY,map[tileX][tileY][i]);
                }
            }
        }
        
        public function initPersonPosition(tileX:uint, tileY:uint, person:Person):void
        {
            addObjectToMap(tileX, tileY, person);
        }
        
        public function removeObjectFromMap(tileX:uint, tileY:uint, moveObject:MoveObject):void
        {
            if(!singleRemoveObjectFromMap(tileX, tileY, moveObject))
            {
                exhaustiveRemoveObjectFromMap(moveObject);
            }
            
            if(GameData.DEBUG_MODE || GameData.SHOW_ELEMENTS)
            {
                trace("removiendo objeto del mapa" + " - tileX: " + tileX + " tileY: " + tileY);
                 //trace("[com.willdom.games.bomberman.position.PositionManager] removing " + getObjectString(moveObject) + " at " + getTileString(tileX, tileY) + "; before in tile: " + getRemainingElementsString(map[tileX][tileY] as Array));
                dispatchEvent(new Event("objectRemoved"));
            }
        }
        
        /**
         * Looks anywhere in the map to remove the object.
         * 
         * //TODO: optiomize this or avoid circumpstances when it occurs.
         */
        private function exhaustiveRemoveObjectFromMap(moveObject:MoveObject):void{
            for(var tileX:Number=0; tileX<GameData.instance.widthNum; tileX++)
            {
                for(var tileY:Number=0; tileY<GameData.instance.heightNum; tileY++)
                {
                    if(singleRemoveObjectFromMap(tileX, tileY, moveObject))
                    {
                        return;
                    }
                }
            }
        }
        
        public function singleRemoveObjectFromMap(tileX:uint, tileY:uint, moveObject:MoveObject):Boolean
        {
            if(GameData.DEBUG_MODE){
                trace("[com.willdom.games.bomberman.position.PositionManager] removing " + getObjectString(moveObject) + " from " + getTileString(tileX, tileY)+ "; before in tile: " + getRemainingElementsString(map[tileX][tileY] as Array));
            }
            
            if(map[tileX][tileY] == null){
                map[tileX][tileY] = new Array();
            }
            
            var targetArray:Array = map[tileX][tileY] as Array;
            var targetIndex:Number = targetArray.indexOf(moveObject);
            if(targetIndex >= 0 )
            {
                targetArray.splice(targetIndex, 1);
                if(GameData.DEBUG_MODE){
                    trace("[com.willdom.games.bomberman.position.PositionManager] object " + getObjectString(moveObject) + " removed from " + getTileString(tileX, tileY)+ "; then in tile: " + getRemainingElementsString(map[tileX][tileY] as Array));
                }
                return true;
            } 
            else
            {
                if(GameData.DEBUG_MODE){
                    trace("[com.willdom.games.bomberman.position.PositionManager] object " + getObjectString(moveObject) + " could not be removed from " + getTileString(tileX, tileY)+ "; then in tile: " + getRemainingElementsString(map[tileX][tileY] as Array));
                }
                return false;
            }
        }
        
        public function copyMap(fromMap:Array,toMap:Array):void{
            
            for(var i:uint=0;i<fromMap.length;i++){
                for(var j:uint=0;j<fromMap[i].length;j++){
                    toMap[i][j] = new Array();
                    if(fromMap[i][j]!=null){
                        toMap[i][j] = (fromMap[i][j] as Array).slice();
                    }
                }
            }
        }
        
        public function restoreMap():void
        {
            if(GameData.DEBUG_MODE)
            {
                trace("[com.willdom.games.bomberman.position.PositionManager] retoring map");
            }

            var i:uint;
            var j:uint;
            var k:uint;
            var amount:uint;

            for(i = 0; i < map.length; i++){
                for(j = 0; j < map[i].length; j++){
                    amount = 0;
                    while(map[i][j] != null && map[i][j][0] is MoveObject && amount < 2){
                        amount ++;
                        if(map[i][j][0] is Treasure)
                        {
                            (map[i][j][0] as Treasure).removeMe();
                        } 
                        else if(map[i][j][0] is Bomb)
                        {
                            (map[i][j][0] as Bomb).removeMe();
                        }
                    }
                }
            }

            copyMap(initialMap,map);

            for(i = 0; i < map.length; i++){
                for(j = 0; j < map[i].length; j++){
                    for(k = 0; map[i][j] != null && k < map[i][j].length; k++){
                        (map[i][j][k] as MoveObject).restore();
                    }
                }
            }
            
            for each(var box:Objects in GameData.instance.immediateOpenBoxes){
                box.openBox(1);
            }
            
        }
        
        public function setInitialMap():void
        {
            copyMap(map, initialMap);
        }
        
        public static function tileOuttOfBounds(requestedTile:Point):Boolean
        {
            return tileCoordinatesOuttOfBounds(requestedTile.x, requestedTile.y);
        }
        
        public static function boxInTile(requestedTile:Point):Boolean
        {
            if(GameData.DEBUG_MODE)
            {
                trace("[com.willdom.games.bomberman.position.PositionManager] is there a box in tile <"+requestedTile.x + ", " + requestedTile.y+">?");
            }
            
            return boxInTileCoordinates(requestedTile.x, requestedTile.y);
        }
        
        public static function tileCoordinatesOuttOfBounds(tileX:Number, tileY:Number):Boolean
        {
            return tileX < 0 || tileX >= GameData.instance.widthNum
                || tileY < 0 || tileY >= GameData.instance.heightNum;
        }
        
        public static function boxInTileCoordinates(tileX:Number, tileY:Number):Boolean
        {
            var objects:Object = GameData.instance.mapObject;
            var staticObject:MoveObject = GameData.instance.mapObject[""+tileX+"_"+tileY] as MoveObject;
            return staticObject != null && staticObject.myMcName != null && staticObject.myMcName.search("Box")>-1 && !staticObject.fire;
        }
        
        /**
         * Method used for testing purposes.
         * Don't use it in any other context.
         */
        public function get pointsWithPersonsOnStage():Array
        {
            var output:Array = new Array();
            for(var tileX:Number=0; tileX<GameData.instance.widthNum; tileX++){
                for(var tileY:Number=0; tileY<GameData.instance.heightNum; tileY++){
                    if(map[tileX][tileY] == null){
                        continue;
                    }
                    for each(var moveObject:MoveObject in map[tileX][tileY] as Array){
                        if(moveObject == null){
                            continue;
                        } else    if(moveObject.objectType == MoveObject.PERSON || moveObject.objectType == MoveObject.KICKER) {
                            output.push(new Point(tileX, tileY));
                        }
                    }
                    
                }
            }
            return output;
        }
        
        public function get bombsInMap():Boolean
        {
            var output:Array = new Array();
            for(var tileX:Number=0; tileX<GameData.instance.widthNum; tileX++){
                for(var tileY:Number=0; tileY<GameData.instance.heightNum; tileY++){
                    if(map[tileX][tileY] == null){
                        continue;
                    }
                    for each(var moveObject:MoveObject in map[tileX][tileY] as Array){
                        if(moveObject == null){
                            continue;
                        } else    if(moveObject.objectType == MoveObject.BOMB && !((moveObject as Bomb).isMine) ) {
                            return true;
                        }
                    }
                    
                }
            }
            return false;
        }
        
        /**
         * Method used for testing purposes.
         * Don't use it in any other context.
         */
        public function getPointsWithObjectsOnStage(objectType:uint):Array
        {
            var output:Array = new Array();
            for(var tileX:Number=0; tileX < GameData.instance.widthNum; tileX++){
                for(var tileY:Number=0; tileY<GameData.instance.heightNum; tileY++){
                    if(map[tileX][tileY] == null){
                        continue;
                    }
                    for each(var moveObject:MoveObject in map[tileX][tileY] as Array){
                        if(moveObject == null){
                            continue;
                        } else    if(moveObject.objectType == objectType) {
                            output.push(new Point(tileX, tileY));
                        }
                    }                    
                }
            }
            return output;
        }
        
        private function getObjectString(moveObject:MoveObject):String {
            var objectType:String = "object"; 
            if(moveObject.objectType == MoveObject.BOMB){
                var bombType:String = "bomb";
                var bomb:Bomb = moveObject as Bomb;
                if(bomb.isMine) {
                    bombType = "mine";
                }
                objectType = bombType + "[" + bomb.bombId + "]";
            }                    
            return objectType + " (type " + moveObject.objectType + ")";
        }
        
        private function getTileString(tileX:Number, tileY:Number):String {
            return "<"+tileX + ", " + tileY + ">";
        }
        
        private function getPointString(tile:Point):String {
            return getTileString(tile.x, tile.y);
        }
        
        private function getRemainingElementsString(elements:Array):String
        {
            if(elements == null)
            {
                return "";
            }
            var elementsText:String = "";
            var separator:String = "{";
            for each(var moveObject:MoveObject in elements)
            {
                elementsText = elementsText + separator + getObjectString(moveObject);
                separator = " | ";
            }
            elementsText += "}";
            return elementsText;
        }
        
        public function destroyTreasures():void
        {
            for each(var treasure:Treasure in treasures)
            {
                treasure.destroy();
            }
            treasures = new Array();
        }
    }
}