using UnityEngine;
using System.Linq;
using System.Text;

public class Zone
{
    public float[] capturePoints;

    /// <summary>
    /// Constructor que toma puntos de un arreglo global con offset
    /// </summary>
    /// <param name="globalCapturePoints">Arreglo global de puntos</param>
    /// <param name="offset">Índice desde donde empezar a tomar puntos</param>
    /// <param name="amount">Cantidad de puntos a tomar</param>
    public Zone(float[] globalCapturePoints, int offset, int amount)
    {
        // Validaciones
        if (globalCapturePoints == null || globalCapturePoints.Length == 0)
        {
            Debug.LogWarning("globalCapturePoints está vacío o nulo");
            capturePoints = new float[0];
            return;
        }
        
        if (offset < 0 || offset >= globalCapturePoints.Length)
        {
            Debug.LogWarning($"Offset {offset} fuera de rango. El arreglo tiene {globalCapturePoints.Length} elementos");
            capturePoints = new float[0];
            return;
        }
        
        if (amount <= 0)
        {
            Debug.LogWarning("amount debe ser mayor a 0");
            capturePoints = new float[0];
            return;
        }
        
        // Calcular la cantidad real de puntos que podemos tomar
        int availablePoints = globalCapturePoints.Length - offset;
        int pointsToTake = Mathf.Min(amount, availablePoints);
        
        if (pointsToTake < amount)
        {
            Debug.LogWarning($"Solo se pueden tomar {pointsToTake} puntos de los {amount} solicitados");
        }
        
        // Crear el arreglo de capturePoints con los puntos seleccionados
        capturePoints = new float[pointsToTake];
        System.Array.Copy(globalCapturePoints, offset, capturePoints, 0, pointsToTake);
    }

    /// <summary>
    /// Devuelve un arreglo con 'amount' puntos aleatorios de capturePoints
    /// </summary>
    /// <param name="amount">Cantidad de puntos aleatorios a devolver</param>
    /// <returns>Arreglo con puntos aleatorios</returns>
    public float[] RandomCapturePoints(int amount)
    {
        // Validaciones
        if (capturePoints == null || capturePoints.Length == 0)
        {
            Debug.LogWarning("capturePoints está vacío o nulo");
            return new float[0];
        }
        
        if (amount <= 0)
        {
            Debug.LogWarning("amount debe ser mayor a 0");
            return new float[0];
        }
        
        // Si se piden más puntos de los disponibles, ajustamos al máximo disponible
        if (amount > capturePoints.Length)
        {
            Debug.LogWarning($"Se solicitan {amount} puntos pero solo hay {capturePoints.Length}. Se devolverán todos.");
            amount = capturePoints.Length;
        }
        
        // Crear una copia temporal para no modificar el original
        float[] tempPoints = (float[])capturePoints.Clone();
        
        // Mezclar el arreglo usando el algoritmo Fisher-Yates
        for (int i = tempPoints.Length - 1; i > 0; i--)
        {
            int randomIndex = Random.Range(0, i + 1);
            float temp = tempPoints[i];
            tempPoints[i] = tempPoints[randomIndex];
            tempPoints[randomIndex] = temp;
        }
        
        // Tomar los primeros 'amount' elementos del arreglo mezclado
        float[] result = new float[amount];
        System.Array.Copy(tempPoints, result, amount);
        
        return result;
    }

    /// <summary>
    /// Devuelve una representación en string de los puntos de la zona
    /// </summary>
    public override string ToString()
    {
        if (capturePoints == null || capturePoints.Length == 0)
        {
            return "Zone: No capture points";
        }
        
        // Usando StringBuilder para mejor performance con muchos elementos
        StringBuilder sb = new StringBuilder();
        sb.Append("Zone Points: [");
        
        for (int i = 0; i < capturePoints.Length; i++)
        {
            sb.Append(capturePoints[i].ToString("F2")); // Formato con 2 decimales
            
            if (i < capturePoints.Length - 1)
            {
                sb.Append(", ");
            }
        }
        
        sb.Append("]");
        return sb.ToString();
    }

}