using UnityEngine;
using TMPro;

public class GameClock : MonoBehaviour
{
    public TextMeshProUGUI timerText;
    private float startTime;

    void Start()
    {
        startTime = Time.time;
    }

    void Update()
    {
        float t = Time.time - startTime;
        string minutes = ((int)t / 60).ToString("00");
        string seconds = (t % 60).ToString("00");
        timerText.text = minutes + ":" + seconds;
    }
}
