package com.gq.ui
{
    import com.smartfoxserver.v2.entities.User;
    import com.willdom.games.bomberman.communication.SmartFoxClient;
    import com.willdom.games.bomberman.communication.SmartFoxClientSingleton;
    import com.willdom.games.bomberman.consts.PlayerVars;
    import com.willdom.games.bomberman.user.UserLocalProperties;
    import com.willdom.games.explodersmmo.shared.ui.AvatarHelper;
    
    import fl.containers.ScrollPane;
    
    import flash.display.Sprite;
    import flash.events.MouseEvent;

    public class InGameUserListRowComponent extends Sprite
    {
        private var userListRowComponent:MC_InGameUserComponent;
        private var userExitedRoom:Boolean = false;
        private var hasMouseOver:Boolean = false;
        private var characterSelected:Boolean = false;
        private var avatarLoaded:Boolean = false;
        private var _user:User;
        private var _userLocalProperties:UserLocalProperties;
        private var _sfsInstance:SmartFoxClient;
        private var _score:int;
        private var _position:int;
        
        public function InGameUserListRowComponent(user:User, userLocalProperties:UserLocalProperties)
        {
            _sfsInstance = SmartFoxClientSingleton.getInstance().smartFoxClient;
            
            initialize(user, userLocalProperties);
            
            addChild(userListRowComponent);
        }
        
        private function initialize(user:User, userLocalProperties:UserLocalProperties):void
        {
            userListRowComponent = new MC_InGameUserComponent;
            _user = user;
            _userLocalProperties = userLocalProperties;
            
            userListRowComponent.playerKilledLeftOverlay.visible = false;
            userListRowComponent.mySelfKilledOverlay.visible = false;
            userListRowComponent.avatarHead.visible = false;
            userListRowComponent.userLeftIcon.visible = false;
            userListRowComponent.userNotSelectedIcon.visible = true;
            userListRowComponent.avatarHolder.visible = false;
            //userListRowComponent.flagIcon.visible = false;
            userListRowComponent.pingIcon.visible = false;
            userListRowComponent.pingIcon.gotoAndStop(1);
            userListRowComponent.rankingIcon.visible = false;
            userListRowComponent.txtRanking.visible = false;
            userListRowComponent.txtPing.visible = false;
            userListRowComponent.flagIcon.gotoAndStop("undefined");
            
            if(_user.id == _sfsInstance.myself.id)
            {
                userListRowComponent.background.gotoAndStop("myself");
            }
            else
            {
                userListRowComponent.background.gotoAndStop("other");
                addEventListener(MouseEvent.ROLL_OVER, onRollOver, false, 0, true);
                addEventListener(MouseEvent.ROLL_OUT, onRollOut, false, 0, true);
            }
            
            if(userLocalProperties.isRegistered)
            {
                if(!avatarLoaded)
                {
                    if(user.containsVariable("chatAvatar"))
                    {
                        userListRowComponent.avatarHolder.addChild(AvatarHelper.loadExternalAvatar(user.getVariable("chatAvatar").getSFSObjectValue().getUtfString("medium")));
                        avatarLoaded = true;
                    }
                }
            }
            else
            {
                userListRowComponent.avatarHolder.addChild(AvatarHelper.loadExternalAvatar("http://tunaplus.api.jaludo.com/assets/images/avatar_boy_medium.png"));
            }
            
            if(user.containsVariable(PlayerVars.NATIONALITY))
            {
                userListRowComponent.flagIcon.gotoAndStop(user.getVariable(PlayerVars.NATIONALITY).getStringValue());
            }
            
            userListRowComponent.txtPosition.text = "-";
            userListRowComponent.txtScore.text = "-";
            userListRowComponent.txtUsername.text = user.name;
            userListRowComponent.txtSkillpoints.text = userLocalProperties.pointsStr;
            userListRowComponent.txtPing.text = "-";
            userListRowComponent.txtRanking.text = userLocalProperties.rankingStr;
        }
        
        public function updateComponent(user:User, userLocalProperties:UserLocalProperties):void
        {
            _userLocalProperties = userLocalProperties;
            _user = user;
            
            userListRowComponent.txtSkillpoints.text = userLocalProperties.pointsStr;
            
            if(userLocalProperties.isRegistered)
            {
                userListRowComponent.skillpointsIcon.alpha = 1;
                userListRowComponent.txtSkillpoints.alpha = 1;
                userListRowComponent.rankingIcon.alpha = 1;
                userListRowComponent.txtRanking.alpha = 1;
                
                userListRowComponent.txtRanking.text =  _userLocalProperties.rankingStr;
            }
            else
            {
                userListRowComponent.skillpointsIcon.alpha = 0.5;
                userListRowComponent.txtSkillpoints.alpha = 0.5;
                userListRowComponent.rankingIcon.alpha = 0.5;
                userListRowComponent.txtRanking.alpha = 0.5;
                
                userListRowComponent.txtRanking.text = "-";
            }
            
            if(userLocalProperties.isRegistered)
            {
                if(!avatarLoaded)
                {
                    if(user.containsVariable("chatAvatar"))
                    {
                        userListRowComponent.avatarHolder.addChild(AvatarHelper.loadExternalAvatar(user.getVariable("chatAvatar").getSFSObjectValue().getUtfString("medium")));
                        avatarLoaded = true;
                    }
                }
            }
            
            if(user.containsVariable(PlayerVars.NATIONALITY))
            {
                userListRowComponent.flagIcon.gotoAndStop(user.getVariable(PlayerVars.NATIONALITY).getStringValue());
            }
        }
        
        public function updateScoreAndPosition(position:int, score:int):void
        {
            _score = score;
            _position = position;
            userListRowComponent.txtPosition.text = position.toString();
            userListRowComponent.txtScore.text = score.toString();
        }
        
        public function updateAvatarHead(characterId:int):void
        {
            if(!hasMouseOver)
            {
                userListRowComponent.userNotSelectedIcon.visible = false;
                userListRowComponent.avatarHead.visible = true;
            }
            userListRowComponent.avatarHead.gotoAndStop("avatar" + characterId.toString());
            characterSelected = true;
        }
        
        public function updatePingIcon(ping:int):void
        {
            if(ping >= 0 && ping <= 60)
            {
                userListRowComponent.pingIcon.gotoAndStop(1);
            }
            else if(ping >= 61 && ping <= 120)
            {
                userListRowComponent.pingIcon.gotoAndStop(2);
            }
            else if(ping >= 121 && ping <= 200)
            {
                userListRowComponent.pingIcon.gotoAndStop(3);
            }
            else
            {
                userListRowComponent.pingIcon.gotoAndStop(4);
            }
            userListRowComponent.txtPing.text = ping.toString();
        }
        
        public function onUserExitRoom():void
        {
            userListRowComponent.pingIcon.visible = false;
            userListRowComponent.txtPing.visible = false;
            userListRowComponent.userLeftIcon.visible = true;
            userListRowComponent.txtScore.visible = false;
            userListRowComponent.playerKilledLeftOverlay.visible = true;
            userListRowComponent.playerKilledLeftOverlay.alpha = 0.5;
            userExitedRoom = true;
        }
        
        public function onUserKilled(userId:int):void
        {
            if(userId == _sfsInstance.myself.id)
            {
                userListRowComponent.mySelfKilledOverlay.visible = true;
                userListRowComponent.mySelfKilledOverlay.alpha = 0.5;
            }
            else
            {
                userListRowComponent.playerKilledLeftOverlay.visible = true;
                userListRowComponent.playerKilledLeftOverlay.alpha = 0.25;
            }
        }
        
        public function onRoundStart():void
        {
            if(!userExitedRoom)
            {
                userListRowComponent.mySelfKilledOverlay.visible = false;
                userListRowComponent.playerKilledLeftOverlay.visible = false;
            }
        }
        
        private function onRollOver(event:MouseEvent):void
        {
            userListRowComponent.avatarHead.visible = false;
            userListRowComponent.skillpointsIcon.visible = false;
            userListRowComponent.userLeftIcon.visible = false;
            userListRowComponent.txtSkillpoints.visible = false;
            userListRowComponent.txtScore.visible = false;
            userListRowComponent.userNotSelectedIcon.visible = false;
            
            userListRowComponent.avatarHolder.visible = true;
            //userListRowComponent.flagIcon.visible = true;
            userListRowComponent.rankingIcon.visible = true;
            userListRowComponent.txtRanking.visible = true;
            
            if(userExitedRoom)
            {
                userListRowComponent.userLeftIcon.visible = true;
                userListRowComponent.pingIcon.visible = false;
                userListRowComponent.txtPing.visible = false;
            }
            else
            {
                userListRowComponent.userLeftIcon.visible = false;
                userListRowComponent.pingIcon.visible = true;
                userListRowComponent.txtPing.visible = true;
            }
            
            hasMouseOver = true;
        }
        
        private function onRollOut(event:MouseEvent):void
        {
            if(!characterSelected)
            {
                userListRowComponent.avatarHead.visible = false;
                userListRowComponent.userNotSelectedIcon.visible = true;
            }
            else
            {
                userListRowComponent.avatarHead.visible = true;
                userListRowComponent.userNotSelectedIcon.visible = false;
            }
            userListRowComponent.skillpointsIcon.visible = true;
            userListRowComponent.txtSkillpoints.visible = true;
            userListRowComponent.txtScore.visible = true;
            
            userListRowComponent.avatarHolder.visible = false;
            userListRowComponent.pingIcon.visible = false;
            //userListRowComponent.flagIcon.visible = false;
            userListRowComponent.rankingIcon.visible = false;
            userListRowComponent.txtRanking.visible = false;
            userListRowComponent.txtPing.visible = false;
            userListRowComponent.txtScore.visible = true;
            userListRowComponent.pingIcon.visible = false;
            
            if(userExitedRoom)
            {
                userListRowComponent.userLeftIcon.visible = true;
                userListRowComponent.txtScore.visible = false;
            }
            
            hasMouseOver = false;
        }
        
        public function get user():User
        {
            return _user;
        }
        
        public function get userLocalProperties():UserLocalProperties
        {
            return _userLocalProperties;
        }
        
        public function get score():int
        {
           return _score;
        }
        
        public function get position():int
        {
            return _position;
        }
    }
}