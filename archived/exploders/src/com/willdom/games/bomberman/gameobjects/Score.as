package com.willdom.games.bomberman.gameobjects
{
    import com.smartfoxserver.v2.entities.data.ISFSObject;
    import com.willdom.games.bomberman.consts.ServerMessages;

    public class Score{
        
        public var alive:Boolean = false;
        public var killsScore:int = 0;
        public var deathsScore:int = 0;
        public var itemPlusScore:int = 0;
        public var itemMinusScore:int = 0;
        public var positionPointsScore:int = 0;
        public var leaveScore:int = 0;
        
        public function Score(score:ISFSObject=null,a:Boolean=false){
            if(score!=null){
                killsScore = score.getInt(ServerMessages.KILLS_PARAM);
                deathsScore = score.getInt(ServerMessages.DEATHS_PARAM);
                itemPlusScore = score.getInt(ServerMessages.ITEMS_PLUS_PARAM);
                itemMinusScore = score.getInt(ServerMessages.ITEMS_MINUS_PARAM);
                positionPointsScore = score.getInt(ServerMessages.POSITION_POINTS_PARAM);
                leaveScore = score.getInt(ServerMessages.LEAVE_PARAM);
                alive = a;
                }
            }
        
        public function get totalScore():int{
            return killsScore + deathsScore + itemPlusScore + itemMinusScore + positionPointsScore + leaveScore;
        }
    }
}