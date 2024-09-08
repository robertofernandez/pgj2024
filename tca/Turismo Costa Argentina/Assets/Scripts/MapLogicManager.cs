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
        if(hasDescriptor(y))
        {
            return Mathf.FloorToInt((y - offset) / zonesHeight);
        }
        else
        {
            throw new ArgumentException("No element present at that position (" + y + ")");
        }
    }

    public MapZoneDescriptor GetDescriptorAt(int index)
    {
        if(index >= 0) 
        {
            return zonesDescriptorByIndex[index];
        }
        else
        {
            return zonesDescriptorByNegativeIndex[-1 * index];
        }
    }

    public MapZoneDescriptor GetDescriptor(float y)
    {
        if(hasDescriptor(y))
        {

            int index = Mathf.FloorToInt((y - offset) / zonesHeight);
            if(index > 0) 
            {
                return zonesDescriptorByIndex[index];
            }
            else
            {
                return zonesDescriptorByNegativeIndex[-1 * index];
            }
        }
        else
        {
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
        int index = Mathf.FloorToInt((y - offset) / zonesHeight);

        if(index > 0) 
        {
            return (zonesDescriptorByIndex.Count > index);
        }
        else
        {
            return (zonesDescriptorByNegativeIndex.Count > index);
        }
    }

    public void AddOrderedDescriptor(float y, MapZoneDescriptor descriptor)
    {
        int index = Mathf.FloorToInt((y - offset) / zonesHeight);

        if(index > 0) 
        {
            if(zonesDescriptorByIndex.Count <= index)
            {
                zonesDescriptorByIndex.Add(descriptor);
            }
            else
            {
                zonesDescriptorByIndex[index] = descriptor;
            }
        }
        else
        {
            index = -1 * index;
            if(zonesDescriptorByNegativeIndex.Count <= index)
            {
                zonesDescriptorByNegativeIndex.Add(descriptor);
            }
            else
            {
                zonesDescriptorByNegativeIndex[index] = descriptor;
            }
        }
    }

    public void AddDescriptor(float y, MapZoneDescriptor descriptor)
    {
        if(hasDescriptor(y))
        {
            int index = Mathf.FloorToInt((y - offset) / zonesHeight);
            if(index > 0) 
            {
                zonesDescriptorByIndex[index] = descriptor;
            }
            else
            {
                zonesDescriptorByNegativeIndex[-1*index] = descriptor;
            }
        }
        else
        {
            throw new ArgumentException("No enough size of the descriptors list to add a new element. All maps elements neede to be added in order an then can be replaced by other descriptors.");
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