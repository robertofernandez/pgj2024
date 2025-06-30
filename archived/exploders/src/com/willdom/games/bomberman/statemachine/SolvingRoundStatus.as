package com.willdom.games.bomberman.statemachine
{
    import com.gq.system.GameData;
    import com.smartfoxserver.v2.entities.data.SFSObject;
    import com.willdom.games.bomberman.consts.ServerMessages;
    import com.willdom.games.bomberman.gameobjects.GameObjectsContainer;
    
    /**
     * Game status that represents the stage when game has finishing conditions,
     * but still has bombs to explode and/or blocks to fall.
     */
    public class SolvingRoundStatus extends BasicStatusWithEventHandling
    {
        private var gameObjectsContainer:GameObjectsContainer;
        
        public function SolvingRoundStatus(gameObjectsContainer:GameObjectsContainer)
        {
            this.gameObjectsContainer = gameObjectsContainer;
        }
        
        override public function init(params:SFSObject):void
        {
            GameData.instance.endingState = true;
            
            registerFunction(ServerMessages.DEADLY_BLOCK_SHADOW, onDeadlyBlockShadow);
            registerFunction(ServerMessages.DEADLY_BLOCK_SETTLE, onDeadlyBlockSettle);
            registerFunction(ServerMessages.POSITION_SWITCH, onPositionSwitch);
            registerFunction(ServerMessages.BOMB_SKIN, onBombSkin);
        }
        
        private function onDeadlyBlockShadow(params:SFSObject):void
        {
            gameObjectsContainer.onDeadlyBlockShadow(params);
        }
        
        private function onDeadlyBlockSettle(params:SFSObject):void
        {
            gameObjectsContainer.onDeadlyBlockSettle(params);
        }
        
        private function onPositionSwitch(params:SFSObject):void
        {
            gameObjectsContainer.onPositionSwitch(params);
        }
        
        private function onBombSkin(params:SFSObject):void
        {
            gameObjectsContainer.onBombSkin(params);
        }

        override public function dispose(params:SFSObject):void
        {
            //TODO: implement function
        }
    }
}