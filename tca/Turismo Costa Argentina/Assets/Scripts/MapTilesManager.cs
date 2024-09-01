using UnityEngine;
using System.Collections.Generic;

public class MapTilesManager : MonoBehaviour {
    public GameObject singleRoadTile;
    public GameObject singleCurveRoadTile;
    public GameObject diagonal2x2RoadTile;
    public GameObject roadTilesetPrototype;
    private Dictionary<string, GameObject> tilesDictionary;
    private Dictionary<string, GameObject> roadTilesSetDictionary;

    public MapTilesManager()
    {
        tilesDictionary = new Dictionary<string,GameObject>();
        roadTilesSetDictionary = new Dictionary<string, GameObject>();
    }

    void Start() 
    {
        tilesDictionary.Add("single road", singleRoadTile);
        tilesDictionary.Add("single curve road", singleCurveRoadTile);
        tilesDictionary.Add("diagonal 2x2 road", diagonal2x2RoadTile);

        roadTilesSetDictionary.Add("basic straight road", createBasicStraightTileset());
        //roadTilesSetDictionary.Add("basic horizontal straight road", createHorizontalBasicStraightTileset());
        //roadTilesSetDictionary["basic horizontal straight road"].transform.position = new Vector3(-3f, -3f, 0.2f);
        roadTilesSetDictionary.Add("single curve straight road", createSingleCurveStraightTileset());
        roadTilesSetDictionary.Add("single left curve straight road", createSingleLeftCurveStraightTileset());
        roadTilesSetDictionary.Add("single diagonal straight road", createSingleDiagonalTileset());

        roadTilesSetDictionary["single curve straight road"].transform.position = new Vector3(-6f, 0f, 0.2f);
        roadTilesSetDictionary["single left curve straight road"].transform.position = new Vector3(-6f, -21f, 0.2f);

        roadTilesSetDictionary["single diagonal straight road"].transform.position = new Vector3(-6f, 42f, 0.2f);
        roadTilesSetDictionary["basic straight road"].transform.position = new Vector3(-6f, 21f, 0.2f);
    }

    public GameObject createSingleDiagonalTileset()
    {
        GameObject output = instantiateRoadTileset();
        for(int y = 0; y < 3; y++)
        {
            addTileToSet(output, instantiateTileByName("single road"), 3.5f, y + 0.5f, false, false, DirectionConstants.SUR_NORTE);
        }
        addTileToSet(output, instantiateTileByName("diagonal 2x2 road"), 4f, 4f, false, false, DirectionConstants.SUR_NORTE);
        for(int y = 5; y < 7; y++)
        {
            addTileToSet(output, instantiateTileByName("single road"), 4.5f, y + 0.5f, false, false, DirectionConstants.SUR_NORTE);
        }

        return output;
    }


    public GameObject createSingleCurveStraightTileset()
    {
        GameObject output = instantiateRoadTileset();
        for(int y = 0; y < 3; y++)
        {
            addTileToSet(output, instantiateTileByName("single road"), 3.5f, y + 0.5f, false, false, DirectionConstants.SUR_NORTE);
        }
        addTileToSet(output, instantiateTileByName("single curve road"), 3.5f, 3.5f, false, false, DirectionConstants.SUR_NORTE);
        addTileToSet(output, instantiateTileByName("single curve road"), 4.5f, 3.5f, false, false, DirectionConstants.NORTE_SUR);
        for(int y = 4; y < 7; y++)
        {
            addTileToSet(output, instantiateTileByName("single road"), 4.5f, y + 0.5f, false, false, DirectionConstants.SUR_NORTE);
        }

        return output;
    }

    public GameObject createSingleLeftCurveStraightTileset()
    {
        GameObject output = instantiateRoadTileset();
        for(int y = 0; y < 3; y++)
        {
            addTileToSet(output, instantiateTileByName("single road"), 4.5f, y + 0.5f, false, false, DirectionConstants.SUR_NORTE);
        }
        addTileToSet(output, instantiateTileByName("single curve road"), 4.5f, 3.5f, false, false,DirectionConstants.OESTE_ESTE);
        addTileToSet(output, instantiateTileByName("single curve road"), 3.5f, 3.5f, false, false, DirectionConstants.ESTE_OESTE);
        for(int y = 4; y < 7; y++)
        {
            addTileToSet(output, instantiateTileByName("single road"), 3.5f, y + 0.5f, false, false, DirectionConstants.SUR_NORTE);
        }

        return output;
    }

    public GameObject createBasicStraightTileset()
    {
        GameObject output = instantiateRoadTileset();
        for(int y = 0; y < 7; y++)
        {
            addTileToSet(output, instantiateTileByName("single road"), 3.5f, y + 0.5f, false, false, DirectionConstants.SUR_NORTE);
        }
        return output;
    }

    public GameObject createHorizontalBasicStraightTileset()
    {
        GameObject output = instantiateRoadTileset();
        for(int x = 0; x < 7; x++)
        {
            addTileToSet(output, instantiateTileByName("single road"), x + 0.5f, 3.5f, false, false, DirectionConstants.ESTE_OESTE);
        }
        return output;
    }



    public void addTileToSet(GameObject tileSet, GameObject tile, float positionX, float positionY, bool flippedX, bool flippedY, string direction)
    {
        RoadTilesSet roadTilesSet = tileSet.GetComponent<RoadTilesSet>();
        addTile(tileSet, tile, positionX, positionY, flippedX, flippedY, direction);
    }

    /**
     * Cuidado que la posicion de botton left si hay rotacion o si hay flip cambia
     */
    public void addTile(GameObject tileSet, GameObject tile, float positionX, float positionY, bool flippedX, bool flippedY, string direction)
    {
        float sizeX = 3f; //make configurable
        float sizeY = 3f; //make configurable
        tile.transform.SetParent(tileSet.transform);

        float newX = positionX * sizeX;
        float newY = positionY * sizeY;

        tile.transform.localPosition = new Vector3(newX, newY, 0);

        float rotationAngle = MathUtils.GetRotationAngle(direction);
        tile.transform.localRotation = Quaternion.Euler(0, 0, rotationAngle);

        Vector3 localScale = tile.transform.localScale;
        localScale.x = flippedX ? -Mathf.Abs(localScale.x) : Mathf.Abs(localScale.x);
        localScale.y = flippedY ? -Mathf.Abs(localScale.y) : Mathf.Abs(localScale.y);
        tile.transform.localScale = localScale;
    }

    public GameObject instantiateTileByName(string tileName)
    {
        if(tilesDictionary.ContainsKey(tileName))
        {
            Vector3 position = new Vector3(0, 0, 0.2f);
            Quaternion rotation = Quaternion.identity;
            GameObject instantiatedPrefab = Instantiate(tilesDictionary[tileName], position, rotation);
            return instantiatedPrefab;
        }
        else
        {
            Debug.Log("no tiles with name " + tileName);
        }
        return null;
    }

    public GameObject instantiateRoadTileset()
    {
        Vector3 position = new Vector3(0, 0, 0.2f);
        Quaternion rotation = Quaternion.identity;
        GameObject instantiatedPrefab = Instantiate(roadTilesetPrototype, position, rotation);
        return instantiatedPrefab;
    }
}