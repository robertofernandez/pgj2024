package com.gq.moveobject
{
    import com.gq.system.*;
    import com.willdom.games.bomberman.communication.SmartFoxClientSingleton;
    import com.willdom.games.bomberman.consts.SkullTypes;
    import com.willdom.games.bomberman.controllers.ConfigController;
    import com.willdom.games.bomberman.position.PositionManager;
    import com.willdom.games.explodersmmo.shared.ui.CustomToolTip;
    
    import flash.geom.Point;

    /**
     * It represents an item in the game.
     */
    public class Treasure extends MoveObject
    {
        private const treasureArr:Array = [ "powerDown", "speedUp", "powerUp", "bombUp", "speedDown", 
                                           "speicalBomb", "bombDown", "powerBomb","maxPower", "mine",
                                           "rocket", "skull", "dangerBomb", "gold", "bouncingBomb",
                                           "powerGlove", "shield", "spikeBomb", "bomb_change"];
        private var disapear:Boolean;
        public var apearMode:String;
        private var count:uint;
        private var soundArr:Array = [ "item_down", "eat", "eat", "eat", "item_down",
                                      "eat", "item_down", "eat", "eat", "eat",
                                      "eat", "eat", "eat", "eat", "eat", "eat", "eat", 
                                      "eat", "eat", "eat"];
        private var mySound:String;
        private var burnable:Boolean;
        private var personWaitingForTargetReached:Person = null;
        public var currentTile:Point;
        public var skullType:String;
        public var itemType:String;
        
        public var movingDirection:int;
        public var targetPoint:Point;
        private const STEP_SIZE_X:int = 14;
        private const STEP_SIZE_Y:int = 14;

        public function Treasure():void
        {
            objectType = TREASURE;
            movingDirection = PositionManager.NONE;
        }

        override protected function initMyData():void
        {
            super.initMyData();
            mySound = soundArr[data_index];
        }
        
        public function initialValues(burnable:Boolean, initialTile:Point, rdm:Number):void {
            this.burnable = burnable;
            _stopsExplosionCategory = STOPS_EXPLOSION;
            currentTile = initialTile;
            itemType = treasureArr[data_index];
            skullType = "";
            if(itemType == "skull"){
                setSkullType(rdm);
            }            
        }
        
        private function setSkullType(rdm:Number):void
        {            
            this.burnable = false;
            
            if(rdm == 1){
                rdm = 0;
            }
            
            var possibleDiseases:Array = SkullTypes.DISEASES_ARRAY.concat();
            
            if(GameData.instance.onSuddenDeath){
                possibleDiseases.splice(possibleDiseases.indexOf(SkullTypes.SUDDEN_DEATH),1);
                possibleDiseases.splice(possibleDiseases.indexOf(SkullTypes.POSITION_SWITCH),1);
            }
            
            skullType = possibleDiseases[Math.floor(rdm * possibleDiseases.length)];
                        
            if (ConfigController.getInstance().gameTestingMode){
                if( rdm < 0.3){
                    skullType = SkullTypes.QUICK;
                }
                else if (rdm < .6)
                {
                    skullType = SkullTypes.LONG_FUSE;
                } 
                else 
                {
                    skullType = SkullTypes.SHORT_FUSE;
                }
                skullType = SkullTypes.SUDDEN_DEATH;
            }
            
            if(GameData.SHOW_ELEMENTS)
            {
                var toolTip:CustomToolTip = new CustomToolTip(skullType, false);
                toolTip.x -= 25;
                toolTip.y -= 15;
                super._this.addChild(toolTip);
            }
        }
        
        override public function updataEvent():void
        {
            if(!disapear)
            {
                if( apearMode == "fall" )
                {
                    fallen();
                }
            }
            else
            {
                disApearFunc();
            }

            if(movingDirection != PositionManager.NONE) {
                if(walkToTarget()){
                    movingDirection = PositionManager.NONE;
                } 
            }
            
            if( personWaitingForTargetReached != null && GameData.instance.walkControls[GameData.instance.myId].hasReachedTarget){
                //This point will only be used to pick up special bombs and diarrhoea skull
                personWaitingForTargetReached.getTreasure(this);
                personWaitingForTargetReached = null;
            }

            controlMc();
        }

        private function fallen():void
        {
            if( ++ count == 15 )
            {
                apearMode = "";
            }
            myZ += 400 / 15;
        }

        private function disApearFunc():void
        {
            _this.y -= 7;
            _this.alpha -= 0.1;
            _this.scaleX = _this.scaleY = 1.3;
            if( _this.alpha <= 0 )
            {
                _this.visible=false;
            }
        }
        //
        override public function controlMc ():void
        {
            if ( _this != null )
            {
                _this.x = myX;
                _this.y = myY + myZ;
                _this.scaleX = myDir;
            }
        }
        

        public function itemCaught(person:Person):void
        {
            if(!SmartFoxClientSingleton.getInstance().smartFoxClient.myself.isSpectatorInRoom(SmartFoxClientSingleton.getInstance().smartFoxClient.gameRoom)
                && int(person.myId) == GameData.instance.myId && !GameData.instance.walkControls[GameData.instance.myId].hasReachedTarget)
            {
                if(itemType == "speicalBomb" || itemType == "dangerBomb" ||
                   itemType == "powerBomb" || itemType == "bouncingBomb" ||
                   itemType == "mine" || itemType == "spikeBomb" ||
                   (itemType == "skull" && skullType==SkullTypes.DIARRHOEA) )
                {
                    personWaitingForTargetReached= person;
                }
                else
                {
                    person.getTreasure(this);
                }
                
            }
            else
            {
                person.getTreasure(this);
            }
            disapear = true;
            GameSys.addEffects(GameData.instance.topObjectContainer, "Effects", "Effect_10", myX, myY, 0);
            SoundClass.addMusic("sound" + String( uint( Math.random() * 7 ) + 1 ), mySound);
        }
        
        public override function restore():void {
            _this.y += 7;
            _this.alpha = 1;
            _this.scaleX = _this.scaleY = 1;
            disapear = false;
            _this.visible=true;
        }

        /**
         * Method to detonate elements.
         */
        override public function fireMe(bomb:Bomb):void
        {
            if(burnable || bomb == null){
                GameData.instance.positionManager.removeObjectFromMap(currentTile.x, currentTile.y, this);
                disapear = true;
            } else {
                GameData.instance.positionManager.moveItem(currentTile, PositionManager.getDirection(bomb.currentPositionxy, currentTile)); 
            }
        }

        override public function isCompatible(objectType:uint, myTile:Point,objectTile:Point):Boolean
        {
            if(PERSON == objectType || KICKER == objectType) {
                return true;
            } else {
                return false;
            }            
        }

        //TODO: refactor to re-use code from bomb
        private function walkToTarget():Boolean
        {
            if(GameData.DEBUG_MODE) {
                trace("item walking to target");
            }
            var hasReachedTarget:Boolean = false;
            switch(movingDirection)
            {
                case PositionManager.WEST:
                {
                    myX -= STEP_SIZE_X;
                    if(myX <= targetPoint.x){
                        myX = targetPoint.x;
                        hasReachedTarget = true;
                    }
                    break;
                }
                case PositionManager.EAST:
                {
                    myX += STEP_SIZE_X;
                    if(myX >= targetPoint.x){
                        myX = targetPoint.x;
                        hasReachedTarget = true;
                    }
                    break;
                }
                case PositionManager.NORTH:
                {
                    myY -= STEP_SIZE_Y;
                    if(myY <= targetPoint.y){
                        myY = targetPoint.y;
                        hasReachedTarget = true;
                    }
                    break;
                }
                case PositionManager.SOUTH:
                {
                    myY += STEP_SIZE_Y;
                    if(myY >= targetPoint.y){
                        myY = targetPoint.y;
                        hasReachedTarget = true;
                    }
                    break;
                }
                default:
                {
                    break;
                }
            }
            
            if(hasReachedTarget){
                
                if(GameData.DEBUG_MODE) 
                {
                    trace("item walking reached target <" + myX + ", " + myY + ">");
                }
                if(_this.parent != null)
                {
                    _this.parent.removeChild(_this);
                }
                getMyPosition();
                GameData.instance["Container_" + String(myCurrentPositionY)].addChild( _this);
            }
            else if(GameData.DEBUG_MODE)
            {
                trace("item walking not yet in target <" + myX + ", " + myY + ">");
            }
            controlMc();
            return hasReachedTarget;
        }
        
        public function destroy():void
        {
            personWaitingForTargetReached = null;
        }
    }
}