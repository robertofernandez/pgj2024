package com.gq.moveobject
{
    import com.gq.system.GameData;
    import com.smartfoxserver.v2.entities.data.SFSArray;
    import com.smartfoxserver.v2.entities.data.SFSObject;
    import com.willdom.games.bomberman.communication.GameUtilityTool;
    import com.willdom.games.bomberman.communication.SmartFoxClientSingleton;
    import com.willdom.games.bomberman.consts.ServerMessages;
    import com.willdom.games.bomberman.position.PositionManager;
    import flash.display.MovieClip;
    import flash.geom.Point;
    import flash.utils.getTimer;
    
    public class DeadlyBlock extends Objects
    {
        private static const FLY_DISTANCE:int = 19;
        private static var presetBlocks:Array;
        private var originalSkullY:int;
        private var _onGround:Boolean = false;
        private var lastFallTime:int = 0;
        private var isFalling:Boolean = false;
        private var activatedByServer:Boolean = false;
        private var _finalX:int = 0;
        private var _finalY:int = 0;
        private var _isFinal:Boolean = false;
        private var lastTimer:int;
        private var blockVel:Number;
        private var shadowVel:Number;
        public var id:int;
        
        public static function createDeadlyBlock(xSpot:int, ySpot:int, oldBlock:MovieClip = null):void
        {
            var thisDeadly:MoveObject
            if (oldBlock == null)
            {
                thisDeadly =( GameData.instance.creater.createObj("person", "DeadlyBlock", "DeadlyBlock_1",(xSpot + 0.5) * GameData.instance.rectWidth,
                    (ySpot + 1.5) * GameData.instance.rectHeight +  GameData.instance.upLine,0,[])) as MoveObject;
            }
            else
            {
                thisDeadly =(GameData.instance.creater.reinitializeObj("person", "DeadlyBlock", "DeadlyBlock_1",(xSpot + 0.5) * GameData.instance.rectWidth,
                    (ySpot + 1.5) * GameData.instance.rectHeight +  GameData.instance.upLine,0,[],oldBlock)) as MoveObject;
            }
            (thisDeadly as DeadlyBlock)._this.x = (xSpot + .5) * GameData.instance.rectWidth;
            (thisDeadly as DeadlyBlock)._this.y = (ySpot + 1.5) * GameData.instance.rectHeight +  GameData.instance.upLine;
            (thisDeadly as DeadlyBlock)._this.skullBox.y = -28;
            GameData.instance.currentMap.deadlyBlocks[xSpot][ySpot] = thisDeadly;
            (thisDeadly as DeadlyBlock).setOnTheSky(xSpot,ySpot);
        }
        
        public static function getBlockSpot(blockX:int, blockY:int):DeadlyBlock
        {
            return GameData.instance.currentMap.deadlyBlocks[blockX][blockY];
        }
        
        public static function eraseDeadlyBlocks():void
        {
            if (GameData.instance.currentMap.deadlyBlocks != null){
                for (var i:uint = 0; i < GameData.instance.currentMap.deadlyBlocks.length; i++)
                {
                    for (var j:uint = 0; j < (GameData.instance.currentMap.deadlyBlocks[i] as Array).length; j++)
                    {
                        if (GameData.instance.currentMap.deadlyBlocks[i][j] != null)
                        {
                            (GameData.instance.currentMap.deadlyBlocks[i][j] as DeadlyBlock).removeMe();
                        }
                    }
                }
            }
        }

        public static function initBlocks():void
        {
            presetBlocks = GameUtilityTool.getStoredContent();
        }
        
        public static function popBlock():DeadlyBlock
        {
            return presetBlocks.pop();
        }
        
        public function DeadlyBlock()
        {
            super();
            objectType = BOX;
        }
        
        public function setFinal():void
        {
            _isFinal = true;
        }
        
        public function get isFinal():Boolean
        {
            return _isFinal;
        }
        
        public override function isHardBlock():Boolean
        {
            return _onGround;
        }
        
        public override function fireMe(bomb:Bomb):void
        {
            return;
        }
        
        public function setOnTheSky(finalX:int, finalY:int):void
        {
            _finalX = finalX;
            _finalY = finalY;
            originalSkullY = _this.skullBox.y;
            blockVel = (GameData.instance.rectHeight*FLY_DISTANCE - GameData.instance.rectHeight - originalSkullY)/1000;
            shadowVel = 1/1400;
            _this.y -= GameData.instance.rectHeight;
            _this.skullBox.y -= GameData.instance.rectHeight*FLY_DISTANCE;            
            _this.shadow.scaleX = .0;
            _this.shadow.scaleY = .0;
            
            if (!PositionManager.boxInTile(new Point(finalX,finalY)))
            {
                _this.shadow.y = -(_this.skullBox.height - GameData.instance.rectHeight) + 4;
            }
        }
        
        public function set onGround(value:Boolean):void
        {
            _onGround = value;
        }
        
        public function get finalX():int
        {
            return _finalX;
        }
        
        public function get finalY():int
        {
            return _finalY;
        }
        
        public function setUpBlock(x:int,y:int):void
        {
        }
        
        public function activateMe():void
        {
            var objectsInTile:Array = GameData.instance.positionManager.getObjectsInTile(new Point(_finalX, _finalY));
            var peopleKilled:SFSArray = new SFSArray();
            
            if (objectsInTile != null && objectsInTile.length > 0)
            {
                var objectsFound:Array;
                objectsFound = objectsInTile.concat();
            }
            
            for (var i:uint = 0; objectsFound != null && i < objectsFound.length; i++)
            {
                var blockBomb:Bomb = new Bomb();
                blockBomb.data_index = 6;
                
                if (objectsFound[i] is Person)
                {
                    peopleKilled.addInt((objectsFound[i] as Person).userId);
                    (objectsFound[i] as Person)._this.visible = false;
                    (objectsFound[i] as Person).fireMe(blockBomb);
                } 
                else if (objectsFound[i] is Bomb && (objectsFound[i] as Bomb).bombType != Bomb.MINE)
                {
                    (objectsFound[i] as Bomb).confirmExplosion(new Point(_finalX, _finalY));
                } 
                else if  (objectsFound[i] is Bomb && (objectsFound[i] as Bomb).bombType == Bomb.MINE)
                { 
                    (objectsFound[i] as Bomb).deleteMe = true;
                }
                else 
                {
                    objectsFound[i].fireMe(blockBomb);
                }
            }
            
            if (peopleKilled.size() > 0 || isFinal)
            {
                var blockFallResults:SFSObject = new SFSObject();
                
                if (peopleKilled.size() > 0){
                    blockFallResults.putSFSArray("peopleKilled", peopleKilled);
                }
                blockFallResults.putInt("fid", id);
                if (isFinal)
                {
                    blockFallResults.putBool(ServerMessages.DEADLY_BLOCK_IS_FINAL, true);
                }
                SmartFoxClientSingleton.getInstance().smartFoxClient.sendExtensionRequestToGameRoom(ServerMessages.BLOCK_FALL_RESULT, blockFallResults);
            }
            GameData.instance.positionManager.addObjectToMap(_finalX,_finalY,this);
        }
        
        public function startFall(fallTime:int = 1000):void
        {
            _this.visible = true;
            isFalling = true;
            lastFallTime = fallTime;
            
            if(lastTimer == 0)
            {
                lastTimer = getTimer();
                isFalling = true;
            }
        }
        
        
        override public function updataEvent():void
        {
            var offset:Number;
            if (activatedByServer)
            {
                offset = 0;
            }
            else
            {
                offset = GameData.instance.rectHeight;
            }
            
            if (isFalling || activatedByServer)
            {
                var currentTimer:Number = (getTimer() - lastTimer);
                if(_this.skullBox.y < originalSkullY-offset)
                {
                    _this.skullBox.y += currentTimer * blockVel;
                    _this.shadow.scaleX += currentTimer * shadowVel;
                    _this.shadow.scaleY += currentTimer * shadowVel;
                    if(_this.skullBox.y > originalSkullY-offset)
                    {
                        _this.skullBox.y = originalSkullY-offset;   
                        isFalling = false;
                    }
                } 
                lastTimer = getTimer();
            }
        }
        
        public function endFall():void
        {
            activatedByServer = true;
            var fallTime:Number = lastFallTime/(FLY_DISTANCE - 1)/1000;
            isFalling = false;
            activateMe();
        }
    }
}