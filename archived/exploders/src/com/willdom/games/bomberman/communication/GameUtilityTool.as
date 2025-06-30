package com.willdom.games.bomberman.communication
{
    import flash.display.MovieClip;

    public class GameUtilityTool
    {
        
        private static var stored:Array = new Array();
        
        public function GameUtilityTool()
        {
        }
        
        public static function addSharedContent(mc:Object):void
        {
            stored.push(mc);
        }
        
        public static function getStoredContent():Array
        {
            return stored.concat();    
        }
        
        public static function removeSharedContent(mc:Object):void
        {
            
            if (stored.indexOf(mc) > -1){
                stored.splice(stored.indexOf(mc), 1);
            }
            
        }
        
        public static function clearStorage():void
        {
            stored.splice();                        
        }
        
        public static function get amountComponents():int{
            
            return stored.length;
            
        }
        
    }
}