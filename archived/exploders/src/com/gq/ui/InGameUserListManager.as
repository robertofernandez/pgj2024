package com.gq.ui
{
    import com.gq.moveobject.Person;
    import com.gq.system.GameData;
    import com.gq.system.GameSys;
    import com.smartfoxserver.v2.entities.User;
    import com.smartfoxserver.v2.entities.data.SFSObject;
    import com.willdom.games.bomberman.communication.SmartFoxClient;
    import com.willdom.games.bomberman.communication.SmartFoxClientSingleton;
    import com.willdom.games.bomberman.consts.ServerMessages;
    import com.willdom.games.bomberman.gameobjects.PersonScore;
    import com.willdom.games.bomberman.rooms.RoomLocalProperties;
    import com.willdom.games.bomberman.user.UserLocalProperties;
    import com.willdom.games.explodersmmo.shared.consts.GameRoomVars;
    import com.willdom.games.explodersmmo.shared.helpers.VectorHelper;
    import com.willdom.games.explodersmmo.shared.inventory.InventoryManager;
    import com.willdom.games.explodersmmo.shared.model.LocalUser;
    import com.willdom.games.explodersmmo.shared.model.SoundSettings;
    import com.willdom.games.explodersmmo.shared.ui.AvatarHelper;
    import com.willdom.games.explodersmmo.shared.ui.CustomButton;
    import com.willdom.util.helpers.EventListenerManager;
    
    import fl.containers.ScrollPane;
    import fl.controls.ScrollPolicy;
    
    import flash.display.Sprite;
    import flash.events.MouseEvent;

    public class InGameUserListManager extends Sprite
    {
        private static var instance:InGameUserListManager;
        private var initialized:Boolean = false;
        private var userListComponent:MC_InGameUserList;
        private var sfsInstance:SmartFoxClient;
        private var userListRowVector:Vector.<InGameUserListRowComponent>;
        private var sortedUserListRowVector:Vector.<InGameUserListRowComponent>;
        private var spectatorsIdsVector:Vector.<int>;
        private var firstTime:Boolean = true;
        private var smallAvatarLoaded:Boolean = false;
        
        private var btnSpectate:CustomButton;
        private var btnJoinWaitingList:CustomButton;
        
        private var _user:User;
        private var _userLocalProperties:UserLocalProperties;
        
        private var endResultsWaitingListsRowsContainer:Sprite;
        private var endResultsWaitingListScrollPane:ScrollPane;
        private var endResultsViewingListsRowContainer:Sprite;
        private var endResultsViewingListScrollPane:ScrollPane;
        
        private var endResultPlayerList:Vector.<InGameUserListRowComponentEndResults>;
        private var endResultsWaitingList:Vector.<InGameUserListRowComponentEndResults>;
        private var endResultsViewingList:Vector.<InGameUserListRowComponentEndResults>;
        
        public function InGameUserListManager()
        {
            if(instance)
            {
                throw new Error("This is a singleton class, use getInstance() instead");
            }
        }
        
        public static function getInstance():InGameUserListManager
        {
            if(instance == null)
            {
                instance = new InGameUserListManager();
            }
            
            return instance;
        }
        
        public function initialize():void
        {
            sfsInstance = SmartFoxClientSingleton.getInstance().smartFoxClient;
            
            if(!initialized)
            {
                initializeComponents();
                initialized = true;
            }
            
            updateSoundButton();
        }
        
        private function initializeComponents():void
        {
            userListComponent = new MC_InGameUserList();
            userListComponent.x = 735;
            userListComponent.homeBtn.buttonMode = true;
            userListComponent.soundBtn.buttonMode = true;
            userListComponent.spectatorsAmount.amount.text = "0";
            
            btnSpectate = new CustomButton(userListComponent.spectatorButtons.spectateBtn);
            btnJoinWaitingList = new CustomButton(userListComponent.spectatorButtons.playBtn);
            
            userListRowVector = new Vector.<InGameUserListRowComponent>;
            sortedUserListRowVector = new Vector.<InGameUserListRowComponent>;
            spectatorsIdsVector = new Vector.<int>;
            
            userListComponent.homeBtn.addEventListener(MouseEvent.CLICK, GameSys.backToLobby, false, 0, true);
            userListComponent.soundBtn.addEventListener(MouseEvent.CLICK, GameSys.onSoundBtnClick, false, 0, true);

            btnSpectate.addEventListener(MouseEvent.CLICK, onSpectateButtonEvent, false, 0, true);
            btnSpectate.texture.addEventListener(MouseEvent.ROLL_OVER, onSpectateButtonEvent, false, 0, true);
            btnSpectate.texture.addEventListener(MouseEvent.ROLL_OUT, onSpectateButtonEvent, false, 0, true);
            
            btnJoinWaitingList.addEventListener(MouseEvent.CLICK, onJoinWaitingListEvent, false, 0, true);
            btnJoinWaitingList.texture.addEventListener(MouseEvent.ROLL_OVER, onJoinWaitingListEvent, false, 0, true);
            btnJoinWaitingList.texture.addEventListener(MouseEvent.ROLL_OUT, onJoinWaitingListEvent, false, 0, true);
            
            setUpEndScreenUserList();
        }
        
        public function onCharacterSelectionStatus():void
        {
            addChild(userListComponent);
        }
        
        public function onMySelfEnterRoom(user:User, userLocalProperties:UserLocalProperties):void
        {
            if(userLocalProperties != null)
            {
                _user = user;
                _userLocalProperties = userLocalProperties;
                
                if(firstTime)
                {
                    updateComponentObjects();
                    firstTime = false;
                }
                
                if(LocalUser.getInstance().registered)
                {
                    if(!smallAvatarLoaded)
                    {
                        if(_user.containsVariable("chatAvatar"))
                        {
                            smallAvatarLoaded = true;
                            userListComponent.avatarHolder.addChild(AvatarHelper.loadExternalAvatar(_user.getVariable("chatAvatar").getSFSObjectValue().getUtfString("small")));
                        }
                    }
                }
                userListComponent.txtUsername.text = sfsInstance.myself.name;
                userListComponent.txtSkillpoints.text = userLocalProperties.pointsStr;
                userListComponent.txtLeaderboardRanking.text = userLocalProperties.rankingStr;
                userListComponent.txtCoins.text = InventoryManager.instance.coins.toString();
                
                userListComponent.spectatorButtons.label.text = LanguageManager.getInstance().getText("_gisSpectatorsBtn");
                userListComponent.spectatorsAmount.label.text = LanguageManager.getInstance().getText("_gisSpectatorsBtn");
                userListComponent.userListEndScreen.txtWaitingList.text = LanguageManager.getInstance().getText("_gsEndResultWaitingListTitle");
                userListComponent.userListEndScreen.txtViewList.text = LanguageManager.getInstance().getText("_gsEndResultSpectateListTitle");
                
                userListComponent.spectatorsAmount.amount.text = sfsInstance.gameRoom.spectatorCount.toString();
                updatePingIcon(sfsInstance.myself.id, userLocalProperties.ping);
            }
        }
        
        public function onUserEnterRoom(user:User, userProperties:UserLocalProperties):void
        {
            if(!user.isSpectator)
            {
                var rowIndex:int = searchUserRowByUserId(user.id);
                
                if(rowIndex == -1)
                {
                    var userRowComponent:InGameUserListRowComponent = new InGameUserListRowComponent(user, userProperties);
                    userListRowVector.push(userRowComponent);
                    
                    if(userListRowVector.length == 1)
                    {
                        userRowComponent.y = 0;
                    }
                    else
                    {
                        userRowComponent.y = userListRowVector[userListRowVector.length -2].y + 70;
                    }
                    
                    userListComponent.userListRowHolder.addChild(userRowComponent);
                }
                else
                {
                    userListRowVector[rowIndex].updateComponent(user, userProperties);
                    
                    var userViewingRow:InGameUserListRowComponentEndResults = searchSpectatorByUserIdInWaitingList(user.id);
                    if(userViewingRow != null)
                    {
                        userViewingRow.updateComponent(user, userProperties);
                    }
                }
            }
            else
            {
                if(searchSpectatorByUserId(user.id) == -1)
                {
                    spectatorsIdsVector.push(user.id);
                    userListComponent.spectatorsAmount.amount.text = spectatorsIdsVector.length;
                }
            }
            
            var inGameUserListRowComponentEndResult:InGameUserListRowComponentEndResults;
            if(searchSpectatorByUserIdInEndScreenList(user.id) == null)
            {
                inGameUserListRowComponentEndResult = new InGameUserListRowComponentEndResults(user, userProperties);
                
                if(!user.isSpectator)
                {
                    inGameUserListRowComponentEndResult.updateStatusIcon("in");
                }
                else
                {
                    inGameUserListRowComponentEndResult.updateStatusIcon("unavailable");
                    
                }
                endResultPlayerList.push(inGameUserListRowComponentEndResult);
            }
            else
            {
                inGameUserListRowComponentEndResult = searchSpectatorByUserIdInEndScreenList(user.id);
                inGameUserListRowComponentEndResult.updateComponent(user, userProperties);
            }
        }
        
        public function onUserExitRoom(userId:int):void
        {
            var spectatorIndex:int = searchSpectatorByUserId(userId);
            
            if(spectatorIndex == -1)
            {
                var rowIndex:int = searchUserRowByUserId(userId);
                
                if(rowIndex != -1)
                {
                    userListRowVector[rowIndex].onUserExitRoom();
                }
            }
            else
            {
                spectatorsIdsVector.splice(spectatorIndex, 1);
                userListComponent.spectatorsAmount.amount.text = spectatorsIdsVector.length;
            }
            
            var userEndMatchRowComponent:InGameUserListRowComponentEndResults = searchSpectatorByUserIdInWaitingList(userId);
            if(userEndMatchRowComponent != null)
            {
                endResultPlayerList.splice(endResultPlayerList.indexOf(userEndMatchRowComponent), 1);
                removeUserFromWaitingList(userEndMatchRowComponent);
            }
            else
            {
                userEndMatchRowComponent = searchSpectatorByUserIdInViewingList(userId);
                if(userEndMatchRowComponent != null)
                {
                    endResultPlayerList.splice(endResultPlayerList.indexOf(userEndMatchRowComponent), 1);
                    removeUserFromViewingList(userEndMatchRowComponent);
                }
            }
            
            if(GameData.instance.gameObjectsContainer.endMatchResultsScreen != null)
            {
                GameData.instance.gameObjectsContainer.endMatchResultsScreen.onUserExit(userId);
            }
        }
        
        public function onUserKilled(userId:int):void
        {
            var rowIndex:int = searchUserRowByUserId(userId);
            
            if(rowIndex != -1)
            {
                userListRowVector[rowIndex].onUserKilled(userId);
            }
        }
        
        public function onRoundStart():void
        {
            for(var i:int = 0; i < userListRowVector.length; i++)
            {
                userListRowVector[i].onRoundStart();
            }
        }
        
        public function onCharacterSelected(userId:int, characterId:int):void
        {
            if(userId == sfsInstance.myself.id && sfsInstance.myself.isPlayer)
            {
                userListComponent.avatars.gotoAndStop("avatar" + characterId.toString());
                userListComponent.avatars.visible = true;
                userListComponent.userNotSelectedIcon.visible = false;
                GameData.instance.myAvatar = characterId;
            }
            
            updateHeadIcon(userId, characterId);
        }
        
        public function updateUserScoresAndPositions(personScore:PersonScore):void
        {
            var rowIndex:int = searchUserRowByUserId(personScore.userId);
            
            if(rowIndex != -1)
            {
                userListRowVector[rowIndex].updateScoreAndPosition(personScore.ranking, personScore.totalScorePoints);
            }
        }
        
        public function orderListByPosition(personScoresArray:Array):void
        {
            sortedUserListRowVector = Vector.<InGameUserListRowComponent>(VectorHelper.sortOn(userListRowVector, "score", Array.NUMERIC));
            sortedUserListRowVector.reverse();
            
            for(var i:int = 0; i < userListRowVector.length; i++)
            {
                userListComponent.userListRowHolder.removeChild(userListRowVector[i]);
            }
            
            for(i = 0; i < userListRowVector.length; i++)
            {
                if(i == 0)
                {
                    sortedUserListRowVector[i].y = 0;
                }
                else
                {
                    sortedUserListRowVector[i].y = sortedUserListRowVector[i - 1].y + 70;
                }
                
                userListComponent.userListRowHolder.addChild(sortedUserListRowVector[i]);
            }
        }
        
        public function updateHeadIcon(userId:int, characterId:int):void
        {
            for(var i:int = 0; i < userListRowVector.length; i++)
            {
                if(userListRowVector[i].user.id == userId)
                {
                    userListRowVector[i].updateAvatarHead(characterId);
                }
            }
        }
        
        public function updatePingIcon(userId:int, ping:int):void
        {
            if(userId == sfsInstance.myself.id)
            {
                if(ping >= 0 && ping <= 60)
                {
                    userListComponent.pingIcon.gotoAndStop(1);
                }
                else if(ping >= 61 && ping <= 120)
                {
                    userListComponent.pingIcon.gotoAndStop(2);
                }
                else if(ping >= 121 && ping <= 200)
                {
                    userListComponent.pingIcon.gotoAndStop(3);
                }
                else
                {
                    userListComponent.pingIcon.gotoAndStop(4);
                }
                userListComponent.txtPing.text = ping.toString();
            }
            else
            {
                var rowIndex:int = searchUserRowByUserId(userId);
                
                if(rowIndex != -1)
                {
                    userListRowVector[rowIndex].updatePingIcon(ping);
                }
            }
        }
        
        public function resetComponents(rematch:Boolean = false):void
        {
            for(var i:int = 0; i < userListRowVector.length; i++)
            {
                userListComponent.userListRowHolder.removeChild(userListRowVector[i]);
                userListRowVector[i] = null;
                sortedUserListRowVector[i] = null;
            }
            
            userListRowVector.splice(0, userListRowVector.length);
            sortedUserListRowVector.splice(0, sortedUserListRowVector.length);
            
            if(userListComponent.parent != null)
            {
                removeChild(userListComponent);
            }
            
            endResultsViewingList.splice(0, endResultsViewingList.length);
            endResultsWaitingList.splice(0, endResultsWaitingList.length);
            for(i = 0; i < endResultPlayerList.length; i++)
            {
                if(endResultPlayerList[i].parent != null)
                {
                    endResultPlayerList[i].parent.removeChild(endResultPlayerList[i]);
                }
            }
            userListComponent.userListEndScreen.txtWaitingListAmount.text = endResultsWaitingList.length;
            userListComponent.userListEndScreen.txtViewingAmount.text = endResultsViewingList.length;
            onWaitingOrViewingComponentEvent();
            
            if(!rematch)
            {
                endResultPlayerList.splice(0, endResultPlayerList.length);
            }
            else
            {
                updateComponentObjects();
                
                for(i = 0; i < sfsInstance.gameRoom.userList.length; i++)
                {
                    var auxUser:User = sfsInstance.gameRoom.userList[i];
                    if(auxUser != null)
                    {
                        if(auxUser.isSpectator)
                        {
                            if(searchSpectatorByUserId(auxUser.id) == -1)
                            {
                                spectatorsIdsVector.push(auxUser.id);
                                userListComponent.spectatorsAmount.amount.text = spectatorsIdsVector.length;
                            }
                        }
                    }
                }
                
            }
            
            userListComponent.userListEndScreen.visible = false;
            firstTime = true;
            
            userListComponent.spectatorsAmount.amount.text = sfsInstance.gameRoom.spectatorCount.toString();
        }
        
        public function onExitGame():void
        {
            spectatorsIdsVector.splice(0, spectatorsIdsVector.length);
        }
        
        public function getRowByUserId(userId:int):InGameUserListRowComponent
        {
            var index:int = searchUserRowByUserId(userId);
            
            if(index != -1)
            {
                return userListRowVector[index];
            }
            
            return null;
        }
        
        public function getRowByUsername(username:String):InGameUserListRowComponent
        {
            var index:int = searchUserRowByUsername(username);
            
            if(index != -1)
            {
                return userListRowVector[index];
            }
            
            return null;
        }
        
        public function onEndResultsScreen():void
        {
            userListComponent.userListEndScreen.visible = true;
        }
        
        
        private function searchUserRowByUserId(userId:int):int
        {
            for(var i:int = 0; i < userListRowVector.length; i++)
            {
                if(userListRowVector[i].user.id == userId)
                {
                    return i;
                }
            }
            
            return -1;
        }
        
        private function searchUserRowByUsername(username:String):int
        {
            for(var i:int = 0; i < userListRowVector.length; i++)
            {
                if(userListRowVector[i].user.name == username)
                {
                    return i;
                }
            }
            
            return -1;
        }
        
        private function searchSpectatorByUserId(userId:int):int
        {
            for(var i:int = 0; i < spectatorsIdsVector.length; i++)
            {
                if(spectatorsIdsVector[i] == userId)
                {
                    return i;
                }
            }
            
            return -1;
        }
        
        public function onSpectateButtonClick(event:MouseEvent):void
        {
            onSpectateButtonEvent(event);
        }
        
        private function onSpectateButtonEvent(event:MouseEvent = null):void
        {
            if(event == null || event.type == MouseEvent.CLICK)
            {
                if(sfsInstance.myself.isSpectator)
                {
                    if(_userLocalProperties.isRegistered || sfsInstance.gameRoom.getVariable(GameRoomVars.FRIENDLY_ROOM).getBoolValue())
                    {
                        if ((sfsInstance.gameRoom.properties as RoomLocalProperties).waitingList.indexOf(sfsInstance.myself) > -1)
                        {
                            sfsInstance.joinWaitingList(false);
                            btnSpectate.disable();
                            GameData.instance.gameObjectsContainer.endMatchResultsScreen.onSpectateButtonClicked();
                            
                            btnJoinWaitingList.enable();
                            GameData.instance.inWaitingList = false;
                        }
                    }
                }
                else
                {
                    btnSpectate.disable();
                    btnJoinWaitingList.enable();
                    GameData.instance.gameObjectsContainer.endMatchResultsScreen.onSpectateButtonClicked();
                    
                    var sfsObject:SFSObject = new SFSObject();
                    sfsObject.putInt(ServerMessages.ROUND_NUMBER,GameData.instance.currentRound);        
                    sfsObject.putInt("pid",SmartFoxClientSingleton.getInstance().smartFoxClient.myself.id);    
                    SmartFoxClientSingleton.getInstance().smartFoxClient.sendExtensionRequestToGameRoom(ServerMessages.DECLINE_REMATCH,sfsObject);
                    Person.getPersonByName(GameData.instance.myName).rematchAccepted = false;
                }
            }
            else if(event.type == MouseEvent.ROLL_OVER)
            {
                userListComponent.spectatorTooltip.gotoAndStop("spectate");
                userListComponent.spectatorTooltip.label.text = LanguageManager.getInstance().getText("_spectateTooltip");
                userListComponent.spectatorTooltip.visible = true;
            }
            else if(event.type == MouseEvent.ROLL_OUT)
            {
                userListComponent.spectatorTooltip.visible = false;
            }
        }
        
        public function onWaitingButtonClick(event:MouseEvent):void
        {
            onJoinWaitingListEvent(event);
        }
        
        private function onJoinWaitingListEvent(event:MouseEvent = null):void
        {
            if(event == null || event.type == MouseEvent.CLICK)
            {
                if(sfsInstance.myself.isSpectator)
                {
                    if(_userLocalProperties.isRegistered || sfsInstance.gameRoom.getVariable(GameRoomVars.FRIENDLY_ROOM).getBoolValue())
                    {
                        if ((sfsInstance.gameRoom.properties as RoomLocalProperties).waitingList.indexOf(sfsInstance.myself) == -1)
                        {
                            sfsInstance.joinWaitingList(true);
                            btnSpectate.enable();
                            GameData.instance.gameObjectsContainer.endMatchResultsScreen.onJoinWaitingListClicked();
                            
                            btnJoinWaitingList.disable();
                            GameData.instance.inWaitingList = true;
                        }
                    }
                }
                else
                {
                    btnSpectate.enable();
                    btnJoinWaitingList.disable();
                    GameData.instance.gameObjectsContainer.endMatchResultsScreen.onJoinWaitingListClicked();
                    
                    var sfsObject2:SFSObject = new SFSObject();
                    sfsObject2.putInt(ServerMessages.ROUND_NUMBER,GameData.instance.currentRound);
                    sfsObject2.putInt("pid",SmartFoxClientSingleton.getInstance().smartFoxClient.myself.id);
                    SmartFoxClientSingleton.getInstance().smartFoxClient.sendExtensionRequestToGameRoom(ServerMessages.ACCEPT_REMATCH,sfsObject2);
                    Person.getPersonByName(GameData.instance.myName).rematchAccepted = true;
                }
            }
            else if(event.type == MouseEvent.ROLL_OVER)
            {
                userListComponent.spectatorTooltip.gotoAndStop("joinGame");
                userListComponent.spectatorTooltip.label.text = LanguageManager.getInstance().getText("_joinGameTooltip");
                userListComponent.spectatorTooltip.visible = true;
            }
            else if(event.type == MouseEvent.ROLL_OUT)
            {
                userListComponent.spectatorTooltip.visible = false;
            }
        }
        
        private function updateComponentObjects():void
        {
            userListComponent.avatars.visible = false;
            userListComponent.spectatorTooltip.visible = false;
            
            if(GameData.instance.iAmSpectating)
            {
                userListComponent.userNotSelectedIcon.visible = false;
                userListComponent.userSpectatingIcon.visible = true;
                userListComponent.spectatorsAmount.visible = false;
                userListComponent.spectatorButtons.visible = true;
                
                sfsInstance.joinWaitingList(false);
                btnSpectate.disable();
                btnJoinWaitingList.enable();
                GameData.instance.inWaitingList = false;
            }
            else
            {
                userListComponent.userNotSelectedIcon.visible = true;
                userListComponent.userSpectatingIcon.visible = false;
                userListComponent.spectatorsAmount.visible = true;
                userListComponent.spectatorButtons.visible = false;
                
                sfsInstance.joinWaitingList(true);
                btnSpectate.enable();
                btnJoinWaitingList.disable();
                GameData.instance.inWaitingList = true;
            }
            
            if(LocalUser.getInstance().registered)
            {
                userListComponent.rankingIcon.alpha = 1;
                userListComponent.txtLeaderboardRanking.alpha = 1;
                
                userListComponent.skillpointIcon.alpha = 1;
                userListComponent.txtSkillpoints.alpha = 1;
            }
            else
            {
                userListComponent.rankingIcon.alpha = 0.25;
                userListComponent.txtLeaderboardRanking.alpha = 0.25;
                
                userListComponent.skillpointIcon.alpha = 0.25;
                userListComponent.txtSkillpoints.alpha = 0.25;
                
                userListComponent.avatarHolder.addChild(AvatarHelper.loadExternalAvatar("http://tunaplus.api.jaludo.com/assets/images/avatar_boy_small.png"));
            }
        }
        
        private function setUpEndScreenUserList():void
        {
           userListComponent.userListEndScreen.visible = false;
           
           userListComponent.userListEndScreen.txtWaitingListEmpty.text = LanguageManager.getInstance().getText("_empty");
           userListComponent.userListEndScreen.txtWaitingListEmpty.visible = true;
           userListComponent.userListEndScreen.txtViewingListEmpty.text = LanguageManager.getInstance().getText("_empty");
           userListComponent.userListEndScreen.txtViewingListEmpty.visible = true;
           
            endResultsWaitingListsRowsContainer = new Sprite;
            endResultsWaitingListsRowsContainer.graphics.beginFill(0x000000, 0);
            endResultsWaitingListsRowsContainer.graphics.drawRect(0,0, userListComponent.userListEndScreen.scrollpaneContainerWaitingList.width, userListComponent.userListEndScreen.scrollpaneContainerWaitingList.height);
            endResultsWaitingListScrollPane = userListComponent.userListEndScreen.scrollpaneContainerWaitingList;
            endResultsWaitingListScrollPane.source = endResultsWaitingListsRowsContainer;
            endResultsWaitingListScrollPane.verticalScrollPolicy = ScrollPolicy.AUTO;
            endResultsWaitingListScrollPane.horizontalScrollPolicy = ScrollPolicy.OFF;
            endResultsWaitingListScrollPane.verticalLineScrollSize = 20;
            
            endResultsViewingListsRowContainer = new Sprite;
            endResultsViewingListsRowContainer.graphics.beginFill(0x000000, 0);
            endResultsViewingListsRowContainer.graphics.drawRect(0,0, userListComponent.userListEndScreen.scrollpaneContainerViewingList.width, userListComponent.userListEndScreen.scrollpaneContainerViewingList.height);
            endResultsViewingListScrollPane = userListComponent.userListEndScreen.scrollpaneContainerViewingList;
            endResultsViewingListScrollPane.source = endResultsViewingListsRowContainer;
            endResultsViewingListScrollPane.verticalScrollPolicy = ScrollPolicy.AUTO;
            endResultsViewingListScrollPane.horizontalScrollPolicy = ScrollPolicy.OFF;
            endResultsViewingListScrollPane.verticalLineScrollSize = 20;
            
            endResultsWaitingListScrollPane.setStyle("upSkin", new Sprite);
            endResultsWaitingListScrollPane.setStyle("upArrowUpSkin", ScrollArrowUp_upSkinGameRoomCustom);
            endResultsWaitingListScrollPane.setStyle("upArrowOverSkin", ScrollArrowUp_upSkinGameRoomCustom);
            endResultsWaitingListScrollPane.setStyle("upArrowDownSkin", ScrollArrowUp_upSkinGameRoomCustom);
            endResultsWaitingListScrollPane.setStyle("downArrowUpSkin", ScrollArrowDown_upSkinGameRoomCustom);
            endResultsWaitingListScrollPane.setStyle("downArrowOverSkin", ScrollArrowDown_upSkinGameRoomCustom);
            endResultsWaitingListScrollPane.setStyle("downArrowDownSkin", ScrollArrowDown_upSkinGameRoomCustom);
            endResultsWaitingListScrollPane.setStyle("trackUpSkin", ScrollTrack_skingameRoomCustom2);
            endResultsWaitingListScrollPane.setStyle("trackOverSkin", ScrollTrack_skingameRoomCustom2);
            endResultsWaitingListScrollPane.setStyle("trackDownSkin", ScrollTrack_skingameRoomCustom2);
            endResultsWaitingListScrollPane.setStyle("thumbUpSkin", ScrollThumb_upSkinGameRoomCustom);
            endResultsWaitingListScrollPane.setStyle("thumbOverSkin", ScrollThumb_upSkinGameRoomCustom2);
            endResultsWaitingListScrollPane.setStyle("thumbDownSkin", ScrollThumb_upSkinGameRoomCustom2);
            endResultsWaitingListScrollPane.setStyle("thumbIcon", new Sprite);
            
            endResultsViewingListScrollPane.setStyle("upSkin", new Sprite);
            endResultsViewingListScrollPane.setStyle("upArrowUpSkin", ScrollArrowUp_upSkinGameRoomCustom);
            endResultsViewingListScrollPane.setStyle("upArrowOverSkin", ScrollArrowUp_upSkinGameRoomCustom);
            endResultsViewingListScrollPane.setStyle("upArrowDownSkin", ScrollArrowUp_upSkinGameRoomCustom);
            endResultsViewingListScrollPane.setStyle("downArrowUpSkin", ScrollArrowDown_upSkinGameRoomCustom);
            endResultsViewingListScrollPane.setStyle("downArrowOverSkin", ScrollArrowDown_upSkinGameRoomCustom);
            endResultsViewingListScrollPane.setStyle("downArrowDownSkin", ScrollArrowDown_upSkinGameRoomCustom);
            endResultsViewingListScrollPane.setStyle("trackUpSkin", ScrollTrack_skingameRoomCustom2);
            endResultsViewingListScrollPane.setStyle("trackOverSkin", ScrollTrack_skingameRoomCustom2);
            endResultsViewingListScrollPane.setStyle("trackDownSkin", ScrollTrack_skingameRoomCustom2);
            endResultsViewingListScrollPane.setStyle("thumbUpSkin", ScrollThumb_upSkinGameRoomCustom2);
            endResultsViewingListScrollPane.setStyle("thumbOverSkin", ScrollThumb_upSkinGameRoomCustom2);
            endResultsViewingListScrollPane.setStyle("thumbDownSkin", ScrollThumb_upSkinGameRoomCustom2);
            endResultsWaitingListScrollPane.setStyle("thumbIcon", new Sprite);
            
            endResultPlayerList = new Vector.<InGameUserListRowComponentEndResults>;
            endResultsWaitingList = new Vector.<InGameUserListRowComponentEndResults>;
            endResultsViewingList = new Vector.<InGameUserListRowComponentEndResults>;
        }

        public function onRoomVariableUpdate():void
        {
            var roomProperties:RoomLocalProperties = sfsInstance.gameRoom.properties as RoomLocalProperties;
            
            for(var i:int = 0; i < endResultPlayerList.length; i++)
            {
                var user:User = sfsInstance.gameRoom.getUserById(endResultPlayerList[i].user.id);
                
                if(user != null)
                {
                    if(user.isPlayer)
                    {
                        var person:Person = Person.getPersonByName(user.name);
                        if(person != null)
                        {
                            if(Person.getPersonByName(user.name).rematchAccepted)
                            {
                                removeUserFromViewingList(endResultPlayerList[i]);
                            }
                            else
                            {
                                endResultPlayerList[i].updateStatusIcon("out");
                                addUserToViewingList(endResultPlayerList[i]);
                            }
                        }
                    }
                    if(user.isSpectator)
                    {
                        if(searchUserInRoomWaitingList(user.id))
                        {
                            endResultPlayerList[i].updateStatusIcon("in");
                            addUserToWaitingList(endResultPlayerList[i]);
                        }
                        else
                        {
                            endResultPlayerList[i].updateStatusIcon("out");
                            addUserToViewingList(endResultPlayerList[i]);
                        }
                    }
                }
                else
                {
                    endResultPlayerList.splice(i, 1);
                    i--;
                }
            }
            
            reDrawViewingList();
            reDrawWaitingList();
        }
        
        private function addUserToWaitingList(userRow:InGameUserListRowComponentEndResults):void
        {
            if(endResultsWaitingList.indexOf(userRow) == -1)
            {
                endResultsWaitingList.push(userRow);
            }
            
            if(searchSpectatorByUserIdInViewingList(userRow.user.id) != null)
            {
                removeUserFromViewingList(userRow);
            }
            
            userListComponent.userListEndScreen.txtWaitingListEmpty.visible = false;
            userListComponent.userListEndScreen.txtWaitingListAmount.text = endResultsWaitingList.length;
        }
        
        private function addUserToViewingList(userRow:InGameUserListRowComponentEndResults):void
        {
            if(endResultsViewingList.indexOf(userRow) == -1)
            {
                endResultsViewingList.push(userRow);
            }
            
            if(searchSpectatorByUserIdInWaitingList(userRow.user.id) != null)
            {
                removeUserFromWaitingList(userRow);
            }
            
            userListComponent.userListEndScreen.txtViewingListEmpty.visible = false;
            userListComponent.userListEndScreen.txtViewingAmount.text = endResultsViewingList.length;
        }
        
        public function showEndMatchUserList():void
        {
            userListComponent.userListEndScreen.visible = true;
            onRoomVariableUpdate();
        }
        
        private function reDrawWaitingList():void
        {
            var auxRow:InGameUserListRowComponentEndResults;
            
            for(var i:int = 0; i < endResultsWaitingList.length; i++)
            {
                auxRow = endResultsWaitingList[i];
                
                if(auxRow.parent != null)
                {
                    auxRow.parent.removeChild(auxRow);
                }
            }
            
            for(i = 0; i <endResultsWaitingList.length; i++)
            {
                auxRow = endResultsWaitingList[i];
                
                if(i == 0)
                {
                    auxRow.y = 0;
                }
                else
                {
                    auxRow.y = endResultsWaitingList[i - 1].y + endResultsWaitingList[i - 1].height;
                }
                
                endResultsWaitingListsRowsContainer.addChild(auxRow);
            }
            
            onWaitingOrViewingComponentEvent();
        }
        
        private function reDrawViewingList():void
        {
            var auxRow:InGameUserListRowComponentEndResults;
            
            for(var i:int = 0; i < endResultsViewingList.length; i++)
            {
                auxRow = endResultsViewingList[i];
                
                if(auxRow.parent != null)
                {
                    auxRow.parent.removeChild(auxRow);
                }
            }
            
            for(i = 0; i < endResultsViewingList.length; i++)
            {
                auxRow = endResultsViewingList[i];
                
                if(auxRow.user.id == sfsInstance.myself.id)
                {
                    endResultsViewingList.splice(i, 1);
                    endResultsViewingList.unshift(auxRow);
                    break;
                }
            }
            
            for(i = 0; i < endResultsViewingList.length; i++)
            {
                auxRow = endResultsViewingList[i];
                
                if(i == 0)
                {
                    auxRow.y = 0;
                }
                else
                {
                    auxRow.y = endResultsViewingList[i - 1].y + endResultsViewingList[i - 1].height;
                }
                
                endResultsViewingListsRowContainer.addChild(auxRow);
            }
            
            onWaitingOrViewingComponentEvent();
        }
        
        private function removeUserFromViewingList(userRow:InGameUserListRowComponentEndResults):void
        {
            var index:int = endResultsViewingList.indexOf(userRow);
            
            if(index != -1)
            {
                endResultsViewingList.splice(index, 1);
                if(userRow.parent != null)
                {
                    userRow.parent.removeChild(userRow);
                }
                if(endResultsViewingList.length == 0)
                {
                    userListComponent.userListEndScreen.txtViewingListEmpty.visible = true;
                }
                
                userListComponent.userListEndScreen.txtViewingAmount.text = endResultsViewingList.length;
                reDrawViewingList();
            }
        }
        
        private function removeUserFromWaitingList(userRow:InGameUserListRowComponentEndResults):void
        {
            var index:int = endResultsWaitingList.indexOf(userRow);
            
            if(index != -1)
            {
                endResultsWaitingList.splice(index, 1);
                if(userRow.parent != null)
                {
                    userRow.parent.removeChild(userRow);
                }
                if(endResultsWaitingList.length == 0)
                {
                    userListComponent.userListEndScreen.txtWaitingListEmpty.visible = true;
                }
                
                userListComponent.userListEndScreen.txtWaitingListAmount.text = endResultsWaitingList.length;
                reDrawWaitingList();
            }
        }
        
        private function onWaitingOrViewingComponentEvent():void
        {
            endResultsWaitingListScrollPane.refreshPane();
            endResultsWaitingListScrollPane.update();
            
            endResultsViewingListScrollPane.refreshPane();
            endResultsViewingListScrollPane.update();
        }
        
        private function searchSpectatorByUserIdInWaitingList(userId:int):InGameUserListRowComponentEndResults
        {
            for(var i:int = 0; i < endResultsWaitingList.length; i++)
            {
                if(endResultsWaitingList[i].user.id == userId)
                {
                    return endResultsWaitingList[i];
                }
            }
            
            return null;
        }
        
        private function searchSpectatorByUserIdInViewingList(userId:int):InGameUserListRowComponentEndResults
        {
            for(var i:int = 0; i < endResultsViewingList.length; i++)
            {
                if(endResultsViewingList[i].user.id == userId)
                {
                    return endResultsViewingList[i];
                }
            }
            return null;
        }
        
        private function searchSpectatorByUserIdInEndScreenList(userId:int):InGameUserListRowComponentEndResults
        {
            for(var i:int = 0; i < endResultPlayerList.length; i++)
            {
                if(endResultPlayerList[i].user.id == userId)
                {
                    return endResultPlayerList[i];
                }
            }
            return null;
        }
        
        private function updateSoundButton():void
        {
            if(SoundSettings.getInstance().masterVolume == 0)
            {
                userListComponent.soundBtn.gotoAndStop("off");
            }
            else
            {
                userListComponent.soundBtn.gotoAndStop("on");
            }
        }
        
        private function searchUserInRoomWaitingList(userId:int):Boolean
        {
            var roomProperties:RoomLocalProperties = sfsInstance.gameRoom.properties as RoomLocalProperties;
                
            for(var i:int = 0; i < roomProperties.waitingList.length; i++)
            {
                if(userId == roomProperties.waitingList[i].id)
                {
                    return true;
                }
            }
            
            return false;
        }
    }
}