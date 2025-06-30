package com.gq.ui
{
    import com.gq.system.GameData;
    import com.gq.system.GameSys;
    import com.willdom.games.bomberman.gameobjects.GameInterfaceManager;
    import com.willdom.util.helpers.EventListenerManager;
    
    import configuration.StageModes;
    
    import flash.display.MovieClip;
    import flash.events.Event;

    public class MessageQueueItem extends Pages
    {
        
        public var message:String = "";
        public var canBeRemoved:Boolean = true;
        
        public function MessageQueueItem():void
        {    
            var queueItemMc:MessagesMC = new MessagesMC();
            if( GameData.instance.STAGE_MODE == StageModes.PENGUIN){
                queueItemMc.gotoAndStop( "penguin" );
            }
            super( queueItemMc );
            EventListenerManager.setListenerTo(this.page, "endTween", readyToRemove);
            EventListenerManager.setListenerTo(this.page, "upTween", fullyOpen);
            
        }
        
        override protected function init():void
        {
            super.init();
        }
        
        public function menuFunc():void
        {
            removeMe();
        }
        
        override public function removeMe():void
        {

            this.page.visible = false;
            super.removeMe();
        }
        
        private function readyToRemove(e:Event):void
        {
            
            GameInterfaceManager.getInstance().endingSubmessage = null;
            this.page.removeEventListener("endTween", readyToRemove);
            this.removeMe();
            GameInterfaceManager.getInstance().checkNextMessageInQueue();
        }
        
        private function fullyOpen(e:Event):void
        {
            GameInterfaceManager.getInstance().startPopUpTimer();
        }
    }
}