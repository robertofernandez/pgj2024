package com.willdom.games.bomberman.consts
{
    public class SkullTypes
    {
        
        //String text tied to language tags.
        public static const CONSTIPATION:String = "Constipation";
        public static const CONFUSION:String = "Confusion";
        public static const LOW_POWER:String = "LowPower";
        public static const RECKLESS:String = "Reckless";
        public static const SLOW:String = "Slow";
        public static const QUICK:String = "Quick";
        public static const DIZZY:String = "Dizzy";
        public static const DIARRHOEA:String = "Diarrhoea";
        public static const SHORT_FUSE:String = "ShortFuze";
        public static const LONG_FUSE:String = "LongFuze";
        public static const POSITION_SWITCH:String = "PositionSwitch";
        public static const EPIC_FIRE:String = "EpicFire";
        public static const SUDDEN_DEATH:String = "SuddenDeath";
        
        
        public static const DISEASES_ARRAY:Array = [CONSTIPATION,CONFUSION,LOW_POWER,RECKLESS,SLOW,QUICK,DIZZY,
                                                    DIARRHOEA,SHORT_FUSE,LONG_FUSE,POSITION_SWITCH,EPIC_FIRE,SUDDEN_DEATH];
        
        public static function getDiseaseText(diseaseType:String):String{
            //return StringHelper.replaceTag("_skullname" + diseaseType);
            return LanguageManager.getInstance().getText("_skullname" + diseaseType);
        }
        
        public static function getDiseaseTextByIndex(diseaseTypeIndex:int):String{
            //return StringHelper.replaceTag("_skullname" + DISEASES_ARRAY[diseaseTypeIndex]);    
            return LanguageManager.getInstance().getText("_skullname" + DISEASES_ARRAY[diseaseTypeIndex]);
        }
    }
}