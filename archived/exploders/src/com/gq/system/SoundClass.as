package com.gq.system
{
    import com.willdom.games.bomberman.communication.SmartFoxClientSingleton;
    
    import flash.events.Event;
    import flash.media.Sound;
    import flash.media.SoundChannel;
    import flash.media.SoundTransform;
    import flash.utils.getDefinitionByName;
        
    public class SoundClass
    {
        public static var currentSoundTransform:SoundTransform = new SoundTransform();
        public static var soundName:String;
        public static var time:uint;
        public static var channelName:String;
        public static var music:Sound = new Sound();
        public static var musicChannel:SoundChannel = new SoundChannel();
        public static var sound:Sound = new Sound();
        public static var soundChannel:SoundChannel = new SoundChannel();
        public static var sound1:Sound = new Sound();
        public static var sound1Channel:SoundChannel = new SoundChannel();
        public static var sound2:Sound = new Sound();
        public static var sound2Channel:SoundChannel = new SoundChannel();
        public static var sound3:Sound = new Sound();
        public static var sound3Channel:SoundChannel = new SoundChannel();
        public static var sound4:Sound = new Sound();
        public static var sound4Channel:SoundChannel = new SoundChannel();
        public static var sound5:Sound = new Sound();
        public static var sound5Channel:SoundChannel = new SoundChannel();
        public static var sound6:Sound = new Sound();
        public static var sound6Channel:SoundChannel = new SoundChannel();
        public static var sound7:Sound = new Sound();
        public static var sound7Channel:SoundChannel = new SoundChannel();
        public static var sound8:Sound = new Sound();
        public static var sound8Channel:SoundChannel = new SoundChannel();
        public static var sound9:Sound = new Sound();
        public static var sound9Channel:SoundChannel = new SoundChannel();
        public static var sound10:Sound = new Sound();
        public static var sound10Channel:SoundChannel = new SoundChannel();
        public static var sound11:Sound = new Sound();
        public static var sound11Channel:SoundChannel = new SoundChannel();
        public static var sound12:Sound = new Sound();
        public static var sound12Channel:SoundChannel = new SoundChannel();
        public static var sound13:Sound = new Sound();
        public static var sound13Channel:SoundChannel = new SoundChannel();
        public static var sound14:Sound = new Sound();
        public static var sound14Channel:SoundChannel = new SoundChannel();
        public static var sound0:Sound = new Sound();
        public static var sound0Channel:SoundChannel = new SoundChannel();
        
        public static var deactivateSound:Boolean = false;
        
        public function SoundClass():void
        {
            
        }
        static public function addMusic( who:String, _soundName:String, _time:uint = 1 ):void
        {
            channelName = who;
            if( who == "music" )
            {
                SoundClass.currentSoundTransform = GameData.instance.musicTrans;
            }
            else
            {
                SoundClass.currentSoundTransform = GameData.instance.soundTrans;
            }
            soundName = _soundName;
            time = _time;
            init();
        }

        public static function init():void
        {
            playMusic();
        }

        public static function playMusic ( where:Number = 0 ):void{
        
            try{
                var tempClass:Class = getDefinitionByName( soundName ) as Class;
                var music:Sound = new tempClass();
                SoundClass[ channelName ] = music;
                SoundClass[ channelName + "Channel" ].stop ();
                SoundClass[ channelName + "Channel" ] = music.play( where, time );
                adjustVolume ( channelName );
            }catch(e:Error){
                
            }
            
        }

        public static function adjustVolume ( who:String ):void
        {
            SoundClass[ who + "Channel" ].soundTransform = currentSoundTransform;
        }
        
        public static function stopSound():void
        {
            try{    musicChannel.stop();    }
            catch(e:Error){};
            try{    soundChannel.stop();    }
            catch(e:Error){};
            try{    sound1Channel.stop();    }
            catch(e:Error){};
            try{    sound2Channel.stop();    }
            catch(e:Error){};
            try{    sound3Channel.stop();    }
            catch(e:Error){};
            try{    sound4Channel.stop();    }
            catch(e:Error){};
            try{    sound5Channel.stop();    }
            catch(e:Error){};
            try{    sound6Channel.stop();    }
            catch(e:Error){};
            try{    sound7Channel.stop();    }
            catch(e:Error){};
            try{    sound8Channel.stop();    }
            catch(e:Error){};
            try{    sound9Channel.stop();    }
            catch(e:Error){};
            try{    sound10Channel.stop();    }
            catch(e:Error){};
            try{    sound11Channel.stop();    }
            catch(e:Error){};
            try{    sound12Channel.stop();    }
            catch(e:Error){};
            try{    sound13Channel.stop();    }
            catch(e:Error){};
            try{    sound14Channel.stop();    }
            catch(e:Error){};
            try{    sound0Channel.stop();    }
            catch(e:Error){};
        }

        public static function playSound():void
        {
            try
            {    
                musicChannel = music.play(1, 9999);
                currentSoundTransform = GameData.instance.musicTrans;
                adjustVolume ( "music" );
            }
            catch(e:Error){};
            try
            {    
                sound4Channel = sound4.play(1, 9999);    
                currentSoundTransform = GameData.instance.soundTrans;
                adjustVolume ( "sound" );
            }
            catch(e:Error){};
        }

        public static function setVolume( num:Number ):void
        {
            var _volume:SoundTransform = new SoundTransform();
            _volume.volume = num;
            GameData.instance.soundTrans.volume = num;
            SoundClass.soundChannel.soundTransform = GameData.instance.soundTrans;
            SoundClass.sound1Channel.soundTransform = GameData.instance.soundTrans;
            SoundClass.sound2Channel.soundTransform = GameData.instance.soundTrans;
            SoundClass.sound3Channel.soundTransform = GameData.instance.soundTrans;
            SoundClass.sound4Channel.soundTransform = GameData.instance.soundTrans;
            SoundClass.sound5Channel.soundTransform = GameData.instance.soundTrans;
            SoundClass.sound6Channel.soundTransform = GameData.instance.soundTrans;
            SoundClass.sound7Channel.soundTransform = GameData.instance.soundTrans;
            SoundClass.sound0Channel.soundTransform = GameData.instance.soundTrans;
            GameData.instance.musicTrans.volume = num;
            if(SoundClass.musicChannel != null)
            {
                SoundClass.musicChannel.soundTransform = GameData.instance.musicTrans;
            }
        }

        public static function setsoundVolume( num:Number ):void
        {
            GameData.instance.soundTrans.volume = num;
            SoundClass.soundChannel.soundTransform = GameData.instance.soundTrans;
            SoundClass.sound1Channel.soundTransform = GameData.instance.soundTrans;
            SoundClass.sound2Channel.soundTransform = GameData.instance.soundTrans;
            SoundClass.sound3Channel.soundTransform = GameData.instance.soundTrans;
            SoundClass.sound4Channel.soundTransform = GameData.instance.soundTrans;
            SoundClass.sound5Channel.soundTransform = GameData.instance.soundTrans;
            SoundClass.sound6Channel.soundTransform = GameData.instance.soundTrans;
            SoundClass.sound7Channel.soundTransform = GameData.instance.soundTrans;
            SoundClass.sound0Channel.soundTransform = GameData.instance.soundTrans;
        }

        public static function setmusicVolume( num:Number ):void
        {
            
            GameData.instance.musicTrans.volume = num;
            SoundClass.musicChannel.soundTransform = GameData.instance.musicTrans;
        }
    }
}