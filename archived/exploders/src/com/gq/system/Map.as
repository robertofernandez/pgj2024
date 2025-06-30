package com.gq.system
{
    import com.gq.moveobject.DeadlyBlock;
    import com.gq.moveobject.MoveObject;
    import com.gq.moveobject.Objects;
    import com.gq.moveobject.Person;
    import com.gq.moveobject.Treasure;
    import com.gq.ui.*;
    import com.smartfoxserver.v2.entities.User;
    import com.smartfoxserver.v2.entities.data.ISFSArray;
    import com.smartfoxserver.v2.entities.data.SFSArray;
    import com.smartfoxserver.v2.entities.data.SFSObject;
    import com.willdom.games.bomberman.communication.GameMessage;
    import com.willdom.games.bomberman.communication.GameUtilityTool;
    import com.willdom.games.bomberman.communication.SmartFoxClientSingleton;
    import com.willdom.games.bomberman.gameobjects.items.AsymmetricalItemAmmountDescription;
    import com.willdom.games.bomberman.gameobjects.items.BowlingItemAmmountDescription;
    import com.willdom.games.bomberman.gameobjects.items.DefaultItemAmountDescription;
    import com.willdom.games.bomberman.gameobjects.items.EmptyItemAmountDescription;
    import com.willdom.games.bomberman.gameobjects.items.HyperFeetItemAmmountDescription;
    import com.willdom.games.bomberman.gameobjects.items.ItemAmountDescription;
    import com.willdom.games.bomberman.gameobjects.items.ItemGrabItemAmmountDescription;
    import com.willdom.games.bomberman.gameobjects.items.ItemTypes;
    import com.willdom.games.bomberman.gameobjects.items.PassageItemAmmountDescription;
    import com.willdom.games.bomberman.gameobjects.items.PotHolesItemAmmountDescription;
    import com.willdom.games.bomberman.gameobjects.items.PowerItemAmmountDescription;
    import com.willdom.games.bomberman.gameobjects.items.VolcanoItemAmmountDescription;
    import com.willdom.games.bomberman.gameobjects.items.ZombiesItemAmmountDescription;
    import com.willdom.games.bomberman.position.maps.CellTypes;
    import com.willdom.games.bomberman.position.maps.ClassicMapDescriptionMC;
    import com.willdom.games.bomberman.position.maps.DescriptionBasedMapGenerator;
    import com.willdom.games.bomberman.position.maps.ItemGrabMapDescription;
    import com.willdom.games.bomberman.position.maps.MapDescription;
    import com.willdom.games.bomberman.position.maps.MapGenerator;
    import com.willdom.games.bomberman.position.maps.MovieClipBasedMapDescription;
    import com.willdom.games.bomberman.position.maps.MovieClipBasedMapDescriptionWithRuledRandomPoints;
    import com.willdom.games.bomberman.position.maps.OpenFieldMapDescriptionMC;
    import com.willdom.games.bomberman.position.maps.PointsBlock;
    import com.willdom.games.bomberman.position.maps.PowerFreaksMapDescriptionMC;
    import com.willdom.games.bomberman.position.maps.ZombiesMapDescriptionMC;
    import com.willdom.games.bomberman.user.UserLocalProperties;
    import com.willdom.util.math.ArrayRandomizer;
    import com.willdom.util.math.Random;
    import com.willdom.util.sfs.structures.ArrayConversion;
    
    import configuration.GameModes;
    import configuration.StageModes;
    
    import flash.display.MovieClip;
    import flash.display.Sprite;
    import flash.display.StageScaleMode;
    import flash.events.MouseEvent;
    import flash.filters.GlowFilter;
    import flash.geom.Point;
     
    public class Map extends Pages
    {
        
        private var drawMc:Sprite;
        public var clickTarget:*;
        private var burnPositionArr_NORMAL:Array;
        private var burnPositionArr_FLAG:Array;
        public var burnPositionArr_itemgrab:Array;
        public var randomArr:Array;
        private var bowlingArr:Array;

        private var treasureArr:Array;

        private var mapDescription:MapDescription;
        private var descriptionsMap:Object;
        private var mapGenerator:MapGenerator;
        private var itemAmountDescription:ItemAmountDescription;

        public var deadlyBlocks:Array;

        private var s:int;

        public function Map(seed:int, mapDescription:MapDescription):void
        {
            super(new MapMc());
            page.y=GameData.instance.upLine;
            dummyCode();
            this.mapDescription = mapDescription;
            mapGenerator = new DescriptionBasedMapGenerator(mapDescription);

            if(GameData.instance.STAGE_MODE == StageModes.HYPER)
            {
                itemAmountDescription = new HyperFeetItemAmmountDescription();
            } 
            else if(GameData.instance.STAGE_MODE == StageModes.GRAB)
            {
                itemAmountDescription = new ItemGrabItemAmmountDescription();
            }
            else if(GameData.instance.STAGE_MODE == StageModes.PASSAGE)
            {
                itemAmountDescription = new PassageItemAmmountDescription();
            }
            else if(GameData.instance.STAGE_MODE == StageModes.ASYMMETRICAL)
            {
                itemAmountDescription = new AsymmetricalItemAmmountDescription;
            }
            else if(GameData.instance.STAGE_MODE == StageModes.ZOMBIES)
            {
                itemAmountDescription = new ZombiesItemAmmountDescription();
            }
            else if(GameData.instance.STAGE_MODE == StageModes.POWER)
            {
                itemAmountDescription = new PowerItemAmmountDescription();
            }
            else if(GameData.instance.STAGE_MODE == StageModes.HOLE)
            {
                itemAmountDescription = new PotHolesItemAmmountDescription();
            }
            else if(GameData.instance.STAGE_MODE == StageModes.VOLCANOES)
            {
                itemAmountDescription = new VolcanoItemAmmountDescription();
            }
            else if(GameData.instance.STAGE_MODE == StageModes.BOWLING)
            {
                itemAmountDescription = new BowlingItemAmmountDescription();
            }
            else
            {
                itemAmountDescription = new DefaultItemAmountDescription();
            }
            
            if(!GameData.instance.skulls){
                itemAmountDescription.setValue(ItemTypes.SKULL,0);
            }

            GameData.instance.map = this;
            GameTools.pushArr(GameData.instance.actionArr, this);

            getData();

            addMapObj(seed, GameData.instance.STAGE_MODE);
        }
        
        private function dummyCode():void
        {
            var treasure_1:Treasure_1;
            var treasure_2:Treasure_2;
            var treasure_3:Treasure_3;
            var treasure_4:Treasure_4;
            var treasure_5:Treasure_5;
            var treasure_6:Treasure_6;
            var treasure_7:Treasure_7;
            var treasure_8:Treasure_8;
            var treasure_9:Treasure_9;
            var treasure_10:Treasure_10;
            var treasure_11:Treasure_11;
            var treasure_12:Treasure_12;
            var treasure_13:Treasure_13;
            var treasure_14:Treasure_14;
            var treasure_15:Treasure_15;
            var treasure_18:Treasure_18;
            var treasure_19:Treasure_19;
            
            var person_1:Person_1;
            var person_2:Person_2;
            var person_3:Person_3;
            var person_4:Person_4;
            var person_5:Person_5;
            var person_6:Person_6;
            var person_7:Person_7;
            var person_8:Person_8;
            var person_9:Person_9;
            var person_10:Person_10;
            var person_11:Person_11;
            var person_12:Person_12;
            var person_13:Person_13;
            var person_14:Person_14;
            var person_15:Person_15;
            var person_16:Person_16;
            var person_17:Person_17;
            var person_18:Person_18;
            var person_19:Person_19;
            var person_20:Person_20;
            var person_21:Person_21;
            var person_22:Person_22;
            var person_26:Person_26;
            var person_27:Person_27;
            var person_28:Person_28;
            var person_751:Person_751;
            var person_752:Person_752;
            var person_501:Person_501;
            var person_502:Person_502;
            var person_503:Person_503;
            var person_700:Person_700;
            var person_701:Person_701;
            var person_702:Person_702;
            var person_703:Person_703;
            var person_704:Person_704;
            var person_706:Person_706;
            var person_707:Person_707;
            var person_708:Person_708;
            var person_709:Person_709;
            var person_710:Person_710;
            var person_711:Person_711;
            
            var vEffect_0:Effect_0;
            var vEffect_1:Effect_1;
            var vEffect_2:Effect_2;
            var vEffect_3:Effect_3;
            var vEffect_4:Effect_4;
            var vEffect_5:Effect_5;
            var vEffect_6:Effect_6;
            var vEffect_10:Effect_10;
            var vEffect_11:Effect_11;
            var vEffect_12:Effect_12;
            var vEffectBasic_1:EffectBasic_1;
            var vEffectBasic_2:EffectBasic_2;
            var vEffectBasic_3:EffectBasic_3;
            var vEffectBasic_4:EffectBasic_4;
            var vEffectBasic_5:EffectBasic_5;
            var vEffectBasic_6:EffectBasic_6;
            var vEffectBasic_7:EffectBasic_7;
            var vEffectBasic_8:EffectBasic_8;
            var vEffectBasic_9:EffectBasic_9;
            var vEffectBasic_10:EffectBasic_10;
            var vEffectBasic_11:EffectBasic_11;
            var vEffectBasic_12:EffectBasic_12;
            var vEffectBasic_13:EffectBasic_13;
            var vEffectBasic_14:EffectBasic_14;
            var vEffectBasic_15:EffectBasic_15;
            var vEffectBasic_16:EffectBasic_16;
            
            var vBoxclassic_1:Boxclassic_1;
            var vBoxclassic_2:Boxclassic_2;
            var vBoxitemgrab_1:Boxitemgrab_1;
            var vBoxitemgrab_2:Boxitemgrab_2;
            var vBoxhole_1:Boxhole_1;
            var vBoxhole_2:Boxhole_2;
            var vBoxhyper_1:Boxhyper_1;
            var vBoxhyper_2:Boxhyper_2;
            var vBoxopen_1:Boxopen_1;
            var vBoxopen_2:Boxopen_2;
            var vBoxpower_1:Boxpower_1;
            var vBoxpower_2:Boxpower_2;
            var vBoxpassage_1:Boxpassage_1;
            var vBoxpassage_2:Boxpassage_2;
            var vBoxasymmetrical_1:Boxasymmetrical_1;
            var vBoxasymmetrical_2:Boxasymmetrical_2;
            var vBoxvolcanoes_1:Boxvolcanoes_1;
            var vBoxvolcanoes_2:Boxvolcanoes_2;
            var vBoxZombies_1:Boxzombies_1;
            var vBoxZombies_2:Boxzombies_2;
            var vBoxPower_1:Boxpower_1;
            var vBoxPower_2:Boxpower_2;
            var vBoxBowling_1:Boxbowling_1;
            var vBoxBowling_2:Boxbowling_2;
            var vDeadlyBlock:DeadlyBlock_1;
            
            var bomb_1:Bomb_1;
            var bomb_2:Bomb_2;
            var bomb_3:Bomb_3;
            var bomb_4:Bomb_4;
            var bomb_5:Bomb_5;
            var bomb_6:Bomb_6;

            var set:setBomb;
            var explore1:explore_1;
            var explore2:explore_2;
            var snd_eat:eat;
            var snd_item_down:item_down;
            var snd_press:press;
            var snd_background:bg1;
            var snd_roundresults:roundresults;
            var snd_gameresults:gameresults;
            var snd_stinger_lose:stinger_lose;
            var snd_stinger_ready:stinger_ready;
            var snd_stinger_go:stinger_go;
            var snd_stinger_win:stinger_win;
            var snd_clocktick:sfx_clocktick;
            var snd_countdown:sfx_countdown;
            var snd_hurryup:sfx_hurryup;
            var snd_killother:sfx_killother;
            var snd_killself:sfx_killself;
            var snd_killsomeone_1:sfx_killsomeone_1;
            var snd_killsomeone_2:sfx_killsomeone_2;
            var snd_killsomeone_3:sfx_killsomeone_3;
            var snd_killsomeone_4:sfx_killsomeone_4;
            var snd_killsomeone_5:sfx_killsomeone_5;
            var snd_roundover:sfx_roundover;
            var snd_music_speed:bgspeed;
            var snd_dead:dead;
            var snd_kick:kick;
        }

        private function drawRect():void
        {
            for (var i:uint = 0; i < GameData.instance.widthNum; i++)
            {
                for (var j:uint = 0; j < GameData.instance.heightNum; j++)
                {
                    drawMc.graphics.lineStyle(1);
                    drawMc.graphics.drawRect( i * GameData.instance.rectWidth, j * GameData.instance.rectHeight, GameData.instance.rectWidth, GameData.instance.rectHeight );
                }
            }
        }
        public function showRect():void
        {
            var temp:Boolean = ! drawMc.visible;
            drawMc.visible = temp;
            for (var i:String in GameData.instance.objectArr)
            {
                GameData.instance.objectArr[i].testMc.visible = temp;
            }
        }
        //
        public function getData( which:String = "" ):void
        {
            drawMc = new Sprite();
            addChild( drawMc );
            drawMc.y = GameData.instance.upLine;
            GameData.instance.rectWidth = GameData.instance.rectHeight = 550 / GameData.instance.heightNum;
            if(GameData.DEBUG_MODE)
            {
                trace( "A small grid of small lattice width: ", GameData.instance.rectWidth);
                trace( "Small grid of high: ", GameData.instance.rectHeight);
            }
        }

        protected function addMapObj(seed:int, stageMode:String):void
        {
            s = seed;

            mapGenerator.generateMap();
            GameData.instance.immediateOpenBoxes = mapGenerator.immediateOpenBoxes;
            createItems(mapGenerator.boxes, mapGenerator.alwaysItemBoxes, seed, itemAmountDescription);
            GameData.instance.positionManager.setInitialMap();
            
            for each(var box:Objects in mapGenerator.immediateOpenBoxes)
            {
                box.openBox();
            }
        }
        
        private function createItems(boxes:Array, alwaysItemsBoxes:Array, seed:Number, itemAmountDescription:ItemAmountDescription):void{
            var randomizer:Random = new Random(seed);
            
            for(var roundNumber:int=1; roundNumber <= GameData.instance.round; roundNumber++)
            {
                var arrayRandomizer:ArrayRandomizer=new ArrayRandomizer();
                var orderedBoxes:Array = arrayRandomizer.getNewOrderFor(boxes, int(randomizer.getRandom()*10000));
                var orderedAlwaysItemBoxes:Array = arrayRandomizer.getNewOrderFor(alwaysItemsBoxes, int(randomizer.getRandom()*10000));
                var orderedItems:Array = arrayRandomizer.getNewOrderFor(itemAmountDescription.itemsList, int(randomizer.getRandom()*10000));
                for(var i:uint = 0; i < orderedItems.length; i++ )
                {
                    var currentBox:Objects;
                    if(i < orderedAlwaysItemBoxes.length)
                    {
                        currentBox = orderedAlwaysItemBoxes[i] as Objects;
                    }
                    else
                    {
                        currentBox = orderedBoxes[i - orderedAlwaysItemBoxes.length] as Objects;
                    }
                    
                    currentBox.setItemForRound(roundNumber, orderedItems[i]);
                    
                    if(orderedItems[i] == ItemTypes.SKULL && GameData.instance.skulls)
                    {
                        //(orderedBoxes[i] as Objects).setSkullForRound(roundNumber, randomizer.getRandom());
                        currentBox.setSkullForRound(roundNumber, randomizer.getRandom());
                    }
                    else
                    {
                        //(orderedBoxes[i] as Objects).setSkullForRound(roundNumber, 0);
                        currentBox.setSkullForRound(roundNumber, 0);
                    }
                }
            }
        }

        private function createBowling():void
        {
            var n:uint;
            for( n = 0; n < bowlingArr.length; n ++ )
            {
                GameData.instance.creater.createObj( "bottomObject","Mark",  "Mark_2",
                                          (bowlingArr[n][0] + 0.5) * GameData.instance.rectWidth,
                                          (bowlingArr[n][1] + 0.5) * GameData.instance.rectHeight + GameData.instance.upLine, 0, [] )._this.gotoAndStop( bowlingArr[n][2] );
            }
        }

        override protected function init():void
        {
            for (var i:uint = 0; i < GameData.instance.mapArr.length; i ++)
            {
                GameData.instance.mapArr[i] = new Array(GameData.instance.heightNum);
                for (var k:uint = 0; k < GameData.instance.mapArr[i].length; k++)
                {
                    GameData.instance.mapArr[i][k] = 0;                    
                }
            }
        }
        
        /**
        * The first time this function is called it creates a DeadlyBlock for every tile in the map. Those blocks
         * are stored in an external array so they can be reused whenever the function is called again.
        */
        
        public function initDeadlyBlocks():void
        {
            var storedBlocks:Array = GameUtilityTool.getStoredContent();
            deadlyBlocks = new Array();
            for (var i:uint = 0; i < GameData.instance.mapArr.length; i++)
            {                
                deadlyBlocks[i] = new Array(GameData.instance.heightNum);
                for (var k:uint = 0; k < deadlyBlocks[i].length; k++)
                {
                    if (!GameData.instance.positionManager.hardBlocksInTile(new Point(i,k))){
                    
                        if (storedBlocks[0] != null)
                        {
                            DeadlyBlock.createDeadlyBlock(i,k, (storedBlocks.shift() as MovieClip));                    
                        }
                        else
                        {
                            DeadlyBlock.createDeadlyBlock(i,k);
                            GameUtilityTool.addSharedContent((DeadlyBlock.getBlockSpot(i,k) as DeadlyBlock)._this);
                            deadlyBlocks[i][k] = DeadlyBlock.getBlockSpot(i,k)
                        }
                    }
                }
            }    
        }

        //==============================================================================
        public function updataEvent():void
        {
        }
        
        public function hideMap():void
        {
            
            page.visible = false;
        }
        
        public function showMap():void
        {
            page.visible = true;
        }
    }
}