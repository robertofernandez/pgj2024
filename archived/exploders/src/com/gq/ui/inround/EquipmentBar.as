package com.gq.ui.inround
{
    import flash.display.Sprite;

    public class EquipmentBar extends Sprite
    {
        private var texture:MC_InGameEquipmentBar;
        
        public function EquipmentBar()
        {
            texture = new MC_InGameEquipmentBar;
            
            addChild(texture);
        }
        
        public function resetPowerUps():void
        {
            texture.iconBombType.gotoAndStop("faded");
            texture.iconDisguise.gotoAndStop("faded");
            texture.iconKick.gotoAndStop("faded");
            
            texture.txtBombsAmount.label.text = "1";
            texture.txtFirePower.label.text = "1";
            texture.txtSpeedAmount.label.text = "1";
            
            texture.txtBombsAmount.visible = false;
            texture.txtFirePower.visible = false;
            texture.txtSpeedAmount.visible = false;
        }
        
        public function updateBombIcon(type:String):void
        {
            texture.iconBombType.gotoAndStop(type);
        }
        
        public function updateDisuiseIcon(enabled:Boolean = true):void
        {
            if(enabled)
            {
                texture.iconDisguise.gotoAndStop("normal");
            }
            else
            {
                texture.iconDisguise.gotoAndStop("faded");
            }
        }
        
        public function updateKickIcon(enabled:Boolean = true):void
        {
            if(enabled)
            {
                texture.iconKick.gotoAndStop("normal");
            }
            else
            {
                texture.iconKick.gotoAndStop("faded");
            }
        }
        
        public function updateBombsAmount(amount:int):void
        {
            texture.txtBombsAmount.label.text = amount.toString();
            
            if(amount > 1)
            {
                texture.txtBombsAmount.visible = true;
            }
            else
            {
                texture.txtBombsAmount.visible = false;
            }
        }
        
        public function updateFirePowerAmount(amount:int):void
        {
            texture.txtFirePower.label.text = amount.toString();
            
            if(amount > 1)
            {
                texture.txtFirePower.visible = true;
            }
            else
            {
                texture.txtFirePower.visible = false;
            }
        }
        
        public function updateSpeedAmount(amount:int):void
        {
            texture.txtSpeedAmount.label.text = amount.toString();
            
            if(amount > 1)
            {
                texture.txtSpeedAmount.visible = true;
            }
            else
            {
                texture.txtSpeedAmount.visible = false;
            }
        }
    }
}