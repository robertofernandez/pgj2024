using NUnit.Framework;
using System.Collections.Generic;
using UnityEngine;

[TestFixture]
public class MathUtilsTests
{
    [Test]
    public void GeneratePointsOnArc_CorrectNumberOfPoints()
    {
        // Arrange
        Vector2 center = new Vector2(0, 0);
        float radius = 5;
        float startAngle = 0;
        float endAngle = 90;
        int numberOfPoints = 5;

        List<Vector2> points = MathUtils.GeneratePointsOnArc(center, radius, startAngle, endAngle, numberOfPoints);

        Assert.AreEqual(numberOfPoints, points.Count, "El número de puntos generados no es el esperado.");
    }

    [Test]
    public void GeneratePointsOnArc_FirstAndLastPointsCorrect()
    {
        Vector2 center = new Vector2(0, 0);
        float radius = 5;
        float startAngle = 0;
        float endAngle = 90;
        int numberOfPoints = 5;

        List<Vector2> points = MathUtils.GeneratePointsOnArc(center, radius, startAngle, endAngle, numberOfPoints);

        // Convertimos los ángulos a radianes
        float startRad = DegreesToRadians(startAngle);
        float endRad = DegreesToRadians(endAngle);

        // Calculamos los puntos esperados
        Vector2 expectedStartPoint = new Vector2(center.x + radius * (float)System.Math.Cos(startRad), center.y + radius * (float)System.Math.Sin(startRad));
        Vector2 expectedEndPoint = new Vector2(center.x + radius * (float)System.Math.Cos(endRad), center.y + radius * (float)System.Math.Sin(endRad));

        // Assert
        Assert.AreEqual(expectedStartPoint, points[0], "El primer punto no coincide con el punto esperado en el ángulo de inicio.");
        Assert.AreEqual(expectedEndPoint, points[points.Count - 1], "El último punto no coincide con el punto esperado en el ángulo final.");

        foreach(Vector2 point in points)
        {
            TestContext.Out.WriteLine("Point generated: " + point);
        }
    }

    [Test]
    public void GeneratePointsOnArc_PointsAreOnCorrectRadius()
    {
        // Arrange
        Vector2 center = new Vector2(0, 0);
        float radius = 5;
        float startAngle = 0;
        float endAngle = 90;
        int numberOfPoints = 5;

        // Act
        List<Vector2> points = MathUtils.GeneratePointsOnArc(center, radius, startAngle, endAngle, numberOfPoints);

        // Assert
        foreach (var point in points)
        {
            float distance = Vector2.Distance(center, point);
            Assert.AreEqual(radius, distance, 0.001f, "El punto no se encuentra en el radio correcto.");
        }
    }

    private float DegreesToRadians(float degrees)
    {
        return degrees * (float)(System.Math.PI / 180);
    }
}
