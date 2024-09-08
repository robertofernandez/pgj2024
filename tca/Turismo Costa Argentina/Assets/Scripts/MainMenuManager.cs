using UnityEngine;
using UnityEngine.SceneManagement;

public class MainMenuManager : MonoBehaviour
{
    public void LoadBeachSelectionScreen()
    {
        SceneManager.LoadScene(2);
    }

    public void QuitGame()
    {
        Debug.Log("Quitting game");
        Application.Quit();
    }

    public void GotoPuertoMadryn()
    {
        //TODO setup Puerto Madryn configuration
        SceneManager.LoadScene(1);
    }

    public void GotoPuntaMedanos()
    {
        //TODO setup Punta Medanos configuration
        SceneManager.LoadScene(1);
    }

}
