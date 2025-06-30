﻿package com.gq.moveobject
{
    import com.gq.effects.ArrayEffect;
    import com.gq.system.*;
    import com.greensock.TweenMax;
    import com.greensock.events.LoaderEvent;
    import com.smartfoxserver.v2.entities.User;
    import com.smartfoxserver.v2.entities.data.ISFSArray;
    import com.smartfoxserver.v2.entities.data.SFSArray;
    import com.smartfoxserver.v2.entities.data.SFSObject;
    import com.willdom.games.bomberman.communication.GameMessage;
    import com.willdom.games.bomberman.communication.SmartFoxClientSingleton;
    import com.willdom.games.bomberman.consts.ServerMessages;
    import com.willdom.games.bomberman.consts.SkullTypes;
    import com.willdom.games.bomberman.events.PersonEvent;
    import com.willdom.games.bomberman.events.PlayerEvent;
    import com.willdom.games.bomberman.gameobjects.GameInterfaceManager;
    import com.willdom.games.bomberman.gameobjects.PersonScore;
    import com.willdom.games.bomberman.gameobjects.Score;
    import com.willdom.games.bomberman.gameobjects.bombs.BombManager;
    import com.willdom.games.bomberman.position.PositionManager;
    import com.willdom.games.bomberman.statemachine.StatusManager;
    import com.willdom.games.explodersmmo.shared.model.CustomLogger;
    import com.willdom.util.helpers.EventListenerManager;
    import com.willdom.util.math.Random;
    
    import configuration.GameModes;
    import configuration.StageModes;
    
    import de.polygonal.core.util.Instance;
    
    import flash.display.Bitmap;
    import flash.display.DisplayObject;
    import flash.display.Loader;
    import flash.display.MovieClip;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.TimerEvent;
    import flash.filters.GlowFilter;
    import flash.geom.ColorTransform;
    import flash.geom.Point;
    import flash.net.URLRequest;
    import flash.net.getClassByAlias;
    import flash.system.System;
    import flash.utils.Timer;
        
    public class Person extends MoveObject
    {
        public static var allPersons:Array = new Array();
        private static const LATENCY_LIMIT:uint = 6000;
        private static const SWITCH_TIME:uint = 550;
        
        protected var slopeNum:Number = 1;
        public var myFace:String = "down";
        public var currentFaceMc:MovieClip;
        public var AIMode:String = "";
        public var upPress:Boolean;
        public var downPress:Boolean;
        public var leftPress:Boolean; 
        public var rightPress:Boolean;
        public var spacePress:Boolean;
        public var shiftPress:Boolean;
        private var spaceDone:Boolean;
        public var shiftDone:Boolean;
        public var controlPress:Boolean;
        public var controlDone:Boolean;
        private var confusion:Boolean = false;
        private var reckless:Boolean = false;
        private var dizzy:Boolean = false;
        private var diarrhoea:Boolean = false;
        private var shortFuse:Boolean = false;
        private var longFuse:Boolean = false;
        private var bombState:Boolean=false;
        private var lastDirection:int = PositionManager.NONE;
        private var bombSkin:MovieClip; 
        public var qPress:Boolean;
        protected var upRect:uint;
        protected var downRect:uint;
        protected var leftRect:uint;
        protected var rightRect:uint;
        public var needReajust:Boolean = true;
        public var doWhat:String;
        public var readyToFlee:Boolean;
        public var myBombArr:Array = new Array();
        public var shield:Boolean;
        public var shieldTime:uint;
        private var _maxBombsAllowed:int;
        public var _bombsOnFieldArray:Array = new Array();
        private var _power:uint;
        private var array:ArrayEffect;
        public var myBurnPositionX:Number;
        public var myBurnPositionY:Number;
        private var depthCount:uint;
        protected var myRectY:Number;
        protected var myRectX:Number;
        public var myScore:uint;
        public var score:PersonScore;
        private var _currentName:String;
        public var trophieList:Object;
        public var winner:String;
        private var skullBuffs:SkullBuffs;
        public var myBombCount:uint;
        private var prevBomb:String = "";
        private var myBomb:String = "1";
        public var str:String = "";
        private var kill:Boolean;
        private var walkStr:String = "";
        public var myKiller:Person;
        public var isPlacingBomb:Boolean=false;
        public var myId:String;
        public var myName:String = "";
        public var myAvatar:uint = 0;
        private var sendCount:uint = uint( Math.random() * 20 + 10 );
        public var user:User;
        public var userId:int;
        public var latency:Number = 0;
        public var rematchAccepted:Boolean = true;
        private var serialId:uint;
        private var switchPositionTimer:Timer = new Timer(SWITCH_TIME, 3);
        private var latencyCheck:Timer = new Timer(LATENCY_LIMIT, 1);
        public var confirmedPosition:Point;
        public var waitingForStartConfirmation:Boolean;
        public var waitingForArriveConfirmation:Boolean;
        public var engagedByMine:Boolean;       //True if a mine traps the person into its tile.
        public var engagingMine:Bomb;           //The mine that person stepped on.
        private var bombSkinItemGot:Boolean;
        private var random:Random;
        public var dialogOver:MC_PlayerNameTooltip;
        public var hasTimedOut:Boolean = false;
        public var playerAvatar:DisplayObject;
        public var myColorTransform:ColorTransform;
        public var variation:ColorTransform;
        public var myGlowFilter:GlowFilter;
        private var impossibleToSwitch:Boolean;
        private var randomPersonToSwitch:Person;
        private var randomPersonId:int;
        public var outline:PersonOutlineComponent;
        public var isTweening:Boolean = false;
        public var colorCycle:Number = 0;
        private var dizzyAnim:DizzyEffect;
        public var speed:Number;
        
        public function Person():void
        {
            objectType = PERSON;
            serialId = 0;
            trophieList = new Object();
            skullBuffs = new SkullBuffs();
            waitingForStartConfirmation = false;
            waitingForArriveConfirmation = false;
            dialogOver = new MC_PlayerNameTooltip();
            allPersons.push(this);
            score = new PersonScore(this);
            GameData.instance.scores.push(score);
            myColorTransform = new ColorTransform();
            variation = new ColorTransform();
            myGlowFilter = new GlowFilter();
        }
        
        override protected function initMyData ():void
        {
            if(GameData.DEBUG_MODE)
            {
                trace("[com.gq.moveobject.Person]"+""+myId+": "+"initMyData");
            }
            _this.down.visible = false;
            _this.up.visible = false;
            _this.right.visible = false;
            waitingForStartConfirmation = false;
            bombSkinItemGot = false;
            
            outline = new PersonOutlineComponent(_this);
            
            var infoScreen:MovieClip = (GameData.instance.infoWindow.getChildAt(0) as MovieClip);
            var layerOrder:int = infoScreen.getChildIndex(infoScreen["spectateBox"]) - 2;
            GameData.instance.Scen.addChildAt(dialogOver, GameData.instance.Scen.getChildIndex(GameData.instance.infoWindow)-2);
            dialogOver.y = -dialogOver.height - 50;
            dialogOver.visible = false;
            
            showDir( "walk" + walkStr );
            scale = currentFaceMc.scaleX;
            
            initProperty();
            
            super.initMyData();
            _stopsExplosionCategory = DONT_STOP_EXPLOSION;
            GameTools.pushArr( GameData.instance.playerArr, this );
            GameData.instance.alivePlayers = GameData.instance.playerNames.length;
            if(GameData.DEBUG_MODE)
            {
                trace("[com.gq.moveobject.Person]"+'Alive players initialized: ' + GameData.instance.alivePlayers);
            }
            
            random = new Random(GameData.instance.gameSeed);
            EventListenerManager.setListenerTo(switchPositionTimer,TimerEvent.TIMER,onSwitchPositionTimer);
            
            myBurnPositionX = myX;
            myBurnPositionY = myY;
            
            alphaIndex = 50;
            objectType = PERSON;
            
            if(GameData.DEBUG_MODE && GameData.INVINCIBILITY_FOR_DEBUG_MODE) {
                invincible = true;
            }
            
            dizzyAnim = new DizzyEffect();
            dizzyAnim.stop();
        }
        
        protected function initProperty():void
        {
            if(GameData.DEBUG_MODE) {
                trace("[com.gq.moveobject.Person]"+""+myId+": "+"initProperty");
            }
            
            skullBuffs.resetBuffs();
            speedAll = 7;
            speed = 7;
            power = 1;
            maxBombsAllowed = 1;
            myBomb = Bomb.NORMAL_BOMB;
            isPlacingBomb = false;
            
            if( GameData.instance.STAGE_MODE == StageModes.HYPER )
            {
                speedAll = 14;
            }
        }
        
        public function showDir( which:String ):void
        {
            if( currentFaceMc )
            {
                currentFaceMc.visible = false;
            }
            currentFaceMc = _this[myFace];
            currentFaceMc.visible = true;
            changeStates( which );
        }
        
        override public function changeStates ( which:String, force:Boolean = true ):void
        {
            states = which;
            changeFrameAction ( currentFaceMc, which );
        }
        
        private function controlCount():void
        {
            if( alphaIndex > 0 && !bombState)
            {
                alphaIndex--;
                _this["right"].alpha = alphaIndex % 2;
                _this["up"].alpha = alphaIndex % 2;
                _this["down"].alpha = alphaIndex % 2;
                if( alphaIndex == 0 )
                {
                    _this["right"].alpha = 1;
                    _this["up"].alpha = 1;
                    _this["down"].alpha = 1;
                }
            }
        }
        
        public function respawn(spawnPoint:Point):void
        {
            CustomLogger.getInstance().log("[com.gq.moveobject.Person]"+""+myId+": "+"respawn at " + spawnPoint.toString());
            _this.visible=true;
            objectType = PERSON; 
            _bombsOnFieldArray = new Array();
            maxBombsAllowed = 1;
            engagedByMine = false;
            waitingForArriveConfirmation = false;
            bombSkinItemGot = false;
            engagingMine = null;
            if(fire)
            {
                if(GameData.DEBUG_MODE)
                {
                    trace("[com.gq.moveobject.Person]"+""+myId+": "+this.myId + ' was fired');
                }
                fire = false;
                restart(spawnPoint);
            }
            else
            {
                restart(spawnPoint);
            }
        }
        
        override public function updataEvent():void
        {
            if(GameSys.paused) {
                return;
            }
            controlCount();
            
            if( can_action && SmartFoxClientSingleton.getInstance().smartFoxClient.gameRoom.getUserByName(myName) != null && !(SmartFoxClientSingleton.getInstance().smartFoxClient.gameRoom.getUserByName(myName) as User).isSpectatorInRoom(SmartFoxClientSingleton.getInstance().smartFoxClient.gameRoom))
            {
                controlMe();
            }
            switchStates();
            restoreState();
            controlMc();
            
            if( deleteMe )
            {
                GameTools.pushArr( GameData.instance.removeArr, this );
            }
        }
        
        override protected function dead_over():void
        {
            if(GameData.DEBUG_MODE)
            {
                trace("[com.gq.moveobject.Person]"+""+myId+": "+"dead over");
            }
            deleteMe = true;
        }
        
        protected function hitTestMap():void
        {
            if( walkStr == "_f" )
            {
                judgeFace();
            }
        }
        
        private function judgeFace():void
        {
            if( myCurrentPositionX == 0 )
            {
                myDir = 1;
                checkFace( "right" );
                myRectY = myCurrentPositionY * GameData.instance.rectHeight + GameData.instance.upLine;
                myX = GameData.instance.rectWidth / 2;
            }
            else if( myCurrentPositionX == GameData.instance.widthNum - 1 )
            {
                myDir = -1;
                checkFace( "right" );
                myX = (GameData.instance.widthNum - 0.5) * GameData.instance.rectWidth;
                myRectY = myCurrentPositionY * GameData.instance.rectHeight + GameData.instance.upLine;
            }
            else
            {
                if( myCurrentPositionY == 0 )
                {
                    checkFace( "down" );
                    myRectX = myCurrentPositionX * GameData.instance.rectWidth;
                    myY = GameData.instance.rectHeight / 2;
                }
                else if( myCurrentPositionY == GameData.instance.heightNum - 1 )
                {
                    checkFace( "up" );
                    myRectX = myCurrentPositionX * GameData.instance.rectWidth;
                    myY = (GameData.instance.heightNum - 0.5) * GameData.instance.rectHeight;
                }
            }
        }
        
        override protected function changeData():void
        {
            judgeLimit();
            hitTestMap();
            
            if( myCurrentPositionX < 0 )
            {
                myCurrentPositionX ++;
            }
            else if( myCurrentPositionX >= GameData.instance.widthNum )
            {
                myCurrentPositionX --;
            }
            if( myCurrentPositionY < 0 )
            {
                myCurrentPositionY ++;
            }
            else if( myCurrentPositionY >= GameData.instance.heightNum )
            {
                myCurrentPositionY --;
            }
            if( speedX != 0 && speedY != 0 )
            {
                slopeNum = 0.7;
            }
            else
            {
                slopeNum = 1;
            }
            if( speedX != 0 )
            {
                if( blockedX && walkStr != "_f" )
                {
                    myX = myRectX + 0.5 * GameData.instance.rectWidth 
                }
                else
                {
                    myX += speedX * slopeNum;
                }
                judgeRectX();
            }
            if( speedY != 0 )
            {
                if( blockedY && walkStr != "_f" )
                {
                    myY = myRectY + 0.5 * GameData.instance.rectHeight 
                }
                else
                {
                    myY += speedY * slopeNum;
                }
                judgeRectY();
            }
        }
        
        protected function judgeRectX():Boolean
        {
            var positionX:uint = uint( myX / GameData.instance.rectWidth );
            if( myCurrentPositionX != positionX )
            {
                myCurrentPositionX = positionX;
                needReajust = true;
                return true;
            }
            else 
            {
                return false;
            }
        }
        
        protected function judgeRectY():Boolean
        {
            var positionY:uint =  uint( (myY - GameData.instance.upLine) / GameData.instance.rectHeight );
            if( myCurrentPositionY != positionY )
            {
                myCurrentPositionY = positionY;
                if(GameData.DEBUG_MODE)
                {
                    trace("ADJUSTING PERSON");
                }
                GameData.instance["Container_" + String(myCurrentPositionY)].addChild (_this);
                needReajust = true;
                return true;
            }
            else
            {
                return false;
            }
        }
        
        private function checkDiarrhoea():void{
            if( diarrhoea && bombsOnField >= maxBombsAllowed )
            {
                var array:Array = GameData.instance.diseaseManager.getDiseasesByPerson(this);
                
                for each(var disease:Disease in array)
                {
                    if(disease.type == SkullTypes.DIARRHOEA)
                    {
                        GameData.instance.diseaseManager.removeDisease(disease);
                    }
                    
                }
            }
        }
        
        override protected function controlMe():void
        {
            var control:WalkControlSet = GameData.instance.walkControls[int(myId)];
            if(control == null)
            {
                return;
            }
            if (this == Person.getPersonByName(GameData.instance.myName))
            {
                _this.dispatchEvent(new PlayerEvent(PlayerEvent.PLAYER_COMMAND));
            }
            if(confirmedPosition !=null && control is LocalWalkControlSet 
                && GameData.instance.walkControls[GameData.instance.myId].hasReachedTarget
                && (control as LocalWalkControlSet).targetConfirmed)
            {
                GameData.instance.controls.checkChangeOfDirection(confirmedPosition, objectType);
            }
            
            checkDiarrhoea();
            
            var nextPosition:Point;
            
            if(control.local && !GameSys.onReadyScreen)
            {
                if (rightPress || leftPress || upPress || downPress || spacePress)
                {
                    GameData.instance.topSprite.dispatchEvent(new PlayerEvent(PlayerEvent.PLAYER_COMMAND));
                }
                if( !dizzy && (leftPress || (reckless && lastDirection == PositionManager.WEST &&
                                  !rightPress && !upPress && !downPress)) )
                {
                    if( reckless )
                    {
                        lastDirection = PositionManager.WEST;
                    }
                    if(confusion)
                    {
                        checkFace("right");
                        _this.scaleX = 1;
                        nextPosition = control.getNextPosition(PositionManager.EAST);
                    }
                    else
                    {
                        nextPosition = control.getNextPosition(PositionManager.WEST);
                        checkFace("right");
                        _this.scaleX = -1;
                    }
                }
                else if( !dizzy && (rightPress || (reckless && lastDirection == PositionManager.EAST &&
                                        !upPress && !leftPress && !downPress)) )
                {
                    if(reckless)
                    {
                        lastDirection = PositionManager.EAST;
                    }
                    if(confusion)
                    {
                        nextPosition = control.getNextPosition(PositionManager.WEST);
                        checkFace("right");
                        _this.scaleX = -1;
                    }
                    else
                    {
                        checkFace("right");
                        _this.scaleX = 1;
                        nextPosition = control.getNextPosition(PositionManager.EAST);
                    }
                }
                
                else if( !dizzy && (upPress || (reckless && lastDirection == PositionManager.NORTH &&
                                    !rightPress && !leftPress && !downPress)) )
                {
                    if(reckless)
                    {
                        lastDirection = PositionManager.NORTH;
                    }
                    
                    if(confusion)
                    {
                        checkFace("down");
                        nextPosition = control.getNextPosition(PositionManager.SOUTH);
                    }
                    else
                    {
                        checkFace("up");
                        nextPosition = control.getNextPosition(PositionManager.NORTH);
                    }
                    
                }
                else if( !dizzy && (downPress || (reckless && lastDirection == PositionManager.SOUTH && !upPress && !leftPress && !rightPress)) )
                {
                    if(reckless)
                    {
                        lastDirection = PositionManager.SOUTH;
                    }
                    
                    if(confusion)
                    {
                        checkFace("up");
                        nextPosition = control.getNextPosition(PositionManager.NORTH);
                    }
                    else
                    {
                        checkFace("down");
                        nextPosition = control.getNextPosition(PositionManager.SOUTH);
                    }
                }
                else
                {
                    showDir("stand");
                    nextPosition = control.getNextPosition(PositionManager.NONE);
                }
            } 
            else 
            {
                nextPosition = control.getNextPosition(PositionManager.NONE);
                if(control.status == "walking")
                {
                    if(control.direction == "left")
                    {
                        checkFace("right");
                        _this.scaleX = -1;
                    } 
                    else 
                    {
                        _this.scaleX = 1;
                        checkFace(control.direction);
                    }
                } 
                else 
                {
                    showDir("stand");
                }
            }
            
            if( !GameSys.onReadyScreen && (spacePress || diarrhoea ) && control.local && !dizzy )
            {
                if( !spaceDone )
                {
                    spaceDone = true;
                    setBomb();
                }
                else if(diarrhoea)
                {
                    spaceDone = false;
                }
            }
            else
            {
                spaceDone = false;
            }
            
            myX = nextPosition.x;
            myY = nextPosition.y;
            judgeRectY();
            
            if( (GameData.instance.walkControls[GameData.instance.myId] is LocalWalkControlSet) && GameData.instance.walkControls[GameData.instance.myId].hasReachedTarget )
            {
                //Bomb skin
                if(bombSkinItemGot && shiftPress && !shiftDone )
                {
                    shiftDone = true;
                    
                    var sfsObject:SFSObject = new SFSObject();
                    sfsObject.putUtfString("myId", myId);
                    sfsObject.putBool("state", !bombState);
                    sfsObject.putInt(ServerMessages.ROUND_NUMBER,GameData.instance.currentRound);
                    
                    SmartFoxClientSingleton.getInstance().smartFoxClient.sendExtensionRequestToGameRoom(ServerMessages.BOMB_SKIN, sfsObject);
                    
                }
            }
        }
        
        public function setBombSkin(activate:Boolean):void
        {
            var mode:String = "";
            if(GameData.instance.STAGE_MODE == StageModes.PENGUIN){
                mode = "Penguin";
            }
                        
            if(activate){
               
                if(bombSkin == null){
                    var tempClass:Class = GameTools.getMeBySwf( "objects" , "Bomb" + mode + "_1");
                    bombSkin = new tempClass();
                }
                _this.up.alpha = 0;
                _this.down.alpha = 0;
                _this.right.alpha = 0;
                bombSkin.x = _this.x;
                bombSkin.y = _this.y;
                _this.parent.addChild(bombSkin);
                outline.bombStateOn(bombSkin as Bomb_1);
                bombState = true;  
            }else{
                _this.up.alpha = 1;
                _this.down.alpha = 1;
                _this.right.alpha = 1;
                _this.parent.removeChild(bombSkin);
                outline.bombStateOff();
                bombState = false;  
            }
        }
        
        protected function walkLeftRight( _dir:int ):void
        {
            speedY = 0
            if( walkStr != "_f" )
            {
                myDir = _dir;
                checkFace( "right" );
                speedX = speedAll * _dir;
            }
            else
            {
                if( myCurrentPositionY == 0 || myCurrentPositionY == GameData.instance.heightNum - 1 )
                {
                    speedX = speedAll * _dir;
                }
            }
        }

        protected function walkUp():void
        {
            if( walkStr != "_f" )
            {
                if( !leftPress && !rightPress )
                    checkFace( "up" );
                speedY = -speedAll;
            }
            else
            {
                if( myCurrentPositionX == 0 || myCurrentPositionX == GameData.instance.widthNum - 1 )
                {
                    speedY = -speedAll;
                }
            }
        }
        protected function walkDown():void
        {
            if( walkStr != "_f" )
            {
                if( !leftPress && !rightPress )
                    checkFace( "down" );
                speedY = speedAll;
            }
            else
            {
                if( myCurrentPositionX == 0 || myCurrentPositionX == GameData.instance.widthNum - 1 )
                {
                    speedY = speedAll;
                }
            }
        }
        
        public function setSpriteFaceDown():void{
            
            checkFace("down");
            
        }
        
        private function checkFace( _face:String ):void
        {
            if( myFace != _face || states != "walk" + walkStr )
            {
                myFace = _face;
                showDir( "walk" + walkStr );
            }
        }
        
        protected function setBomb():void
        {
            if(GameData.DEBUG_MODE)
            {
                trace("[com.gq.moveobject.Person] Attempting to set bomb");
            }
            if(!isPlacingBomb && bombsOnField < maxBombsAllowed && !GameData.instance.endingState)
            {
                
                getMyPosition();
                var tempX:uint;
                var tempY:uint;
                
                if(diarrhoea){
                    tempX = confirmedPosition.x;
                    tempY = confirmedPosition.y;
                }else{
                    tempX = myCurrentPositionX;
                    tempY = myCurrentPositionY;
                }
                
                if((GameData.instance.positionManager.bombsInTile(new Point(tempX,tempY)).length <= 0 && GameData.instance.GAME_MODE != GameModes.AIR) || walkStr == "_f" )
                {
                    isPlacingBomb = true;
                    var newBombId:uint = bombId;
                    if(GameData.DEBUG_MODE){
                        trace("[com.gq.moveobject.Person] Bomb set " + newBombId + " on field = " + bombsOnField + "; person current pos: <" + myCurrentPositionX + ", " + myCurrentPositionY + ">");
                    }
                    var sfsObject:SFSObject = new SFSObject();
                    sfsObject.putLong("bombId", newBombId);
                    sfsObject.putInt("seq", 0);
                    var bombToSet:String = "";
                    if(myBomb == Bomb.MINE)
                    {
                        bombToSet = myBomb;
                        myBomb = Bomb.NORMAL_BOMB;
                        if(GameData.DEBUG_MODE)
                        {
                            trace("[com.gq.moveobject.Person]"+"mine set, restore bomb num");
                        }                    
                    }
                    else if (myBomb == Bomb.DANGER_BOMB || myBomb == Bomb.POWER_BOMB)
                    {
                        for (var i:int = 0; i < _bombsOnFieldArray.length; i++) 
                        {
                            if((_bombsOnFieldArray[i] as Bomb).bombType == Bomb.DANGER_BOMB || (_bombsOnFieldArray[i] as Bomb).bombType == Bomb.POWER_BOMB)
                            {
                                bombToSet = Bomb.NORMAL_BOMB;
                                break;
                            }
                        }
                        if(bombToSet == "")
                        {
                            bombToSet = myBomb;
                        }
                    }
                    else
                    {
                        bombToSet = myBomb;
                    }
                    sfsObject.putUtfString("_b", bombToSet);
                    sfsObject.putUtfString("_m", myId);
                    sfsObject.putLong("_x", tempX);
                    sfsObject.putLong("_y", tempY);
                    sfsObject.putUtfString("_w", walkStr);
                    sfsObject.putInt(ServerMessages.ROUND_NUMBER,GameData.instance.currentRound);
                    
                    if(shortFuse && longFuse){
                        sfsObject.putInt("fut",6);
                    }else if(shortFuse){
                        sfsObject.putInt("fut",3);
                    }else if(longFuse){
                        sfsObject.putInt("fut",9);
                    }
                    
                    if(skullBuffs.isActive)
                    {
                        if(skullBuffs.type == SkullTypes.LOW_POWER)
                        {
                            sfsObject.putInt("area", 1);
                        }
                        else
                        {
                            sfsObject.putInt("area", skullBuffs.power);
                        }
                    }
                    else
                    {
                        sfsObject.putInt("area", power);
                    }
                    SmartFoxClientSingleton.getInstance().smartFoxClient.sendExtensionRequestToGameRoom(BombManager.SET_BOMB, sfsObject);
                }
            }
        }
        
        override public function controlMc ():void
        {
            if ( _this != null )
            {
                _this.x = myX - 20;
                _this.y = myY + myZ -  50;
                if(bombState && bombSkin != null && bombSkin.parent != null)
                {
                    if(_this.y != bombSkin.y)
                    {
                        bombSkin.parent.removeChild(bombSkin);
                        _this.parent.addChild(bombSkin);
                        bombSkin.x = myX;
                        bombSkin.y = myY + myZ;
                    }
                    else
                    {
                        bombSkin.x = myX;
                        bombSkin.y = myY + myZ;
                    }
                }
                currentFaceMc.scaleX = scale * myDir;
                
                dialogOver.x = _this.x + 25;
                dialogOver.y = _this.y + 97;
                
                if (_this.scaleX < 0)
                {
                    _this.x += 40;
                } 
            }
        }

        override public function getProperty( obj:Object ):void
        {
            if(GameData.DEBUG_MODE)
            {
                trace("[com.gq.moveobject.Person]"+""+myId+": "+"get property: " + obj.toString());
            }
            myX = obj._x;
            myY = obj._y;
            myZ = obj._z;
            states = obj._s;
            _this.x = myX;
            _this.y = myY + myZ;
            changeStates( states );
        }
        
        override public function fireMe(bomb:Bomb):void
        {
            if(GameData.DEBUG_MODE)
            {
            trace("[com.gq.moveobject.Person]"+"firing person at <"+ myCurrentPositionX + ", " + myCurrentPositionY+">"+
                "<"+ myX + ", " + myY+">" + 
                "<"+ myRectX + ", " + myRectY+">");                
            }
            
            if( invincible || fire )
            {
                return;
            }
            
            if (outline != null)
            {
                outline.bombStateOff();
            }
            
            var victimName:String = myName;
            var victim:Person = Person.getPersonByName(victimName);
            var killerName:String = "";
            
            if(bomb!=null && bomb.bombType != Bomb.DEADLY_BLOCK)
            {
                if (bomb.owner != null && victim != bomb.owner)
                {
                    killerName = (bomb.owner as Person).myName;
                }
                else
                {
                    killerName = (bomb.myMaster as Person).myName;
                }
            }
            Person.searchScore(victim).roundDeaths++;
            Person.searchScore(victim).totalDeaths++;
            
            victim.fireConfirmed(victimName, killerName, bomb);
            
            if(GameData.instance.alivePlayers > 1 && bomb!=null && bomb.bombType != Bomb.DEADLY_BLOCK)
            {
                GameInterfaceManager.getInstance().createKillMessage(victim.myName,killerName, bomb);
            }
        }
        
        public function drawResults():void
        {
            can_action = false;
            showDir("stand");
            score.totalTrophies++;
            score.currentTrophies++;
            trophieList[GameData.instance.currentRound] = "filled";
        }
        
        public function fireConfirmed(victimName:String, killerName:String, bomb:Bomb):void
        {
            var currentTile:Point = (GameData.instance.walkControls[int(myId)] as WalkControlSet).currentTile;
            GameData.instance.positionManager.removeObjectFromMap(currentTile.x, currentTile.y, this);
            
            var killer:Person = getPersonByName(killerName);
            var victimName:String = victimName;
            var victim:Person = getPersonByName(victimName);
            
            var messageShow:Boolean = false;
            if(GameData.DEBUG_MODE)
            {
                trace("[com.gq.moveobject.Person]"+""+myId+": "+"fire confirmed for round " + GameData.instance.currentRound);
            }
            if(GameData.DEBUG_MODE)
            {
                trace("[com.gq.moveobject.Person]"+""+myId+": "+"kill is " + kill.toString());
                trace("[com.gq.moveobject.Person]"+""+myId+": "+"game mode is " + GameData.instance.GAME_MODE);                
            }
            
            can_action = false;
            if( GameData.instance.GAME_MODE == GameModes.BOMB && !kill)
            {
                if(GameData.DEBUG_MODE)
                {
                    trace("[com.gq.moveobject.Person]"+""+myId+": not kill fire");
                }
                fire = true;
                myBombCount = 20;
                shieldTime = 0;
            }
            else
            {
                fire = true;
                myFace = "down";
                showDir("fire");
                deadCount = 0;
                GameData.instance.alivePlayers--;
                can_action = false;
                
                if(bomb==null || bomb.bombType == Bomb.MINE || bomb.bombType == Bomb.DEADLY_BLOCK)
                {
                    var sfsObject:SFSObject = new SFSObject();
                    sfsObject.putInt("pid",victim.userId);
                    sfsObject.putInt(ServerMessages.ROUND_NUMBER,GameData.instance.currentRound);
                    if(bomb!=null && bomb.bombType != Bomb.DEADLY_BLOCK){
                    sfsObject.putInt("kid",getPersonByName(killerName).userId);
                    }
                    
                    SmartFoxClientSingleton.getInstance().smartFoxClient.sendExtensionRequestToGameRoom(ServerMessages.PLAYER_DEATH_REQUEST, sfsObject);
                    
                    if (bomb!=null && bomb.bombType == Bomb.DEADLY_BLOCK)
                    {
                        _this.visible = false;
                    }
                }
                                
                if(bombState){
                    setBombSkin(false);
                }
                if(GameData.DEBUG_MODE)
                {
                    trace("[com.gq.moveobject.Person]"+""+myId+": "+"kill fire");
                    trace("[com.gq.moveobject.Person]"+""+myId+": "+'ALIVE PLAYERS: ',GameData.instance.alivePlayers);
                }
                if(GameData.instance.alivePlayers == 1)
                {
                    GameData.instance.endingState = true;
                    if(GameData.DEBUG_MODE)
                    {
                        trace("[com.gq.moveobject.Person]"+" Are there bombs in the map? " + GameData.instance.positionManager.bombsInMap);
                    }
                }
                else if(GameData.instance.alivePlayers == 0)
                {
                    GameData.instance.endingState = true;
                }
            }
        }
        
        public function pushMe():void
        {
            if(GameData.DEBUG_MODE)
            {
                trace("[com.gq.moveobject.Person]"+""+myId+": "+"pushme");
            }
            
            initSpeed();
            myFace = "down";
            showDir( "dead2" );
            deadCount = 0;
            can_action = false;
        }
        
        public function removeSkull(skullType:String,final:Boolean):void
        {
            skullBuffs.isActive = false;
            
            switch(skullType)
            {
                case SkullTypes.CONFUSION:
                    confusion = false;
                    break;
                case SkullTypes.RECKLESS:
                    reckless = false;
                    lastDirection = PositionManager.NONE;
                    break;
                case SkullTypes.CONSTIPATION:
                    if(skullBuffs.maxBomb == 0)
                    {
                        maxBombsAllowed = 1;
                    }
                    else
                    {
                        maxBombsAllowed = skullBuffs.maxBomb;
                    }
                    skullBuffs.maxBomb = 0;
                    break;
                case SkullTypes.LOW_POWER:
                   /* if(skullBuffs.power == 0)
                    {
                        power = 1;
                    }
                    else
                    {
                        power = skullBuffs.power;
                    }*/
                    skullBuffs.power = 0;
                    break;
                case SkullTypes.SLOW:
                    GameSys.addPowerUp("updateSpeed", myName);
                    break;
                case SkullTypes.QUICK:
                    /*if(GameData.instance.diseaseManager.getDiseasesByPerson(this).length == 0)
                    {
                        if(skullBuffs.speed == 0)
                        {
                            speedAll = 7;
                        }
                        else
                        {
                            speedAll = skullBuffs.speed;
                        }
                        GameSys.addPowerUp("updateSpeed", myName);
                        skullBuffs.speed = 0;
                    }*/
                    GameSys.addPowerUp("updateSpeed", myName);
                    break;
                case SkullTypes.DIZZY:
                    dizzy = false;
                    hideDizzy();
                    break;
                case SkullTypes.DIARRHOEA:
                    diarrhoea = false;
                    break;
                case SkullTypes.EPIC_FIRE:
                    // This point can only be arrived through the function onExtensionResponse, so it always remains synchronized
                    if(GameData.instance.diseaseManager.getDiseasesByPerson(this).length == 0 ){
                        if(skullBuffs.speed == 0)
                        {
                            speedAll = 7;
                        }
                        else
                        {
                            speedAll = skullBuffs.speed;
                        }
                        GameSys.addPowerUp("updateSpeed", myName);
                        skullBuffs.speed = 0;
                    }
                    if(final)
                    {
                        if(!fire)
                        {
                            var diseaseType:String = SkullTypes.getDiseaseText(SkullTypes.EPIC_FIRE);
                            GameInterfaceManager.getInstance().showSubmessage(LanguageManager.getInstance().getAndReplaceTexts("_skullSubmessageEpicFireEnd", ["%player%","%effect%"],[myName,diseaseType]), myAvatar,null,false,SkullTypes.EPIC_FIRE);
                            fireMe(null);
                        }
                    }
                    break;
                case SkullTypes.SHORT_FUSE:
                    shortFuse = false;
                    break;
                case SkullTypes.LONG_FUSE:
                    longFuse = false;
                    break;
                }

            skullBuffs.type = "";
            skullBuffs.deactivateBuff();
        }
        
        public function getSkull(skullType:String):void
        {
            if(GameData.DEBUG_MODE){
                trace("[com.gq.moveobject.Person]"+""+myId+": "+"get skull");
            }
            skullBuffs.isActive = true;
            skullBuffs.type = skullType;
            switch(skullType)
            {
                case SkullTypes.CONSTIPATION:
                    skullBuffs.maxBomb = maxBombsAllowed;
                    maxBombsAllowed = 0;   
                    break;
                case SkullTypes.CONFUSION:
                    skullBuffs.power = power;
                    confusion = true;
                    break;
                case SkullTypes.LOW_POWER:
                    skullBuffs.power = 1;
                    break;
                case SkullTypes.RECKLESS:
                    skullBuffs.power = power;
                    reckless = true;
                    break;
                case SkullTypes.SLOW:
                    skullBuffs.power = power;
                    /*if(speedAll/2 > 0){
                        if( skullBuffs.speed == 0 ){
                            skullBuffs.speed = speedAll;
                        }
                        speedAll = speedAll/2;
                        GameSys.addPowerUp("updateSpeed", myName);*/
                    //}
                    //GameSys.addPowerUp("updateSpeed", myName);
                    break;
                case SkullTypes.QUICK:
                    skullBuffs.power = power;
                    /*if( skullBuffs.speed == 0 ){
                        skullBuffs.speed = speedAll;
                    }
                    skullBuffs.speed = speedAll;
                    speedAll = speedAll*2;
                    GameSys.addPowerUp("updateSpeed", myName);*/
                    //GameSys.addPowerUp("updateSpeed", myName);
                    break;
                case SkullTypes.DIZZY:
                    skullBuffs.power = power;
                    dizzy = true;
                    showDizzy();
                    break;
                case SkullTypes.DIARRHOEA:
                    skullBuffs.power = power;
                    diarrhoea = true;
                    break;
                case SkullTypes.EPIC_FIRE:
                    skullBuffs.power = power;
                    if( skullBuffs.speed == 0 ){
                        skullBuffs.speed = speedAll;
                    }
                    speedAll = 15;
                    GameSys.addPowerUp("updateSpeed", myName);
                    break;
                case SkullTypes.SHORT_FUSE:
                    skullBuffs.power = power;
                    shortFuse = true;
                    break;
                case SkullTypes.LONG_FUSE:
                    skullBuffs.power = power;
                    longFuse = true;
                    break;
                case SkullTypes.POSITION_SWITCH:
                    
                    impossibleToSwitch = false;
                    randomPersonId = random.getRandomBounded(0,GameData.instance.playerArr.length-1);
                    var originalId:int = randomPersonId;
                    randomPersonToSwitch = getPersonById(randomPersonId);
                    
                    while( (randomPersonId == int(myId) || randomPersonToSwitch.fire) && !impossibleToSwitch )
                    {
                        randomPersonId++;
                        if(randomPersonId == GameData.instance.playerArr.length){
                            randomPersonId = 0;
                        }
                        
                        if(originalId==randomPersonId){
                            impossibleToSwitch = true;
                        }
                        randomPersonToSwitch = getPersonById(randomPersonId);
                    }
                    
                    if(!impossibleToSwitch){
                        if(myName == GameData.instance.myName)
                        {
                            var outPut:SFSObject = new SFSObject();
                            outPut.putUtfString("fst", myName);
                            outPut.putUtfString("scd", randomPersonToSwitch.myName);
                            SmartFoxClientSingleton.getInstance().smartFoxClient.sendExtensionRequestToGameRoom(ServerMessages.POSITION_SWITCH, outPut);
                        }
                        
                        if( myName == SmartFoxClientSingleton.getInstance().smartFoxClient.myself.name){
                            //GameInterfaceManager.getInstance().showSubmessage(LanguageManager.getInstance().getAndReplaceText("_yourPositionSwitchSubmessage","%opponent%",randomPersonToSwitch.myName), myAvatar,null,false,SkullTypes.POSITION_SWITCH);
                            
                        }else if( randomPersonToSwitch.myName == SmartFoxClientSingleton.getInstance().smartFoxClient.myself.name){
                            //GameInterfaceManager.getInstance().showSubmessage(LanguageManager.getInstance().getAndReplaceText("_yourPositionSwitchSubmessage","%opponent%",myName), randomPersonToSwitch.myAvatar,null,false,SkullTypes.POSITION_SWITCH);
                        }else{
                            //GameInterfaceManager.getInstance().showSubmessage(LanguageManager.getInstance().getAndReplaceTexts("_positionSwitchSubmessage",["%player%","%opponent%"],[myName,randomPersonToSwitch.myName]), myAvatar,null,false,SkullTypes.POSITION_SWITCH);
                        }
                        invincible = true;
                        randomPersonToSwitch.invincible = true;
                        if ((SmartFoxClientSingleton.getInstance().smartFoxClient.gameRoom != null && !SmartFoxClientSingleton.getInstance().smartFoxClient.myself.isSpectatorInRoom(SmartFoxClientSingleton.getInstance().smartFoxClient.gameRoom)) || GameData.instance.serverMessagesHandler.isSynchronized()){
                            var portal1:Portal = new Portal();
                            var portal2:Portal = new Portal();
                            portal1.openPortal(_this, false, true);
                            portal2.openPortal(randomPersonToSwitch._this, true, true);
                        }
                        setSpriteFaceDown();
                        dizzy = true;
                        randomPersonToSwitch.setSpriteFaceDown();
                        randomPersonToSwitch.dizzy = true;
                        isTweening = true;
                        randomPersonToSwitch.isTweening = true;
                    }
                    break;
            }
        }
        
        public function showDizzy():void{
            _this.addChild(dizzyAnim);
            dizzyAnim.play();
        }
        
        public function hideDizzy():void{
            if (dizzyAnim.parent != null)
            {
                dizzyAnim.stop();
                dizzyAnim.parent.removeChild(dizzyAnim);
            }
        }
        
        public function endPortal():void{
            
            
            if ((SmartFoxClientSingleton.getInstance().smartFoxClient.gameRoom != null && !SmartFoxClientSingleton.getInstance().smartFoxClient.myself.isSpectatorInRoom(SmartFoxClientSingleton.getInstance().smartFoxClient.gameRoom)) || GameData.instance.serverMessagesHandler.isSynchronized())
            {
                switchPositionTimer.start();
            }
            else
            {
                this.invincible = false;
                dizzy = false;
                isTweening = false;
            }
        }
        
        private function onSwitchPositionTimer(evt:TimerEvent):void
        {
            if(switchPositionTimer.currentCount == 1)
            {
                var portal:Portal = Portal.getPortalByPerson(this);
                portal.openPortal(_this, !portal.orange);    
            }
            else if(switchPositionTimer.currentCount == 2)
            {
                Portal.getPortalByPerson(this).unbind();
                Portal.getPortalByPerson(this).closePortal();    
            }
            else if(switchPositionTimer.currentCount == 3)
            {
                
                Portal.getPortalByPerson(this).killPortal();
                dizzy = false;
                switchPositionTimer.reset();
                switchPositionTimer.stop();
                isTweening = false;
            }
        }
        
        public function getTreasure(treasure:Treasure):void
        {
            if(GameData.DEBUG_MODE)
            {
                trace("[com.gq.moveobject.Person]"+""+myId+": "+"get treasure");
            }
            var isPositive:Boolean = true;
            var forceSuddenDeath:Boolean = false;
            
            switch(treasure.itemType)
            {
                case "speicalBomb":
                    objectType = KICKER;
                    GameSys.addPowerUp("specialBomb", myName);
                    break;
                case "dangerBomb":
                    prevBomb = myBomb;
                    myBomb = Bomb.DANGER_BOMB;
                    GameSys.addPowerUp("dangerBomb", myName);
                    break;
                case "powerBomb":
                    prevBomb = myBomb;
                    myBomb = Bomb.POWER_BOMB;
                    GameSys.addPowerUp("powerBomb", myName);
                    break;
                case "bouncingBomb":
                    prevBomb = myBomb;
                    myBomb = Bomb.BOUNCING_BOMB;
                    GameSys.addPowerUp("bouncingBomb", myName);
                    break;
                case "mine":
                    myBomb = Bomb.MINE;
                    GameSys.addPowerUp("mine", myName);
                    break;
                case "spikeBomb":
                    myBomb = Bomb.SPIKE_BOMB;
                    GameSys.addPowerUp("spikeBomb", myName);
                    break;
                case "rocket":
                    break;
                case "skull":
                    isPositive = false;
                    
                    if(treasure.skullType == SkullTypes.SUDDEN_DEATH && !GameData.instance.onSuddenDeath
                        && GameData.instance.diseaseManager.getDiseasesByPerson(this).length == 0){
                        forceSuddenDeath = true;
                        SoundClass.addMusic( "sound", "sfx_roundover" );
                    }
                    else
                    {
                        if(GameData.instance.onSuddenDeath && (treasure.skullType == SkullTypes.POSITION_SWITCH || treasure.skullType == SkullTypes.SUDDEN_DEATH))
                        {
                            treasure.skullType = SkullTypes.QUICK;
                        }
                        GameData.instance.diseaseManager.createDisease(this, treasure.skullType);
                    }
                    break;
                case "powerDown":
                    
                    isPositive = false;
                    
                    if( power > 1 )
                    {
                        /*if(!skullBuffs.isActive && skullBuffs.power == 0){
                            power--;
                        }else if(skullBuffs.power == 0){
                            power--;
                        }*/
                        power--;
                        skullBuffs.power = power;
                    }
                    break
                case "speedUp":
                    if( speed < 14 )
                    {
                        /*if(!skullBuffs.isActive && skullBuffs.speed == 0){
                            speedAll++;
                            GameSys.addPowerUp("updateSpeed", myName);
                        }else if(skullBuffs.speed == 0){
                            speedAll++;
                            GameSys.addPowerUp("updateSpeed", myName);
                        }*/
                        speed++;
                        GameSys.addPowerUp("updateSpeed", myName);
                    }
                    GameSys.addPowerUp("updateSpeed", myName);
                    break;
                case "bombUp":
                    if(GameData.DEBUG_MODE)
                    {
                        trace("[com.gq.moveobject.Person] bomb up picked");
                    }
                    if( maxBombsAllowed < 8 )
                    {
                        if(!skullBuffs.isActive && skullBuffs.maxBomb == 0)
                        {
                            maxBombsAllowed++;
                        }
                        else if(skullBuffs.maxBomb == 0)
                        {
                            maxBombsAllowed++;
                        }
                    }
                    break;
                case "bombDown":
                    
                    isPositive = false;
                    if(GameData.DEBUG_MODE)
                    {
                        trace("[com.gq.moveobject.Person] bomb down picked");
                    }
                    if( maxBombsAllowed >= 2 )
                    {
                        if(!skullBuffs.isActive && skullBuffs.maxBomb == 0){
                            maxBombsAllowed--;
                        }else if(skullBuffs.maxBomb == 0){
                            maxBombsAllowed--;
                        }
                    }
                    break;
                case "powerUp":
                    if( power < 8 )
                    {
                        /*if(!skullBuffs.isActive && skullBuffs.power == 0)
                        {
                            power++;
                        }
                        else if(skullBuffs.power == 0)
                        {
                            power++;
                        }*/
                        power++;
                        skullBuffs.power = power;
                    }
                    break;
                case "maxPower":
                        power = 8;
                        skullBuffs.power = power;
                    break;
                case "speedDown":
                    isPositive = false;
                    if( speed > 7 )
                    {
                        /*if(!skullBuffs.isActive && skullBuffs.speed == 0){
                            speedAll--;
                            GameSys.addPowerUp("updateSpeed",myName);
                        }else if(skullBuffs.speed == 0){
                            speedAll--;
                            GameSys.addPowerUp("updateSpeed",myName);
                        }*/
                        speed--;
                        GameSys.addPowerUp("updateSpeed",myName);
                    }
                    break;
                case "bomb_change":
                    bombSkinItemGot = true;
                    GameSys.addPowerUp("bomb_change", myName);
                    break;
            }
            
            var scorePoints:int = 0;
            if (isPositive){
                score.roundPositiveItems++;
                score.totalPositiveItems++;
                scorePoints = GameData.SCORE_PER_POSITIVE_ITEM;
            }else{
                score.roundNegativeItems++;
                score.totalNegativeItems++;
                scorePoints = GameData.SCORE_PER_NEGATIVE_ITEM;
            }
            
            if(userId == SmartFoxClientSingleton.getInstance().smartFoxClient.myself.id){
                var sfsObject:SFSObject = new SFSObject();
                sfsObject.putInt("s",scorePoints);
                if(forceSuddenDeath){
                    sfsObject.putBool("sd",true);
                    //GameInterfaceManager.getInstance().showSubmessage(LanguageManager.getInstance().getAndReplaceText("_yourSuddenDeathSkullSubmessage","%player%",myName), myAvatar, null, false, SkullTypes.SUDDEN_DEATH);
                }
                SmartFoxClientSingleton.getInstance().smartFoxClient.sendExtensionRequestToGameRoom(ServerMessages.ITEM_CAUGHT,sfsObject);
            }else{
                if(forceSuddenDeath){
                    //GameInterfaceManager.getInstance().showSubmessage(LanguageManager.getInstance().getAndReplaceText("_suddenDeathSkullSubmessage","%player%",myName), myAvatar, null, false, SkullTypes.SUDDEN_DEATH);
                }
            }
        }
        
        override protected function fire_Func():void
        {
            if(GameData.DEBUG_MODE)
            {
                trace("[com.gq.moveobject.Person]"+""+myId+": "+"fire");
            }
            changeStates( "dead" );
            SoundClass.addMusic( "sound" + String( uint( Math.random() * 7 ) + 1 ), "dead" );
        }
        
        public function saved():void
        {
            if(GameData.DEBUG_MODE)
            {
                trace("[com.gq.moveobject.Person]"+""+myId+": "+"saved");
            }
            
            can_action = true;
            fire = false;
            showDir( "stand" + walkStr );
        }
        
        override public function removeMe ():void
        {
            if(fire){
                _this.visible=false;
            }
        }
        
        public function finalDelete():void
        {
            var myPersonPosition:int = Person.allPersons.indexOf(this);
            dialogOver.visible = false;
            Person.allPersons.splice(myPersonPosition,1);
            score.person = null;
            _this.visible=false;
            GameTools.unPushArr(GameData.instance.objectArr, this);
            super.removeMe();
            removeMeFromMap();
            GameTools.unPushArr(GameData.instance.playerArr, this);
            if(!fire)
            {
                GameData.instance.alivePlayers--;
            }
        }
        
        protected function reburn():void
        {
            if(GameData.DEBUG_MODE)
            {
                trace("[com.gq.moveobject.Person]" + myId + ": "+"re");
            }
            
            myX = myBurnPositionX;
            myY = myBurnPositionY;
            initProperty();
            saved();
            initMyData();
            dead=false;
            scale = Math.abs(scale);
        }
        
        protected function restart(initialTilePosition:Point):void
        {
            
            myX = myBurnPositionX;
            myY = myBurnPositionY;
            
            GameData.instance.positionManager.initPersonPosition(initialTilePosition.x, initialTilePosition.y, this);
            confirmedPosition.x = initialTilePosition.x;
            confirmedPosition.y = initialTilePosition.y;
            
            if(GameData.DEBUG_MODE)
            {
                trace("[com.gq.moveobject.Person]"+""+myId+": "+"restart at my=<" + myX + ", " + myY + ">; init tile = <"+ initialTilePosition.x + ", " + initialTilePosition.y + ">" );
            }
            
            GameSys.resetPowerUp();
            initProperty();
            saved();
            GameData.instance.alivePlayers = GameData.instance.playerNames.length;
            (GameData.instance.walkControls[myId] as WalkControlSet).restoreBornTilePosition(initialTilePosition);
            deleteMe = false;
            controlMc();
            can_action = true;
            power = 1;
            skullBuffs.isActive = false;
            
            if(bombState){
                setBombSkin(false);
                
            }
        }
        
        public function changePosition():void
        {
            trace("[com.gq.moveobject.Person]"+""+myId+": "+"change position");
            walkStr = ""
            reburn();
        }
        
        override protected function judgeLimit ():void
        {
            if(GameData.DEBUG_MODE)
            {
                trace("[com.gq.moveobject.Person]"+""+myId+": "+"judge limit");
            }
            
            super.judgeLimit();
            
            if( walkStr == "_f" )
            {
                judgeRectX();
                judgeRectY();
            }
        }
        
        private function setPos( _x:Number, _y:Number ):void
        {
            if(GameData.DEBUG_MODE)
            {
                trace("[com.gq.moveobject.Person]"+""+myId+": "+"set pos("+_x+", "+_y+")");
            }
            
            myX = _x;
            myY = _y;
        }
        
        public static function getPersonById(id:uint):Person{
            var p:Array = GameData.instance.playerArr;
            for each(var player:Person in GameData.instance.playerArr){
                if(uint(player.myId)==id){
                    return player; 
                }
            }
            return null;
        }
        
        public static function getPersonByName(name:String):Person{
            if(Person.allPersons.length > 0){
                for(var i:uint=0;i<Person.allPersons.length;i++){
                    
                    if(Person.allPersons[i].myName == name){
                        return Person.allPersons[i];
                    }
                }
            }
            return null;
        }
        
        public static function getPersonByUserId(id:int):Person{
            if(GameData.instance.playerArr.length > 0){
                for(var i:uint=0;i<GameData.instance.playerNames.length;i++){
                    if(GameData.instance.playerArr[i].userId == id){
                        return GameData.instance.playerArr[i];
                    }
                }
            }
            return null;
        }
        
        override public function isCompatible(objectType:uint, myTile:Point,objectTile:Point):Boolean {
            //TODO: use game mode
            if ( BOMB == objectType || BOX == objectType) {
                return false;
            } else {
                return true;
            }
        }
        
        public function get power():uint{
            return _power;
        }
        
        public function set power(value:uint):void{
            _power = value;
            GameSys.addPowerUp("updatePower", myName);
        }
        
        public function get bombsOnField():int{
            return _bombsOnFieldArray.length;
        }
        
        public function get maxBombsAllowed():uint{
            return _maxBombsAllowed;
        }
        
        public function set maxBombsAllowed(value:uint):void{
            if(GameData.DEBUG_MODE) {
                trace("[com.gq.moveobject.Person]"+"bomb total set to "+value);
            }
            _maxBombsAllowed = value;
            GameSys.addPowerUp("updateBombNum", myName)
        }
        
        public function get bombId():uint{
            serialId++;
            return serialId*100 + uint(myId);
        }
        
        public function get currentName():String
        {
            _currentName = myName;
            return _currentName;
        }
        
        public function set currentName(value:String):void
        {
            _currentName = value;
        }
        
        override protected function getMyPosition():void
        {
            
            var control:WalkControlSet = GameData.instance.walkControls[int(myId)];
            if(control != null){
                myCurrentPositionX = control.currentTile.x;
                myCurrentPositionY = control.currentTile.y;
            }
            
        }    
        
        public function showDialogOver():void{
            
            if (myName == SmartFoxClientSingleton.getInstance().smartFoxClient.myself.name){
                
                dialogOver.gotoAndStop("myself");
                
            } else {
                
                dialogOver.gotoAndStop("unknown");
                
            }
            
            if (SmartFoxClientSingleton.getInstance().smartFoxClient.getPlayerByName(myName) != null 
                && !(SmartFoxClientSingleton.getInstance().smartFoxClient.myself.name == myName 
                && SmartFoxClientSingleton.getInstance().smartFoxClient.myself.isSpectatorInRoom(SmartFoxClientSingleton.getInstance().smartFoxClient.gameRoom))
                && GameData.instance.currentGameStatus != StatusManager.CHARACTER_SELECT_STATUS){
                dialogOver.visible = true;
            } else {
                dialogOver.visible = false;
            }
            dialogOver.label.text = myName;
            
        }
        
        public static function toggleVisible(on:Boolean):void{
            
            for (var i:uint = 0; i < allPersons.length; i++){
                
                if ((allPersons[i] as Person)._this != null 
                    && SmartFoxClientSingleton.getInstance().smartFoxClient.getPlayerByName(allPersons[i].myName) != null && 
                    !(SmartFoxClientSingleton.getInstance().smartFoxClient.myself.name == (allPersons[i] as Person).myName && SmartFoxClientSingleton.getInstance().smartFoxClient.myself.isSpectatorInRoom(SmartFoxClientSingleton.getInstance().smartFoxClient.gameRoom))){
                    
                    if((allPersons[i] as Person).confirmedPosition != null){
                        (allPersons[i] as Person)._this.visible = on;
                        (allPersons[i] as Person).dialogOver.alpha = 1;
                        (allPersons[i] as Person).alphaIndex = 150;
                        TweenMax.to((allPersons[i] as Person).dialogOver, 2, {alpha:0,delay:5});
                    }
                }
            }
        }
        
        public static function playersReady():void{
            for (var i:uint = 0; i < allPersons.length; i++){
                if ((allPersons[i] as Person)._this != null){
                    (allPersons[i] as Person).alphaIndex = 1;
                }
            }
        }
        
        public static function resetRoundKillScores():void{
            for each(var s:PersonScore in GameData.instance.scores){
                s.roundKills = 0;
                s.roundDeaths = 0;
                s.deathPosition = 0;
                s.roundNegativeItems = 0;
                s.roundPositiveItems = 0;
                s.currentScore = new Score();
            }
        }
        
        public static function startLatencyCheck():void{
            for (var i:uint = 0; i < allPersons.length; i++){
                EventListenerManager.setListenerTo((allPersons[i] as Person).latencyCheck, TimerEvent.TIMER_COMPLETE, timedOut);
                (allPersons[i] as Person).latencyCheck.start();
            }
        }
        
        public static function stopLatencyCheck():void{
            for (var i:uint = 0; i < allPersons.length; i++){
                EventListenerManager.removelistenerFrom((allPersons[i] as Person).latencyCheck, TimerEvent.TIMER_COMPLETE, timedOut);
                (allPersons[i] as Person).latencyCheck.reset();
            }
        }
            
        public static function cleanLatencyCheck():void{
            
            for (var i:uint = 0; i < allPersons.length; i++){
                EventListenerManager.removelistenerFrom((allPersons[i] as Person).latencyCheck, TimerEvent.TIMER_COMPLETE, timedOut);
                (allPersons[i] as Person).latencyCheck.stop();
                (allPersons[i] as Person).latencyCheck = null;
        }
        
        }
        
        private static function timedOut(e:TimerEvent):void{
            
            var thisPerson:Person;
            
            for (var i:uint = 0; i < allPersons.length; i++){
                if ((allPersons[i] as Person).latencyCheck == e.currentTarget){
                    thisPerson = allPersons[i];
                }
            }
            var timeOutEvent:PersonEvent = new PersonEvent(PersonEvent.TIMED_OUT, thisPerson);
            if (thisPerson != null && thisPerson._this != null){
                thisPerson._this.dispatchEvent(timeOutEvent);
                thisPerson.hasTimedOut = true;
            }
            
        }
        
        public function refreshLatencyCheck():void{
            
            latencyCheck.reset();
            latencyCheck.start();
            
        }

        public static function searchScore(p:Person):PersonScore{
            for each(var s:PersonScore in GameData.instance.scores){
                if(s.person == p){
                    return s;
                }
            }
            return null;
        }
        
        public static function personsNotInList(list:ISFSArray):Array
        {
            var output:Array = new Array();
            if(allPersons.length > 0)
            {
                var namesMap:Object = new Object();
                for(var i:int=0; i < list.size(); i++)
                {
                    namesMap[list.getUtfString(i)] = 1;
                }
                for(var j:uint=0;j< allPersons.length;j++)
                {
                    if(namesMap[allPersons[j].myName] != 1)
                    {
                        output.push(allPersons[j].myName);
                    }
                }
            }
            return output;
        }
        
        public static function printAllPersons():String
        {
            var output:String = "|";
            if(allPersons.length > 0)
            {
                for(var j:uint=0;j< allPersons.length;j++)
                {
                        output += allPersons[j].myName + "|";
                }
            }
            else
            {
                output += "{empy list|}";
            }
            return output;
        }
        
        public override function set speedAll(value:Number):void
        {
            _speedAll = value;
        }
        
        public override function get speedAll():Number
        {
            if(skullBuffs.isActive)
            {
                if(skullBuffs.type == SkullTypes.SLOW)
                {
                    return 3.5;
                }
                else if(skullBuffs.type == SkullTypes.QUICK)
                {
                    return 14;
                }
            }
            
            return speed;
        }
    }
}