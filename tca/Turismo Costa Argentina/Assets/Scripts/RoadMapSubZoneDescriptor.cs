using UnityEngine;
using System.Collections.Generic;

public class RoadMapSubZoneDescriptor
{
    public float BottomLeftX { get; private set; }
    public float BottomLeftY { get; private set; }
    public float SizeX { get; private set; }
    public float SizeY { get; private set; }
    private RoadMapSubZoneCalculator calculator;
    public string TypeName { get; private set; }

    public RoadMapSubZoneDescriptor(float bottomLeftX, float bottomLeftY, float sizeX, float sizeY, RoadMapSubZoneCalculator calculator, string typeName)
    {
        BottomLeftX = bottomLeftX;
        BottomLeftY = bottomLeftY;
        TypeName = typeName;
        SizeX = sizeX;
        SizeY = sizeY;
        this.calculator = calculator;
    }

    public List<Vector2> GetInterestPoints()
    {
        return calculator.GetInterestPoints(SizeX, SizeY, BottomLeftX, BottomLeftY);
    }

    public bool OnRoad(float x, float y)
    {
        return calculator.OnRoad(x, y, SizeX, SizeY, BottomLeftX, BottomLeftY);
    }

    // Método que devuelve el punto central de la subzona
    public Vector2 GeometricCenter()
    {
        return new Vector2(BottomLeftX + SizeX / 2, BottomLeftY + SizeY / 2);
    }

    // Método que chequea si una coordenada absoluta está dentro de esta subzona
    public bool Contains(float x, float y)
    {
        return x >= BottomLeftX && x < (BottomLeftX + SizeX) &&
               y >= BottomLeftY && y < (BottomLeftY + SizeY);
    }

    // Métodos para obtener las esquinas de la subzona
    public Vector2 BottomLeft()
    {
        return new Vector2(BottomLeftX, BottomLeftY);
    }

    public Vector2 BottomRight()
    {
        return new Vector2(BottomLeftX + SizeX, BottomLeftY);
    }

    public Vector2 TopLeft()
    {
        return new Vector2(BottomLeftX, BottomLeftY + SizeY);
    }

    public Vector2 TopRight()
    {
        return new Vector2(BottomLeftX + SizeX, BottomLeftY + SizeY);
    }

    public string GetDebugDescription()
    {
        return $"Type: {TypeName}, Bottom-Left: ({BottomLeftX}, {BottomLeftY}), Size: ({SizeX}, {SizeY})";
    }
}
