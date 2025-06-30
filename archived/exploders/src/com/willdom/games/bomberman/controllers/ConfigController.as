package com.willdom.games.bomberman.controllers
{
    public class ConfigController
    {
        protected static var _instance:ConfigController;
        public var gameTestingMode:Boolean = false;
        public var allowRankedGames:Boolean = true;

        public function ConfigController(caller:Function = null)
        {
            if (caller != ConfigController.getInstance)
            {
                throw new Error ("ConfigController is a singleton class, use getInstance() instead");
            }
            
            if ( ConfigController._instance != null )
            {
                throw new Error( "Only one ConfigController instance should be instantiated" );
            } 
            
            //init();
        }
        
        private function init():void
        {
            
        }
        
        public static function getInstance():ConfigController        
        {
            if (_instance == null)
            {
                _instance = new ConfigController(arguments.callee);
                _instance.init();
            }
            return _instance;    
        }
        
    }
}