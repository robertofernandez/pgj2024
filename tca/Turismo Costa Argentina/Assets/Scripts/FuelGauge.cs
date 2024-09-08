using UnityEngine;
using UnityEngine.UI;

public class FuelGauge : MonoBehaviour
{
    public Slider fuelSlider;
    private float maxFuel = 5000f;
    private float currentFuel;
	public GameObject characterManagerObject;
	//public GameObject mapTilesManagerContainer;
	
	//private MapTilesManager mapTilesManager;
	private CharactersManager charactersManager;

    void Start()
    {
        currentFuel = maxFuel;
		charactersManager = characterManagerObject.GetComponent<CharactersManager>();
		//mapTilesManager = mapTilesManagerContainer.GetComponent<MapTilesManager>();
    }

    void Update()
    {
		currentFuel = charactersManager.character.fuelAmount;
        fuelSlider.value = currentFuel / maxFuel;
    }
}
