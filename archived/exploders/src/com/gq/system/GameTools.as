package com.gq.system
{
    import com.gq.effects.*;
    import com.gq.moveobject.*;
    import com.gq.ui.*;
    import com.smartfoxserver.v2.entities.Room;
    import com.smartfoxserver.v2.entities.User;
    import com.smartfoxserver.v2.entities.data.SFSArray;
    import com.smartfoxserver.v2.entities.data.SFSObject;
    import com.willdom.games.bomberman.communication.SmartFoxClientSingleton;
    import flash.display.BitmapData;
    import flash.display.DisplayObjectContainer;
    import flash.display.Loader;
    import flash.display.LoaderInfo;
    import flash.display.MovieClip;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.ProgressEvent;
    import flash.geom.ColorTransform;
    import flash.geom.Matrix;
    import flash.geom.Point;
    import flash.media.Sound;
    import flash.net.LocalConnection;
    import flash.net.SharedObject;
    import flash.net.URLRequest;
    import flash.text.TextField;
    import flash.utils.getDefinitionByName;
    import flash.utils.getQualifiedClassName;
    import com.willdom.games.bomberman.communication.SmartFoxClientSingleton;
    import com.willdom.games.bomberman.communication.GameMessage;
    
    public class GameTools
    {
        getQualifiedClassName( Person );
        getQualifiedClassName( Objects );
        
        getQualifiedClassName( Bomb );
        getQualifiedClassName( ExploreEffect );
        getQualifiedClassName( Treasure );
        
        public static function pushArr ( where:Array, who:* ):void
        {
            if ( where.indexOf( who ) == -1 )
            {
                where.push ( who );
            }
        }
        public static function unPushArr ( where:Array, who:* ):void
        {
            if ( where.indexOf( who ) != -1 )
            {
                where.splice ( where.indexOf( who ), 1 );
            }
        }
        ///////跳转桢//////=============================================
        public static function gotoFrame (where:MovieClip,frame:String ):void
        {
            if (where != null)
            {
                    where.gotoAndStop (frame);
            }
        }
        //计算2点之间的角度
        public static function calcuRotation ( x1:Number, y1:Number, x2:Number, y2:Number ):Number
        {
            var distY:Number = y2 - y1;
            var distX:Number = x2 - x1;
            return Math.atan2(distY,distX) / 0.01745;
        }
        //得到数字的正负号=================================================================================
        public static function getTab (num:Number, ifZero:Boolean = false):Number
        {
            if ( num != 0 )
            {
                return num / Math.abs(num);
            }
            else
            {
                if( ifZero )
                {
                    return 0;
                }
                else
                {
                    return 1;
                }
            }
        }
        //得到数字的每一位
        public static function getNum ( num:int, numLength:int, who:MovieClip = null ):Array
        {
            var arr:Array = new Array();
            var tempNum:int = num;
            for (var i:uint = 0; i < numLength; i++)
            {
                arr.push (tempNum % 10);
                tempNum = int(tempNum / 10);
                if( who != null )
                {
                    ( who.getChildAt(i) as MovieClip ).gotoAndStop( arr[ i ] + 1 );
                }
            }
            return arr;
        }
        //隐藏零位=======================================================================
        public static function hideZero ( who:MovieClip ):void
        {
            for (var i:int = who.numChildren - 1; i >= 1; i-- )
            {
                if ( ( who.getChildAt( i ) as MovieClip ).currentFrame == 1 )
                {
                    who.getChildAt( i ).visible = false;
                }
                else
                {
                    who.getChildAt( i ).visible = true;
                    break;
                }
            }
        }
        //求2点之间距离==========================================================================================================
        public static function getDistance ( num1:Number, num2:Number, num3:Number, num4:Number ):Number
        {
            var sumpow:Number = Math.pow( ( num1 - num3 ),2 ) + Math.pow( ( num2 - num4 ),2 );
            return Math.sqrt(sumpow);
        }
        //转换坐标======================================================================================
        public static function changeXY ( which:*, where:Sprite, point:Point, isStage:Boolean = true ):Point
        {
            point = which.parent.localToGlobal( point );
            if( isStage )
            {
                return point;
            }
            else
            {
                return where.globalToLocal( point );
            }
        }
        //添加滤镜=================================================================
        public static function addFilters ( who:*, filterArr:Array ):void
        {
            who.filters = [];
            who.filters = filterArr;
        }
        //添加ColorTransform=======================================================
        public static function addColors ( who:Sprite, newColor:ColorTransform ):void
        {
            who.transform.colorTransform = newColor;
        }
        //得到0-360以内的角度
        public static function getTureAngle ( angel:Number ):Number
        {
            if ( angel < 0 )
            {
                return angel + 360;
            }
            else if ( angel > 360 )
            {
                return angel - 360;
            }
            else
            {
                return angel;
            }
        }
        //动态拿类名
        public static function createClass ( who:String ):Class
        {
            return getDefinitionByName( who ) as  Class;
        }
        
        //动态拿类名
        public static function getMeBySwf ( where:String, who:String ):Class
        {
            return getDefinitionByName( who ) as Class; 
        }
        //得到旋转方向
        public static function adjustRotation ( myRotation:Number, tempPoint:Point, tempMc:MovieClip ):int
        {
            var addRot1:int;
            var addRot2:int;
            var jump_out:uint = 0;
            while ( tempMc.hitTestPoint( tempPoint.x + Math.sin( ( myRotation + addRot1 + 1 ) * 0.01745 ) * 5, 
                    tempPoint.y - Math.cos( ( myRotation + addRot1 + 1 ) * 0.01745 ) * 5, true ) )
            {
                addRot1++;
                if ( ++jump_out == 90 )
                {
                    break;
                }
            }
            jump_out = 0;
            while ( tempMc.hitTestPoint( tempPoint.x + Math.sin( ( myRotation - addRot2 - 1 ) * 0.01745 ) * 5, 
                    tempPoint.y - Math.cos( ( myRotation - addRot2 - 1 ) * 0.01745 ) * 5, true ) )
            {
                addRot2++;
                if ( ++jump_out == 90 )
                {
                    break;
                }
            }
            if ( addRot1 <= addRot2 )
            {
                return addRot1;
            }
            else
            {
                return - addRot2;
            }
        }
        //判断是否在屏幕内
        public static function judgeInScreen ( myX:Number, myY:Number, range:Number = 0.5 ):Boolean
        {
            var tempPoint:Point = GameData.instance.moveObjectContainer.localToGlobal( new Point ( myX, myY ) );
            if ( tempPoint.x > ( 0 - range ) * GameData.instance.screenWidth
              && tempPoint.x < ( range + 1 ) * GameData.instance.screenWidth 
              && tempPoint.y > ( 0 - range ) * GameData.instance.screenHeight
              && tempPoint.y < ( range + 1 ) * GameData.instance.screenHeight )
            {
                return true;
            }
            else
            {
                return false;
            }
        }
        //添加特效
        public static function addEffect ( where:DisplayObjectContainer, _x:Number, _y:Number, _scaleX:Number, which:String ):void
        {
            var tempClass:Class = createClass( which );
            var temp:MovieClip = new tempClass();
            
            temp.x = _x;
            temp.y = _y;
            temp.scaleX = _scaleX;
            where.addChild ( temp );
        }
        public static function createPage ( page:Class):Pages
        {
            var tempPage:Pages = new page();
            GameData.instance.Scen.addChild ( tempPage.page );
            return tempPage
        }
        //清空Sprite===================================
        public static function removeWho (who:DisplayObjectContainer):void
        {
            for (var i:int = who.numChildren - 1; i >= 0; i--)
            {
                who.removeChild (who.getChildAt(i));
            }
        }
        //游戏暂停和继续=======================================================================
        public static function gamePause ( _pause:Boolean ):void
        {
            for( var i:int = GameData.instance.actionArr.length - 1; i >= 0; i-- )
            {
                var ctrlMc:*;
                try
                {
                    ctrlMc = GameData.instance.actionArr[i].myHost;
                }
                catch (e:*)
                {
                    ctrlMc = GameData.instance.actionArr[i];
                }
                if ( _pause )
                {
                    ctrlMc.pauseMe ();
                }
                else
                {
                    ctrlMc.resumeMe ();
                }
            }
            for( var k:int = GameData.instance.actionArr.length - 1; k >= 0; k-- )
            {
                ctrlMc = GameData.instance.actionArr[k];
                if ( _pause )
                {
                    ctrlMc.pauseMe ();
                }
                else
                {
                    ctrlMc.resumeMe ();
                }
            }
        }
        //添加音乐================================================================================
        public static function addMusic ( who:String, Name:String, time:uint = 999, where:Number = 0 ):void
        {
            var tempClass:Class = GameData.instance.sndLoader.contentLoaderInfo.applicationDomain.getDefinition( Name ) as Class;
            var music:Sound = new tempClass();
            GameData.instance[ who ] = music;
            GameData.instance[ who + "Channel"].stop ();
            GameData.instance[ who + "Channel" ] = music.play( where, time );
            adjustVolume ( who );
        }
        public static function adjustVolume ( who:String ):void
        {
            if ( who == "music" )
            {
                GameData.instance[ who + "Channel" ].soundTransform = GameData.instance.musicTrans;
            }
            else
            {
                GameData.instance[ who + "Channel" ].soundTransform = GameData.instance.soundTrans;
            }
        }
        //比较函数======================================================
        public static function compareFunc (element:*, index:int, arr:Array):Boolean
        {
            return (element == arr[0]);
        }
        //清空内存=============-=============================
        public static function cleanupMemory():void
        { 
            try 
            { 
                (new LocalConnection).connect("foo"); 
                (new LocalConnection).connect("foo");
                (new LocalConnection).connect("foo");
                (new LocalConnection).connect("foo");
            } 
            catch( e:Error ) 
            { 
            } 
        } 
        //判断是否出屏
        public static function ifOutScreen( _x:Number, _y:Number, distance:Number = 50 ):Boolean
        {
            var tempPoint:Point = GameData.instance.personContainer.localToGlobal( new Point( _x, _y ) );
            if( tempPoint.x < -distance || tempPoint.x > GameData.instance.screenWidth + distance || tempPoint.y < - distance || tempPoint.y > GameData.instance.screenHeight + distance )
            {
                return true;
            }
            else
            {
                return false;
            }
        }
        //计算抛物线系数
        public static function calcuCurve( x1:Number, y1:Number, x2:Number, y2:Number, _curveNum:Number ):Array
        {
            //弯曲控制点
            var curveNum:int = _curveNum;
            //开炮点
            var tempP1:Point = new Point( x1, y1 );
            //目标位置
            var tempP2:Point = new Point( x2, y2 );
            //顶点位置
            var tempP3:Point = new Point( 0, Math.round(Math.min(tempP1.y,tempP2.y) + curveNum) );
            var b:Number = ( Math.sqrt((tempP1.y - tempP3.y)/(tempP2.y - tempP3.y)) * tempP2.x + tempP1.x) 
                             / ( 1 + Math.sqrt((tempP1.y - tempP3.y)/(tempP2.y - tempP3.y)) );
            var a:Number = (tempP1.y - tempP3.y) / ((tempP1.x - b) * (tempP1.x - b));
            var c:Number = tempP3.y;
            return [a, b, c];
        }
        public static function judgeInSceen( who:MovieClip ):Boolean
        {
            var tempPoint:Point = GameData.instance.personContainer.localToGlobal( new Point( who.x, who.y ) );
            if( tempPoint.x >= 0 && tempPoint.x <= GameData.instance.screenWidth && tempPoint.y >= 0 && tempPoint.y <= GameData.instance.screenHeight )
            {
                return true;
            }
            return false;
        }
        public static function hitTest( testMc:MovieClip, hitMc:MovieClip, type:uint ):Boolean
        {
            if( type == 1 )
            {
                return     testMc.hitTestObject( hitMc );
            }
            else
            {
                var tempPoint:Point = hitMc.parent.localToGlobal ( new Point( hitMc.x, hitMc.y ) );
                return testMc.hitTestPoint( tempPoint.x, tempPoint.y, true );
            }
        }
        //调整旋转角度（通用）
        static public function adjudgeRotation ( cannonRot:Number, tempRot:Number ):int
        {
            if ( cannonRot > 180 )
            {
                cannonRot -= 360;
            }
            else if ( cannonRot < -180 )
            {
                cannonRot += 360;
            }
            if ( ( cannonRot - tempRot > 180 && cannonRot - tempRot < 360 ) || ( cannonRot - tempRot > -180 && cannonRot - tempRot < 0 ) )
            {
                return 1;
            }
            else if ( ( cannonRot - tempRot < 180 && cannonRot - tempRot > 0 ) || ( cannonRot - tempRot < -180 && cannonRot - tempRot > -360 ) )
            {
                return -1;
            }
            else
            {
                return 1;
            }
        }
        //调整桢频
        public static function adjustFrame( frame:uint ):void
        {
            GameData.instance.Scen.stage.frameRate = frame;
        }
        //画矩形
        public static function drawRectangle( drawer:Sprite, _color:uint, _x:Number, _y:Number, _width:Number, _height:Number ):void
        {
            drawer.graphics.lineStyle(1)
            drawer.graphics.beginFill( _color );
            drawer.graphics.drawRect( _x, _y, _width, _height );
        }
        
        public static function getEmptyArea():Array
        {
            var tempArr:Array = new Array();
            for( var i:uint = 0; i < GameData.instance.widthNum - 1; i++ )
            {
                for( var k:uint = 0; k < GameData.instance.heightNum - 1; k++ )
                {
                    if( GameData.instance.mapArr[i][k] <= 0 )
                    {
                        tempArr.push([i, k])
                    }
                }
            }

            return tempArr;
        }

        public static function getUser():User
        {
            var currRoom:Room = SmartFoxClientSingleton.getInstance().smartFoxClient.gameRoom;
            var user:User = SmartFoxClientSingleton.getInstance().smartFoxClient.myself;
            return user;
        }
    }
}