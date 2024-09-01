using UnityEngine;
using System.Collections.Generic;

public class RoadTilesManager : MonoBehaviour {
    public GameObject singleRoadTile;
    public GameObject singleCurveRoadTile;

    private Dictionary<string, GameObject> tilesDictionary;

    public RoadTilesManager()
    {
        tilesDictionary = new Dictionary<string,GameObject>();
        tilesDictionary.Add("single road", singleRoadTile);
        tilesDictionary.Add("single curve road", singleCurveRoadTile);
    }


    public GameObject instantiateTileByName(string tileName, float x, float y)
    {
        if(tilesDictionary.ContainsKey(tileName))
        {
            Vector3 position = new Vector3(x, y, 0.2f);
            Quaternion rotation = Quaternion.identity;
            GameObject instantiatedPrefab = Instantiate(tilesDictionary[tileName], position, rotation);
            return instantiatedPrefab;
        }
        return null;
    }
}