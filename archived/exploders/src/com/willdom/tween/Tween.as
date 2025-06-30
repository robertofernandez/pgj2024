package com.willdom.tween
{
    import flash.display.MovieClip;
    import flash.events.EventDispatcher;
    import flash.utils.getTimer;
    
    public class Tween extends EventDispatcher
    {
        private var currentTime:int;
        private var finalTime:int;        
        private var targetValues:Object = new Object();    //Hashmap of TweenData instances.
        private var targetsList:Array = new Array();
        private var stepTime:int;
        private var running:Boolean = false;
        private var onCompleteParams:Object;
        
        public function Tween()
        {
        }
        
        
        /**
         * - duration argument: Is the amount of time the tween will elapse, expressed in miliseconds
         * - addTime argument: Will determinate how the duration is managed, if true, the time will be added to the original duration, 
         * respecting the elapsed time for the original count. If false, it will discard the original elasped time and restart the time count
         * - onCompleteParams argument: Takes an object with parameters that can be provided to a function that will be triggered once the tween is completed,
         * parameters should be stored in the same order they will be provided to the function
         **/
        public function start(duration:int, addTime:Boolean = true, onCompleteParams:Object = null):void
        {
            this.onCompleteParams = onCompleteParams;     
            
            if (!running)
            {
                currentTime = getTimer();
                running = true;
                finalTime = currentTime + duration;
                
            }
            else if (addTime)
            {
                finalTime += duration;
            }
            else
            {
                finalTime = currentTime + duration;
            }
            
            var tweenData:TweenData;
            
            for each(var target:String in targetsList){
                for each (tweenData in targetValues[target]){
                    tweenData.currentVel = (tweenData.finalValue - tweenData.initialValue)/(finalTime - currentTime);
                    tweenData.running = true;
                }
            }
            
        }
        
        /**
         * The object parameter is a string that identifies a particular tweenable object. A single tween instance can tween multiple objects.
         **/
        
        public function addProperty(object:String,tweenData:TweenData):void
        {
            var enc:Boolean = false;
            var i:int = 0;
            
            if (targetValues[object] == null){
                targetValues[object] = [];
            }
            
            for(i = 0;i < targetValues[object].length && !enc;i++){
                if( (targetValues[object][i] as TweenData).property == tweenData.property){
                    enc = true;
                    break;
                }
            }
            if (enc){
                targetValues[object][i] = tweenData;
            } else {
                targetValues[object].push(tweenData);
            }
            
            if (targetsList.indexOf(object) == -1){
                targetsList.push(object);
            }
            if(running){
                tweenData.currentVel = (tweenData.finalValue - tweenData.initialValue)/(finalTime - currentTime);
            }
        }
        
        public function kill():void{
            currentTime = 0;
            finalTime = 0;        
            targetValues = {};    //Hashmap of TweenData instances.
            targetsList = [];
            stepTime = 0;
            running = false;
            onCompleteParams = {};
        }
        
        public function update():void
        {
            if (running)
            {            
                
                var tweenData:TweenData;
                var newValue:Number;
                
                stepTime = getTimer() - currentTime;
                
                for each(var target:String in targetsList){
                    for each (tweenData in targetValues[target]){
                        if (tweenData.property == "frame" && tweenData.target is MovieClip)
                        {
                            newValue = (tweenData.target as MovieClip).currentFrame + tweenData.currentVel * stepTime;
                        }
                        else
                        {
                            newValue = tweenData.target[tweenData.property] + tweenData.currentVel * stepTime;
                        }
                        if (tweenData.running)
                        {
                            if(tweenData.currentVel<0){
                                if ( newValue > tweenData.finalValue ){
                                    if (tweenData.property == "frame" && tweenData.target is MovieClip)
                                    {
                                        (tweenData.target as MovieClip).gotoAndStop(Math.floor(newValue));
                                    }
                                    else
                                    {
                                        tweenData.target[tweenData.property] = newValue;
                                    }
                                }
                                else
                                {
                                    if (tweenData.property == "frame" && tweenData.target is MovieClip)
                                    {
                                        (tweenData.target as MovieClip).gotoAndStop(Math.floor(tweenData.finalValue));
                                    }
                                    else
                                    {
                                        tweenData.target[tweenData.property] = tweenData.finalValue;
                                    }
                                    tweenData.running = false;
                                    (targetValues[target] as Array).splice((targetValues[target] as Array).indexOf(tweenData), 1);
                                    dispatchEvent(new TweenEvent(TweenEvent.COMPLETE, false, false, onCompleteParams));
                                }
                            }else{
                                if ( newValue > tweenData.finalValue )
                                {
                                    if (tweenData.property == "frame" && tweenData.target is MovieClip)
                                    {
                                        (tweenData.target as MovieClip).gotoAndStop(Math.floor(tweenData.finalValue));
                                    }
                                    else
                                    {
                                        tweenData.target[tweenData.property] = tweenData.finalValue;
                                    }
                                    tweenData.running = false;
                                    (targetValues[target] as Array).splice((targetValues[target] as Array).indexOf(tweenData), 1);
                                    dispatchEvent(new TweenEvent(TweenEvent.COMPLETE, false, false, onCompleteParams));
                                }
                                else
                                {
                                    
                                    if (tweenData.property == "frame" && tweenData.target is MovieClip)
                                    {
                                        (tweenData.target as MovieClip).gotoAndStop(Math.floor(newValue));
                                    }
                                    else
                                    {
                                        tweenData.target[tweenData.property] = newValue;
                                    }
                                }
                            }
                        }
                    }
                }
                currentTime += stepTime;
                if (targetValues[target] != null && (targetValues[target] as Array).length == 0){
                    targetValues[target] = null;
                    running = false;
                }
            }
        }
    }
}