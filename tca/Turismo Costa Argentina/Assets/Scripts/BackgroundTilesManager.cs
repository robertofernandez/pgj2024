using UnityEngine;

public class BackgroundTilesManager : MonoBehaviour {
    public GameObject backgroundTile;
    public BackgroundTileContainer[,] tilesSet;
    float currentCenterX = 0;
    float currentCenterY = 0;

	void Start() 
    {
        Debug.Log("Background Tiles Manager Started");

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
        updatePositions();
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