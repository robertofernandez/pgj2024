package com.gq.ui.endround
{
    import com.willdom.games.bomberman.communication.SmartFoxClientSingleton;
    import com.willdom.games.bomberman.gameobjects.Score;
    
    import flash.display.Sprite;
    import flash.events.MouseEvent;

    public class EndRoundResultsRowComponent extends Sprite
    {
        private var _texture:MC_InGameRoundResultsRowComponent;
        
        private var _userId:int;
        private var _totalScore:int;
        
        public function EndRoundResultsRowComponent(userId:int, username:String, userAvatar:int, currentRoundScore:int, totalScore:int, roundKills:int, position:int, scoreDetails:Score, left:Boolean)
        {
            _userId = userId;
            _totalScore = totalScore;
            
            _texture = new MC_InGameRoundResultsRowComponent;
            _texture.txtUsername.text = username;
            _texture.txtKills.text = roundKills.toString();
            _texture.txtRoundScore.text = currentRoundScore.toString();
            _texture.txtTotalScore.text = totalScore.toString();
            
            _texture.iconAvatar.gotoAndStop("avatar" + userAvatar.toString());
            _texture.iconUserLeft.visible = false;
            _texture.iconFlags.visible = false;
            _texture.userExitOverlay.visible = false;
            _texture.roundResultsDetail.visible = false;
            
            _texture.roundResultsDetail.txtKillsPlus.text = LanguageManager.getInstance().getText("_killsB");
            _texture.roundResultsDetail.txtKillsCons.text = LanguageManager.getInstance().getText("_deathsB");
            _texture.roundResultsDetail.txtItemsPlus.text = LanguageManager.getInstance().getText("_positiveItems");
            _texture.roundResultsDetail.txtItemsCons.text = LanguageManager.getInstance().getText("_negativeItems");
            updateRoundDetails(scoreDetails);
            
            if(position % 2 != 0)
            {
                _texture.background.gotoAndStop("empty");
            }
            else
            {
                _texture.background.gotoAndStop("filled");
            }
            
            if(userId == SmartFoxClientSingleton.getInstance().smartFoxClient.myself.id)
            {
                _texture.txtPosition.textColor = 0xFFFFFF;
                _texture.txtUsername.textColor = 0xFFFFFF;
                _texture.txtKills.textColor = 0xFFFFFF;
                _texture.txtRoundScore.textColor = 0xFFFFFF;
                _texture.txtTotalScore.textColor = 0xFFFFFF;
                _texture.background.gotoAndStop("myself");
            }
            
            if(left)
            {
                onUserExit();
            }
            
            addEventListener(MouseEvent.ROLL_OVER, onMouseRollOver, false,0 , true);
            addEventListener(MouseEvent.ROLL_OUT, onMouseRollOut, false, 0, true);
            
            addChild(_texture);
        }
        
        public function updateRow(currentRoundScore:int, totalScore:int, roundKills:int, position:int, scoreDetails:Score, left:Boolean):void
        {
            _totalScore = totalScore;
            
            _texture.txtKills.text = roundKills.toString();
            _texture.txtRoundScore.text = currentRoundScore.toString();
            _texture.txtTotalScore.text = totalScore.toString();
            updateRoundDetails(scoreDetails);
            
            if(position % 2 != 0)
            {
                _texture.background.gotoAndStop("empty");
            }
            else
            {
                _texture.background.gotoAndStop("filled");
            }
            if(userId == SmartFoxClientSingleton.getInstance().smartFoxClient.myself.id)
            {
                _texture.background.gotoAndStop("myself");
            }
            
            if(left)
            {
                onUserExit();
            }
        }
        
        public function updatePosition(position:String):void
        {
            _texture.txtPosition.text = position;
        }
        
        private function onUserExit():void
        {
            _texture.txtPosition.alpha = 0.5;
            _texture.txtUsername.alpha = 0.5;
            _texture.txtKills.alpha = 0.5;
            _texture.txtRoundScore.alpha = 0.5;
            _texture.txtTotalScore.alpha = 0.5;
            _texture.iconUserLeft.alpha = 0.5;
            _texture.iconUserLeft.visible = true;
            _texture.userExitOverlay.visible = true;
        }
        
        private function updateRoundDetails(scoreDetails:Score):void
        {
            _texture.roundResultsDetail.txtKillsPlusValue.text = scoreDetails.killsScore;
            _texture.roundResultsDetail.txtKillsConsValue.text = scoreDetails.deathsScore;
            _texture.roundResultsDetail.txtItemsPlusValue.text = scoreDetails.itemPlusScore;
            _texture.roundResultsDetail.txtItemsConsValue.text = scoreDetails.itemMinusScore;
        }
        
        private function onMouseRollOver(event:MouseEvent):void
        {
            _texture.roundResultsDetail.visible = true;   
        }
        
        private function onMouseRollOut(event:MouseEvent):void
        {
            _texture.roundResultsDetail.visible = false;
        }
        
        public function get texture():MC_InGameRoundResultsRowComponent
        {
            return _texture;
        }
        
        public function get userId():int
        {
            return _userId;
        }
        
        public function get totalScore():int
        {
            return _totalScore;
        }
    }
}