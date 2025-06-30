package com.willdom.games.bomberman.usableItems
{
    import com.gq.system.GameData;
    import com.willdom.games.explodersmmo.shared.consts.SharedVars;
    
    import flash.text.TextField;
    import flash.text.TextFormat;
    import flash.ui.Keyboard;
    import flash.utils.Dictionary;

    public class UsableItemsManager
    {
        public static const ITEM_WARP:String = "warp";
        
        private var itemsDictionary:Dictionary;
        
        //For debugging
        private var textFieldQ:TextField;
        private var textFieldW:TextField;
        private var textFieldE:TextField;
        private var textFormat:TextFormat;
        
        public function UsableItemsManager()
        {
            itemsDictionary = new Dictionary;
            
            textFormat = new TextFormat(null, 14, 0xFFFFFF, true);
            
            textFieldQ = new TextField;
            textFieldW = new TextField;
            textFieldE = new TextField;
        }
        
        public function addUsableItem():void
        {
            itemsDictionary[Keyboard.Q] = new UsableItemWarp(100, ITEM_WARP);
            
            textFieldQ.text = "[Q]: ";
            textFieldW.text = "[W]: ";
            textFieldE.text = "[E]: ";
            
            if(itemsDictionary[Keyboard.Q]!=null)
                textFieldQ.appendText(itemsDictionary[Keyboard.Q].type + ", " + itemsDictionary[Keyboard.Q].usesLeft);
            if(itemsDictionary[Keyboard.W]!=null)
                textFieldW.appendText(itemsDictionary[Keyboard.W].type + ", " + itemsDictionary[Keyboard.W].usesLeft);
            if(itemsDictionary[Keyboard.E]!=null)
                textFieldE.appendText(itemsDictionary[Keyboard.E].type + ", " + itemsDictionary[Keyboard.E].usesLeft);
            
            textFieldQ.x = 650;
            textFieldQ.y = 630;
            textFieldW.x = 650;
            textFieldW.y = 650;
            textFieldE.x = 650;
            textFieldE.y = 670;
            
            textFieldQ.setTextFormat(textFormat);
            textFieldW.setTextFormat(textFormat);
            textFieldE.setTextFormat(textFormat);
            
            /*if(GameData.SHOW_ELEMENTS)
            {
                SharedVars.stage.addChild(textFieldQ);
                SharedVars.stage.addChild(textFieldW);
                SharedVars.stage.addChild(textFieldE);
            }*/
        }
        
        public function onItemKeyPressed(keyCode:int):void
        {
            /*switch (keyCode)
            {
                case Keyboard.Q:
                    useItem(itemsDictionary[Keyboard.Q]);
                    break;
                case Keyboard.W:
                    useItem(itemsDictionary[Keyboard.W]);
                    break;
                case Keyboard.E:
                    useItem(itemsDictionary[Keyboard.E]);
                    break;
            }*/
        }
        
        public function consumeItem(itemType:String):void
        {
            for each (var item:UsableItem in itemsDictionary)
            {
                if(item.type == itemType)
                {
                    item.consumeItem();
                }
            }
            
            textFieldQ.text = "[Q]: ";
            textFieldW.text = "[W]: ";
            textFieldE.text = "[E]: ";
            
            if(itemsDictionary[Keyboard.Q]!=null)
                textFieldQ.appendText(itemsDictionary[Keyboard.Q].type + ", " + itemsDictionary[Keyboard.Q].usesLeft);
            if(itemsDictionary[Keyboard.W]!=null)
                textFieldW.appendText(itemsDictionary[Keyboard.W].type + ", " + itemsDictionary[Keyboard.W].usesLeft);
            if(itemsDictionary[Keyboard.E]!=null)
                textFieldE.appendText(itemsDictionary[Keyboard.E].type + ", " + itemsDictionary[Keyboard.E].usesLeft);
            
            textFieldQ.setTextFormat(textFormat);
            textFieldW.setTextFormat(textFormat);
            textFieldE.setTextFormat(textFormat);
        }
        
        private function useItem(item:UsableItem):void
        {
            if(item != null)
            {
                if(item.usesLeft >= 1)
                {
                    item.useItem();
                }
            }
        }
        
        public function reset():void
        {
            /*if(GameData.SHOW_ELEMENTS)
            {
                SharedVars.stage.removeChild(textFieldQ);
                SharedVars.stage.removeChild(textFieldW);
                SharedVars.stage.removeChild(textFieldE);
            }*/
        }
    }
}