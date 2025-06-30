package com.willdom.util.math
{

    public class ArrayRandomizer
    {
        public function ArrayRandomizer()
        {
        }

        public function getNewOrderFor(array:Array, seed:int):Array
        {
            var outputArray:Array = new Array();
            var tempArray:Array = array.concat();

            var randomizer:Random = new Random(seed);
            while(tempArray.length > 0){
                var nextIndex:int = int(randomizer.getRandomBounded(0, tempArray.length-1));
                outputArray.push(tempArray[nextIndex]);
                tempArray.splice(nextIndex, 1);
            }
            return outputArray;
        }
        
        public function getRandomIndexFor(array:Array, seed:int):int
        {
            var randomizer:Random = new Random(seed);
            return int(randomizer.getRandomBounded(0, array.length-1));    
        }
        
        public function getRandomElementFor(array:Array, seed:int):Object
        {
            return array[getRandomIndexFor(array, seed)];    
        }
    }
}