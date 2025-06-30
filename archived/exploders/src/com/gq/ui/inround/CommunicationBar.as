package com.gq.ui.inround
{
    import com.gq.system.GameData;
    import com.gq.system.SoundClass;
    import com.greensock.TweenMax;
    import com.greensock.easing.Linear;
    import com.willdom.games.bomberman.consts.SkullTypes;
    
    import flash.display.Sprite;

    public class CommunicationBar extends Sprite
    {
        private var texture:MC_IngameCommunicationBar;
        private var tweenReadyGo:TweenMax;
        private var tweenSuddenDeath:TweenMax;
        private var tweenClock:TweenMax;
        
        public function CommunicationBar()
        {
            texture = new MC_IngameCommunicationBar;
            
            tweenReadyGo = new TweenMax(texture.messageReadyGo, 1, {y:10, ease:Linear.easeInOut, onComplete: onReadyGoTweenComplete});
            tweenSuddenDeath = new TweenMax(texture.messageSuddenDeath, 1, {y:10, ease:Linear.easeInOut});
            tweenClock = new TweenMax(texture.clock, 1, {alpha:1});
            
            tweenReadyGo.pause();
            tweenSuddenDeath.pause();
            tweenClock.pause();
            
            addChild(texture);
        }
        
        public function initialize():void
        {
            texture.clock.txtTime.text = LanguageManager.getInstance().getText("_time");
            texture.clock.txtRound.text = LanguageManager.getInstance().getText("_round");
            texture.clock.alpha = 0;
            texture.clock.wipeAnimation.gotoAndStop(1);
        }
        
        public function resetComponent(timeValue:String, currentRound:int, totalRounds:int):void
        {
            texture.messageReadyGo.visible = false;
            texture.messageSuddenDeath.visible = false;
            texture.messageDisease.visible = false;
            texture.clock.alpha = 0;
            
            tweenClock.restart();
            tweenClock.pause();
            
            tweenSuddenDeath.restart();
            tweenSuddenDeath.pause();
            
            setUpClockTime(timeValue);
        }
        
        public function setUpClockTime(timeValue:String):void
        {
            texture.clock.txtTimeValue.text = timeValue;
            moveClockAnimation();
        }
        
        public function setUpRound(currentRound:int, totalRounds:int):void
        {
            texture.clock.txtRoundValue.text = (currentRound - 1).toString() + " / " + totalRounds.toString();
        }
        
        public function displayReadyGoMessage():void
        {
            texture.messageReadyGo.label.text = LanguageManager.getInstance().getText("_gisReadMessage");
            texture.messageReadyGo.visible = true;
            tweenReadyGo.play();
            
            if(!SoundClass.deactivateSound)
            {  
                SoundClass.addMusic( "sound", "stinger_ready", 1);
            }
        }
        
        public function displaySuddenDeathMessage():void
        {
            texture.messageSuddenDeath.label.text = LanguageManager.getInstance().getText("_gisSuddenDeathMessage");
            texture.messageSuddenDeath.visible = true;
            tweenSuddenDeath.play();
        }
        
        private function moveClockAnimation():void
        {
            texture.clock.wipeAnimation.gotoAndStop(GameData.instance.currentLocalTick);
        }
        
        private function onReadyGoTweenComplete():void
        {
            TweenMax.delayedCall(1.5, changeReadyGoText);
            TweenMax.delayedCall(3, tweenReadyGo.reverse);
            TweenMax.delayedCall(3, tweenClock.play);
        }
        
        private function changeReadyGoText():void
        {
            texture.messageReadyGo.label.text = LanguageManager.getInstance().getText("_gisGoMessage");
            
            if(!SoundClass.deactivateSound )
            {                
                SoundClass.addMusic("sound", "stinger_go", 1);
            }
        }
    }
}