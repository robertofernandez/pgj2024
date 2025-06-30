package com.gq.system
{
    import com.gq.moveobject.MoveObject;
    import com.gq.system.*;
    import flash.display.MovieClip;
    import flash.events.Event;

    public class MonsterCreater
    {
        private var createCount:uint;
        private var createCD:uint = 50;
        private var createNum:uint;
        
        public function MonsterCreater():void
        {
            createCD = 20;
            createCount = createCD;
        }
        public function updataEvent():void
        {
            if( ++createCount >= createCD && !GameData.instance.can_pass )
            {
                createCount = 0;
            }
        } 

        /**
         * Creating monsters and other stage elements.
         */
        public function createObj( Parent:String, Name:String, index:String, _x:Number, _y:Number, _z:Number, _walkPath:Array, createId:uint = 0 ):MoveObject
        {
            var tempClass:Class = GameTools.createClass( "com.gq.moveobject." + Name );
            var mc:MoveObject = new tempClass();
            mc.init ( _x, _y, _z, "stand1" );
            GameTools.pushArr ( GameData.instance.actionArr, mc );
            GameTools.pushArr ( GameData.instance.objectArr, mc );
            mc.createMe ( GameData.instance[ Parent + "Container" ], index, 0, "objects", _walkPath );
            return mc;
        }
        
        public function reinitializeObj(Parent:String, Name:String, index:String, _x:Number, _y:Number, _z:Number, _walkPath:Array, obj:MovieClip, createId:uint = 0):MoveObject{
            var tempClass:Class = GameTools.createClass("com.gq.moveobject." + Name );
            var mc:MoveObject = new tempClass();
            mc.init ( _x, _y, _z, "stand1" );
            GameTools.pushArr(GameData.instance.actionArr, mc);
            GameTools.pushArr(GameData.instance.objectArr, mc);
            mc.createMe ( GameData.instance[ Parent + "Container" ], index, 0, "objects", _walkPath, obj);
            return mc;
        }
    }
}