package com.gq.system
{
    import com.gq.moveobject.Person;
    import com.gq.ui.FocusBoard;
    import com.smartfoxserver.v2.entities.data.SFSObject;
    import com.willdom.games.bomberman.communication.GameMessage;
    import com.willdom.games.bomberman.communication.SmartFoxClientSingleton;
    import com.willdom.games.bomberman.gameobjects.GameObjectsContainer;
    import com.willdom.games.bomberman.position.PositionManager;
    import com.willdom.games.explodersmmo.shared.model.CustomLogger;
    import com.willdom.util.helpers.EventListenerManager;
    
    import flash.display.DisplayObjectContainer;
    import flash.display.MovieClip;
    import flash.events.Event;
    import flash.events.FocusEvent;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.geom.Point;
    import flash.ui.Keyboard;
    import flash.utils.getQualifiedClassName;
    import flash.utils.getQualifiedSuperclassName;
    
    public class Ctrl
    {
        static private var Scen:DisplayObjectContainer;
        
        public var removed:Boolean;
        private var ESC:uint = 27;
        public var controlWho:*
        private var A:uint;
        private var S:uint;
        private var W:uint;
        private var D:uint;
        private var space:uint;
        private var ctrl:uint;
        
        private var inputArray:Array;
        private var alternativeDirection:Boolean = false;
        public var gameObjectsContainer:GameObjectsContainer;
        
        private var chatFocusOut:Boolean=false;
        public var firstFocusOut:Boolean=true;
        public var impossible:Boolean;
        
        public function Ctrl ( scen:DisplayObjectContainer, who:* ):void
        {
            removed = false;
            inputArray = new Array();
            Scen = scen;
            controlWho = who;
            GameData.instance.Scen.stage.focus = Scen;
            EventListenerManager.setListenerTo(Scen, KeyboardEvent.KEY_DOWN, KeyDownHD );
            EventListenerManager.setListenerTo(Scen, KeyboardEvent.KEY_UP, KeyUpHD );
            EventListenerManager.setListenerTo(Scen, Event.ACTIVATE, focusIn);
            EventListenerManager.setListenerTo(Scen, Event.DEACTIVATE, focusOut);
            
            A = GameData.instance.A;
            S = GameData.instance.S;
            D = GameData.instance.D;
            W = GameData.instance.W;
            space = GameData.instance.space;
            ctrl = GameData.instance.ctrl;
        }
        
        private function focusIn( evt:Event):void{
            trace(evt.target);
            chatFocusOut = false;
            gameObjectsContainer.onGainFocus();
            if(Scen.stage!=null){
                EventListenerManager.setListenerTo(Scen, KeyboardEvent.KEY_DOWN, KeyDownHD );
                EventListenerManager.setListenerTo(Scen, KeyboardEvent.KEY_UP, KeyUpHD );
            }
            try
            {
                GameData.instance["controlWho" + GameData.instance.myId].leftPress = false;
                GameData.instance["controlWho" + GameData.instance.myId].downPress = false;
                GameData.instance["controlWho" + GameData.instance.myId].rightPress = false;
                GameData.instance["controlWho" + GameData.instance.myId].upPress = false;
                GameData.instance["controlWho" + GameData.instance.myId].spacePress=false;
                GameData.instance["controlWho" + GameData.instance.myId].shiftPress=false;
                GameData.instance["controlWho" + GameData.instance.myId].controlPress=false;
            }
            catch(e:Error)
            {
                CustomLogger.getInstance().log("[Ctrl] impossible to access controlWho variable");
            }
            cleanInputArray();
            alternativeDirection = false;
            
        }
        
        private function focusOut( evt:Event):void{
            trace("focusOut");
            if(!firstFocusOut && !chatFocusOut){
                gameObjectsContainer.onLostFocus();
            }
            try
            {
                firstFocusOut=false;
                GameData.instance["controlWho" + GameData.instance.myId].leftPress = false;
                GameData.instance["controlWho" + GameData.instance.myId].downPress = false;
                GameData.instance["controlWho" + GameData.instance.myId].rightPress = false;
                GameData.instance["controlWho" + GameData.instance.myId].upPress = false;
                GameData.instance["controlWho" + GameData.instance.myId].spacePress=false;
                GameData.instance["controlWho" + GameData.instance.myId].shiftPress=false;
                GameData.instance["controlWho" + GameData.instance.myId].controlPress=false;
            }
            catch(e:Error)
            {
                CustomLogger.getInstance().log("[Ctrl] impossible to access controlWho variable");
            }
            cleanInputArray();
            alternativeDirection = false;
        }
        public function deactivateListeners():void{
            if(Scen.stage!=null){
                Scen.removeEventListener(KeyboardEvent.KEY_DOWN, KeyDownHD);
                Scen.removeEventListener(KeyboardEvent.KEY_UP, KeyUpHD);
            }
            try
            {
                if(GameData.instance["controlWho" + GameData.instance.myId] != null)
                {
                    GameData.instance["controlWho" + GameData.instance.myId].leftPress = false;
                    GameData.instance["controlWho" + GameData.instance.myId].downPress = false;
                    GameData.instance["controlWho" + GameData.instance.myId].rightPress = false;
                    GameData.instance["controlWho" + GameData.instance.myId].upPress = false;
                    GameData.instance["controlWho" + GameData.instance.myId].spacePress=false;
                    GameData.instance["controlWho" + GameData.instance.myId].shiftPress=false;
                    GameData.instance["controlWho" + GameData.instance.myId].controlPress=false;
                    alternativeDirection = false;
                }
            }
            catch(e:Error)
            {
                CustomLogger.getInstance().log("[Ctrl] impossible to access controlWho variable");
            }
        }
        
        public function activateListeners():void{
            removed = false;
            if(!gameObjectsContainer.lostFocusScreen){
                EventListenerManager.setListenerTo(Scen, KeyboardEvent.KEY_DOWN, KeyDownHD );
                EventListenerManager.setListenerTo(Scen, KeyboardEvent.KEY_UP, KeyUpHD );
            }
        }
        
        private function addToInputArray(value:uint):void{
            var index:int = inputArray.indexOf(value);
            if(index==-1){
                inputArray.push(value);
            }
        }
        
        private function removeFromInputArray(value:uint):void{
            alternativeDirection = false;
            var index:int = inputArray.indexOf(value);
            while(index!=-1){
                inputArray.splice(index,1);
                index = inputArray.indexOf(value);
            }
        }
        
        public function cleanInputArray():void
        {
            alternativeDirection = false;
            inputArray = new Array();
            try
            {
                if(GameData.instance["controlWho" + GameData.instance.myId] != null)
                {
                    GameData.instance["controlWho" + GameData.instance.myId].upPress = false;
                    GameData.instance["controlWho" + GameData.instance.myId].downPress = false;
                    GameData.instance["controlWho" + GameData.instance.myId].leftPress = false;
                    GameData.instance["controlWho" + GameData.instance.myId].rightPress = false;
                }
            }
            catch(e:Error)
            {
                CustomLogger.getInstance().log("[Ctrl] impossible to access controlWho variable");
            }
            
        }

    
        private function KeyDownHD( evt:KeyboardEvent ):void
        {            
            switch( evt.keyCode )
            {
                case A:
                case Keyboard.LEFT:
                    addToInputArray(PositionManager.WEST);
                    break;
                case S:
                case Keyboard.DOWN:
                    addToInputArray(PositionManager.SOUTH);
                    break;
                case D:
                case Keyboard.RIGHT:
                    addToInputArray(PositionManager.EAST);
                    break;
                case W:
                case Keyboard.UP:
                    addToInputArray(PositionManager.NORTH);
                    break;
                case Keyboard.SHIFT:
                    GameData.instance["controlWho" + GameData.instance.myId].shiftPress = true;
                    break;
                case Keyboard.CONTROL:
                    GameData.instance["controlWho" + GameData.instance.myId].controlPress = true;
                    break;
                case space:
                    GameData.instance["controlWho" + GameData.instance.myId].spacePress=true;
                    break;
                case Keyboard.Q:
                    GameData.instance.usableItemsManager.onItemKeyPressed(Keyboard.Q);
                    break;
                case Keyboard.W:
                    GameData.instance.usableItemsManager.onItemKeyPressed(Keyboard.W);
                    break;
                case Keyboard.E:
                    GameData.instance.usableItemsManager.onItemKeyPressed(Keyboard.E);
                    break;
            }
            
            if(inputArray.length==1){
                alternativeDirection = false;
                switch(inputArray[0]){
                    case PositionManager.NORTH:
                        GameData.instance["controlWho" + GameData.instance.myId].upPress = true;
                        GameData.instance["controlWho" + GameData.instance.myId].downPress = false;
                        GameData.instance["controlWho" + GameData.instance.myId].leftPress = false;
                        GameData.instance["controlWho" + GameData.instance.myId].rightPress = false;
                       break;
                    case PositionManager.SOUTH:
                        GameData.instance["controlWho" + GameData.instance.myId].upPress = false;
                        GameData.instance["controlWho" + GameData.instance.myId].downPress = true;
                        GameData.instance["controlWho" + GameData.instance.myId].leftPress = false;
                        GameData.instance["controlWho" + GameData.instance.myId].rightPress = false;
                        break;
                    case PositionManager.WEST:
                        GameData.instance["controlWho" + GameData.instance.myId].upPress = false;
                        GameData.instance["controlWho" + GameData.instance.myId].downPress = false;
                        GameData.instance["controlWho" + GameData.instance.myId].leftPress = true;
                        GameData.instance["controlWho" + GameData.instance.myId].rightPress = false;
                        break;
                    case PositionManager.EAST:
                        GameData.instance["controlWho" + GameData.instance.myId].upPress = false;
                        GameData.instance["controlWho" + GameData.instance.myId].downPress = false;
                        GameData.instance["controlWho" + GameData.instance.myId].leftPress = false;
                        GameData.instance["controlWho" + GameData.instance.myId].rightPress = true;
                        break;
                }
                
            }
        }
        
        
        public function checkChangeOfDirection(currentPosition:Point,personType:uint):void{
            
            if(inputArray.length>1){
               
                var directionToChange:int;
                var possiblePosition:Point;
                
                if(alternativeDirection){
                    directionToChange = inputArray[0];
                }else{
                    directionToChange = inputArray[1];
                }
                
                switch(directionToChange){
                    case PositionManager.NORTH:
                                                
                        possiblePosition = new Point(currentPosition.x,currentPosition.y-1);
                        
                        if( !PositionManager.tileOuttOfBounds(possiblePosition) && 
                            !GameData.instance.positionManager.incompatibleElements(personType,possiblePosition.x,possiblePosition.y,currentPosition.x,currentPosition.y) ){
                            
                            alternativeDirection = !alternativeDirection;
                            GameData.instance["controlWho" + GameData.instance.myId].upPress = true;
                            GameData.instance["controlWho" + GameData.instance.myId].downPress = false;
                            GameData.instance["controlWho" + GameData.instance.myId].leftPress = false;
                            GameData.instance["controlWho" + GameData.instance.myId].rightPress = false;
                            
                        }
                        break;
                    case PositionManager.SOUTH:
                        
                        possiblePosition = new Point(currentPosition.x,currentPosition.y+1);
                        
                        if( !PositionManager.tileOuttOfBounds(possiblePosition) && 
                            !GameData.instance.positionManager.incompatibleElements(personType,possiblePosition.x,possiblePosition.y,currentPosition.x,currentPosition.y) ){
                            
                            alternativeDirection = !alternativeDirection;
                            GameData.instance["controlWho" + GameData.instance.myId].upPress = false;
                            GameData.instance["controlWho" + GameData.instance.myId].downPress = true;
                            GameData.instance["controlWho" + GameData.instance.myId].leftPress = false;
                            GameData.instance["controlWho" + GameData.instance.myId].rightPress = false;
                           
                        } 
                        break;
                    case PositionManager.WEST:
                        
                        possiblePosition = new Point(currentPosition.x-1,currentPosition.y);
                        
                        if( !PositionManager.tileOuttOfBounds(possiblePosition) && 
                            !GameData.instance.positionManager.incompatibleElements(personType,possiblePosition.x,possiblePosition.y,currentPosition.x,currentPosition.y) ){
                            
                            alternativeDirection = !alternativeDirection;
                            GameData.instance["controlWho" + GameData.instance.myId].upPress = false;
                            GameData.instance["controlWho" + GameData.instance.myId].downPress = false;
                            GameData.instance["controlWho" + GameData.instance.myId].leftPress = true;
                            GameData.instance["controlWho" + GameData.instance.myId].rightPress = false;
                           
                        }
                        break;
                    case PositionManager.EAST:
                        
                        possiblePosition = new Point(currentPosition.x+1,currentPosition.y);
                        
                        if( !PositionManager.tileOuttOfBounds(possiblePosition) && 
                            !GameData.instance.positionManager.incompatibleElements(personType,possiblePosition.x,possiblePosition.y,currentPosition.x,currentPosition.y) ){
                            
                            alternativeDirection = !alternativeDirection;
                            GameData.instance["controlWho" + GameData.instance.myId].upPress = false;
                            GameData.instance["controlWho" + GameData.instance.myId].downPress = false;
                            GameData.instance["controlWho" + GameData.instance.myId].leftPress = false;
                            GameData.instance["controlWho" + GameData.instance.myId].rightPress = true;
                            
                        }  
                        break;
                }
                
            }    
        }        
        
        
        //
        private function KeyUpHD( evt:KeyboardEvent ):void
        {
            switch( evt.keyCode )
            {
                case A:
                case Keyboard.LEFT:
                    removeFromInputArray(PositionManager.WEST);
                    GameData.instance["controlWho" + GameData.instance.myId].leftPress = false;
                    break;
                case S:
                case Keyboard.DOWN:
                    removeFromInputArray(PositionManager.SOUTH);
                    GameData.instance["controlWho" + GameData.instance.myId].downPress = false;
                    break;
                case D:
                case Keyboard.RIGHT:
                    removeFromInputArray(PositionManager.EAST);
                    GameData.instance["controlWho" + GameData.instance.myId].rightPress = false;
                    break;
                case W:
                case Keyboard.UP:
                    removeFromInputArray(PositionManager.NORTH);
                    GameData.instance["controlWho" + GameData.instance.myId].upPress = false;
                    break;
                case Keyboard.SHIFT:
                    GameData.instance["controlWho" + GameData.instance.myId].shiftDone = false;
                    GameData.instance["controlWho" + GameData.instance.myId].shiftPress = false;
                    break;
                case Keyboard.CONTROL:
                    GameData.instance["controlWho" + GameData.instance.myId].controlDone = false;
                    GameData.instance["controlWho" + GameData.instance.myId].controlPress = false;
                    break;
                case space:
                    GameData.instance["controlWho" + GameData.instance.myId].spacePress=false;
                    break;
            }
            
            if(inputArray.length>0){
                switch(inputArray[0]){
                    case PositionManager.NORTH:
                        GameData.instance["controlWho" + GameData.instance.myId].upPress = true;
                        GameData.instance["controlWho" + GameData.instance.myId].downPress = false;
                        GameData.instance["controlWho" + GameData.instance.myId].leftPress = false;
                        GameData.instance["controlWho" + GameData.instance.myId].rightPress = false;
                        break;
                    case PositionManager.SOUTH:
                        GameData.instance["controlWho" + GameData.instance.myId].upPress = false;
                        GameData.instance["controlWho" + GameData.instance.myId].downPress = true;
                        GameData.instance["controlWho" + GameData.instance.myId].leftPress = false;
                        GameData.instance["controlWho" + GameData.instance.myId].rightPress = false;
                        break;
                    case PositionManager.WEST:
                        GameData.instance["controlWho" + GameData.instance.myId].upPress = false;
                        GameData.instance["controlWho" + GameData.instance.myId].downPress = false;
                        GameData.instance["controlWho" + GameData.instance.myId].leftPress = true;
                        GameData.instance["controlWho" + GameData.instance.myId].rightPress = false;
                        break;
                    case PositionManager.EAST:
                        GameData.instance["controlWho" + GameData.instance.myId].upPress = false;
                        GameData.instance["controlWho" + GameData.instance.myId].downPress = false;
                        GameData.instance["controlWho" + GameData.instance.myId].leftPress = false;
                        GameData.instance["controlWho" + GameData.instance.myId].rightPress = true;
                        break;
                }
            }
            else
            {         
                alternativeDirection = false;
                GameData.instance["controlWho" + GameData.instance.myId].upPress = false;
                GameData.instance["controlWho" + GameData.instance.myId].downPress = false;
                GameData.instance["controlWho" + GameData.instance.myId].leftPress = false;
                GameData.instance["controlWho" + GameData.instance.myId].rightPress = false;
            }
        }

        public function removeMe():void
        {
            if(Scen.stage != null){
                Scen.removeEventListener(KeyboardEvent.KEY_DOWN, KeyDownHD);
                Scen.removeEventListener(KeyboardEvent.KEY_UP, KeyUpHD);
                Scen.removeEventListener(FocusEvent.FOCUS_IN, focusIn);
                Scen.removeEventListener(FocusEvent.FOCUS_OUT, focusOut);
                Scen.removeEventListener(FocusEvent.KEY_FOCUS_CHANGE, focusOut);
            }
            removed = true;
        }
    }
}