package com.gq.ui
{
    public class FocusBoard extends Pages
    {
        
        public function FocusBoard():void
        {
            super(new FocusBoardMC());
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
            this.page.visible = false;
            super.removeMe();
        }
    }
}