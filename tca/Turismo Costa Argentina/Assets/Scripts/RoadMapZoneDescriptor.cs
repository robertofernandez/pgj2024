using UnityEngine;
using System.Collections.Generic;

public abstract class RoadMapZoneDescriptor:MapZoneDescriptor
{
    public float SubtilesAmount { get; set; }
    public float SubtilesSize { get; set;}
    private Dictionary<string, List<Vector2>> significantPointsByDirection;
    public abstract Dictionary<string, List<Vector2>> GenerateSignificantPointsByDirection();

    public RoadMapZoneDescriptor(float centerX, float centerY, string typeName, float subtilesAmount, float subtilesSize): base(centerX, centerY, typeName)
    {
        SubtilesAmount = subtilesAmount;
        SubtilesSize = subtilesSize;
        significantPointsByDirection = GenerateSignificantPointsByDirection();
    }

    public List<Vector2> GetSignificantPointsInRoad(string direction)
    {
        if(significantPointsByDirection.ContainsKey(direction))
        {
            return significantPointsByDirection[direction];
        }
        return new List<Vector2>();
    }

    public override Vector2 GeometricCenter()
    {
        return new Vector2(CenterX + SubtilesAmount * SubtilesSize /2, CenterY + SubtilesAmount * SubtilesSize /2);
    }

    public override Vector2 BottomLeft()
    {
        return new Vector2(CenterX, CenterY);
    }
    
    public override Vector2 BottomRight()
    {
        return new Vector2(CenterX + SubtilesAmount * SubtilesSize, CenterY);
    }

    public override Vector2 TopLeft()
    {
        return new Vector2(CenterX, CenterY + SubtilesAmount * SubtilesSize);
    }

    public override Vector2 TopRight()
    {
        return new Vector2(CenterX + SubtilesAmount * SubtilesSize, CenterY + SubtilesAmount * SubtilesSize);
    }
}