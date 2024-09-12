using UnityEngine;

public abstract class RoadMapZoneDescriptor:MapZoneDescriptor
{
    public float SubtilesAmount { get; set; }
    public float SubtilesSize { get; set;}

    public RoadMapZoneDescriptor(float centerX, float centerY, string typeName, float subtilesAmount, float subtilesSize): base(centerX, centerY, typeName)
    {
        SubtilesAmount = subtilesAmount;
        SubtilesSize = subtilesSize;
    }

    public override Vector2 GeometricCenter()
    {
        return new Vector2(CenterX + SubtilesAmount * SubtilesSize /2, CenterY + SubtilesAmount * SubtilesSize /2);
    }
}