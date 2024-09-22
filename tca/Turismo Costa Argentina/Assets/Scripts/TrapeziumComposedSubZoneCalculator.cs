using UnityEngine;
using System.Collections.Generic;

public class TrapeziumComposedSubZoneCalculator : RoadMapSubZoneCalculator
{
    private float trapeziumHeight;
    private List<float> leftPoints;
    private List<float> rightPoints;

    public TrapeziumComposedSubZoneCalculator(float trapeziumHeight, List<float> leftPoints, List<float> rightPoints)
    {
        this.trapeziumHeight = trapeziumHeight;
        this.leftPoints = leftPoints;
        this.rightPoints = rightPoints;
    }

    public override List<Vector2> GetInterestPoints(float sizeX, float sizeY, float BottomLeftX, float BottomLeftY)
    {
        List<Vector2> output = new List<Vector2>();
        float y = BottomLeftY + sizeY;
        float stepY = sizeY * trapeziumHeight;

        for (int i=0; i < leftPoints.Count; i++)
        {
            float leftX = leftPoints[i] * sizeX + BottomLeftX;
            float rightX = rightPoints[i] * sizeX + BottomLeftX;
            output.Add(new Vector2(leftX, y));
            output.Add(new Vector2(rightX, y));
            y-=stepY;
        }

        return output;
    }


    // Método para determinar si el punto (x, y) está dentro de la ruta formada por los trapecios
    public override bool OnRoad(float x, float y, float sizeX, float sizeY, float BottomLeftX, float BottomLeftY)
    {
        // Determinar en qué trapecio cae el punto en el eje Y
        int trapeziumIndex = Mathf.FloorToInt((y - BottomLeftY) / (trapeziumHeight * sizeY));
        
        if (trapeziumIndex < 0 || trapeziumIndex >= leftPoints.Count)
        {
            // El punto está fuera del rango de trapecios
            return false;
        }

        float localY = (y - BottomLeftY) % (sizeY * trapeziumHeight);
        float t = localY / (sizeY * trapeziumHeight); 

        // Interpolación lineal para calcular los bordes izquierdo y derecho según la pendiente
        float leftEdgeX = Mathf.Lerp(
            BottomLeftX + leftPoints[trapeziumIndex] * sizeX,
            BottomLeftX + leftPoints[trapeziumIndex + 1] * sizeX,
            t
        );

        float rightEdgeX = Mathf.Lerp(
            BottomLeftX + rightPoints[trapeziumIndex] * sizeX,
            BottomLeftX + rightPoints[trapeziumIndex + 1] * sizeX,
            t
        );
        // Verificar si el punto x está dentro de los límites del trapecio correspondiente
        return (x >= leftEdgeX && x <= rightEdgeX);
    }
}
