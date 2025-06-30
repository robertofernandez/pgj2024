package com.willdom.games.bomberman.communication
{
    import com.smartfoxserver.v2.entities.data.SFSObject;

    public class GameMessage
    {
        private var _command:String;
        private var _params:SFSObject;
        private var _recipients:Array;
        public function GameMessage(command:String, params:SFSObject = null, recipients:Array = null)
        {
            _command = command;
            _params = params != null ? params : new SFSObject();
            _recipients = recipients != null ? recipients : new Array();
        }
        
        public function get command():String { return _command; }
        public function set command(value:String):void { _command = value; }
        
        public function get params():SFSObject { return _params; }
        public function set params(value:SFSObject):void { _params = value; }
        
        public function get recipients():Array { return _recipients ; }
        public function set recipients(value:Array):void { _recipients = value; }
        
        public function getSFSObject():SFSObject
        {
            var o:SFSObject = new SFSObject();
            o.putUtfStringArray("r", _recipients);
            o.putUtfString("c", _command);
            o.putSFSObject("p", _params);
            
            return o;
        }
    }
}