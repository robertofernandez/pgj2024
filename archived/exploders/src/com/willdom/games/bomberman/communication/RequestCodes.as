package com.willdom.games.bomberman.communication
{
    public class RequestCodes
    {
        public static const JOIN_MM_QUEUE:String = "mm.j";
        public static const LEAVE_MM_QUEUE:String = "mm.l";
        
        public static const JOIN_CHAT:String = "join_chat";
        
        public static const GAME_MESSAGE:String = "gm";
        public static const START_GAME:String = "sg";
        public static const END_GAME:String = "eg";
        public static const GAME_READY:String = "gr";
        public static const BEGIN_GAME:String = "bg";
        public static const RESTART_GAME:String = "rg";
        public static const LEAVE_GAME:String = "lg";
        
        public static const CHANGE_TEAM:String = "ct";
        public static const SKILLPOINTS_MESSAGE:String = "skm";
        public static const SEED_VALUE:String = "sv";
        
        public static const MESSAGE_TO_MODS:String = "mtm";
        
        public static const WHO_IS_PLAYING_WITH:String = "wpw";
        
        public static const CREATE_GAME:String = "cg";
        public static const JOIN_GAME:String = "jg";
        
        public static const JOIN_WAITING_LIST:String = "wlc";
        public static const IS_IN:String = "isIn";
    }
}