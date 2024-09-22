using UnityEngine;
using System.Collections.Generic;

public class VerticalComposedRoadMapZoneDescriptor:RoadMapZoneDescriptor
{
    public override void BuildSubZones()
    {
        
    }

    public override string TypeName()
    {
        return "Vertical Composed Road Zone";
    }


    public override Dictionary<string, List<Vector2>> GenerateSignificantPointsByDirection()
    {
        return new Dictionary<string, List<Vector2>>();
    }

    public VerticalComposedRoadMapZoneDescriptor(float centerX, float centerY, string typeName, float subtilesAmount, float subtilesSize): base(centerX, centerY, typeName, subtilesAmount, subtilesSize)
    {

    }
}