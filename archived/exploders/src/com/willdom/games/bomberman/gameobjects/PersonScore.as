package com.willdom.games.bomberman.gameobjects{
    import com.gq.moveobject.Person;
    import com.gq.system.GameData;
    import com.gq.system.GameSys;
    import com.greensock.events.LoaderEvent;
    import com.smartfoxserver.v2.entities.User;
    import com.willdom.games.bomberman.communication.SmartFoxClientSingleton;
    import com.willdom.games.bomberman.user.UserLocalProperties;
    import com.willdom.util.helpers.EventListenerManager;
    
    import flash.display.Bitmap;
    import flash.display.DisplayObject;
    import flash.display.Loader;
    import flash.display.LoaderInfo;
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.events.SecurityErrorEvent;
    import flash.net.URLRequest;

    public class PersonScore{
        
        public var userId:uint;
        private var _name:String;
        public var avatar:uint;
        public var person:Person;
        public var currentScore:Score = new Score();
        public var totalScore:Score = new Score();
        public var ranking:int = 0;
        public var isRegistered:Boolean = false;
        public var currentSkillPoints:int = 0;
        public var currentTrophies:uint = 0;
        public var totalTrophies:uint = 0;
        public var deathPosition:uint = 0;
        public var roundKills:uint = 0;
        public var totalKills:uint = 0;
        public var roundDeaths:uint = 0;
        public var totalDeaths:uint = 0;
        public var totalPositiveItems:uint = 0;
        public var totalNegativeItems:uint = 0;
        public var roundPositiveItems:uint = 0;
        public var roundNegativeItems:uint = 0;
        public var difference:int = 0;
        public var playerAvatar:Bitmap = new Bitmap();
        
        public function PersonScore(p:Person){
            
            person = p;
        }
        
        public static function getPersonScoreByName(personName:String):PersonScore{
                        
            for each (var thisScore:PersonScore in GameData.instance.scores)
            {
                if (thisScore.name == personName)
                {
                    return thisScore;
                }
            }
            return null;
        }
        
        public function loadFullAvatar():void{
            
            var myUser:User = SmartFoxClientSingleton.getInstance().smartFoxClient.getPlayerByName(name);
            var avatarUrl:URLRequest = new URLRequest((myUser.properties as UserLocalProperties).fullAvatar);    
            var avatarLoader:Loader = new Loader();
            
            EventListenerManager.setListenerTo(avatarLoader.contentLoaderInfo, Event.COMPLETE, onAvatarLoaded);
            EventListenerManager.setListenerTo(avatarLoader.contentLoaderInfo, IOErrorEvent.IO_ERROR, onLoaderError);
            EventListenerManager.setListenerTo(avatarLoader.contentLoaderInfo, SecurityErrorEvent.SECURITY_ERROR, onLoaderError);
            
            //avatarLoader.load(avatarUrl);
            
        }
        
        private function onLoaderError(e:Event):void{
            trace('BBM: Error loading avatar');
        }
        
        private function onAvatarLoaded(e:Event):void{
            
            this.playerAvatar = ((e.currentTarget as LoaderInfo).content as Bitmap);
            
        }
        
        public function get currentRoundScore():int{
            return currentScore.totalScore;
        }
        
        public function get totalScorePoints():int{
            return totalScore.totalScore;
        }    

        public function get name():String
        {
            return _name;
        }

        public function set name(value:String):void
        {
            _name = value;
            
            var inList:Boolean = false;
            for each(var u:User in SmartFoxClientSingleton.getInstance().smartFoxClient.gameRoom.playerList)
            {
                if(u.name == _name)
                {
                    inList = true;
                    break;
                }
            }
            
            if(!inList)
            {
                totalScore.leaveScore += GameData.instance.leaveScoreReduction;
            }
        }

    }
}