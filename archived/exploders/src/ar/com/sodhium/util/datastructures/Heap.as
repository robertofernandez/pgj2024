package ar.com.sodhium.util.datastructures {

    /**
     * Heap (priority queue).
     * 
     * @author Roberto G. Fernandez
     */
    public class Heap {
        private var elements:Array;

        public function Heap():void {
            elements = new Array();
        }

        public function addElement(element:Priorizable):void {
            elements.push(element);
            restoreQueueFromEnd();
        }

        public function pop():Priorizable {
            var returnElement:Priorizable = elements[0] as Priorizable;
            if (elements.length == 1) {
                return elements.pop() as Priorizable;
            }
            elements[0] = elements.pop();
            restoreQueueFromStart();
            return returnElement;
        }

        public function peek():Priorizable {
            return elements[0] as Priorizable;
        }

        public function isEmpty():Boolean {
            return !elements.length>0;
        }

        private function restoreQueueFromEnd() :void {
            for (var currentIndex:Number = elements.length - 1; currentIndex > 0; ) {
                var parentIndex:Number = Math.floor((currentIndex + 1) / 2 - 1);
                var currenElement:Priorizable = elements[currentIndex] as Priorizable;
                var parentElement:Priorizable = elements[parentIndex] as Priorizable;
                if (currenElement.hasLowerPriorityThan(parentElement)) {
                    return;
                }
                swapIndexes(currentIndex, parentIndex);
                currentIndex = parentIndex;
            }
        }

        private function restoreQueueFromStart() :void {
            for (var currentIndex:Number = 0; currentIndex < elements.length; ) {
                var leftSonIndex:Number = (currentIndex + 1) * 2 -1;
                var rightSonIndex:Number = (currentIndex+1)*2;
                var currenElement:Priorizable = elements[currentIndex] as Priorizable;
                var leftSon:Priorizable = elements[leftSonIndex] as Priorizable;
                var rightSon:Priorizable = elements[rightSonIndex] as Priorizable;
                var swappingSon:Priorizable;
                var swappingIndex:Number;
                if(leftSon==null){
                    return;
                }
                if (rightSon==null || rightSon.hasLowerPriorityThan(leftSon)) {
                    swappingIndex = leftSonIndex;
                    swappingSon = leftSon;
                } else {
                    swappingIndex = rightSonIndex;
                    swappingSon = rightSon;

                }
                if (swappingSon.hasLowerPriorityThan(currenElement)) {
                    return;
                }
                swapIndexes(currentIndex, swappingIndex);
                currentIndex = swappingIndex;
            }
        }

        private function swapIndexes(firstIndex:Number, secondIndex:Number) : void
        {
            var firstElement:Priorizable = elements[firstIndex] as Priorizable;
            elements[firstIndex] = elements[secondIndex];
            elements[secondIndex] = firstElement;
        }
        
        public function size():uint
        {
            return elements.length;
        }
    }
}