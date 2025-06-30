package configuration{
        
    public class StageModes{
        
        public static const DEFAULT:String = "classic";
        public static const CLASSIC:String = "classic";
        public static const OPEN:String = "open";
        public static const HOLE:String = "hole";
        public static const GRAB:String = "itemgrab";
        public static const HYPER:String = "hyper";
        public static const PENGUIN:String = "penguin";
        public static const PASSAGE:String = "passage";
        public static const ASYMMETRICAL:String = "asymmetrical";
        public static const ZOMBIES:String = "zombies";
        public static const POWER:String = "power";
        public static const VOLCANOES:String = "volcanoes";
        public static const BOWLING:String = "bowling";
        
        public var optionMap:Object;
        public var reverseOptionMap:Object;
        public static var _instance:StageModes=new StageModes();
        
        public function StageModes():void{
            
            optionMap=new Object();
            reverseOptionMap=new Object();
            optionMap[CLASSIC]="classic";
            reverseOptionMap["classic"]=CLASSIC;
            
            optionMap[DEFAULT]="classic";
            reverseOptionMap["classic"]=DEFAULT;
            
            optionMap[OPEN]="openField";
            reverseOptionMap["openField"]=OPEN;
            
            optionMap[HOLE]="potHoles";
            reverseOptionMap["potHoles"]=HOLE;
            
            optionMap[GRAB]="itemGrab";
            reverseOptionMap["itemGrab"]=GRAB;
            
            optionMap[HYPER]="hyperFeet";
            reverseOptionMap["hyperFeet"]=HYPER;
            
            optionMap[PENGUIN]="classicPenguin";
            reverseOptionMap["classicPenguin"]=PENGUIN;
            
            optionMap[PASSAGE] = "dungeon";
            reverseOptionMap["dungeon"]=PASSAGE;
            
            optionMap[ASYMMETRICAL] = "tundra";
            reverseOptionMap["tundra"] = ASYMMETRICAL;
            
            optionMap[ZOMBIES] = "zombies";
            reverseOptionMap["zombies"] = ZOMBIES;
            
            optionMap[POWER] = "power";
            reverseOptionMap["power"] = POWER;
            
            optionMap[VOLCANOES] = "volcanoes";
            reverseOptionMap["volcanoes"] = VOLCANOES;
            
            optionMap[BOWLING] = "bombBowling";
            reverseOptionMap["bombBowling"] = BOWLING;
        }
        
        public static function getInstance():StageModes    {
            return _instance;    
        }
        
    }
}