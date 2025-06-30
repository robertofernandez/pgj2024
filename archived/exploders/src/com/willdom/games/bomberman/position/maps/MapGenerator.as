package com.willdom.games.bomberman.position.maps
{
    public interface MapGenerator
    {
        function generateMap():void;
        function get boxes():Array;
        function get immediateOpenBoxes():Array;
        function get alwaysItemBoxes():Array;
    }
}