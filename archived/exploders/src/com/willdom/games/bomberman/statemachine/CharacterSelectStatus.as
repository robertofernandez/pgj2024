package com.willdom.games.bomberman.statemachine
{
    import com.gq.system.GameData;
    import com.gq.system.GameSys;
    import com.gq.ui.InGameChatManager;
    import com.gq.ui.InGameUserListManager;
    import com.greensock.TweenMax;
    import com.greensock.easing.Linear;
    import com.smartfoxserver.v2.SmartFox;
    import com.smartfoxserver.v2.entities.User;
    import com.smartfoxserver.v2.entities.data.ISFSArray;
    import com.smartfoxserver.v2.entities.data.SFSObject;
    import com.willdom.games.bomberman.communication.ParamCodes;
    import com.willdom.games.bomberman.communication.SmartFoxClientSingleton;
    import com.willdom.games.bomberman.consts.PlayerVars;
    import com.willdom.games.bomberman.consts.ServerMessages;
    import com.willdom.games.bomberman.controllers.ConfigController;
    import com.willdom.games.bomberman.events.PlayerEvent;
    import com.willdom.games.bomberman.gameobjects.GameObjectsContainer;
    import com.willdom.games.bomberman.position.maps.SfsBasedMapDescription;
    import com.willdom.games.bomberman.rooms.RoomLocalProperties;
    import com.willdom.games.bomberman.user.UserLocalProperties;
    import com.willdom.games.explodersmmo.shared.consts.SharedVars;
    import com.willdom.games.explodersmmo.shared.events.SharedEventType;
    import com.willdom.games.explodersmmo.shared.inventory.InventoryManager;
    import com.willdom.games.explodersmmo.shared.inventory.InventoryOwnedCharacterInfo;
    import com.willdom.games.explodersmmo.shared.model.CustomLogger;
    import com.willdom.games.explodersmmo.shared.shop.ShopInfoManager;
    //import com.willdom.games.explodersmmo.shared.tracker.HoneyTracksHelper;
    import com.willdom.util.helpers.EventListenerManager;
    
    import flash.display.MovieClip;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.events.TimerEvent;
    import flash.filters.GlowFilter;
    import flash.geom.ColorTransform;
    import flash.text.TextField;
    import flash.utils.Timer;

    public class CharacterSelectStatus extends BasicStatusWithEventHandling
    {
        public var container:Sprite;
        private var gameObjectsContainer:GameObjectsContainer;
        
        public function CharacterSelectStatus(gameObjectsContainer:GameObjectsContainer)
        {
            this.gameObjectsContainer = gameObjectsContainer;
        }
        
        override public function init(params:SFSObject):void
        {
            registerFunction(ServerMessages.CHARACTER_SELECTION_TIMER_TICK, onCharacterSelectionTimerTick);
            registerFunction(PlayerEvent.PLAYER_SELECTED, onPlayerSelected);
            registerFunction(ServerMessages.USER_LEAVE, onUserLeave);
            registerFunction(ServerMessages.CHARACTER_SELECT_VOTEMAP_STATS, onVoteMapStatsUpdated);
            
            GameData.instance.afterCharSelectStatus = true;
            GameData.instance.gameBox.visible = false;
            GameData.instance.playersList = [];
            
            for (var i:uint = 0; i < params.getSFSArray("plist").size(); i++)
            {
                GameData.instance.playersList[i] = params.getSFSArray("plist").getElementAt(i);
            }
            
            CustomLogger.getInstance().log("[com.gq.system.DocumentClass] Character selection screen.");
            
            var seed:int = params.getInt(ParamCodes.SEED_VALUE);
            var charactersQty:uint = 14;
            Login.newInstance(container).remoteSeed = seed%charactersQty+1;
            Login.getInstance(container).fillPlayersArray(charactersQty);
            CustomLogger.getInstance().log("[com.gq.system.DocumentClass] Seed: " + seed + ".-");
            
            var mapDescription:SfsBasedMapDescription = new SfsBasedMapDescription(params.getUtfString("mapName"),params.getSFSArray("mapDescription"));
            GameData.instance.initData();
            GameSys.initGameVisualResources();
            GameSys.setBuildParams(seed, mapDescription);

            var infoScreen:MovieClip = (GameData.instance.infoWindow.getChildAt(0) as MovieClip);
            
            InGameChatManager.getInstance().onCharacterSelectionStatus();
            InGameUserListManager.getInstance().onCharacterSelectionStatus();
            GameData.instance.gameObjectsContainer.buildCharacterSelectDependencies();
            GameData.instance.gameObjectsContainer.characterSelectScreen.setUpVoteMaps(params.getSFSArray("mapNames"));
            GameData.instance.gameObjectsContainer.characterSelectScreen.addCharactersFromServer(params.getSFSArray("charset"))
            GameData.instance.gameObjectsContainer.characterSelectScreen.showCharacterScreen();
        }
        
        private function onInventoryUpdated(event:Event):void
        {
            gameObjectsContainer.selectionScreen.coins.label.text = InventoryManager.instance.coins.toString();
        }
        
        private function onCharacterSelectionTimerTick(params:SFSObject):void
        {
            GameData.instance.gameObjectsContainer.characterSelectScreen.onCharacterSelectionTimerTick(params);
        }
        
        private function onPlayerSelected(params:SFSObject):void
        {
            GameData.instance.gameObjectsContainer.characterSelectScreen.onPlayerSelected(params);
        }
        
        private function onUserLeave(params:SFSObject):void
        {
            GameData.instance.gameObjectsContainer.characterSelectScreen.onUserLeave(params);
        }
        
        private function onVoteMapStatsUpdated(params:SFSObject):void
        {
            GameData.instance.gameObjectsContainer.characterSelectScreen.onVoteMapStatsUpdated(params.getSFSArray("mapVotes"));
        }
        
        override public function dispose(params:SFSObject):void
        {
            if(!SmartFoxClientSingleton.getInstance().smartFoxClient.myself.isSpectator)
            {
                GameData.instance.gameBox.visible = true;
            }
            
            GameData.instance.gameObjectsContainer.characterSelectScreen.hideCharacterScreen();
            InGameUserListManager.getInstance().onCharacterSelectionStatus();
        }
    }
}