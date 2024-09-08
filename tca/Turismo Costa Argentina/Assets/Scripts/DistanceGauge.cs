using UnityEngine;
using UnityEngine.UI;

public class DistanceGauge : MonoBehaviour
{
    public Slider distanceSlider;
    private float maxDistance = 100f;
    private float currentDistance;
	public GameObject characterManagerObject;
	public GameObject mapTilesManagerContainer;
	
	private MapTilesManager mapTilesManager;
	private CharactersManager charactersManager;

    void Start()
    {
        currentDistance = maxDistance;
		charactersManager = characterManagerObject.GetComponent<CharactersManager>();
		mapTilesManager = mapTilesManagerContainer.GetComponent<MapTilesManager>();
    }

    void Update()
    {
		maxDistance = mapTilesManager.mapFinalY;
		Transform playerTransform = charactersManager.getMainPlayerTransform();
        currentDistance = Mathf.Abs(maxDistance - playerTransform.position.y);
        distanceSlider.value = currentDistance / maxDistance;
    }
}
