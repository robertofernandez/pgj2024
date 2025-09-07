using System.Collections.Generic;

    public interface IEventHandler
    {
        void Execute(Dictionary<string, object> @params);
    }