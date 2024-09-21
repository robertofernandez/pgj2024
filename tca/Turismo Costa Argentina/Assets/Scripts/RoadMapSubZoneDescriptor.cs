using UnityEngine;

public class RoadMapSubZoneDescriptor
{
    public float BottomLeftX { get; private set; }
    public float BottomLeftY { get; private set; }
    public float SizeX { get; private set; }
    public float SizeY { get; private set; }
    private RoadMapSubZoneCalculator calculator;

    public RoadMapSubZoneDescriptor(float bottomLeftX, float bottomLeftY, float sizeX, float sizeY, RoadMapSubZoneCalculator calculator)
    {
        BottomLeftX = bottomLeftX;
        BottomLeftY = bottomLeftY;
        SizeX = sizeX;
        SizeY = sizeY;
        this.calculator = calculator;
    }

    public bool OnRoad(float x, float y)
    {
        return calculator.OnRoad(x, y, SizeX, SizeY);
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
}
