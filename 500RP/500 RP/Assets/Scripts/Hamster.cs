using UnityEngine;
using System.Collections;

public class Hamster : MonoBehaviour
{
    [Header("Configuración")]
    public float moveSpeed = 1.2f;
    public float decisionTimeMin = 3f;
    public float decisionTimeMax = 6f;
    public float eatingTimeMin = 2f;
    public float eatingTimeMax = 5f;

    [Header("Estado")]
    public bool isTargeted = false;
    public bool isCaptured = false;
    public bool isEscaping = false;
    public bool isTrapped = false;
    public bool isEating = false;

    [Header("Debug")]
    public float[] capturePoints;   // puntos en X
    public float currentTargetX;    // hacia dónde se mueve
    public float decisionTimer;

    private Transform cage; // referencia a la jaula si está atrapado

    public void Init(float[] points)
    {
        capturePoints = points;
        PickRandomTarget();
    }

    void Update()
    {
        if (isCaptured)
        {
            // sigue la jaula hacia arriba
            if (cage != null)
                transform.position = cage.position + Vector3.down * 0.5f;
            return;
        }

        if (isTargeted)
        {
            // quieto
            return;
        }

        if (isEscaping)
        {
            // correr a la izquierda
            transform.position += Vector3.left * moveSpeed * 2f * Time.deltaTime;
            return;
        }

        if (isEating)
        {
            decisionTimer -= Time.deltaTime;
            if (decisionTimer <= 0)
            {
                isEating = false;
                PickRandomTarget();
            }
            return;
        }

        // movimiento normal
        decisionTimer -= Time.deltaTime;
        if (decisionTimer <= 0)
        {
            PickRandomTarget();
        }

        MoveTowardsTarget();
    }

    private void PickRandomTarget()
    {
        if (capturePoints == null || capturePoints.Length == 0) return;

        int index = Random.Range(0, capturePoints.Length);
        currentTargetX = capturePoints[index];
        decisionTimer = Random.Range(decisionTimeMin, decisionTimeMax);
    }

    private void MoveTowardsTarget()
    {
        Vector3 targetPos = new Vector3(currentTargetX, transform.position.y, transform.position.z);
        Vector3 direction = targetPos - transform.position;

        // movimiento
        transform.position = Vector3.MoveTowards(transform.position, targetPos, moveSpeed * Time.deltaTime);

        // girar hacia donde se mueve
        if (direction.x > 0.01f) 
        {
            // mirando a la derecha
            transform.localScale = new Vector3(-0.15f, 0.15f, 1);
        }
        else if (direction.x < -0.01f) 
        {
            // mirando a la izquierda
            transform.localScale = new Vector3(0.15f, 0.15f, 1);
        }

        // cuando llega, chance de comer
        if (Mathf.Abs(transform.position.x - currentTargetX) < 0.05f)
        {
            // 50% de chance de comer (podés ajustar la probabilidad)
            if (Random.value < 0.5f)
            {
                isEating = true;
                decisionTimer = Random.Range(eatingTimeMin, eatingTimeMax);
            }
            else
            {
                PickRandomTarget();
            }
        }
    }

    public void Target()
    {
        isTargeted = true;
    }

    public void Capture(Transform cageTransform)
    {
        isTargeted = false;
        isCaptured = true;
        cage = cageTransform;
    }

    public void CageDestroyed()
    {
        isCaptured = false;
        cage = null;
        PickRandomTarget(); // vuelve a moverse
    }

    public void Release()
    {
        isCaptured = false;
        isTargeted = false;
        cage = null;
        isEscaping = true;
        StartCoroutine(DestroyAfterEscape());
    }

    private IEnumerator DestroyAfterEscape()
    {
        yield return new WaitForSeconds(5f);
        HamsterGameManager.Instance.HamsterEscaped();
        Destroy(gameObject);
    }
}
