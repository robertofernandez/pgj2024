package com.gq.ui.endmatch
{
    import com.gq.system.GameData;
    import com.gq.ui.InGameUserListManager;
    import com.greensock.TweenMax;
    import com.willdom.games.bomberman.communication.SmartFoxClientSingleton;
    import com.willdom.games.bomberman.gameobjects.PersonScore;
    import com.willdom.games.bomberman.rooms.RoomLocalProperties;
    import com.willdom.games.bomberman.user.UserLocalProperties;
    import com.willdom.games.explodersmmo.shared.consts.GameRoomVars;
    import com.willdom.games.explodersmmo.shared.ui.CustomButton;
    
    import flash.display.Sprite;
    import flash.events.MouseEvent;

    public class EndMatchResultsScreen extends Sprite
    {
        private var texture:MC_InGameEndResults
        private var tweenShowEndResultsScreen:TweenMax;
        private var matchScoresRowVector:Vector.<EndMatchResultsRowComponent>;
        private var dataFilled:Boolean;
        
        private var btnSpectate:CustomButton;
        private var btnJoinWaitingList:CustomButton;
        
        public function EndMatchResultsScreen()
        {
            texture = new MC_InGameEndResults;
            matchScoresRowVector = new Vector.<EndMatchResultsRowComponent>;
            dataFilled = false;
            
            texture.txtPlayers.text = LanguageManager.getInstance().getText("_players");
            texture.txtMatchScore.text = LanguageManager.getInstance().getText("_matchScore");
            texture.txtMatchScore.y = texture.txtMatchScore.y + Math.floor((texture.txtMatchScore.height - texture.txtMatchScore.textHeight) / 2);
            texture.txtOldSkillpoints.text = LanguageManager.getInstance().getText("_oldSkillPoints");
            texture.txtPointsThisRound.text = LanguageManager.getInstance().getText("_difference");
            texture.txtNewSkillpoints.text = LanguageManager.getInstance().getText("_newSkillPoints");
            
            tweenShowEndResultsScreen = new TweenMax(this, 1, {alpha: 1});
            tweenShowEndResultsScreen.play();
            
            btnSpectate = new CustomButton(texture.spectateBtn);
            btnJoinWaitingList = new CustomButton(texture.playBtn);
            
            btnSpectate.addEventListener(MouseEvent.CLICK, onSpectateButtonEvent, false, 0, true);
            btnJoinWaitingList.addEventListener(MouseEvent.CLICK, onJoinWaitingListEvent, false, 0, true);
            
            addChild(texture);
        }
        
        public function showEndResultsScreen(timeTick:int):void
        {
            if(SmartFoxClientSingleton.getInstance().smartFoxClient.myself.isSpectator || SmartFoxClientSingleton.getInstance().smartFoxClient.myself.isGuest())
            {
                texture.levelProgressionBar.visible = false;
                texture.txtTimer.y = 40;
            }
            texture.txtTimer.text = LanguageManager.getInstance().getAndReplaceText("_gsEndResultCountdownMessage", "%time%", timeTick.toString()); 
            
            this.visible = true;
            this.alpha = 0;
            
            if(GameData.instance.inWaitingList)
            {
                btnSpectate.enable();
                btnJoinWaitingList.disable();
                texture.txtDescription.text = LanguageManager.getInstance().getText("_youWillPlay");
            }
            else
            {
                btnSpectate.disable();
                btnJoinWaitingList.enable();
                texture.txtDescription.text = LanguageManager.getInstance().getText("_youWillSpectate");
            }
            
            showRows();
            tweenShowEndResultsScreen.play();
        }
        
        public function hideEndResultsScreen():void
        {
            this.visible = false;
            this.alpha = 0;
            tweenShowEndResultsScreen.restart();
            tweenShowEndResultsScreen.pause();
        }
        
        public function fillTableData(positionsArray:Array):void
        {
            if(!dataFilled)
            {
                for(var i:int = 0; i < positionsArray.length; i++)
                {
                    var personScore:PersonScore = positionsArray[i][0];
                    createRow(personScore.userId, personScore.name, personScore.avatar, personScore.totalScorePoints,
                              personScore.currentSkillPoints - personScore.difference, personScore.difference, personScore.currentSkillPoints,
                              i, personScore.person == null);
                }  
                
                dataFilled = true;
            }
        }
        
        private function createRow(userId:int, username:String, userAvatar:int, matchScore:int, oldSkillpoints:int, skillpointsGained:int, newSkillpoints:int, position:int, left:Boolean):void
        {
            var userMatchResultRow:EndMatchResultsRowComponent;

            userMatchResultRow = new EndMatchResultsRowComponent(userId, username, userAvatar, matchScore, oldSkillpoints, skillpointsGained, newSkillpoints,position, left);
            matchScoresRowVector.push(userMatchResultRow);
        }
        
        private function showRows():void
        {
            var userRoundResultRow:EndMatchResultsRowComponent;
            
            for(var i:int = 0; i < matchScoresRowVector.length; i++)
            {
                userRoundResultRow = matchScoresRowVector[i];
                if(InGameUserListManager.getInstance().getRowByUsername(userRoundResultRow.username) != null)
                {
                    userRoundResultRow.updatePosition(InGameUserListManager.getInstance().getRowByUsername(userRoundResultRow.username).position.toString());
                }
                else
                {
                    userRoundResultRow.updatePosition("-");
                }
                
                if(i == 0)
                {
                    userRoundResultRow.x = 3;
                    userRoundResultRow.y = 169;
                }
                else
                {
                    userRoundResultRow.x = 3;
                    userRoundResultRow.y = matchScoresRowVector[i - 1].y + userRoundResultRow.texture.background.height;
                }
                addChild(userRoundResultRow);
            }
        }
        
        public function dispose():void
        {
            removeAllRows();
            dataFilled = false;
            matchScoresRowVector.splice(0, matchScoresRowVector.length);
            matchScoresRowVector = null;
        }
        
        public function updateTimer(value:int):void
        {
            texture.txtTimer.text = LanguageManager.getInstance().getAndReplaceText("_gsEndResultCountdownMessage", "%time%", value.toString()); 
        }
        
        
        private function removeAllRows():void
        {
            for(var i:int = 0; i < matchScoresRowVector.length; i++)
            {
                if(matchScoresRowVector[i].parent != null)
                {
                    removeChild(matchScoresRowVector[i]);
                }
                
                matchScoresRowVector[i] = null;
            }
        }
        
        private function searchUserRowByUserId(userId:int):int
        {
            for(var i:int = 0; i < matchScoresRowVector.length; i++)
            {
                if(matchScoresRowVector[i].userId == userId)
                {
                    return i;
                }
            }
            
            return -1;
        }
        
        private function onSpectateButtonEvent(event:MouseEvent = null):void
        {
            InGameUserListManager.getInstance().onSpectateButtonClick(event);
        }
        
        private function onJoinWaitingListEvent(event:MouseEvent = null):void
        {
            InGameUserListManager.getInstance().onWaitingButtonClick(event);
        }
        
        public function onSpectateButtonClicked():void
        {
            btnSpectate.disable();
            btnJoinWaitingList.enable();
            texture.txtDescription.text = LanguageManager.getInstance().getText("_youWillSpectate");
        }
        
        public function onJoinWaitingListClicked():void
        {
            btnSpectate.enable();
            btnJoinWaitingList.disable();
            texture.txtDescription.text = LanguageManager.getInstance().getText("_youWillPlay");
        }
        
        public function onPlayerDeclinedRematch(userId:int):void
        {
            var index:int = searchUserRowByUserId(userId);
            
            if(index != -1)
            {
                matchScoresRowVector[index].statusChangedSpectating();
            }
        }
        
        public function onPlayerAcceptedRematch(userId:int):void
        {
            var index:int = searchUserRowByUserId(userId);
            
            if(index != -1)
            {
                matchScoresRowVector[index].statusChangedPlaying();
            }
        }
        
        public function onUserExit(userId:int):void
        {
            var index:int = searchUserRowByUserId(userId);
            
            if(index != -1)
            {
                matchScoresRowVector[index].onUserExit();
            }
        }
    }
}