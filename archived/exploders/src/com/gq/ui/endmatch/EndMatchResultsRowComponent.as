package com.gq.ui.endmatch
{
    import com.willdom.games.bomberman.communication.SmartFoxClientSingleton;
    
    import flash.display.Sprite;

    public class EndMatchResultsRowComponent extends Sprite
    {
        private var _texture:MC_InGameEndResultsRowComponent;
        
        private var _userId:int;
        private var _username:String;
        
        public function EndMatchResultsRowComponent(userId:int, username:String, userAvatar:int, matchScore:int, oldSkillpoints:int, skillpointsGained:int, newSkillpoints:int, position:int, left:Boolean)
        {
            _userId = userId;
            _username = username;
            
            _texture = new MC_InGameEndResultsRowComponent;
            _texture.txtUsername.text = username;
            _texture.txtMatchScore.text = matchScore.toString();
            _texture.txtOldSkillpoints.text = oldSkillpoints.toString();
            _texture.txtPointsThisRound.text = skillpointsGained.toString();
            _texture.txtNewSkillpoints.text = newSkillpoints.toString();
            
            _texture.iconAvatar.gotoAndStop("avatar" + userAvatar.toString());
            _texture.iconUserLeft.visible = false;
            _texture.iconFlags.visible = false;
            _texture.iconStatus.visible = false;
            _texture.userExitOverlay.visible = false;
            
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
                _texture.txtMatchScore.textColor = 0xFFFFFF;
                _texture.txtOldSkillpoints.textColor = 0xFFFFFF;
                _texture.txtPointsThisRound.textColor = 0xFFFFFF;
                _texture.txtNewSkillpoints.textColor = 0xFFFFFF;
                _texture.background.gotoAndStop("myself");
            }
            
            if(left)
            {
                onUserExit();
            }
            else
            {
                statusChangedPlaying();
            }
            
            addChild(_texture);
        }
        
        public function updatePosition(position:String):void
        {
            _texture.txtPosition.text = position;
        }
        
        public function onUserExit():void
        {
            _texture.txtPosition.alpha = 0.5;
            _texture.txtUsername.alpha = 0.5;
            _texture.txtMatchScore.alpha = 0.5;
            _texture.txtOldSkillpoints.alpha = 0.5;
            _texture.txtPointsThisRound.alpha = 0.5;
            _texture.txtNewSkillpoints.alpha = 0.5;
            _texture.iconUserLeft.alpha = 0.5;
            _texture.iconStatus.visible = false;
            _texture.iconUserLeft.visible = true;
            _texture.userExitOverlay.visible = true;
        }
        
        public function statusChangedPlaying():void
        {
            _texture.iconStatus.visible = true;
            _texture.iconStatus.gotoAndStop("playing");
            
            if(userId == SmartFoxClientSingleton.getInstance().smartFoxClient.myself.id)
            {
                _texture.iconStatus.icon.gotoAndStop("myself");
            }
            else
            {
                _texture.iconStatus.icon.gotoAndStop("other");
            }
        }
        
        public function statusChangedSpectating():void
        {
            _texture.iconStatus.visible = true;
            _texture.iconStatus.gotoAndStop("paused");
            
            if(userId == SmartFoxClientSingleton.getInstance().smartFoxClient.myself.id)
            {
                _texture.iconStatus.icon.gotoAndStop("myself");
            }
            else
            {
                _texture.iconStatus.icon.gotoAndStop("other");
            }
        }
        
        public function get userId():int
        {
            return _userId;
        }
        
        public function get username():String
        {
            return _username;
        }
        
        public function get texture():MC_InGameEndResultsRowComponent
        {
            return _texture;
        }
    }
}