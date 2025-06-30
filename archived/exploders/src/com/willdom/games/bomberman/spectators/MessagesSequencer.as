package com.willdom.games.bomberman.spectators
{
    import ar.com.sodhium.util.datastructures.Heap;
    
    import com.gq.system.GameData;
    import com.gq.system.GameSys;
    import com.smartfoxserver.v2.core.SFSEvent;
    import com.smartfoxserver.v2.entities.data.ISFSArray;
    import com.smartfoxserver.v2.entities.data.ISFSObject;
    import com.smartfoxserver.v2.entities.data.SFSArray;
    import com.smartfoxserver.v2.entities.data.SFSObject;
    import com.willdom.games.bomberman.consts.ServerMessages;
    
    import flash.events.EventDispatcher;
    import flash.events.IEventDispatcher;
       
    public class MessagesSequencer extends EventDispatcher
    {
        private var heap:Heap;
        private var nextItemSequence:Number;
        private var requestedRound:int;
        private var firstInRoundItemSequence:Number;
        private var firstInRoundItemSet:Boolean;
        private var waitingForNextItemNumber:Boolean;
        private var _syncFinished:Boolean = false;

        public function MessagesSequencer(requestedRound:int, target:IEventDispatcher=null)
        {
            super(target);
            nextItemSequence = 1;
            this.requestedRound = requestedRound;
            GameData.instance.currentRound = requestedRound;
            waitingForNextItemNumber = false;
            heap = new Heap();
        }
        
        private function setfirstInRoundItemSequenceIfInRoundMessage(cmd:String, params:ISFSObject):void
        {
            if(cmd == "stch")
            {
                var statusName:String = params.getUtfString(ServerMessages.STATUS_NAME_PARAM);
                var roundNumber:int = params.getInt("rnum");
                
                if(!firstInRoundItemSet && "inRound" == statusName)
                {
                    firstInRoundItemSet = true;
                    firstInRoundItemSequence = params.getLong("meseq") as int;
                    if(waitingForNextItemNumber)
                    {
                        nextItemSequence = firstInRoundItemSequence;
                    }
                    /*Refactor change
                    // FIXME check why this is here
                    if (GameSys.infoScreen!=null && GameSys.infoScreen.bombTimer != null)
                    {
                        GameSys.infoScreen.bombTimer.timerMessage.text = LanguageManager.getInstance().getAndReplaceTexts("_roundNumber", new Array("%num%", "%total%"), new Array(GameData.instance.currentRound.toString(), GameData.instance.round.toString()));
                    }
                    */
                }
            }
        }

        public function addMessage(e:SFSEvent, syncFinished:Boolean = false):void
        {
            if(syncFinished && !_syncFinished)
            {
                _syncFinished = true;
                if(GameData.DEBUG_MODE)
                {
                    trace("Sync finished, next item seq set to " + nextItemSequence);
                }
            }
            var cmd:String = e.params["cmd"];
            var params:ISFSObject = e.params["params"];
            if(requestedRound != 0)
            {
                setfirstInRoundItemSequenceIfInRoundMessage(cmd, params);
            }
            else if(GameData.DEBUG_MODE)
            {
                trace("Requested round 0!");
            }
            var container:MessageContainer;
            if(cmd != "syncSpec")
            {
                container = new MessageContainer(params.getLong("meseq"), e);
                heap.addElement(container);
            }
            else
            {
                var messages:ISFSArray = params.getSFSArray("msgs");
                for(var i:int = 0; i < messages.size(); i++)
                {
                    var item:ISFSObject = messages.getSFSObject(i);
                    var eventParams:Object = new Object();
                    eventParams["cmd"] = item.getUtfString("cmd");
                    eventParams["params"] = item.getSFSObject("params");
                    if(requestedRound != 0)
                    {
                        setfirstInRoundItemSequenceIfInRoundMessage(item.getUtfString("cmd"), item.getSFSObject("params"));
                    }
                    var event:SFSEvent = new SFSEvent(SFSEvent.EXTENSION_RESPONSE, eventParams); 
                    container = new MessageContainer(item.getLong("meseq"), event)
                    heap.addElement(container);
                }
            }

            while(!heap.isEmpty() && (firstInRoundItemSet||_syncFinished) && ((heap.peek() as MessageContainer).seq <= nextItemSequence || _syncFinished))
            {
                container = heap.pop() as MessageContainer;
                if (requestedRound != 0 && !_syncFinished && (container.event.params["cmd"] == "stch"
                    && container.event.params["params"].getUtfString(ServerMessages.STATUS_NAME_PARAM) == "readyScreen"))
                {
                    if(firstInRoundItemSet)
                    {
                        nextItemSequence = firstInRoundItemSequence;
                    }
                    else
                    {
                        waitingForNextItemNumber = true;
                    }
                    dispatchEvent(container.event);
                }
                else if(container.seq < nextItemSequence)
                {
                    if(GameData.DEBUG_MODE)
                    {
                        trace("Skipping repeated message: " + container.seq + " < " + nextItemSequence);
                    }
                    continue;
                }
                else
                {
                    nextItemSequence = container.seq + 1;
                    dispatchEvent(container.event);
                }
            }
        }

        public function hasEmptyQueue():Boolean
        {
            return heap.isEmpty();
        }

        public function queueLevel():uint
        {
            return heap.size();
        }
    }
}