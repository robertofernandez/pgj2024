package com.gq.system
{
    import com.gq.moveobject.Person;
    import com.willdom.games.bomberman.communication.SmartFoxClientSingleton;
    import com.willdom.games.bomberman.consts.SkullTypes;
    
    import flash.geom.ColorTransform;
    import flash.utils.Timer;
    
    public class Disease
    {        
        private static var diseaseIdCount:uint = 1;
        
        private var _infectedPersons:Array;
        private var _duration:int;
        private var _type:String;
        private var _id:int;
        private var _contagious:Boolean = true;
        private var _personToInfect:Person; 
        private var _overrideEndOfDisease:Boolean = false;
        private var _prevDiseaseTimer:int;
        private var _maxDiseaseTimer:int;
        private var _person:Person;
        private var _tick:int;
        private var currentTime:int;
        private var timerDisplay:DiseaseTimer;
        
        public function Disease(contagious:Boolean = true, duration:int = 10):void
        {
            _infectedPersons = new Array();
            _id = diseaseIdCount;
            _contagious = contagious;
            diseaseIdCount++;
            _duration = duration;
            _maxDiseaseTimer = duration;
        }
        
        public static function dispose():void{
            diseaseIdCount = 1;
        }
        
        public function get duration():int
        {
            return _duration;
        }
                
        public function infectPerson(target:Person):void
        {
            _person = target;
            
            if(duration != 0)
            {
                if (timerDisplay == null)
                {
                    timerDisplay = new DiseaseTimer(target, duration, this);
                }
                else 
                {
                    timerDisplay.person = target;
                }
            }
            
            GameData.instance.diseaseManager.allInfected.push(target);
            GameData.instance.diseaseManager.setDiseaseColor(type, target);
            
            _infectedPersons.push(target);
            
            target.getSkull(type);
        }
        
        public function get infectedPersons():Array{
            
            return _infectedPersons.concat();
        }
        
        public function isInfected(person:Person):Boolean
        {
            if (_infectedPersons.indexOf(person) > -1){
                return true;
            } else {
                return false;
            }
        }
        
        public function healPerson(target:Person,final:Boolean=false):void{
            if(_infectedPersons.indexOf(target) > -1){
                var t:int = _infectedPersons.indexOf(target);
                _infectedPersons.splice(t, 1);
            }
            
            if(GameData.instance.diseaseManager.allInfected.indexOf(target) > -1){
                GameData.instance.diseaseManager.allInfected.splice(GameData.instance.diseaseManager.allInfected.indexOf(target), 1);
            }
            
            target.removeSkull(type, final);
            
            if (final && timerDisplay!=null && timerDisplay.person!=null ){
                timerDisplay.killMe();
            }
            
            if (type != SkullTypes.POSITION_SWITCH){
                GameData.instance.diseaseManager.setDiseaseColor(type, target, true);
            }
        }
        
        public function healAllPersons(final:Boolean = false):void{
            while (_infectedPersons.length > 0){
                healPerson(_infectedPersons[0],final);
            }
        }
        
        public function removeDisconnectedPersons():void
        {
            var erasePeople:Array = [];
            var p:Person;
            
            for each (p in _infectedPersons)
            {
                if (Person.getPersonByName(p.myName) == null)
                {
                    erasePeople.push(p);
                }
            }
            for each (p in erasePeople)
            {
                if (GameData.instance.diseaseManager.allInfected.indexOf(p) > -1)
                {
                    GameData.instance.diseaseManager.allInfected.splice(GameData.instance.diseaseManager.allInfected.indexOf(p), 1);
                    
                }
                _infectedPersons.splice(_infectedPersons.indexOf(p),1);
            }    
        }
        
        public function remainingTime(currentTime:int):int
        {
            return duration - currentTime;
        }
        
        public function setTimerTick(tick:uint):void
        {
            _tick = tick;
            
            if(timerDisplay!=null)
            {
                timerDisplay.mc.txt.text = "" + tick;
            }
        }
        
        public function get isContagious():Boolean
        {
            return _contagious;
        }
        
        public function get id():uint
        {
            return _id;
        }
        
        public function get type():String
        {
            return _type;
        }
        
        public function set type(value:String):void
        {
            _type = value;
        }
        
        public function get personToInfect():Person
        {
            return _personToInfect;
        }
        
        public function set personToInfect(value:Person):void
        {
            _personToInfect = value;
        }
        
        public function get overrideEndOfDisease():Boolean
        {
            return _overrideEndOfDisease;
        }
        
        public function set overrideEndOfDisease(value:Boolean):void
        {
            _overrideEndOfDisease = value;
        }
        
        public function get prevDiseaseTimer():int
        {
            return _prevDiseaseTimer;
        }
        
        public function set prevDiseaseTimer(value:int):void
        {
            _prevDiseaseTimer = value;
        }
        
        public function get maxDiseaseTimer():int
        {
            return _maxDiseaseTimer;
        }
        
        public function set maxDiseaseTimer(value:int):void
        {
            _maxDiseaseTimer = value;
        }
        
        public function get tick():int
        {
            return _tick;
        }
    }
}