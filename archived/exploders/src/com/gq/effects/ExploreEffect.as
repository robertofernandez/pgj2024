package com.gq.effects
{
    import com.gq.moveobject.Person;
    import com.gq.system.GameData;
    import com.gq.system.GameTools;
    import configuration.GameModes;

    public class ExploreEffect extends Effects
    {
        public function ExploreEffect():void
        {
            
        }

        override public function updataEvent():void
        {
            if(++deadCount == 16 )
            {
                GameTools.pushArr( GameData.instance.removeArr, this );
            }
        }
    }
}