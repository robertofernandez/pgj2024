using UnityEngine;
using System.Collections.Generic;

/**
 * TODO: combine visual and logic creators / initializations
 * Road type 03
 */
public class SingleLeftCurveStraightRoadZoneDescriptor : RoadMapZoneDescriptor
{
    public SingleLeftCurveStraightRoadZoneDescriptor(float centerX, float centerY, float subtilesAmount, float subtilesSize) : base(centerX, centerY, MapZoneDescriptor.SINGLE_LEFT_CURVE_STRAIGHT_ROAD, subtilesAmount, subtilesSize)
    {
        
    }

    public override Dictionary<string, List<Vector2>> GenerateSignificantPointsByDirection()
    {
        Dictionary<string, List<Vector2>> output = new Dictionary<string, List<Vector2>>();
        List<Vector2> southNorth = new List<Vector2>();
        southNorth.Add(new Vector2(GeometricCenter().x + SubtilesSize / 4f, BottomLeft().y));
        southNorth.Add(new Vector2(GeometricCenter().x + SubtilesSize / 4f, BottomLeft().y + SubtilesSize * 3f));
/*        List<Vector2> internalArc = MathUtils.GeneratePointsOnArc(new Vector2(GeometricCenter().x + SubtilesSize / 2, BottomLeft().y + SubtilesSize * 3.5f), SubtilesSize / 4, 180, 90, 4);
        foreach(Vector2 point in internalArc)
        {
            southNorth.Add(point);
        }
        List<Vector2> externalArc = MathUtils.GeneratePointsOnArc(new Vector2(GeometricCenter().x + SubtilesSize / 2, BottomLeft().y + SubtilesSize * 4.5f), SubtilesSize / 4, 270, 360, 4);
        foreach(Vector2 point in internalArc)
        {
            southNorth.Add(point);
        }*/
        southNorth.Add(new Vector2(GeometricCenter().x + SubtilesSize + SubtilesSize / 4, TopLeft().y));
        output[DirectionConstants.SUR_NORTE] = southNorth;
        List<Vector2> northSouth = new List<Vector2>();
        northSouth.Add(new Vector2(GeometricCenter().x - SubtilesSize / 4, TopLeft().y));
        northSouth.Add(new Vector2(GeometricCenter().x - SubtilesSize / 4, BottomLeft().y));
        output[DirectionConstants.NORTE_SUR] = northSouth;

        return output;
    }
}