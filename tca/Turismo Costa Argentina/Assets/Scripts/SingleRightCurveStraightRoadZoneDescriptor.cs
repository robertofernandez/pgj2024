using UnityEngine;
using System.Collections.Generic;

/**
 * TODO: combine visual and logic creators / initializations
 * Road type 02
 */
public class SingleRightCurveStraightRoadZoneDescriptor : RoadMapZoneDescriptor
{
    public SingleRightCurveStraightRoadZoneDescriptor(float centerX, float centerY, float subtilesAmount, float subtilesSize) : base(centerX, centerY, MapZoneDescriptor.SINGLE_RIGHT_CURVE_STRAIGHT_ROAD, subtilesAmount, subtilesSize)
    {
        
    }

    public override Dictionary<string, List<Vector2>> GenerateSignificantPointsByDirection()
    {
        Dictionary<string, List<Vector2>> output = new Dictionary<string, List<Vector2>>();
        List<Vector2> southNorth = new List<Vector2>();
        southNorth.Add(new Vector2(GeometricCenter().x + SubtilesSize / 4, BottomLeft().y));
        List<Vector2> internalArc = MathUtils.GeneratePointsOnArc(new Vector2(GeometricCenter().x + SubtilesSize / 2, BottomLeft().y + SubtilesSize * 3f), SubtilesSize / 4, 180, 90, 4);
        foreach(Vector2 point in internalArc)
        {
            southNorth.Add(point);
        }
        List<Vector2> externalArc = MathUtils.GeneratePointsOnArc(new Vector2(GeometricCenter().x + SubtilesSize / 2, BottomLeft().y + SubtilesSize * 4f), SubtilesSize * 3 / 4, 270, 360, 4);
        foreach(Vector2 point in externalArc)
        {
            southNorth.Add(point);
        }
        southNorth.Add(new Vector2(GeometricCenter().x + SubtilesSize * 5 / 4, TopLeft().y));
        output[DirectionConstants.SUR_NORTE] = southNorth;

        //==============

        List<Vector2> northSouth = new List<Vector2>();
        northSouth.Add(new Vector2(GeometricCenter().x + SubtilesSize * 3 / 4, TopLeft().y));
        internalArc = MathUtils.GeneratePointsOnArc(new Vector2(GeometricCenter().x + SubtilesSize * 1 / 2, TopLeft().y - SubtilesSize * 3f), SubtilesSize / 4, 0, -90, 4);
        foreach(Vector2 point in internalArc)
        {
            northSouth.Add(point);
        }
        externalArc = MathUtils.GeneratePointsOnArc(new Vector2(GeometricCenter().x + SubtilesSize * 1 / 2, TopLeft().y - SubtilesSize * 4f), SubtilesSize * 3 / 4, 90, 180, 4);
        foreach(Vector2 point in externalArc)
        {
            northSouth.Add(point);
        }

        northSouth.Add(new Vector2(GeometricCenter().x - SubtilesSize * 1 / 4, BottomLeft().y));
        output[DirectionConstants.NORTE_SUR] = northSouth;

        return output;
    }
}