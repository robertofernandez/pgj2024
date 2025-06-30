package com.gq.ui.characterselect
{
    import com.gq.system.GameData;
    import com.gq.ui.InGameUserListManager;
    import com.smartfoxserver.v2.entities.User;
    import com.smartfoxserver.v2.entities.data.ISFSArray;
    import com.smartfoxserver.v2.entities.data.ISFSObject;
    import com.smartfoxserver.v2.entities.data.SFSObject;
    import com.willdom.games.bomberman.communication.SmartFoxClientSingleton;
    import com.willdom.games.bomberman.consts.ServerMessages;
    import com.willdom.games.bomberman.events.PlayerEvent;
    import com.willdom.games.bomberman.rooms.RoomLocalProperties;
    import com.willdom.games.bomberman.user.UserLocalProperties;
    import com.willdom.games.explodersmmo.shared.consts.SharedVars;
    import com.willdom.games.explodersmmo.shared.inventory.InventoryManager;
    import com.willdom.games.explodersmmo.shared.inventory.InventoryOwnedCharacterInfo;
    import com.willdom.games.explodersmmo.shared.shop.ShopCharacterInfo;
    import com.willdom.games.explodersmmo.shared.shop.ShopInfoManager;
    //import com.willdom.games.explodersmmo.shared.tracker.HoneyTracksHelper;
    import com.willdom.games.explodersmmo.shared.ui.CustomButton;
    import com.willdom.games.explodersmmo.shared.ui.CustomToolTip;
    import com.willdom.util.helpers.EventListenerManager;
    
    import flash.display.MovieClip;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.events.TimerEvent;
    import flash.filters.GlowFilter;
    import flash.utils.Timer;
    
    public class CharacterSelectScreen extends Sprite
    {
        private const MAX_CHARS_PER_ROW:int = 7;
        
        private var texture:MC_InGameCharacterSelect;
        
        private var amountChars:int = 0;
        private var amountCharsMaxInRow:int = 0;
        
        private var leftArrow:CustomButton;
        private var rightArrow:CustomButton;
        private var arrowIndex:int = 7; 
        
        private var charactersRows:Vector.<MC_IngameCharacterSelectCharacter>;
        private var charactersIndexArray:Array;
        private var charactersAmountPerRow:Array;
        
        private var playerLocked:Boolean = false;
        private var playerLockedTimer:Timer;
        
        private var reservations:Object;
        private var reservationsCharactersIds:Object;
        
        private var mapNames:Array;
        
        private var voteMapSelectedGlow:GlowFilter;
        
        private var confirmationPopUp:MovieClip;
        private var confirmationPopUpCloseBtn:CustomButton;
        private var confirmationPopUpUnlockBtn:CustomButton;
        private var lastCharacterInfo:ShopCharacterInfo;
        
        private var toolTip:CustomToolTip;
        
        public function CharacterSelectScreen()
        {
            texture = new MC_InGameCharacterSelect;
            charactersRows = new Vector.<MC_IngameCharacterSelectCharacter>;
            charactersIndexArray = new Array;
            charactersAmountPerRow = new Array;
            
            leftArrow = new CustomButton(texture.arrowLeft);
            EventListenerManager.setListenerTo(leftArrow, MouseEvent.CLICK, onArrowClick);
            leftArrow.disable();
            rightArrow = new CustomButton(texture.arrowRight);
            EventListenerManager.setListenerTo(rightArrow, MouseEvent.CLICK, onArrowClick);
            rightArrow.disable();
            
            playerLockedTimer = new Timer(3000, 1);
            EventListenerManager.setListenerTo(playerLockedTimer, TimerEvent.TIMER_COMPLETE, onPlayerLockedTimerComplete);
            
            reservations = new Object();
            reservationsCharactersIds = new Object();
            
            texture.popUpNotEnoughPlayers.visible = false;
            texture.popUpCantSelect.visible = false;
            
            if(!SmartFoxClientSingleton.getInstance().smartFoxClient.myself.isSpectator)
            {
                texture.txtTopDescription1.text = LanguageManager.getInstance().getText("_gcsChooseCharacterTitlemessage");
            }
            else
            {
                texture.txtTopDescription1.text = LanguageManager.getInstance().getText("_gcsChooseCharacterSpectatorsTitlemessage");
            }
            texture.txtTopTimeLeft.text = LanguageManager.getInstance().getAndReplaceText("_gcsChooseCharacterCountdownMessage", "%time%", "10");
            texture.txtVoteMap.text = LanguageManager.getInstance().getText("_gcsMapVotingTitle");
            
            EventListenerManager.setListenerTo(texture.voteMapItem0, MouseEvent.CLICK, onVoteMapItemClick, false, 0, true);
            texture.voteMapItem0.buttonMode = true;
            EventListenerManager.setListenerTo(texture.voteMapItem1, MouseEvent.CLICK, onVoteMapItemClick, false, 0, true);
            texture.voteMapItem1.buttonMode = true;
            EventListenerManager.setListenerTo(texture.voteMapItem2, MouseEvent.CLICK, onVoteMapItemClick, false, 0, true);
            texture.voteMapItem2.buttonMode = true;
            
            voteMapSelectedGlow = new GlowFilter(0xFF6600, 1, 6, 6, 8, 1, true);
            
            confirmationPopUp = texture.characterUnlockConfirmationPopUp;
            confirmationPopUp.txtMainTitle.text = LanguageManager.getInstance().getText("_unlockPopUpMainTitle");
            confirmationPopUp.txtDescription.text = LanguageManager.getInstance().getText("_unlockPopUpDescription");
            confirmationPopUp.txtDescription.visible = false;
            confirmationPopUp.txtDays.text = LanguageManager.getInstance().getText("_unlockPopUpDays");
            confirmationPopUp.txtDays.visible = false;
            confirmationPopUp.txtDaysNumber.visible = false
            confirmationPopUp.visible = false;
            confirmationPopUpCloseBtn = new CustomButton(confirmationPopUp.btnClose);
            EventListenerManager.setListenerTo(confirmationPopUpCloseBtn, MouseEvent.CLICK, onConfirmationPopUpMouseClick);
            confirmationPopUpUnlockBtn = new CustomButton(confirmationPopUp.btnGetItNow, "_csShopGetNowMessage");
            EventListenerManager.setListenerTo(confirmationPopUpUnlockBtn, MouseEvent.CLICK, onConfirmationPopUpMouseClick, false);
            
            toolTip = new CustomToolTip("_gcsBuyCharacterHover", true, 0.9);
            
            addChild(texture);
        }
        
        public function addCharactersFromServer(charactersArray:ISFSArray):void
        {
            for(var i:int = 0; i < charactersArray.size(); i++)
            {
                for(var j:int = 0; j < charactersArray.getSFSArray(i).size(); j++)
                {
                    charactersIndexArray.push(charactersArray.getSFSArray(i).getUtfString(j));
                }
                
                charactersAmountPerRow.push(charactersArray.getSFSArray(i).size());
                
                if(charactersArray.getSFSArray(i).size() > amountCharsMaxInRow)
                {
                    amountCharsMaxInRow = charactersArray.getSFSArray(i).size();
                }
            }
            
            amountChars = charactersIndexArray.length;
            
            createCharactersPanels();
        }
        
        public function showCharacterScreen():void
        {
            this.visible = true;
        }
        
        public function hideCharacterScreen():void
        {
            this.visible = false;
        }
        
        private function createCharactersPanels():void
        {
            var currentPanelItem:int = 0;
            var currentScrollComponent:int = 0;
            var thisPanel:MC_IngameCharacterSelectCharacter;
            var status:String;
            
            for(var i:int = 0; i < amountChars; i++)
            {
                var avatarIndex:int = int(charactersIndexArray[i]);
                
                if(SharedVars.characterReplacements[avatarIndex] != null)
                {
                    avatarIndex = int(SharedVars.characterReplacements[avatarIndex]);
                }
                
                if (currentPanelItem >= charactersAmountPerRow[currentScrollComponent] )
                {
                    currentPanelItem = 0;
                    currentScrollComponent++;
                }
                
                status = getCharacterAvailableStatus(i);
                thisPanel = new MC_IngameCharacterSelectCharacter;
                charactersRows.push(thisPanel);
                
                if(currentPanelItem == 0)
                {
                    thisPanel.x = 0;
                }
                else
                {
                    thisPanel.x = charactersRows[i - 1].x + charactersRows[i - 1].width + 11;
                }
                
                MovieClip(texture.getChildByName("row" + currentScrollComponent)).addChild(thisPanel);
                
                thisPanel.coins.visible = false;
                thisPanel.lockedOverlay.visible = false;
                thisPanel.background.gotoAndStop("free");
                thisPanel.avatar.gotoAndStop("avatar" + avatarIndex);
                
                if (status == "locked")
                {
                    thisPanel.lockedOverlay.visible = true;
                    thisPanel.bottom.gotoAndStop("locked");
                    thisPanel.bottom.label.text = LanguageManager.getInstance().getText("_locked");
                    
                    if(ShopInfoManager.instance.searchIdForBuyableCharacter(avatarIndex) != null)
                    {
                        if(ShopInfoManager.instance.searchIdForBuyableCharacter(avatarIndex).value == 0)
                        {
                            thisPanel.coins.label.text = LanguageManager.getInstance().getText("_free");
                        }
                        else
                        {
                            thisPanel.background.gotoAndStop("buyable");
                            thisPanel.bottom.gotoAndStop("buyable");
                            thisPanel.coins.label.text = ShopInfoManager.instance.searchIdForBuyableCharacter(avatarIndex).value.toString();
                            thisPanel.bottom.label.text = LanguageManager.getInstance().getText("_locked");
                        }
                        thisPanel.coins.visible = true;
                    }
                } 
                else 
                {
                    thisPanel.bottom.label.text = LanguageManager.getInstance().getText("_open");
                    thisPanel.background.gotoAndStop("free");
                    thisPanel.bottom.gotoAndStop("free");
                    
                    if(ShopInfoManager.instance.searchIdForBuyableCharacter(avatarIndex) != null)
                    {
                        thisPanel.coins.visible = true;
                        thisPanel.background.gotoAndStop("buyable");
                        thisPanel.bottom.gotoAndStop("buyable");
                        
                        if(ShopInfoManager.instance.searchIdForBuyableCharacter(avatarIndex).value == 0)
                        {
                            thisPanel.coins.label.text = LanguageManager.getInstance().getText("_free");
                            thisPanel.bottom.label.text = LanguageManager.getInstance().getText("_gcsFreeSlotMessage");
                        }
                        else
                        {
                            thisPanel.coins.label.text = ShopInfoManager.instance.searchIdForBuyableCharacter(avatarIndex).value.toString();
                            thisPanel.bottom.label.text = LanguageManager.getInstance().getText("_csShopGetNowMessage");
                        }
                        
                        if(InventoryManager.instance.searchBoughtCharacter(avatarIndex) != null)
                        {
                            thisPanel.coins.visible = false;
                            thisPanel.bottom.label.text = //ownedCharacterTimeLeft(InventoryManager.instance.searchBoughtCharacter(avatarIndex));
                            thisPanel.bottom.label.text = LanguageManager.getInstance().getText("_gisChooseCharacterMessage");
                        }
                        else
                        {
                            EventListenerManager.setListenerTo(thisPanel, MouseEvent.ROLL_OVER, onPlayerSelectionOver, false, 0, true);
                            EventListenerManager.setListenerTo(thisPanel, MouseEvent.ROLL_OUT, onPlayerSelectionOut, false, 0, true);
                        }
                    }
                    
                    
                    if (!SmartFoxClientSingleton.getInstance().smartFoxClient.myself.isSpectatorInRoom(SmartFoxClientSingleton.getInstance().smartFoxClient.gameRoom))
                    {
                        EventListenerManager.setListenerTo(thisPanel, MouseEvent.CLICK, onPlayerSelectionClick, false, 0, true);
                        thisPanel.buttonMode = true;
                    }
                }
                currentPanelItem++;
            }
            
            updateScrollPanels();
        }
        
        private function updateScrollPanels():void
        {
            if(amountCharsMaxInRow <= MAX_CHARS_PER_ROW)
            {
                leftArrow.disable();
                rightArrow.disable();
            }
            else
            {
                rightArrow.enable();
            }
        }
        
        private function onArrowClick(event:MouseEvent):void
        {
            if(event.target == leftArrow)
            {
                rightArrow.enable();
                
                if(arrowIndex > MAX_CHARS_PER_ROW)
                {
                    arrowIndex = MAX_CHARS_PER_ROW;
                    texture.row0.x = 60;
                    texture.row1.x = 60;
                    texture.row2.x = 60;
                    
                }
                
                if(arrowIndex == MAX_CHARS_PER_ROW)
                {
                    leftArrow.disable();
                }
            }
            else if(event.target == rightArrow)
            {
                leftArrow.enable();
                
                if(arrowIndex < amountCharsMaxInRow)
                {
                    arrowIndex = amountCharsMaxInRow;
                    texture.row0.x = 60 - (94 *(amountCharsMaxInRow - MAX_CHARS_PER_ROW));
                    texture.row1.x = 60 - (94 *(amountCharsMaxInRow - MAX_CHARS_PER_ROW));
                    texture.row2.x = 60 - (94 *(amountCharsMaxInRow - MAX_CHARS_PER_ROW));
                    trace(texture.row0.x);
                }
                if(arrowIndex == amountCharsMaxInRow)
                {
                    rightArrow.disable();
                }
            }
        }
        
        private function getCharacterAvailableStatus(characterId:uint):String
        {
            if (characterId >= charactersAmountPerRow[0] && !(SmartFoxClientSingleton.getInstance().smartFoxClient.myself.properties as UserLocalProperties).isRegistered && SharedVars.zoneOverride != "Test")
            {
                return "locked";
            }
            else 
            {
                if (characterId > charactersAmountPerRow[0])
                {
                    return "unlocked";
                } 
                else 
                {
                    return "free";
                }
            }
        }
        
        private function ownedCharacterTimeLeft(ownedCharacterInfo:InventoryOwnedCharacterInfo):String
        {
            var str:String = LanguageManager.getInstance().getText("_csShopStillMessage");
            
            if(ownedCharacterInfo.daysLeft >= 1)
            {
                str += " " + ownedCharacterInfo.daysLeft.toString() + " ";
                str += LanguageManager.getInstance().getText("_csShopDaysLeftMessage");
            }
            else if(ownedCharacterInfo.hoursLeft >= 1)
            {
                str += " " + ownedCharacterInfo.hoursLeft.toString() + " ";
                str += LanguageManager.getInstance().getText("_csShopHoursLeftMessage");
            }
            else if(ownedCharacterInfo.minutesLeft >= 1)
            {
                str += " " + ownedCharacterInfo.minutesLeft.toString() + " ";
                str += LanguageManager.getInstance().getText("_csShopMinutesLeftMessage"); 
            }
            
            return str;
        }
        
        private function onPlayerLockedTimerComplete(event:TimerEvent):void
        {
            playerLockedTimer.reset();
            texture.popUpCantSelect.visible = false;
        }
        
        private function onPlayerSelectionOver(event:MouseEvent):void
        {
            SharedVars.stage.addChild(toolTip);
            toolTip.visible = true;
        }
        private function onPlayerSelectionOut(event:MouseEvent):void
        {
            SharedVars.stage.removeChild(toolTip);
            toolTip.visible = false;
        }
        
        private function onPlayerSelectionClick(event:MouseEvent):void
        {
            var selectedCharacter:int = charactersRows.indexOf(event.currentTarget);
            var params:SFSObject = new SFSObject();
            
            if(!playerLocked)
            {
                if(ShopInfoManager.instance.searchIdForBuyableCharacter(charactersIndexArray[selectedCharacter]) != null)
                {
                    if(InventoryManager.instance.searchBoughtCharacter(charactersIndexArray[selectedCharacter]) != null)
                    {
                        params.putInt("player", (charactersIndexArray[selectedCharacter]));
                        params.putInt(ServerMessages.ROUND_NUMBER,GameData.instance.currentRound);
                        params.putUtfString("s",SmartFoxClientSingleton.getInstance().smartFoxClient.myself.name);
                        SmartFoxClientSingleton.getInstance().smartFoxClient.sendExtensionRequestToGameRoom(PlayerEvent.PLAYER_SELECTED, params);
                    }
                    else
                    {
                        lastCharacterInfo = ShopInfoManager.instance.searchIdForBuyableCharacter(charactersIndexArray[selectedCharacter]);
                        showConfirmationPopUp(ShopInfoManager.instance.searchIdForBuyableCharacter(charactersIndexArray[selectedCharacter]));
                    }
                }
                else
                {
                    params.putInt("player", (charactersIndexArray[selectedCharacter]));
                    params.putInt(ServerMessages.ROUND_NUMBER,GameData.instance.currentRound);
                    params.putUtfString("s",SmartFoxClientSingleton.getInstance().smartFoxClient.myself.name);
                    SmartFoxClientSingleton.getInstance().smartFoxClient.sendExtensionRequestToGameRoom(PlayerEvent.PLAYER_SELECTED, params);
                }
            }
            else
            {
                if(!playerLockedTimer.running)
                {
                    texture.popUpCantSelect.label.text = LanguageManager.getInstance().getText("_gcsLockedCharacterMessage");
                    texture.popUpCantSelect.visible = true;
                    playerLockedTimer.start();
                }
            }
        }
        
        public function onPlayerSelected(params:SFSObject):void
        {
            var charId:int = params.getInt("player");
            var player:int= charactersIndexArray.indexOf(params.getInt("player").toString());
            var sender:User = SmartFoxClientSingleton.getInstance().smartFoxClient.myself.userManager.getUserByName(params.getUtfString("s"));
            
            if(!params.containsKey("success"))
            {
                if (sender == null)
                {
                    return;
                }
                
                if(player >= 0)
                {
                    reservations[sender.id] = player;
                    reservationsCharactersIds[sender.id] = charId;
                    
                    if(sender.name == GameData.instance.myName)
                    {
                        charactersRows[player].background.gotoAndStop("myself");
                        charactersRows[player].bottom.gotoAndStop("myself");
                        
                        if(ShopInfoManager.instance.searchIdForBuyableCharacter(charId) != null)
                        {
                            charactersRows[player].coins.visible = false;
                            //charactersRows[player].bottom.label.text = ownedCharacterTimeLeft(InventoryManager.instance.searchBoughtCharacter(charId));
                            charactersRows[player].bottom.label.text = LanguageManager.getInstance().getText("_gisChooseCharacterMessage");
                        }
                    }
                    else
                    {
                        charactersRows[player].bottom.gotoAndStop("occupied");
                        charactersRows[player].background.gotoAndStop("occupied");
                        
                        if (getCharacterAvailableStatus(player) == "free")
                        {
                        } 
                        else
                        {
                            
                        }
                        
                        if(ShopInfoManager.instance.searchIdForBuyableCharacter(charId) != null)
                        {
                            charactersRows[player].coins.visible = false;
                        }
                    }
                    charactersRows[player].bottom.label.text = sender.name;
                    charactersRows[player].buttonMode = false;
                    EventListenerManager.removelistenerFrom(charactersRows[player], MouseEvent.CLICK, onPlayerSelectionClick);
                    if(sender.isItMe)
                    {
                        GameData.instance.myAvatar = player;
                        GameData.instance.randomAvatar = false;
                    }
                    if(sender.name == GameData.instance.myName)
                    {
                        playerLocked = true;
                        disableAllCharacters();
                    }
                    
                    confirmationPopUp.visible = false;
                    InGameUserListManager.getInstance().onCharacterSelected(sender.id, charId);
                }
                
                toolTip.visible = false;
                EventListenerManager.removelistenerFrom(charactersRows[player], MouseEvent.ROLL_OVER, onPlayerSelectionOver);
                EventListenerManager.removelistenerFrom(charactersRows[player], MouseEvent.ROLL_OUT, onPlayerSelectionOut);
            }
        }
        
        private function disableAllCharacters(removeClick:Boolean = false):void
        {
            for(var i:int = 0; i < charactersRows.length; i++)
            {
                if(removeClick)
                {
                    EventListenerManager.removelistenerFrom(charactersRows[i], MouseEvent.CLICK, onPlayerSelectionClick);
                }
                EventListenerManager.removelistenerFrom(charactersRows[i], MouseEvent.ROLL_OVER, onPlayerSelectionOver);
                EventListenerManager.removelistenerFrom(charactersRows[i], MouseEvent.ROLL_OUT, onPlayerSelectionOut);
                charactersRows[i].buttonMode = false;
            }
        }
        
        public function onCharacterSelectionTimerTick(params:SFSObject):void
        {
            var currentTick:int = params.getInt("counter")+1;
            var totalTime:int = params.getInt("tt");
            var timeLeft:int = totalTime - currentTick;
            
            texture.txtTopTimeLeft.text = LanguageManager.getInstance().getAndReplaceText("_gcsChooseCharacterCountdownMessage", "%time%", timeLeft.toString());
        }
        
        public function onUserLeave(params:SFSObject):void
        {
            if(SmartFoxClientSingleton.getInstance().smartFoxClient.getGamePlayersCount() < 2 && (SmartFoxClientSingleton.getInstance().smartFoxClient.gameRoom.properties as RoomLocalProperties).waitingList.length < 1)
            {
                texture.popUpNotEnoughPlayers.visible = true;
                texture.popUpNotEnoughPlayers.titleTxt.text = LanguageManager.getInstance().getText("_gcsPlayerLeftTitle");
                texture.popUpNotEnoughPlayers.infoTxt.text = LanguageManager.getInstance().getText("_gcsPlayerLeftMessage");
                texture.popUpNotEnoughPlayers.closeBtn.buttonMode = true;
                EventListenerManager.setListenerTo(texture.popUpNotEnoughPlayers.closeBtn, MouseEvent.CLICK, closePopUp, false, 0, true);
                disableAllCharacters(true);
            }
            GameData.instance.myId = GameData.instance.playerNames.indexOf(SmartFoxClientSingleton.getInstance().smartFoxClient.myself.name);
            
            InGameUserListManager.getInstance().onUserExitRoom(params.getInt("pid"));
        }
        
        private function closePopUp(event:Event):void
        {
            event.target.parent.visible = false;
        }
        
        private function onConfirmationPopUpMouseClick(event:MouseEvent):void
        {
            if(event.target == confirmationPopUpCloseBtn)
            {
                confirmationPopUp.visible = false;
            }
            else if(event.target == confirmationPopUpUnlockBtn)
            {
                if(lastCharacterInfo.value > InventoryManager.instance.coins)
                {
                    confirmationPopUp.visible = false;
                    
                    texture.popUpCantSelect.label.text = LanguageManager.getInstance().getText("_csCharacterSelectShopNotEnoughCoinsmessage");
                    texture.popUpCantSelect.visible = true;
                    playerLockedTimer.start();
                }
                else
                {
                    //HoneyTracksHelper.trackVirtualGoodsFeaturePurchase(lastCharacterInfo.id, ShopInfoManager.instance.searchIdForBuyableCharacter(lastCharacterInfo.id).value, false);
                    
                    var params:SFSObject = new SFSObject();
                    params.putInt("player", lastCharacterInfo.id);
                    params.putInt(ServerMessages.ROUND_NUMBER,GameData.instance.currentRound);
                    params.putUtfString("s",SmartFoxClientSingleton.getInstance().smartFoxClient.myself.name);
                    SmartFoxClientSingleton.getInstance().smartFoxClient.sendExtensionRequestToGameRoom(PlayerEvent.PLAYER_SELECTED, params);
                }
            }
        }
        
        private function showConfirmationPopUp(charInfo:ShopCharacterInfo):void
        {
            confirmationPopUp.icon.gotoAndStop("avatar" + charInfo.id);
            confirmationPopUp.coins.label.text = charInfo.value.toString();
            confirmationPopUp.visible = true;
        }
        
        private function onVoteMapItemClick(event:MouseEvent):void
        {
            var mapParams:SFSObject = new SFSObject();
            
            if(event.currentTarget == texture.voteMapItem0)
            {
                texture.voteMapItem0.mouseEnabled = false;
                texture.voteMapItem0.buttonMode = false;
                texture.voteMapItem0.image.filters = [voteMapSelectedGlow];
                texture.voteMapItem1.mouseEnabled = true;
                texture.voteMapItem1.buttonMode = true;
                texture.voteMapItem1.image.filters = [];
                texture.voteMapItem2.mouseEnabled = true;
                texture.voteMapItem2.buttonMode = true;
                texture.voteMapItem2.image.filters = [];
                
                mapParams.putUtfString("mapName", "classic");
                SmartFoxClientSingleton.getInstance().smartFoxClient.sendExtensionRequestToGameRoom("voteMap", mapParams);
            }
            else if(event.currentTarget == texture.voteMapItem1)
            {
                texture.voteMapItem0.mouseEnabled = true;
                texture.voteMapItem0.buttonMode = true;
                texture.voteMapItem0.image.filters = [];
                texture.voteMapItem1.mouseEnabled = false;
                texture.voteMapItem1.buttonMode = false;
                texture.voteMapItem1.image.filters = [voteMapSelectedGlow];
                texture.voteMapItem2.mouseEnabled = true;
                texture.voteMapItem2.buttonMode = true;
                texture.voteMapItem2.image.filters = [];
                
                mapParams.putUtfString("mapName", mapNames[1]);
                SmartFoxClientSingleton.getInstance().smartFoxClient.sendExtensionRequestToGameRoom("voteMap", mapParams);
            }
            else if(event.currentTarget == texture.voteMapItem2)
            {
                texture.voteMapItem0.mouseEnabled = true;
                texture.voteMapItem0.buttonMode = true;
                texture.voteMapItem0.image.filters = [];
                texture.voteMapItem1.mouseEnabled = true;
                texture.voteMapItem1.buttonMode = true;
                texture.voteMapItem1.image.filters = [];
                texture.voteMapItem2.mouseEnabled = false;
                texture.voteMapItem2.buttonMode = false;
                texture.voteMapItem2.image.filters = [voteMapSelectedGlow];
                
                mapParams.putUtfString("mapName", mapNames[2]);
                SmartFoxClientSingleton.getInstance().smartFoxClient.sendExtensionRequestToGameRoom("voteMap", mapParams);
            }
        }
        
        public function setUpVoteMaps(isfsMapNames:ISFSArray):void
        {
            mapNames = new Array;
            mapNames.push("classic");
            
            for(var i:int = 0; i < isfsMapNames.size(); i++)
            {
                mapNames.push(isfsMapNames.getUtfString(i));
            }
            
            texture.voteMapItem0.image.gotoAndStop("classic");
            texture.voteMapItem0.label.text = LanguageManager.getInstance().getText("_gcsMapVoteNoVotesMessage");
            
            texture.voteMapItem1.image.gotoAndStop(mapNames[1]);
            texture.voteMapItem1.label.text = LanguageManager.getInstance().getText("_gcsMapVoteNoVotesMessage");
            
            texture.voteMapItem2.image.gotoAndStop(mapNames[2]);
            texture.voteMapItem2.label.text = LanguageManager.getInstance().getText("_gcsMapVoteNoVotesMessage");
        }
        
        public function onVoteMapStatsUpdated(mapVotes:ISFSArray):void
        {
            var mapName:String ;
            var mapVoteObject:ISFSObject;
            var votes:int;
            var mapFound:Boolean = false;
            
            for(var i:int = 0; i < mapNames.length; i++)
            {
                mapName = mapNames[i];
                mapFound = false;
                
                for(var j:int = 0; j < mapVotes.size(); j++)
                {
                    mapVoteObject = mapVotes.getSFSObject(j);
                    
                    if(mapName == mapVoteObject.getUtfString("map"))
                    {
                        votes = mapVoteObject.getInt("votes");
                        
                        if(votes == 1)
                        {
                            texture["voteMapItem" + i].label.text = LanguageManager.getInstance().getText("_gcsMapVoteOneVoteMessage");
                        }
                        else if(votes >= 2)
                        {
                            texture["voteMapItem" + i].label.text = LanguageManager.getInstance().getAndReplaceText("_gcsMapVoteMoreVotesMessage", "%votes%", votes.toString());
                        }
                        
                        texture["voteMapItem" + i].barMask.x = 2 + ((texture["voteMapItem" + i ].barMask.width / SmartFoxClientSingleton.getInstance().smartFoxClient.gameRoom.userList.length) * votes);
                        mapFound = true;
                    }
                }
                
                if(!mapFound)
                {
                    texture["voteMapItem" + i].label.text = LanguageManager.getInstance().getText("_gcsMapVoteNoVotesMessage");
                    texture["voteMapItem" + i].barMask.x = -181;
                }
            }
        }
        
        public function dispose():void
        {
            if(toolTip.parent != null)
            {
                toolTip.parent.removeChild(toolTip);
            }
            toolTip.visible = false;
            
            
            if(playerLockedTimer.running)
            {
                playerLockedTimer.reset();
                playerLockedTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, onPlayerLockedTimerComplete);
                playerLockedTimer = null;
            }
        }
    }
}