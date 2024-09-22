public class StraightRoadSubZoneCalculator:RoadMapSubZoneCalculator
{
    public override bool OnRoad(float x, float y, float sizeX, float sizeY, float BottomLeftX, float BottomLeftY)
    {
        return x > BottomLeftX && x < (BottomLeftX + x) && y > BottomLeftY && y < (BottomLeftY + y);
    }
}