package com.gq.system
{
    import com.gq.moveobject.*;
    import com.gq.ui.*;
    import com.smartfoxserver.v2.entities.Room;
    import com.smartfoxserver.v2.entities.data.SFSArray;
    import com.smartfoxserver.v2.entities.data.SFSObject;
    import com.willdom.games.bomberman.communication.SmartFoxClientSingleton;
    import com.willdom.games.bomberman.config.GameConfigManager;
    import com.willdom.games.bomberman.controllers.ConfigController;
    import com.willdom.games.bomberman.gameobjects.GameObjectsContainer;
    import com.willdom.games.bomberman.gameobjects.PersonScore;
    import com.willdom.games.bomberman.gameobjects.bombs.BombManager;
    import com.willdom.games.bomberman.gameobjects.items.ItemTypes;
    import com.willdom.games.bomberman.position.PositionManager;
    import com.willdom.games.bomberman.position.maps.MapDescription;
    import com.willdom.games.bomberman.spectators.ServerMessagesHandler;
    import com.willdom.games.bomberman.usableItems.UsableItemsManager;
    import com.willdom.games.explodersmmo.shared.model.SoundSettings;
    
    import configuration.Config;
    import configuration.GameModes;
    import configuration.StageModes;
    
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.DisplayObjectContainer;
    import flash.display.Loader;
    import flash.display.MovieClip;
    import flash.display.Sprite;
    import flash.filters.ColorMatrixFilter;
    import flash.filters.GlowFilter;
    import flash.geom.ColorTransform;
    import flash.geom.Rectangle;
    import flash.media.Sound;
    import flash.media.SoundChannel;
    import flash.media.SoundTransform;
    import flash.net.SharedObject;
    import flash.net.URLLoader;
    import flash.net.URLRequest;
    import flash.text.TextField;
    
    import flashx.textLayout.elements.Configuration;
    
    
    public class GameData
    {
        public static const DEBUG_MODE:Boolean = false;
        public static const SHOW_ELEMENTS:Boolean = false;
        public static const INVINCIBILITY_FOR_DEBUG_MODE:Boolean = false;
        public static const SCORE_PER_DEATH:uint = 20;
        public static const SCORE_PER_ROUND_SURVIVAL:uint = 40;
        public static const SCORE_PER_COMBO_2:uint = 5;
        public static const SCORE_PER_COMBO_3:uint = 10;
        public static const SCORE_PER_COMBO_MORE_THAN_3:uint = 15;
        public static const SCORE_PER_DEATH_POINT:Number = 0;
        public static const SCORE_PER_POSITIVE_ITEM:Number = 1;
        public static const SCORE_PER_NEGATIVE_ITEM:Number = -1;
        
        public static const CHARACTER_NAMES:Array = ["Nerd","Blue girl","Loop","Bandit","Curly","Pipe","Camo",
            "Orange girl","Pirate","Ninja","SE Girl","Green soldier","Bunny","Pinguin","Bandana","Mask","Glasses",
            "Batman","Joker","Superman","Wolverine","Lara","Captain","Catwoman","Avatar"];
        
        //游戏模式
        public var GAME_MODE:String = GameModes.DEFAULT; //"BOMB"//"KING"//"AIR"//"GOLD"//FLAG"//"REVENGE"//"COUNT";
        public var STAGE_MODE:String = StageModes.DEFAULT;//"open"//"power"//"ufo"//"hole"//"bowling"//"grab"//"volcanoes"//"zombies"//hyper
        
        public static const MINE_DISSAPEARENCE_TIME:uint=1500;
        
        public static const SCORE_SHOW_TIMER:uint = 5;
        public static const TOTAL_SHOW_TIMER:uint = 10;
        public static const REMATCH_TIMER:uint = 20;
        public static const REMATCH_TIMER_SHORT:uint = 5;
        public static const SELECTION_TIMER:uint = 15;
        public static const BACK_TO_LOBBY_TIMER:uint = 5;
        public static const SCORE_TITLE_FONT_SIZE:int = 22;

        public static const ROUND_TRIP_ALPHA:Number = .75;

        public var gameStarted:Boolean;
        public var playersCreated:Boolean;
        
        public var rematchTimer:uint = 20;
        public var scoreTimer:uint = 5;
        public var isRematching:Boolean = false;
        public var rematchFailed:Boolean = false;
        public var rematchCountStarted:Boolean = false;
        public var totalPlayers:int = 0;
        public var leaveScoreReduction:int;
        
        public var gameSync:Boolean = false;
        public var syncExtendedContainer:Boolean = true;
        
        public var positionManager:PositionManager;
        public var bombManager:BombManager;
        
        //是否按局数计分
        public var trophies:Boolean = false;
        private var _winner:String;
        public var rematcher:Boolean;
        public var rematcherName:String;
        //总局数
        private var _currentRound:uint = 1;
        public var round:uint = 1;
        //每局时间
        public var time:uint = 60;
        //是否为复仇模式
        public var revenge:Boolean;
        //是否有围城模式
        public var onSuddenDeath:Boolean = false;
        public var suddenDeath:Boolean = false;
        //是否可推箱子
        public var push:Boolean = false;
        //是否有头骨
        public var skulls:Boolean;
        //是否有物品选项
        public var item:Boolean;
        
        public var firstTick:Boolean = false;
        public var alreadyWinLose:Boolean = false;
        public var isShowingMessage:Boolean = false;
        
        public var currentTick:int = 0;
        public var currentLocalTick:int = 0;
        
        /**
         * Whether a random starting point.
         */
        public var random_point:Boolean = false;
        public var burnableItems:Boolean = true;
        
        public var shakeCount:uint;
        //目前控制的是谁
        public var controlWho0:*;
        public var controlWho1:*;
        public var controlWho2:*;
        public var controlWho3:*;
        public var controlWho4:*;
        public var controlWho5:*;
        public var controlWho6:*;
        public var controlWho7:*;
        public var controlWho8:*;
        //当前大关
        public var mapName:String = "1";
        //当前小关
        public var level_index:uint = 1;
        //总共多少关
        public var total_level_num:uint;
        //剩余时间
        public var time_left:int;
        //总时间
        public var total_time:uint = 99;
        //舞台
        public var Scen:DisplayObjectContainer;
        //地图
        public var currentMap:Map;
        //
        public var topSprite:Sprite;
        public var bottomSprite:Sprite;
        public var playerSelectionWindow:Sprite;
        public var noPlayersWindow:Sprite;
        public var infoWindow:Sprite;
        public var roundWindow:Sprite;
        public var totalWindow:Sprite;
        
        public var suddenDeathSprite:Sprite;
        public var suddenDeathMessage:SuddenDeathMessage;
        //主容器
        public var gameContainer:Sprite;
        //背景容器
        public var bgContainer:Sprite;
        //特效容器
        public var effectContainer:Sprite;
        //移动物体容器
        public var moveObjectContainer:Sprite;
        //底层物品容器
        public var bottomObjectContainer:Sprite;
        //人物容器
        public var personContainer:Sprite;
        //顶层物品容器
        public var topObjectContainer:Sprite;
        //Game controls
        private var _gameControls:Ctrl;
        //地图数组
        public var resourceWidth:int
        public var resourceHeight:int
        public var screenWidth:int = 1060;
        public var screenHeight:int = 860; //Old Value: 660px;
        public var nowTraceX:Number;
        public var nowTraceY:Number;
        
        public var bgRect:Rectangle;
        public var resourceBmd:BitmapData;
        public var screenBmd:BitmapData;
        public var bitmap:Bitmap;
        public var gameBg:Sprite;
        public var gameHitBg:Sprite;
        //碰撞检测地图
        public var hitTestBmd:BitmapData;
        
        public var widthNum:uint = 17;
        //地图纵排数
        public var heightNum:uint = 15;
        
        //格子横向宽
        public var rectWidth:Number = 20;
        //格子纵向宽
        public var rectHeight:Number = 20;
        public var BIAS_VALUE:int = 14;
        public var LINE_VALUE:int = 10;
        
        //地图数组
        public var mapArr:Array = new Array( widthNum )
        //每桢行动数组
        public var actionArr:Array;
        //特效数组
        public var effectArr:Array;
        //所有需要排列深度的数组
        public var objectArr:Array;
        //
        //客人数组
        public var babyArr:Array;
        //地图元素数组
        public var mapInforArr:Array;
        //屏幕中箱子数组
        public var objInScreenArr:Array;
        //可以接受攻击的数组
        public var can_clickArr:Array;
        //桌子数组
        public var tableArr:Array;
        //需要删除的数组
        public var removeArr:Array;
        
        public var immediateOpenBoxes:Array;
        
        public var resultsScrollCount:int;
        //地图移动==========================================
        public var mapSpeedX:Number;
        public var mapSpeedY:Number;
        //是否暂停中
        public var isPausing:Boolean;
        //是否可以通过
        public var can_pass:Boolean;
        //滤镜效果=======================================================
        public var redFilters:Array = [ new GlowFilter() ];
        public var whiteFilters:Array = [ new GlowFilter( 0xffffff, 1, 10, 10 ) ];
        public var greyFilters:Array = [ new ColorMatrixFilter([0.3086,0.6094,0.082,0,0,0.3086,0.6094,0.082,0,0,0.3086,0.6094,0.082,0,0,0,0,0,1,0]) ];
        //颜色效果
        //无效果
        public var initTrans:ColorTransform = new ColorTransform( 1, 1, 1, 1, 0, 0, 0, 0 )
        //白光
        public var whiteTrans:ColorTransform = new ColorTransform( 0, 0, 0, 1, 255, 255, 255, 0 );
        //红光
        public var redTrans:ColorTransform = new ColorTransform( 0, 0, 0, 1, 255, 0, 0, 0 );//new ColorTransform( 1, 0.85, 0.85, 1, 0, 0, 0, 0 );
        //蓝光
        public var blueTrans:ColorTransform = new ColorTransform( 0, 0, 0, 1, 0, 0, 102, 0 );//new ColorTransform( 0.6, 0.6, 0.6, 1, 0, 0, 100, 0 );
        //灰光
        
        public var greyTrans:ColorTransform = new ColorTransform( 0.4, 0.4, 0.4, 1, 0, 0, 0, 0 );
        //存储用======================================================================================================
        public var myShareObject:SharedObject;
        //按键--------------------------------
        public var A:uint = 65;
        public var S:uint = 83;
        public var W:uint = 87;
        public var D:uint = 68;
        public var J:uint = 74;
        public var K:uint = 75;
        public var L:uint = 76;
        public var space:uint = 32;
        public var ctrl:uint = 17;
        public var A2:uint = 37//65;
        public var S2:uint = 40//83;
        public var W2:uint = 38//87;
        public var D2:uint = 39//68;
        public var space2:uint = 97;
        public var ctrl2:uint = 98;
        public var AString:String = "A";
        public var SString:String = "S";
        public var WString:String = "W";
        public var DString:String = "D";
        public var JString:String = "J";
        public var KString:String = "K";
        public var LString:String = "L";
        public var leftCount:uint;
        public var rightCount:uint;
        //声音-------------------------------
        //用到的声音数
        public var channelNum:uint = 3;
        public var sndLoader:Loader = /*DocumentClass._mcLoader != null ? DocumentClass._mcLoader.loadersObj.soundLoader :*/ null;
        //背景音乐
        public var music:Sound = new Sound();
        public var musicChannel:SoundChannel = new SoundChannel();
        public var musicTrans:SoundTransform = new SoundTransform();
        //按钮声，主角挥拳声，主角开枪声
        public var sound:Sound = new Sound();
        public var soundChannel:SoundChannel = new SoundChannel();
        public var soundTrans:SoundTransform = new SoundTransform();
        //主角挥拳击打声
        public var sound1:Sound = new Sound();
        public var sound1Channel:SoundChannel = new SoundChannel();
        //敌人挥拳声
        public var sound2:Sound = new Sound();
        public var sound2Channel:SoundChannel = new SoundChannel();
        //其他特效声
        public var sound3:Sound = new Sound();
        public var sound3Channel:SoundChannel = new SoundChannel();
        //地图加载
        public var nowLoading:int;
        public var Loader1:Loader = new Loader();
        public var Loader2:Loader = new Loader();
        public var Loader3:Loader = new Loader();
        public var Loader4:Loader = new Loader();
        public var Loader5:Loader = new Loader();
        public var Loader6:Loader = new Loader();
        public var Loader7:Loader = new Loader();
        public var Loader8:Loader = new Loader();
        public var _loadPercentTxt:TextField;
        public var isPlay:Boolean;
        //分数
        public var current_score:Number = 0;
        //总分数
        public var total_score:Number = 0;
        //当前目标分数
        public var current_goal:Number = 0;
        public var leftMapLimit:Number = 0;
        public var rightMapLimit:Number = 0;
        //
        public var idIndex:uint;
        //
        public var clickObj:Array;
        //所有正确的地形块高度
        public var okHeightArr:Array = ["000", "010", "040", "050", "080", "101", "110", "120", "130", "165", "180", "200", "220", "235", "250", "280", "300", "350", "500" ];
        //敌人波数数组
        public var enemyTimeArr:Array = new Array( 30 );
        //当前所点击之物
        public var currentClickObj:*
        //发兵器
        public var creater:MonsterCreater;
        public var map:Map;
        public var can_click:Boolean;
        //FUTURE: is this suitable to be variable or const?
        public var upLine:Number = -45;
        
        public var Container_0:Sprite;
        public var Container_1:Sprite;
        public var Container_2:Sprite;
        public var Container_3:Sprite;
        public var Container_4:Sprite;
        public var Container_5:Sprite;
        public var Container_6:Sprite;
        public var Container_7:Sprite;
        public var Container_8:Sprite;
        public var Container_9:Sprite;
        public var Container_10:Sprite;
        public var Container_11:Sprite;
        public var Container_12:Sprite;
        public var Container_13:Sprite;
        public var Container_14:Sprite;
        public var Container_15:Sprite;
        public var Container_16:Sprite;
        public var playerArr:Array = [];
        public var playersAnswers:int;
        public var alivePlayers:int;
        public var bombArr:Array
        public var boxArr:Array;
        public var editData:Array;
        public var gameType:String = "";
        public var mapData:Array;
        public var playerBurnArr:Array;
        public var powerLv:uint;
        public var speedLv:uint;
        public var bombLv:uint;
        public var waterLv:uint;
        public var shieldLv:uint;
        public var coins:uint;
        public var bonus:uint;
        public var get_coins:uint;
        //游戏人数
        public var playerNum:uint;
        public var quality:String = "MEDIUM";
        public var mapObject:Object = new Object();
        
        public var listArr:Array;
        public var idArr:Array = [];
        private var _myId:uint;
        public var myName:String;
        public var personValue:uint;
        public var myRoom:Room;
        public var playersList:Array = [];
        
        //players
        public var playerInforArr:Array = [];
        public var playerNames:Array = [];
        public var infoScreenId:Array = [];
        
        public var myAvatar:int;
        public var randomAvatar:Boolean=true;
        public var randomPlayers:Array = [];
        
        public var endingState:Boolean=false;
        
        //location of other objects to generate
        public var otherPosition:Array = [];
        
        //chest position generated
        public var boxPosition1:Array = [];
        public var boxPosition2:Array = [];
        public var boxPosition3:Array = [];
        public var boxPosition4:Array = [];
        public var boxPosition5:Array = [];
        public var boxPosition6:Array = [];
        
        public var roundStarted:Boolean;
        public var roundOver:Boolean;
        public var roundRestart:Boolean;
        public var restartPlayers:int;
        
        public var powerDownNum:uint = 4;
        public var speedUpNum:uint = 11;
        public var powerUpNum:uint = 15;
        public var bombUpNum:uint = 15;
        public var speedDownNum:uint = 4;
        public var speicalBombNum:uint = 4;
        public var bombDownNum:uint = 4;
        public var maxPowerNum:uint = 2;
        public var mineNum:uint = 4;
        public var rocketNum:uint = 1;
        public var skullNum:uint = 2;
        public var dangerBombNum:uint = 2;
        public var goldNum:uint = 0;
        
        public var scores:Array = new Array();
        private var _mostTrophies:uint = 0;
        public var walkControls:Object = new Object();
        public var isMuted:Boolean = false;
        public var gameSeed:int;
        public var latencyValue:int = 0;
        public var diseaseManager:DiseaseManager;
        public var currentGameStatus:String;
        public var serverMessagesHandler:ServerMessagesHandler = new ServerMessagesHandler();
        public var userIds:Object = new Object();
        public var objectsMarks:Array = new Array();
        public var afterCharSelectStatus:Boolean;
        
        public var inWaitingList:Boolean = false;
        public var iAmSpectating:Boolean = false;
        
        public var gameObjectsContainer:GameObjectsContainer;
        
        private static var _instance:GameData;
        public var gameBox:DisplayObjectContainer;
        /**
         * Marks indicating objects are there. Used for testing purposes.
         */
        
        public var usableItemsManager:UsableItemsManager;
        
        public static function get instance():GameData {
            if(_instance == null){
                _instance = new GameData();
            }
            return _instance;
        }
        
        public static function newInstance():GameData {
            
            _instance = new GameData();
            GameData.instance.boxArr=null;
            return _instance;
        }
        
        public function dispose():void
        {
            usableItemsManager.reset();
            gameObjectsContainer = null;
            _instance = null;
        }
        
        public function initMapData(mapDescription:MapDescription):void
        {
            STAGE_MODE = mapDescription.mapName;
        }
        
        public function initData():void
        {
            gameStarted = false;
            time_left = 50;
            actionArr = [];
            effectArr = [];
            objectArr = [];
            removeArr = [];
            
            bombArr = [];
            boxArr = [];
            
            gameSeed = 0;
            
            immediateOpenBoxes = new Array();
            
            get_coins = 0;
            playerNum = 1;
            playersAnswers = 0;
            rematchTimer = 0;
            restartPlayers = 0;
            currentTick = 0;
            currentLocalTick = 0;
            
            afterCharSelectStatus = false;
            alreadyWinLose = false;
            isShowingMessage = false;
            isPausing = false;
            can_pass = false;
            roundStarted = false;
            roundOver = false;
            roundRestart = false;
            can_click = true;
            rematcher = false;
            isRematching = false;
            rematchFailed = false;
            rematchCountStarted = false;
            onSuddenDeath = false;
            
            rematcherName = "";
            
            firstTick = false;
            
            creater = null;
            currentMap = null;
            gameContainer = null;
            bgContainer = null;
            effectContainer = null;
            moveObjectContainer = null;
            bottomObjectContainer = null;
            personContainer = null; 
            topObjectContainer = null;
            _gameControls = null;
            map = null;
            currentClickObj = null;
            
            controlWho1 = null;
            controlWho2 = null;
            controlWho3 = null;
            controlWho4 = null;
            controlWho5 = null;
            controlWho6 = null;
            controlWho7 = null;
            controlWho8 = null;
            GAME_MODE = Config.mode;
            trophies = Config.trophies;
            round = Config.rounds;
            time = Config.time;
            suddenDeath = Config.suddenDeath;
            skulls = Config.skulls;
            userIds = new Object();
            
            var o:SFSObject = new SFSObject();
            o.putInt("time",time);
            o.putInt("rounds",round);
            o.putBool("suddenDeath",suddenDeath);
            o.putBool("skulls",skulls);
            if(!SmartFoxClientSingleton.getInstance().smartFoxClient.myself.isSpectatorInRoom(SmartFoxClientSingleton.getInstance().smartFoxClient.gameRoom))
            {
                SmartFoxClientSingleton.getInstance().smartFoxClient.sendExtensionRequestToGameRoom("setInitialProperties",o);
            }
            
            random_point = !Config.fixedPosition;
            burnableItems = Config.burnableItems;
            quality = Config.gameQuality;
            
            if(Scen.stage != null){
                Scen.stage.quality = quality;
            }
            
            for(var a:uint = 0; a < 16; a++)
            {
                GameData.instance["Container_" + String(a)] = null;
            }
            if(positionManager==null)
            {
                positionManager = new PositionManager();
            }
            if(bombManager==null)
            {
                bombManager = new BombManager();
            }
            
            if(!SmartFoxClientSingleton.getInstance().smartFoxClient.myself.isSpectatorInRoom(SmartFoxClientSingleton.getInstance().smartFoxClient.gameRoom) || 
                GameData.instance.gameSync){
                
                checkSoundVolume();
            }else{
                SoundClass.setmusicVolume(0);
                SoundClass.setsoundVolume(0);
            }
            
            usableItemsManager = new UsableItemsManager;
            usableItemsManager.addUsableItem();
        }
        
        public function checkSoundVolume():void{
            
            SoundClass.setmusicVolume(SoundSettings.getInstance().masterVolume * SoundSettings.getInstance().gameMusicVolume);
            SoundClass.setsoundVolume(SoundSettings.getInstance().masterVolume * SoundSettings.getInstance().gameSoundVolume);
        }
        
        public function SuperInit():void
        {
            total_level_num = 0;
            level_index = 1;
            
            otherPosition = [];
            boxPosition1 = [];
            boxPosition2 = [];
            boxPosition3 = [];
            boxPosition4 = [];
            boxPosition5 = [];
            boxPosition6 = [];
        }
        
        public function get myId():uint 
        {
            return _myId;
        }
        
        public function set myId(value:uint):void
        {
            _myId = value;
        }
        
        public function get winner():String
        {
            return _winner;
        }
        
        public function set winner(value:String):void
        {
            _winner = value;
        }
        
        public function get mostTrophies():uint
        {
            return _mostTrophies;
        }
        
        public function set mostTrophies(value:uint):void
        {
            _mostTrophies = value;
        }
        
        public function set currentRound(roundNumber:int):void
        {
            if(DEBUG_MODE)
            {
                trace("setting current round to " + roundNumber);
            }
            if(roundNumber == 0)
            {
                roundNumber = 1;
            }
            _currentRound = roundNumber;
        }

        public function get currentRound():int
        {
            return _currentRound;
        }
        
        /**
         * Game controls corresponding to the current player.
         */
        public function get controls():Ctrl
        {
            return _gameControls;
        }

        public function set controls(controls:Ctrl):void
        {
            _gameControls = controls;
        }
    }
}