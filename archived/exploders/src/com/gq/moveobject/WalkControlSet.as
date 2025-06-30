package com.gq.moveobject
{
    import flash.geom.Point;

    public interface WalkControlSet
    {
        function get local():Boolean;
        function getNextPosition(currentDirectionRequested:int):Point;
        
        /**
         * @return 'standing' or 'walking'
         */
        function get status():String;

        /**
         * @return 'left', 'right', 'up' or 'down'
         */
        function get direction():String;
        function restoreBornTilePosition(initialTile:Point):void;
        function get currentTile():Point;
        function setInitialTilePosition(initialPosition:Point):void;
        function dispose():void;
    }
}