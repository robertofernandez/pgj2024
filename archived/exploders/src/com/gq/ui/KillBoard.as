package com.gq.ui
{
    import com.gq.system.GameData;
    
    import configuration.StageModes;
    
    import flash.events.Event;
    
    import com.willdom.util.helpers.EventListenerManager;

    public class KillBoard extends Pages
    {
        
        public function KillBoard():void
        {    
            var killMessagesMc:MessagesMC = new MessagesMC();
            if( GameData.instance.STAGE_MODE == StageModes.PENGUIN){
                killMessagesMc.gotoAndStop( "penguin" );
            }
            super( killMessagesMc );
            EventListenerManager.setListenerTo(this.page, "endTween", readyToRemove);
        }
        
        override protected function init():void
        {
            super.init();
        }
        
        public function menuFunc( ):void
        {
            removeMe();
        }
        
        override public function removeMe():void
        {
            this.page.submessage.gotoAndPlay("out");
        }
        
        private function readyToRemove(e:Event):void{
            
            this.page.removeEventListener("endTween", readyToRemove);
            this.page.parent.removeChild(this.page);            
            
        }
        
    }
}