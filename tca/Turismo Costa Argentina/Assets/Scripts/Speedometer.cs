using UnityEngine;
using TMPro; // Importar el espacio de nombres de TextMeshPro

public class Speedometer : MonoBehaviour
{
    public TextMeshProUGUI speedText; // Cambiado a TextMeshProUGUI
    public GameObject charactersManagerContainer;
    private CharactersManager manager;

    void Start()
    {
        manager = charactersManagerContainer.GetComponent<CharactersManager>();
    }

    void Update()
    {
        if(manager != null)
        {
            float translatedSpeed = manager.GetCurrentSpeed() * 11f;
            speedText.text = translatedSpeed.ToString("F0") + " km/h";
        }       
    }
}
