using UnityEngine;

public class BalloonVisual : MonoBehaviour
{
    [Header("Referencia al padre")]
    public Balloon balloonController; // Referencia al script principal

    void Start()
    {
        // Buscar automáticamente el controller si no está asignado
        if (balloonController == null)
        {
            balloonController = GetComponentInParent<Balloon>();
        }
        
        if (balloonController == null)
        {
            Debug.LogError("BalloonController no encontrado en el padre!");
        }
    }

    void OnCollisionEnter2D(Collision2D collision)
    {
        // Delegar la colisión al controller principal
        if (balloonController != null)
        {
            balloonController.TakeDamage(10f);
        }
    }
}