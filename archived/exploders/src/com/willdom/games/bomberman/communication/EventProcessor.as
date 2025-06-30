package com.willdom.games.bomberman.communication
{
    import com.smartfoxserver.v2.SmartFox;
    import com.smartfoxserver.v2.core.SFSEvent;
    import com.smartfoxserver.v2.entities.Room;
    import com.smartfoxserver.v2.entities.User;
    import com.smartfoxserver.v2.entities.data.SFSObject;
    import com.smartfoxserver.v2.entities.invitation.Invitation;
    import com.smartfoxserver.v2.entities.variables.UserVariable;
    import com.smartfoxserver.v2.exceptions.SFSError;
    import com.smartfoxserver.v2.requests.ExtensionRequest;
    import com.willdom.games.bomberman.events.MessageEvent;
    import com.willdom.games.bomberman.events.SmartFoxClientEvent;
    import com.willdom.games.bomberman.events.UserEvent;
    import com.willdom.games.bomberman.events.UserVarsEvent;
    import com.willdom.games.explodersmmo.shared.inventory.InventoryManager;
    
    import flash.events.EventDispatcher;

    public class EventProcessor extends EventDispatcher
    {
        private var _sfs:SmartFox;
        private var _sfsClient:SmartFoxClient;
        
        private var customExtensionResponsesListener:EventDispatcher;
        
        public function EventProcessor(sfs:SmartFox, client:SmartFoxClient)
        {
            _sfs = sfs;
            _sfsClient = client;
            _sfs.addEventListener(SFSEvent.USER_ENTER_ROOM, onUserEnterRoom);
            _sfs.addEventListener(SFSEvent.USER_EXIT_ROOM, onUserExitRoom);
            _sfs.addEventListener(SFSEvent.EXTENSION_RESPONSE, onExtensionResponse);
            _sfs.addEventListener(SFSEvent.CONNECTION_LOST, onConnectionLost);
            _sfs.addEventListener(SFSEvent.ROOM_VARIABLES_UPDATE, onRoomVarsUpdate);
            _sfs.addEventListener(SFSEvent.USER_VARIABLES_UPDATE, onUserVarsUpdate);
            
        }
        
        public function redirectExtensionResponsesTo(listener:EventDispatcher):void
        {
            customExtensionResponsesListener = listener;
            _sfs.removeEventListener(SFSEvent.EXTENSION_RESPONSE, onExtensionResponse);
            listener.addEventListener(SFSEvent.EXTENSION_RESPONSE, onExtensionResponse);
        }
        
        public function reEngageExtensionResponses():void
        {
            if(customExtensionResponsesListener != null){
                customExtensionResponsesListener.removeEventListener(SFSEvent.EXTENSION_RESPONSE, onExtensionResponse);
            }
            _sfs.addEventListener(SFSEvent.EXTENSION_RESPONSE, onExtensionResponse);
        }
        
        private function onUserEnterRoom(ev:SFSEvent):void
        {    
            
            var e:UserEvent = new UserEvent(UserEvent.ENTER_ROOM);
            e.room = ev.params.room;
            e.user = ev.params.user;
            
            _sfsClient.dispatchEvent(e);
                    
        }
        
        private function onUserExitRoom(ev:SFSEvent):void
        {    
            var e:UserEvent = new UserEvent(UserEvent.EXIT_ROOM);
            e.room = ev.params.room;
            e.user = ev.params.user;
            
            _sfsClient.dispatchEvent(e);
            
        }
        
        private function onExtensionResponse(ev:SFSEvent):void
        {
            switch(ev.params.cmd){
                case ExtensionResponses.GAME_MESSAGE:
                    processGameMessage(ev);
                    break;
                case ExtensionResponses.START_GAME:
                    processGameStart(ev);
                    break;
                case ExtensionResponses.GAME_READY:
                    processGameReady(ev);
                    break;
                case ExtensionResponses.END_GAME:
                    processEndGame(ev);
                    break;
                case ExtensionResponses.BEGIN_GAME:
                    processBeginGame(ev);
                    break;
                case ExtensionResponses.RESTART_GAME:
                    processRestartGame(ev);
                    break;
            }
        }
        
        private function onRoomVarsUpdate(ev:SFSEvent):void
        {
            var room:Room = ev.params.room as Room;
            var vars:Array = ev.params.changedVars as Array;
            
            var e:RoomVarsEvent = new RoomVarsEvent(RoomVarsEvent.VARS_CHANGED);
            e.room = room;
            e.vars = vars;
            _sfsClient.dispatchEvent(e);
        }
        
        private function onUserVarsUpdate(ev:SFSEvent):void
        {
            var user:User =  ev.params.user as User;
            var vars:Array = ev.params.changedVars as Array;
            
            var e:UserVarsEvent = new UserVarsEvent(UserVarsEvent.USER_VARS_CHANGED);
            e.user = user;
            e.vars = vars;
            
            if(user.id == SmartFoxClientSingleton.getInstance().smartFoxClient.myself.id)
            {
                for(var i:int = 0; i < vars.length; i++)
                {
                    if(vars[i] == "inventory")
                    {
                        InventoryManager.instance.updateInventory(user.getVariable("inventory").getSFSObjectValue().getInt("coins"), user.getVariable("inventory").getSFSObjectValue().getSFSArray("chars"));
                    }
                }
            }
            _sfsClient.dispatchEvent(e);
        }
        
        private function processGameStart(ev:SFSEvent):void
        {
            var e:MessageEvent = new MessageEvent(MessageEvent.GAME_START);

            _sfsClient.dispatchEvent(e);
        }
        
        private function processGameReady(ev:SFSEvent):void
        {
            var e:MessageEvent = new MessageEvent(MessageEvent.GAME_READY);
            e.params = SFSObject(ev.params.params);
            _sfsClient.dispatchEvent(e);
        }
        
        private function processEndGame(ev:SFSEvent):void
        {
            var e:MessageEvent = new MessageEvent(MessageEvent.END_GAME);
            e.params = SFSObject(ev.params.params);
            _sfsClient.dispatchEvent(e);
        }
        
        private function processBeginGame(ev:SFSEvent):void
        {
            var e:MessageEvent = new MessageEvent(MessageEvent.BEGIN_GAME);
            e.params = SFSObject(ev.params.params);
            _sfsClient.dispatchEvent(e);
        }
        
        private function processRestartGame(ev:SFSEvent):void
        {
            var e:MessageEvent = new MessageEvent(MessageEvent.GAME_READY);
            e.params = SFSObject(ev.params.params);
            _sfsClient.dispatchEvent(e);
        }
        
        private function processGameMessage(ev:SFSEvent):void
        {
            var e:MessageEvent = new MessageEvent(MessageEvent.GAME_MESSAGE);
            var messageParams:SFSObject = ev.params.params as SFSObject;

            e.params = messageParams.getSFSObject("p").getSFSObject("p") as SFSObject;
            e.message =  messageParams.getSFSObject("p").getUtfString("c");
            e.sender = _sfs.userManager.getUserByName(messageParams.getUtfString("s"));
            _sfsClient.dispatchEvent(e);
        }
                
        private function onConnectionLost(ev:SFSEvent):void
        {
            var e:SmartFoxClientEvent = new SmartFoxClientEvent(SmartFoxClientEvent.CONNECTION_LOST);
            e.reason=ev.params.reason;
            _sfsClient.dispatchEvent(e);
        }
    }
}