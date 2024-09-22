using UnityEngine;
using System.Collections.Generic;

public abstract class RoadMapSubZoneCalculator
{
    public abstract bool OnRoad(float x, float y, float sizeX, float sizeY, float BottomLeftX, float BottomLeftY);

    public virtual List<Vector2> GetInterestPoints(float sizeX, float sizeY, float BottomLeftX, float BottomLeftY) 
    {
        return new List<Vector2>();
    }
}