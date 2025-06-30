package com.gq.ui
{
    import com.smartfoxserver.v2.entities.User;
    import com.willdom.games.bomberman.communication.SmartFoxClient;
    import com.willdom.games.bomberman.communication.SmartFoxClientSingleton;
    import com.willdom.games.bomberman.consts.PlayerVars;
    import com.willdom.games.bomberman.user.UserLocalProperties;
    import com.willdom.games.explodersmmo.shared.ui.AvatarHelper;
    
    import flash.display.Sprite;

    public class InGameUserListRowComponentEndResults extends Sprite
    {
        private var userListRowComponent:MC_IngameUserComponentEndScreen
        private var _sfsInstance:SmartFoxClient;
        private var avatarLoaded:Boolean = false;
        private var _user:User;
        private var _userLocalProperties:UserLocalProperties;
        
        public function InGameUserListRowComponentEndResults(user:User, userProperties:UserLocalProperties)
        {
            userListRowComponent = new MC_IngameUserComponentEndScreen;
            _sfsInstance = SmartFoxClientSingleton.getInstance().smartFoxClient;
            
            initialize(user, userLocalProperties);
            
            addChild(userListRowComponent);
        }
        private function initialize(user:User, userLocalProperties:UserLocalProperties):void
        {
            _user = user;
            _userLocalProperties = userLocalProperties;
            
            userListRowComponent.flagIcon.gotoAndStop("undefined");
            
            if(_user.id == _sfsInstance.myself.id)
            {
                userListRowComponent.background.gotoAndStop("myself");
                userListRowComponent.txtUsername.textColor = 0xFFFFFF;
                userListRowComponent.txtSkillpoints.textColor = 0xFFFFFF;
            }
            else
            {
                userListRowComponent.background.gotoAndStop("other");
            }
            
            userListRowComponent.avatarHolder.visible = true;
            userListRowComponent.avatarHolder.addChild(AvatarHelper.loadExternalAvatar("http://tunaplus.api.jaludo.com/assets/images/avatar_boy_medium.png"));
            
            if(userLocalProperties != null)
            {
                if(userLocalProperties.isRegistered)
                {
                    if(user.containsVariable("chatAvatar"))
                    {
                        userListRowComponent.avatarHolder.addChild(AvatarHelper.loadExternalAvatar(user.getVariable("chatAvatar").getSFSObjectValue().getUtfString("medium")));
                        avatarLoaded = true;
                    }
                }
            }
            
            userListRowComponent.txtUsername.text = user.name;
            userListRowComponent.txtSkillpoints.text = "-";
        }
        
        public function updateComponent(user:User, userLocalProperties:UserLocalProperties):void
        {
            _userLocalProperties = userLocalProperties;
            _user = user;
            
            userListRowComponent.avatarHolder.visible = true;

            
            if(_userLocalProperties.isRegistered)
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
            
            if(user.containsVariable(PlayerVars.NATIONALITY) && user.getVariable(PlayerVars.NATIONALITY).getStringValue() != "label" && user.getVariable(PlayerVars.NATIONALITY).getStringValue() != "")
            {
                userListRowComponent.flagIcon.gotoAndStop(user.getVariable(PlayerVars.NATIONALITY).getStringValue());
            }
            
            userListRowComponent.txtSkillpoints.text = userLocalProperties.pointsStr;
        }
        
        public function updateStatusIcon(status:String):void
        {
            userListRowComponent.waitingIcon.gotoAndStop(status);
        }
        
        public function get user():User
        {
            return _user;
        }
        
        public function get userLocalProperties():UserLocalProperties
        {
            return _userLocalProperties;
        }
    }
}