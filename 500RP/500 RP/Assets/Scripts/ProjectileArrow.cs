using UnityEngine;

public class ProjectileArrow : MonoBehaviour
{
    [Header("Configuración de Impacto")]
    public float damage = 1f;
    public float maxBounces = 3f; // Máximo de rebotes antes de destruirse
    public float velocityReductionOnHit = 0.3f; // Reducción de velocidad al impactar (0-1)
    public LayerMask balloonLayer; // Capa de los globos

    [Header("Referencias")]
    public GameObject hitEffect; // Efecto de impacto opcional

    private Rigidbody2D rb;
    private int currentBounces = 0;
    private bool hasHit = false;

    void Start()
    {
        rb = GetComponent<Rigidbody2D>();
    }

    void FixedUpdate()
    {
        if (rb != null && rb.linearVelocity.sqrMagnitude > 0.1f)
        {
            UpdateRotation();
        }
    }

    private void UpdateRotation()
    {
        float angle = Mathf.Atan2(rb.linearVelocity.y, rb.linearVelocity.x) * Mathf.Rad2Deg;
        transform.rotation = Quaternion.AngleAxis(angle, Vector3.forward);
    }

    void OnCollisionEnter2D(Collision2D collision)
    {
        // Verificar si es un globo (usando capas o tags)
        if (((1 << collision.gameObject.layer) & balloonLayer) != 0)
        {
            HandleBalloonHit(collision);
        }
        else
        {
            HandleOtherCollision(collision);
        }
    }

    private void HandleBalloonHit(Collision2D collision)
    {
        // 1. Destruir el globo
        Destroy(collision.gameObject);

        // 2. Aplicar efecto de impacto
        if (hitEffect != null)
        {
            Instantiate(hitEffect, collision.contacts[0].point, Quaternion.identity);
        }

        // 3. Modificar ligeramente la trayectoria
        if (rb != null)
        {
            // Reducir velocidad pero mantener dirección
            rb.linearVelocity *= (1f - velocityReductionOnHit);

            // Pequeño cambio de dirección basado en el punto de impacto
            if (collision.contacts.Length > 0)
            {
                Vector2 normal = collision.contacts[0].normal;
                Vector2 newDirection = Vector2.Reflect(rb.linearVelocity.normalized, normal) * 0.2f;
                rb.linearVelocity += newDirection;
            }
        }

        // 4. Contar rebote y verificar si se destruye
        currentBounces++;
        if (currentBounces >= maxBounces)
        {
            Destroy(gameObject, 0.1f); // Pequeño delay para efectos
        }

        hasHit = true;
    }

    private void HandleOtherCollision(Collision2D collision)
    {
        // Comportamiento normal para otras colisiones
        currentBounces++;
        if (currentBounces >= maxBounces + 2) // Más rebotes en otras superficies
        {
            Destroy(gameObject, 0.1f);
        }
    }

    // Para debug
    private void OnDrawGizmos()
    {
        if (rb != null && Application.isPlaying)
        {
            Gizmos.color = Color.red;
            Gizmos.DrawLine(transform.position, transform.position + (Vector3)rb.linearVelocity.normalized);
        }
    }
}