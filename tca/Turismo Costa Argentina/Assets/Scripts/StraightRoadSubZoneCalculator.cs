using UnityEngine;
using System.Collections.Generic;

public class StraightRoadSubZoneCalculator:RoadMapSubZoneCalculator
{
    public float OFFSET = 0.4f;
    public override bool OnRoad(float x, float y, float sizeX, float sizeY, float BottomLeftX, float BottomLeftY)
    {
        return x > LeftPoint(BottomLeftX) && x < RightPoint(BottomLeftX + sizeX) && y > BottomLeftY && y < (BottomLeftY + y);
    }

    public override List<Vector2> GetInterestPoints(float sizeX, float sizeY, float BottomLeftX, float BottomLeftY)
    {
        List<Vector2> output = new List<Vector2>();
        output.Add(new Vector2(LeftPoint(BottomLeftX), BottomLeftY));
        output.Add(new Vector2(RightPoint(BottomLeftX + sizeX), BottomLeftY));
        output.Add(new Vector2(LeftPoint(BottomLeftX), BottomLeftY + sizeY));
        output.Add(new Vector2(RightPoint(BottomLeftX + sizeX), BottomLeftY + sizeY));
        return output;
    }

    public float LeftPoint(float baseX)
    {
        return baseX + OFFSET;
    }

    public float RightPoint(float baseX)
    {
        return baseX - OFFSET;
    }

}