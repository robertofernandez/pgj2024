package com.willdom.games.bomberman.gameobjects.items
{
    public class BowlingItemAmmountDescription extends AbstractItemAmmountDescriptionWithAmountsArray
    {
        public function BowlingItemAmmountDescription()
        {
            super();

            amounts[ItemTypes.POWER_UP]    = 12;
            amounts[ItemTypes.BOMB_UP]    = 12;
            amounts[ItemTypes.SPEED_UP]    = 12;
            amounts[ItemTypes.MAX_POWER]    = 2;
            amounts[ItemTypes.KICK_BOMB]    = 3;
            amounts[ItemTypes.BOUNCING_BOMB] =     2;
            //amounts[ItemTypes.ROCKET] =     2;
            //amounts[ItemTypes.POWER_GLOVE] =     2;
            amounts[ItemTypes.POWER_BOMB]    = 3;
            amounts[ItemTypes.MINE]    = 2;
            //amounts[ItemTypes.SHIELD] =     2;
            amounts[ItemTypes.SPIKE_BOMB]    = 3;
            amounts[ItemTypes.BOMB_CHANGE]    = 3;
            amounts[ItemTypes.DANGER_BOMB]    = 3;
            amounts[ItemTypes.POWER_DOWN]    = 4;
            amounts[ItemTypes.BOMB_DOWN]    = 4;
            amounts[ItemTypes.SPEED_DOWN]    = 4;
            amounts[ItemTypes.SKULL]    = 3;
            amounts[ItemTypes.GOLD]    = 0;
        }
    }
}