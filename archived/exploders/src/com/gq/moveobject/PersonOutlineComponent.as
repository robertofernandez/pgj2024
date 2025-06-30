package com.gq.moveobject
{
    import com.willdom.util.helpers.EventListenerManager;
    
    import flash.display.MovieClip;
    import flash.events.Event;
    import flash.filters.GlowFilter;

    public class PersonOutlineComponent
    {
        public var mc:PersonOutline;
        private var regularTarget:MovieClip;
        private var currentTarget:MovieClip;
        private var personAnimationContainer:MovieClip;
        private var outlineAnimationContainer:MovieClip;
        private var personAnimation:MovieClip;
        private var outlineAnimation:MovieClip;
        public var bombState:Boolean = false;
        
        public function PersonOutlineComponent(targetMc:MovieClip)
        {
            currentTarget = targetMc;
            regularTarget = targetMc;
            mc = new PersonOutline();
            currentTarget.addChildAt(mc,0);
            mc.bomb.visible = false;
            var glowFilter:GlowFilter = new GlowFilter();
            glowFilter.color = 0xFF0000;
            glowFilter.strength = 7;
            glowFilter.blurX = 5;
            glowFilter.blurY = 5;
            glowFilter.knockout = false;
            var filterSet:Array = mc.filters.concat();
            filterSet.push(glowFilter);
            mc.filters = filterSet;
            mc.visible = false;
            mc.up.visible = true;
            mc.right.visible = false;
            mc.down.visible = false;
        }
        
        public function updateOutlineVisual():void
        {
            if (!bombState)
            {
                /*if (currentTarget.up.visible)
                {
                    if (currentTarget.up.currentFrameLabel == "walk")
                    {
                        mc.up.gotoAndStop("walk");
                    } 
                    else if (currentTarget.up.currentFrameLabel == "stand")
                    {
                        mc.up.gotoAndStop("stand");
                    }
                    mc.up.visible = true;
                    mc.right.visible = false;
                    mc.down.visible = false;
                    personAnimationContainer = currentTarget.up;
                    outlineAnimationContainer = mc.up;
                } 
                else if (currentTarget.down.visible)
                {
                    if (currentTarget.down.currentFrameLabel == "walk")
                    {
                        mc.down.gotoAndStop("walk");
                    } 
                    else if (currentTarget.down.currentFrameLabel == "stand")
                    {
                        mc.down.gotoAndStop("stand");
                    } 
                    else if (currentTarget.down.currentFrameLabel == "dead" || currentTarget.down.currentFrameLabel == "fire" || currentTarget.down.currentFrameLabel == "dead2")
                    {
                        mc.down.gotoAndStop("dead");
                    }
                    mc.up.visible = false;
                    mc.right.visible = false;
                    mc.down.visible = true;
                    personAnimationContainer = currentTarget.down;
                    outlineAnimationContainer = mc.down;
                } 
                else if (currentTarget.right.visible)
                {
                    if (currentTarget.right.currentFrameLabel == "walk")
                    {
                        mc.right.gotoAndStop("walk");
                    } 
                    else if (currentTarget.right.currentFrameLabel == "stand")
                    {
                        mc.right.gotoAndStop("stand");
                    }
                    mc.up.visible = false;
                    mc.right.visible = true;
                    mc.down.visible = false;
                    personAnimationContainer = currentTarget.right;
                    outlineAnimationContainer = mc.right;
                }
                else 
                {
                    mc.scaleX = currentTarget.scaleX;                
                }*/
            } 
            else 
            {
                personAnimationContainer = currentTarget;
                outlineAnimationContainer = mc.bomb;
                
                for (var i:uint = 0; i < personAnimationContainer.numChildren; i++)
                {
                    if (personAnimationContainer.getChildAt(i) is MovieClip)
                    {
                        personAnimation = (personAnimationContainer.getChildAt(i) as MovieClip);
                    }
                }
                
                for (i = 0; i < outlineAnimationContainer.numChildren; i++)
                {
                    if (outlineAnimationContainer.getChildAt(i) is MovieClip)
                    {
                        outlineAnimation = (outlineAnimationContainer.getChildAt(i) as MovieClip);
                    }
                }
                
                if (personAnimation != null && outlineAnimation != null)
                {
                    outlineAnimation.gotoAndStop(personAnimation.currentFrame);
                } 
                else 
                {
                    deactivate();
                }
            }
        }
        
        public function deactivate():void
        {
            mc.visible = false;
        }
        
        public function activate():void
        {
            mc.up.visible = false;
            mc.right.visible = false;
            mc.down.visible = false;
            mc.visible = true;
        }
        
        public function bombStateOn(bombSkin:Bomb_1):void
        {
            mc.up.visible = false;
            mc.right.visible = false;
            mc.down.visible = false;
            mc.bomb.visible = true;
            currentTarget = bombSkin;
            bombState = true;
        }
        
        public function bombStateOff():void
        {    
            if (currentTarget is Bomb_1)
                {
                currentTarget = regularTarget;
            }
            bombState = false;
            mc.bomb.visible = false;
        }
        
        public function killMe():void
        {
            if (mc.parent != null){
                mc.parent.removeChild(mc);
            }
            mc = null;
        }
        
    }
}