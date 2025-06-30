package com.willdom.games.bomberman.config
{
    import com.smartfoxserver.v2.entities.User;
    
    import flash.display.DisplayObject;
    import flash.display.Sprite;
    import flash.events.EventDispatcher;
    
    import mx.core.mx_internal;
    
    //[Event(name="event", type="event.class")]
    public class GameConfigManager extends EventDispatcher
    {        
        protected static var _instance:GameConfigManager;
        
        public static var CUSTOM_GAME:String = "CustomGame";
        public static var MATCHMAKING:String = "Matchmaking";
        public static var REMATCH:String = "Rematch";
        
        public var gamePrefix:String = "";
        
        public var sharedData:XML;
        public var sharedLanguage:String = "";
        public var sharedZone:String = "Speeleiland Lobby";
        public var sharedDomain:String = "www.speeleiland.nl";
        public var sharedGame:int = -1;
        public var sharedSfsConfig:String = "sfs-config.xml";
        
        public var rematchsStarted:int = 0;
        public var matchmakingsStarted:int = 0;
        
        public var typeOfGame:String;
        
        public var loadedSWF:Object;
        public var options:Object;
        private var variables:Array;
        
        public var showingChat:Boolean = false;
        
        public var isRematching:Boolean=false;
        public var loaderUrl:String = "";
        
        public var challengeInviterName:String = "";
        public var challengeInviteeName:String = "";
        
        private var _extendedContainer:Boolean = true;
        
        public function GameConfigManager(caller :Function = null)
        {
            if (caller != GameConfigManager.getInstance)
            {
                throw new Error ("GameConfigManager is a singleton class, use getInstance() instead");
            }
            
            if ( GameConfigManager._instance != null )
            {
                throw new Error( "Only one GameConfigManager instance should be instantiated" );
            } 
            
            //init();
        }
        
        public function get extendedContainer():Boolean{ return _extendedContainer; }
        public function set extendedContainer(value:Boolean):void{
            _extendedContainer = value;
            /*TODO: REMOVE THIS EVENT OF EXTENDED CONTAINER AND CHECK NEED OF A NEW ONE
            var e:LobbyComunicationEvent = new LobbyComunicationEvent( LobbyComunicationEvent.EXTEND_CONTAINER);
            e.response = value;
            dispatchEvent(e);
            */
        }
        
        private function init():void
        {
            variables = new Array();
        }
        
        
        public function saveVariable(index:int,value:Object):void
        {
            variables[index] = value; 
        }
        
        public function getVariable(index:int):Object
        {
            if (variables.hasOwnProperty(index))
                return variables[index];
            
            return null;
        }
        
        public function resetVariables():void{
            variables = new Array();
        }
        
        public static function getInstance():GameConfigManager        
        {
            if (_instance == null)
            {
                _instance = new GameConfigManager(arguments.callee);
                _instance.init();
            }
            return _instance;    
        }
        
        
        
    }
}