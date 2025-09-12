using UnityEngine;
using System.Collections.Generic;
using System;

public class HamsterGameManager : MonoBehaviour
{
    public static HamsterGameManager Instance;

    [Header("Configuración de escenario")]
    public float minX = -8.71f;
    public float maxX = 3.7f;
    public float y = -4.3f;
    public float hamsterWidth = 0.39f;
    public float cageWidth = 0.707f;
    public int maxSimultaneousCages = 4;
    int zonesAmount = 3;

    [Header("Configuración de Niveles")]
    public int currentLevel = 1;
    public int initialHamsters = 32;
    public int hamstersPerLevelIncrease = 6;
    public int maxCapturedToLose = 8;

    [Header("Estado del Juego")]
    public int totalHamstersInLevel;
    public int capturedHamsters;
    public int escapedHamsters;
    public bool levelCompleted;

    [Header("Referencias")]
    public GameObject hamsterPrefab;
    public Transform hamsterContainer;
    public List<Transform> hamsterSpawnPoints = new List<Transform>();

    private List<Hamster> activeHamsters = new List<Hamster>();
    public Zone[] zones;

    public float[] capturePoints;

    void Awake()
    {
        if (Instance == null)
        {
            Instance = this;
            DontDestroyOnLoad(gameObject);
        }
        else
        {
            Destroy(gameObject);
        }
    }

    void Start()
    {
        StartLevel(currentLevel);
    }

    public void StartLevel(int level)
    {
        zones = new Zone[zonesAmount];
        float pickUpZoneWidth = maxX - minX;
        int pickUpPointsAmount = (int) Math.Floor((double)pickUpZoneWidth / (double)cageWidth);
        int pointsByZone = (int) Math.Floor((double)pickUpPointsAmount / (double)zonesAmount);
        //int zonesAmount = Math.Floor(pickUpPointsAmount / maxSimultaneousCages);

        capturePoints = new float[pickUpPointsAmount];

        float currentX = minX;
        

        for (int i=0; i<pickUpPointsAmount;i++)
        {
            capturePoints[i] = currentX;
            currentX+=cageWidth;
        }

        for (int i=0; i<zonesAmount;i++)
        {
            zones[i] = new Zone(capturePoints, i * pointsByZone, pointsByZone);
        }

        foreach (var zone in zones)
        {
            Debug.Log($"Zone created: {zone}");
        }

        int simulationTime = 500;
        int initialZone = UnityEngine.Random.Range(0, zonesAmount);

        // Calcular hamsters para este nivel
        totalHamstersInLevel = initialHamsters + ((level - 1) * hamstersPerLevelIncrease);

        currentLevel = level;
        capturedHamsters = 0;
        escapedHamsters = 0;
        levelCompleted = false;

        SpawnHamsters(totalHamstersInLevel, pickUpPointsAmount);
    }

    private void SpawnHamsters(int count, int pickUpPointsAmount)
    {
        // Limpiar hamsters anteriores
        foreach (Transform child in hamsterContainer)
        {
            Destroy(child.gameObject);
        }
        activeHamsters.Clear();

        // Generar hamsters
        for (int i = 0; i < count; i++)
        {
                float x = capturePoints[i%pickUpPointsAmount];
                Vector3 customPosition = new Vector3(x, y, hamsterContainer.position.z); // Reemplaza 5.0f y 3.0f con tus valores conocidos
                GameObject hamsterGO = Instantiate(hamsterPrefab, customPosition, Quaternion.identity, hamsterContainer);

                Hamster hamster = hamsterGO.GetComponent<Hamster>();
                hamster.Init(capturePoints, i);
                activeHamsters.Add(hamster);
        }
    }

    public Hamster GetOneActiveHamsterAt(int capturePointIndex)
    {
        foreach (Hamster hamster in activeHamsters)
        {
            if (!hamster.isCaptured && !hamster.isEscaping)
            {
                return hamster;
            }
        }
        return null;
    }

    public Hamster GetNearestHamster(float xPosition)
    {
        Hamster nearest = null;
        float minDistance = Mathf.Infinity;

        foreach (Hamster h in activeHamsters)
        {
            if (h == null || h.isTrapped) continue;

            float dist = Mathf.Abs(h.transform.position.x - xPosition);
            if (dist < minDistance)
            {
                minDistance = dist;
                nearest = h;
            }
        }

        return nearest;
    }

    public void HamsterCaptured()
    {
        capturedHamsters++;
        CheckLevelCompletion();

        if (capturedHamsters >= maxCapturedToLose)
        {
            GameOver();
        }
    }

    public void HamsterEscaped()
    {
        escapedHamsters++;
        CheckLevelCompletion();
    }

    private void CheckLevelCompletion()
    {
        if (capturedHamsters + escapedHamsters >= totalHamstersInLevel)
        {
            levelCompleted = true;
            LevelComplete();
        }
    }

    private void LevelComplete()
    {
        Debug.Log($"Nivel {currentLevel} completado! Capturados: {capturedHamsters}, Libres: {escapedHamsters}");
        
        // Pasar al siguiente nivel o victoria final
        if (currentLevel < 6)
        {
            // Cargar siguiente nivel después de delay
            Invoke("LoadNextLevel", 2f);
        }
        else
        {
            Victory();
        }
    }

    private void LoadNextLevel()
    {
        currentLevel++;
        StartLevel(currentLevel);
    }

    private void GameOver()
    {
        Debug.Log("Game Over! Demasiados hamsters capturados.");
        // Reiniciar nivel o volver al menú
    }

    private void Victory()
    {
        Debug.Log("¡Victoria! Todos los niveles completados.");
    }

    public List<Hamster> GetActiveHamsters()
    {
        return activeHamsters;
    }
}