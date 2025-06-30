package com.gq.system
{
    import com.gq.moveobject.Person;
    import com.smartfoxserver.v2.entities.data.SFSObject;
    import com.willdom.games.bomberman.communication.SmartFoxClientSingleton;
    import com.willdom.games.bomberman.consts.ServerMessages;
    import com.willdom.games.bomberman.consts.SkullTypes;
    import com.willdom.games.bomberman.gameobjects.GameInterfaceManager;
    import com.willdom.util.helpers.EventListenerManager;
    import com.willdom.util.math.ArrayRandomizer;
    import com.willdom.util.math.Random;
    
    import flash.display.DisplayObjectContainer;
    import flash.events.Event;
    import flash.filters.GlowFilter;
    import flash.geom.Point;
    import flash.utils.getTimer;
        
    public class DiseaseManager
    {
        
        private var allDiseases:Array;
        private var allContagious:Array;
        public var allInfected:Array;
        private var timerTicks:Object;
        
        public static const moss:Object = {red:-100,green:20,blue:-50,filter:0xFF0000};
        public static const viridian:Object = {red:-100,green:50,blue:-70,filter:0xFF0000};
        public static const green:Object = {red:70,green:110,blue:50,filter:0xFF0000};
        public static const white:Object = {red:100,green:100,blue:100,filter:0xFF0000};
        public static const black:Object = {red:-70,green:-70,blue:-70,filter:0xFF0000};
        public static const cerulean:Object = {red:50,green:70,blue:120,filter:0xFF0000};
        public static const ochre:Object = {red:90,green:50,blue:30,filter:0xFF0000};
        public static const blue:Object = {red:-40,green:-100,blue:0,filter:0xFF0000};
        public static const bordeaux:Object = {red:20,green:-70,blue:-70,filter:0xFF0000};
        public static const ignite:Object = {red:120,green:20,blue:-100,filter:0xFF0000};
        public static const violet:Object = {red:-40,green:-200,blue:0,filter:0xFF0000};
        public static const yellow:Object = {red:70,green:70,blue:-70,filter:0xFF0000};
        public static const purple:Object = {red:-40,green:-120,blue:40,filter:0xFF0000};
        
        public static const TIME_FOR_ACTIVATION:int = 0;
        
        public static const DURATION_CONSTIPATION:int = 20;
        public static const DURATION_DIARRHEA:int = 0;
        public static const DURATION_SHORT_FUSE:int = 15;
        public static const DURATION_LONG_FUSE:int = 15;
        public static const DURATION_DIZZY:int = 5;
        public static const DURATION_CONFUSION:int = 10;
        public static const DURATION_QUICK:int = 10;
        public static const DURATION_SLOW:int = 10;
        public static const DURATION_RECKLESS:int = 30;
        public static const DURATION_LOW_POWER:int = 15;
        public static const DURATION_POSITION_SWITCH:int = 0;
        public static const DURATION_EPIC_FIRE:int = 30;
        
        public static const CONTAGIOUS_CONSTIPATION:Boolean = true;
        public static const CONTAGIOUS_DIARRHEA:Boolean = false;
        public static const CONTAGIOUS_SHORT_FUSE:Boolean = true;
        public static const CONTAGIOUS_LONG_FUSE:Boolean = true;
        public static const CONTAGIOUS_DIZZY:Boolean = true;
        public static const CONTAGIOUS_CONFUSION:Boolean = true;
        public static const CONTAGIOUS_QUICK:Boolean = true;
        public static const CONTAGIOUS_SLOW:Boolean = true;
        public static const CONTAGIOUS_RECKLESS:Boolean = true;
        public static const CONTAGIOUS_LOW_POWER:Boolean = true;
        public static const CONTAGIOUS_POSITION_SWITCH:Boolean = false;
        public static const CONTAGIOUS_EPIC_FIRE:Boolean = true;
        
        public function DiseaseManager()
        {
            allDiseases = new Array();    
            allContagious = new Array();
            allInfected = new Array();
            timerTicks = {};
        }
        
        public function startTingling():void{
            EventListenerManager.setListenerTo(GameData.instance.topObjectContainer, Event.ENTER_FRAME, colorTingling);
        }
        
        public function spread(xSpot:int, ySpot:int):void
        {
            
            var healthyOne:Boolean = false;
            var infectedOne:Boolean = false;
            var diseasesFound:Array = new Array();
            var personsFound:Array = new Array();
            var objectsInTile:Array = GameData.instance.positionManager.getObjectsInTile(new Point(xSpot, ySpot));
            var i:uint = 0;
            
            for (i = 0; i < objectsInTile.length; i++){
                
                if (objectsInTile[i] is Person){
                    
                    personsFound.push(objectsInTile[i]);
                    
                }
                
            }
            
            if (personsFound.length > 1){
                
                for each (var thisDisease:Disease in allContagious){
                    
                    
                    for each (var thisPerson:Person in personsFound){
                        
                        if (thisDisease.isInfected(thisPerson)){
                            
                            diseasesFound.push(thisDisease);
                            infectedOne = true;
                            
                        } else {
                            
                            healthyOne = true;
                            
                        }
                        
                    }
                    
                }
                
                var iAmHealed:Boolean = false;
                var infectedBy:Disease = null;
                var diseaseSpreader:Person;
                
                if (infectedOne && healthyOne){
                    
                    
                    var healPeople:Array = [];
                    var infectPeople:Array = [];
                    
                    for (i = 0; i < diseasesFound.length; i++)
                    {

                        healPeople[i] = [];
                        infectPeople[i] = [];
                        for each (var person:Person in personsFound)
                        {
                            if (diseasesFound[i].isInfected(person))
                            {
                                healPeople[i].push(person); 
                            }
                            else
                            {
                                infectPeople[i].push(person);
                            }
                        }
                    
                    }
                    
                    for (i = 0; i < diseasesFound.length; i++)
                    {
                        for each (person in healPeople[i])
                        {
                            (diseasesFound[i] as Disease).healPerson(person);
                            if (person.myName == GameData.instance.myName && !SmartFoxClientSingleton.getInstance().smartFoxClient.myself.isSpectatorInRoom(SmartFoxClientSingleton.getInstance().smartFoxClient.gameRoom)){
                                iAmHealed = true;
                                
                                GameInterfaceManager.getInstance().hideDiseaseMessage();
                            }
                        }
                    }
                    for (i = 0; i < diseasesFound.length; i++)
                    {
                        for each (person in infectPeople[i])
                        {
                            (diseasesFound[i] as Disease).infectPerson(person);
                            if (person.myName == GameData.instance.myName && !SmartFoxClientSingleton.getInstance().smartFoxClient.myself.isSpectatorInRoom(SmartFoxClientSingleton.getInstance().smartFoxClient.gameRoom)){
                                infectedBy = diseasesFound[i];
                            }
                        }
                    }
                    
                    if (iAmHealed && infectedBy == null && !Person.getPersonByName(GameData.instance.myName).fire)
                    {
                        GameInterfaceManager.getInstance().hideDiseaseMessage();
                    } 
                    else if (infectedBy != null)
                    {
                        GameInterfaceManager.getInstance().showDiseaseMessage(GameData.instance.myAvatar, infectedBy.type, infectedBy.prevDiseaseTimer);
                    }
                }
            }
        }
        
        public function createDisease(target:Person, skullType:String):void
        {
            var personDiseases:Array = getDiseasesByPerson(target);
            var type:String = skullType;
            var duration:int;
            var thisDisease:Disease;
            
            if(personDiseases.length>0){
                thisDisease = personDiseases[0];
                type = thisDisease.type;        
            }
            
            switch (type)
            {
                case SkullTypes.CONFUSION:
                    duration = DURATION_CONFUSION;
                    break;
                case SkullTypes.CONSTIPATION:
                    duration = DURATION_CONSTIPATION;
                    break;
                case SkullTypes.DIZZY:
                    duration = DURATION_DIZZY;
                    break;
                case SkullTypes.LOW_POWER:
                    duration = DURATION_LOW_POWER;
                    break;
                case SkullTypes.QUICK:
                    duration = DURATION_QUICK;
                    break;
                case SkullTypes.RECKLESS:
                    duration = DURATION_RECKLESS;
                    break;
                case SkullTypes.SLOW:
                    duration = DURATION_SLOW;
                    break;
                case SkullTypes.SHORT_FUSE:
                    duration = DURATION_SHORT_FUSE;
                    break;
                case SkullTypes.LONG_FUSE:
                    duration = DURATION_LONG_FUSE;
                    break;
                case SkullTypes.POSITION_SWITCH:
                    duration = DURATION_POSITION_SWITCH;
                    break;
                case SkullTypes.EPIC_FIRE:
                    duration = DURATION_EPIC_FIRE;
                    break;
                case SkullTypes.DIARRHOEA:
                    duration = DURATION_DIARRHEA;
                    break;
            }
            
            var contagious:Boolean;
            switch (type)
            {
                case SkullTypes.CONFUSION:
                    contagious = CONTAGIOUS_CONFUSION;
                    break;
                case SkullTypes.CONSTIPATION:
                    contagious = CONTAGIOUS_CONSTIPATION;
                    break;
                case SkullTypes.DIZZY:
                    contagious = CONTAGIOUS_DIZZY;
                    break;
                case SkullTypes.LOW_POWER:
                    contagious = CONTAGIOUS_LOW_POWER;
                    break;
                case SkullTypes.QUICK:
                    contagious = CONTAGIOUS_QUICK;
                    break;
                case SkullTypes.RECKLESS:
                    contagious = CONTAGIOUS_RECKLESS;
                    break;
                case SkullTypes.SLOW:
                    contagious = CONTAGIOUS_SLOW;
                    break;            
                case SkullTypes.SHORT_FUSE:
                    contagious = CONTAGIOUS_SHORT_FUSE;
                    break;
                case SkullTypes.LONG_FUSE:
                    contagious = CONTAGIOUS_LONG_FUSE;
                    break;
                case SkullTypes.POSITION_SWITCH:
                    contagious = CONTAGIOUS_POSITION_SWITCH;
                    break;
                case SkullTypes.EPIC_FIRE:
                    contagious = CONTAGIOUS_EPIC_FIRE;
                    break;    
                case SkullTypes.DIARRHOEA:
                    contagious = CONTAGIOUS_DIARRHEA;
                    break;
            }
            var skullMessage:SFSObject;        
            
            if(personDiseases.length == 0){
                
                if(type == SkullTypes.POSITION_SWITCH){
                    
                    /*if (target.myName == GameData.instance.myName)
                    {
                    }*/
                    GameInterfaceManager.getInstance().showDiseaseMessage(target.myAvatar, type, 2, 1);
                    target.getSkull(type);       
                }else{
                    
                    thisDisease = new Disease(contagious, duration);
                    if (timerTicks[String(thisDisease.id)] != null && timerTicks[String(thisDisease.id)] > 0)
                    {
                        thisDisease.prevDiseaseTimer = thisDisease.maxDiseaseTimer + TIME_FOR_ACTIVATION - timerTicks[String(thisDisease.id)];
                        timerTicks[String(thisDisease.id)] = null;
                    } 
                    else 
                    {
                        thisDisease.prevDiseaseTimer = thisDisease.maxDiseaseTimer + TIME_FOR_ACTIVATION;
                    }
                    thisDisease.type = type;
                    allDiseases.push(thisDisease);            
                    
                    if (thisDisease.isContagious){
                        
                        allContagious.push(thisDisease);
                        
                    }
                    
                    thisDisease.personToInfect = target;
                    thisDisease.infectPerson(thisDisease.personToInfect);    
                    
                    var diseaseType:String = SkullTypes.getDiseaseText(thisDisease.type);
                    
                    if(thisDisease.personToInfect.myName == SmartFoxClientSingleton.getInstance().smartFoxClient.myself.name){
                        //GameSys.showSubmessage(StringHelper.replaceTag("_skullYourSubmessage","%effect%",diseaseType), thisDisease.personToInfect.myAvatar,null,false,thisDisease.type);
                        //GameInterfaceManager.getInstance().showSubmessage(LanguageManager.getInstance().getAndReplaceText("_skullYourSubmessage","%effect%",diseaseType), thisDisease.personToInfect.myAvatar,null,false,thisDisease.type);
                    }else{
                        if(thisDisease.type == SkullTypes.EPIC_FIRE){
                            //GameSys.showSubmessage(StringHelper.replaceTag("_skullSubmessageEpicFire","%player%",thisDisease.personToInfect.myName), thisDisease.personToInfect.myAvatar,null,false,thisDisease.type);
                            GameInterfaceManager.getInstance().showSubmessage(LanguageManager.getInstance().getAndReplaceText("_skullSubmessageEpicFire","%player%",thisDisease.personToInfect.myName), thisDisease.personToInfect.myAvatar,null,false,thisDisease.type);
                        }else{
                            //GameSys.showSubmessage(StringHelper.replaceTags("_skullSubmessage",["%player%","%effect%"],[thisDisease.personToInfect.myName,diseaseType]), thisDisease.personToInfect.myAvatar,null,false,thisDisease.type);
                            GameInterfaceManager.getInstance().showSubmessage(LanguageManager.getInstance().getAndReplaceTexts("_skullSubmessage",["%player%","%effect%"],[thisDisease.personToInfect.myName,diseaseType]), thisDisease.personToInfect.myAvatar,null,false,thisDisease.type);
                        }
                    }
                    thisDisease.setTimerTick(thisDisease.duration);    
                    
                    thisDisease.personToInfect = null;
                                        
                    
                    if (target == Person.getPersonByName(GameData.instance.myName))
                    {
                        
                        if(thisDisease.duration + TIME_FOR_ACTIVATION > 0)
                        {
                            skullMessage = new SFSObject();
                            skullMessage.putInt(ServerMessages.DISEASE_ID, thisDisease.id);
                            skullMessage.putInt(ServerMessages.DISEASE_TIMER, thisDisease.duration + TIME_FOR_ACTIVATION);
                            SmartFoxClientSingleton.getInstance().smartFoxClient.sendExtensionRequestToGameRoom(ServerMessages.DISEASE_GENERATION, skullMessage);
                            var selectedFace:uint = SkullTypes.DISEASES_ARRAY.indexOf(thisDisease.type);
                            selectedFace++;
                        } 
                        
                        if(thisDisease.type == SkullTypes.DIARRHOEA)
                        {
                            GameInterfaceManager.getInstance().showDiseaseMessage(GameData.instance.myAvatar, thisDisease.type, 2, 2);
                        }
                        else
                        {
                            GameInterfaceManager.getInstance().showDiseaseMessage(GameData.instance.myAvatar, thisDisease.type, thisDisease.duration, 2);
                        }
                    }
                    
                }
                
            }else{
                thisDisease.overrideEndOfDisease = true;    
                
                if(thisDisease.personToInfect == null && target == Person.getPersonByName(GameData.instance.myName)){
                    if(thisDisease.duration/2 > 0 ){
                        skullMessage = new SFSObject();
                        skullMessage.putInt(ServerMessages.DISEASE_ID, thisDisease.id);
                        skullMessage.putInt(ServerMessages.DISEASE_TIMER, thisDisease.duration/2 );    
                        
                        GameInterfaceManager.getInstance().updateDiseaseTime(thisDisease.tick + thisDisease.duration/2);
                        
                        SmartFoxClientSingleton.getInstance().smartFoxClient.sendExtensionRequestToGameRoom(ServerMessages.DISEASE_MODIFICATION, skullMessage);
                    }
                }
            }
        }
        

        
        private function getRandomReels(finalType:String):Array{
            
            var finalTypeIndex:int = SkullTypes.DISEASES_ARRAY.indexOf(finalType);
            var reels:Array = new Array();
            var random:Random = new Random(getTimer());
            var randomDisease:int;
            var randomDiseaseIndex:int;
            var differentRandomTypes:int = 0;
            var i:uint = 0;
            
            var randomCase:int = random.getRandomBounded(0,100);
            
            reels.push(finalTypeIndex);
            reels.push(finalTypeIndex);
            
            var possibleDiseases:Array = SkullTypes.DISEASES_ARRAY.concat();
            possibleDiseases.splice( finalTypeIndex ,1);
            
            if(randomCase < 60){
                //1st case: 2 final type, 3 slots from different random type.
                
                differentRandomTypes = 3;                
                
            }else if(randomCase < 85){
                //2nd case: 3 final type, 2 slots from another type
                
                reels.push(finalTypeIndex);
                
                randomDisease = random.getRandomBounded(0,possibleDiseases.length-1);
                randomDiseaseIndex = SkullTypes.DISEASES_ARRAY.indexOf(possibleDiseases[randomDisease]);
                reels.push(randomDiseaseIndex);
                reels.push(randomDiseaseIndex);
                
            }else{
                //3rd case: 3 final type, 2 slots from different random type
                
                reels.push(finalTypeIndex);
                differentRandomTypes = 2;
            }
            
            for(i = 0;i<differentRandomTypes;i++){
                randomDisease = random.getRandomBounded(0,possibleDiseases.length-1);
                randomDiseaseIndex = SkullTypes.DISEASES_ARRAY.indexOf(possibleDiseases[randomDisease]);
                reels.push(randomDiseaseIndex);
                possibleDiseases.splice(randomDisease,1);
            }
            var arrayRandomizer:ArrayRandomizer = new ArrayRandomizer();
            reels = arrayRandomizer.getNewOrderFor(reels,random.seed);
            
            
            //In case final type is not stored in last reel position
            if(reels[reels.length-1] != finalTypeIndex){

                var swapped:Boolean = false;
                randomCase = random.getRandomBounded(0,100);
                
                //Store it in last position
                if(randomCase < 70){
                    var modifier:int;
                    //Half chance to start from the first element
                    if(randomCase < 35){
                        i=0;
                        modifier = 1;
                    }else{
                        //Half chance to start from the last element
                        i=reels.length-2;
                        modifier = -1;
                    }
                    while(!swapped){
                        if(reels[i]==finalTypeIndex){
                            reels[i] = reels[reels.length-1];
                            reels[reels.length-1] = finalTypeIndex;
                            swapped = true;
                        }
                        i += modifier;
                    }
                }
                
            }
            
            return reels;
        }
        
        public function removeDisease(disease:Disease, final:Boolean = true):void
        {
            if (disease != null){
                
                disease.removeDisconnectedPersons();
                disease.healAllPersons(final);
                allDiseases.splice(allDiseases.indexOf(disease),1);
                if (disease.isContagious){
                    allContagious.splice(allContagious.indexOf(disease),1)
                }
            }
        }
        
        public function removeAllDiseases():void{
            
            for each (var thisDisease:Disease in allDiseases){
                
                removeDisease(thisDisease, false);
                
            }
            
        }
        
        
        public function getDiseaseById(diseaseId:int):Disease{
            
            for (var i:uint = 0; i < allDiseases.length; i++){
                
                if ((allDiseases[i] as Disease).id == diseaseId){
                    
                    return allDiseases[i];
                    
                }
                
            }
            
            return null;            
        }
        
        public function getDiseasesByPerson(person:Person):Array{
            var array:Array = new Array();
            for (var i:uint = 0; i < allDiseases.length; i++){
                
                if ((allDiseases[i] as Disease).isInfected(person) || (allDiseases[i] as Disease).personToInfect == person){
                    array.push(allDiseases[i]);            
                }
                
            }
            
            return array;    
        }
        
        private function isContagious(disease:Disease):Boolean{
            
            var diseaseType:String = disease.type;
            
            if (diseaseType == "1"){
                
                return true;
                
            } else if (diseaseType == "2"){
                
                return true;
                
            } 
            
            return true;
            
        }
        
        private function getDuration(disease:Disease):int{
            
            return 3000;
            
        }
        
        public function setDiseaseColor(diseaseType:String, person:Person, removeColor:Boolean = false):void
        {
            
            
            var container:DisplayObjectContainer = person._this.parent;            
            
            //var color:ColorTransform = person.myColorTransform;
            
            //color.alphaMultiplier = person._this.alpha;
            
            var colorData:Object;
            
            if (diseaseType == SkullTypes.LOW_POWER){
                
                colorData = cerulean;
                
            } else if (diseaseType == SkullTypes.CONSTIPATION){
                
                colorData = moss;
                
            } else if (diseaseType == SkullTypes.SLOW){
                
                colorData = black;
                
            } else if (diseaseType == SkullTypes.QUICK){
                
                colorData = white;
                
            } else if (diseaseType == SkullTypes.CONFUSION){
                
                colorData = yellow;
                
            } else if (diseaseType == SkullTypes.RECKLESS){
                
                colorData = purple;
                
            } else if (diseaseType == SkullTypes.DIZZY){
                
                colorData = viridian;
            } else if (diseaseType == SkullTypes.DIARRHOEA){
                
                colorData = ignite; 
            } else if (diseaseType == SkullTypes.SHORT_FUSE){
                
                colorData = ochre; 
            } else if (diseaseType == SkullTypes.LONG_FUSE){
                
                colorData = green; 
            } else if (diseaseType == SkullTypes.EPIC_FIRE){
                
                colorData = bordeaux; 
            }
            
            
            if (removeColor)
            {
                
                //color.redOffset -= colorData.red;
                //color.greenOffset -= colorData.green;
                //color.blueOffset -= colorData.blue;
                
                //var newFilterSet:Array = []
                
                /*for each(var thisGlowFilter:GlowFilter in person.outline.mc.filters){
                
                
                if (thisGlowFilter.color == colorData.filter){
                
                newFilterSet = person._this.filters.concat();
                newFilterSet.splice(person._this.filters.indexOf(thisGlowFilter), 1);
                
                }
                }*/
                if(getDiseasesByPerson(person).length == 0){
                    person.outline.deactivate();
                    person._this.filters = [];
                }
                /*
                if (person.outline != null){
                    person.outline.killMe();
                    person.outline = null;
                }
                */
                //person._this.transform.colorTransform = color;
                
            } 
            else
            {
                
                //color.redOffset += colorData.red;
                //color.greenOffset += colorData.green;
                //color.blueOffset += colorData.blue;
                
                
                //person.outline = new PersonOutlineComponent(person._this);
                
                //container.addChild(person.outline.mc);            
                
                //person._this.transform.colorTransform = color;
                
                person.outline.activate();
            }            
            
        }
        
        
        private function colorTingling(e:Event):void{
            
            
            
            var cycle:Number;
            var person:Person;
            var filters:Array;
            var bOffset:Number;
            var gOffset:Number;
            var rOffset:Number;
            
            for (var i:uint=0; i < allInfected.length; i++){
                
                cycle = allInfected[i].colorCycle;
                person = allInfected[i];    
                
                                
                //person.variation.redOffset = person.myColorTransform.redOffset;
                //person.variation.blueOffset = person.myColorTransform.blueOffset;
                //person.variation.greenOffset = person.myColorTransform.greenOffset;
                if(person.outline!=null){                

                    filters = person.outline.mc.filters;
                    
                    allInfected[i].colorCycle = (cycle + 0.2) % (2*Math.PI);
                    var variation:Number = Math.cos(allInfected[i].colorCycle) * .6 + 1;
                    
                    (filters[0] as GlowFilter).strength = variation +1;
                    (filters[0] as GlowFilter).blurX = (variation + 1) *10;
                    (filters[0] as GlowFilter).blurY = (variation + 1) *10;
                    
                    //person.outline.mc.filters = filters;
                    person._this.filters = filters;
                }
                
                //person.variation.redOffset *=  variation;
                //person.variation.greenOffset *=  variation;
                //person.variation.blueOffset *=  variation;
                //person.variation.alphaMultiplier = person._this.alpha;
                
                //person._this.transform.colorTransform = person.variation;                                    
            }
            
        }
        
        public function storeTimerTickInAdvance(diseaseId:int):void
        {
            if (timerTicks[String(diseaseId)] != null){
                timerTicks[String(diseaseId)]++;
            } else {
                timerTicks[String(diseaseId)] = 1;
            }
             
        }
        
    }
}