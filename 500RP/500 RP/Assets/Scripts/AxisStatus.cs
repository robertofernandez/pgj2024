using UnityEngine;

[System.Serializable]
public class AxisStatus
{
    public string axisName;
    public Vector2 value;

    public override string ToString()
    {
        return $"{axisName}: {value}";
    }
}