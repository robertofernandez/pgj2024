using UnityEngine;
using System.Collections.Generic;

public class MapTilesManager : MonoBehaviour {
    public GameObject startLine;
    public GameObject finishLine;

    public GameObject barrelPrototype;
    public GameObject dividerTop;
    public GameObject dividerBottom;

    public GameObject singleRoadTile;
    public GameObject singleCurveStraightRoadTile;
    public GameObject diagonal2x2RoadTile;
    public GameObject roadTilesetPrototype;
    public GameObject locationMarkPrototype;
    public GameObject dotMarkerPrototype;
    public GameObject whiteDotMarkerPrototype;
    public GameObject testIceCreamsPrototye;
    public GameObject whiteTestIceCreamsPrototye;

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
    private List<GameObject> allDecoElements;
    private List<GameObject> allDecoElementsRight;

    private GameObject[] locationMarks;
    private GameObject[] dotMarkers;
    private GameObject[] whiteDotMarkers;
    private GameObject[] testIceCreams;
    private GameObject[] whiteTestIceCreams;

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

    private float initialMapX = -22f;
    private float initialMapY = -21f * 1.5f;

    private float roadSubtiles = 7f;

    private float tileSizeY = 21 * 1.5f;

    private float initialX = -22f;
    private float initialY = -21f * 1.5f;

    public GameObject casa0;
    public GameObject casa1;
    public GameObject casa2;
    public GameObject casa3;
    public GameObject casa4;
    public GameObject casa5;
    public GameObject casa6;
    public GameObject casa7;

    public GameObject piedra;
    public GameObject sombrilla_silla;

    public GameObject arbol1;
    public GameObject arbol2;

    private MapLogicManager mapLogicManager;

    public float mapFinalY = 1500;

    int locationMarksNumber = 20;
    int dotMarkersNumber = 200;

    public bool carOnRoad = false;
    public string currentSubDescriptor = "";

    public string currentZoneDescriptor = "";

    public string currentZoneIndex = "";

    public MapTilesManager()
    {
        tilesDictionary = new Dictionary<string,GameObject>();
        roadTilesSetDictionary = new Dictionary<string, GameObject>();
        shoreTilesSetDictionary = new Dictionary<string, GameObject>();
        mapLogicManager = new MapLogicManager(tileSizeY, initialY);
    }

    void Start() 
    {
        allDecoElements = new List<GameObject>();
        allDecoElements.Add(instantiateObject(casa0));
        allDecoElements.Add(instantiateObject(arbol1));
        allDecoElements.Add(instantiateObject(casa1));
        allDecoElements.Add(instantiateObject(arbol2));
        allDecoElements.Add(instantiateObject(casa2));
        allDecoElements.Add(instantiateObject(arbol1));
        allDecoElements.Add(instantiateObject(casa3));
        allDecoElements.Add(instantiateObject(arbol2));
        allDecoElements.Add(instantiateObject(casa4));
        allDecoElements.Add(instantiateObject(arbol1));
        allDecoElements.Add(instantiateObject(casa5));
        allDecoElements.Add(instantiateObject(arbol2));
        allDecoElements.Add(instantiateObject(casa6));
        allDecoElements.Add(instantiateObject(arbol1));
        allDecoElements.Add(instantiateObject(casa7));
        allDecoElements.Add(instantiateObject(arbol2));
        allDecoElements.Add(instantiateObject(casa0));
        allDecoElements.Add(instantiateObject(arbol1));
        allDecoElements.Add(instantiateObject(casa1));
        allDecoElements.Add(instantiateObject(arbol2));
        allDecoElements.Add(instantiateObject(casa2));
        allDecoElements.Add(instantiateObject(arbol1));
        allDecoElements.Add(instantiateObject(casa3));
        allDecoElements.Add(instantiateObject(arbol2));
        allDecoElements.Add(instantiateObject(casa4));
        allDecoElements.Add(instantiateObject(arbol1));
        allDecoElements.Add(instantiateObject(casa5));
        allDecoElements.Add(instantiateObject(arbol2));
        allDecoElements.Add(instantiateObject(casa6));
        allDecoElements.Add(instantiateObject(arbol1));
        allDecoElements.Add(instantiateObject(casa7));
        allDecoElements.Add(instantiateObject(arbol2));
        allDecoElements.Add(instantiateObject(casa0));
        allDecoElements.Add(instantiateObject(arbol1));
        allDecoElements.Add(instantiateObject(casa1));
        allDecoElements.Add(instantiateObject(arbol2));
        allDecoElements.Add(instantiateObject(casa2));
        allDecoElements.Add(instantiateObject(arbol1));
        allDecoElements.Add(instantiateObject(casa3));
        allDecoElements.Add(instantiateObject(arbol2));
        allDecoElements.Add(instantiateObject(casa4));
        allDecoElements.Add(instantiateObject(arbol1));
        allDecoElements.Add(instantiateObject(casa5));
        allDecoElements.Add(instantiateObject(arbol2));
        allDecoElements.Add(instantiateObject(casa6));
        allDecoElements.Add(instantiateObject(arbol1));
        allDecoElements.Add(instantiateObject(casa7));
        allDecoElements.Add(instantiateObject(arbol2));

        allDecoElementsRight = new List<GameObject>();

        for(int dre = 0; dre < 20;dre++)
        {
            allDecoElementsRight.Add(instantiateObject(piedra));
            allDecoElementsRight.Add(instantiateObject(piedra));
            allDecoElementsRight.Add(instantiateObject(sombrilla_silla));
            allDecoElementsRight.Add(instantiateObject(piedra));
            allDecoElementsRight.Add(instantiateObject(piedra));
            allDecoElementsRight.Add(instantiateObject(arbol1));
            allDecoElementsRight.Add(instantiateObject(piedra));
            allDecoElementsRight.Add(instantiateObject(piedra));
            allDecoElementsRight.Add(instantiateObject(arbol2));
            allDecoElementsRight.Add(instantiateObject(piedra));
        }

        initializeGenericDecoPositions(allDecoElements, -15, 0, 2);
        initializeGenericDecoPositions(allDecoElementsRight, 2, 0, 1);

        //TODO make configurable
        int totalTilesSetInMap = 50;

        float finalY = 1400f;
        mapFinalY = finalY;
        //float finalY = 400f;

        charactersManager = charactersManagerGameObject.GetComponent<CharactersManager>();

        //GameObject playerCar = instantiatePlayerCar(-5.15f, 6f);
        startLine.transform.position = new Vector3(-6.24f, 7.72f, 0.2f);

        tilesDictionary.Add("single road", singleRoadTile);
        tilesDictionary.Add("single curve road", singleCurveStraightRoadTile);
        tilesDictionary.Add("diagonal 2x2 road", diagonal2x2RoadTile);

        //roadTilesSetDictionary.Add("basic horizontal straight road", createHorizontalBasicStraightTileset());
        roadTilesSetDictionary.Add("basic straight road", createBasicStraightTileset());
        roadTilesSetDictionary.Add("basic straight road2", createBasicStraightTileset());
        roadTilesSetDictionary.Add("single curve straight road", createSingleCurveStraightTileset());
        roadTilesSetDictionary.Add("single left curve straight road", createSingleLeftCurveStraightTileset());
        roadTilesSetDictionary.Add("single diagonal straight road", createSingleDiagonalTileset());
        roadTilesSetDictionary.Add("single left diagonal straight road", createSingleLeftDiagonalTileset());
        roadTilesSetDictionary.Add("single diagonal straight road2", createSingleDiagonalTileset());
        roadTilesSetDictionary.Add("single left diagonal straight road2", createSingleLeftDiagonalTileset());

		float currentY = initialY;

        roadTilesSetDictionary["basic straight road"].transform.position = new Vector3(initialX, currentY, 0.2f);
        mapLogicManager.AddOrderedDescriptor(currentY, new SingleRoadZoneDescriptor(initialX, currentY, roadSubtiles, roadTileSizeX));
		currentY+=tileSizeY;
        roadTilesSetDictionary["single curve straight road"].transform.position = new Vector3(initialX, currentY, 0.2f);
        mapLogicManager.AddOrderedDescriptor(currentY, new SingleRightCurveStraightRoadZoneDescriptor(initialX, currentY, roadSubtiles, roadTileSizeX));
		currentY+=tileSizeY;
        roadTilesSetDictionary["single left diagonal straight road"].transform.position = new Vector3(initialX, currentY, 0.2f);
        mapLogicManager.AddOrderedDescriptor(currentY, new SingleLeftDiagonalStraightRoadZoneDescriptor(initialX, currentY, roadSubtiles, roadTileSizeX));
		currentY+=tileSizeY;
        roadTilesSetDictionary["basic straight road2"].transform.position = new Vector3(initialX, currentY, 0.2f);
        mapLogicManager.AddOrderedDescriptor(currentY, new SingleRoadZoneDescriptor(initialX, currentY, roadSubtiles, roadTileSizeX));
		currentY+=tileSizeY;
        roadTilesSetDictionary["single diagonal straight road"].transform.position = new Vector3(initialX, currentY, 0.2f);
        mapLogicManager.AddOrderedDescriptor(currentY, new SingleRightDiagonalStraightRoadZoneDescriptor(initialX, currentY, roadSubtiles, roadTileSizeX));
		currentY+=tileSizeY;
        roadTilesSetDictionary["single left curve straight road"].transform.position = new Vector3(initialX, currentY, 0.2f);
        mapLogicManager.AddOrderedDescriptor(currentY, new SingleLeftCurveStraightRoadZoneDescriptor(initialX, currentY, roadSubtiles, roadTileSizeX));
		currentY+=tileSizeY;
        roadTilesSetDictionary["single diagonal straight road2"].transform.position = new Vector3(initialX, currentY, 0.2f);
        mapLogicManager.AddOrderedDescriptor(currentY, new SingleRightDiagonalStraightRoadZoneDescriptor(initialX, currentY, roadSubtiles, roadTileSizeX));
		currentY+=tileSizeY;
        roadTilesSetDictionary["single left diagonal straight road2"].transform.position = new Vector3(initialX, currentY, 0.2f);
        mapLogicManager.AddOrderedDescriptor(currentY, new SingleLeftDiagonalStraightRoadZoneDescriptor(initialX, currentY, roadSubtiles, roadTileSizeX));
		currentY+=tileSizeY;

        for(int k = 0; k < totalTilesSetInMap; k++)
        {
            mapLogicManager.AddOrderedDescriptor(currentY, new SingleRoadZoneDescriptor(initialX, currentY, roadSubtiles, roadTileSizeX));
			currentY+=tileSizeY;
            mapLogicManager.AddOrderedDescriptor(currentY, new SingleRightCurveStraightRoadZoneDescriptor(initialX, currentY, roadSubtiles, roadTileSizeX));
			currentY+=tileSizeY;
            mapLogicManager.AddOrderedDescriptor(currentY, new SingleLeftDiagonalStraightRoadZoneDescriptor(initialX, currentY, roadSubtiles, roadTileSizeX));
			currentY+=tileSizeY;
            mapLogicManager.AddOrderedDescriptor(currentY, new SingleRoadZoneDescriptor(initialX, currentY, roadSubtiles, roadTileSizeX));
			currentY+=tileSizeY;
            mapLogicManager.AddOrderedDescriptor(currentY, new SingleRightDiagonalStraightRoadZoneDescriptor(initialX, currentY, roadSubtiles, roadTileSizeX));
			currentY+=tileSizeY;
            mapLogicManager.AddOrderedDescriptor(currentY, new SingleLeftCurveStraightRoadZoneDescriptor(initialX, currentY, roadSubtiles, roadTileSizeX));
			currentY+=tileSizeY;
            mapLogicManager.AddOrderedDescriptor(currentY, new SingleRightDiagonalStraightRoadZoneDescriptor(initialX, currentY, roadSubtiles, roadTileSizeX));
			currentY+=tileSizeY;
            mapLogicManager.AddOrderedDescriptor(currentY, new SingleLeftDiagonalStraightRoadZoneDescriptor(initialX, currentY, roadSubtiles, roadTileSizeX));
			currentY+=tileSizeY;
        }

        Debug.Log("Max index in map: " + mapLogicManager.GetMaxIndex());
        Debug.Log("Max y in map: " + mapLogicManager.GetMaxY());

        //FIXME make configurable
        drawDebugMarkers2();

        MapZoneDescriptor finalTilesetDescriptor = mapLogicManager.GetMapZoneDescriptorOfTypeSurrounding(MapZoneDescriptor.SINGLE_ROAD, finalY);

        finishLine.transform.position = new Vector3(finalTilesetDescriptor.GeometricCenter().x, finalTilesetDescriptor.CenterY, 0.2f);
        //FIXME: CHECK WHY
        //finishLine.transform.position = new Vector3(-6.24f, finalTilesetDescriptor.CenterY, 0.2f);

        mapFinalY = finalTilesetDescriptor.CenterY;

        for(int barrelNumber = 1; barrelNumber < 10; barrelNumber++)
        {
            float barrelY = (float) barrelNumber * completeTileSetSize * tileSetsAmount;
            MapZoneDescriptor tilesetDescriptor = mapLogicManager.GetMapZoneDescriptorOfTypeSurrounding(MapZoneDescriptor.SINGLE_ROAD, barrelY);
            GameObject barrelObject = instantiateObject(barrelPrototype);
            Barrel barrel = barrelObject.GetComponent<Barrel>();
            barrel.characterManager = charactersManager;
            //Debug.Log("putting a barrel near to " + barrelY + "(" +tilesetDescriptor.CenterY + ")");
            barrel.transform.position = new Vector3(-6.24f, tilesetDescriptor.CenterY, 0.2f);

            barrelObject = instantiateObject(barrelPrototype);
            barrel = barrelObject.GetComponent<Barrel>();
            barrel.characterManager = charactersManager;
            //TODO hacer algo random
            barrel.transform.position = new Vector3(-7.24f, tilesetDescriptor.CenterY + 2f, 0.2f);

            barrelObject = instantiateObject(barrelPrototype);
            barrel = barrelObject.GetComponent<Barrel>();
            barrel.characterManager = charactersManager;
            barrel.transform.position = new Vector3(-5.5f, tilesetDescriptor.CenterY + 2.5f, 0.2f);
        }

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
        float characterX = charactersManager.getMainPlayerTransform().position.x;
        float characterY = charactersManager.getMainPlayerTransform().position.y;

        RoadMapZoneDescriptor roadMapZoneDescriptor = (RoadMapZoneDescriptor) mapLogicManager.GetDescriptor(characterY);
        if(roadMapZoneDescriptor != null)
        {
            dividerTop.transform.position = new Vector3(roadMapZoneDescriptor.GeometricCenter().x, roadMapZoneDescriptor.TopLeft().y, 0.2f);
            dividerBottom.transform.position = new Vector3(roadMapZoneDescriptor.GeometricCenter().x, roadMapZoneDescriptor.BottomLeft().y, 0.2f);

            currentZoneDescriptor = roadMapZoneDescriptor.GetDebugDescription();
            currentZoneIndex = "" + roadMapZoneDescriptor.IndexInLogic;
            RoadMapSubZoneDescriptor descriptor = roadMapZoneDescriptor.GetSubZoneAt(characterX, characterY);
            if(descriptor == null)
            {
                currentSubDescriptor = "No descriptor";
            }
            else
            {
                currentSubDescriptor = descriptor.GetDebugDescription();
            }
            bool nowOnRoad = roadMapZoneDescriptor.OnRoad(characterX, characterY);
            if(carOnRoad != nowOnRoad)
            {
                carOnRoad = nowOnRoad;
                if(carOnRoad)
                {
                    Debug.Log("Entered road");
                }
                else
                {
                    Debug.Log("Out of road");
                }
            }
        }
        else
        {
            currentZoneDescriptor = "No descriptor";
        }
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

    public void drawDebugMarkers()
    {
        locationMarks = new GameObject[locationMarksNumber];
        for(int i=0;i<locationMarksNumber;i++)
        {
            locationMarks[i] = instantiateObject(locationMarkPrototype);
        }

        dotMarkers = new GameObject[dotMarkersNumber];
        testIceCreams = new GameObject[dotMarkersNumber];

        whiteDotMarkers = new GameObject[dotMarkersNumber];
        whiteTestIceCreams = new GameObject[dotMarkersNumber];

        for(int i=0; i<dotMarkersNumber; i++)
        {
            dotMarkers[i] = instantiateObject(dotMarkerPrototype);
            testIceCreams[i] = instantiateObject(testIceCreamsPrototye);
            whiteDotMarkers[i] = instantiateObject(whiteDotMarkerPrototype);
            whiteTestIceCreams[i] = instantiateObject(whiteTestIceCreamsPrototye);
        }

        int j = 0;
        int k = 0;
        int m = 0;

        int p = 0;
        int q = 0;

        //string printedDirection = DirectionConstants.SUR_NORTE;
        //string printedDirection = DirectionConstants.NORTE_SUR;

        for(int i=-1; i<20; i++)
        {
            RoadMapZoneDescriptor descriptor = (RoadMapZoneDescriptor)mapLogicManager.GetDescriptorAt(i);
            if( j < locationMarksNumber)
            {
                locationMarks[j++].transform.position = new Vector3(descriptor.GeometricCenter().x, descriptor.GeometricCenter().y, locationMarks[0].transform.position.z);

                if(i%2 == 0)
                {
                    foreach (Vector2 point in descriptor.GetSignificantPointsInRoad(DirectionConstants.SUR_NORTE))
                    {
                        dotMarkers[k++].transform.position = new Vector3(point.x , point.y, locationMarks[0].transform.position.z);
                    }
                    foreach (Vector2 point in descriptor.GetSignificantPointsInRoad(DirectionConstants.NORTE_SUR))
                    {
                        testIceCreams[m++].transform.position = new Vector3(point.x , point.y, testIceCreams[0].transform.position.z);
                    }
                }
                else
                {
                    foreach (Vector2 point in descriptor.GetSignificantPointsInRoad(DirectionConstants.SUR_NORTE))
                    {
                        whiteDotMarkers[p++].transform.position = new Vector3(point.x , point.y, locationMarks[0].transform.position.z);
                    }
                    foreach (Vector2 point in descriptor.GetSignificantPointsInRoad(DirectionConstants.NORTE_SUR))
                    {
                        whiteTestIceCreams[q++].transform.position = new Vector3(point.x , point.y, testIceCreams[0].transform.position.z);
                    }
                }

                /*
                dotMarkers[k++].transform.position = new Vector3(descriptor.BottomLeft().x , descriptor.BottomLeft().y, locationMarks[0].transform.position.z);
                dotMarkers[k++].transform.position = new Vector3(descriptor.TopLeft().x , descriptor.TopLeft().y, locationMarks[0].transform.position.z);
                dotMarkers[k++].transform.position = new Vector3(descriptor.BottomRight().x , descriptor.BottomRight().y, locationMarks[0].transform.position.z);
                dotMarkers[k++].transform.position = new Vector3(descriptor.TopRight().x , descriptor.TopRight().y, locationMarks[0].transform.position.z);
                */
            }
        }
    }

    public void drawDebugMarkers2()
    {
        dotMarkers = new GameObject[dotMarkersNumber];

        for(int i=0; i<dotMarkersNumber; i++)
        {
            dotMarkers[i] = instantiateObject(dotMarkerPrototype);
        }

        int k = 0;

        for(int i=-1; i<20; i++)
        {
            RoadMapZoneDescriptor descriptor = (RoadMapZoneDescriptor)mapLogicManager.GetDescriptorAt(i);
            if( k < dotMarkersNumber)
            {
                foreach (Vector2 point in descriptor.GetInterestPoints())
                {
                    if( k < dotMarkersNumber)
                    {
                        dotMarkers[k++].transform.position = new Vector3(point.x , point.y, dotMarkers[0].transform.position.z);
                    }
                }
            }
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

    /**
     * TODO: combine visual and logic creators / initializations
     * Road type 02
     */
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

    /**
     * TODO: combine visual and logic creators / initializations
     * Road type 03
     */
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

    public void initializeGenericDecoPositions(List<GameObject> elements, float initialX, float initialY, float rangeX)
    {
        float currentY = initialY;
        foreach(GameObject element in elements)
        {
            Vector3 position = element.transform.position;
            currentY = currentY + Random.Range(2, 6);
            float newX = initialX + Random.Range(-1 * rangeX, rangeX);
            element.transform.position = new Vector3(newX, currentY, position.z);
        }
    }


}