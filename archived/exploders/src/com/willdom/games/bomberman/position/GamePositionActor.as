package com.willdom.games.bomberman.position
{
    import com.smartfoxserver.v2.entities.data.SFSObject;

    public interface GamePositionActor
    {
        function execute(data:SFSObject):void;
    }
}