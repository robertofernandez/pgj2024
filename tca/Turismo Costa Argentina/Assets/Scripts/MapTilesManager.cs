using UnityEngine;
using System.Collections.Generic;

public class MapTilesManager : MonoBehaviour {
    public GameObject singleRoadTile;
    public GameObject singleCurveRoadTile;
    public GameObject diagonal2x2RoadTile;
    public GameObject roadTilesetPrototype;

    public GameObject shoreTile_1_4;
    public GameObject shoreTile_4_1;
    public GameObject shoreTile_2_3;
    public GameObject shoreTile_3_2;
    public GameObject shoreTile_2_5;
    public GameObject shoreTile_5_2;
    public GameObject shoreTile_4_3;
    public GameObject shoreTile_3_4;

    public GameObject baseSeaTile;

    private Dictionary<string, GameObject> tilesDictionary;
    private Dictionary<string, GameObject> roadTilesSetDictionary;
    private Dictionary<string, GameObject> shoreTilesSetDictionary;
    private GameObject[] allTilesets;
    private GameObject[] shoreTilesets;

    private GameObject[] baseSeaTilesets;
    private GameObject[] baseSeaTilesets2;

    public GameObject charactersManagerGameObject;
    public CharactersManager charactersManager;

    private float completeTileSetSize = 21f * 1.5f;
    private float tileSetsAmount = 8f;
    private float shoreTileSetsAmount = 8f;
    private float completeShoreTileSetSize = 7f;
    private float baseSeaTilesetsAmount = 3f;
    private float baseSeaTilesetSize = 7f;

    private float roadTileSizeX = 3f * 1.5f;
    private float roadTileSizeY = 3f * 1.5f;

    public MapTilesManager()
    {
        tilesDictionary = new Dictionary<string,GameObject>();
        roadTilesSetDictionary = new Dictionary<string, GameObject>();
        shoreTilesSetDictionary = new Dictionary<string, GameObject>();
    }

    void Start() 
    {
        charactersManager = charactersManagerGameObject.GetComponent<CharactersManager>();

        tilesDictionary.Add("single road", singleRoadTile);
        tilesDictionary.Add("single curve road", singleCurveRoadTile);
        tilesDictionary.Add("diagonal 2x2 road", diagonal2x2RoadTile);

        float initialX = -22f;
        float initialY = -21f;

        float tileSizeY = 21 * 1.5f;

        //roadTilesSetDictionary.Add("basic horizontal straight road", createHorizontalBasicStraightTileset());
        roadTilesSetDictionary.Add("basic straight road", createBasicStraightTileset());
        roadTilesSetDictionary.Add("basic straight road2", createBasicStraightTileset());
        roadTilesSetDictionary.Add("single curve straight road", createSingleCurveStraightTileset());
        roadTilesSetDictionary.Add("single left curve straight road", createSingleLeftCurveStraightTileset());
        roadTilesSetDictionary.Add("single diagonal straight road", createSingleDiagonalTileset());
        roadTilesSetDictionary.Add("single left diagonal straight road", createSingleLeftDiagonalTileset());
        roadTilesSetDictionary.Add("single diagonal straight road2", createSingleDiagonalTileset());
        roadTilesSetDictionary.Add("single left diagonal straight road2", createSingleLeftDiagonalTileset());

        roadTilesSetDictionary["basic straight road"].transform.position = new Vector3(initialX, initialY+=tileSizeY, 0.2f);
        roadTilesSetDictionary["single curve straight road"].transform.position = new Vector3(initialX, initialY+=tileSizeY, 0.2f);
        roadTilesSetDictionary["single left diagonal straight road"].transform.position = new Vector3(initialX, initialY+=tileSizeY, 0.2f);
        roadTilesSetDictionary["basic straight road2"].transform.position = new Vector3(initialX, initialY+=tileSizeY, 0.2f);
        roadTilesSetDictionary["single diagonal straight road"].transform.position = new Vector3(initialX, initialY+=tileSizeY, 0.2f);
        roadTilesSetDictionary["single left curve straight road"].transform.position = new Vector3(initialX, initialY+=tileSizeY, 0.2f);
        roadTilesSetDictionary["single diagonal straight road2"].transform.position = new Vector3(initialX, initialY+=tileSizeY, 0.2f);
        roadTilesSetDictionary["single left diagonal straight road2"].transform.position = new Vector3(initialX, initialY+=tileSizeY, 0.2f);

        allTilesets = new GameObject[8];

        allTilesets[0] = roadTilesSetDictionary["basic straight road"];
        allTilesets[1] = roadTilesSetDictionary["single curve straight road"];
        allTilesets[2] = roadTilesSetDictionary["single left diagonal straight road"];
        allTilesets[3] = roadTilesSetDictionary["basic straight road2"];
        allTilesets[4] = roadTilesSetDictionary["single diagonal straight road"];
        allTilesets[5] = roadTilesSetDictionary["single left curve straight road"];
        allTilesets[6] = roadTilesSetDictionary["single diagonal straight road2"];
        allTilesets[7] = roadTilesSetDictionary["single left diagonal straight road2"];

        shoreTilesSetDictionary.Add("1-4", createShoreTile_1_4());
        shoreTilesSetDictionary.Add("4-1", createShoreTile_4_1());
        shoreTilesSetDictionary.Add("2-3", createShoreTile_2_3());
        shoreTilesSetDictionary.Add("3-2", createShoreTile_3_2());
        shoreTilesSetDictionary.Add("3-4", createShoreTile_3_4());
        shoreTilesSetDictionary.Add("4-3", createShoreTile_4_3());
        shoreTilesSetDictionary.Add("2-5", createShoreTile_2_5());
        shoreTilesSetDictionary.Add("5-2", createShoreTile_5_2());

        initialX = 6f;
        initialY = -7f;
        shoreTilesSetDictionary["3-4"].transform.position = new Vector3(initialX, initialY+=completeShoreTileSetSize, -0.2f);
        shoreTilesSetDictionary["4-1"].transform.position = new Vector3(initialX, initialY+=completeShoreTileSetSize, -0.2f);
        shoreTilesSetDictionary["1-4"].transform.position = new Vector3(initialX, initialY+=completeShoreTileSetSize, -0.2f);
        shoreTilesSetDictionary["4-3"].transform.position = new Vector3(initialX, initialY+=completeShoreTileSetSize, -0.2f);
        shoreTilesSetDictionary["3-2"].transform.position = new Vector3(initialX, initialY+=completeShoreTileSetSize, -0.2f);
        shoreTilesSetDictionary["2-5"].transform.position = new Vector3(initialX, initialY+=completeShoreTileSetSize, -0.2f);
        shoreTilesSetDictionary["5-2"].transform.position = new Vector3(initialX, initialY+=completeShoreTileSetSize, -0.2f);
        shoreTilesSetDictionary["2-3"].transform.position = new Vector3(initialX, initialY+=completeShoreTileSetSize, -0.2f);

        shoreTilesets = new GameObject[8];
        int i = 0;
        shoreTilesets[i++] = shoreTilesSetDictionary["3-4"];
        shoreTilesets[i++] = shoreTilesSetDictionary["4-1"];
        shoreTilesets[i++] = shoreTilesSetDictionary["1-4"];
        shoreTilesets[i++] = shoreTilesSetDictionary["4-3"];
        shoreTilesets[i++] = shoreTilesSetDictionary["3-2"];
        shoreTilesets[i++] = shoreTilesSetDictionary["2-5"];
        shoreTilesets[i++] = shoreTilesSetDictionary["5-2"];
        shoreTilesets[i++] = shoreTilesSetDictionary["2-3"];

        initialX = 13f;
        initialY = -7f;

        baseSeaTilesets = new GameObject[3];
        baseSeaTilesets[0] = createBaseSeaTile();
        baseSeaTilesets[1] = createBaseSeaTile();
        baseSeaTilesets[2] = createBaseSeaTile();
        baseSeaTilesets[0].transform.position = new Vector3(initialX, initialY+=baseSeaTilesetSize, -0.2f);
        baseSeaTilesets[1].transform.position = new Vector3(initialX, initialY+=baseSeaTilesetSize, -0.2f);
        baseSeaTilesets[2].transform.position = new Vector3(initialX, initialY+=baseSeaTilesetSize, -0.2f);

        initialX = 20f;
        initialY = -7f;

        baseSeaTilesets2 = new GameObject[3];
        baseSeaTilesets2[0] = createBaseSeaTile();
        baseSeaTilesets2[1] = createBaseSeaTile();
        baseSeaTilesets2[2] = createBaseSeaTile();
        baseSeaTilesets2[0].transform.position = new Vector3(initialX, initialY+=baseSeaTilesetSize, -0.2f);
        baseSeaTilesets2[1].transform.position = new Vector3(initialX, initialY+=baseSeaTilesetSize, -0.2f);
        baseSeaTilesets2[2].transform.position = new Vector3(initialX, initialY+=baseSeaTilesetSize, -0.2f);

    }

    void FixedUpdate()
    {
        updateBaseTilesPosition();
    }

    public void updateBaseTilesPosition()
    {
        if(charactersManager.getMainPlayerTransform() != null)
        {
            float characterX = charactersManager.getMainPlayerTransform().position.x;
            float characterY = charactersManager.getMainPlayerTransform().position.y;
            updateGenericTilesSetPositions(allTilesets, tileSetsAmount, completeTileSetSize, characterX, characterY);
            updateGenericTilesSetPositions(shoreTilesets, shoreTileSetsAmount, completeShoreTileSetSize, characterX, characterY);
            updateGenericTilesSetPositions(baseSeaTilesets, baseSeaTilesetsAmount, baseSeaTilesetSize, characterX, characterY);
            updateGenericTilesSetPositions(baseSeaTilesets2, baseSeaTilesetsAmount, baseSeaTilesetSize, characterX, characterY);
        }
        else
        {
            Debug.Log("no player transform");
        }
    }

    /**
     * Made to update vertical single set updates based ob character position. Should be used only for those kind of repetitive elements.
     */
    public void updateGenericTilesSetPositions(GameObject[] tileSets, float tileSetsAmount, float completeTileSetSize, float characterX, float characterY)
    {
            for(int i=0; i < tileSetsAmount; i++)
            {
                Vector3 position = tileSets[i].transform.position;
                float distance = Mathf.Abs(position.y - characterY);
                float maxDist = (completeTileSetSize * tileSetsAmount) / 2;
                if(distance > maxDist) 
                {
                    //Debug.Log("moving");
                    float newY = 0;
                    if (position.y > characterY)
                    {
                        newY = position.y - completeTileSetSize * tileSetsAmount;
                    }
                    else
                    {
                        newY = position.y + completeTileSetSize * tileSetsAmount;
                    }
                    tileSets[i].transform.position = new Vector3(position.x, newY, position.z);
                }
                /*
                else
                {
                    Debug.Log("OK, " + distance + " <= " + maxDist);
                }*/
            }
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

    public GameObject createSingleLeftDiagonalTileset()
    {
        GameObject output = instantiateRoadTileset();
        for(int y = 0; y < 3; y++)
        {
            addTileToSet(output, instantiateTileByName("single road"), 4.5f, y + 0.5f, false, false, DirectionConstants.SUR_NORTE);
        }
        addTileToSet(output, instantiateTileByName("diagonal 2x2 road"), 4f, 4f, false, true, DirectionConstants.SUR_NORTE);
        for(int y = 5; y < 7; y++)
        {
            addTileToSet(output, instantiateTileByName("single road"), 3.5f, y + 0.5f, false, false, DirectionConstants.SUR_NORTE);
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
        tile.transform.SetParent(tileSet.transform);

        float newX = positionX * roadTileSizeX;
        float newY = positionY * roadTileSizeY;

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

    public GameObject instantiateObject(GameObject gameObject)
    {
        Vector3 position = new Vector3(0, 0, 0.2f);
        Quaternion rotation = Quaternion.identity;
        GameObject instantiatedPrefab = Instantiate(gameObject, position, rotation);
        return instantiatedPrefab;
    }

    public GameObject createBaseSeaTile()
    {
        return instantiateObject(baseSeaTile);
    }

    public GameObject createShoreTile_1_4()
    {
        return instantiateObject(shoreTile_1_4);
    }

    public GameObject createShoreTile_4_1()
    {
        return instantiateObject(shoreTile_4_1);
    }

    public GameObject createShoreTile_2_3()
    {
        return instantiateObject(shoreTile_2_3);
    }

    public GameObject createShoreTile_3_2()
    {
        return instantiateObject(shoreTile_3_2);
    }

    public GameObject createShoreTile_4_3()
    {
        return instantiateObject(shoreTile_4_3);
    }

    public GameObject createShoreTile_3_4()
    {
        return instantiateObject(shoreTile_3_4);
    }

    public GameObject createShoreTile_2_5()
    {
        return instantiateObject(shoreTile_2_5);
    }

    public GameObject createShoreTile_5_2()
    {
        return instantiateObject(shoreTile_5_2);
    }

}