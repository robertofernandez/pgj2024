using UnityEngine;
using System.Collections.Generic;
using Sodhium.Utils;
using Sodhium.Geometry;

public class SingleRightDiagonalStraightRoadZoneDescriptor : RoadMapZoneDescriptor
{
    public SingleRightDiagonalStraightRoadZoneDescriptor(float centerX, float centerY, float subtilesAmount, float subtilesSize) : base(centerX, centerY, MapZoneDescriptor.SINGLE_RIGHT_DIAGONAL_STRAIGHT_ROAD, subtilesAmount, subtilesSize)
    {
        
    }

    public override void BuildSubZones()
    {
        
    }

    public override Dictionary<string, List<Vector2>> GenerateSignificantPointsByDirection()
    {
        TilesetCoordinatesCalculator calculator = TilesUtils.GetTilesetCoordinatesCalculator(CenterX, CenterY, SubtilesAmount, SubtilesAmount, SubtilesSize, SubtilesSize);
        Dictionary<string, List<Vector2>> output = new Dictionary<string, List<Vector2>>();
        List<Vector2> southNorth = new List<Vector2>();
        southNorth.Add(calculator.GetTileCoordinatesHalfTileRight(RectangleAnchorValues.BOTTOM, RectangleAnchorValues.MIDDLE, 3, 0));
		Vector2 currentCurveCoordinates = calculator.GetTileCoordinatesHalfTileRight(RectangleAnchorValues.BOTTOM, RectangleAnchorValues.MIDDLE, 3, 3);
        southNorth.Add(currentCurveCoordinates);
		currentCurveCoordinates = currentCurveCoordinates + new Vector2(1 * SubtilesSize / 20f, SubtilesSize / 4f);
        southNorth.Add(currentCurveCoordinates);
		currentCurveCoordinates = currentCurveCoordinates + new Vector2(1 * SubtilesSize / 15f, SubtilesSize / 4f);
        southNorth.Add(currentCurveCoordinates);
		currentCurveCoordinates = currentCurveCoordinates + new Vector2(1 * SubtilesSize / 8f, SubtilesSize / 4f);
        southNorth.Add(currentCurveCoordinates);
		currentCurveCoordinates = currentCurveCoordinates + new Vector2(1 * SubtilesSize / 3f, SubtilesSize / 4f);
        southNorth.Add(currentCurveCoordinates);

		currentCurveCoordinates = currentCurveCoordinates + new Vector2(1 * SubtilesSize / 5f, SubtilesSize / 4f);
        southNorth.Add(currentCurveCoordinates);
		currentCurveCoordinates = currentCurveCoordinates + new Vector2(1 * SubtilesSize / 10f, SubtilesSize / 4f);
        southNorth.Add(currentCurveCoordinates);
		currentCurveCoordinates = currentCurveCoordinates + new Vector2(1 * SubtilesSize / 15f, SubtilesSize / 4f);
        southNorth.Add(currentCurveCoordinates);
		currentCurveCoordinates = currentCurveCoordinates + new Vector2(1 * SubtilesSize / 20f, SubtilesSize / 4f);
        southNorth.Add(currentCurveCoordinates);

        southNorth.Add(calculator.GetTileCoordinatesHalfTileRight(RectangleAnchorValues.TOP, RectangleAnchorValues.MIDDLE, 4, 6));
        output[DirectionConstants.SUR_NORTE] = southNorth;

        //==============

        List<Vector2> northSouth = new List<Vector2>();
        northSouth.Add(calculator.GetTileCoordinatesHalfTileLeft(RectangleAnchorValues.TOP, RectangleAnchorValues.MIDDLE, 4, 6));
		
		
		currentCurveCoordinates = calculator.GetTileCoordinatesHalfTileLeft(RectangleAnchorValues.TOP, RectangleAnchorValues.MIDDLE, 4, 4);
        northSouth.Add(currentCurveCoordinates);
		currentCurveCoordinates = currentCurveCoordinates + new Vector2(-1 * SubtilesSize / 30f, -1 * SubtilesSize / 4f);
        northSouth.Add(currentCurveCoordinates);
		currentCurveCoordinates = currentCurveCoordinates + new Vector2(-1 * SubtilesSize / 30f, -1 * SubtilesSize / 4f);
        northSouth.Add(currentCurveCoordinates);
		currentCurveCoordinates = currentCurveCoordinates + new Vector2(-1 * SubtilesSize / 20f, -1 * SubtilesSize / 4f);
        northSouth.Add(currentCurveCoordinates);
		currentCurveCoordinates = currentCurveCoordinates + new Vector2(-1 * SubtilesSize / 5f, -1 * SubtilesSize / 4f);
        northSouth.Add(currentCurveCoordinates);

		currentCurveCoordinates = currentCurveCoordinates + new Vector2(-1 * SubtilesSize / 3f, -1 * SubtilesSize / 4f);
        northSouth.Add(currentCurveCoordinates);
		currentCurveCoordinates = currentCurveCoordinates + new Vector2(-1 * SubtilesSize / 5f, -1 * SubtilesSize / 4f);
        northSouth.Add(currentCurveCoordinates);
		currentCurveCoordinates = currentCurveCoordinates + new Vector2(-1 * SubtilesSize / 20f, -1 * SubtilesSize / 4f);
        northSouth.Add(currentCurveCoordinates);
		currentCurveCoordinates = currentCurveCoordinates + new Vector2(-1 * SubtilesSize / 20f, -1 * SubtilesSize / 4f);
        northSouth.Add(currentCurveCoordinates);
		
        northSouth.Add(calculator.GetTileCoordinatesHalfTileLeft(RectangleAnchorValues.BOTTOM, RectangleAnchorValues.MIDDLE, 3, 0));
        output[DirectionConstants.NORTE_SUR] = northSouth;

        return output;
	}
}