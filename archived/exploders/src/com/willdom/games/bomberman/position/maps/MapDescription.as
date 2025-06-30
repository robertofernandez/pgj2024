package com.willdom.games.bomberman.position.maps
{
    public interface MapDescription
    {
        function getObjectType(x:Number, y:Number):uint;
        function get mapName():String;
    }
}