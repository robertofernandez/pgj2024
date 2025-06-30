package ar.com.sodhium.util.displaymanagement.displaystate {
    /**
    * Maps an object state to a frame range or a next frame selection criteria.
    *
    * @author Roberto G. Fernandez
    */
    public interface DisplayState {
        function getNextFrame():Number;
        function reset():void;
    }
}
