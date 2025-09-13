using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class AlienSpaceship : MonoBehaviour
{
    [Header("Configuración")]
    public GameObject cagePrefab;
    public Transform dropPoint;

    [Header("Floating")]
    public float bobbingAmplitude = 0.1f;
    public float bobbingSpeed = 2f;

    private int currentLane = 14;
    private bool movingRight = true;

    private List<Cage> allCages = new List<Cage>();

    void Update()
    {
        // Movimiento senoidal en Y
        float newY = 0.56f + Mathf.Sin(Time.time * bobbingSpeed) * bobbingAmplitude;
        transform.localPosition = new Vector3(transform.localPosition.x, newY, transform.localPosition.z);

        foreach(Cage cage in allCages)
        {
            if(cage != null)
            {
                if(!cage.joined && cage.HasTrappedHamster())
                {
                    if (cage.transform.position.y > 0.9 && Mathf.Abs(cage.transform.position.x - transform.position.x) < 1.5)
                    {
                        cage.JoinSpaceship();
                    }
                }
            }
        }

        PatrolCapturePoints();
    }

    private void PatrolCapturePoints()
    {
        float[] capturePoints = HamsterGameManager.Instance.capturePoints;
        if (capturePoints == null || capturePoints.Length == 0) return;

        float speed = 1f + HamsterGameManager.Instance.currentLevel * 0.5f; // velocidad según nivel
        float targetX = capturePoints[currentLane] + 2.5f;
        Vector3 targetPos = new Vector3(targetX, transform.localPosition.y, transform.localPosition.z);

        transform.localPosition = Vector3.MoveTowards(transform.localPosition, targetPos, speed * Time.deltaTime);

        // ¿Llegamos al capturePoint?
        if (Mathf.Abs(transform.localPosition.x - targetX) < 0.01f)
        {
            TryDropCage(currentLane);

            // Avanzar al siguiente
            if (movingRight)
                currentLane++;
            else
                currentLane--;

            // Cambiar de dirección si llegamos a los extremos
            if (currentLane >= capturePoints.Length)
            {
                currentLane = capturePoints.Length - 1;
                movingRight = false;
            }
            else if (currentLane < 0)
            {
                currentLane = 0;
                movingRight = true;
            }
        }
    }

    private void TryDropCage(int laneIndex)
    {
        // ¿ya hay una jaula ocupando la lane?
        if (!HamsterGameManager.Instance.IsLaneFree(laneIndex)) return;

        GameObject cageObj = Instantiate(cagePrefab, dropPoint.position, Quaternion.identity);
        Cage cage = cageObj.GetComponent<Cage>();
        cage.laneIndex = laneIndex;
        cage.laneFree = false;
        cage.hamsterManager = HamsterGameManager.Instance;

        allCages.Add(cage);

        HamsterGameManager.Instance.OccupyLane(laneIndex, cage);
    }

    private void FreeCage(Cage cage)
    {
        if (cage != null)
        {
            cage.JoinSpaceship(); // la cage se autodestruye y libera su lane
            HamsterGameManager.Instance.FreeLane(cage.laneIndex);
        }
    }
}
