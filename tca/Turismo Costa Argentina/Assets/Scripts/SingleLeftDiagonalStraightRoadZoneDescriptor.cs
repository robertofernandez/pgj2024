using UnityEngine;
using System.Collections.Generic;
using Sodhium.Utils;
using Sodhium.Geometry;

public class SingleLeftDiagonalStraightRoadZoneDescriptor : RoadMapZoneDescriptor
{
    public SingleLeftDiagonalStraightRoadZoneDescriptor(float centerX, float centerY, float subtilesAmount, float subtilesSize) : base(centerX, centerY, MapZoneDescriptor.SINGLE_LEFT_DIAGONAL_STRAIGHT_ROAD, subtilesAmount, subtilesSize)
    {
        
    }

    public override Dictionary<string, List<Vector2>> GenerateSignificantPointsByDirection()
    {
        TilesetCoordinatesCalculator calculator = TilesUtils.GetTilesetCoordinatesCalculator(CenterX, CenterY, SubtilesAmount, SubtilesAmount, SubtilesSize, SubtilesSize);
        Dictionary<string, List<Vector2>> output = new Dictionary<string, List<Vector2>>();
        List<Vector2> southNorth = new List<Vector2>();
        southNorth.Add(calculator.GetTileCoordinatesHalfTileRight(RectangleAnchorValues.BOTTOM, RectangleAnchorValues.MIDDLE, 4, 0));

        Debug.Log("Descriptor for left diagonal at " + CenterX + ", " + CenterY);
        Debug.Log("Geometric center:  " + GeometricCenter().x + ", " + GeometricCenter().y);
        Debug.Log("Expected:  " + GeometricCenter().x + ", " + CenterY);
        Vector2 temp = calculator.GetTileCoordinatesHalfTileRight(RectangleAnchorValues.BOTTOM, RectangleAnchorValues.MIDDLE, 4, 0);
        Debug.Log("Got:  " + temp.x + ", " + temp.y);

        List<Vector2> externalArc = MathUtils.GeneratePointsOnArc(calculator.GetTileCoordinates(RectangleAnchorValues.TOP, RectangleAnchorValues.LEFT, 4, 2), SubtilesSize * 3/ 4, 0, 90, 4);
                foreach(Vector2 point in externalArc)
        {
            southNorth.Add(point);
        }
        List<Vector2> internalArc = MathUtils.GeneratePointsOnArc(calculator.GetTileCoordinates(RectangleAnchorValues.TOP, RectangleAnchorValues.LEFT, 4, 3), SubtilesSize * 1 / 4, 270, 180, 4);
        foreach(Vector2 point in internalArc)
        {
            southNorth.Add(point);
        }
        southNorth.Add(calculator.GetTileCoordinatesHalfTileRight(RectangleAnchorValues.TOP, RectangleAnchorValues.MIDDLE, 3, 7));
        output[DirectionConstants.SUR_NORTE] = southNorth;

        //==============

        List<Vector2> northSouth = new List<Vector2>();
        northSouth.Add(calculator.GetTileCoordinatesHalfTileLeft(RectangleAnchorValues.TOP, RectangleAnchorValues.MIDDLE, 3, 7));

        externalArc = MathUtils.GeneratePointsOnArc(calculator.GetTileCoordinates(RectangleAnchorValues.TOP, RectangleAnchorValues.LEFT, 4, 3), SubtilesSize * 3/ 4, 180, 270, 4);
        foreach(Vector2 point in externalArc)
        {
            northSouth.Add(point);
        }
        internalArc = MathUtils.GeneratePointsOnArc(calculator.GetTileCoordinates(RectangleAnchorValues.TOP, RectangleAnchorValues.LEFT, 4, 2), SubtilesSize * 1 / 4, 90, 0, 4);
        foreach(Vector2 point in internalArc)
        {
            northSouth.Add(point);
        }

        northSouth.Add(calculator.GetTileCoordinatesHalfTileLeft(RectangleAnchorValues.BOTTOM, RectangleAnchorValues.MIDDLE, 4, 0));
        output[DirectionConstants.NORTE_SUR] = northSouth;

        return output;
    }
}