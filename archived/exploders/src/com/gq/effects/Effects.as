package com.gq.effects
{
    import com.gq.moveobject.MoveObject;
    import com.gq.system.*;
    import flash.display.MovieClip;
    import flash.display.Sprite;
    import flash.events.Event;

    public class Effects extends MoveObject
    {
        public function Effects():void
        {
            objectType=EFFECT;
            GameTools.pushArr( GameData.instance.actionArr, this )
        }
        override public function updataEvent():void
        {
            if( ++deadCount == 10 )
            {
                myAction();
            }
        }
        public function createEffect( who:Sprite, index:String, _x:Number, _y:Number, _z:Number):void
        {
            myMcName = index;
            var tempClass:Class = GameTools.getMeBySwf( "", index );
            var tempMc:MovieClip = new tempClass();
            myX = _x;
            myY = _y;
            myZ = _z;
            myCurrentPositionX = Math.round( myX / GameData.instance.rectWidth );
            myCurrentPositionY = Math.round( (myY - GameData.instance.upLine) / GameData.instance.rectHeight );
            who.addChild ( tempMc );
            _this = tempMc;
            _this["myHost"] = this;
            data_index = uint( index.substring( index.indexOf( "_" ) + 1, index.length ) ) - 1;
            distX = _this.width / 2;
            distY = _this.height;
            initMyData ();
        }
        protected function myAction():void
        {
            removeMe();
        }
        override public function removeMe():void
        {
            GameTools.unPushArr( GameData.instance.actionArr, this )
            _this.parent.removeChild( _this )
        }
    }
}