using UnityEngine;
using System.Collections.Generic;

public class PowerMeterController : MonoBehaviour
{
    [Header("Configuración")]
    [Range(0, 5)]
    public int currentPower = 0; // Potencia actual (0-5)

    [Header("Referencias de los Chunks")]
    [Tooltip("Arrastra aquí los chunks en ORDEN. El primero es el chunk 1, el último el chunk 5.")]
    public List<GameObject> powerChunks = new List<GameObject>(); // Lista de los chunks

    void Start()
    {
        // Actualiza el medidor al iniciar con el valor por defecto
        UpdatePowerMeter();
    }

    // Método PÚBLICO para cambiar la potencia desde otros scripts
    public void SetPower(int powerLevel)
    {
        // Aseguramos que el valor esté entre 0 y el número total de chunks
        currentPower = Mathf.Clamp(powerLevel, 0, powerChunks.Count);
        UpdatePowerMeter();
    }

    // Método que actualiza la visibilidad de los chunks basado en el orden de la lista
    private void UpdatePowerMeter()
    {
        // Itera a través de todos los chunks en la lista
        for (int i = 0; i < powerChunks.Count; i++)
        {
            // Verifica que la referencia al chunk no sea nula para evitar errores
            if (powerChunks[i] != null)
            {
                // La magia está aquí: El ÍNDICE de la lista define el número de chunk.
                // Si el índice (i) es menor que la potencia actual, debe estar ACTIVO.
                powerChunks[i].SetActive(i < currentPower);
            }
        }
    }

    // Este método se ejecuta en el Editor cuando se cambia un valor en el Inspector.
    // Es útil para ver los cambios en tiempo real mientras diseñas.
    private void OnValidate()
    {
        // Si la aplicación está jugando (en Play Mode), actualiza el medidor visualmente.
        if (Application.isPlaying)
        {
            UpdatePowerMeter();
        }
    }
}