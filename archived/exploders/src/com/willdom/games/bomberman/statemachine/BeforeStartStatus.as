package com.willdom.games.bomberman.statemachine
{
    import com.smartfoxserver.v2.entities.data.SFSObject;
    import com.willdom.games.bomberman.communication.SmartFoxClientSingleton;
    import com.willdom.games.bomberman.controllers.ConfigController;
    import com.willdom.games.bomberman.gameobjects.GameObjectsContainer;
    
    import flash.display.Sprite;

    public class BeforeStartStatus extends BasicStatusWithEventHandling
    {
        public var waitingW:WaitingMC;
        public var container:Sprite;
        private var gameObjectsContainer:GameObjectsContainer;
        
        public function BeforeStartStatus(gameObjectsContainer:GameObjectsContainer)
        {
            this.gameObjectsContainer = gameObjectsContainer;
        }
        
        override public function init(params:SFSObject):void
        {
            waitingW = gameObjectsContainer.waitingW;
            container.parent.addChild(waitingW);
            
            if (ConfigController.getInstance().gameTestingMode)
            {
                waitingW.visible = false;
            }
            
            waitingW.registerLayer.visible = false;
            
            if (SmartFoxClientSingleton.getInstance().smartFoxClient.gameRoom != null && 
                SmartFoxClientSingleton.getInstance().smartFoxClient.myself.isSpectatorInRoom(SmartFoxClientSingleton.getInstance().smartFoxClient.gameRoom))
            {
                LanguageManager.getInstance().registerTag("_loadingGameSpectator", waitingW.titleTxt, "text");
            }
            else
            {
                LanguageManager.getInstance().registerTag("_waitingTitle", waitingW.titleTxt, "text");
            }
        }
        
        override public function dispose(params:SFSObject):void
        {
        }
    }
}