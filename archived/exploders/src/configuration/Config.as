package configuration
{
    import com.smartfoxserver.v2.entities.data.ISFSArray;
    import com.smartfoxserver.v2.entities.data.SFSArray;
    import com.smartfoxserver.v2.entities.variables.RoomVariable;
    import com.willdom.games.bomberman.communication.SmartFoxClientSingleton;
    import com.willdom.games.bomberman.options.BombermanOptionsVars;
    import com.willdom.games.bomberman.options.GameOptions;
    import com.willdom.games.explodersmmo.shared.consts.GameRoomVars;
    
    public class Config{
        
        public static function get mode():String
        {
            
             return GameModes.DEFAULT;
            
        }
        
        public static function get gameQuality():String
        {
            return "HIGH";
        }
        
        public static function get trophies():Boolean
        {
            var roomVar:RoomVariable = SmartFoxClientSingleton.getInstance().smartFoxClient.gameRoom.getVariable(GameRoomVars.SETTINGS);
            
            if( roomVar==null ){
                return false;
            }else{
                return roomVar.getSFSObjectValue().getBool(GameRoomVars.TROPHIES);
            }
        }
        
        public static function get rounds():uint
        {
            var roomVar:RoomVariable = SmartFoxClientSingleton.getInstance().smartFoxClient.gameRoom.getVariable(GameRoomVars.SETTINGS);
            
            if(roomVar==null){
                return BombermanOptionsVars.DEFAULT_ROUNDS;
            }else{
                return roomVar.getSFSObjectValue().getInt(GameRoomVars.ROUNDS);
            }
            
        }
        
        public static function get time():uint
        {
            var roomVar:RoomVariable = SmartFoxClientSingleton.getInstance().smartFoxClient.gameRoom.getVariable(GameRoomVars.SETTINGS);
            if(roomVar==null){
                return 90;
            }else{
                return roomVar.getSFSObjectValue().getInt(GameRoomVars.ROUNDS_TIME);
            }
        }
        
        public static function get fixedPosition():Boolean
        {
            var roomVar:RoomVariable = SmartFoxClientSingleton.getInstance().smartFoxClient.gameRoom.getVariable(GameRoomVars.SETTINGS);
            if(roomVar==null ){
                return false;
            }else{
                return roomVar.getSFSObjectValue().getBool(GameRoomVars.FIXED_POSITIONS);
            }
        }
        
        public static function get map():String
        {
            var roomVar:RoomVariable = SmartFoxClientSingleton.getInstance().smartFoxClient.gameRoom.getVariable(GameRoomVars.SETTINGS);
            if(roomVar==null ){
                return StageModes.DEFAULT;
            }else{
                return roomVar.getSFSObjectValue().getUtfString(GameRoomVars.MAP);
            }
        }

        public static function get burnableItems():Boolean
        {
            var roomVar:RoomVariable = SmartFoxClientSingleton.getInstance().smartFoxClient.gameRoom.getVariable(GameRoomVars.SETTINGS);
            if(roomVar == null)
            {
                return true;
            }
            else
            {
                return roomVar.getSFSObjectValue().getBool(GameRoomVars.BURNABLE_ITEMS);
            }
        }
        
        public static function get suddenDeath():Boolean
        {
            var roomVar:RoomVariable = SmartFoxClientSingleton.getInstance().smartFoxClient.gameRoom.getVariable(GameRoomVars.SETTINGS);
            
            if(roomVar == null){
                return true;
            }else{
                return roomVar.getSFSObjectValue().getBool(GameRoomVars.SUDDEN_DEATH);
            }
        }
        
        public static function get skulls():Boolean
        {
            var roomVar:RoomVariable = SmartFoxClientSingleton.getInstance().smartFoxClient.gameRoom.getVariable(GameRoomVars.SETTINGS);
            
            if(roomVar == null){
                return true;
            }else{
                return roomVar.getSFSObjectValue().getBool(GameRoomVars.SKULLS);
            }
        }
    }
}