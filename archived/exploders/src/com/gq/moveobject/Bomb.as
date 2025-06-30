package com.gq.moveobject
{
    import ar.com.sodhium.util.displaymanagement.displaystate.FinalizableDisplayState;
    
    import com.deviant.HueColorMatrixFilter;
    import com.gq.system.*;
    import com.smartfoxserver.v2.entities.data.SFSArray;
    import com.smartfoxserver.v2.entities.data.SFSObject;
    import com.willdom.games.bomberman.Explosions.ExplodingCell;
    import com.willdom.games.bomberman.Explosions.ExplosionArea;
    import com.willdom.games.bomberman.Explosions.ExplosionChunk;
    import com.willdom.games.bomberman.communication.GameMessage;
    import com.willdom.games.bomberman.communication.SmartFoxClientSingleton;
    import com.willdom.games.bomberman.consts.ServerMessages;
    import com.willdom.games.bomberman.controllers.ConfigController;
    import com.willdom.games.bomberman.gameobjects.bombs.BombManager;
    import com.willdom.games.bomberman.position.PositionManager;
    import com.willdom.games.explodersmmo.shared.stats.StatsManager;
    
    import flash.display.DisplayObject;
    import flash.display.DisplayObjectContainer;
    import flash.display.MovieClip;
    import flash.filters.ColorMatrixFilter;
    import flash.geom.Point;
    

    /**
     * Class to represent bombs.
     * It is responsible for mantaining status for the bomb,
     * updating position and exploding.
     */
    public class Bomb extends MoveObject
    {
        public static const NORMAL_BOMB:String = "1";
        public static const SPIKE_BOMB:String = "2";
        public static const DANGER_BOMB:String = "3";
        public static const POWER_BOMB:String = "4";
        public static const MINE:String = "5";
        public static const BOUNCING_BOMB:String = "6";
        public static const DEADLY_BLOCK:String = "7";
        public static const SKULL_DEATH:String = "8";
        private static const STEP_SIZE_X:int = 14;
        private static const STEP_SIZE_Y:int = 14;

        private var _area:uint = 1;
        public var moveMode:Boolean;
        private var moveCount:uint;
        private var isGo:Boolean;
        public var apearMode:String;
        private var count:uint;
        private var markArr:Array;
        private var mySound:String;
        public var isMine:Boolean;
        public var isActive:Boolean;
        private var activeMessageSent:Boolean;
        public var movingDirection:int;
        public var targetPoints:Array;
        private var _tilePoint:Point;
        public var bombId:uint;
        private var explodeConfirmed:Boolean;
        public var movementSequence:uint;
        public var lastMovementId:int;
        public var isTriggered:Boolean;
        public var hasSentTriggerMessage:Boolean;
        private var canceledMovements:Object;
        public var owner:Person;
        /**
         * Sequence for firing timer.
         */
        private var sequenceNumber:int;
        private var currentDisplayState:FinalizableDisplayState;
        private var nextDisplayState:FinalizableDisplayState;
        private var normalDisplayState:FinalizableDisplayState;
        private var upBouncingDisplayState:FinalizableDisplayState;
        private var downBouncingDisplayState:FinalizableDisplayState;
        private var leftBouncingDisplayState:FinalizableDisplayState;
        private var rightBouncingDisplayState:FinalizableDisplayState;

        public function Bomb():void
        {
            objectType = BOMB;
            movingDirection = PositionManager.NONE;
            isActive = false;
            activeMessageSent = false;
            movementSequence = 0;
            lastMovementId = 0;
            isTriggered = false;
            hasSentTriggerMessage = false;
            targetPoints = new Array();
            canceledMovements = new Object();
            sequenceNumber = 0;
            normalDisplayState = new FinalizableDisplayState(1, 20);
            leftBouncingDisplayState = new FinalizableDisplayState(21, 24);
            rightBouncingDisplayState = new FinalizableDisplayState(25, 28);
            downBouncingDisplayState = new FinalizableDisplayState(29, 32);
            upBouncingDisplayState = new FinalizableDisplayState(33, 36);
            currentDisplayState = normalDisplayState;
            nextDisplayState = normalDisplayState;
        }
        
        public function get sequence():int
        {
            return sequenceNumber;
        }
        
        public function morph(movieClip:MovieClip, bombType:String, bombIndex:int):void
        {
             sequenceNumber++;
             movieClip.x = _this.x;
             movieClip.y = _this.y;
             var parent:DisplayObjectContainer = _this.parent;
             parent.removeChild(_this);
             _this = movieClip;
             parent.addChild(movieClip);
             data_index = bombIndex;
             stopMoving();
             var sfsObject:SFSObject = new SFSObject();
             sfsObject.putLong("bombId", this.bombId);
             sfsObject.putInt("seq", this.sequenceNumber);
             sfsObject.putUtfString("_m", (this.myMaster as Person).myName);
             sfsObject.putLong("_x", this.tilePoint.x);
             sfsObject.putLong("_y", this.tilePoint.y);
             sfsObject.putInt(ServerMessages.ROUND_NUMBER,GameData.instance.currentRound);

             SmartFoxClientSingleton.getInstance().smartFoxClient.sendExtensionRequestToGameRoom(BombManager.SET_BOMB, sfsObject);
        }
        
        public function stopMoving():void
        {
            if(targetPoints.length > 0) {
                targetPoints = new Array();
            }
            var absPoint:Point = new Point((tilePoint.x + 0.5) * GameData.instance.rectWidth,(tilePoint.y + 0.5)*GameData.instance.rectWidth+ GameData.instance.upLine);
            myX = absPoint.x;
            myY = absPoint.y;
            movingDirection = PositionManager.NONE;
            controlMc();
        }
        
        public function switchDirection():void
        {
            if(movingDirection == PositionManager.WEST)
            {
                currentDisplayState = leftBouncingDisplayState;
            }
            else if(movingDirection == PositionManager.EAST)
            {
                currentDisplayState == rightBouncingDisplayState;
            }
            else if(movingDirection == PositionManager.NORTH)
            {
                currentDisplayState = upBouncingDisplayState;
            }
            else if(movingDirection == PositionManager.SOUTH)
            {
                currentDisplayState = downBouncingDisplayState;
            }
            movingDirection = (movingDirection + 2)%4;            
        }

        public function addTargetPoint(point:Point):void
        {
            targetPoints.push(point);
        }

        override protected function initMyData():void
        {
            super.initMyData();
            GameTools.pushArr( GameData.instance.bombArr, this );
            SoundClass.addMusic("sound" + String( uint( Math.random() * 7 ) + 1 ), "setBomb");

            mySound = ( data_index == 2 ) ? "explore_2" : "explore_1";

            if( data_index == 3 )
            {
                area = 8;
            }
            movingDirection = PositionManager.NONE;
            explodeConfirmed = false;
        }
        
        public function get bombType():String
        {
            if(data_index == 2)
            {
                return DANGER_BOMB;
            }
            else if(data_index == 3)
            {
                return POWER_BOMB;
            }
            else if(data_index == 4)
            {
                return MINE;
            }
            else if(data_index == 5)
            {
                return BOUNCING_BOMB;
            }
            else if(data_index == 6){
                return DEADLY_BLOCK;
            }
            else if(data_index == 1)
            {
                return SPIKE_BOMB;
            }
            else
            {
                return NORMAL_BOMB;
            }
        }

        private function fallen():void
        {
            myZ += 800 / 40;
            if( myZ == 0 )
            {
                apearMode = "";
            }
        }

        override public function updataEvent():void
        {
            if(bombType == BOUNCING_BOMB)
            {
                (_this as Bomb_6).animation.gotoAndStop(currentDisplayState.getNextFrame());
                if(currentDisplayState.isFinalized())
                {
                    currentDisplayState.reset();
                    currentDisplayState = nextDisplayState;
                }
            }
            if(isMine && _this != null) 
            {
                if(_this.alpha > 30/GameData.MINE_DISSAPEARENCE_TIME){
                    _this.alpha -= 30/GameData.MINE_DISSAPEARENCE_TIME;
                } else {
                    _this.alpha = 0;
                    if(!isActive && !activeMessageSent)
                    {
                        activeMessageSent = true;
                        var params:SFSObject = new SFSObject();
                        params.putLong("bombId", bombId);
                        params.putInt("xt",tilePoint.x);
                        params.putInt("yt",tilePoint.y);
                        params.putInt(ServerMessages.ROUND_NUMBER,GameData.instance.currentRound);
                        SmartFoxClientSingleton.getInstance().smartFoxClient.sendExtensionRequestToGameRoom(BombManager.ACTIVATE_MINE, params);
                    }
                }
                return;
            }
            if(apearMode == "fall")
            {
                fallen();
                controlMc();
                return;
            }

            if(isGo)
            {
                checkGo();
                controlMc();
                return
            }

            if( moveMode )
            {
                controlMc();
                return;
            }
            walkToTarget();
        }

        //TODO: check if this will be needed for revenge mode (probably will have to be re-written)
        public function go( _x:int, _y:int, area:uint ):void
        {
            isGo = true;
            _area = area;
            if( _x == 0 )
            {
                speedX = 10;
            }
            else if( _x == GameData.instance.widthNum - 1 )
            {
                speedX = -10;
            }
            else if( _y == 0 )
            {
                speedY = 10;
            }
            else if( _y == GameData.instance.heightNum - 1 )
            {
                speedY = -10;
            }
            if(_this != null)
            {
                GameData.instance.topObjectContainer.addChild( _this );
            }
            SoundClass.addMusic( "sound" + String( uint( Math.random() * 7 ) + 1 ), "kick" );
        }

        private function checkGo():void
        {
            myX += speedX;
            myY += speedY;
            getMyPosition();
            if( ( speedX != 0 && (myCurrentPositionX == 3 || myCurrentPositionX == GameData.instance.widthNum - 4) )
             || ( speedY != 0 && (myCurrentPositionY == 3 || myCurrentPositionY == GameData.instance.heightNum - 4) ) )
            {
                myX = (myCurrentPositionX + 0.5) * GameData.instance.rectWidth;
                myY = (myCurrentPositionY + 0.5) * GameData.instance.rectHeight;
                isGo = false;
                initial(area);
                if( GameData.instance.mapArr[myCurrentPositionX][myCurrentPositionY] == 1 )
                {
                    for( var i:uint = 0; i < GameData.instance.boxArr.length; i++ )
                    {
                        if( GameData.instance.boxArr[i].myCurrentPositionX == myCurrentPositionX && GameData.instance.boxArr[i].myCurrentPositionY == myCurrentPositionY)
                        {
                            GameData.instance.boxArr[i].fireMe();
                        }
                    }
                }
            }
        }

        /**
         * 
         * @returns explosion area, in an array organized by
         * direction, in which each one of the four elements
         * contains an array with the explosion area for the
         * indexed direction.
         * 
         */
        private function getExplosionArea():Array {
            if(GameData.DEBUG_MODE)
            {
                trace("[com.gq.moveobject.Bomb] "+ bombId + ": getting my explosion area");
            }
            if(data_index == 2) {
                return getSquareExplosionArea();
            } else {
                return getCrossExplosionArea();    
            }
        }
        
        private function getCrossExplosionArea():Array
        {
            var explosionArea:Array = new Array();
            for(var i:int=PositionManager.WEST;i<=PositionManager.SOUTH;i++)
            {
                var partialArea:Array = GameData.instance.positionManager.getCrossExplosionArea(i, tilePoint, area);
                explosionArea[i] = partialArea;
            }
            return explosionArea;
        }
        
        private function getSquareExplosionArea():Array {
            return GameData.instance.positionManager.getSquareExplosionArea(tilePoint);
        }

        /**
         * 
         * @returns every tile of explosion area.
         * 
         */
        private function getLinealExplosionArea():Array {
            var explosionArea:Array = new Array();
            for(var i:int=PositionManager.WEST;i<=PositionManager.SOUTH;i++)
            {
                var partialArea:Array = GameData.instance.positionManager.getCrossExplosionArea(i, tilePoint, area);
                for each(var tilePosition:Point in partialArea){
                    explosionArea.push(tilePosition);
                }
            }
            return explosionArea;
        }

        //TODO: refactor and make just 1: clear and getExplosionArea
        private function clearCrossExplosionArea():Array
        {
            var explosionArea:Array = new Array();
            for(var i:int=PositionManager.WEST; i <= PositionManager.SOUTH;i++)
            {
                var partialArea:Array = GameData.instance.positionManager.getCrossExplosionArea(i, tilePoint, area);
                explosionArea[i] = partialArea;
                for each(var firedPoint:Point in partialArea)
                {
                    var objectsInTile:Array = GameData.instance.positionManager.getObjectsInTile(firedPoint);
                    for each(var firedObject:MoveObject in objectsInTile)
                    {
                        firedObject.fireMe(this);
                    }
                }
            }
            GameData.instance.mapArr[myCurrentPositionX][myCurrentPositionY] = 0;
            return explosionArea;
        }

        private function clearMineExplosionArea():void
        {
            var objectsInTile:Array = GameData.instance.positionManager.getObjectsInTile(tilePoint);
            for each(var firedObject:MoveObject in objectsInTile)
            {
                firedObject.fireMe(this);
            }

            GameData.instance.mapArr[myCurrentPositionX][myCurrentPositionY] = 0;
        }
        
        //TODO: refactor and make just one: clear and getExplosionArea
        private function clearSquareExplosionArea():Array
        {
            var explosionArea:Array = GameData.instance.positionManager.getSquareExplosionArea(tilePoint);
            for each(var firedPoint:Point in explosionArea)
            {
                var objectsInTile:Array = GameData.instance.positionManager.getObjectsInTile(firedPoint);
                for each(var firedObject:MoveObject in objectsInTile)
                {
                    firedObject.fireMe(this);
                }
            }
            return explosionArea;
        }

        
        private function clearArea():Array {
            if(data_index == 2) {
                return clearSquareExplosionArea();
            } else {
                return clearCrossExplosionArea();    
            }
        }

        override public function fireMe(bomb:Bomb):void
        {
            if(!isMine && this != bomb && !fire)
            {
                fire = true;
            }
        }

        public function blowMine():void
        {
            if(isMine && isActive)
            {
                if(GameData.DEBUG_MODE)
                {
                    trace("[com.gq.moveobject.Bomb] "+ bombId + ": Mine blown at <" + tilePoint.x + ", " + tilePoint.y + ">. My master is " + (myMaster as Person).myId);
                }

                fire = true;
                clearMineExplosionArea();
                GameTools.unPushArr(GameData.instance.bombArr, this);
                explodeConfirmed = true;
                var tempX:Number = tilePoint.x * GameData.instance.rectWidth;
                var tempY:Number = tilePoint.y * GameData.instance.rectHeight + GameData.instance.upLine;
                GameSys.addEffects(GameData.instance.topObjectContainer, "ExploreEffect", "Effect_6", tempX, tempY, 0, 1, 0).myMaster = myMaster;
                SoundClass.addMusic("sound" + String( uint( Math.random() * 7 ) + 1 ), mySound );
                if(GameData.DEBUG_MODE)
                {
                    trace("[com.gq.moveobject.Bomb] "+ bombId + ": removing mine from <" + myCurrentPositionX + ", " + myCurrentPositionY + ">.");
                }
                
                removeMeFromMap();
                    
            }
        }

        public function confirmExplosion(position:Point):void {
            if(fire)
            {
                return;
            }

            if(GameData.DEBUG_MODE)
            {
                trace("[com.gq.moveobject.Bomb] "+ bombId + ": Explosion confirmed. My master is " + (myMaster as Person).myId);
            }
            
            fire = true;
            if(myMaster && data_index != 4 )
            {
                (myMaster as Person)._bombsOnFieldArray.splice((myMaster as Person)._bombsOnFieldArray.indexOf(this), 1);
            }
            var newExplosionArea:ExplosionArea = GameData.instance.positionManager.getComposedExplosionArea(this);
            var corridorExplosions:Array = new Array();
            var normalExplosions:Array = new Array();
            var stopperExplosions:Array = new Array();
            var dangerousExplosions:Array = new Array();
            var penetratingExplosions:Array = new Array();
            var peopleKilled:Array = new Array();
            var ownerKilled:Boolean = false;
            for each (var explodingCell:ExplodingCell in newExplosionArea.explodingCells) 
            {
                for each(var chunk:ExplosionChunk in explodingCell.explosionChunks)
                {
                    if(chunk.chunkType == ExplosionChunk.CORRIDOR_CHUNK)
                    {
                        corridorExplosions.push(chunk);
                    }
                    if(chunk.chunkType == ExplosionChunk.NORMAL_BOMB_CHUNK)
                    {
                        normalExplosions.push(chunk);
                    }
                    if(chunk.chunkType == ExplosionChunk.STOPPER_CHUNK)
                    {
                        stopperExplosions.push(chunk);
                    }
                    if(chunk.chunkType == ExplosionChunk.DANGEROUS_BOMB_CHUNK)
                    {
                        dangerousExplosions.push(chunk);
                    }
                }
                var firedPoint:Point = new Point(explodingCell.x, explodingCell.y);
                var objectsInTile:Array = GameData.instance.positionManager.getObjectsInTile(firedPoint);
                if(objectsInTile != null)
                {
                    objectsInTile = objectsInTile.concat();
                }
                for each(var firedObject:MoveObject in objectsInTile)
                {
                    firedObject.fireMe(this);
                    if(firedObject is Person && !(firedObject as Person).invincible){
                        peopleKilled.push(firedObject);
                    }
                    if(firedObject == owner)
                    {
                        ownerKilled = true;
                    }
                    if(firedObject is Objects)
                    {
                        if(!(firedObject as Objects).isHardBlock())
                        {
                            if((myMaster as Person).userId == SmartFoxClientSingleton.getInstance().smartFoxClient.myself.id)
                            {
                                StatsManager.instance.onSoftBlockedDestroyed();
                            }
                        }
                    }
                }
            }
            
            var personToScore:Person = myMaster as Person;
            if(!ownerKilled && owner != null)
            {
                personToScore = owner;
                if(GameData.DEBUG_MODE){
                    trace("Points to owner:" + owner.currentName);
                }
            } else {
                if(GameData.DEBUG_MODE){
                    trace("No new owner, points to:" + personToScore.currentName);
                }
            }
            
            var peopleKilledCount:int = 0;
            var pointsKilled:int = 0;
            
            var bombExplosion:SFSObject = new SFSObject();
            var sfsPeopleKilled:SFSArray = new SFSArray();
            var gainedScore:int = 0;
            
            //var tracePeopleKilled:String = "[";

            for each(var killedPerson:Person in peopleKilled)
            {                
                if(killedPerson != personToScore)
                {
                    peopleKilledCount++;
                    pointsKilled += (int)(killedPerson.score.totalScorePoints);
                    
                    if(this.bombType == Bomb.DANGER_BOMB)
                    {
                        StatsManager.instance.onPlayerKilledWithDangerousBomb();
                    }
                }
                sfsPeopleKilled.addInt(killedPerson.userId);
                //tracePeopleKilled += killedPerson.user.name + "(" + killedPerson.user.id + "/" + killedPerson.userId + ") ";
            }
            //tracePeopleKilled += "]";
                        
            gainedScore += GameData.SCORE_PER_DEATH * peopleKilledCount;
            gainedScore += GameData.SCORE_PER_DEATH_POINT * pointsKilled;
            
            if(peopleKilledCount == 2)
            {
                gainedScore += GameData.SCORE_PER_COMBO_2;
            }
            else if(peopleKilledCount == 3)
            {
                gainedScore += GameData.SCORE_PER_COMBO_3;
            }
            else if(peopleKilledCount > 3)
            {
                gainedScore += GameData.SCORE_PER_COMBO_MORE_THAN_3;
            }

            bombExplosion.putSFSArray("peopleKilled",sfsPeopleKilled);
            bombExplosion.putLong("bid",bombId);
            bombExplosion.putUtfString("pid",""+personToScore.userId); //El que origina la explosion
            bombExplosion.putInt("score",gainedScore);
            /*
            if(ConfigController.gameTestingMode && peopleKilled.length > 0){
                SmartFoxClientSingleton.getInstance().smartFoxClient.sendPublicMessage("Killer: " + personToScore.user.name + "(" + personToScore.user.id + "). Killed: " + tracePeopleKilled);
            }
            */
            if(!SmartFoxClientSingleton.getInstance().smartFoxClient.myself.isSpectatorInRoom(SmartFoxClientSingleton.getInstance().smartFoxClient.gameRoom))
            {
                SmartFoxClientSingleton.getInstance().smartFoxClient.sendExtensionRequestToGameRoom(ServerMessages.BOMB_EXPLOSION, bombExplosion);
            }
            
            renderExplosions(corridorExplosions, normalExplosions, stopperExplosions, dangerousExplosions);
            
            if(_this != null)
            {
                _this.visible = false;
            }
            GameTools.unPushArr(GameData.instance.bombArr, this);
            explodeConfirmed = true;
            
            setCurrentPosition(position);
            
            this.removeMe();
            
            SoundClass.addMusic( "sound" + String( uint( Math.random() * 7 ) + 1 ), mySound );
            
            if(GameData.DEBUG_MODE)
            {
                trace("[com.gq.moveobject.Bomb]"+" Are there bombs in the map? " + GameData.instance.positionManager.bombsInMap);
            }
                        
        }
        
        private function renderExplosions(corridorExplosions:Array, normalExplosions:Array, stopperExplosions:Array, dangerousExplosions:Array):void
        {
            var chunk:ExplosionChunk;
            var hueColorMatrixFilter:HueColorMatrixFilter = new HueColorMatrixFilter();
            hueColorMatrixFilter.reset();
            hueColorMatrixFilter.Hue = 160;
            var leftChunksCount:uint = 0;
            var rightChunksCount:uint = 0;
            var upChunksCount:uint = 0;
            var downChunkCount:uint = 0;
            var bombs:Array = [];
            var directionCount:Array = [];
            var counters:Object;
            var explosionIndex:int = 0;
            for each (chunk in corridorExplosions) 
            {
                
                
                explosionIndex = bombs.indexOf(chunk.generatorBomb);
                
                if (explosionIndex == -1){
                    explosionIndex = bombs.length;
                    bombs.push(chunk.generatorBomb);
                    directionCount[explosionIndex] = {n:0, e:0, w:0, s:0};
                }
                
                 counters = directionCount[explosionIndex];
                
                var filter:ColorMatrixFilter;
                if(chunk.isPenetrating)
                {
                    filter = hueColorMatrixFilter.Filter;
                }
                else
                {
                    filter = null;
                }

                
                
                switch(chunk.direction)
                {
                    case PositionManager.SOUTH:
                        counters.s++;
                        if (counters.sOrigin == null || chunk.parentCell.y < (counters.sOrigin as ExplosionChunk).parentCell.y){
                            counters.sOrigin = chunk;                                
                        }
                        break;
                    case PositionManager.EAST:
                        counters.e++;
                        if (counters.eOrigin == null || chunk.parentCell.x < (counters.eOrigin as ExplosionChunk).parentCell.x){
                            counters.eOrigin = chunk;                                
                        }
                        break;
                    case PositionManager.WEST:
                        counters.w++;
                        if (counters.wOrigin == null || chunk.parentCell.x > (counters.wOrigin as ExplosionChunk).parentCell.x){
                            counters.wOrigin = chunk;                                
                        }
                        break;
                    case PositionManager.NORTH:
                        counters.n++;
                        if (counters.nOrigin == null || chunk.parentCell.y > (counters.nOrigin as ExplosionChunk).parentCell.y){
                            counters.nOrigin = chunk;            
                        }
                        break;
                    case PositionManager.NONE:
                        setSinglePic(chunk.parentCell, 0, "Effect_6", filter);
                        break;
                }
            }
            
            for each (chunk in stopperExplosions) 
            {
                
                explosionIndex = bombs.indexOf(chunk.generatorBomb);
                
                if (explosionIndex == -1){
                    explosionIndex = bombs.length;
                    bombs.push(chunk.generatorBomb);
                    directionCount[explosionIndex] = {n:0, e:0, w:0, s:0};
                }
            
                counters = directionCount[explosionIndex];
                
                if(chunk.isPenetrating)
                {
                    filter = hueColorMatrixFilter.Filter;
                }
                else
                {
                    filter = null;
                }
                switch(chunk.direction)
                {
                    case PositionManager.SOUTH:
                        counters.s++;
                        if (counters.sOrigin == null || chunk.parentCell.y < (counters.sOrigin as ExplosionChunk).parentCell.y){
                            counters.sOrigin = chunk;                                
                        }
                        break;
                    case PositionManager.EAST:
                        counters.e++;
                        if (counters.eOrigin == null || chunk.parentCell.x < (counters.eOrigin as ExplosionChunk).parentCell.x){
                            counters.eOrigin = chunk;                                
                        }
                        break;
                    case PositionManager.WEST:
                        counters.w++;
                        if (counters.wOrigin == null || chunk.parentCell.x > (counters.wOrigin as ExplosionChunk).parentCell.x){
                            counters.wOrigin = chunk;                                
                        }
                        break;
                    case PositionManager.NORTH:
                        counters.n++;
                        if (counters.nOrigin == null || chunk.parentCell.y > (counters.nOrigin as ExplosionChunk).parentCell.y){
                            counters.nOrigin = chunk;                                
                        }
                        break;
                    case PositionManager.NONE:
                        setSinglePic(chunk.parentCell, 0, "Effect_6", filter);
                        break;
                }
            }
            
            for each(var explosion:Object in directionCount){
                
                
                if (explosion.n > 0){
                    
                    if((explosion.nOrigin as ExplosionChunk).isPenetrating)
                    {
                        filter = hueColorMatrixFilter.Filter;
                    }
                    else
                    {
                        filter = null;
                    }
                    
                    setSinglePic((explosion.nOrigin as ExplosionChunk).parentCell, -90, "EffectBasic_" + explosion.n, filter, 2, 39);
                    
                }
                if (explosion.s > 0){
                    
                    if((explosion.sOrigin as ExplosionChunk).isPenetrating)
                    {
                        filter = hueColorMatrixFilter.Filter;
                    }
                    else
                    {
                        filter = null;
                    }
                    
                    setSinglePic((explosion.sOrigin as ExplosionChunk).parentCell, 90, "EffectBasic_" + explosion.s, filter, 34, 0);
                }
                if (explosion.w > 0){
                    
                    if((explosion.wOrigin as ExplosionChunk).isPenetrating)
                    {
                        filter = hueColorMatrixFilter.Filter;
                    }
                    else
                    {
                        filter = null;
                    }
                    
                    setSinglePic((explosion.wOrigin as ExplosionChunk).parentCell, 180, "EffectBasic_" + explosion.w, filter, 37, 26);
                }
                if (explosion.e > 0){
                    
                    if((explosion.eOrigin as ExplosionChunk).isPenetrating)
                    {
                        filter = hueColorMatrixFilter.Filter;
                    }
                    else
                    {
                        filter = null;
                    }
                    
                    setSinglePic((explosion.eOrigin as ExplosionChunk).parentCell, -0, "EffectBasic_" + explosion.e, filter, 0, -6);
                }                
            }
            
            
            for each (chunk in normalExplosions) 
            {
                if(chunk.isPenetrating)
                {
                    filter = hueColorMatrixFilter.Filter;
                }
                else
                {
                    filter = null;
                }
                
                if(chunk.originatedByDangerous){
                    setSinglePic(chunk.parentCell, 0, "Effect_6", filter, 4, -4);    
                }else{
                    setSinglePic(chunk.parentCell, 0, "Effect_1", filter, 4, -4);
                }                        
            }

            for each (chunk in dangerousExplosions) 
            {
                setSinglePic(chunk.parentCell, 0, "Effect_12");    
            }            
        
        }
        
        //FUTURE: refactor to re-use confirmExplosion
        public function silentExplosion():void {
            removeMeFromMap();
            if(GameData.DEBUG_MODE)
            {
                trace("[com.gq.moveobject.Bomb] "+ bombId + ": Silent explosion.");
            }
            
            fire = true;
            if( myMaster && data_index != 4 )
            {
                (myMaster as Person)._bombsOnFieldArray.splice((myMaster as Person)._bombsOnFieldArray.indexOf(this),1);
            }

            if(_this != null)
            {
                _this.visible = false;
            }
            GameTools.unPushArr(GameData.instance.bombArr, this);
            explodeConfirmed = true;
        }

        private function setSinglePic(cell:ExplodingCell, angel:Number, effect1:String, filter:ColorMatrixFilter = null, xOffset:int = 0, yOffset:int = 0):void
        {
            var tempX:int;
            var tempY:int;
            tempX = cell.x * GameData.instance.rectWidth;
            tempY = cell.y * GameData.instance.rectHeight + GameData.instance.upLine;
            GameSys.addEffects(GameData.instance.topObjectContainer, "ExploreEffect", effect1, tempX, tempY, 0, 1, angel, filter, xOffset, yOffset).myMaster = myMaster;            
        }

        private function setPic( areaArr:Array, angel:Number, effect1:String ):void
        {
            var tempX:Number;
            var tempY:Number;
            for( var i:uint = 0; i < areaArr.length; i++ )
            {
                tempX = areaArr[i].x * GameData.instance.rectWidth;
                tempY = areaArr[i].y * GameData.instance.rectHeight + GameData.instance.upLine;

                GameSys.addEffects( GameData.instance.topObjectContainer, "ExploreEffect", effect1, tempX, tempY, 0, 1, angel ).myMaster = myMaster;
            }
        }
        
        private function setDangerPic(areaArr:Array, angel:Number):void
        {
            var tempX:Number;
            var tempY:Number;
            
            if (areaArr.length == 25){
            
            for( var i:uint = 0; i < areaArr.length; i++ )
            {
                tempX = areaArr[i].x * GameData.instance.rectWidth;
                tempY = areaArr[i].y * GameData.instance.rectHeight + GameData.instance.upLine;

                GameSys.addEffects(GameData.instance.topObjectContainer, "ExploreEffect", "Effect_6", tempX, tempY, 0, 1, angel ).myMaster = myMaster;
            }
            
            } 
        }

        public function initial(proposedArea:uint):void
        {
            if( myMaster )
            {
                if( data_index == 3 )
                {
                    _area = 16;
                }
                else if( data_index == 4 )
                {
                    _area = 0;
                    isMine = true;
                    GameData.instance.mapArr[myCurrentPositionX][myCurrentPositionY] = -1;
                }
                else
                {
                    _area = proposedArea;
                }
            }
            else
            {
                area = proposedArea;
                markPosition();
            }

            tellFlee();
            GameData.instance.mapObject[String(myCurrentPositionX) + "_" + String(myCurrentPositionY)] = this;
        }

        /**
         * Marks explosive areas.
         */
        private function markPosition():void
        {
            markArr = [];
            markArr.push(GameData.instance.creater.createObj("person", "Mark", "Mark_3", (myCurrentPositionX + 0.5) * GameData.instance.rectWidth, (myCurrentPositionY + 0.5) * GameData.instance.rectHeight + GameData.instance.upLine , 0, []));
            var explosionArea:Array = getLinealExplosionArea();
            for each(var tilePosition:Point in explosionArea)
            {
                markArr.push( GameData.instance.creater.createObj("person", "Mark", "Mark_1", (tilePosition.x + 0.5) * GameData.instance.rectWidth, (tilePosition.y + 0.5) * GameData.instance.rectHeight + GameData.instance.upLine , 0, []));
            }
        }

        private function tellFlee():void
        {
            for( var i:uint = 0; i < GameData.instance.playerArr.length; i++)
            {
                var target:Person = GameData.instance.playerArr[i];
                if( GameTools.getDistance( target.myX, target.myY, myX, myY ) < 150 )
                {
                    target.readyToFlee = true;
                    target.flee = false;
                    GameTools.pushArr( target.myBombArr, this );
                }
            }
        }

        override public function removeMe():void
        {
            super.removeMe();
            GameData.instance.mapObject[myCurrentPositionX + "_" + myCurrentPositionY] = null;
            
            removeMeFromMap();

            for each(var markObject:MoveObject in markArr)
            {
                markObject.removeMe();
            }
        }

        override public function controlMc ():void
        {
            if ( _this != null )
            {
                _this.x = myX;
                _this.y = myY + myZ;
                _this.scaleX = myDir;
            }
        }

        override public function isCompatible(objectType:uint, myTile:Point,objectTile:Point):Boolean
        {
            //TODO: use game mode
            if(PERSON == objectType && bombType == BOUNCING_BOMB)
            {
                return true;
            }
            if(!isMine && (PERSON == objectType || BOMB == objectType))
            {
                return false;
            } else {
                return true;
            }
        }
        
        //TODO: fix x or y when displaced from current cell coordinate (when kick comes before walk finished)
        private function walkToTarget():void
        {
            if(targetPoints.length < 1)
            {
                return;
            } else
            {
                while(targetPoints.length > 1)
                {
                    var currentPoint:Point = targetPoints.shift();
                    myX = (currentPoint.x + 0.5) * GameData.instance.rectWidth;
                    myY = (currentPoint.y + 0.5) * GameData.instance.rectWidth + GameData.instance.upLine;
                }
            }

            var tileTargetPoint:Point = targetPoints[0];
            var targetPoint:Point = new Point((tileTargetPoint.x + 0.5) * GameData.instance.rectWidth,(tileTargetPoint.y + 0.5)*GameData.instance.rectWidth+ GameData.instance.upLine);

            switch(movingDirection)
            {
                case PositionManager.WEST:
                {
                    myX -= STEP_SIZE_X;
                    myY = targetPoint.y;
                    if(myX <= targetPoint.x){
                        myX = targetPoint.x;
                        targetPoints.shift();
                    }
                    break;
                }
                case PositionManager.EAST:
                {
                    myX += STEP_SIZE_X;
                    myY = targetPoint.y;
                    if(myX >= targetPoint.x){
                        myX = targetPoint.x;
                        targetPoints.shift();
                    }
                    break;
                }
                case PositionManager.NORTH:
                {
                    myY -= STEP_SIZE_Y;
                    myX = targetPoint.x;
                    if(myY <= targetPoint.y){
                        myY = targetPoint.y;
                        targetPoints.shift();
                    }
                    break;
                }
                case PositionManager.SOUTH:
                {
                    myY += STEP_SIZE_Y;
                    myX = targetPoint.x;
                    if(myY >= targetPoint.y){
                        myY = targetPoint.y;
                        targetPoints.shift();
                    }
                    break;
                }
                case PositionManager.NONE:
                {
                    myX = targetPoint.x;
                    myY = targetPoint.y;
                }
                default:
                {
                    break;
                }
            }
           
            if(targetPoints.length < 1)
            {
                if(_this.parent != null)
                {
                    _this.parent.removeChild(_this);
                }
                getMyPosition();
                GameData.instance["Container_" + String(myCurrentPositionY)].addChild( _this);
                
                if(GameData.DEBUG_MODE) 
                {
                    trace("[com.gq.moveobject.Bomb] "+ bombId + ": bomb walking reached target <" + myX + ", " + myY + ">");
                }
                
            }
            else if(GameData.DEBUG_MODE)
            {
                trace("[com.gq.moveobject.Bomb] "+ bombId + ": bomb walking not yet in target <" + myX + ", " + myY + ">");
            }
           
            controlMc();
        }

        public function setCurrentPosition(position:Point):void
        {
            myCurrentPositionX = position.x;
            myCurrentPositionY = position.y;
        }
        
        public function reEnableLastMovement():void
        {
            canceledMovements[lastMovementId] = false;
        }
        
        public function cancelMovement(movementId:uint):void
        {
            canceledMovements[movementId] = true;
        }

        public function isMovementEnabled(movementId:uint):Boolean
        {
            if(canceledMovements[movementId] != null)
            {
                return false;
            }
            else
            {
                return !canceledMovements[movementId];
            }
        }

        public function get currentPositionxy():Point {
            return new Point(myCurrentPositionX, myCurrentPositionY);
        }

        override public function get stopsExplosionCategory():uint
        {
            if(isMine)
            {
                return DONT_STOP_EXPLOSION;
            } else
            {
                return STOPS_EXPLOSION;
            }
        }

        public function get tilePoint():Point
        {
            return _tilePoint;
        }

        public function set tilePoint(tilePoint:Point):void
        {
            _tilePoint = tilePoint;
            myCurrentPositionX = _tilePoint.x;
            myCurrentPositionY = _tilePoint.y;
        }

        public function get currentMovementId():uint {
            return bombId * 10000 + movementSequence;
        }
        
        public function updateMovementSequenceWithId(movementId:Number):void {
            lastMovementId = movementId;
            movementSequence = movementId - bombId * 10000;
        }

        public function get area():uint
        {
            return _area;
        }

        public function set area(newArea:uint):void
        {
            _area = newArea;
        }
    }
}