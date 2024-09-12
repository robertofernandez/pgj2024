using UnityEngine;

public abstract class MapZoneDescriptor
{
    public static string SINGLE_ROAD = "Single Road";
    public static string SINGLE_RIGHT_CURVE_STRAIGHT_ROAD = "Single Right Curve Straight Road";
    public static string SINGLE_LEFT_CURVE_STRAIGHT_ROAD = "Single Left Curve Straight Road";
    public static string SINGLE_RIGHT_DIAGONAL_STRAIGHT_ROAD = "Single Right Diagonal Straight Road";
    public static string SINGLE_LEFT_DIAGONAL_STRAIGHT_ROAD = "Single Left Diagonal Straight Road";

    public float CenterX { get; set; }
    public float CenterY { get; set;}
    public string TypeName { get; set; }

    public MapZoneDescriptor(float centerX, float centerY, string typeName)
    {
        CenterX = centerX;
        CenterY = centerY;
        TypeName = typeName;
    }

    public abstract Vector2 GeometricCenter();
}