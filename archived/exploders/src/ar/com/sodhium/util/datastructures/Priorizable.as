package ar.com.sodhium.util.datastructures {

    /**
     * Element able to be priorized.
     * 
     * @author Roberto G. Fernandez
     */
    public interface Priorizable {
        function hasLowerPriorityThan(priorizable:Priorizable):Boolean;
    }
}