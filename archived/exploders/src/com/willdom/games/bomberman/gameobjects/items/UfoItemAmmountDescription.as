package com.willdom.games.bomberman.gameobjects.items
{
    public class UfoItemAmmountDescription extends AbstractItemAmmountDescriptionWithAmountsArray
    {
        public function UfoItemAmmountDescription()
        {
            super();

            amounts[ItemTypes.POWER_UP]    = 18;
            amounts[ItemTypes.BOMB_UP]    = 18;
            amounts[ItemTypes.SPEED_UP]    = 18;
            amounts[ItemTypes.MAX_POWER]    = 4;
            amounts[ItemTypes.KICK_BOMB]    = 4;
            amounts[ItemTypes.BOUNCING_BOMB] = 4;
            //amounts[ItemTypes.ROCKET] = 2;
            //amounts[ItemTypes.POWER_GLOVE] = 2;
            amounts[ItemTypes.POWER_BOMB]    = 3;
            amounts[ItemTypes.MINE]    = 2;
            //amounts[ItemTypes.SHIELD] = 2;
            amounts[ItemTypes.SPIKE_BOMB]    = 4;
            amounts[ItemTypes.BOMB_CHANGE]    = 3;
            amounts[ItemTypes.DANGER_BOMB]    = 4;
            amounts[ItemTypes.POWER_DOWN]    = 5;
            amounts[ItemTypes.BOMB_DOWN]    = 5;
            amounts[ItemTypes.SPEED_DOWN]    = 5;
            amounts[ItemTypes.SKULL]    = 3;
            amounts[ItemTypes.GOLD]    = 0;
        }
    }
}