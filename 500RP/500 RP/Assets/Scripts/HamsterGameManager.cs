using UnityEngine;
using System.Collections.Generic;

public class HamsterGameManager : MonoBehaviour
{
    public static HamsterGameManager Instance;

    [Header("Configuración de Niveles")]
    public int currentLevel = 1;
    public int initialHamsters = 12;
    public int hamstersPerLevelIncrease = 2;
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
        currentLevel = level;
        capturedHamsters = 0;
        escapedHamsters = 0;
        levelCompleted = false;

        // Calcular hamsters para este nivel
        totalHamstersInLevel = initialHamsters + ((level - 1) * hamstersPerLevelIncrease);
        
        SpawnHamsters(totalHamstersInLevel);
    }

    private void SpawnHamsters(int count)
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
            if (i < hamsterSpawnPoints.Count)
            {
                GameObject hamsterGO = Instantiate(hamsterPrefab, hamsterSpawnPoints[i].position, Quaternion.identity, hamsterContainer);
                Hamster hamster = hamsterGO.GetComponent<Hamster>();
                activeHamsters.Add(hamster);
            }
        }
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