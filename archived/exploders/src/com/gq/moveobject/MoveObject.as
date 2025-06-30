package com.gq.moveobject
{
    import com.gq.system.*;
    
    import flash.display.MovieClip;
    import flash.display.Sprite;
    import flash.geom.Point;

    /**
     * Represents a movable object in the game.
     */
    public class MoveObject
    {
        public static const EFFECT:uint=0;
        public static const BOMB:uint=1;
        public static const CROWN:uint=2;
        public static const FLAG:uint=3;
        public static const MARK:uint=4;
        public static const PERSON:uint=5;
        public static const TREASURE:uint=6;
        public static const BOX:uint=7;
        public static const KICKER:uint=8;
        public static const HOLE:uint=9;

        public static const STOPS_EXPLOSION:uint=0;
        public static const DONT_STOP_EXPLOSION:uint=1;

        /**
         * Indicates the type of the represented object.
         * Posible values are:
         * 
         * MoveObject.EFFECT
         * MoveObject.BOMB
         * MoveObject.CROWN
         * MoveObject.FLAG
         * MoveObject.MARK
         * MoveObject.PERSON
         * MoveObject.TREASURE
         * MoveObject.BOX
         * MoveObject.KICKER
         */
        public var objectType:uint;

        /**
         * Indicates if the object stops an explosion when 
         * it hits it, or have any policy for stopping explosions.
         * Current posible values are:
         * 
         * STOPS_EXPLOSION
         * DONT_STOP_EXPLOSION 
         */
        protected var _stopsExplosionCategory:uint;

        public var shoot_count:uint;
        //是否可以发生碰撞
        protected var can_collision:Boolean;
        public var _this:MovieClip;
        public var myMcName:String;
        public var data_index:uint;
        public var createId:uint;
        //行走路径
        protected var walkPath:Array;
        //目前所举之物
        public var myHandObj:MoveObject;
        //
        public var action_index:uint;
        //受创几率
        protected var injureRate:Number = 1;
        //是否可以接受攻击
        public var can_beat:Boolean;
        //怪物类型
        public var type:String = "";
        //零件名
        public var myClipName:String = "";
        //射击特效名
        protected var myShootEffectName:String = "";
        //当前所在地面高度
        public var nowLandHeight:String;
        //打我的人
        public var hiter:MoveObject;
        //被我攻击到的人
        public var myHiter:Array = new Array();
        //子弹类型
        protected var bulletType:uint;
        //攻击力
        public var damageArr:Array = [ 10, 1, 1 ];
        //自己的主人
        public var myMaster:MoveObject;
        //重力加速度
        public var g:Number = 1;
        //死亡闪烁时间
        public var deadCount:uint;
        //是否闪烁---------------------------------------------------
        protected var flashing:Boolean;
        //攻击CD
        protected var current_cd:uint;
        protected var cd_time:uint;
        //炮口
        protected var cannon_height:Number;
        //自己的阵营
        public var myCamp:String = "";
        public var myLife:Number = 500;
        public var restoreLife:Number;
        public var restoreSpeed:Number = 0.2;
        public var states:String;
        public var blockedX:Boolean;
        public var blockedY:Boolean;
        public var flee:Boolean;
        public var myID:uint;
        public var myX:Number;
        public var myY:Number;
        public var myZ:Number;
        public var myDir:int = 1;
        //横向格子
        public var myXRect:uint;
        //纵向格子
        public var myYRect:uint;
        //自身速度
        public var speedX:Number = 0;
        public var speedY:Number = 0;
        public var speedZ:Number = 0;
        //被动速度
        public var pushSpeedX:Number = 0;
        public var pushSpeedY:Number = 0;
        public var pushSpeedZ:Number = 0;
        //最终速度
        public var finalSpeedX:Number = 0;
        public var finalSpeedY:Number = 0;
        public var finalSpeedZ:Number = 0;
        //
        protected var _speedAll:Number;
        //角度
        public var myRotation:Number;
        protected var nowMoveSpeed:Number = 7;
        //
        public var distX:Number;
        public var distY:Number;
        //一段跳跃速度
        protected var jumpSpeed:Number = -15;
        //是否已经死亡
        protected var dead:Boolean;
        //是否可控制移动
        public var can_action:Boolean = true;
        //是否无敌
        public var invincible:Boolean;
        //无敌计数时间
        public var alphaIndex:uint;
        //无敌总时间
        public var invinciTime:uint = 70;

        protected var myCurrentFrame:int;
        protected var whichFrameReady:int;
        protected var whichFrameFinished:int;
        protected var whichFrameReturn:int;
        protected var myFrameEvent:Array;
        protected var myFrameSound:Array;
        public var myReady:Boolean = true;
        //动作是否完成
        public var myActionFinished:Boolean = true;

        public var deleteMe:Boolean;
        public var notAdd:Boolean;
        public var myParent:Sprite;
        //Z轴落点
        public var distPostionZ:Number = 0;
        //头顶上的东西
        public var upThingsArr:Array = new Array();
        //X，Y轴碰撞到的物体
        public var collisionObjArr:Array = new Array();
        public var nowCollisionObj:MovieClip;
        //是否已经着陆
        public var land:Boolean;
        //血槽
        public var bloodBar:MovieClip;
        //A*寻路----------------------------------------------
        protected var targetIX:int;
        protected var targetIY:int;
        protected var unlockList:Array;
        protected var lockList:Object;
        public var myCurrentPositionX:int;
        public var myCurrentPositionY:int;
        protected var myOldX:Number;
        protected var myOldY:Number;
        protected var stand_FI:Array;
        protected var stand2_FI:Array;
        protected var stand_f_FI:Array;
        protected var walk_FI:Array;
        protected var walk2_FI:Array;
        protected var walk_f_FI:Array;
        protected var fire_FI:Array;
        protected var dead_FI:Array;
        protected var dead2_FI:Array;
        
        protected var scale:Number;
        public var testMc:MovieClip;
        public var fire:Boolean;
        public var open:Boolean = false;
        
        public function MoveObject ():void
        {
            stand_FI =      [1,  1,   30,     [1],                                     null];
            stand2_FI =      [1,  1,   30,     [1],                                     null];
            stand_f_FI =      [1,  1,   30,     [1],                                     null];
            walk_FI =      [1,  1,   30,     [1],                                     null];
            walk2_FI =      [1,  1,   30,     [1],                                     null];
            walk_f_FI =      [1,  1,   30,     [1],                                     null];
            fire_FI =      [1,  1,   2,     [2],                                     null];
            dead_FI =      [1,  1,   45,     [45],                                     null];
            dead2_FI =      [1,  1,   40,     [40],                                     null];
            initData ();
        }
        public function initData ():void
        {
            states = "stand";
        }
        public function init ( _x:Number, _y:Number, _z:Number, _states:String = "" ):void
        {
            myX = _x;
            myY = _y;
            myZ = _z;
            
        }

        public function isCompatible(objectType:uint, myTile:Point,objectTile:Point):Boolean{
            return true;
        }

        public function createMe ( where:Sprite, who:String, index:int, swf_name:String, _walkPath:Array , oldMc:MovieClip = null):void
        {
            myMcName = who;
            var tempMc:MovieClip;
            if (oldMc == null){
                var tempClass:Class = GameTools.getMeBySwf( swf_name, who );
                tempMc = new tempClass();
            }else{
                tempMc = oldMc;
            }
            getMyPosition();
            GameData.instance["Container_" + String(myCurrentPositionY)].addChildAt ( tempMc, index );
            _this = tempMc;
            _this["myHost"] = this;
            _this.mouseEnabled = false;
            _this.mouseChildren = false;
            data_index = uint( who.substring( who.indexOf( "_" ) + 1, who.length ) ) - 1;
            distX = _this.width / 2;
            distY = _this.height;
            walkPath = _walkPath;
            initMyData ();            
        }

        /**
         * Initialize the personality attributes.
         */
        protected function initMyData ():void
        {
            controlMc ();
            _stopsExplosionCategory = DONT_STOP_EXPLOSION;
        }
        
        //地面改变状态------------------------------------------------------------------------
        public function changeStates ( which:String, force:Boolean = true ):void
        {
            states = which;
            changeFrameAction ( _this, which );
        }
        public function updataEvent ():void
        {
        }

        protected function Fall():void
        {
        }

        //判断我现在的位置是否有物体
        protected function judgeMyPostion():Boolean
        {
            var _value:Boolean;
            try
            {
                _value = GameData.instance["mapArr" + nowLandHeight][myXRect][myYRect];
            }
            catch(e:Error)
            {
                trace("[com.gq.moveobject.MoveObject] map error" );
                _value = false;
            }
            return _value;
        }
        protected function hitTestWho ( where:String ):void
        {
            for (var k:uint = 0; k < GameData.instance[ where ].numChildren; k++)
            {
                var tc:MovieClip = GameData.instance[ where ].getChildAt( k ) as MovieClip;
            }
        }
        protected function getBlocked ():void
        {
            
        }
        protected function controlMe ():void
        {
        }
        protected function switchStates ():void
        {
            try
            {
                this[states + "_Func"]();
            }
            catch (e:*)
            {
                trace("[com.gq.moveobject.MoveObject] action execution error");
            }
        }
        protected function changeData ():void
        {
            myX += speedX;
            myY += speedY;
        }
        protected function judgeLimit ():void
        {
            blockedX = false;
            blockedY = false;
            if ( speedX < 0 && myX - 15 + speedX < 0  )
            {
                myX = 15;
                blockedX = true;
            }
            else if ( speedX > 0 && myX + distX + speedX > GameData.instance.screenWidth )
            {
                myX = GameData.instance.screenWidth - distX
                blockedX = true;
            }
            if ( speedY < 0 && myY - GameData.instance.rectHeight / 2 + speedY < GameData.instance.upLine )
            {
                
                myY = GameData.instance.upLine + GameData.instance.rectHeight / 2;
                blockedY = true;
            }
            else if ( speedY > 0 && myY + GameData.instance.rectHeight / 2 + speedY > GameData.instance.screenHeight )
            {
                myY = GameData.instance.screenHeight - GameData.instance.rectHeight / 2;
                blockedY = true;
            }
        }
        public function controlMc ():void
        {
            if ( _this != null )
            {
                _this.x = myX;
                _this.y = myY;
                _this.scaleX = myDir;
            }
        }
        //在空中----------------------------------------------------
        protected function stayInSky ():void
        {
            if( type != "fly" )
            {
                speedZ += g;
            }
            if ( speedZ > 20 )
            {
                speedZ = 20;
            }
        }
        public function changeFrameAction (who:MovieClip,where:String):void
        {
            myCurrentFrame = 1;
            GameTools.gotoFrame ( who, where );
            whichFrameReady = this[where+"_FI"][0];
            whichFrameFinished = this[where+"_FI"][1];
            whichFrameReturn = this[where+"_FI"][2];
            myFrameEvent = this[where+"_FI"][3];
            myFrameSound = this[where+"_FI"][4];
            if ( whichFrameReady + whichFrameFinished > 2 )
            {
                myReady = false;
                myActionFinished = false;
            }
        }
        protected function restoreState ():void
        {
            if ( myFrameEvent != null )
            {
                if ( myCurrentFrame == Number( myFrameEvent[0] ) )
                {
                    try
                    {
                        this[ states + "_over" ]();
                    }
                    catch (e:*)
                    {
                        trace("[com.gq.moveobject.MoveObject]", this, "Wrong end of the action", states );
                    }
                }
            }

            //frame of the animation parameters, must be greater than to play one frame after the last
            if (myCurrentFrame == whichFrameReady)
            {
                myReady = true;
            }
            if (myCurrentFrame >= whichFrameFinished)
            {
                myActionFinished = true ;
            }
            if (myCurrentFrame >= whichFrameReturn)
            {
                myCurrentFrame = 0;
            }

            myCurrentFrame++;
        }

        public function initSpeed ( Z:Boolean = false ):void
        {
            speedX = 0;
            speedY = 0;
            if ( Z )
            {
                speedZ = 0;
            }
        }

        protected function stand_over ():void
        {
        }

        protected function stand2_over ():void
        {
        }

        protected function stand_f_over ():void
        {
        }

        protected function walk_over ():void
        {
        }

        protected function walk2_over ():void
        {
        }

        protected function walk_f_over ():void
        {
        }

        protected function fire_over():void
        {
        }

        protected function dead_over():void
        {
        }

        protected function dead2_over():void
        {
        }

        protected function stand_Func ():void
        {
        }

        protected function stand2_Func ():void
        {
        }

        protected function stand_f_Func ():void
        {
        }

        protected function walk_Func ():void
        {
        }

        protected function walk2_Func ():void
        {
        }

        protected function walk_f_Func ():void
        {
        }

        protected function fire_Func ():void
        {
        }

        protected function dead_Func():void
        {
        }

        protected function dead2_Func():void
        {
        }

        public function removeMe ():void
        {
            GameTools.unPushArr(GameData.instance.actionArr, this);
            GameTools.unPushArr(GameData.instance.objectArr, this);
            dispose();
            defaultData();
            hiter = null;
            myMaster = null;
        }

        protected function defaultData():void
        {
            hiter = null;
            myMaster = null;
            _this = null;
        }

        protected function flashMe ():void
        {
            if ( _this != null )
            {
                _this.alpha = deadCount % 2;
            }

            if ( ++deadCount == 30 )
            {
                deleteMe = true;
            }
        }

        public function removeMc ():void
        {
            if ( _this != null )
            {
                myParent = _this.parent as Sprite;
                myParent.removeChild ( _this );
                notAdd = true;
            }
        }

        public function addMc ():void
        {
            if ( _this != null && myParent != null )
            {
                myParent.addChild ( _this );
                notAdd = false;
            }
        }

        public function pauseMe ():void
        {
            if ( _this.mc != null )
            {
                _this.mc.stop ();
            }
        }

        public function resumeMe ():void
        {
            if ( _this.mc != null )
            {
                _this.mc.play ();
            }
        }

        protected function otherFunc():void
        {
        }
        
        protected function getMyPosition():void
        {
            myCurrentPositionX = uint( myX/ GameData.instance.rectWidth );
            myCurrentPositionY = uint( (myY - GameData.instance.upLine) / GameData.instance.rectHeight );
        }

        public function HurtMe( damage:int, tough_time:uint, spdX:Number ):void
        {
            myLife -= damage;
        }

        protected function addMyPart( num:uint, clipName:String ):void
        {
            for( var i:uint = 0; i < num; i++ )
            {
                GameSys.addEffects( GameData.instance.personContainer, "ClipEffect", clipName, myX, myY, myZ )
            }
        }
        //添加击打特效
        protected function addHitEffect( type:uint, hiter:MoveObject ):void
        {
        }
        
        /**
         * Method to detonate elements.
         */
        public function fireMe(bomb:Bomb):void
        {
        }
        
        public function restore():void{
            
        }

        //
        public function getProperty( obj:Object ):void
        {
            
        }
        
        public function get stopsExplosionCategory():uint
        {
            return _stopsExplosionCategory;
        }
        
        public function removeMeFromMap():void
        {
            GameData.instance.positionManager.removeObjectFromMap(myCurrentPositionX, myCurrentPositionY, this);
        }
        
        public function dispose():void
        {
            myMcName = null;
            walkPath = null;
            type = null;
            myClipName = null;
            myShootEffectName = null;
            nowLandHeight = null;
            hiter = null;
            myHiter = null;
            damageArr = null;
            myMaster = null;
            myCamp = null;
            states = null;
            myFrameEvent = null;
            myFrameSound = null;
            myParent = null;
            upThingsArr = null;
            collisionObjArr = null;
            nowCollisionObj = null;
            bloodBar = null;
            unlockList = null;
            lockList:Object;
            stand_FI = null;
            stand2_FI = null;
            stand_f_FI = null;
            walk_FI = null;
            walk2_FI = null;
            walk_f_FI = null;
            fire_FI = null;
            dead_FI = null;
            dead2_FI = null;
            testMc = null;
            if (_this != null && _this.parent != null){
                _this.parent.removeChild(_this);
            }
            _this = null;;
        }
        
        public function get speedAll():Number
        {
            return _speedAll;
        }
        
        public function set speedAll(value:Number):void
        {
            _speedAll = value;
        }
    }
}