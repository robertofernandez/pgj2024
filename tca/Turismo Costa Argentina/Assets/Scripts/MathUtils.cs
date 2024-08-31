public static class MathUtils
{
    public static bool contains(IRectangularArea zone, float x, float y)
    {
        return (zone.minX() <= x && zone.maxX() >= x && zone.minY() <= y && zone.maxY() >= y);
    }
}