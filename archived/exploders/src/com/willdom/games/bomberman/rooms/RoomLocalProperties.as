package com.willdom.games.bomberman.rooms
{
    public class RoomLocalProperties
    {
        public var capacity:int;
        public var skillpointsActive:Boolean = true;
        public var currentRound:int = 0;
        public var gameStatus:String = "";
        public var waitingList:Array = new Array();
        
        public function RoomLocalProperties()
        {   
        }
    }
}