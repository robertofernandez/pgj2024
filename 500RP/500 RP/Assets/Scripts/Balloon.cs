using UnityEngine;

public class Balloon : MonoBehaviour
{
    [Header("Configuración del Globo")]
    public float health = 1f;
    public GameObject popEffect;
    public int scoreValue = 10;
    
    [Header("Configuración de Movimiento")]
    public float riseSpeed = 1.1f; // Velocidad de ascenso
    public float maxHeight = 3.1f; // Altura máxima (donde está la nave)
    public float fallSpeed = 3f; // Velocidad de caída cuando se revienta
    public bool useRigidbodyForFall = true; // Usar física para la caída

    [Header("Referencias")]
    public Transform balloonVisual; // Referencia al globo visual
    public Transform stringVisual; // Referencia a la piola/cuerda
    public Rigidbody2D rb; // Rigidbody opcional para caída física

    private bool isPopped = false;
    private Vector3 initialScale;
    private float initialStringLength;

    void Start()
    {
        // Guardar escala inicial para posibles efectos
        if (balloonVisual != null)
        {
            initialScale = balloonVisual.localScale;
        }
        
        // Guardar longitud inicial de la piola
        if (stringVisual != null)
        {
            initialStringLength = stringVisual.localScale.y;
        }
        
        // Obtener Rigidbody si no está asignado
        if (rb == null)
        {
            rb = GetComponent<Rigidbody2D>();
        }
    }

    void Update()
    {
        if (!isPopped)
        {
            RiseBehavior();
        }
        else
        {
            FallBehavior();
        }
        
        UpdateStringVisual();
    }

    private void RiseBehavior()
    {
        // Subir hasta alcanzar la altura máxima
        if (transform.position.y < maxHeight)
        {
            transform.Translate(Vector3.up * riseSpeed * Time.deltaTime);
        }
        else
        {
            // Llegó a la nave - podría ser capturado
            ReachedSpaceship();
        }
    }

    private void FallBehavior()
    {
        if (useRigidbodyForFall && rb != null)
        {
            // Caída con física - asegurar que tiene gravedad
            if (rb.gravityScale == 0)
            {
                Debug.Log("Falling with gravity");
                rb.gravityScale = 1f;
            }
        }
        else
        {
            // Caída simple sin física
            Debug.Log("Falling with no gravity");
            transform.Translate(Vector3.down * fallSpeed * Time.deltaTime);
        }
        
        // Destruir si cae demasiado
        if (transform.position.y < -10f)
        {
            Destroy(gameObject);
        }
    }

    private void UpdateStringVisual()
    {
        // Opcional: hacer que la piola se estire mientras sube
        /*
        if (stringVisual != null && !isPopped)
        {
            float stretchFactor = 1f + (transform.position.y / maxHeight) * 0.5f;
            stringVisual.localScale = new Vector3(
                stringVisual.localScale.x,
                initialStringLength * stretchFactor,
                stringVisual.localScale.z
            );
        }*/
    }

    private void ReachedSpaceship()
    {
        // Lógica cuando el globo llega a la nave
        // Puedes triggerear un evento o simplemente destruirlo
        Debug.Log("Globo capturado por la nave!");
        Destroy(gameObject);
        
        // Si usas un sistema de eventos:
        // GameEvents.TriggerBalloonCaptured(scoreValue);
    }

    public void TakeDamage(float damage)
    {
        if (isPopped) return;
        
        health -= damage;
        
        if (health <= 0)
        {
            PopBalloon();
        }
    }

    private void PopBalloon()
    {
        isPopped = true;
        
        // Efecto de reventón
        if (popEffect != null)
        {
            Instantiate(popEffect, balloonVisual.position, Quaternion.identity);
        }

        // Desactivar o esconder el globo visual
        if (balloonVisual != null)
        {
            balloonVisual.gameObject.SetActive(false);
        }

        // Configurar física para la caída
        if (useRigidbodyForFall && rb != null)
        {
            rb.gravityScale = 1f;
            rb.angularDamping = 0.5f;
            rb.linearDamping = 0.3f;
        }

        // Sonido, score, etc.
        // GameManager.Instance.AddScore(scoreValue);
        
        Cage cage = GetComponentInParent<Cage>();
        if (cage != null)
        {
            cage.ReleaseHamster();
        }

        // Destruir después de un tiempo
        Destroy(gameObject, 5f); // Destruir después de 5 segundos de caída
    }

/*
movido a la clase que maneja el BalloonBody
    void OnCollisionEnter2D(Collision2D collision)
    {
        // Si algo choca con el globo, puede reventarlo
        if (!isPopped && collision.relativeVelocity.magnitude > 2f)
        {
            PopBalloon();
        }

        if (!isPopped)
        {
            PopBalloon();
        }
    }
*/
    public void HandleCollision(Collision2D collision)
    {
        if (!isPopped)
        {
            PopBalloon();
        }
    }

    // Para debug
    void OnDrawGizmos()
    {
        // Dibujar línea hasta la altura máxima
        Gizmos.color = Color.green;
        Gizmos.DrawLine(transform.position, new Vector3(transform.position.x, maxHeight, transform.position.z));
        
        // Dibujar esfera en la altura máxima
        Gizmos.color = Color.red;
        Gizmos.DrawWireSphere(new Vector3(transform.position.x, maxHeight, transform.position.z), 0.5f);
    }
}