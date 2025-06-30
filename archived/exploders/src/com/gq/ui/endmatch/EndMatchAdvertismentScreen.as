package com.gq.ui.endmatch
{
    import com.gq.system.GameData;
    import com.greensock.TweenMax;
    
    import flash.display.Sprite;

    public class EndMatchAdvertismentScreen extends Sprite
    {
        private var texture:MC_InGameAdvertismentScreen;
        private var tweenShowAdvertismentScreen:TweenMax;
        
        public function EndMatchAdvertismentScreen()
        {
            texture = new MC_InGameAdvertismentScreen;
            
            texture.txtLoading.text = LanguageManager.getInstance().getText("_gapSavingResult");
            
            tweenShowAdvertismentScreen = new TweenMax(this, 1, {alpha: 1});
            tweenShowAdvertismentScreen.pause();
            
            addChild(texture);
        }
        
        public function showAdvertismentScreen():void
        {
            GameData.instance.gameObjectsContainer.endMatchAuxBackground.visible = true;
            this.visible = true;
            this.alpha = 0;
            texture.loadingAnimation.play();
            tweenShowAdvertismentScreen.play();
        }
        
        public function hideAdvertismentScreen():void
        {
            this.visible = false;
            this.alpha = 0;
            texture.loadingAnimation.gotoAndStop(1);
            tweenShowAdvertismentScreen.restart();
            tweenShowAdvertismentScreen.pause();
        }
        
        public function dispose():void
        {
            hideAdvertismentScreen();
        }
    }
}