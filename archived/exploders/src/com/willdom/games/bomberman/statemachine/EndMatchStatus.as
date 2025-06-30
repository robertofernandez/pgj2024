package com.willdom.games.bomberman.statemachine
{
    import com.gq.moveobject.Person;
    import com.gq.system.GameData;
    import com.gq.system.GameSys;
    import com.gq.system.SoundClass;
    import com.gq.ui.InGameUserListManager;
    import com.greensock.TweenLite;
    import com.greensock.TweenMax;
    import com.greensock.easing.Linear;
    import com.jaludo.JaludoAds;
    import com.jaludo.data.JaludoAdType;
    import com.jaludo.data.JaludoAdsResult;
    import com.jaludo.errors.JaludoErrorCollection;
    import com.jaludo.events.JaludoAdEvent;
    import com.jaludo.services.ads.IJaludoAd;
    import com.smartfoxserver.v2.entities.User;
    import com.smartfoxserver.v2.entities.data.SFSObject;
    import com.willdom.games.bomberman.communication.RoomVarsEvent;
    import com.willdom.games.bomberman.communication.SmartFoxClientSingleton;
    import com.willdom.games.bomberman.config.GameConfigManager;
    import com.willdom.games.bomberman.consts.ServerMessages;
    import com.willdom.games.bomberman.gameobjects.GameObjectsContainer;
    import com.willdom.games.bomberman.gameobjects.PersonScore;
    import com.willdom.games.bomberman.rooms.RoomLocalProperties;
    import com.willdom.games.bomberman.user.UserLocalProperties;
    import com.willdom.games.explodersmmo.shared.consts.GameRoomVars;
    import com.willdom.games.explodersmmo.shared.consts.SharedVars;
    import com.willdom.games.explodersmmo.shared.helpers.StringHelper;
    import com.willdom.games.explodersmmo.shared.model.CustomLogger;
    import com.willdom.games.explodersmmo.shared.model.LocalUser;
    import com.willdom.games.explodersmmo.shared.stats.StatsManager;
    //import com.willdom.games.explodersmmo.shared.tracker.HoneyTrackConstants;
    //import com.willdom.games.explodersmmo.shared.tracker.HoneyTracks;
    //import com.willdom.games.explodersmmo.shared.tracker.HoneyTracksHelper;
    import com.willdom.tween.Tween;
    import com.willdom.tween.TweenData;
    import com.willdom.util.helpers.EventListenerManager;
    import com.willdom.util.math.Random;
    
    import flash.display.DisplayObject;
    import flash.display.MovieClip;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.events.TimerEvent;
    import flash.text.TextField;
    import flash.text.TextFormat;
    import flash.utils.Timer;

    public class EndMatchStatus extends BasicStatusWithEventHandling
    {
        private var END_RESULTS_SCREEN_TIME:int = 30;
        private static const WINNER_SCREEN_TIME:int = 20;
        private static var END_RESULTS_ENDING:int = 30;
        private static const ADVERTISEMENT_MAX_WIDTH:int = 550;
        private static const ADVERTISEMENT_MAX_HEIGHT:int = 370;
        private var currentEndGameTick:uint = 0;
        private var currentClockTween:TweenMax;
        private var currentNeedleTween:TweenMax;
        private var defaultAdvertisement:DefaultAdvertisement;
        private var advertisementTween:Tween;
        private var adContainer:Sprite;
        private var loadingMc:LoadingMc;
        private var ad:IJaludoAd;
        private var advertisementPopup:Sprite;
        private var gameObjectsContainer:GameObjectsContainer;
        private var winnersScreen:WinnersScreen;
        private var resultsTimeOffset:int = 0;
        private var endMatchScreen:EndMatchScreenMC;
        
        private var winnerScreenTimer:Timer;
        private var showAdvertismentScreen:Boolean = true;
        
        
        public function EndMatchStatus(gameObjectsContainer:GameObjectsContainer)
        {
            super();
            this.gameObjectsContainer = gameObjectsContainer;
        }
        
        override public function init(params:SFSObject):void
        {
            registerFunction(ServerMessages.END_GAME_TIMER_TICK, onEndGameTimerTick);
            registerFunction(ServerMessages.ACCEPT_REMATCH, onAcceptRematch);
            registerFunction(ServerMessages.DECLINE_REMATCH, onDeclineRematch);
            
            defaultAdvertisement = new DefaultAdvertisement();
            loadingMc = new LoadingMc();
            winnersScreen = new WinnersScreen();
            endMatchScreen = new EndMatchScreenMC();
            
            endMatchScreen.x = 85;
            endMatchScreen.y = 130;
            endMatchScreen.gotoAndStop("endmatch");
            
            /*if(SmartFoxClientSingleton.getInstance().smartFoxClient.myself.isSpectator)
            {
                endMatchScreen.spectatorsButton.visible = false;
            }
            else
            {
                endMatchScreen.spectatorsButton.visible = true;
            }
            endMatchScreen.homeButton.visible = false;
            endMatchScreen.spectatorsButton.buttonMode = true;
            endMatchScreen.homeButton.buttonMode = true;
            endMatchScreen.spectatorsButton.mouseChildren = false;*/
            
            /*if (!SmartFoxClientSingleton.getInstance().smartFoxClient.myself.isSpectatorInRoom(SmartFoxClientSingleton.getInstance().smartFoxClient.gameRoom))
            {
                EventListenerManager.setListenerTo(endMatchScreen.spectatorsButton, MouseEvent.CLICK, gameObjectsContainer.resultsScreenContainer.onRematchStatusClick);    
            }
            else
            {
                EventListenerManager.setListenerTo(endMatchScreen.spectatorsButton, MouseEvent.CLICK, gameObjectsContainer.resultsScreenContainer.toggleWaitingListStatus);
            }*/
            
            gameObjectsContainer.resultsScreenContainer.currentResultsScreen = endMatchScreen;
            //gameObjectsContainer.infoScreen.addChildAt(endMatchScreen, gameObjectsContainer.infoScreen.getChildIndex(gameObjectsContainer.infoScreen.spectateBox)-1);
            
            //showTotalResults();
            //showWinnersScreen();
            GameSys.updatePanels();
            /*if (GameData.instance.trophies)
            {
                gameObjectsContainer.resultsScreenContainer.fillTotalScreenTrophies(true);
            } 
            else 
            {
                gameObjectsContainer.resultsScreenContainer.fillTotalScreenScore(true);
            }*/
            /*EventListenerManager.setListenerTo(endMatchScreen.insufficientPeople.hitArea, MouseEvent.CLICK, GameSys.backToLobby, false, 0, true);
            endMatchScreen.insufficientPeople.hitArea.buttonMode = true;
            EventListenerManager.setListenerTo(endMatchScreen.insufficientPeople.btnClose, MouseEvent.CLICK, closeMe, false, 0, true);
            endMatchScreen.insufficientPeople.btnClose.buttonMode = true;
            LanguageManager.getInstance().registerTag("_tooBad", endMatchScreen.insufficientPeople.mainTitle, "text");
            GameSys.autoResize(endMatchScreen.insufficientPeople.mainTitle);
            LanguageManager.getInstance().registerTag("_notEnoughForRematch",  endMatchScreen.insufficientPeople.textItem1, "text");
            GameSys.autoResize(endMatchScreen.insufficientPeople.textItem1);
            LanguageManager.getInstance().registerTag("_backToLobby",  endMatchScreen.insufficientPeople.buttonTxt, "text");
            GameSys.autoResize(endMatchScreen.insufficientPeople.buttonTxt);
            endMatchScreen.resultsTimer.messagePanel.gotoAndStop("red");
            LanguageManager.getInstance().registerTag("_backToLobbyResults",  endMatchScreen.resultsTimer.timerMessage, "text");*/
            
            EventListenerManager.setListenerTo(SmartFoxClientSingleton.getInstance().smartFoxClient, RoomVarsEvent.VARS_CHANGED, onRoomVarsChanged);
            
            GameData.instance.gameBox.visible = false;
            
            if(GameData.instance.gameObjectsContainer.endMatchWinnerScreen == null)
            {
                GameData.instance.gameObjectsContainer.buildEndMatchDependencies();
            }
            
            winnerScreenTimer = new Timer(1000, 5);
            EventListenerManager.setListenerTo(winnerScreenTimer, TimerEvent.TIMER_COMPLETE, onWinnerScreenTimerComlete);
            winnerScreenTimer.start();
            
            GameData.instance.gameObjectsContainer.endMatchWinnerScreen.showWinnerScreen();
            GameData.instance.gameObjectsContainer.endMatchWinnerScreen.setWinnersData();
            
            //showTotalResults();
            gameObjectsContainer.resultsScreenContainer.fillTotalScreenScore();
        }
        
        private function showTotalResults(lastPlayer:Boolean = false):void
        {
            //if(GameData.instance.alreadyWinLose && !lastPlayer) return;
            //GameData.instance.alreadyWinLose = true;
            GameData.instance.scoreTimer = GameData.TOTAL_SHOW_TIMER;
            //var i:int = 0;
            /*if(GameData.instance.trophies)
            {
                gameObjectsContainer.resultsScreenContainer.fillTotalScreenTrophies(lastPlayer);
            }
            else
            {    
                gameObjectsContainer.resultsScreenContainer.fillTotalScreenScore(lastPlayer);
            }*/
        }
        
        private function onEnterFrame(event:Event):void
        {
            if (advertisementTween != null){
                advertisementTween.update();
            }
        }
        
        private function onEndGameTimerTick(params:SFSObject):void
        {
            if(params.containsKey("showAds"))
            {
                if(!params.getBool("showAds"))
                {
                    showAdvertismentScreen = false;
                    END_RESULTS_SCREEN_TIME = 15;
                }
                else
                {
                    showAdvertismentScreen = true;
                }
            }
            
            currentEndGameTick = params.getInt("counter");
            onEndGameTick(currentEndGameTick);
        }
        private function onDeclineRematch(params:SFSObject):void
        {
            var playerId:uint = params.getInt("pid");
            //gameObjectsContainer.resultsScreenContainer.toggleRematchStatusDisplay(Person.getPersonByUserId(playerId).myName, false);
            Person.getPersonByUserId(playerId).rematchAccepted = false;
            gameObjectsContainer.endMatchResultsScreen.onPlayerDeclinedRematch(playerId);
            InGameUserListManager.getInstance().onRoomVariableUpdate();
        }
        
        private function onAcceptRematch(params:SFSObject):void
        {
            var playerId:uint = params.getInt("pid");
            //gameObjectsContainer.resultsScreenContainer.toggleRematchStatusDisplay(Person.getPersonByUserId(playerId).myName, true);
            Person.getPersonByUserId(playerId).rematchAccepted = true;
            gameObjectsContainer.endMatchResultsScreen.onPlayerAcceptedRematch(playerId);
            InGameUserListManager.getInstance().onRoomVariableUpdate();
        }
        
        protected function onEndGameTick(tick:int):void
        {
            if (tick >= END_RESULTS_SCREEN_TIME - 1)
            {
                EventListenerManager.removelistenerFrom(SmartFoxClientSingleton.getInstance().smartFoxClient, RoomVarsEvent.VARS_CHANGED, onRoomVarsChanged);
            }
            
            if (tick != 0 ) 
            {
                if (resultsTimeOffset > 0 && tick >= resultsTimeOffset)
                {
                    if (currentClockTween != null)
                    {
                        currentClockTween.kill();
                    }
                    if (currentNeedleTween != null)
                    {
                        currentNeedleTween.kill();
                    }
                    
                    currentClockTween = TweenMax.to(endMatchScreen.resultsTimer.clockWork, 1, {ease:Linear.easeNone, frame:Math.floor((130 / (END_RESULTS_SCREEN_TIME - resultsTimeOffset))  * (tick - resultsTimeOffset + 1))});
                    currentNeedleTween = TweenMax.to(endMatchScreen.resultsTimer.clockWork.needle, 1, {ease:Linear.easeNone, frame:Math.floor((130 / (END_RESULTS_SCREEN_TIME - resultsTimeOffset))  * (tick - resultsTimeOffset + 1))});
                }
                if(defaultAdvertisement != null)
                {
                    LanguageManager.getInstance().registerTag("_advertisementClose",  defaultAdvertisement.closeTimer, "text","%time%","" + (WINNER_SCREEN_TIME - resultsTimeOffset - tick) );
                }
                endMatchScreen.resultsTimer.timeTxt.text = StringHelper.timeToClock(END_RESULTS_SCREEN_TIME - tick);
                if (tick == WINNER_SCREEN_TIME)
                {
                    cleanAd(true);
                    gotoResultsScreen(WINNER_SCREEN_TIME);
                }
                else if(tick == END_RESULTS_ENDING)
                {
                    SoundClass.addMusic( "music", "sfx_countdown", 1 );
                }
                
                GameData.instance.gameObjectsContainer.endMatchResultsScreen.updateTimer(END_RESULTS_SCREEN_TIME - tick);
            }
        }
        
        private function showWinnersScreen():void
        {
            var i:uint;
            CustomLogger.getInstance().log("[GameSys] showWinnerScreen called");
            if (GameData.instance.scores.length == 0)
            {
                return;
            }
            if(SmartFoxClientSingleton.getInstance().smartFoxClient.myself.isSpectatorInRoom(SmartFoxClientSingleton.getInstance().smartFoxClient.gameRoom))
            {
                if(GameData.instance.gameSync)
                {
                    GameConfigManager.getInstance().extendedContainer = false;
                }
                else
                {
                    GameData.instance.syncExtendedContainer = false;
                }
            }
            else
            {
                GameData.instance.syncExtendedContainer = false;
            }
            
            //HoneyTracksHelper.trackFeatureUsage(LocalUser.getInstance().registered, SmartFoxClientSingleton.getInstance().smartFoxClient.myself.isSpectator, HoneyTrackConstants.TRACKERNAME_GAME_FINISHED, GameSys.gameSource);
            
            //gameObjectsContainer.infoScreen.playerListComponent.visible = true;
            //gameObjectsContainer.resultsScreenContainer.currentResultsScreen.visible = false;
            /*if (!SmartFoxClientSingleton.getInstance().smartFoxClient.myself.isSpectatorInRoom(SmartFoxClientSingleton.getInstance().smartFoxClient.gameRoom))
            {
                gameObjectsContainer.infoScreen.powerUpBar.visible = true;
            }
            gameObjectsContainer.infoScreen.menuPopup.visible = false;
            winnersScreen.clockWork.visible = false;
            winnersScreen.timeTxt.visible = false;
            TweenMax.to(GameData.instance.topSprite, 0, {delay:.95, visible:false});
            GameSys.sortPlayersOrderByScore();*/
            var thisPersonScore:PersonScore = GameData.instance.scores[0];
            var winnerScore:int = thisPersonScore.totalScorePoints;
            var allWinners:Array = new Array();
            var iAmWinner:Boolean = false;
            allWinners.push(thisPersonScore);
            if(thisPersonScore.name == SmartFoxClientSingleton.getInstance().smartFoxClient.myself.name)
            {
                iAmWinner = true;
            }
            for (i = 1; i < GameData.instance.scores.length; i++)
            {
                
                thisPersonScore = GameData.instance.scores[i];
                
                if (thisPersonScore.totalScorePoints == winnerScore)
                {
                    
                    allWinners.push(thisPersonScore);
                    if(thisPersonScore.name == SmartFoxClientSingleton.getInstance().smartFoxClient.myself.name){
                        iAmWinner = true;
                    }
                } 
                else 
                {
                    break;
                }
            }
            
            if(iAmWinner)
            {
                SoundClass.addMusic( "music", "stinger_win", 1);
            }
            else
            {
                SoundClass.addMusic( "music", "stinger_lose", 1 );
            }
            //winnersScreen.gotoAndStop(1);
            
            if (allWinners.length < 3)
            {
                winnersScreen.winnersPanel.gotoAndStop("winners_" + allWinners.length);
            } 
            else 
            {
                winnersScreen.winnersPanel.gotoAndStop("winners_" + 3);
            }
            winnersScreen.x = 10;
            winnersScreen.y = 25;
            if (allWinners.length > 1)
            {
                LanguageManager.getInstance().registerTag("_theWinners",  winnersScreen.winnersPanel.mainTitle, "text");
            }
            else
            {
                LanguageManager.getInstance().registerTag("_theWinner",  winnersScreen.winnersPanel.mainTitle, "text");
            }
            
            for (i = 0; i < allWinners.length && i < 3; i++)
            {
                var thisPanel:MovieClip = winnersScreen.winnersPanel["panel" + (i+1)];
                if (allWinners.length == 1){
                    (winnersScreen.winnersPanel.avatarMark as MovieClip).addChild((allWinners[i] as PersonScore).playerAvatar);
                    (winnersScreen.winnersPanel.avatarMark as MovieClip).mask = winnersScreen.winnersPanel.maskMc;
                    (winnersScreen.winnersPanel.avatarMark as MovieClip).visible = false;
                    winnersScreen.winnersPanel.animationContainer.gotoAndStop("avatar" + (allWinners[i] as PersonScore).avatar);
                }
                if(winnersScreen.winnersPanel.maskMc != null)
                {
                    winnersScreen.winnersPanel.maskMc.visible = false;
                }
                thisPanel.mainTitle.text = (allWinners[i] as PersonScore).name;
                
                var u:User = SmartFoxClientSingleton.getInstance().smartFoxClient.getPlayerByName((allWinners[i] as PersonScore).name);
                
                LanguageManager.getInstance().registerTag("_skillpointsMessage",  thisPanel.skillpointsLabel, "text");
                LanguageManager.getInstance().registerTag("_ingameRankingMessage",  thisPanel.rankingLabel, "text");
                LanguageManager.getInstance().registerTag("_LeaderBoardWonGamesMessage",  thisPanel.wonLabel, "text");
                LanguageManager.getInstance().registerTag("_LeaderBoardLostGamesMessage",  thisPanel.lostLabel, "text");
                if(u != null)
                {
                    thisPanel.skillpointsTxt.text = (u.properties as UserLocalProperties).pointsStr;
                    thisPanel.rankingTxt.text = (u.properties as UserLocalProperties).ranking;
                    thisPanel.wonTxt.text = (u.properties as UserLocalProperties).gamesWon;
                    thisPanel.lostTxt.text = (u.properties as UserLocalProperties).gamesLost;
                    
                    if( !(u.properties as UserLocalProperties).isRegistered )
                    {
                        thisPanel.rankingTxt.text = 0;
                        thisPanel.skillpointsTxt.text = 0;
                    }
                }
            }
            
            var mask:Sprite = new Sprite();
            mask.graphics.beginFill(0x000000);
            mask.graphics.drawRect(0,0,760, 660);
            winnersScreen.addChild(mask);
            advertisementTween = new Tween();
            advertisementPopup = createAdvertisement();
            advertisementPopup.x = 380;
            advertisementPopup.mask = mask;
            winnersScreen.addChild(advertisementPopup);
            
            scaleAdPopup();
            
            var originalHeight:Number = advertisementPopup.height;
            advertisementPopup.x = 380;
            
            advertisementPopup.y = 740 + advertisementPopup.height;
            advertisementTween.addProperty("popup",new TweenData(675 - advertisementPopup.height/2, advertisementPopup, "y"));
            advertisementTween.start(850, false);
            
            adContainer = new Sprite();
            advertisementPopup.addChild(adContainer);
            
            gameObjectsContainer.infoScreen.addChild(winnersScreen);
            
            if(SharedVars.allowAds && SharedVars.midRollAds == "exploders")
            {
                JaludoAds.getAd(JaludoAdType.MID_ROLL, false, onAdsLoaded);
                CustomLogger.getInstance().log("[GameSys] getAd called");
            }
            else
            {
                showDefaultAd();
            }
            
            winnersScreen.alpha = 0;
            //TweenLite.to(winnersScreen, 1, {alpha: 1, onComplete: onWinnersScreenFadeInComplete});
            TweenLite.to(winnersScreen, 1, {alpha: 0, onComplete: onWinnersScreenFadeInComplete});
            
            if(!SmartFoxClientSingleton.getInstance().smartFoxClient.sfs.mySelf.isSpectator)
            {
                StatsManager.instance.onMatchEnded(iAmWinner, int(thisPanel.wonTxt.text));
                StatsManager.instance.sendData();
            }
        }
        
        private function onWinnersScreenFadeInComplete():void
        {
            gameObjectsContainer.selectionScreen.visible = false;
            gameObjectsContainer.noPlayersScreen.visible = false;
        }
        
        private function createAdvertisement():Sprite
        {
            
            var container:Sprite = new Sprite();
            container.graphics.beginFill(0xFFFFFF);
            container.graphics.drawRoundRect(-(550 + 20)/2,-(480 + 50)/2, 550 + 20, 480 + 80, 10, 10);
            container.graphics.beginFill(0x000000);
            container.graphics.drawRoundRect(-550/2,-480/2 + 5, 550, 480, 10, 10);
            container.addChild(loadingMc);
            loadingMc.x = -loadingMc.width/2;
            loadingMc.y = -loadingMc.height/2 - 19;
            
            var textField:TextField = new TextField();
            textField.defaultTextFormat = new TextFormat("arial", 16, 0x000000, true);
            textField.width = container.width;
            textField.height = 30;
            textField.x = 8 - container.width/2;
            textField.y = - container.height/2 + 14;
            textField.selectable = false;
            
            var r:Random;
            var randomNumber:int = Math.floor(Math.random()*5) + 1;
            
            LanguageManager.getInstance().registerTag("_advertisementMessage" + randomNumber,  textField, "text");
            container.addChild(textField);
            
            container.addChild(textField);
            var originalHeight:Number = container.height;
            
            return container;
        }
        
        private function showDefaultAd():void
        {
            if(loadingMc != null && loadingMc.parent != null)
            {
                advertisementPopup.removeChild(loadingMc);
                //HoneyTracks.trackFeatureUsage(HoneyTrackConstants.TRACKERNAME_ADVERTISMENT_VIEWED, HoneyTrackConstants.CATEGORY_MIDROLE, HoneyTrackConstants.SUBCATEGORY_ADVERTISMENT_PLACEHOLDER);
                LanguageManager.getInstance().registerTag("_advertisementClose",  defaultAdvertisement.closeTimer, "text","%time%", "" + WINNER_SCREEN_TIME );
                adContainer.addChild(defaultAdvertisement);
                loadingMc = null;
                defaultAdvertisement.x = -defaultAdvertisement.width/2;
                defaultAdvertisement.y = -defaultAdvertisement.height/2;
            }
        }
        
        private function onAdsLoaded(adData:JaludoAdsResult, errors:JaludoErrorCollection):void
        {
            if(errors)
            {
                showDefaultAd();
            }
            else
            {
                if(adContainer != null)
                {
                    ad = adData.ad;
                    //HoneyTracks.trackFeatureUsage(HoneyTrackConstants.TRACKERNAME_ADVERTISMENT_VIEWED, HoneyTrackConstants.CATEGORY_MIDROLE, HoneyTrackConstants.SUBCATEGORY_ADVERTISMENT);
                    adContainer.addChild(ad as DisplayObject);
                    ad.addEventListener(JaludoAdEvent.STARTED, adStartedHandler, false, 0, true);
                    ad.addEventListener(JaludoAdEvent.COMPLETED, adCompletedHandler, false, 0, true);
                    ad.start();
                    CustomLogger.getInstance().log("[GameSys] onAdsLoaded ok");
                }
            }
        }
        
        private function adStartedHandler(event:JaludoAdEvent):void
        {
            CustomLogger.getInstance().log("[GameSys] adStartedHandler");
            ad = event.ad;
            
            if(loadingMc != null){
                advertisementPopup.removeChild(loadingMc);
                loadingMc = null;
                adContainer.x = -ad.width/2;
                adContainer.y = -ad.height/2;
            }
            
            ad.removeEventListener(JaludoAdEvent.STARTED, adStartedHandler);
        }
        
        private function scaleAdPopup():void
        {
            if (advertisementPopup.width > ADVERTISEMENT_MAX_WIDTH || advertisementPopup.height > ADVERTISEMENT_MAX_HEIGHT)
            {
                var proportion:Number;
                if((advertisementPopup.width - ADVERTISEMENT_MAX_WIDTH) > (advertisementPopup.height - ADVERTISEMENT_MAX_HEIGHT))
                {
                    proportion = ADVERTISEMENT_MAX_WIDTH/advertisementPopup.width;
                }
                else
                {
                    proportion = ADVERTISEMENT_MAX_HEIGHT/advertisementPopup.height;
                }
                if(proportion < 1)
                {
                    advertisementPopup.scaleX = proportion;
                    advertisementPopup.scaleY = proportion;
                }
            }
        }
        
        private function cleanAd(stopIt:Boolean = false):void
        {
            if(ad != null )
            {
                if(stopIt)
                {
                    try
                    {
                        ad.stop();
                    }
                    catch(error:Error)
                    {
                        CustomLogger.getInstance().log("[GameSys] Exception catched when trying to stop ad");
                    }
                }
                if((ad as DisplayObject).parent != null)
                {
                    (ad as DisplayObject).parent.removeChild((ad as DisplayObject));
                }
                ad.removeEventListener(JaludoAdEvent.COMPLETED, adCompletedHandler);
                ad.removeEventListener(JaludoAdEvent.STARTED, adStartedHandler);
                ad = null;
            }
            
            GameData.instance.gameObjectsContainer.endMatchAdvertismentScreen.hideAdvertismentScreen();
        }
        
        private function adCompletedHandler(event:JaludoAdEvent):void
        {
            event.ad.removeEventListener(JaludoAdEvent.COMPLETED, adCompletedHandler);
            cleanAd();
            CustomLogger.getInstance().log("[GameSys] adCompletedHander");
            
            if (!endMatchScreen.visible)
            {
                gotoResultsScreen(currentEndGameTick);
            }
        }
        
        
        
        private function updateRematchStatusDisplay():void
        {
            var spot:int;
            for each (var thisScore:PersonScore in GameData.instance.scores)
            {
                var color:String = "red";
                spot = GameData.instance.scores.indexOf(thisScore);
                if (thisScore.person != null && thisScore.person.rematchAccepted) 
                {
                    color = "green"; 
                }
                
                if ( spot > -1 && endMatchScreen.totalResultsComponent["player"+(spot+1)] != null && endMatchScreen.visible)
                {
                    endMatchScreen.totalResultsComponent["player"+(spot+1)].dot.gotoAndStop(color);
                }
            }
            gameObjectsContainer.resultsScreenContainer.displayRematchAvailability();
        }
        
        private function gotoResultsScreen(currentTime:uint):void{
            SoundClass.addMusic( "music", "gameresults", 999 );
            if(SmartFoxClientSingleton.getInstance().smartFoxClient.myself.isSpectatorInRoom(SmartFoxClientSingleton.getInstance().smartFoxClient.gameRoom) ){
                if(GameData.instance.gameSync){
                    GameConfigManager.getInstance().extendedContainer = true;
                }else{
                    GameData.instance.syncExtendedContainer = true;
                }
            }else{
                GameConfigManager.getInstance().extendedContainer = true;
            }
            
            gameObjectsContainer.infoScreen.playerListComponent.visible=false;
            //endMatchScreen.visible = true;
            if ((GameSys.getRematchCount() + (SmartFoxClientSingleton.getInstance().smartFoxClient.gameRoom.properties as RoomLocalProperties).waitingList.length) > 1)
            {
                endMatchScreen.resultsTimer.messagePanel.gotoAndStop("green");
                LanguageManager.getInstance().registerTag("_newMatchStartingSoon", endMatchScreen.resultsTimer.timerMessage, "text");
            } 
            else 
            {
                endMatchScreen.resultsTimer.messagePanel.gotoAndStop("red");
                LanguageManager.getInstance().registerTag("_backToLobbyResults", endMatchScreen.resultsTimer.timerMessage, "text");
            }
            if (gameObjectsContainer.infoScreen.getChildByName(winnersScreen.name) != null)
            {
                gameObjectsContainer.infoScreen.removeChild(winnersScreen);
            }
            endMatchScreen.resultsTimer.clockWork.gotoAndStop(1);
            endMatchScreen.resultsTimer.clockWork.needle.gotoAndStop(1);
            
            updateRematchStatusDisplay();
            
            endMatchScreen.resultsTimer.clockWork.gotoAndStop(1);
            endMatchScreen.resultsTimer.clockWork.needle.gotoAndStop(1);
            resultsTimeOffset = currentTime;
            
            if(!SmartFoxClientSingleton.getInstance().smartFoxClient.gameRoom.getVariable(GameRoomVars.FRIENDLY_ROOM).getBoolValue() && !LocalUser.getInstance().registered)
            {
                gameObjectsContainer.infoScreen.playBtn.visible = false;
            }
            else if(SmartFoxClientSingleton.getInstance().smartFoxClient.myself.isSpectator)
            {
                gameObjectsContainer.infoScreen.playBtn.visible = false;
            }
            
            InGameUserListManager.getInstance().showEndMatchUserList();
            GameData.instance.gameObjectsContainer.endMatchResultsScreen.showEndResultsScreen(END_RESULTS_SCREEN_TIME - currentEndGameTick);
        }
        
        
        private function onRoomVarsChanged(e:RoomVarsEvent):void
        {
            if (SmartFoxClientSingleton.getInstance().smartFoxClient.gameRoom != null)
            {
                if (GameData.instance.trophies)
                {
                    gameObjectsContainer.resultsScreenContainer.fillTotalScreenTrophies(false, GameData.instance.resultsScrollCount);
                }
                else
                {
                    gameObjectsContainer.resultsScreenContainer.fillTotalScreenScore(false, GameData.instance.resultsScrollCount);
                }
                gameObjectsContainer.resultsScreenContainer.displayRematchAvailability();
                
                InGameUserListManager.getInstance().onRoomVariableUpdate();
            }
        }
        
        public function closeMe(e:MouseEvent):void
        {
            e.currentTarget.parent.visible = false;
        }
        
        private function onWinnerScreenTimerComlete(event:TimerEvent):void
        {
            GameData.instance.gameObjectsContainer.endMatchWinnerScreen.hideWinnerScreen();
            if(showAdvertismentScreen)
            {
                GameData.instance.gameObjectsContainer.endMatchAdvertismentScreen.showAdvertismentScreen();
                
                var mask:Sprite = new Sprite();
                mask.graphics.beginFill(0x000000);
                mask.graphics.drawRect(0,0,760, 660);
                GameData.instance.gameObjectsContainer.endMatchAdvertismentScreen.addChild(mask);
                advertisementTween = new Tween();
                advertisementPopup = createAdvertisement();
                advertisementPopup.x = 380;
                advertisementPopup.mask = mask;
                GameData.instance.gameObjectsContainer.endMatchAdvertismentScreen.addChild(advertisementPopup);
                
                scaleAdPopup();
                
                var originalHeight:Number = advertisementPopup.height;
                advertisementPopup.x = 350;
                advertisementPopup.y = 350;
                
                adContainer = new Sprite();
                advertisementPopup.addChild(adContainer);
                
                if(SharedVars.allowAds && SharedVars.midRollAds == "exploders")
                {
                    JaludoAds.getAd(JaludoAdType.MID_ROLL, false, onAdsLoaded);
                }
                else
                {
                    showDefaultAd();
                }
            }
            else
            {
                gotoResultsScreen(currentEndGameTick);
            }
        }
        
        override public function dispose(params:SFSObject):void
        {
            if(advertisementPopup != null)
            {
                advertisementPopup.removeEventListener (Event.ENTER_FRAME, onEnterFrame );
            }
            cleanAd(true);
            advertisementPopup = null;
            advertisementTween = null;
            defaultAdvertisement = null;
            adContainer = null;
            loadingMc = null; 
            
            endMatchScreen.visible = false;
            winnersScreen.visible = false;
            if(endMatchScreen.parent != null)
            {
                endMatchScreen.parent.removeChild(endMatchScreen);
            }
            if(winnersScreen.parent != null)
            {
                winnersScreen.parent.removeChild(winnersScreen);
            }
            endMatchScreen = null;
            winnersScreen = null;
            gameObjectsContainer.infoWindow.playBtn.visible = false;
        }
    }
}