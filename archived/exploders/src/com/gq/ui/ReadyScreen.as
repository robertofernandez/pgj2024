package com.gq.ui 
{
    public class ReadyScreen extends Pages
    {

        public function ReadyScreen():void
        {
            super(new BonusBoardMc());
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
