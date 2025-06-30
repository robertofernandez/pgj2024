package com.willdom.games.bomberman.spectators
{
    import com.gq.moveobject.Person;
    import com.gq.moveobject.RemoteControlSet;
    import com.gq.system.GameData;
    import com.gq.system.GameSys;
    import com.smartfoxserver.v2.core.SFSEvent;
    import com.smartfoxserver.v2.entities.data.ISFSArray;
    import com.smartfoxserver.v2.entities.data.ISFSObject;
    import com.smartfoxserver.v2.entities.data.SFSArray;
    import com.smartfoxserver.v2.entities.data.SFSObject;
    import com.willdom.games.bomberman.communication.SmartFoxClientSingleton;
    import com.willdom.games.bomberman.consts.ServerMessages;
    import com.willdom.games.bomberman.events.MessageEvent;
    import com.willdom.games.explodersmmo.shared.model.CustomLogger;
    import com.willdom.util.helpers.EventListenerManager;
    
    import flash.events.EventDispatcher;
    
    public class ServerMessagesHandler extends EventDispatcher
    {
        private var messageSequencer:MessagesSequencer;
        private var roundNum:uint;
        private var matchNum:int = 0;
        private var syncStarted:Boolean = false;
        public var actionsEnd:Boolean = false;
        private var syncFinished:Boolean = false;
        public var firstRecievedMessageSequenceNumber:int = 0;
        
        public function ServerMessagesHandler()
        {
            EventListenerManager.setListenerTo(SmartFoxClientSingleton.getInstance().smartFoxClient.sfs, SFSEvent.EXTENSION_RESPONSE, onExtensionResponse);
        }
        
        public function initialize():void{
            SmartFoxClientSingleton.getInstance().smartFoxClient.redirectExtensionResponsesTo(this);
        }
        
        private function onExtensionResponse(e:SFSEvent):void
        {
            if (GameData.DEBUG_MODE && (e.params["cmd"] == MessageEvent.GAME_REMATCH_STARTED && SmartFoxClientSingleton.getInstance().smartFoxClient.myself.isSpectatorInRoom(SmartFoxClientSingleton.getInstance().smartFoxClient.gameRoom)))
            {
                trace("Game Rematch event recieved in spectator client");
            }
            
            if(e.params["cmd"] == MessageEvent.SYNC_FINISHED)
            {
                syncFinished = true; 
            }
            else if(SmartFoxClientSingleton.getInstance().smartFoxClient.gameRoom != null && SmartFoxClientSingleton.getInstance().smartFoxClient.myself.isSpectatorInRoom(SmartFoxClientSingleton.getInstance().smartFoxClient.gameRoom) && e.params["cmd"] != MessageEvent.GAME_REMATCH_STARTED)
            {
                storeAndSort(e);
            } 
            else
            {
                outputCommand(e);
            }
        }

        public function isSynchronized():Boolean
        {
            return syncStarted && messageSequencer.hasEmptyQueue();
        }

        private function storeAndSort(e:SFSEvent):void
        {
            roundNum = e.params["params"].getInt("rnum");
            if (!syncStarted)
            {
                messageSequencer = new MessagesSequencer(roundNum);
                EventListenerManager.setListenerTo(messageSequencer, SFSEvent.EXTENSION_RESPONSE, outputCommand);
                syncStarted = true;
                firstRecievedMessageSequenceNumber = (e.params["params"] as SFSObject).getLong("meseq");
                var outPut:SFSObject = new SFSObject();
                outPut.putLong("lastPackage", firstRecievedMessageSequenceNumber);

                outPut.putInt("rnm", roundNum);
                SmartFoxClientSingleton.getInstance().smartFoxClient.sendExtensionRequestToGameRoom("syncSpec", outPut);
            }

            messageSequencer.addMessage(e, syncFinished);
            actionsEnd = true;
            var iterator:int = 0;
            if(messageSequencer.queueLevel() > 1)
            {
                for(var i:uint=0; i< Person.allPersons.length; i++)
                {
                   var remoteControlSet:RemoteControlSet = GameData.instance.walkControls[Person.allPersons[i].myId] as RemoteControlSet;
                   if(remoteControlSet != null)
                   {
                       while(remoteControlSet.getPendingPositions() > 0)
                       {
                           iterator ++;
                           if(iterator >= 20)
                           {
                               break;
                           }
                           GameSys.triggerUpdataEvent();
                           actionsEnd = false;
                       }
                   }
                }
            }
        }

        public function outputCommand(e:SFSEvent):void
        {
            var commandName:String = e.params["cmd"];
            if( commandName == "stch")
            {
                var statusName:String = e.params["params"].getUtfString(ServerMessages.STATUS_NAME_PARAM);
                if("inRound" == statusName)
                {
                    GameData.instance.currentRound = (e.params["params"] as SFSObject).getInt("rnum");
                    var playersList:ISFSArray = (e.params["params"] as SFSObject).getSFSArray("plist");
                    traceInRoundMessage(playersList);
                    var personsNotIntList:Array = Person.personsNotInList(playersList);
                    for each(var playerName:String in personsNotIntList)
                    {
                        if (GameData.DEBUG_MODE)
                        {
                            CustomLogger.getInstance().log("removing player " + playerName +" before start round");
                        }
                        GameSys.onUserExitRoom((Person.getPersonByName(playerName) as Person).myName);
                    }
                }
            }

            if (SmartFoxClientSingleton.getInstance().smartFoxClient.gameRoom != null)
            {
                this.dispatchEvent(e);
            }
        }
        
        private function traceInRoundMessage(playersList:ISFSArray):void
        {
            var output:String = "Players in round: |";
            for(var i:Number = 0; i < playersList.size(); i++)
            {
                output += playersList.getUtfString(i) + "|";
            }
            CustomLogger.getInstance().log(output);
            CustomLogger.getInstance().log("All persons: " + Person.printAllPersons());
        }
    }
}