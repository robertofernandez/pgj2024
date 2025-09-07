using UnityEngine;
using System.Collections;

public class Hamster : MonoBehaviour
{
    [Header("Configuración")]
    public float moveSpeed = 2f;
    public float avoidanceRadius = 0.5f;
    public float decisionTimeMin = 1f;
    public float decisionTimeMax = 3f;

    [Header("Estado")]
    public bool isTrapped = false;
    public bool isEscaping = false;

    private Rigidbody2D rb;
    private Vector2 movementDirection;
    private float decisionTimer;

    void Start()
    {
        rb = GetComponent<Rigidbody2D>();
        SetRandomDecision();
    }

    void Update()
    {
        if (isTrapped || isEscaping) return;

        decisionTimer -= Time.deltaTime;
        if (decisionTimer <= 0)
        {
            SetRandomDecision();
        }

        Move();
        AvoidOtherHamsters();
    }

    private void SetRandomDecision()
    {
        movementDirection = new Vector2(Random.Range(-1f, 1f), 0).normalized;
        decisionTimer = Random.Range(decisionTimeMin, decisionTimeMax);
    }

    private void Move()
    {
        rb.linearVelocity = movementDirection * moveSpeed;
    }

    private void AvoidOtherHamsters()
    {
        Collider2D[] nearbyHamsters = Physics2D.OverlapCircleAll(transform.position, avoidanceRadius, LayerMask.GetMask("Hamsters"));
        
        foreach (Collider2D hamster in nearbyHamsters)
        {
            if (hamster.gameObject != gameObject)
            {
                Vector2 avoidanceDirection = (transform.position - hamster.transform.position).normalized;
                movementDirection = Vector2.Lerp(movementDirection, avoidanceDirection, 0.5f).normalized;
            }
        }
    }

    public void Trap()
    {
        isTrapped = true;
        rb.linearVelocity = Vector2.zero;
        rb.isKinematic = true;
        // Animación de atrapado
    }

    public void Release()
    {
        isTrapped = false;
        isEscaping = true;
        rb.isKinematic = false;
        
        // Huir fuera de la pantalla
        Vector2 escapeDirection = -Vector2.right;
        //Vector2 escapeDirection = (transform.position - Camera.main.transform.position).normalized;
        rb.linearVelocity = escapeDirection * moveSpeed * 2f;
        
        StartCoroutine(DestroyAfterEscape());
    }

    private IEnumerator DestroyAfterEscape()
    {
        yield return new WaitForSeconds(5f);
        HamsterGameManager.Instance.HamsterEscaped();
        Destroy(gameObject);
    }

    void OnDrawGizmos()
    {
        Gizmos.color = Color.yellow;
        Gizmos.DrawWireSphere(transform.position, avoidanceRadius);
    }
}