package com.gq.system
{
    import com.gq.moveobject.Person;
    
    import flash.display.DisplayObject;
    import flash.display.MovieClip;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.TimerEvent;
    import flash.geom.Point;
    import flash.utils.Timer;
    import flash.utils.getTimer;
    
    import com.willdom.util.helpers.EventListenerManager;

    public class DiseaseTimer
    {
        
        public static var timers:Array = new Array();
        
        public var mc:PersonClock;
        public var person:Person;
        private var initialTime:int;
        private var duration:int;
        private var elapsedTime:int;
        private var remainingTime:int;
        private var seconds:int;
        private var fraction:int;
        private var secondsStr:String;
        private var fractionStr:String;
        private var disease:Disease;
        private var currentPoint:Point;
        
        public function DiseaseTimer (person:Person, duration:int, disease:Disease)
        {
                        
            initialTime = getTimer();
            this.mc = new PersonClock();
            this.duration = duration * 1000;
            this.disease = disease;
            this.person = person;
            
            timers.push(this);
            
            var infoScreen:InfoScreen = GameData.instance.infoWindow.getChildAt(0) as InfoScreen;
            
            infoScreen.addChildAt(mc, infoScreen.getChildIndex(infoScreen.spectateBox) -1);
            EventListenerManager.setListenerTo(mc, Event.ENTER_FRAME, onEnterFrame);
            elapsedTime = 0;
            remainingTime = duration;
            seconds = Math.floor(remainingTime/1000);
            fraction = Math.floor((remainingTime % 1000)/10);
            
            mc.y = person._this.y + 100;
            mc.x = person._this.x + 33;
            
            if (person._this.scaleX > 0){
                mc.x += mc.width;
            } else {
                
            }
            
            mc.txt.text = "" + seconds;
            if(duration != 0){
                mc.visible = true;
            }
        }
        
        
        public static function dispose():void{
            var diseaseTimer:DiseaseTimer;
            while(timers.length > 0){    
                timers[0].killMe();
            }            
        }
        
        /*
        private function fillTimeLabels():void{
            
            if (seconds < 10){
                secondsStr = "0" + seconds;
            } else {
                secondsStr = "" + seconds;                
            }
            
            if (fraction < 10){
                fractionStr = "0" + fraction;
            } else {
                fractionStr = "" + fraction;
            }
            
            if (seconds <= 0 && fraction <= 0){
                
                mc.txt.text = "00:00";
                
            } else {
            
            mc.txt.text = secondsStr + ":" + fractionStr;
            
            }
        }
        */
        
        private function onEnterFrame(e:Event):void{
            
            if (person != null && person._this != null && person._this.visible && !person.isTweening){
                mc.visible = true;
            }else{
                mc.visible = false;
                return;
            }
            
            if (remainingTime > 0 && disease.isInfected(person)){
            
                /*elapsedTime = getTimer() - initialTime;
                remainingTime = duration - elapsedTime;
                seconds = Math.floor(remainingTime/1000);
                fraction = Math.floor((remainingTime % 1000)/10);
                */
                mc.y = person._this.y + 100;
                mc.x = person._this.x + 33;

                if (person._this.scaleX > 0){
                    mc.x += mc.width - 2;
                } else {
                    
                }
                
            }
        }
        
        public function killMe():void{
            timers.splice(timers.indexOf(this),1);
            mc.visible = false;
            (GameData.instance.infoWindow.getChildAt(0) as InfoScreen).removeChild(mc);
            EventListenerManager.removelistenerFrom(mc, Event.ENTER_FRAME, onEnterFrame);
            mc = null;
            person = null;
                        
        }
    }
}