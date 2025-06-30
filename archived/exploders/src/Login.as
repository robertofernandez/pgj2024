package
{
    import com.gq.system.*;
    import com.smartfoxserver.v2.entities.Room;
    import com.smartfoxserver.v2.entities.User;
    
    import fl.controls.*;
    
    import flash.display.DisplayObjectContainer;
    import flash.display.MovieClip;
    import flash.display.Sprite;
    import flash.events.MouseEvent;
    
    import com.willdom.games.bomberman.communication.SmartFoxClientSingleton;
    import com.willdom.games.bomberman.events.MessageEvent;

    public class Login extends Sprite
    {
        private static var _instance:Login;
        
        private var container:DisplayObjectContainer;
        private var playersNames:Array=new Array();
        
        private var _remoteSeed:int;
        
        public static function getInstance(which:DisplayObjectContainer=null):Login{
            if(_instance==null){
                _instance=new Login(which);
            }
            return _instance;
        }
        
        public static function newInstance(which:DisplayObjectContainer=null):Login
        {
            
            _instance = new Login(which);
            
            return _instance;
        }
        
        public function set remoteSeed(r:int):void{
            _remoteSeed=r;
        }

        public function Login( which:DisplayObjectContainer ):void
        {
            container = which;
            loginSuccess(SmartFoxClientSingleton.getInstance().smartFoxClient.myself.name);
        }

        private function loginSuccess( who:String ):void
        {
            if(GameData.DEBUG_MODE)
            {
                trace("[Login] player logged: " + who );
            }

            sendNewScore();
            GameData.instance.Scen = container;
            GameData.instance.Scen.stage.showDefaultContextMenu = false;
            GameSys.createGame();
        }

        public function sendNewScore():void
        {
            GameData.instance.myRoom = SmartFoxClientSingleton.getInstance().smartFoxClient.gameRoom;
            
            for each(var playerName:String in GameData.instance.playersList){
                
                    playersNames.push(playerName);
            }

            playersNames.sort();
        }
        
        public function fillPlayersArray(charactersQty:uint):void{
            var person:uint = _remoteSeed;
            var playerId:int;
            var tmpArray:Array = new Array();
            
            for each(var playerName:String in GameData.instance.playersList){
                tmpArray.push(playerName);
            }
            
            tmpArray.sort();
            
            for each(var name:String in tmpArray){
                if(name==SmartFoxClientSingleton.getInstance().smartFoxClient.myself.name){
                    GameData.instance.myId = playersNames.indexOf(SmartFoxClientSingleton.getInstance().smartFoxClient.myself.name);
                    GameData.instance.myAvatar = person;
                }else{
                    GameData.instance.playerNum ++;
                }
                playerId = playersNames.indexOf(name);
                GameData.instance.playerNames.push(name);
                GameData.instance.playerInforArr.push([playerId, person]);
                GameData.instance.idArr.push(playerId);
                GameData.instance.totalPlayers++;
                
                person++;
                
                if(GameData.instance.myId == 0 && person == GameData.instance.playerInforArr[0][1]){
                    person++;
                }
                
                if(person>charactersQty){
                    person=1;    
                }
            }
            GameData.instance.myName = SmartFoxClientSingleton.getInstance().smartFoxClient.myself.name;
        }
        
        public static function deleteInstance():void{
            
            _instance = null;
            
        }

    }
}