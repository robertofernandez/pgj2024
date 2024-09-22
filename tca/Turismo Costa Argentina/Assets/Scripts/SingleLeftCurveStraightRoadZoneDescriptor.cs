using UnityEngine;
using System.Collections.Generic;
using Sodhium.Utils;
using Sodhium.Geometry;

/**
 * TODO: combine visual and logic creators / initializations
 * Road type 03
 */
public class SingleLeftCurveStraightRoadZoneDescriptor : RoadMapZoneDescriptor
{
    public SingleLeftCurveStraightRoadZoneDescriptor(float centerX, float centerY, float subtilesAmount, float subtilesSize) : base(centerX, centerY, MapZoneDescriptor.SINGLE_LEFT_CURVE_STRAIGHT_ROAD, subtilesAmount, subtilesSize)
    {
        
    }

    public override string TypeName()
    {
        return "Single Left Curve Straight Road";
    }

    public override void BuildSubZones()
    {
        AddSubZone(3, 6, 1, 1, new StraightRoadSubZoneCalculator(), "straight");
        AddSubZone(3, 5, 1, 1, new StraightRoadSubZoneCalculator(), "straight");

        float trapeziumHeight = 0.1f;
        List<float> leftPointsForRightCurve = new List<float> { 0.05f, 0.05f, 0.1f, 0.15f, 0.26f, 0.4f, 0.5f, 0.53f, 0.54f, 0.56f};

        // Lista de puntos para el borde derecho (mantiene una línea recta)
        List<float> rightPointsForRightCurve = new List<float> { 0.45f, 0.45f, 0.5f, 0.55f, 0.6f, 0.75f, 0.85f, 0.9f, 0.93f, 0.93f};

        // Crear el calculador para curva y contracurva a la derecha
        TrapeziumComposedSubZoneCalculator rightCurveCalculator = new TrapeziumComposedSubZoneCalculator(
            trapeziumHeight, 
            leftPointsForRightCurve, 
            rightPointsForRightCurve
        );

        AddSubZone(3, 3, 2, 2, rightCurveCalculator, "right curve");

        AddSubZone(4, 2, 1, 1, new StraightRoadSubZoneCalculator(), "straight");
        AddSubZone(4, 1, 1, 1, new StraightRoadSubZoneCalculator(), "straight");
        AddSubZone(4, 0, 1, 1, new StraightRoadSubZoneCalculator(), "straight");
    }

    public override Dictionary<string, List<Vector2>> GenerateSignificantPointsByDirection()
    {
        TilesetCoordinatesCalculator calculator = TilesUtils.GetTilesetCoordinatesCalculator(CenterX, CenterY, SubtilesAmount, SubtilesAmount, SubtilesSize, SubtilesSize);
        Dictionary<string, List<Vector2>> output = new Dictionary<string, List<Vector2>>();
        List<Vector2> southNorth = new List<Vector2>();
        southNorth.Add(calculator.GetTileCoordinatesHalfTileRight(RectangleAnchorValues.BOTTOM, RectangleAnchorValues.MIDDLE, 4, 0));

        //Debug.Log("Descriptor for left curve at " + CenterX + ", " + CenterY);
        //Debug.Log("Geometric center:  " + GeometricCenter().x + ", " + GeometricCenter().y);
        //Debug.Log("Expected:  " + GeometricCenter().x + ", " + CenterY);
        //Vector2 temp = calculator.GetTileCoordinates(RectangleAnchorValues.BOTTOM, RectangleAnchorValues.MIDDLE, 4, 0);
        //Debug.Log("Got:  " + temp.x + ", " + temp.y);
        //DebugVectors(southNorth);

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
        southNorth.Add(calculator.GetTileCoordinatesHalfTileRight(RectangleAnchorValues.TOP, RectangleAnchorValues.MIDDLE, 3, 6));
        output[DirectionConstants.SUR_NORTE] = southNorth;

        //==============

        List<Vector2> northSouth = new List<Vector2>();
        northSouth.Add(calculator.GetTileCoordinatesHalfTileLeft(RectangleAnchorValues.TOP, RectangleAnchorValues.MIDDLE, 3, 6));

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

        //DebugVectors(output[DirectionConstants.NORTE_SUR]);

        return output;
    }

    public void DebugVectors(List<Vector2> vectorList)
    {
        foreach (Vector2 vector in vectorList)
        {
            Debug.Log(vector);
        }
    }
}