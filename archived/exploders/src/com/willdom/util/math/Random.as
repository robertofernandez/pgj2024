package com.willdom.util.math
{
    public class Random
    {
        
        private const MT:Array = new Array();
        private var index:int, _seed:int;
        /**
         * Get the seed currently in use
         */
        public function get seed():int {
            return _seed;
        }
        /**
         * Set the seed currently in use (resets state)
         */
        public function reset(a:int):void {
            if (a != _seed) {
                var i:int, b:int = MT[index = 0] = _seed = seed;
                while (++i < 624) b = (MT[i] = (1812433253 * b ^ ((b >>> 30) + i)) & 0xFFFFFFFF);
            }
        }
        /**
         * @param int: seed The seed number to use, using the same seed will get you the same results each time
         */
        public function Random(seed:int):void {
            var i:int, b:int = MT[0] = _seed = seed;
            while (++i < 624) b = (MT[i] = (1812433253 * b ^ ((b >>> 30) + i)) & 0xFFFFFFFF);
        }
        /**
         * extractNumber
         * @return Number: A number that is greater than or equal to zero and less than one
         */
        public function getRandom():Number {
            if (index == 0) generateNumbers();
            var y:int = MT[index];
            index = (index + 1) % 624;
            y ^= y >>> 11;
            y ^= (y << 7) & 2636928640;
            y ^= (y << 15) & 4022730752;
            return uint(y ^ (y >>> 18)) / (uint.MAX_VALUE + Number.MIN_VALUE);
        }
        
        /**
         * extractNumber
         * @return Number: A number that is greater than or equal to low and less or equal than high
         */
        public function getRandomBounded(low:int, high:int):int
        {
            return (Math.floor(getRandom() * (1 + high - low)) + low);
        }
        
        /**
         * extractUint
         * @return uint: An unsigned integer between 0 and uint.MAX_VALUE
         */
        public function extractUint():uint {
            if (index == 0) generateNumbers();
            var y:int = MT[index];
            index = (index + 1) % 624;
            y ^= y >>> 11;
            y ^= (y << 7) & 2636928640;
            y ^= (y << 15) & 4022730752;
            return (y ^ (y >>> 18));
        }
        /**
         * extractInt
         * @return int: An integer between int.MIN_VALUE and int.MAX_VALUE
         */
        public function extractInt():int {
            if (index == 0) generateNumbers();
            var y:int = MT[index];
            index = (index + 1) % 624;
            y ^= y >>> 11;
            y ^= (y << 7) & 2636928640;
            y ^= (y << 15) & 4022730752;
            return (y ^ (y >>> 18));
        }
        private function generateNumbers():void {
            var i:int, y:int;
            while (i < 623) {
                if ((y = (MT[i] & 2147483648) | (MT[(++i) % 624] & 2147483647)) & 1) {
                    MT[i] = (MT[(i + 396) % 624] ^ (y >>> 1)) ^ 2567483615;
                } else {
                    MT[i] = MT[(i + 396) % 624] ^ (y >>> 1);
                }
            }
        }
    }
}