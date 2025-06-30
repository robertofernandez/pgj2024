package com.willdom.games.bomberman.position.maps
{
    import com.willdom.util.math.ArrayRandomizer;
    
    import flash.geom.Point;

    public class PointsBlock
    {
        
        private var _blocks:Array = new Array();
        private var pointsMap:Object;
        private var _w:int;
        private var _h:int;
        private var middlePoint:Point;
        private var referenceAngle:Number;
        
        public function PointsBlock(w:int, h:int)
        {
            _w = w;
            _h = h;
            middlePoint = new Point(_w/2, _h/2);
            referenceAngle = Math.atan2((middlePoint.y - .5) , (middlePoint.x - .5));
            pointsMap = new Object();
        }
        
        public function getRandomPoint(seed:int):Point {
            var arrayRandomizer:ArrayRandomizer = new ArrayRandomizer();
            return arrayRandomizer.getRandomElementFor(_blocks, seed) as Point;
        }
        
        public function getFixedPoint():Point{
            return _blocks[0];
        }
        
        public function contains(point:Point):Boolean {
            return pointsMap[point.x+"_"+point.y] != null;
        }

        public function get points():Array
        {
            return _blocks;
        }

        public function addPoint(point:Point):void
        {
            _blocks.push(point);
            pointsMap[point.x+"_"+point.y] = true;
        }
        
        public function get size():int
        {
            return _blocks.length;
        }
        
        public function get distance():Number
        {
            var tempPoint:Point = new Point(_blocks[0].x + .5, _blocks[0].y + .5);
            var _distance:Number = Point.distance(middlePoint, tempPoint);
            return Math.ceil(_distance);
        }
        
        public function get angle():Number
        {
            var yDif:Number = middlePoint.y - (_blocks[0].y + .5);
            var xDif:Number = middlePoint.x - (_blocks[0].x + .5);
            var _angle:Number = Math.atan2(yDif,xDif);
            _angle -= referenceAngle;
            if(_angle < 0){
                _angle += Math.PI * 2;
            }
            return Math.ceil(_angle);
        }
        
        public function get orderInMatrix():Number
        {
            var position: Number = (_blocks[0].x * _blocks[0].y) + _blocks[0].y;
            return position;
        }
        
        public function get ySorting():Number
        {
            return _blocks[0].y + .5;
        }
    }
}