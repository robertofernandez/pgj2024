using System.Collections;
using System.Collections.Generic;

    public class GameEvent
    {
        public enum EventType
        {
            gameTimer,
            playerDied,
            abilityPicked,
            log,
            keyboardUpdate,
            gamepadUpdate,
            gameClockTick
        }
    
        public EventType eventType { get; private set; }

        public Dictionary<string, object> @params { get; private set; }

        public GameEvent(EventType eventType, Dictionary<string, object> @params)
        {
            this.eventType = eventType;
            this.@params = @params;
        }
    }
