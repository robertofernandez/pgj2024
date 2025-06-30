package com.willdom.games.bomberman.gameobjects.items
{
    public class ItemGrabItemAmmountDescription extends AbstractItemAmmountDescriptionWithAmountsArray
    {
        public function ItemGrabItemAmmountDescription()
        {
            super();
            //TODO: replace amounts when items implemented
            amounts[ItemTypes.POWER_UP]    = 16;
            amounts[ItemTypes.BOMB_UP]    = 16;
            amounts[ItemTypes.SPEED_UP]    = 16;
            amounts[ItemTypes.MAX_POWER]    = 4;
            amounts[ItemTypes.KICK_BOMB]    = 5;
            amounts[ItemTypes.BOUNCING_BOMB] = 4;
            //amounts[ItemTypes.ROCKET] = 2;
            //amounts[ItemTypes.POWER_GLOVE] = 3;
            amounts[ItemTypes.POWER_BOMB] = 2;
            amounts[ItemTypes.MINE]    = 2;
            amounts[ItemTypes.SPIKE_BOMB] = 4;
            amounts[ItemTypes.BOMB_CHANGE] = 3;
            //amounts[ItemTypes.SHIELD] = 2;
            amounts[ItemTypes.DANGER_BOMB]    = 3;
            amounts[ItemTypes.POWER_DOWN]    = 3;
            amounts[ItemTypes.BOMB_DOWN]    = 3;
            amounts[ItemTypes.SPEED_DOWN]    = 3;
            amounts[ItemTypes.SKULL]    = 3;
            amounts[ItemTypes.GOLD]    = 0;
        }
    }
}