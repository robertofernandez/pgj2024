using System;
using System.Collections.Generic;
using System.Collections.Concurrent;
using System.Linq;

    public class EventsService : IEventsService
    {
        private class HandlerEntry
        {
            public Guid Id { get; }
            public IEventHandler Handler { get; }

            public HandlerEntry(Guid id, IEventHandler handler)
            {
                Id = id;
                Handler = handler;
            }
        }

        private readonly ConcurrentDictionary<GameEvent.EventType, List<HandlerEntry>> _listeners;
        private readonly ConcurrentDictionary<GameEvent.EventType, ConcurrentQueue<HandlerEntry>> _volatileListeners;

        public EventsService()
        {
            _listeners = new ConcurrentDictionary<GameEvent.EventType, List<HandlerEntry>>();
            _volatileListeners = new ConcurrentDictionary<GameEvent.EventType, ConcurrentQueue<HandlerEntry>>();
        }

        // -------- Registro con IEventHandler --------
        public Guid Register(GameEvent.EventType eventName, IEventHandler handler)
        {
            var id = Guid.NewGuid();

            if (!_listeners.ContainsKey(eventName))
            {
                _listeners[eventName] = new List<HandlerEntry>();
            }
            _listeners[eventName].Add(new HandlerEntry(id, handler));

            return id;
        }

        public Guid VolatileRegister(GameEvent.EventType eventName, IEventHandler handler)
        {
            var id = Guid.NewGuid();

            if (!_volatileListeners.ContainsKey(eventName))
            {
                _volatileListeners[eventName] = new ConcurrentQueue<HandlerEntry>();
            }
            _volatileListeners[eventName].Enqueue(new HandlerEntry(id, handler));

            return id;
        }

        // -------- Registro con Action --------
        public Guid Register(GameEvent.EventType eventName, Action<Dictionary<string, object>> action)
        {
            return Register(eventName, new ActionEventHandler(action));
        }

        public Guid VolatileRegister(GameEvent.EventType eventName, Action<Dictionary<string, object>> action)
        {
            return VolatileRegister(eventName, new ActionEventHandler(action));
        }

        // -------- Unregister --------
        public bool Unregister(GameEvent.EventType eventName, Guid handlerId)
        {
            var removed = false;

            if (_listeners.TryGetValue(eventName, out var list))
            {
                removed |= list.RemoveAll(entry => entry.Id == handlerId) > 0;
            }

            if (_volatileListeners.TryGetValue(eventName, out var queue))
            {
                // Para colas concurrentes, hay que reconstruir sin el handler
                var newQueue = new ConcurrentQueue<HandlerEntry>(
                    queue.Where(entry => entry.Id != handlerId)
                );
                _volatileListeners[eventName] = newQueue;
                removed = true;
            }

            return removed;
        }

        // -------- Disparador --------
        public void Trigger(GameEvent.EventType eventName, Dictionary<string, object> parameters)
        {
            if (_listeners.TryGetValue(eventName, out var regularHandlers))
            {
                foreach (var entry in regularHandlers.ToList())
                {
                    entry.Handler.Execute(parameters);
                }
            }

            if (_volatileListeners.TryGetValue(eventName, out var volatileHandlers))
            {
                while (volatileHandlers.TryDequeue(out var entry))
                {
                    entry.Handler.Execute(parameters);
                }
            }
        }

        // -------- Adaptador para Action --------
        private class ActionEventHandler : IEventHandler
        {
            private readonly Action<Dictionary<string, object>> _action;

            public ActionEventHandler(Action<Dictionary<string, object>> action)
            {
                _action = action ?? throw new ArgumentNullException(nameof(action));
            }

            public void Execute(Dictionary<string, object> @params)
            {
                _action(@params);
            }
        }
    }
