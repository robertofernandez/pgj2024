package com.gq.system
{
    import flash.geom.Rectangle;
    import flash.text.TextField;
    import flash.text.TextFormat;

    public class AutoResizeData
    {
        
        public static var allInstances:Array = new Array();
        
        public var textField:TextField;
        public var textFormat:TextFormat;
        public var fontSize:int = 0;
        public var rectArea:Rectangle;
        
        public function AutoResizeData(textField:TextField):void
        {
            
            this.textField = textField;
            this.rectArea = new Rectangle(textField.x, textField.y, textField.width, textField.height);
            if (allInstances.indexOf(this) == -1){    
                this.textFormat = textField.getTextFormat();
                this.fontSize = int(textFormat.size);
                allInstances.push(this);
            }
        }
        
        
        /**
         * Returns the format corresponding to a certan textField, in case there is one. If there isn't, returns null.
         * */
        public static function getData(textField:TextField):AutoResizeData{
            
            for (var i:uint = 0; i < allInstances.length; i++){
                
                if (allInstances[i].textField == textField){
                    
                    return allInstances[i];
                    
                }
                
            }
            
            return null;
            
        }
        
        public static function dispose():void{
            
            allInstances.splice();
            
        }
        
    }
}