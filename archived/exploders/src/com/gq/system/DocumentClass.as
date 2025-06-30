package com.gq.system
{
    import com.gq.moveobject.Person;
    import com.gq.moveobject.RemoteControlSet;
    import com.jaludo.Jaludo;
    import com.jaludo.data.JaludoResult;
    import com.jaludo.errors.JaludoErrorCollection;
    import com.smartfoxserver.v2.SmartFox;
    import com.smartfoxserver.v2.core.SFSEvent;
    import com.smartfoxserver.v2.entities.Room;
    import com.smartfoxserver.v2.entities.User;
    import com.smartfoxserver.v2.entities.data.SFSObject;
    import com.willdom.games.bomberman.communication.ParamCodes;
    import com.willdom.games.bomberman.communication.RequestCodes;
    import com.willdom.games.bomberman.communication.SmartFoxClientSingleton;
    import com.willdom.games.bomberman.config.GameConfigManager;
    import com.willdom.games.bomberman.consts.ServerMessages;
    import com.willdom.games.bomberman.controllers.ConfigController;
    import com.willdom.games.bomberman.position.maps.SfsBasedMapDescription;
    import com.willdom.games.bomberman.spectators.ServerMessagesHandler;
    import com.willdom.games.bomberman.statemachine.StatusManager;
    import com.willdom.games.bomberman.user.UserLocalProperties;
    import com.willdom.games.explodersmmo.shared.events.LobbyGameCommunicationEvent;
    import com.willdom.games.explodersmmo.shared.model.LocalUser;
    import com.willdom.util.helpers.EventListenerManager;
    
    import configuration.Config;
    import configuration.StageModes;
    
    import flash.display.InteractiveObject;
    import flash.display.MovieClip;
    import flash.display.Scene;
    import flash.display.SimpleButton;
    import flash.display.Sprite;
    import flash.display.StageScaleMode;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.events.ProgressEvent;
    import flash.events.TimerEvent;
    import flash.text.TextField;
    import flash.utils.Timer;
            
    [SWF( width = "1060", height = "860", frameRate = "35" )]
    public class DocumentClass extends Sprite
    {
        
        private var spectatorStarted:Boolean = false;
        private var statusManager:StatusManager;
        
        public function DocumentClass()
        {
            GameData.newInstance();
            
            visible = false;
            EventListenerManager.setListenerTo(this, Event.ADDED_TO_STAGE,onAddedToStage);
            
            GameConfigManager.getInstance().extendedContainer = true;
        }
    
        private function onAddedToStage(evt:Event):void
        {
            statusManager = new StatusManager();
            statusManager.init(this);
        }
    }
}