using System;
using System.Collections.Generic;
using UnityEngine;

/// <summary>
/// The <c>MapLogicManager</c> class manages the logical elements of a map,
/// where each horizontal band of the map is represented by a single descriptor.
/// For each segment along the y-axis of the map, there is only one corresponding descriptor.
/// This class provides methods to handle the creation, manipulation, and retrieval of map descriptors
/// and ensures the logical consistency of the map layout.
/// </summary>
public class MapLogicManager
{
    private List<MapZoneDescriptor> zonesDescriptorByIndex;
    private List<MapZoneDescriptor> zonesDescriptorByNegativeIndex;
    private float zonesHeight;
    private float offset;

    public MapLogicManager(float zonesHeight, float offset)
    {
        this.zonesHeight = zonesHeight;
        this.offset = offset;
        zonesDescriptorByIndex = new List<MapZoneDescriptor>();
        zonesDescriptorByNegativeIndex = new List<MapZoneDescriptor>();
    }

    public int GetIndex(float y)
    {
        return Mathf.FloorToInt((y + offset) / zonesHeight);
    }

    public MapZoneDescriptor GetDescriptorAt(int index)
    {
        if(index >= 0) 
        {
            return zonesDescriptorByIndex[index];
        }
        else
        {
            return zonesDescriptorByNegativeIndex[-1 * index - 1];
        }
    }

    public MapZoneDescriptor GetDescriptor(float y)
    {
        int index = GetIndex(y);
        if(hasDescriptorAtIndex(index))
        {
            return GetDescriptorAt(index);
        }
        else
        {
            Debug.Log("No descriptor for y = " + y + "(index " + index + ")");
            throw new ArgumentException("No element present at that position");
        }
    }

    public int GetMaxIndex()
    {
        return zonesDescriptorByIndex.Count - 1;
    }

    public float GetMaxY()
    {
        return (zonesDescriptorByIndex.Count - 1) * zonesHeight;
    }

    public bool hasDescriptor(float y)
    {
        int index = GetIndex(y);
        return hasDescriptorAtIndex(index);
    }

    public bool hasDescriptorAtIndex(int index)
    {
        if(index >= 0) 
        {
            return (zonesDescriptorByIndex.Count > index);
        }
        else
        {
            return (zonesDescriptorByNegativeIndex.Count > (- 1 + index * -1));
        }
    }


    public void AddOrderedDescriptor(float y, MapZoneDescriptor descriptor)
    {
        int index = GetIndex(y);
        descriptor.IndexInLogic = index;
        if(index >= 0) 
        {
            if(zonesDescriptorByIndex.Count <= index)
            {
                while(zonesDescriptorByIndex.Count <= index)
                {
                    zonesDescriptorByIndex.Add(descriptor);
                }
            }
            else
            {
                zonesDescriptorByIndex[index] = descriptor;
            }
        }
        else
        {
            index = -1 * index - 1;
            if(zonesDescriptorByNegativeIndex.Count <= index)
            {
                while(zonesDescriptorByNegativeIndex.Count <= index)
                {
                    zonesDescriptorByNegativeIndex.Add(descriptor);
                }
            }
            else
            {
                zonesDescriptorByNegativeIndex[index] = descriptor;
            }
        }
    }

    public MapZoneDescriptor GetMapZoneDescriptorOfTypeSurrounding(string typeName, float y)
    {
        int i = GetIndex(y);
        MapZoneDescriptor currentDescriptor = GetDescriptor(y);
        while(currentDescriptor.TypeName != typeName)
        {
            i++;
            currentDescriptor = GetDescriptorAt(i);
        }
        return currentDescriptor;
    }
}