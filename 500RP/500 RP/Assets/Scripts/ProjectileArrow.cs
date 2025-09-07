using UnityEngine;

public class ProjectileArrow : MonoBehaviour
{
    [Header("Configuración")]
    public bool rotateToMatchVelocity = true;
    public float rotationSmoothing = 5f;

    private Rigidbody2D rb;

    void Start()
    {
        rb = GetComponent<Rigidbody2D>();
    }

    void FixedUpdate()
    {
        if (rotateToMatchVelocity && rb != null && rb.linearVelocity.sqrMagnitude > 0.1f)
        {
            UpdateRotation();
        }
    }

    private void UpdateRotation()
    {
        // Calcular ángulo basado en la velocidad
        float angle = Mathf.Atan2(rb.linearVelocity.y, rb.linearVelocity.x) * Mathf.Rad2Deg;
        
        // Aplicar rotación directamente (más preciso para física)
        transform.rotation = Quaternion.AngleAxis(angle, Vector3.forward);
    }
}