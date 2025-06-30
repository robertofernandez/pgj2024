package com.willdom.games.bomberman.statemachine
{
    import com.gq.system.GameData;
    import com.gq.system.GameSys;
    import com.smartfoxserver.v2.core.SFSEvent;
    import com.smartfoxserver.v2.entities.data.SFSObject;
    import com.willdom.games.bomberman.communication.ParamCodes;
    import com.willdom.games.bomberman.communication.SmartFoxClientSingleton;
    import com.willdom.games.bomberman.consts.ServerMessages;
    import com.willdom.games.bomberman.gameobjects.GameObjectsContainer;
    import com.willdom.games.bomberman.position.maps.SfsBasedMapDescription;
    import com.willdom.games.explodersmmo.shared.events.game.GameEndedEvent;
    import com.willdom.games.explodersmmo.shared.model.CustomLogger;
    import com.willdom.util.helpers.EventListenerManager;
    
    import flash.display.Sprite;
    import flash.events.TimerEvent;
    import flash.utils.Dictionary;
    import flash.utils.Timer;
    
    public class StatusManager
    {
        public static const BEFORE_START_STATUS:String = "beforeStart";
        public static const LOADING_GAME:String = "loadingGame";
        public static const CHARACTER_SELECT_STATUS:String = "charSelect";
        public static const IN_ROUND_STATUS:String = "inRound";
        public static const SOLVING_ROUND_STATUS:String = "solvingRound";
        public static const END_ROUND_STATUS:String = "endRound";
        public static const END_MATCH_STATUS:String = "endMatch";
        public static const END_GAME_STATUS:String = "endGame";
        public static const READY_STATUS:String = "readyScreen";
        public static const CALCULATING_POINTS_STATUS:String = "calculatingPoints";
        
        private var statuses:Dictionary;
        private var currentStatus:Status;
        private var beforeStartStatus:BeforeStartStatus;
        private var loadingGameStatus:LoadingGameStatus;
        private var readyStatus:ReadyStatus;
        private var characterSelectStatus:CharacterSelectStatus;
        private var inRoundStatus:InRoundStatus;
        private var endRoundStatus:EndRoundStatus;
        private var calculatingPointsStatus:CalculatingPointsStatus;
        private var endGameStatus:EndMatchStatus;
        
        private var solvingRoundStatus:SolvingRoundStatus;
        private var gameObjectsContainer:GameObjectsContainer;
        
        public function StatusManager()
        {
            gameObjectsContainer = new GameObjectsContainer();
            GameData.instance.gameObjectsContainer = gameObjectsContainer;
            
            statuses = new Dictionary();
            beforeStartStatus = new BeforeStartStatus(gameObjectsContainer);
            loadingGameStatus = new LoadingGameStatus(gameObjectsContainer);
            characterSelectStatus = new CharacterSelectStatus(gameObjectsContainer);
            readyStatus = new ReadyStatus(gameObjectsContainer);
            inRoundStatus = new InRoundStatus(gameObjectsContainer);
            endRoundStatus = new EndRoundStatus(gameObjectsContainer);
            solvingRoundStatus = new SolvingRoundStatus(gameObjectsContainer);
            calculatingPointsStatus = new CalculatingPointsStatus(gameObjectsContainer);
            endGameStatus = new EndMatchStatus(gameObjectsContainer);
                
            statuses[BEFORE_START_STATUS] = beforeStartStatus;
            statuses[LOADING_GAME] = loadingGameStatus;
            statuses[CHARACTER_SELECT_STATUS] = characterSelectStatus;
            statuses[READY_STATUS] = readyStatus;
            statuses[IN_ROUND_STATUS] = inRoundStatus;
            statuses[END_ROUND_STATUS] = endRoundStatus;
            statuses[SOLVING_ROUND_STATUS] = solvingRoundStatus;
            statuses[CALCULATING_POINTS_STATUS] = calculatingPointsStatus;
            statuses[END_MATCH_STATUS] = endGameStatus;
        }
        
        private function initializeDependencies(container:Sprite):void
        {
            beforeStartStatus.container = container;
            loadingGameStatus.container = container;
            characterSelectStatus.container = container;
        }
        
        public function init(container:Sprite):void
        {
            initializeDependencies(container);
            
            currentStatus = statuses[BEFORE_START_STATUS];
            currentStatus.init(null);
            
            EventListenerManager.setListenerTo(container.parent, GameEndedEvent.GAME_ENDED, onGameEnded);
            EventListenerManager.setListenerTo(container.parent, GameEndedEvent.GAME_ENDED_FORCED, onGameEnded);
            EventListenerManager.setListenerTo(GameData.instance.serverMessagesHandler, SFSEvent.EXTENSION_RESPONSE, onExtensionResponse);
            GameData.instance.serverMessagesHandler.initialize();
        }
        
        private function onExtensionResponse(e:SFSEvent):void{
            var params:SFSObject = e.params.params as SFSObject;
            
            if(e.params.cmd == ServerMessages.STATUS_CHANGE_RESPONSE){
                CustomLogger.getInstance().log("Status change. " + params.getUtfString(ServerMessages.STATUS_NAME_PARAM));
                GameData.instance.currentGameStatus = params.getUtfString(ServerMessages.STATUS_NAME_PARAM);
                currentStatus.dispose(params);
                if(statuses[params.getUtfString(ServerMessages.STATUS_NAME_PARAM)] != null)
                {
                    currentStatus = statuses[params.getUtfString(ServerMessages.STATUS_NAME_PARAM)];
                    currentStatus.init(params);
                }
                else
                {
                    CustomLogger.getInstance().log("[StatusManager] Status null: " + params.getUtfString(ServerMessages.STATUS_NAME_PARAM),"error");
                }
            }
            else
            {
                //TODO: Review the meaning of this condition
                if(e.params["params"].getInt("rnum") != 0 && e.params["params"].getInt("rnum") < GameData.instance.currentRound &&  e.params["params"].getUtfString(ServerMessages.STATUS_NAME_PARAM) != "inRound"){
                    return;
                }
                
                currentStatus.handleMessage(e.params.cmd,params);
            }
            
            if(params.getLong("meseq") > GameData.instance.serverMessagesHandler.firstRecievedMessageSequenceNumber
                && GameData.instance.serverMessagesHandler.firstRecievedMessageSequenceNumber != 0 
                && GameData.instance.serverMessagesHandler.isSynchronized() 
                && GameData.instance.serverMessagesHandler.actionsEnd)
            {
                statuses[LOADING_GAME].initHideLoadingScreenTimer();
            }
        }
        
        private function onGameEnded(event:GameEndedEvent):void
        {
            currentStatus.dispose(null);
        }
    }
}