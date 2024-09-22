using UnityEngine;
using System.Collections.Generic;
using Sodhium.Utils;
using Sodhium.Geometry;

public class SingleRightDiagonalStraightRoadZoneDescriptor : RoadMapZoneDescriptor
{
    public SingleRightDiagonalStraightRoadZoneDescriptor(float centerX, float centerY, float subtilesAmount, float subtilesSize) : base(centerX, centerY, MapZoneDescriptor.SINGLE_RIGHT_DIAGONAL_STRAIGHT_ROAD, subtilesAmount, subtilesSize)
    {
        
    }

    public override string TypeName()
    {
        return "Single Right Diagonal Straight Road";
    }

    public override void BuildSubZones()
    {
        AddSubZone(4, 6, 1, 1, new StraightRoadSubZoneCalculator());
        AddSubZone(4, 5, 1, 1, new StraightRoadSubZoneCalculator());

        float trapeziumHeight = 0.1f;
        List<float> leftPointsForRightCurve = new List<float> { 0.05f, 0.05f, 0.06f, 0.1f, 0.15f, 0.25f, 0.35f, 0.45f, 0.5f, 0.56f};

        // Lista de puntos para el borde derecho (mantiene una línea recta)
        List<float> rightPointsForRightCurve = new List<float> { 0.45f, 0.45f, 0.47f, 0.49f, 0.53f, 0.6f, 0.75f, 0.85f, 0.92f, 0.94f};

        // Crear puntos simétricos para el borde izquierdo
        List<float> leftPointsForLeftCurve = new List<float>();
        foreach (float point in rightPointsForRightCurve)
        {
            leftPointsForLeftCurve.Add(1f - point); // Reflexión alrededor del centro
        }

        // Crear puntos simétricos para el borde derecho
        List<float> rightPointsForLeftCurve = new List<float>();
        foreach (float point in leftPointsForRightCurve)
        {
            rightPointsForLeftCurve.Add(1f - point); // Reflexión alrededor del centro
        }

        // Crear el calculador para curva y contracurva a la izquierda (simétrica)
        TrapeziumComposedSubZoneCalculator leftCurveCalculator = new TrapeziumComposedSubZoneCalculator(
            trapeziumHeight,
            leftPointsForLeftCurve,
            rightPointsForLeftCurve
        );

        AddSubZone(3, 3, 2, 2, leftCurveCalculator);

        AddSubZone(3, 2, 1, 1, new StraightRoadSubZoneCalculator());
        AddSubZone(3, 1, 1, 1, new StraightRoadSubZoneCalculator());
        AddSubZone(3, 0, 1, 1, new StraightRoadSubZoneCalculator());
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