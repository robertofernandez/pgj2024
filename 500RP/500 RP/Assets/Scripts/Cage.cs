using UnityEngine;
using System.Collections;

public class Cage : MonoBehaviour
{
    [Header("Referencias")]
    public Balloon balloon;
    public GameObject brokenCageEffect;

    [Header("Configuración")]
    public float descentSpeed = 3f;
    public float detectionRadius = 0.5f;

    [Header("Configuración")]
    public float groundLevel = -4.5f; // Nivel Y donde está el "suelo"

    private bool hasLanded = false;
    private Hamster trappedHamster;
    private Hamster targetHamster;

    private bool isActive = true;
    
    void Start()
    {
        // Inicialmente no atrapar hasta tocar el suelo
        trappedHamster = null;
    }

    public void ReleaseHamster()
    {
        if (trappedHamster != null)
        {
            trappedHamster.Release();
            trappedHamster = null;
        }

        if (brokenCageEffect != null)
        {
            Instantiate(brokenCageEffect, transform.position, Quaternion.identity);
        }

        Destroy(gameObject);
    }

    void OnDrawGizmos()
    {
        // Debug visual del raycast al suelo
        Gizmos.color = hasLanded ? Color.green : Color.yellow;
        Gizmos.DrawLine(transform.position, transform.position + Vector3.down * detectionRadius);
    }

   void Update()
    {
        if (!hasLanded)
        {
            // Mover hacia abajo
            transform.Translate(Vector3.down * descentSpeed * Time.deltaTime);
            
            // Verificar si llegó al nivel del suelo
            if (transform.position.y <= groundLevel)
            {
                LandOnGround();
            }
        }
    }

    private void LandOnGround()
    {
        hasLanded = true;
        transform.position = new Vector3(transform.position.x, groundLevel, transform.position.z);
        
        // Atrapar al hamster si está cerca
        if (targetHamster != null && !targetHamster.isTrapped)
        {
            float distance = Vector3.Distance(transform.position, targetHamster.transform.position);
            if (distance < 1.5f)
            {
                trappedHamster = targetHamster;
                trappedHamster.Trap();
                Debug.Log("Hamster atrapado en el suelo!");
            }
        }
    }

    public void Initialize(Hamster target)
    {
        targetHamster = target;
    }
}