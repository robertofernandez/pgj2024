using UnityEngine;
using System.Collections;

public class AlienSpaceship : MonoBehaviour
{
    [Header("Configuración")]
    public float timeBetweenDrops = 3f;
    public GameObject cagePrefab;
    public Transform dropPoint;

    [Header("Targeting")]
    public float targetingRange = 10f;

    [Header("Floating")]
    public float bobbingAmplitude = 0.1f;
    public float bobbingSpeed = 2f;

    private void Start()
    {
        StartCoroutine(DropCagesRoutine());
    }

    private IEnumerator DropCagesRoutine()
    {
        while (true)
        {
            yield return new WaitForSeconds(timeBetweenDrops);
            
            if (!HamsterGameManager.Instance.levelCompleted)
            {
                Hamster target = FindRandomHamster();
                if (target != null)
                {
                    DropCage(target);
                }
            }
        }
    }

    private Hamster FindRandomHamster()
    {
        var activeHamsters = HamsterGameManager.Instance.GetActiveHamsters();
        if (activeHamsters.Count == 0) return null;

        // Buscar hamsters no atrapados
        var availableHamsters = activeHamsters.FindAll(h => !h.isTrapped);
        if (availableHamsters.Count == 0) return null;

        return availableHamsters[Random.Range(0, availableHamsters.Count)];
    }

/*
    private void DropCage(Hamster targetHamster)
    {
        Debug.Log("Instanciando jaula en: " + dropPoint.position);
        Debug.DrawRay(dropPoint.position, Vector3.down * 5f, Color.red, 2f);

        if (targetHamster == null)
        {
            Debug.Log("Null hamster dropping cage");
            return;
        }
        if (targetHamster.isTrapped)
        {
            Debug.Log("Trapped hamster dropping cage");
            return;
        }
        
        GameObject cageGO = Instantiate(cagePrefab, dropPoint.position, Quaternion.identity);
        Cage cage = cageGO.GetComponent<Cage>();
        
        if (cage != null)
        {
            cage.Initialize(targetHamster);
            
            // Aplicar fuerza inicial hacia abajo
            Rigidbody2D cageRb = cageGO.GetComponent<Rigidbody2D>();
            if (cageRb != null)
            {
                cageRb.linearVelocity = Vector2.down * 2f; // Pequeño impulso inicial
            }
        }
        else
        {
            Debug.Log("Null cage dropping");
        }
    }
*/

    private void DropCage(Hamster targetHamster)
    {
        if (targetHamster == null || targetHamster.isTrapped) return;
        
        GameObject cageGO = Instantiate(cagePrefab, dropPoint.position, Quaternion.identity);
        Cage cage = cageGO.GetComponent<Cage>();
        cage.hamsterManager = HamsterGameManager.Instance;

/*
        Cage cage = cageGO.GetComponent<Cage>();
        
        if (cage != null)
        {
            // Solo pasar la referencia, NO atrapar todavía
            cage.Initialize(targetHamster);
            
            // Aplicar pequeña fuerza inicial si usas física
            Rigidbody2D cageRb = cageGO.GetComponent<Rigidbody2D>();
            if (cageRb != null)
            {
                cageRb.linearVelocity = Vector2.down * 2f;
            }
        }
        */
    }

    public void OnCageCaptured()
    {
        HamsterGameManager.Instance.HamsterCaptured();
    }

    void Update()
    {
        // bobbing senoidal
        float newY = 0.56f + Mathf.Sin(Time.time * bobbingSpeed) * bobbingAmplitude;
        transform.localPosition = new Vector3(transform.localPosition.x, newY, transform.localPosition.z);
    }
}