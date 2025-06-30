package com.willdom.games.bomberman.spectators
{
    import ar.com.sodhium.util.datastructures.Priorizable;
        
    import com.smartfoxserver.v2.core.SFSEvent;
    import com.smartfoxserver.v2.entities.data.ISFSObject;
        
    public class MessageContainer implements Priorizable
    {
        private var _seq:Number;
        private var _event:SFSEvent;

        public function MessageContainer(seq:Number, event:SFSEvent)
        {
            _seq = seq;
            _event = event;
        }

        public function get event():SFSEvent
        {
            return _event;
        }

        public function hasLowerPriorityThan(anotherElement:Priorizable):Boolean
        {
            return _seq > (anotherElement as MessageContainer).seq;
        }

        public function get seq():Number
        {
            return _seq;
        }
    }
}