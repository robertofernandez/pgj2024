using Sodhium.Geometry;

public class CurveSubZoneCalculator:RoadMapSubZoneCalculator
{
    private float anchorY;
    private float anchorX;

    public CurveSubZoneCalculator(float anchorY, float anchorX)
    {
        this.anchorY = anchorY;
        this.anchorX = anchorX;
    }

    public override bool OnRoad(float x, float y, float sizeX, float sizeY, float BottomLeftX, float BottomLeftY)
    {
        float centerX = BottomLeftX;
        float centerY = BottomLeftY;

        if(anchorX == RectangleAnchorValues.RIGHT)
        {
            centerX = BottomLeftX + sizeX;
        }
        if(anchorY == RectangleAnchorValues.TOP)
        {
            centerY = BottomLeftY + sizeY;
        }

        float square_x = (x - centerX) * (x - centerX);
        float square_y = (y - centerY) * (y - centerY);

        float square_radius = sizeX * sizeX;

        return (x > BottomLeftX && x < (BottomLeftX + x) && y > BottomLeftY && y < (BottomLeftY + y))
               && (square_radius <= (square_x + square_y));
    }
}