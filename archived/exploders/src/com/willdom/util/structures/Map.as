package com.willdom.util.structures
{
    public class Map
    {
        private var valuesMap:Object;

        public function Map()
        {
            valuesMap = new Object;
        }
        
        /**
         * Removes all mappings from this map (optional operation).
         */
        public function clear():void{
            valuesMap = new Object;
        }
        
        /**
         * Returns true if this map contains a mapping for the specified key.
         */
        public function containsKey(key:Object): Boolean{
            return valuesMap[String(key)] != null;
        }
        
        /**
         * Returns true if this map maps one or more keys to the specified value.
         */
        public function containsValue(value:Object): Boolean {
            for each(var element:Object in valuesMap){
                if(element == value){
                    return true;
                }
            }
            return false;
        }
        
        /**
         * Returns the value to which this map maps the specified key.
         */
        public function get(key:Object): Object{
            return valuesMap[String(key)];
        }

        /**
         * Returns true if this map contains no key-value mappings.
         */
        public function isEmpty(): Boolean{
            return false;
        }
        
        /**
         * Returns a set view of the keys contained in this map.
         */
        public function keySet(): Array {
            return null;
        }
        
        /**
         * Associates the specified value with the specified key in this map (optional operation).
         */
        public function put(key:Object, value:Object): Object{
            valuesMap[String(key)] = value;
            return value;
        }
        
        /**
         * Copies all of the mappings from the specified map to this map (optional operation).
         */
        public function putAll(t:Map): void{
            
        }
        
        /**
         * Removes the mapping for this key from this map if it is present (optional operation).
         */
        public function remove(key:Object): Object {
            var output:Object = valuesMap[String(key)];
            valuesMap[String(key)] = null;
            return output;
        }
        
        /**
         * Returns the number of key-value mappings in this map.
         */
        public function size(): int{
            return 0;
        }
        
        /**
         * Returns a collection view of the values contained in this map.
         */
        public function values(): Array {
            return null;
        }
    }
}