package ar.com.sodhium.util.displaymanagement.displaystate {

    /**
    * Maps an object state to a frame range. Also indicates whether that range has reach the end.
    *
    * @author Roberto G. Fernandez
    */
    public class FinalizableDisplayState implements DisplayState {
        protected var initialFrame : Number;
        protected var finalFrame : Number;
        protected var currentFrame : Number;

        public function FinalizableDisplayState (inputInitialFrame : Number, inputFinalFrame : Number) : void {
            initialFrame = inputInitialFrame;
            finalFrame = inputFinalFrame;
            currentFrame = initialFrame;
        }

        public function getNextFrame() : Number {
            var returnFrame : Number = currentFrame;
            if (currentFrame < finalFrame)
            {
                currentFrame ++;
            }
            return returnFrame;
        }

        public function isFinalized() : Boolean {
            return (currentFrame >= finalFrame);
        }
        
        public function reset():void
        {
            currentFrame = initialFrame;
        }
    }
}
