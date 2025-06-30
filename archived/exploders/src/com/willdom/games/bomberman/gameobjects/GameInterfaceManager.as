package com.willdom.games.bomberman.gameobjects
{
    import com.gq.moveobject.Bomb;
    import com.gq.moveobject.Person;
    import com.gq.system.GameData;
    import com.gq.system.GameTools;
    import com.gq.system.SoundClass;
    import com.gq.ui.MessageQueueItem;
    import com.gq.ui.Pages;
    import com.greensock.TweenMax;
    import com.greensock.easing.Linear;
    import com.willdom.games.bomberman.communication.SmartFoxClientSingleton;
    import com.willdom.games.bomberman.consts.SkullTypes;
    import com.willdom.util.helpers.EventListenerManager;
    
    import flash.display.Bitmap;
    import flash.display.MovieClip;
    import flash.events.TimerEvent;
    import flash.utils.Timer;

    public class GameInterfaceManager
    {
        private static var instance:GameInterfaceManager;
        public var endingSubmessage:MessageQueueItem;
        private var submessageTimer:Timer;
        private var gameTitleSprite:Bitmap;
        private var submessages:Array;
        private var diseaseMessage:Submessage;
        private var tweenProgressionBarMask:TweenMax;
        private var tweenDisease:TweenMax;
        
        public function GameInterfaceManager()
        {
            if(instance)
            {
                throw new Error("Use get instance instead");
            }
            else
            {
                gameTitleSprite = new Bitmap(new TitleSprite());
                submessageTimer = new Timer(3000);
                EventListenerManager.setListenerTo(submessageTimer, TimerEvent.TIMER, onSubmessageTimer, false, 0, true);
                submessages = new Array();
            }
        }
        
        public static function getInstance():GameInterfaceManager
        {
            if(instance == null)
            {
                instance = new GameInterfaceManager();
            }
            return instance;
        }
        
        public function build():void
        {
            GameData.instance.Scen.addChild(gameTitleSprite);
            gameTitleSprite.visible = false;
            gameTitleSprite.x = 9;
            gameTitleSprite.y = -54;
            EventListenerManager.setListenerTo(submessageTimer, TimerEvent.TIMER, onSubmessageTimer, false, 0, true);
            
            diseaseMessage = new Submessage;
            tweenDisease = new TweenMax(diseaseMessage, 0.85, {y: 655, ease:Linear.easeInOut});
            tweenProgressionBarMask = new TweenMax(diseaseMessage.messageBox.diseaseProgressionBarMask, 1, {x: diseaseMessage.messageBox.diseaseProgressionBarMask.x - diseaseMessage.messageBox.diseaseProgressionBarMask.width, 
                                                   delay:1, onComplete: onDiseaseAnimationComplete, ease:Linear.easeNone});
            
            diseaseMessage.x = 140;
            diseaseMessage.y = 710;
            
            tweenDisease.pause();
            tweenProgressionBarMask.pause();
        }
        
        public function toggleTitleScreenTitlePosition(top:Boolean = true):void
        {
            if (GameData.instance.Scen != null)
            {
                if (gameTitleSprite.parent == GameData.instance.Scen)
                {
                    GameData.instance.Scen.removeChild(gameTitleSprite);
                }
                if (top)
                {
                    GameData.instance.Scen.addChild(gameTitleSprite);
                }
                else
                {
                    GameData.instance.Scen.addChildAt(gameTitleSprite, GameData.instance.Scen.getChildIndex(GameData.instance.infoWindow)-3);
                }
            }
        }
        
        private function onSubmessageTimer(e:TimerEvent):void
        {
            if(submessages.length > 0)
            {
                endingSubmessage = submessages.shift();
                if (endingSubmessage.page.getChildAt(0) is Submessage)
                {
                    (endingSubmessage.page.getChildAt(0) as Submessage).gotoAndPlay("out");
                }
            }
            else
            {
                submessageTimer.stop();
                GameData.instance.isShowingMessage = false;
            }
        }
        
        public function showSubmessage(message:String, character:int = 0, bomb:Bomb = null, monochrome:Boolean = false, skullType:String = "", canBeRemoved:Boolean = true):void
        {
            //if(tweenProgressionBarMask != null && tweenProgressionBarMask.paused)
            //{
                if(!GameData.instance.endingState)
                {
                    if(!EventListenerManager.hasEventListener(submessageTimer, TimerEvent.TIMER))
                    {
                        EventListenerManager.setListenerTo(submessageTimer, TimerEvent.TIMER, onSubmessageTimer, false, 0, true);
                    }
                    
                    for(var i:uint = 1;i < submessages.length;i++)
                    {
                        if((submessages[i] as MessageQueueItem).message == message)
                        {
                            submessages.splice(i,1);
                        }
                    }
                    var lastSubmessage:MessageQueueItem;
                    if(submessages.length > 0)
                    {
                        lastSubmessage = submessages[submessages.length-1];
                    }
                    if(submessages.length==0 || ((lastSubmessage==null || lastSubmessage.message != message) && (endingSubmessage==null || endingSubmessage.message!= message)))
                    {
                        var queueItem:MessageQueueItem = GameTools.createPage(MessageQueueItem) as MessageQueueItem;
                        submessages.push(queueItem);
                        
                        var thisMessage:Submessage = new Submessage();
                        if (monochrome) thisMessage.messageBox.gotoAndStop("mono") else thisMessage.messageBox.gotoAndStop("normal");
                        
                        queueItem.message = message;
                        thisMessage.messageBox.mainText.text = message;
                        thisMessage.mask = thisMessage.maskMC;
                        thisMessage.messageBox.diseaseProgressionBar.visible = false;
                        thisMessage.messageBox.diseaseProgressionBarBackground.visible = false;
                        queueItem.page.addChildAt(thisMessage, 0);
                        
                        if(character > 0)
                        {
                            thisMessage.messageBox.avatar.gotoAndStop("avatar"+character);
                        }
                        else
                        {
                            thisMessage.messageBox.avatar.visible = false;    
                        }
                        if(skullType != "")
                        {
                            //var firstLowerCase:String = skullType.charAt(0).toLocaleLowerCase();
                            //var label:String = firstLowerCase.concat( skullType.substring(1) );
                            thisMessage.messageBox.bombType.visible = true;
                            thisMessage.messageBox.bombType.gotoAndStop(skullType);
                            thisMessage.messageBox.avatar.gotoAndStop("skull");
                        }
                        else if(bomb == null)
                        {
                            thisMessage.messageBox.bombType.visible = false;
                            thisMessage.messageBox.iconHolder.visible = false;
                        }
                        else
                        {
                            switch (bomb.bombType) {
                                case Bomb.NORMAL_BOMB:
                                    thisMessage.messageBox.bombType.visible = true;
                                    thisMessage.messageBox.bombType.gotoAndStop("regular");
                                    break;
                                case Bomb.DANGER_BOMB:
                                    thisMessage.messageBox.bombType.visible = true;
                                    thisMessage.messageBox.bombType.gotoAndStop("dangerous");
                                    break;
                                case Bomb.POWER_BOMB:
                                    thisMessage.messageBox.bombType.visible = true;
                                    thisMessage.messageBox.bombType.gotoAndStop("power");
                                    break;
                                case Bomb.BOUNCING_BOMB:
                                    thisMessage.messageBox.bombType.visible = true;
                                    thisMessage.messageBox.bombType.gotoAndStop("bouncing");
                                    break;
                                case Bomb.SPIKE_BOMB:
                                    thisMessage.messageBox.bombType.visible = true;
                                    thisMessage.messageBox.bombType.gotoAndStop("piercing");
                                    break;
                                case Bomb.MINE:
                                    thisMessage.messageBox.bombType.visible = true;
                                    thisMessage.messageBox.bombType.gotoAndStop("mine");
                                    break;
                            }
                        }
                        
                        queueItem.page.x += 140;
                        queueItem.page.y = 700;
                        
                        if(GameData.instance.isShowingMessage)
                        {
                            queueItem.page.visible = false;
                        }
                        else
                        {
                            GameData.instance.isShowingMessage = true;
                            thisMessage.gotoAndPlay("in");
                        }  
                        queueItem.canBeRemoved = canBeRemoved;
                    }
                }
            //}
        }
        
        public function createKillMessage(killed:String, killer:String, bomb:Bomb):void
        {
            if (bomb != null)
            {
                if (killed == SmartFoxClientSingleton.getInstance().smartFoxClient.myself.name)
                {
                    SoundClass.addMusic( "sound", "sfx_killself" );
                    if (killer != SmartFoxClientSingleton.getInstance().smartFoxClient.myself.name)
                    {
                        showSubmessage(LanguageManager.getInstance().getAndReplaceText("_hasKilledYouMessage", "%killer%", killer), Person.getPersonByName(killer).myAvatar, bomb);
                    }
                    else
                    {
                        showSubmessage(LanguageManager.getInstance().getAndReplaceText("_suicideMessage"), Person.getPersonByName(killer).myAvatar, bomb, true);
                    }
                }
                else if (killer == SmartFoxClientSingleton.getInstance().smartFoxClient.myself.name)
                {
                    var killSoundNumber:int = Math.floor(Math.random() * 5);
                    SoundClass.addMusic( "sound", "sfx_killsomeone_" + killSoundNumber);
                    showSubmessage(LanguageManager.getInstance().getAndReplaceText("_youHaveKilledMessage","%killed%",killed), Person.getPersonByName(killer).myAvatar, bomb);
                }
                else
                {
                    SoundClass.addMusic( "sound", "sfx_killother" );
                    if (killed == killer)
                    {
                        showSubmessage(LanguageManager.getInstance().getAndReplaceText("_otherSuicideMessage","%killer%",killer), (Person.getPersonByName(killed) as Person).myAvatar, bomb, true);
                    }
                    else
                    {
                        showSubmessage(LanguageManager.getInstance().getAndReplaceText("_killMessage","%killer%",killer).replace("%killed%",killed), (Person.getPersonByName(killed) as Person).myAvatar, bomb, true);
                    }
                }
            }
            else
            {
                if (GameData.instance.roundStarted)
                {
                    
                    showSubmessage(LanguageManager.getInstance().getAndReplaceText("_leftTheGameMessage","%player%",killed), Person.getPersonByName(killed).myAvatar,null, true); 
                }
            }
        }
        
        public function startPopUpTimer():void
        {
            submessageTimer.start();
        }
        
        public function checkNextMessageInQueue():void
        {
            if(submessages.length > 0)
            {
                var newMessage:Pages = submessages[0];
                Pages(newMessage).page.visible = true;
                submessageTimer.stop();
                if(newMessage is MessageQueueItem)
                {
                    (Pages(newMessage).page.getChildAt(0) as MovieClip).gotoAndPlay("in");
                }
            }
            else
            {
                submessageTimer.stop();
                GameData.instance.isShowingMessage = false;
            }
        }
        
        public function deleteFlaggedSubmessages():void
        {
            var i:int = 1;
            
            while(i < submessages.length)
            {
                if( (submessages[i] as MessageQueueItem).canBeRemoved)
                {
                    submessages.splice(i,1);
                }
                else
                {
                    i++;
                }
            }
        }
        
        public function showDiseaseMessage(myAvatar:int, type:String, time:int, delay:int = 0):void
        {
            var message:String;
            
            switch (type)
            {
                case SkullTypes.CONFUSION:
                    message = LanguageManager.getInstance().getText("_gisDiseaseConfusionMessage");
                    break;
                case SkullTypes.CONSTIPATION:
                    message = LanguageManager.getInstance().getText("_gisDiseaseConstipationMessage");
                    break;
                case SkullTypes.DIZZY:
                    message = LanguageManager.getInstance().getText("_gisDiseaseDizzyMessage");
                    break;
                case SkullTypes.LOW_POWER:
                    message = LanguageManager.getInstance().getText("_gisDiseaseLowPowerMessage");
                    break;
                case SkullTypes.QUICK:
                    message = LanguageManager.getInstance().getText("_gisDiseaseQuickMessage");
                    break;
                case SkullTypes.RECKLESS:
                    message = LanguageManager.getInstance().getText("_gisDiseaseRecklessMessage");
                    break;
                case SkullTypes.SLOW:
                    message = LanguageManager.getInstance().getText("_gisDiseaseSlowMessage");
                    break;
                case SkullTypes.SHORT_FUSE:
                    message = LanguageManager.getInstance().getText("_gisDiseaseShortFuseMessage");
                    break;
                case SkullTypes.LONG_FUSE:
                    message = LanguageManager.getInstance().getText("_gisDiseaseLongFuseMessage");
                    break;
                case SkullTypes.POSITION_SWITCH:
                    message = LanguageManager.getInstance().getText("_gisDiseasePositionSwitchMessage");
                    break;
                case SkullTypes.EPIC_FIRE:
                    message = LanguageManager.getInstance().getText("_gisDiseaseEpicFireMessage");
                    break;
                case SkullTypes.DIARRHOEA:
                    message = LanguageManager.getInstance().getText("_gisDiseaseDiarrhoeaMessage");
                    break;
            }
            
            GameData.instance.Scen.addChild(diseaseMessage);
            diseaseMessage.messageBox.gotoAndStop("normal");
            diseaseMessage.messageBox.avatar.gotoAndStop("avatar"+ myAvatar);
            diseaseMessage.messageBox.mainText.text = message;
            diseaseMessage.messageBox.bombType.gotoAndStop(type);
            
            tweenProgressionBarMask.duration = time;
            tweenProgressionBarMask.delay = delay;
            tweenProgressionBarMask.restart();
            tweenDisease.play();
        }
        
        public function updateDiseaseTime(time:int):void
        {
            tweenProgressionBarMask.duration = time;
            tweenProgressionBarMask.restart();
        }
        
        public function hideDiseaseMessage():void
        {
            tweenProgressionBarMask.pause();
            tweenDisease.reverse();
        }
        
        private function onDiseaseAnimationComplete():void
        {
            tweenDisease.reverse();
        }
        
        public function dispose():void
        {
            hideDiseaseMessage();
            submessageTimer.stop();
            EventListenerManager.setListenerTo(submessageTimer, TimerEvent.TIMER, onSubmessageTimer);
        }
    }
}