package com.willdom.games.bomberman.statemachine
{
    import com.gq.moveobject.Person;
    import com.gq.system.Disease;
    import com.gq.system.GameData;
    import com.gq.system.GameSys;
    import com.gq.system.SoundClass;
    import com.smartfoxserver.v2.entities.data.ISFSArray;
    import com.smartfoxserver.v2.entities.data.ISFSObject;
    import com.smartfoxserver.v2.entities.data.SFSObject;
    import com.willdom.games.bomberman.communication.SmartFoxClientSingleton;
    import com.willdom.games.bomberman.controllers.ConfigController;
    import com.willdom.games.bomberman.events.PlayerEvent;
    import com.willdom.games.bomberman.gameobjects.GameObjectsContainer;
    import com.willdom.util.helpers.EventListenerManager;
    
    import flash.events.MouseEvent;
    
    /**
     * Game status that represents the stage when game finishes and
     * skillpoints are being calculated by backend.
     */
    public class CalculatingPointsStatus extends BasicStatusWithEventHandling
    {
        private var gameObjectsContainer:GameObjectsContainer;
        
        public function CalculatingPointsStatus(gameObjectsContainer:GameObjectsContainer)
        {
            this.gameObjectsContainer = gameObjectsContainer;
        }
        
        override public function init(params:SFSObject):void
        {
            var i:uint = 0;
            //"Pairs" array will only be provided by the server at this point if there aren't enough players to
            // start the game after selection step. Here we start players data to show it on results screen,
            // and also hide the game display elements.
            var pairs:ISFSArray = params.getSFSArray("pairs");
            if(pairs != null)
            {
                var data:ISFSObject;
                var playerSelected:int;
                var number:int;
                for(i=0; i < pairs.size(); i++)
                {
                    data = pairs.getSFSObject(i);
                    number =  GameData.instance.playerNames.indexOf(data.getUtfString("name"));
                    if (number > -1)
                    {
                        playerSelected = data.getInt("avid");
                        GameData.instance.playerInforArr[number][1] = playerSelected;
                    }
                }
                GameSys.checkPlayersListForcedInitCondition();
                (Person.allPersons[0] as Person)._this.visible = false;
                (Person.allPersons[0] as Person).dialogOver.visible = false;
                GameData.instance.topSprite.visible = false;
                if(GameData.instance.map != null)
                {
                    GameData.instance.map.page.visible = false;
                }
                gameObjectsContainer.infoScreen.playerListComponent.visible = false;
                gameObjectsContainer.infoScreen.powerUpBar.visible = false;
            }
        }
        
        override public function dispose(params:SFSObject):void
        {
            if(GameData.instance.gameObjectsContainer.inRoundEquipmentBar != null)
            {
                GameData.instance.gameObjectsContainer.inRoundEquipmentBar.visible = false;
            }
            if(GameData.instance.gameObjectsContainer.inRoundCommunicationBar != null)
            {
                GameData.instance.gameObjectsContainer.inRoundCommunicationBar.visible = false;
            }
        }
    }
}
