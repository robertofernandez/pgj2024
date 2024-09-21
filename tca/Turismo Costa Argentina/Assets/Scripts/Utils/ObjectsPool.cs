using System.Collections.Generic;
using UnityEngine;

namespace Sodhium.Utils
{
    // Clase que contiene el GameObject y su ID único
    public class GameObjectContainer
    {
        public GameObject GameObject { get; private set; }
        public int ID { get; private set; }
        
        public GameObjectContainer(GameObject gameObject, int id)
        {
            GameObject = gameObject;
            ID = id;
        }
    }

    // Clase para gestionar el pool de objetos
    public class ObjectsPool : MonoBehaviour
    {
        // Diccionario que almacenará los pools de cada tipo de objeto
        private Dictionary<string, Queue<GameObjectContainer>> pools;
        
        // Lista de objetos en uso con su ID para poder liberar los elementos
        private Dictionary<int, GameObjectContainer> inUse;

        // Contador para generar un ID único para cada objeto
        private int idCounter = 0;

        private void Awake()
        {
            pools = new Dictionary<string, Queue<GameObjectContainer>>();
            inUse = new Dictionary<int, GameObjectContainer>();
        }

        // Método para crear un pool de n objetos a partir de un prototipo
        public void CreatePool(GameObject prototype, string name, int n)
        {
            if (!pools.ContainsKey(name))
            {
                pools[name] = new Queue<GameObjectContainer>();
            }

            for (int i = 0; i < n; i++)
            {
                GameObject obj = Instantiate(prototype);
                obj.SetActive(false); // Desactiva el objeto por defecto
                int id = idCounter++;
                pools[name].Enqueue(new GameObjectContainer(obj, id));
            }
        }

        // Método para obtener un objeto del pool
        public GameObjectContainer PickElement(string name)
        {
            if (pools.ContainsKey(name) && pools[name].Count > 0)
            {
                GameObjectContainer container = pools[name].Dequeue();
                container.GameObject.SetActive(true); // Activa el objeto
                inUse[container.ID] = container; // Lo marca como en uso
                return container;
            }
            return null; // No hay objetos disponibles
        }

        // Método para obtener un objeto del pool, creando uno nuevo si es necesario
        public GameObjectContainer PickElementDynamic(GameObject prototype, string name)
        {
            GameObjectContainer container = PickElement(name);

            // Si no hay disponibles, crear uno nuevo dinámicamente
            if (container == null)
            {
                GameObject obj = Instantiate(prototype);
                obj.SetActive(true);
                int id = idCounter++;
                container = new GameObjectContainer(obj, id);
                inUse[container.ID] = container;
            }

            return container;
        }

        // Método para liberar un objeto y devolverlo al pool
        public void FreeObject(int id)
        {
            if (inUse.ContainsKey(id))
            {
                GameObjectContainer container = inUse[id];
                container.GameObject.SetActive(false); // Desactiva el objeto
                pools[container.GameObject.name].Enqueue(container); // Lo devuelve al pool
                inUse.Remove(id); // Lo saca de la lista de objetos en uso
            }
        }
    }
}