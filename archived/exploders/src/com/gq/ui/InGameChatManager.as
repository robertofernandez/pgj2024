package com.gq.ui
{
    import com.smartfoxserver.v2.entities.data.SFSObject;
    import com.willdom.games.bomberman.communication.SmartFoxClientSingleton;
    import com.willdom.games.explodersmmo.shared.model.LocalUser;
    import com.willdom.games.explodersmmo.shared.ui.CustomButton;
    
    import fl.containers.ScrollPane;
    import fl.controls.ScrollPolicy;
    import fl.controls.TextInput;
    
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.FocusEvent;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.text.TextFormat;
    import flash.ui.Keyboard;
    
    import mx.utils.StringUtil;
        
    public class InGameChatManager extends Sprite
    {
        private const STATUS_COLLAPSED:String = "collapsed";
        private const STATUS_EXPANDED:String = "expanded";
        private const MAX_MESSAGES:int = 50;
        
        private static var instance:InGameChatManager;
        private var initialized:Boolean = false;
        private var currentStatus:String;
        private var unreadGeneralChatMessages:int;
        private var inGameChatCollapsed:MC_InGameChatCollapsed;
        private var inGameChatExpanded:MC_InGameChatExpandedA;
        private var inGameChatCurrentStatus:String;
        private var btnFriendsCollapsed:CustomButton;
        private var btnRoomChatCollapsed:CustomButton;
        private var btnFriendsExpanded:CustomButton;
        private var btnRoomChatExpanded:CustomButton;
        private var btnCollapse:CustomButton;
        private var btnSendMessage:CustomButton;
        private var scrollPaneContainer:ScrollPane;
        private var scrollPaneSource:Sprite;
        private var inputMessage:TextInput;
        private var vectorMessages:Vector.<InGameChatMessageRowComponent>;
        private var arialRegular:GameArialRegular;
        private var textFormat:TextFormat;
        
        public function InGameChatManager()
        {
            if(instance)
            {
                throw new Error("This is a singleton class, use getInstance() instead");
            }
        }
        
        public static function getInstance():InGameChatManager
        {
            if(instance == null)
            {
                instance = new InGameChatManager();
            }
            
            return instance;
        }
        
        public function initialize():void
        {
            if(!initialized)
            {
                initializeComponents();
                skinComponents();
                
                initialized = true;
            }
        }
        
        private function initializeComponents():void
        {
            inGameChatCollapsed = new MC_InGameChatCollapsed;
            btnFriendsCollapsed = new CustomButton(inGameChatCollapsed.btnFriendsChat);
            btnRoomChatCollapsed = new CustomButton(inGameChatCollapsed.btnGameRoomChat);
            btnFriendsCollapsed.addEventListener(MouseEvent.CLICK, onInGameChatCollapsedButtonEvent, false, 0, true);
            btnRoomChatCollapsed.addEventListener(MouseEvent.CLICK, onInGameChatCollapsedButtonEvent, false, 0, true);
            inGameChatCollapsed.gameRoomChatNotification.visible = false;
            inGameChatCollapsed.gameRoomChatNotification.mouseEnabled = false;
            inGameChatCollapsed.gameRoomChatNotification.mouseChildren = false;
            inGameChatCollapsed.x = 776;
            inGameChatCollapsed.y = 660
            
            inGameChatExpanded = new MC_InGameChatExpandedA;
            inGameChatExpanded.visible = false;
            btnFriendsExpanded = new CustomButton(inGameChatExpanded.btnFriendsChat, "");
            btnRoomChatExpanded = new CustomButton(inGameChatExpanded.btnGameRoomChat, "", true, true);
            btnCollapse = new CustomButton(inGameChatExpanded.btnCollapse);
            btnSendMessage = new CustomButton(inGameChatExpanded.btnSendMessage);
            btnFriendsExpanded.addEventListener(MouseEvent.CLICK, onInGameChatExpandedButtonEvent, false, 0, true);
            btnRoomChatExpanded.addEventListener(MouseEvent.CLICK, onInGameChatExpandedButtonEvent, false, 0, true);
            btnCollapse.addEventListener(MouseEvent.CLICK, onInGameChatExpandedButtonEvent, false, 0, true);
            btnSendMessage.addEventListener(MouseEvent.CLICK, onInGameChatExpandedButtonEvent, false, 0, true);
            inGameChatExpanded.x = 774;
            inGameChatExpanded.y = 245;
            
            scrollPaneSource = new Sprite;
            scrollPaneContainer = inGameChatExpanded.scrollPaneContainer;
            scrollPaneContainer.source = scrollPaneSource;
            scrollPaneContainer.verticalScrollPolicy = ScrollPolicy.AUTO;
            scrollPaneContainer.horizontalScrollPolicy = ScrollPolicy.OFF;
            
            inputMessage = inGameChatExpanded.inputMessage;
            inputMessage.addEventListener(FocusEvent.FOCUS_IN, onMessageFocusIn, false, 0, true);
            inputMessage.addEventListener(KeyboardEvent.KEY_UP, onMessageInputKeyUp, false, 0, true);
            
            vectorMessages = new Vector.<InGameChatMessageRowComponent>;
            currentStatus = STATUS_COLLAPSED;
            unreadGeneralChatMessages = 0;
            
            btnFriendsCollapsed.enableToolTip();
            btnFriendsExpanded.enableToolTip();
        }
        
        private function skinComponents():void
        {
            arialRegular = new GameArialRegular;
            textFormat = new TextFormat(arialRegular.fontName, 12, 0x7FA0BF);
            
            scrollPaneContainer.setStyle("upSkin", new Sprite);
            scrollPaneContainer.setStyle("thumbIcon", new Sprite);
            scrollPaneContainer.setStyle("upArrowUpSkin", ScrollArrowUp_upSkinGameRoomCustom);
            scrollPaneContainer.setStyle("upArrowOverSkin", ScrollArrowUp_upSkinGameRoomCustom);
            scrollPaneContainer.setStyle("upArrowDownSkin", ScrollArrowUp_upSkinGameRoomCustom);
            scrollPaneContainer.setStyle("downArrowUpSkin", ScrollArrowDown_upSkinGameRoomCustom);
            scrollPaneContainer.setStyle("downArrowOverSkin", ScrollArrowDown_upSkinGameRoomCustom);
            scrollPaneContainer.setStyle("downArrowDownSkin", ScrollArrowDown_upSkinGameRoomCustom);
            scrollPaneContainer.setStyle("trackUpSkin", ScrollTrack_skinGameRoomCustom);
            scrollPaneContainer.setStyle("trackOverSkin", ScrollTrack_skinGameRoomCustom);
            scrollPaneContainer.setStyle("trackDownSkin", ScrollTrack_skinGameRoomCustom);
            scrollPaneContainer.setStyle("thumbUpSkin", ScrollThumb_upSkinGameRoomCustom);
            scrollPaneContainer.setStyle("thumbOverSkin", ScrollThumb_upSkinGameRoomCustom);
            scrollPaneContainer.setStyle("thumbDownSkin", ScrollThumb_upSkinGameRoomCustom);
            
            inputMessage.setStyle("upSkin", TextInput_upSkinGameRoomChatCustom);
            inputMessage.setStyle("textFormat", textFormat);
            inputMessage.setStyle("textPadding", 3);
        }
        
        public function onCharacterSelectionStatus():void
        {
            addChild(inGameChatCollapsed);
            addChild(inGameChatExpanded);
        }
        
        private function onInGameChatCollapsedButtonEvent(event:MouseEvent):void
        {
            if(event.target == btnFriendsCollapsed)
            {
                
            }
            else if(event.target == btnRoomChatCollapsed)
            {
                inGameChatCollapsed.gameRoomChatNotification.visible = false;
                unreadGeneralChatMessages = 0;
                
                inGameChatCollapsed.visible = false;
                inGameChatExpanded.visible = true;
                
                currentStatus = STATUS_EXPANDED;
            }
        }
        
        private function onInGameChatExpandedButtonEvent(event:MouseEvent):void
        {
            if(event.target == btnFriendsExpanded)
            {
                
            }
            else if(event.target == btnRoomChatExpanded)
            {
                inGameChatCollapsed.visible = true;
                inGameChatExpanded.visible = false;
                currentStatus = STATUS_COLLAPSED;
                
                btnRoomChatExpanded.enable();
            }
            else if(event.target == btnCollapse)
            {
                inGameChatCollapsed.visible = true;
                inGameChatExpanded.visible = false;
                currentStatus = STATUS_COLLAPSED;
                
                btnRoomChatExpanded.enable();
            }
            else if(event.target == btnSendMessage)
            {
                if(LocalUser.getInstance().registered || (SmartFoxClientSingleton.getInstance().smartFoxClient.myself.isSpectator && LocalUser.getInstance().registered))
                {
                    sendMessage();
                }
            }
        }
        
        private function onAddedToStage(event:Event):void
        {

        }
        
        private function onMessageInputKeyUp(event:KeyboardEvent):void
        {
            if(event.keyCode == Keyboard.ENTER)
            {
                if(LocalUser.getInstance().registered || (SmartFoxClientSingleton.getInstance().smartFoxClient.myself.isSpectator && LocalUser.getInstance().registered))
                {
                    sendMessage();
                }
            }
        }
        
        private function onMessageFocusIn(event:FocusEvent):void
        {
            if(LocalUser.getInstance().registered || (SmartFoxClientSingleton.getInstance().smartFoxClient.myself.isSpectator && LocalUser.getInstance().registered))
            {
                inputMessage.text = "";
                inputMessage.removeEventListener(FocusEvent.FOCUS_IN, onMessageFocusIn);
            }
        }
        
        private function sendMessage():void
        {
            var trimmedMessage:String = StringUtil.trim(inputMessage.text);
            if(trimmedMessage != "")
            {
                if(trimmedMessage != LanguageManager.getInstance().getText("_gisChatDefaultMessage"))
                {
                    var params:SFSObject = new SFSObject();
                    params.putUtfString("message", inputMessage.text);
                    SmartFoxClientSingleton.getInstance().smartFoxClient.sendExtensionRequestToGameRoom("inGameMessage", params);
                    inputMessage.text = "";
                }
            }
        }
        
        public function addMessage(username:String, message:String, avatar:String):void
        {
            var auxMessage:InGameChatMessageRowComponent = new InGameChatMessageRowComponent;
            auxMessage.initialize(username, message, avatar);
            
            if(vectorMessages.length >= 1)
            {
                auxMessage.y = vectorMessages[vectorMessages.length - 1].y + vectorMessages[vectorMessages.length - 1].height;
            }
            else
            {
                auxMessage.y = 0;
            }
            vectorMessages.push(auxMessage);
            scrollPaneSource.addChild(auxMessage);
            checkForMaxMessages();
            updateMessagesScrollpane();
            
            if(currentStatus == STATUS_COLLAPSED)
            {
                inGameChatCollapsed.gameRoomChatNotification.visible = true;
                unreadGeneralChatMessages++;
                
                if(unreadGeneralChatMessages <= 9)
                    inGameChatCollapsed.gameRoomChatNotification.label.text = unreadGeneralChatMessages.toString();
                else
                    inGameChatCollapsed.gameRoomChatNotification.label.text = "9+";
            }
        }
        
        private function checkForMaxMessages():void
        {
            if(vectorMessages.length > MAX_MESSAGES)
            {
                var auxMessage:InGameChatMessageRowComponent = vectorMessages.shift();
                auxMessage.parent.removeChild(auxMessage);
                auxMessage = null;
                
                for(var i:int = 0; i < vectorMessages.length; i++)
                {
                    auxMessage = vectorMessages[i];
                    if(i == 0)
                    {
                        auxMessage.y = 0;
                    }
                    else
                    {
                        auxMessage.y = vectorMessages[i - 1].y + vectorMessages[i - 1].height;
                    }
                }
            }
        }
        
        private function updateMessagesScrollpane():void
        {
            var rollDown:Boolean;
            
            if(scrollPaneContainer.verticalScrollPosition == scrollPaneContainer.maxVerticalScrollPosition)
            {
                rollDown = true;
            }
            else
            {
                rollDown = false;
            }
            
            scrollPaneContainer.refreshPane();
            scrollPaneContainer.update();
            
            if(rollDown)
            {
                scrollPaneContainer.verticalScrollPosition = scrollPaneContainer.maxVerticalScrollPosition;
            }
        }
        
        public function resetComponents():void
        {
            unreadGeneralChatMessages = 0;
            currentStatus = STATUS_COLLAPSED;
            
            inGameChatExpanded.visible = false;
            inGameChatCollapsed.visible = true;
            inGameChatCollapsed.gameRoomChatNotification.visible = false;
            
            inputMessage.addEventListener(FocusEvent.FOCUS_IN, onMessageFocusIn, false, 0, true);
            
            for(var i:int = 0; i < vectorMessages.length; i++)
            {
                vectorMessages[i].parent.removeChild(vectorMessages[i]);
            }
            vectorMessages.splice(0, vectorMessages.length);
            updateMessagesScrollpane();
            
            if(inGameChatCollapsed.parent != null)
            {
                removeChild(inGameChatCollapsed);
            }
            if(inGameChatExpanded.parent != null)
            {
                removeChild(inGameChatExpanded);
            }
        }
        
        private function updateInputMessage():void
        {
            if(LocalUser.getInstance().registered || (SmartFoxClientSingleton.getInstance().smartFoxClient.myself.isSpectator && LocalUser.getInstance().registered))
            {
                inputMessage.enabled = true;
                inputMessage.text = LanguageManager.getInstance().getText("_gisChatDefaultMessage");
            }
            else
            {
                inputMessage.enabled = false;
                inputMessage.text = LanguageManager.getInstance().getText("_gisChatDefaultGuestMessage");
            }
        }
    }
}