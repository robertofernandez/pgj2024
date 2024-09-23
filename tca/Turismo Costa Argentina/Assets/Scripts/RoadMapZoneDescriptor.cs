using UnityEngine;
using System.Collections.Generic;

public abstract class RoadMapZoneDescriptor:MapZoneDescriptor
{
    public float SubtilesAmount { get; set; }
    public float SubtilesSize { get; set;}
    private Dictionary<string, List<Vector2>> significantPointsByDirection;
    public abstract Dictionary<string, List<Vector2>> GenerateSignificantPointsByDirection();
    public abstract void BuildSubZones();
    public abstract string TypeName();

    // Diccionario para guardar subzonas de carreteras (tramos de road)
    private List<RoadMapSubZoneDescriptor> subZoneDescriptors;

    public RoadMapZoneDescriptor(float centerX, float centerY, string typeName, float subtilesAmount, float subtilesSize) 
        : base(centerX, centerY, typeName)
    {
        SubtilesAmount = subtilesAmount;
        SubtilesSize = subtilesSize;
        significantPointsByDirection = GenerateSignificantPointsByDirection();
        subZoneDescriptors = new List<RoadMapSubZoneDescriptor>();
        BuildSubZones();
    }

    // Método para agregar subzonas de carreteras
    public void AddSubZone(float x, float y, float sizeX, float sizeY, RoadMapSubZoneCalculator calculator, string typeName)
    {
        RoadMapSubZoneDescriptor subZone = new RoadMapSubZoneDescriptor(CenterX + x * SubtilesSize, CenterY + y * SubtilesSize, SubtilesSize * sizeX, SubtilesSize * sizeY, calculator, typeName);
        subZoneDescriptors.Add(subZone);
    }

    public List<Vector2> GetInterestPoints()
    {
        List<Vector2> output = new List<Vector2>();
        foreach (RoadMapSubZoneDescriptor descriptor in subZoneDescriptors)
        {
            // Obtener la lista de puntos de interés de cada descriptor
            List<Vector2> interestPoints = descriptor.GetInterestPoints();
            
            // Agregar todos los puntos de interés a la lista de salida
            output.AddRange(interestPoints);
        }
        return output;
    }

    // FUTURE improve using coordinates
    public RoadMapSubZoneDescriptor GetSubZoneAt(float absoluteX, float absoluteY)
    {
        foreach (var subZone in subZoneDescriptors)
        {
            if (subZone.Contains(absoluteX, absoluteY))
            {
                return subZone;
            }
        }
        return null; // Si no encuentra un subtile que coincida, devuelve null
    }

    public bool OnRoad(float absoluteX, float absoluteY)
    {
        RoadMapSubZoneDescriptor szd = GetSubZoneAt(absoluteX, absoluteY);
        if(szd != null)
        {
            return szd.OnRoad(absoluteX, absoluteY);
        }
        return false;
    }

    public List<Vector2> GetSignificantPointsInRoad(string direction)
    {
        if(significantPointsByDirection.ContainsKey(direction))
        {
            return significantPointsByDirection[direction];
        }
        return new List<Vector2>();
    }

    public override Vector2 GeometricCenter()
    {
        return new Vector2(CenterX + SubtilesAmount * SubtilesSize /2, CenterY + SubtilesAmount * SubtilesSize /2);
    }

    public override Vector2 BottomLeft()
    {
        return new Vector2(CenterX, CenterY);
    }
    
    public override Vector2 BottomRight()
    {
        return new Vector2(CenterX + SubtilesAmount * SubtilesSize, CenterY);
    }

    public override Vector2 TopLeft()
    {
        return new Vector2(CenterX, CenterY + SubtilesAmount * SubtilesSize);
    }

    public override Vector2 TopRight()
    {
        return new Vector2(CenterX + SubtilesAmount * SubtilesSize, CenterY + SubtilesAmount * SubtilesSize);
    }

    public string GetDebugDescription()
    {
        return $"Type: {TypeName()}, Index: {IndexInLogic}, Bottom-Left: ({BottomLeft().x}, {BottomLeft().y}), Size: ({SubtilesAmount * SubtilesSize}, {SubtilesAmount * SubtilesSize})";
    }
}