package com.willdom.games.bomberman.statemachine
{
    import com.smartfoxserver.v2.entities.data.SFSObject;

    public interface Status
    {
        function init(params:SFSObject):void;
        function handleMessage(type:String, params:SFSObject):void;
        function dispose(params:SFSObject):void;
    }
}