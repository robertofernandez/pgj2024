// DictionaryExtensions.cs
using System.Collections.Generic;
using System.Text;
using UnityEngine;

public static class DictionaryExtensions
{
    public static string ToDebugString<TKey, TValue>(this Dictionary<TKey, TValue> dictionary)
    {
        StringBuilder sb = new StringBuilder();
        sb.Append("{");
        
        foreach (var kvp in dictionary)
        {
            sb.Append($"{kvp.Key}: ");
            
            // Manejo especial para listas/arrays
            if (kvp.Value is System.Collections.IEnumerable enumerable && 
                !(kvp.Value is string))
            {
                sb.Append("[");
                bool first = true;
                foreach (var item in enumerable)
                {
                    if (!first) sb.Append(", ");
                    sb.Append(item.ToString());
                    first = false;
                }
                sb.Append("]");
            }
            else
            {
                sb.Append(kvp.Value?.ToString() ?? "null");
            }
            
            sb.Append(", ");
        }
        
        if (sb.Length > 1)
            sb.Length -= 2; // Elimina la última ", "
            
        sb.Append("}");
        return sb.ToString();
    }
}