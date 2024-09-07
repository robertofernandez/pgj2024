using System.Collections;
using UnityEngine;

public class CharactersManager : MonoBehaviour {
    public GameObject mainCamera;

    public int MAX_SPEED = 16;

    public GameObject fuelUI;
    public GameObject basicCar;
	public GameObject explosion;

    public Transform mainPlayerTransform;
    //private Transform[,] teamsMembersTransforms;
    //private Character[,] characters;

    public int acceleration = 0;
	
	public int fuelUnits;
	
	public string status = "initialized";

    public float currentSpeed = 0;

	void Start() 
    {
        Debug.Log("Characters Manager Started");
        //teamsMembersTransforms = new Transform[teamsAmount,charactersAmount];
        //characters = new Character[teamsAmount,charactersAmount];

        GameObject playerCar = instantiatePlayerCar(-5.15f, 6f);
        mainPlayerTransform = playerCar.transform;
    }

    public void playerCarExplosion()
    {
        Transform t = mainPlayerTransform;
        instantiateExplosion(t.position.x, t.position.y + 0.9f);
    }

    public GameObject instantiatePlayerCar(float x, float y) {
        Vector3 position = new Vector3(x, y, 0);
        Quaternion rotation = Quaternion.identity;
        GameObject instantiatedPrefab = Instantiate(basicCar, position, rotation);
        instantiatedPrefab.GetComponent<Character>().SetManager(this);
        return instantiatedPrefab;
    }

    public GameObject instantiateExplosion(float x, float y) {
        Vector3 position = new Vector3(x, y, 0);
        Quaternion rotation = Quaternion.identity;
        GameObject instantiatedPrefab = Instantiate(explosion, position, rotation);
        return instantiatedPrefab;
    }

    void Update()
    {
        if(status == "game over")
        {
            return;
        }

        if (Input.GetKeyDown(KeyCode.Keypad1) || Input.GetKeyDown(KeyCode.Alpha1))
        {
            Debug.Log("Current Weapon: Banana");
        }
        if (Input.GetKeyDown(KeyCode.Keypad2) || Input.GetKeyDown(KeyCode.Alpha2))
        {
            Debug.Log("Current Weapon: Baseball bat");
        }
        if (Input.GetKeyDown(KeyCode.Keypad3) || Input.GetKeyDown(KeyCode.Alpha3))
        {
            Debug.Log("Current Weapon: Frozen Banana");
        }
        if (Input.GetKeyDown(KeyCode.Tab))
        {
            Debug.Log("TAB");
        }

		if(Input.GetKey(KeyCode.Space))
		{
            Debug.Log("NITRO!");
		}
    }
	
	public Transform getMainPlayerTransform()
	{
		return mainPlayerTransform;
	}

    public void SetCurrentSpeed(float currentSpeed)
    {
        this.currentSpeed = currentSpeed;
    }

    public float GetCurrentSpeed()
    {
        return currentSpeed;
    }
}