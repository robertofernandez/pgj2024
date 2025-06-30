package com.willdom.games.bomberman.gameobjects.items
{
    public class ZombiesItemAmmountDescription extends AbstractItemAmmountDescriptionWithAmountsArray
    {
        public function ZombiesItemAmmountDescription()
        {
            super();
            amounts[ItemTypes.POWER_UP]    = 14;
            amounts[ItemTypes.BOMB_UP]    = 14;
            amounts[ItemTypes.SPEED_UP]    = 14;
            amounts[ItemTypes.MAX_POWER]    = 2;
            amounts[ItemTypes.KICK_BOMB]    = 2;
            amounts[ItemTypes.BOUNCING_BOMB] =     2;
            //amounts[ItemTypes.ROCKET] =     1;
            //amounts[ItemTypes.POWER_GLOVE] =     2;
            amounts[ItemTypes.POWER_BOMB]    = 2;
            amounts[ItemTypes.MINE]    = 1;
            //amounts[ItemTypes.SHIELD] =     1;
            amounts[ItemTypes.SPIKE_BOMB]    = 2;
            amounts[ItemTypes.BOMB_CHANGE]    = 1;
            amounts[ItemTypes.DANGER_BOMB]    = 1;
            amounts[ItemTypes.POWER_DOWN]    = 3;
            amounts[ItemTypes.BOMB_DOWN]    = 3;
            amounts[ItemTypes.SPEED_DOWN]    = 3;
            amounts[ItemTypes.SKULL]    = 3;
            amounts[ItemTypes.GOLD]    = 0;
        }
    }
}