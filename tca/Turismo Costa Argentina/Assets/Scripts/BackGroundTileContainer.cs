using UnityEngine;

public class BackgroundTileContainer {
    public GameObject tile;
    public int id;

    public float currentX;
    public float currentY;

    public float width;
    public float height;

    public BackgroundTileContainer(GameObject tile, int id)
    {
        this.tile = tile;
        this.id = id;

        SpriteRenderer sr = tile.GetComponent<SpriteRenderer>();

        if (sr != null)
        {
            Vector2 size = sr.bounds.size;

            width = size.x;
            height = size.y;
            Debug.Log($"Ancho tile: {width}, Alto tile: {height}");
        }
        else
        {
            Debug.LogError("El GameObject no tiene un componente SpriteRenderer.");
        }
    }

    public void setPosition(int i, int j, float currentCenterX, float currentCenterY)
    {
        int x = i-1;
        int y = j-1;

        tile.transform.position = new Vector3(currentCenterX + x*width, currentCenterY + y*height, 0.1f);
    }
}