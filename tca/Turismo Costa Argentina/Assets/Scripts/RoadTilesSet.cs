using UnityEngine;
using System.Collections.Generic;

//FUTURE podemos agregar una lista de puntos de conexion Vector2Int

/**
 * Representa un tileset de 7x7 RoadTiles.
 */
public class RoadTilesSet : MonoBehaviour {
    public float sizeX;
    public float sizeY;

    public RoadTilesSet(float sizeX, float sizyY)
    {
        this.sizeX = sizeX;
        this.sizeY = sizyY;
    }
}