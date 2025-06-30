package com.gq.ui
{
    import com.willdom.games.explodersmmo.shared.model.LocalUser;
    import com.willdom.games.explodersmmo.shared.ui.AvatarHelper;
    
    import flash.display.Sprite;
    import flash.text.TextFieldAutoSize;

    public class InGameChatMessageRowComponent extends Sprite
    {
        private const MESSAGE_OFFSET_Y:int = 5;
        private var texture:MC_InGameChatMessageRowComponent;
        
        public function InGameChatMessageRowComponent() 
        {
            texture = new MC_InGameChatMessageRowComponent;
            addChild(texture);
        }
        
        public function initialize(username:String, message:String, avatar:String):void
        {
            var auxMessage:String = username + ": " + message;
            texture.message.autoSize = TextFieldAutoSize.LEFT;
            texture.message.multiline = true;
            texture.message.wordWrap = true;
            texture.message.selectable = false;
            
            var htmlMessage:String;
            if(username == LocalUser.getInstance().username)
            {
                htmlMessage = "<b><font color='#FF4700'>" + username + ": " + "</font></b><font color='#333333'>" + message + "</font>";
            }
            else
            {
                htmlMessage = "<b><font color='#106C81'>" + username + ": " + "</font></b><font color='#333333'>" + message + "</font>";
            }
            texture.message.htmlText = htmlMessage;
            
            texture.messageSeparator.mouseEnabled = false;
            texture.messageSeparator.y = texture.height;
            
            if(avatar == "")
            {
                avatar = "http://tunaplus.api.jaludo.com/assets/images/avatar_boy_small.png";
            }
            texture.avatarHolder.addChild(AvatarHelper.loadExternalAvatar(avatar));
        }
    }
}