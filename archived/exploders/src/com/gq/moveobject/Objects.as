package com.gq.moveobject
{
    import com.gq.system.GameData;
    import com.gq.system.GameTools;
    import com.willdom.games.explodersmmo.shared.model.CustomLogger;
    
    import configuration.StageModes;
    
    import flash.geom.Point;

    /**
     * It represents a box in the game.
     * It is a soft block.
     * 
     */
    public class Objects extends MoveObject
    {
        private var itemsByRound:Object;
        private var skullForRound:Object;
        public var haveGoods:Boolean;

        private var moveMode:Boolean;
        private var moveDir:Vector.<int> = new Vector.<int>();
        private var moveCount:uint;

        public function Objects():void
        {
            objectType = BOX;
            itemsByRound = new Object();
            skullForRound = new Object();
        }

        override protected function initMyData ():void
        {
            super.initMyData();
            _stopsExplosionCategory = STOPS_EXPLOSION;
            GameTools.pushArr( GameData.instance.boxArr, this );
            setMapInfor();
        }
        
        override public function updataEvent ():void
        {
            if( moveMode )
            {
                checkFallen();
                controlMc();
            }
        }

        private function checkFallen():void
        {
            if( myCurrentPositionY + moveDir[1] < 0
             || myCurrentPositionY + moveDir[1] >= GameData.instance.heightNum 
             || myCurrentPositionX + moveDir[0] < 0 
             || myCurrentPositionX + moveDir[0] >= GameData.instance.widthNum
             || GameData.instance.mapArr[ myCurrentPositionX + moveDir[0] ][ myCurrentPositionY + moveDir[1] ] > 0 )
            {
                setMapInfor();
                if(GameData.DEBUG_MODE){
                    trace("ADJUSTING OBJECT");
                }
                GameData.instance["Container_" + String(myCurrentPositionY)].addChild( _this );
                moveMode = false;
                return;
            }
            myX += moveDir[0] * GameData.instance.rectWidth / 2;
            myY += moveDir[1] * GameData.instance.rectHeight / 2;
            if( ++moveCount % 2 == 0 )
            {
                myCurrentPositionX += moveDir[0];
                myCurrentPositionY += moveDir[1];
            }
        }

        protected function setMapInfor():void
        {
            GameData.instance.mapArr[ myCurrentPositionX ][ myCurrentPositionY ] = data_index + 1;
            GameData.instance.mapObject[String(myCurrentPositionX) + "_" + String(myCurrentPositionY)] = this;
        }

        override public function fireMe(bomb:Bomb):void
        {
            if(data_index == 1) {
                return;
            }
            if(GameData.DEBUG_MODE){
                trace("[com.gq.moveobject.Objects] " + GameData.instance.myId + ': Box fired (' + myCurrentPositionX + ',' + myCurrentPositionY + ') +' + fire);
            }
            if( !fire )
            {
                fire = true;
                if( data_index != 111 && GameData.instance.STAGE_MODE != StageModes.GRAB)
                {
                    createTreasure();
                }
                _this.visible = false;
                GameData.instance.mapArr[myCurrentPositionX][myCurrentPositionY] = 0;
                GameData.instance.positionManager.removeObjectFromMap(myCurrentPositionX, myCurrentPositionY, this);
            }
        }
        
        public function openBox(offset:int=0):void
        {
            if(GameData.DEBUG_MODE){
                trace("[com.gq.moveobject.Objects] " + GameData.instance.myId + ': Box open (' + myCurrentPositionX + ',' + myCurrentPositionY + ')');
            }
            createTreasure(offset);
            _this.visible = false;
            fire = true;
            GameData.instance.mapArr[myCurrentPositionX][myCurrentPositionY] = 0;
            GameData.instance.positionManager.removeObjectFromMap(myCurrentPositionX, myCurrentPositionY, this);
        }

        public function cleanMe():Boolean
        {
            if(data_index == 1) {
                return false;
            } else {
                _this.visible = false;
                GameData.instance.mapArr[myCurrentPositionX][myCurrentPositionY] = 0;
                GameData.instance.positionManager.removeObjectFromMap(myCurrentPositionX, myCurrentPositionY, this);
                return true;
            }
        }

        public override function restore():void {
            fire = false;
            _this.visible = true;
        }

        private function createTreasure(offset:int=0):void
        {
            var currentItem:String = itemsByRound[GameData.instance.currentRound + offset];
            var skullType:Number = skullForRound[GameData.instance.currentRound + offset];
            var item:Treasure;
            
            if(currentItem == null)
            {
                return;
            }
            var currentItemNumber:uint = int(currentItem) + 1;

            if(GameData.DEBUG_MODE)
            {
                CustomLogger.getInstance().log("[com.gq.moveobject.Objects] creating item " + currentItemNumber);
            }
            
            if(GameData.instance.STAGE_MODE == StageModes.PENGUIN){
                item = GameData.instance.creater.createObj( "person", "Treasure", "TreasurePenguin_" + String(currentItemNumber), (myCurrentPositionX + 0.5) * GameData.instance.rectWidth, (myCurrentPositionY + 0.5) * GameData.instance.rectHeight + GameData.instance.upLine, 0, []) as Treasure;
                
            }else{
                item = GameData.instance.creater.createObj( "person", "Treasure", "Treasure_" + String(currentItemNumber), (myCurrentPositionX + 0.5) * GameData.instance.rectWidth, (myCurrentPositionY + 0.5) * GameData.instance.rectHeight + GameData.instance.upLine, 0, []) as Treasure;    
            }
            item.initialValues(GameData.instance.burnableItems, new Point(myCurrentPositionX, myCurrentPositionY), skullType);
            GameData.instance.positionManager.addObjectToMap(myCurrentPositionX, myCurrentPositionY, item);
        }
        
        public function setItemForRound(roundNumber:Number, itemNumber:Number):void
        {
            itemsByRound[roundNumber] = itemNumber;
        }
        
        public function setSkullForRound(roundNumber:Number, skullNumber:Number):void
        {
            skullForRound[roundNumber] = skullNumber;
        }

        public function touchMe( dir:Vector.<int> ):void
        {
            if( !moveMode )
            {
                moveMode = true;
                if (moveDir != null){
                    moveDir.splice(0, moveDir.length);
                }
                moveDir = dir;
                moveCount = 0;
                GameData.instance.mapObject[String(myCurrentPositionX) + "_" + String(myCurrentPositionY)] = null;
                GameData.instance.mapArr[myCurrentPositionX][myCurrentPositionY] = 0;
            }
        }
        //删除自身=======================================================================================
        override public function removeMe ():void
        {

            super.removeMe();

            GameTools.unPushArr(GameData.instance.actionArr, this);
            GameTools.unPushArr(GameData.instance.objectArr, this);

            GameData.instance.mapArr[myCurrentPositionX][myCurrentPositionY] = 0;
                        
            itemsByRound = null;
            skullForRound = null;
            moveDir = null;
            clearMeArea();
        }
        protected function clearMeArea():void
        {
        }
        
        override public function isCompatible(objectType:uint, myTile:Point,objectTile:Point):Boolean {
            //TODO: use game mode
            if(PERSON == objectType || KICKER == objectType || BOMB == objectType){
                return false;
            } else {
                return true;
            }
        }
        
        public function isHardBlock():Boolean
        {
            return (data_index == 1);
        }
        
        public override function dispose():void
        {
            super.dispose();
            itemsByRound = null;
            skullForRound = null;
            if (moveDir != null){
                moveDir.splice(0,moveDir.length);
                moveDir = null;
            }
        }
    }
}