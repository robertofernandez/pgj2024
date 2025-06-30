package com.gq.ui.endround
{
    import com.gq.ui.InGameUserListManager;
    import com.greensock.TweenMax;
    import com.willdom.games.bomberman.gameobjects.PersonScore;
    import com.willdom.games.bomberman.gameobjects.Score;
    import com.willdom.games.explodersmmo.shared.helpers.VectorHelper;
    
    import flash.display.MovieClip;
    import flash.display.Sprite;
    import flash.events.Event;

    public class EndRoundResultsScreen extends Sprite
    {
        private var texture:MC_InGameRoundResults;
        private var tweenShowRoundResults:TweenMax;
        private var roundScoresRowVector:Vector.<EndRoundResultsRowComponent>;
        private var sortedRoundScoresRowVector:Vector.<EndRoundResultsRowComponent>
        
        public function EndRoundResultsScreen()
        {
            texture = new MC_InGameRoundResults;
            roundScoresRowVector = new Vector.<EndRoundResultsRowComponent>;
            sortedRoundScoresRowVector = new Vector.<EndRoundResultsRowComponent>;
            
            texture.txtPlayers.text = LanguageManager.getInstance().getText("_players");
            texture.txtKills.text = LanguageManager.getInstance().getText("_killsB");
            texture.txtRoundPoints.text = LanguageManager.getInstance().getText("_roundScore");
            texture.txtTotalScore.text = LanguageManager.getInstance().getText("_totalScore");
            
            tweenShowRoundResults = new TweenMax(this, 1, {alpha: 1});
            tweenShowRoundResults.pause();
            
            addChild(texture);
        }
        
        public function showRoundResults():void
        {
            this.visible = true;
            this.alpha = 0;
            texture.txtTimer.text = LanguageManager.getInstance().getAndReplaceText("_gsRoundResultCountdownMessage", "%time%", "5");
            tweenShowRoundResults.play();
        }
        
        public function hideRoundResults():void
        {
            this.visible = false;
            this.alpha = 0;
            tweenShowRoundResults.restart();
            tweenShowRoundResults.pause();
        }
        
        public function fillTableData(positionsArray:Array):void
        {
            for(var i:int = 0; i < positionsArray.length; i++)
            {
                var personScore:PersonScore = positionsArray[i][0];
                createRow(personScore.userId, personScore.name, personScore.avatar, personScore.currentRoundScore, personScore.totalScorePoints, personScore.roundKills, i, personScore.currentScore, personScore.person == null);
            }
        }
        
        private function createRow(userId:int, username:String, userAvatar:int, currentRoundScore:int, totalScore:int, roundKills:int, position:int, scoreDetails:Score, left:Boolean):void
        {
            var userRoundResultRowIndex:int = searchUserRowByUserId(userId);
            var userRoundResultRow:EndRoundResultsRowComponent;
            
            if(userRoundResultRowIndex == -1)
            {
                userRoundResultRow = new EndRoundResultsRowComponent(userId, username, userAvatar, currentRoundScore, totalScore, roundKills, position, scoreDetails, left);
                roundScoresRowVector.push(userRoundResultRow);
            }
            else
            {
               userRoundResultRow = roundScoresRowVector[userRoundResultRowIndex];
               userRoundResultRow.updateRow(currentRoundScore, totalScore, roundKills, position, scoreDetails, left);
            }
        }
        
        public function showRows():void
        {
            var userRoundResultRow:EndRoundResultsRowComponent;
            sortedRoundScoresRowVector = Vector.<EndRoundResultsRowComponent>(VectorHelper.sortOn(roundScoresRowVector, "totalScore", Array.NUMERIC));
            sortedRoundScoresRowVector.reverse();
            
            for(var i:int = 0; i < roundScoresRowVector.length; i++)
            {
                if(roundScoresRowVector[i].parent != null)
                {
                    removeChild(roundScoresRowVector[i]);
                }
            }
            
            for(i = 0; i < roundScoresRowVector.length; i++)
            {
                userRoundResultRow = sortedRoundScoresRowVector[i];
                if(InGameUserListManager.getInstance().getRowByUserId(userRoundResultRow.userId) != null)
                {
                    userRoundResultRow.updatePosition(InGameUserListManager.getInstance().getRowByUserId(userRoundResultRow.userId).position.toString());
                }
                else
                {
                    userRoundResultRow.updatePosition("-");
                }
                
                if(i == 0)
                {
                    userRoundResultRow.x = 3;
                    userRoundResultRow.y = 129;
                }
                else
                {
                    userRoundResultRow.x = 3;
                    userRoundResultRow.y = sortedRoundScoresRowVector[i - 1].y + userRoundResultRow.texture.background.height;
                }
                addChild(userRoundResultRow);
            }
        }
        
        public function updateTimer(value:int):void
        {
            texture.txtTimer.text = LanguageManager.getInstance().getAndReplaceText("_gsRoundResultCountdownMessage", "%time%", value.toString()); 
        }
        
        public function dispose():void
        {
            removeAllRows();
            roundScoresRowVector.splice(0, roundScoresRowVector.length);
            roundScoresRowVector = null;
            sortedRoundScoresRowVector.splice(0, sortedRoundScoresRowVector.length);
            sortedRoundScoresRowVector = null;
        }
        
        
        private function removeAllRows():void
        {
            for(var i:int = 0; i < roundScoresRowVector.length; i++)
            {
                if(roundScoresRowVector[i].parent != null)
                {
                    removeChild(roundScoresRowVector[i]);
                }
                
                roundScoresRowVector[i] = null;
            }
        }
        
        private function searchUserRowByUserId(userId:int):int
        {
            for(var i:int = 0; i < roundScoresRowVector.length; i++)
            {
                if(roundScoresRowVector[i].userId == userId)
                {
                    return i;
                }
            }
            
            return -1;
        }
    }
}