package com.gq.ui
{
    import com.gq.system.*;
    import flash.display.MovieClip;
    import flash.display.SimpleButton;
    import flash.display.Sprite;
    import flash.events.MouseEvent;
    //
    public class Pages extends MovieClip
    {
        public var page:MovieClip;
        protected var myCount:uint;
        protected var mySound:String = "";
        public var callBackFunc:Function;

        public function Pages(p:MovieClip):void
        {
            page=p;
            init();
        } 

        protected function init():void
        {
            if( mySound != "" )
            {
                SoundClass.addMusic ( "music", mySound, 999 )
            }
        }
        
        protected function clickHD( evt:MouseEvent ):void
        {
            this[ evt.target.name + "Func" ]();
            SoundClass.addMusic ( "sound", "press" )
               
        }
        protected function myBtnsFunc():void
        {
        }
        
        public function removeMe():void
        {
            if(parent!=null){
                page.parent.removeChild( page );
            }
        }
    }
}