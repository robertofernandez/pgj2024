package com.willdom.games.bomberman.statemachine
{
    import com.gq.system.GameData;
    import com.gq.system.GameSys;
    import com.smartfoxserver.v2.entities.data.SFSObject;
    import com.willdom.games.bomberman.communication.RequestCodes;
    import com.willdom.games.bomberman.communication.SmartFoxClientSingleton;
    import com.willdom.games.bomberman.config.GameConfigManager;
    import com.willdom.games.bomberman.gameobjects.GameObjectsContainer;
    import com.willdom.games.explodersmmo.shared.events.LobbyGameCommunicationEvent;
    import com.willdom.util.helpers.EventListenerManager;
    
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.TimerEvent;
    import flash.utils.Timer;

    public class LoadingGameStatus extends BasicStatusWithEventHandling
    {
        private var waitingW:WaitingMC;
        public var container:Sprite;
        private var gameObjectsContainer:GameObjectsContainer;
        
        public function LoadingGameStatus(gameObjectsContainer:GameObjectsContainer)
        {
            this.gameObjectsContainer = gameObjectsContainer;
        }
        
        override public function init(params:SFSObject):void
        {
            waitingW = gameObjectsContainer.waitingW;
            
            if(!SmartFoxClientSingleton.getInstance().smartFoxClient.myself.isSpectatorInRoom(SmartFoxClientSingleton.getInstance().smartFoxClient.gameRoom))
            {
                SmartFoxClientSingleton.getInstance().smartFoxClient.sendGameRequest(RequestCodes.GAME_READY);
            }
        }
        
        override public function dispose(params:SFSObject):void
        {
            if (waitingW.parent == container.parent && !SmartFoxClientSingleton.getInstance().smartFoxClient.myself.isSpectatorInRoom(SmartFoxClientSingleton.getInstance().smartFoxClient.gameRoom))
            {
                container.parent.removeChild(waitingW);
                container.visible = true;
            }
        }
        
        public function initHideLoadingScreenTimer():void
        {
            var t:Timer = new Timer(800, 1);
            EventListenerManager.setListenerTo(t, TimerEvent.TIMER_COMPLETE, hideLoadingScreen);
            t.start();
        }
        
        private function hideLoadingScreen(e:TimerEvent):void
        {
            if (waitingW.parent == container.parent && container.parent != null)
            {
                GameData.instance.gameSync = true;
                GameConfigManager.getInstance().extendedContainer = GameData.instance.syncExtendedContainer;  
                
                container.parent.removeChild(waitingW);
                container.visible = true;
                
                if(SmartFoxClientSingleton.getInstance().smartFoxClient.myself.isSpectatorInRoom(SmartFoxClientSingleton.getInstance().smartFoxClient.gameRoom)){             
                    GameData.instance.checkSoundVolume();
                }
            }
        }
        
    }
}