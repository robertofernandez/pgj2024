using System;
using System.Collections.Generic;

    public interface IEventsService
    {
        Guid Register(GameEvent.EventType eventName, IEventHandler handler);
        Guid VolatileRegister(GameEvent.EventType eventName, IEventHandler handler);

        Guid Register(GameEvent.EventType eventName, Action<Dictionary<string, object>> action);
        Guid VolatileRegister(GameEvent.EventType eventName, Action<Dictionary<string, object>> action);

        bool Unregister(GameEvent.EventType eventName, Guid handlerId);

        void Trigger(GameEvent.EventType eventName, Dictionary<string, object> parameters);
    }
