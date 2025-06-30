package com.willdom.games.bomberman.gameobjects.items
{
    import com.gq.system.GameSys;
    import com.smartfoxserver.v2.entities.SFSUser;
    import com.willdom.games.bomberman.communication.SmartFoxClientSingleton;
    import com.willdom.games.bomberman.gameobjects.PersonScore;
    import com.willdom.games.bomberman.rooms.RoomLocalProperties;
    import com.willdom.games.bomberman.user.UserLocalProperties;
    
    public class JoiningPlayer
    {
        private var _skillPoints:String;
        private var _name:String;
        public var status:Boolean;
        private static var allJoiningPlayers:Array = null;
        
        
        public static function createFakePlayer(x:int):void{
            
            for (var i:uint = 0; i < x; i++){
                allJoiningPlayers.push(new JoiningPlayer("Toga " + i, false, "I'm fake"));
            }
        }
        
        public static function stopRecord():void{
            allJoiningPlayers = null;
        }
        
        public static function startRecord():void{
            allJoiningPlayers = new Array();
        }
        
        public function JoiningPlayer(name:String, status:Boolean = true, skillPoints:String = "NA")
        {
            _name = name;
            this.status = status;
            _skillPoints = skillPoints;
        }

        public static function updateJoiningPlayers():void
        {
            
            var freeSeats:int = SmartFoxClientSingleton.getInstance().smartFoxClient.gameRoom.maxUsers - GameSys.getRematchCount();
            
            allJoiningPlayers.splice(0);
            
            var playerInRoom:SFSUser;
            
            var userList:Array = (SmartFoxClientSingleton.getInstance().smartFoxClient.gameRoom.properties as RoomLocalProperties).waitingList;
            
            for (var i:uint = 0; i < userList.length; i++)
            {
                if (i < freeSeats)
                {
                    allJoiningPlayers.push(new JoiningPlayer(userList[i].name, true, (userList[i].properties as UserLocalProperties).pointsStr));
                } 
                else 
                {
                    allJoiningPlayers.push(new JoiningPlayer(userList[i].name, false, (userList[i].properties as UserLocalProperties).pointsStr));
                }
            }    
        }
        
        public function get skillPoints():String
        {
            return _skillPoints;
        }
        
        public function get name():String
        {
            return _name;
        }
        
        public static function getJoiningPlayers():Array{
            return allJoiningPlayers;
        }
        
        public static function getJoiningPlayerByName(playerName:String):JoiningPlayer
        {
            for each (var player:JoiningPlayer in allJoiningPlayers)
            {
                if (player.name == playerName){
                    return player;
                }
            }
            
            return null;
        }
        
    }
}