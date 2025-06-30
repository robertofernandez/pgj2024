package com.willdom.util.sfs.structures
{
    import com.smartfoxserver.v2.entities.data.ISFSArray;
    import com.smartfoxserver.v2.entities.data.SFSArray;
    import com.smartfoxserver.v2.entities.data.SFSDataWrapper;

    public class ArrayConversion
    {
        public function ArrayConversion()
        {
        }

        public static function tupleOfIntsIsfsArrayToArray(isfsArray:ISFSArray):Array{
            var output:Array=new Array();
            for(var i:int=0;i<isfsArray.size();i++){
                output.push(isfsArray.getIntArray(i));
            }
            return output;
        }

        public static function tupleOfIntsArrayToIsfsArray(intsArray:Array):ISFSArray{
            var output:ISFSArray=new SFSArray();
            for(var i:int=0;i<intsArray.length;i++){
                output.addIntArray(intsArray[i]);
            }
            return output;
        }

        public static function tupleOfObjectsIsfsArrayToArray(isfsArray:ISFSArray):Array{
            var output:Array=new Array();
            for(var i:int=0;i<isfsArray.size();i++){
                var currentTuple:ISFSArray = isfsArray.getSFSArray(i);
                var currentTupleArray:Array = new Array();
                for(var j:int=0;j<currentTuple.size();j++){
                    currentTupleArray.push(currentTuple.getElementAt(i));
                }
                output.push(currentTupleArray);
            }
            return output;
        }
/*
        public static function tupleOfObjectsArrayToIsfsArray(objectsArray:Array):ISFSArray{
            var output:ISFSArray=new SFSArray();
            for(var i:int=0;i<objectsArray.length;i++){
                var currentTuple:ISFSArray = new SFSArray();
                var currentTupleArray:Array = objectsArray[i];
                for(var j:int=0;j<currentTupleArray.length;j++){
                    if(currentTupleArray[i] is String){
                        currentTuple.addUtfString(currentTupleArray[i]);
                    } else {
                        currentTuple.addInt(currentTupleArray[i]);
                    }
                    currentTupleArray.push(currentTuple.getElementAt(i));
                }
                output.addSFSArray(currentTuple);
            }
            return output;
        }
        */

    }
    
}