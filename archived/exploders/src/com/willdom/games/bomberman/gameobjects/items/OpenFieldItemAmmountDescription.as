package com.willdom.games.bomberman.gameobjects.items
{
    public class OpenFieldItemAmmountDescription extends AbstractItemAmmountDescriptionWithAmountsArray
    {
        public function OpenFieldItemAmmountDescription()
        {
            super();

            amounts[ItemTypes.POWER_UP]    = 25;
            amounts[ItemTypes.BOMB_UP]    = 25;
            amounts[ItemTypes.SPEED_UP]    = 25;
            amounts[ItemTypes.MAX_POWER]    = 5;
            amounts[ItemTypes.KICK_BOMB]    = 5;
            amounts[ItemTypes.BOUNCING_BOMB] = 5;
            //amounts[ItemTypes.ROCKET] = 4;
            //amounts[ItemTypes.POWER_GLOVE] = 3;
            amounts[ItemTypes.POWER_BOMB]    = 4;
            amounts[ItemTypes.MINE]    = 2;
            //amounts[ItemTypes.SHIELD] = 2;
            amounts[ItemTypes.SPIKE_BOMB]    = 5;
            amounts[ItemTypes.BOMB_CHANGE]    = 3;
            amounts[ItemTypes.DANGER_BOMB]    = 5;
            amounts[ItemTypes.POWER_DOWN]    = 6;
            amounts[ItemTypes.BOMB_DOWN]    = 6;
            amounts[ItemTypes.SPEED_DOWN]    = 6;
            amounts[ItemTypes.SKULL]    = 3;
            amounts[ItemTypes.GOLD]    = 0;
        }
    }
}