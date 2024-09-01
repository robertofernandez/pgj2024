using UnityEngine;

public static class MathUtils
{
    public static bool contains(IRectangularArea zone, float x, float y)
    {
        return (zone.minX() <= x && zone.maxX() >= x && zone.minY() <= y && zone.maxY() >= y);
    }

    public static float GetRotationAngle(string direccion)
    {
        // Determinar el ángulo de rotación basado en la dirección
        switch (direccion)
        {
            case DirectionConstants.SUR_NORTE:
                return 0f; // Sin rotación
            case DirectionConstants.NORTE_SUR:
                return 180f; // Rotación de 180 grados
            case DirectionConstants.ESTE_OESTE:
                return 90f; // Rotación de 90 grados
            case DirectionConstants.OESTE_ESTE:
                return -90f; // Rotación de -90 grados
            default:
                Debug.LogWarning("Dirección no válida: " + direccion);
                return 0f; // Valor predeterminado si la dirección no es válida
        }
    }

    /**
     * Devuelve la posicion relativa de la esquina inferior izquierda x, y de un tile girado en la direccion pasada por parametro.
     */
    public static Vector2Int GetTopLeftRelativePositionForDirection(string direccion, int initialX, int initialY)
    {
        switch (direccion)
        {
            case DirectionConstants.SUR_NORTE:
                return new Vector2Int(initialX, initialY);
            case DirectionConstants.NORTE_SUR:
                return new Vector2Int(initialX - 1, initialY - 1);
            case DirectionConstants.ESTE_OESTE:
                return new Vector2Int(initialX, initialY + 1);
            case DirectionConstants.OESTE_ESTE:
                return new Vector2Int(initialX - 1, initialY);
            default:
                Debug.LogWarning("Dirección no válida: " + direccion);
                return new Vector2Int(initialX, initialY);
        }
    }

    /**
     * Devuelve la posicion relativa de la esquina inferior izquierda x, y de un tile flipado en las direcciones correpsondientes.
     */
    public static Vector2Int GetTopLeftRelativePositionFlipped(int initialX, int initialY, bool flipX, bool flipY)
    {
        int flippedX = initialX;
        int flippedY = initialY;
        if(flipX)
        {
            flippedX++;
        }
        if(flipY)
        {
            flippedY++;
        }
        return new Vector2Int(flippedX, flippedY);
    }
}