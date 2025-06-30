package com.gq.ui.endmatch
{
    import com.gq.system.GameData;
    import com.gq.system.GameSys;
    import com.gq.system.SoundClass;
    import com.greensock.TweenMax;
    import com.willdom.games.bomberman.communication.SmartFoxClientSingleton;
    import com.willdom.games.bomberman.gameobjects.PersonScore;
    import com.willdom.games.bomberman.user.UserLocalProperties;
    import com.willdom.games.explodersmmo.shared.stats.StatsManager;
    
    import flash.display.MovieClip;
    import flash.display.Sprite;
    import flash.events.Event;

    public class EndMatchWinnerScreen extends Sprite
    {
        private var texture:MC_InGameWinnerScreen;
        private var tweenShowWinnerScreen:TweenMax;
        
        //Star particles variables
        private var particleMaxSpeed:Number = 4;
        private var particleFadeSpeed:Number = 0.005;
        private var particleTotal:Number = 2;
        private var particleRange:Number = 700;
        private var particleCurrentAmount:Number = 0;
        private var particleArray:Array;
        
        public function EndMatchWinnerScreen()
        {
            texture = new MC_InGameWinnerScreen;
            
            tweenShowWinnerScreen = new TweenMax(this, 1, {alpha: 1, onComplete: onShowScreenComplete});
            tweenShowWinnerScreen.pause();
            
            particleArray = new Array;
            
            addChild(texture);
        }
        
        public function showWinnerScreen():void
        {
            this.visible = true;
            this.alpha = 0;
            tweenShowWinnerScreen.play();
        }
        
        public function hideWinnerScreen():void
        {
            this.visible = false;
            this.alpha = 0;
            tweenShowWinnerScreen.restart();
            tweenShowWinnerScreen.pause();
            
            removeEventListener(Event.ENTER_FRAME, onEnterFrame);
            destroyAllParticles();
        }
        
        public function setWinnersData():void
        {
            var thisPersonScore:PersonScore;
            var iAmWinner:Boolean = false;
            GameSys.sortPlayersOrderByScore();
            
            if(GameData.instance.scores[0].name == SmartFoxClientSingleton.getInstance().smartFoxClient.myself.name)
            {
                iAmWinner = true;
            }
            
            for(var i:int = 0; i < GameData.instance.scores.length; i++)
            {
                thisPersonScore = GameData.instance.scores[i];
                
                if(i == 0)
                {
                    if (thisPersonScore.userId == SmartFoxClientSingleton.getInstance().smartFoxClient.myself.id)
                    {
                        setPosition1(thisPersonScore.avatar, thisPersonScore.name, true);
                    }
                    else
                    {
                        setPosition1(thisPersonScore.avatar, thisPersonScore.name);
                    }
                }
                else if(i == 1)
                {
                    if (thisPersonScore.userId == SmartFoxClientSingleton.getInstance().smartFoxClient.myself.id)
                    {
                        setPosition2(thisPersonScore.avatar, thisPersonScore.name, true);
                    }
                    else
                    {
                        setPosition2(thisPersonScore.avatar, thisPersonScore.name);
                    }
                }
                else if(i == 2)
                {
                    if (thisPersonScore.userId == SmartFoxClientSingleton.getInstance().smartFoxClient.myself.id)
                    {
                        setPosition3(thisPersonScore.avatar, thisPersonScore.name, true);
                    }
                    else
                    {
                        setPosition3(thisPersonScore.avatar, thisPersonScore.name);
                    }
                }
            }
            
            if(GameData.instance.scores.length == 1)
            {
                texture.avatarPosition2.visible = false;
                texture.position2Name.visible = false;
                texture.position2Circle.gotoAndStop("unknown");
                texture.position2Name.gotoAndStop("unknown");
                texture.position2Top.gotoAndStop("unknown");
                texture.position2Text.textColor = 0x1B94BA;
                
                texture.avatarPosition3.visible = false;
                texture.position3Name.visible = false;
                texture.position3Circle.gotoAndStop("unknown");
                texture.position3Name.gotoAndStop("unknown");
                texture.position3Top.gotoAndStop("unknown");
                texture.position3Text.textColor = 0x1B94BA;
            }
            else if(GameData.instance.scores.length == 2)
            {
                texture.avatarPosition3.visible = false;
                texture.position3Name.visible = false;
                texture.position3Circle.gotoAndStop("unknown");
                texture.position3Name.gotoAndStop("unknown");
                texture.position3Top.gotoAndStop("unknown");
                texture.position3Text.textColor = 0x1B94BA;
            }
            
            if(iAmWinner)
            {
                SoundClass.addMusic( "music", "stinger_win", 1);
            }
            else
            {
                SoundClass.addMusic( "music", "stinger_lose", 1 );
            }
            
            if(GameData.instance.scores.length >= 2)
            {
                if(GameData.instance.scores[0].totalScore == GameData.instance.scores[1].totalScore)
                {
                    texture.drawMessage.visible = true;
                    texture.drawMessage.label.text = LanguageManager.getInstance().getText("_gisWinnerDrawMessage");
                }
                else
                {
                    texture.drawMessage.visible = false;
                }
            }
            
            if(!SmartFoxClientSingleton.getInstance().smartFoxClient.sfs.mySelf.isSpectator)
            {
                StatsManager.instance.onMatchEnded(iAmWinner, (SmartFoxClientSingleton.getInstance().smartFoxClient.myself.properties as UserLocalProperties).gamesWon);
                StatsManager.instance.sendData();
            }
        }
        
        public function dispose():void
        {
            hideWinnerScreen();
        }
        
        private function setPosition1(characterId:int, name:String, mySelf:Boolean = false):void
        {
            texture.avatarPosition1.gotoAndStop("avatar" + characterId);
            texture.position1Name.label.text = name;
            
            if(mySelf)
            {
                texture.position1Circle.gotoAndStop("myself");
                texture.position1Name.gotoAndStop("myself");
                texture.position1Top.gotoAndStop("myself");
                texture.position1Text.textColor = 0xFF4800;
            }
            else
            {
                texture.position1Circle.gotoAndStop("unknown");
                texture.position1Name.gotoAndStop("unknown");
                texture.position1Top.gotoAndStop("unknown");
                texture.position1Text.textColor = 0x1B94BA;
            }
        }
        
        private function setPosition2(characterId:int, name:String, mySelf:Boolean = false):void
        {
            texture.avatarPosition2.gotoAndStop("avatar" + characterId);
            texture.position2Name.label.text = name;
            
            if(mySelf)
            {
                texture.position2Circle.gotoAndStop("myself");
                texture.position2Name.gotoAndStop("myself");
                texture.position2Top.gotoAndStop("myself");
                texture.position2Text.textColor = 0xFF4800;
            }
            else
            {
                texture.position2Circle.gotoAndStop("unknown");
                texture.position2Name.gotoAndStop("unknown");
                texture.position2Top.gotoAndStop("unknown");
                texture.position2Text.textColor = 0x1B94BA;
            }
        }
        
        private function setPosition3(characterId:int, name:String, mySelf:Boolean = false):void
        {
            texture.avatarPosition3.gotoAndStop("avatar" + characterId);
            texture.position3Name.label.text = name;
            
            if(mySelf)
            {
                texture.position3Circle.gotoAndStop("myself");
                texture.position3Name.gotoAndStop("myself");
                texture.position3Top.gotoAndStop("myself");
                texture.position3Text.textColor = 0xFF4800;
            }
            else
            {
                texture.position3Circle.gotoAndStop("unknown");
                texture.position3Name.gotoAndStop("unknown");
                texture.position3Top.gotoAndStop("unknown");
                texture.position3Text.textColor = 0x1B94BA;
            }
        }
        
        private function onShowScreenComplete():void
        {
            for(var i:int = 0; i < 20; i++)
            {
                createParticle(0, -50);
            }
            
            addEventListener(Event.ENTER_FRAME, onEnterFrame);
        }
        
        private function onEnterFrame(event:Event):void
        {
            updateParticle();
        }
        
        private function createParticle(targetX:Number, targetY:Number):void
        {
            for (var i:Number = 0; i < particleTotal; i++) 
            {
                var particle_mc:MovieClip = new MC_WinnerScreenStar();
                
                particle_mc.x = targetX;
                particle_mc.y = targetY;
                particle_mc.rotation = Math.random() * 360;
                particle_mc.alpha = Math.random() * 1 + .5;
                
                particle_mc.boundyLeft = targetX - particleRange;
                particle_mc.boundyTop = targetY - particleRange;
                particle_mc.boundyRight = targetX + particleRange;
                particle_mc.boundyBottom = targetY + particleRange;
                
                particle_mc.speedX = Math.random() * particleMaxSpeed - Math.random() * particleMaxSpeed;
                particle_mc.speedY = Math.random() * particleMaxSpeed - Math.random() * particleMaxSpeed;
                particle_mc.speedX *= particleMaxSpeed;
                particle_mc.speedY *= particleMaxSpeed;
                particle_mc.aceleration = 0.1;
                particle_mc.rotationSpeed = Math.random() * 8 - Math.random() * -8;
                
                particle_mc.fadeSpeed = Math.random()*particleFadeSpeed;
                
                particleCurrentAmount++;
                
                particleArray.push(particle_mc);
                
                texture.background.addChild(particle_mc);
            }
        }
        
        private function updateParticle():void
        {
            for (var i:int = 0; i < particleArray.length; i++)
            {
                var tempParticle:MovieClip = particleArray[i];
                tempParticle.aceleration += 0.01;
                tempParticle.speedY += tempParticle.aceleration;
                tempParticle.alpha -= tempParticle.fadeSpeed;
                tempParticle.x += tempParticle.speedX;
                tempParticle.y += tempParticle.speedY;
                tempParticle.rotation += tempParticle.rotationSpeed;
                
                if (tempParticle.alpha <= 0)
                {
                    destroyParticle(tempParticle);
                }
                else if (tempParticle.x < tempParticle.boundyLeft || 
                    tempParticle.x > tempParticle.boundyRight || 
                    tempParticle.y < tempParticle.boundyTop || 
                    tempParticle.y > tempParticle.boundyBottom)
                {
                    tempParticle.fadeSpeed += .05;
                }
            }
        }
        
        private function destroyParticle(particle:MovieClip):void
        {
            for (var i:int = 0; i < particleArray.length; i++)
            {
                var tempParticle:MovieClip = particleArray[i];
                if (tempParticle == particle)
                {
                    particleCurrentAmount--;
                    particleArray.splice(i,1);
                    tempParticle.parent.removeChild(tempParticle);
                }
            }
        }
        
        private function destroyAllParticles():void
        {
            for(var i:int = 0; i < particleArray.length; i++)
            {
                var particle:MovieClip = particleArray[i];
                
                if(particle.parent != null)
                {
                    particle.parent.removeChild(particle);
                }
                
                particle = null;
            }
            
            particleArray.splice(i, particleArray.length);
        }
    }
}