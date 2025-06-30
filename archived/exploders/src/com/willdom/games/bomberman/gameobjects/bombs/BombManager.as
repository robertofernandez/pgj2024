package com.willdom.games.bomberman.gameobjects.bombs
{
    import com.gq.moveobject.Bomb;
    import com.gq.moveobject.MoveObject;
    import com.gq.moveobject.Person;
    import com.gq.system.GameData;
    import com.smartfoxserver.v2.core.SFSEvent;
    import com.smartfoxserver.v2.entities.data.SFSObject;
    import com.willdom.games.bomberman.communication.SmartFoxClientSingleton;
    import com.willdom.games.bomberman.consts.ServerMessages;
    import com.willdom.games.bomberman.spectators.ServerMessagesHandler;
    import com.willdom.games.explodersmmo.shared.stats.StatsManager;
    import com.willdom.util.helpers.EventListenerManager;
    
    import configuration.StageModes;
    
    import flash.events.EventDispatcher;
    import flash.events.IEventDispatcher;
    import flash.geom.Point;
    
    public class BombManager extends EventDispatcher
    {
        public static const SET_BOMB:String = "setBomb";
        public static const EXPLODE_BOMB:String = "explodeBomb";
        public static const ACTIVATE_MINE:String = "activateMine";
        public static const BLOW_MINE:String = "blowMine";

        private var burstBombs:Object;
        private var readyBombs:Object;
        private var collisionManager:BombCollisionManager;
        
        public function BombManager(target:IEventDispatcher=null)
        {
            super(target);
            burstBombs = new Object();
            readyBombs = new Object();
            collisionManager = new BombCollisionManager();
            var stopMovementStayActor:BombCollisionActor = new BombCollisionActor(new StayBombsCollisionAction(), new StopMovingBombsCollisionAction());
            var stopMovementStopMovementActor:BombCollisionActor = new BombCollisionActor(new StopMovingBombsCollisionAction(), new StopMovingBombsCollisionAction());
            var bounceStayActor:BombCollisionActor = new BombCollisionActor(new StayBombsCollisionAction(), new BounceBombsCollisionAction());
            var bounceStopMovementActor:BombCollisionActor = new BombCollisionActor(new StopMovingBombsCollisionAction(), new BounceBombsCollisionAction());
            var stopMovingBounceActor:BombCollisionActor = new BombCollisionActor(new BounceBombsCollisionAction(), new StopMovingBombsCollisionAction());
            var fusionActor:BombCollisionActor = new BombCollisionActor(new MorphIntoDangerousBombsCollisionAction(), new DissapearBombsCollisionAction());

            collisionManager.registerActor(Bomb.NORMAL_BOMB, Bomb.NORMAL_BOMB, BombCollisionManager.BOMB_STAYING, stopMovementStayActor);
            collisionManager.registerActor(Bomb.NORMAL_BOMB, Bomb.DANGER_BOMB, BombCollisionManager.BOMB_STAYING, stopMovementStayActor);
            collisionManager.registerActor(Bomb.NORMAL_BOMB, Bomb.POWER_BOMB, BombCollisionManager.BOMB_STAYING, stopMovementStayActor);
            collisionManager.registerActor(Bomb.NORMAL_BOMB, Bomb.SPIKE_BOMB, BombCollisionManager.BOMB_STAYING, stopMovementStayActor);
            collisionManager.registerActor(Bomb.NORMAL_BOMB, Bomb.BOUNCING_BOMB, BombCollisionManager.BOMB_STAYING, stopMovementStayActor);
            
            collisionManager.registerActor(Bomb.DANGER_BOMB, Bomb.NORMAL_BOMB, BombCollisionManager.BOMB_STAYING, stopMovementStayActor);
            collisionManager.registerActor(Bomb.DANGER_BOMB, Bomb.DANGER_BOMB, BombCollisionManager.BOMB_STAYING, stopMovementStayActor);
            collisionManager.registerActor(Bomb.DANGER_BOMB, Bomb.POWER_BOMB, BombCollisionManager.BOMB_STAYING, stopMovementStayActor);
            collisionManager.registerActor(Bomb.DANGER_BOMB, Bomb.SPIKE_BOMB, BombCollisionManager.BOMB_STAYING, stopMovementStayActor);
            collisionManager.registerActor(Bomb.DANGER_BOMB, Bomb.BOUNCING_BOMB, BombCollisionManager.BOMB_STAYING, stopMovementStayActor);
            
            collisionManager.registerActor(Bomb.POWER_BOMB, Bomb.NORMAL_BOMB, BombCollisionManager.BOMB_STAYING, stopMovementStayActor);
            collisionManager.registerActor(Bomb.POWER_BOMB, Bomb.DANGER_BOMB, BombCollisionManager.BOMB_STAYING, stopMovementStayActor);
            collisionManager.registerActor(Bomb.POWER_BOMB, Bomb.POWER_BOMB, BombCollisionManager.BOMB_STAYING, stopMovementStayActor);
            collisionManager.registerActor(Bomb.POWER_BOMB, Bomb.SPIKE_BOMB, BombCollisionManager.BOMB_STAYING, stopMovementStayActor);
            collisionManager.registerActor(Bomb.POWER_BOMB, Bomb.BOUNCING_BOMB, BombCollisionManager.BOMB_STAYING, stopMovementStayActor);
            
            collisionManager.registerActor(Bomb.SPIKE_BOMB, Bomb.NORMAL_BOMB, BombCollisionManager.BOMB_STAYING, stopMovementStayActor);
            collisionManager.registerActor(Bomb.SPIKE_BOMB, Bomb.DANGER_BOMB, BombCollisionManager.BOMB_STAYING, stopMovementStayActor);
            collisionManager.registerActor(Bomb.SPIKE_BOMB, Bomb.POWER_BOMB, BombCollisionManager.BOMB_STAYING, stopMovementStayActor);
            collisionManager.registerActor(Bomb.SPIKE_BOMB, Bomb.SPIKE_BOMB, BombCollisionManager.BOMB_STAYING, stopMovementStayActor);
            collisionManager.registerActor(Bomb.SPIKE_BOMB, Bomb.BOUNCING_BOMB, BombCollisionManager.BOMB_STAYING, stopMovementStayActor);
            
            collisionManager.registerActor(Bomb.BOUNCING_BOMB, Bomb.NORMAL_BOMB, BombCollisionManager.BOMB_STAYING, bounceStayActor);
            collisionManager.registerActor(Bomb.BOUNCING_BOMB, Bomb.DANGER_BOMB, BombCollisionManager.BOMB_STAYING, bounceStayActor);
            collisionManager.registerActor(Bomb.BOUNCING_BOMB, Bomb.POWER_BOMB, BombCollisionManager.BOMB_STAYING, bounceStayActor);
            collisionManager.registerActor(Bomb.BOUNCING_BOMB, Bomb.SPIKE_BOMB, BombCollisionManager.BOMB_STAYING, bounceStayActor);
            collisionManager.registerActor(Bomb.BOUNCING_BOMB, Bomb.BOUNCING_BOMB, BombCollisionManager.BOMB_STAYING, bounceStayActor);
            
            collisionManager.registerActor(Bomb.NORMAL_BOMB, Bomb.NORMAL_BOMB, BombCollisionManager.BOMB_MOVING, fusionActor);
            collisionManager.registerActor(Bomb.NORMAL_BOMB, Bomb.DANGER_BOMB, BombCollisionManager.BOMB_MOVING, stopMovementStopMovementActor);
            collisionManager.registerActor(Bomb.NORMAL_BOMB, Bomb.POWER_BOMB, BombCollisionManager.BOMB_MOVING, fusionActor);
            collisionManager.registerActor(Bomb.NORMAL_BOMB, Bomb.SPIKE_BOMB, BombCollisionManager.BOMB_MOVING, fusionActor);
            collisionManager.registerActor(Bomb.NORMAL_BOMB, Bomb.BOUNCING_BOMB, BombCollisionManager.BOMB_MOVING, fusionActor);
            
            collisionManager.registerActor(Bomb.DANGER_BOMB, Bomb.NORMAL_BOMB, BombCollisionManager.BOMB_MOVING, stopMovementStopMovementActor);
            collisionManager.registerActor(Bomb.DANGER_BOMB, Bomb.DANGER_BOMB, BombCollisionManager.BOMB_MOVING, stopMovementStopMovementActor);
            collisionManager.registerActor(Bomb.DANGER_BOMB, Bomb.POWER_BOMB, BombCollisionManager.BOMB_MOVING, stopMovementStopMovementActor);
            collisionManager.registerActor(Bomb.DANGER_BOMB, Bomb.SPIKE_BOMB, BombCollisionManager.BOMB_MOVING, stopMovementStopMovementActor);
            collisionManager.registerActor(Bomb.DANGER_BOMB, Bomb.BOUNCING_BOMB, BombCollisionManager.BOMB_MOVING, stopMovingBounceActor);
            
            collisionManager.registerActor(Bomb.POWER_BOMB, Bomb.NORMAL_BOMB, BombCollisionManager.BOMB_MOVING, fusionActor);
            collisionManager.registerActor(Bomb.POWER_BOMB, Bomb.DANGER_BOMB, BombCollisionManager.BOMB_MOVING, stopMovementStopMovementActor);
            collisionManager.registerActor(Bomb.POWER_BOMB, Bomb.POWER_BOMB, BombCollisionManager.BOMB_MOVING, fusionActor);
            collisionManager.registerActor(Bomb.POWER_BOMB, Bomb.SPIKE_BOMB, BombCollisionManager.BOMB_MOVING, fusionActor);
            collisionManager.registerActor(Bomb.POWER_BOMB, Bomb.BOUNCING_BOMB, BombCollisionManager.BOMB_MOVING, fusionActor);
            
            collisionManager.registerActor(Bomb.SPIKE_BOMB, Bomb.NORMAL_BOMB, BombCollisionManager.BOMB_MOVING, fusionActor);
            collisionManager.registerActor(Bomb.SPIKE_BOMB, Bomb.DANGER_BOMB, BombCollisionManager.BOMB_MOVING, stopMovementStopMovementActor);
            collisionManager.registerActor(Bomb.SPIKE_BOMB, Bomb.POWER_BOMB, BombCollisionManager.BOMB_MOVING, fusionActor);
            collisionManager.registerActor(Bomb.SPIKE_BOMB, Bomb.SPIKE_BOMB, BombCollisionManager.BOMB_MOVING, fusionActor);
            collisionManager.registerActor(Bomb.SPIKE_BOMB, Bomb.BOUNCING_BOMB, BombCollisionManager.BOMB_MOVING, fusionActor);
            
            collisionManager.registerActor(Bomb.BOUNCING_BOMB, Bomb.NORMAL_BOMB, BombCollisionManager.BOMB_MOVING, fusionActor);
            collisionManager.registerActor(Bomb.BOUNCING_BOMB, Bomb.DANGER_BOMB, BombCollisionManager.BOMB_MOVING, bounceStopMovementActor);
            collisionManager.registerActor(Bomb.BOUNCING_BOMB, Bomb.POWER_BOMB, BombCollisionManager.BOMB_MOVING, fusionActor);
            collisionManager.registerActor(Bomb.BOUNCING_BOMB, Bomb.SPIKE_BOMB, BombCollisionManager.BOMB_MOVING, fusionActor);
            collisionManager.registerActor(Bomb.BOUNCING_BOMB, Bomb.BOUNCING_BOMB, BombCollisionManager.BOMB_MOVING, fusionActor);
            
            EventListenerManager.setListenerTo(GameData.instance.serverMessagesHandler, SFSEvent.EXTENSION_RESPONSE, onExtensionResponse);
        }
        
        public function applyCollisionActions(collisionerBomb:Bomb, collisionedBomb:Bomb):void
        {
            collisionManager.apply(collisionerBomb, collisionedBomb);
        }

        /*TODO: Check if this works ok as an extension response
        public function onGameMessage(e:MessageEvent):void{
            var bombId:uint = e.params.getLong('bombId');
        
            if (e.message == ACTIVATE_MINE) {
                if((readyBombs[bombId] as Bomb) != null){
                    (readyBombs[bombId] as Bomb).isActive = true;
                }
            } else if (e.message == BLOW_MINE) {
                if((readyBombs[bombId] as Bomb) != null){
                    var mine:Bomb = (readyBombs[bombId] as Bomb);
                    var persons:Array = GameData.instance.positionManager.typedObjectsInTile(mine.tilePoint, MoveObject.PERSON).concat(
                        GameData.instance.positionManager.typedObjectsInTile(mine.tilePoint, MoveObject.KICKER));
                    for each(var person:Person in persons)
                    {
                        person.fireMe(mine);
                    }
                    mine.blowMine();
                }
            }
        }
*/
        private function onExtensionResponse(e:SFSEvent):void 
        {
            var data:SFSObject = e.params["params"] as SFSObject;
            var bombId:uint;
            
            if(e.params["cmd"] == SET_BOMB)
            {
                if(!GameData.instance.endingState){
                    setBomb(data);
                }                
            } else if(e.params["cmd"] == EXPLODE_BOMB)
            {
                bombId = data.getLong('bombId');
                var sequenceNumber:int = data.getInt('seq');
                if(burstBombs[bombId] == null) {
                    var bombToBurn:Bomb = null;
                    if(readyBombs[bombId] == null){
                        bombToBurn = null;
                    } else {
                        bombToBurn = readyBombs[bombId] as Bomb;
                    }
                    if(!SmartFoxClientSingleton.getInstance().smartFoxClient.myself.isSpectatorInRoom(SmartFoxClientSingleton.getInstance().smartFoxClient.gameRoom))
                    {
                        if(bombToBurn == null || bombToBurn.fire)
                        {
                            var bombExplosion:SFSObject = new SFSObject();
                            bombExplosion.putLong("bid",bombId);
                            SmartFoxClientSingleton.getInstance().smartFoxClient.sendExtensionRequestToGameRoom(ServerMessages.BOMB_ALREADY_EXPLODED, bombExplosion);
                        }
                    }
                    if(bombToBurn == null || bombToBurn.sequence != sequenceNumber || bombToBurn.bombType == Bomb.MINE)
                    {
                        return;
                    }
                    burnBomb(bombId);
                    (bombToBurn).confirmExplosion(new Point(data.getInt('_x'),data.getInt('_y')));
                }
            }
            else if (e.params["cmd"] == ACTIVATE_MINE)
            {
                bombId = data.getLong('bombId');
                if((readyBombs[bombId] as Bomb) != null){
                    (readyBombs[bombId] as Bomb).isActive = true;
                }
            } 
            else if (e.params["cmd"] == BLOW_MINE) {
                bombId = data.getLong('bombId');
                if((readyBombs[bombId] as Bomb) != null){
                    var mine:Bomb = (readyBombs[bombId] as Bomb);
                    var persons:Array = GameData.instance.positionManager.typedObjectsInTile(mine.tilePoint, MoveObject.PERSON).concat(
                        GameData.instance.positionManager.typedObjectsInTile(mine.tilePoint, MoveObject.KICKER));
                    for each(var person:Person in persons)
                    {
                        if((mine.myMaster as Person).userId == SmartFoxClientSingleton.getInstance().smartFoxClient.myself.id && person.userId != SmartFoxClientSingleton.getInstance().smartFoxClient.myself.id)
                        {
                            StatsManager.instance.onPlayerKilledWithMine();
                        }
                        person.fireMe(mine);
                    }
                    mine.blowMine();
                }
            }
        }

        private function setBomb(input:SFSObject):void
        {
            // If bomb sequence number is > 0 it means it is a morphed bomb.
            if(input.getInt("seq") != 0)
            {
                return;
            }
            var bombToSet:String = input.getUtfString("_b");
            var myId:String = input.getUtfString("_m");
            var tempX:Number = input.getLong("_x");
            var tempY:Number = input.getLong("_y");
            var walkStr:String = input.getUtfString("_w");
            var master:Person = Person.getPersonById(int(myId));
            var area:uint = 1;
            if(input.containsKey("area")){
                area = input.getInt("area");
            }

            if(master == null)
            {
                return;
            }
            master.isPlacingBomb = false;
            
            if(GameData.instance.positionManager.bombsInTile(new Point(tempX, tempY)).length <= 0)
            {
                //TODO: check if this is still needed
                GameData.instance.mapArr[tempX][tempY] = 999;
                var bombName:String;
                if(GameData.instance.STAGE_MODE == StageModes.PENGUIN)
                {
                    bombName = "BombPenguin_";
                }
                else
                {
                    bombName = "Bomb_";
                }
                var bomb:Bomb = GameData.instance.creater.createObj( "person", "Bomb", bombName + bombToSet, (tempX + 0.5) * GameData.instance.rectWidth, (tempY + 0.5) * GameData.instance.rectHeight + GameData.instance.upLine, 0, []) as Bomb;;
                
                if(bombToSet == Bomb.MINE)
                {
                    bomb.isMine = true;
                    //mines will remain until someone activates them, so they shouldn't block the bombs dropping
                }
                else 
                {
                    master._bombsOnFieldArray.push(bomb);
                }
                
                bomb.bombId = input.getLong('bombId');
                bomb.tilePoint = new Point(tempX, tempY);
                
                if(GameData.DEBUG_MODE)
                {
                    var bombType:String = "bomb";
                    if(bomb.isMine) {
                        bombType = "mine";
                    }
                    
                    trace("[ReceiveHandler] setting " + bombType + " at <" + bomb.tilePoint.x + ", " + bomb.tilePoint.y + ">");
                }
                
                GameData.instance.positionManager.addObjectToMap(tempX, tempY, bomb);
                GameData.instance.bombManager.addBomb(bomb);
                
                bomb.myMaster = master;
                
                // TODO: is this code still valid?
                if( walkStr == "_f" )
                {
                    bomb.go(tempX, tempY, area);
                }
                else
                {
                    bomb.initial(area);
                }
            }
        }

        public function isBurst(id:uint):Boolean{
            
            return burstBombs[id]!=null;            
        }
        
        public function burnBomb(id:uint):void{
            burstBombs[id] = true;
        }
        
        public function addBomb(bomb:Bomb):void{
            readyBombs[bomb.bombId] = bomb;
        }

        public function dispose():void{
        //    SmartFoxClientSingleton.getInstance().smartFoxClient.removeEventListener(MessageEvent.GAME_MESSAGE,onGameMessage);
            SmartFoxClientSingleton.getInstance().smartFoxClient.removeExtensionResponseListener(onExtensionResponse);
            
        }

        public function confirmMovement(objectId:uint, movementId:uint):Bomb
        {
            if(readyBombs[objectId] != null && (readyBombs[objectId] as Bomb).currentMovementId == movementId)
            {
                return readyBombs[objectId] as Bomb;
            }
            else
            {
                return null;
            }
        }
    }
}