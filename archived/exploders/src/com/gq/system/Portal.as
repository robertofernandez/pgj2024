package com.gq.system
{
    import com.gq.moveobject.Person;
    import com.greensock.TweenMax;
    import com.willdom.games.bomberman.position.PositionManager;
    import flash.display.MovieClip;
    import flash.geom.ColorTransform;
    
    public class Portal
    {
        private static const PORTAL_OPENING_TIME:Number = .4;
        private static var allPortals:Array = [];
        private var colorTransform:ColorTransform;
        private var portalMc:PortalEffect;
        public var targetMc:MovieClip;
        private var binded:Boolean = false;
        private var closed:Boolean = false;
        public var orange:Boolean = false;
        
        public function Portal()
        {
            colorTransform = new ColorTransform();
            portalMc = new PortalEffect();
            portalMc.scaleX = 0;
            portalMc.x = GameData.instance.rectWidth/2 + 1;
            portalMc.y = GameData.instance.rectHeight + 6 ;
            //portalMc.mask = portalMc.maskMc;
            allPortals.push(this);
            
        }
        
        public function openPortal(targetMc:MovieClip, orange:Boolean = false, autoClose:Boolean = false):void
        {
            this.orange = orange;
            
            targetMc.addChildAt(portalMc, 0);            
            if (closed)
            {
                TweenMax.to(targetMc, PORTAL_OPENING_TIME, {scaleX:1});
            } 
            else if (autoClose)
            {
                TweenMax.to(portalMc, PORTAL_OPENING_TIME, {scaleX:1, onComplete:closePortal});
            } 
            else 
            {
                TweenMax.to(portalMc, PORTAL_OPENING_TIME, {scaleX:1});
            }
            this.targetMc = targetMc;        
            binded = true;
            closed = false;
            if (orange)
            {
                colorTransform.greenOffset = -50;
                colorTransform.redOffset = 120;
                colorTransform.blueOffset = -200;
            } 
            else 
            {
                colorTransform.redOffset = -30;
                colorTransform.greenOffset = -20;
                colorTransform.blueOffset = 50;
            }
            portalMc.transform.colorTransform = colorTransform;
        }
            
        
        public function closePortal():void
        {
            if (binded)
            {
                TweenMax.to(targetMc, PORTAL_OPENING_TIME, {scaleX:0});
                closed = true;
            } 
            else 
            {
                TweenMax.to(portalMc, PORTAL_OPENING_TIME, {scaleX:0});
            }
        }
        
        public function killPortal():void
        {
            targetMc.removeChild(portalMc);
            portalMc = null;
            allPortals.splice(allPortals.indexOf(this),1);
        }
        
        public function unbind():void
        {
            binded = false;
        }
        
        public static function getPortalByPerson(person:Person):Portal
        {
            
            for each( var portal:Portal in allPortals){
                if (portal.targetMc == person._this){
                    return portal;
                }
            }
            
            return null;
            
        }
    }
}