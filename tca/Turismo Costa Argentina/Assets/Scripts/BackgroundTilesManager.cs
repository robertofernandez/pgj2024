using UnityEngine;

public class BackgroundTilesManager : MonoBehaviour {
    public GameObject backgroundTile;
    public BackgroundTileContainer[,] tilesSet;
    float currentCenterX = 0;
    float currentCenterY = 0;
    public GameObject charactersManagerGameObject;
    public CharactersManager charactersManager;

	void Start() 
    {
        Debug.Log("Background Tiles Manager Started");

        charactersManager = charactersManagerGameObject.GetComponent<CharactersManager>();

        tilesSet = new BackgroundTileContainer[3, 3];

        int cid = 1;
        for (int i = 0; i < 3; i++)
        {
            for (int j = 0; j < 3; j++)
            {
                GameObject tile = instantiateBackgroundTile(0f,0f);
                BackgroundTileContainer current = new BackgroundTileContainer(tile, cid++);
                tilesSet[i, j] = current;
            }
        }
    }

    void FixedUpdate()
    {
        if(charactersManager.getMainPlayerTransform() != null)
        {
            float characterX = charactersManager.getMainPlayerTransform().position.x;
            float characterY = charactersManager.getMainPlayerTransform().position.y;
            updateGrid(characterX, characterY);
        }

        updatePositions();
    }

    void updateGrid(float characterX, float characterY)
    {
        BackgroundTileContainer center = null;
        int swapI = 0;
        int swapJ = 0;
        for (int i = 0; i < 3; i++)
        {
            for (int j = 0; j < 3; j++)
            {
                BackgroundTileContainer current = tilesSet[i, j];
                if(MathUtils.contains(current, characterX, characterY))
                {
                    center = current;
                    currentCenterX = center.centerX();
                    currentCenterY = center.centerY();
                    swapI = i;
                    swapJ = j;
                    break;
                }
            }
        }
        if (center != null)
        {
            BackgroundTileContainer temp = tilesSet[1, 1];
            tilesSet[1, 1] = center;
            tilesSet[swapI, swapJ] = temp;
        }
    }

    void updatePositions()
    {
        for (int i = 0; i < 3; i++)
        {
            for (int j = 0; j < 3; j++)
            {
                BackgroundTileContainer current = tilesSet[i, j];
                current.setPosition(i, j, currentCenterX, currentCenterY);
            }
        }
    }

    public GameObject instantiateBackgroundTile(float x, float y) {
        Vector3 position = new Vector3(x, y, 0.1f);
        Quaternion rotation = Quaternion.identity;
        GameObject instantiatedPrefab = Instantiate(backgroundTile, position, rotation);
        return instantiatedPrefab;
    }
}