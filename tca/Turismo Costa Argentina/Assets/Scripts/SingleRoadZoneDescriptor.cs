using UnityEngine;
using System.Collections.Generic;

public class SingleRoadZoneDescriptor : RoadMapZoneDescriptor
{
    public SingleRoadZoneDescriptor(float centerX, float centerY, float subtilesAmount, float subtilesSize) : base(centerX, centerY, MapZoneDescriptor.SINGLE_ROAD, subtilesAmount, subtilesSize)
    {

    }

    public override string TypeName()
    {
        return "Straight Road";
    }

    public override void BuildSubZones()
    {
        AddSubZone(3, 6, 1, 1, new StraightRoadSubZoneCalculator(), "straight");
        AddSubZone(3, 5, 1, 1, new StraightRoadSubZoneCalculator(), "straight");
        AddSubZone(3, 4, 1, 1, new StraightRoadSubZoneCalculator(), "straight");
        AddSubZone(3, 3, 1, 1, new StraightRoadSubZoneCalculator(), "straight");
        AddSubZone(3, 2, 1, 1, new StraightRoadSubZoneCalculator(), "straight");
        AddSubZone(3, 1, 1, 1, new StraightRoadSubZoneCalculator(), "straight");
        AddSubZone(3, 0, 1, 1, new StraightRoadSubZoneCalculator(), "straight");
    }

    public override Dictionary<string, List<Vector2>> GenerateSignificantPointsByDirection()
    {
        Dictionary<string, List<Vector2>> output = new Dictionary<string, List<Vector2>>();
        List<Vector2> southNorth = new List<Vector2>();
        southNorth.Add(new Vector2(GeometricCenter().x + SubtilesSize / 4, BottomLeft().y));
        southNorth.Add(new Vector2(GeometricCenter().x + SubtilesSize / 4, TopLeft().y));
        output[DirectionConstants.SUR_NORTE] = southNorth;
        List<Vector2> northSouth = new List<Vector2>();
        northSouth.Add(new Vector2(GeometricCenter().x - SubtilesSize / 4, TopLeft().y));
        northSouth.Add(new Vector2(GeometricCenter().x - SubtilesSize / 4, BottomLeft().y));
        output[DirectionConstants.NORTE_SUR] = northSouth;

        return output;
    }
}