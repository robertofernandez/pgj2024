package com.willdom.games.bomberman.options
{
    import com.smartfoxserver.v2.entities.data.ISFSObject;
    import com.smartfoxserver.v2.entities.data.SFSObject;
        
    public class GameOptions extends SFSObject
    {
        public static var MAP_INDEX:String = "mapIndex";
        public static var MAX_PLAYERS:String = "maxPlayers";
        public static var OPTION_A:String = "opt1";
        public static var IS_PRIVATE:String = "isPrivate";
        public static var IS_FRIENDLY:String = "isFriendly";
        public static var FRIENDS_ONLY:String = "friendsOnly";
        public static var GAME_NAME:String = "gameName";
        public static var GAME_TYPE:String = "gameType";
        public static var SUPPORTED_TEAMS:String = "teams";
        public static var PASS:String = "pass";
        public static var DESC:String = "desc";
        
        public function GameOptions(data:ISFSObject=null)
        {
            super();
            
            if (data!=null)
            {
                mapIndex = data.getInt(MAP_INDEX);
                maxPlayers = data.getInt(MAX_PLAYERS);
                isPrivate = data.getBool(IS_PRIVATE);
                friendsOnly = data.getBool(FRIENDS_ONLY);
                gameName = data.getUtfString(GAME_NAME);
                gameType = data.getInt(GAME_TYPE);
                teams = data.getInt(SUPPORTED_TEAMS);
                pass = data.getUtfString(PASS);
                isFriendly = data.getBool(IS_FRIENDLY);
                
                var list:Array = new Array();
                
                if (data.getSFSArray(DESC)!=null)
                {                
                    for (var i:int=0;i<data.getSFSArray(DESC).size();i++)
                    {
                        list.push(  data.getSFSArray(DESC).getUtfString(i) );
                    }
                    
                    desc = list;
                    
                } else if (data.getUtfStringArray(DESC)!=null)
                {
                    desc = data.getUtfStringArray(DESC);
                }
                
                
            }
        }
        
        public function set mapIndex(value:int):void
        {
            this.putInt(MAP_INDEX,value);
        }
        
        public function get mapIndex():int
        {
            return this.getInt(MAP_INDEX);
        }
                    
        public function set maxPlayers(value:int):void
        {
            this.putInt(MAX_PLAYERS,value);
        }
        
        public function get maxPlayers():int
        {
            return this.getInt(MAX_PLAYERS);
        }
        
        public function set isPrivate(value:Boolean):void
        {
            this.putBool(IS_PRIVATE,value);
        }
        
        public function get isPrivate():Boolean
        {
            return this.getBool(IS_PRIVATE);
        }
        
        public function set optionA(value:String):void
        {
            this.putUtfString(OPTION_A,value);
        }
        
        public function get optionA():String
        {
            return this.getUtfString(OPTION_A);
        }
        
        public function set gameName(value:String):void
        {
            this.putUtfString(GAME_NAME,value);
        }
        
        public function get gameName():String
        {
            return this.getUtfString(GAME_NAME);
        }
        
        public function set friendsOnly(value:Boolean):void
        {
            this.putBool(FRIENDS_ONLY,value);
        }
        
        public function get friendsOnly():Boolean
        {
            return this.getBool(FRIENDS_ONLY);
        }
        
        public function set gameType(value:int):void
        {
            this.putInt(GAME_TYPE,value);
        }
        
        public function get gameType():int
        {
            return this.getInt(GAME_TYPE);
        }
        
        public function set teams(value:int):void
        {
            this.putInt(SUPPORTED_TEAMS,value);
        }
        
        public function get teams():int
        {
            return this.getInt(SUPPORTED_TEAMS);
        }
        
        public function set pass(value:String):void
        {
            this.putUtfString(PASS,value);
        }
        
        public function get pass():String
        {
            return this.getUtfString(PASS);
        }
        
        public function set desc(value:Array):void
        {
            this.putUtfStringArray(DESC,value);
        }
        
        public function get desc():Array
        {
            return this.getUtfStringArray(DESC);
        }
        
        public function set isFriendly(value:Boolean):void{
            this.putBool(IS_FRIENDLY,value);
        }
        
        public function get isFriendly():Boolean{
            return this.getBool(IS_FRIENDLY);
        }
        
    }
}