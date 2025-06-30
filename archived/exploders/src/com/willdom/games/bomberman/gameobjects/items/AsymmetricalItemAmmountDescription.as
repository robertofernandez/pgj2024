package com.willdom.games.bomberman.gameobjects.items
{
    public class AsymmetricalItemAmmountDescription extends AbstractItemAmmountDescriptionWithAmountsArray
    {
        public function AsymmetricalItemAmmountDescription()
        {
            super();
            amounts[ItemTypes.POWER_UP] = 7;
            amounts[ItemTypes.BOMB_UP] = 7;
            amounts[ItemTypes.SPEED_UP] = 7;
            amounts[ItemTypes.MAX_POWER] = 2;
            amounts[ItemTypes.KICK_BOMB] = 2;
            amounts[ItemTypes.BOUNCING_BOMB] = 2;
            //amounts[ItemTypes.ROCKET] = 2;
            //amounts[ItemTypes.POWER_GLOVE] = 2;
            amounts[ItemTypes.POWER_BOMB] = 2;
            amounts[ItemTypes.MINE] = 2;
            //amounts[ItemTypes.SHIELD] = 2;
            amounts[ItemTypes.SPIKE_BOMB] = 2;
            amounts[ItemTypes.DANGER_BOMB] = 1;
            amounts[ItemTypes.BOMB_CHANGE] = 1;
            amounts[ItemTypes.POWER_DOWN] = 2;
            amounts[ItemTypes.BOMB_DOWN] = 2;
            amounts[ItemTypes.SPEED_DOWN] = 2;
            amounts[ItemTypes.SKULL] = 3;
        }
    }
}