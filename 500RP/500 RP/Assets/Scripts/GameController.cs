using UnityEngine;
using System.Collections.Generic;

public class GameController : MonoBehaviour
{
    private IEventsService _eventsService;
    
    [Header("Referencias")]
    public PowerMeterController powerMeterController;
    public NewInputController inputController;
    public ArmControllerNewInput armController;
    public ShootingControllerNewInput shootingController;
    public LocalDevicesInputManager localDevicesManager;

    void Start()
    {
        // Crear el servicio de eventos
        _eventsService = new EventsService(); // Asume que EventsService implementa IEventsService
        localDevicesManager.SetEventsService(_eventsService);

        // Configurar e inicializar componentes
        InitializeComponents();
        
        // Registrar eventos globales
        RegisterGlobalEvents();
    }

    private void InitializeComponents()
    {
        // Configurar el servicio de eventos en los componentes que lo necesitan
        if (powerMeterController == null)
        {
            Debug.LogError("Power meter not assigned in GameController!");
            return;
        }

        if (inputController != null)
        {
            inputController.SetEventsService(_eventsService);
        }

        // Inicializar referencias entre componentes
        if (armController != null && inputController != null)
        {
            armController.inputController = inputController;
        }

        if (shootingController != null)
        {
            shootingController.inputController = inputController;
            shootingController.armController = armController;
            shootingController.powerMeter = powerMeterController;
        }

    }

    private void RegisterGlobalEvents()
    {
        // Registrar eventos globales del juego
        //_eventsService.Register(GameEvent.EventType.bombDetonation, OnBombDetonation);
        _eventsService.Register(GameEvent.EventType.log, OnLog);
        // Puedes agregar más eventos aquí según necesites
    }

    //public void OnBombDetonation(Dictionary<string, object> @params)
    public void OnLog(Dictionary<string, object> @params)
    {
        string textToLog = string.Empty;
        if (@params.ContainsKey("text"))
        {
            textToLog = (string)@params["text"];
            Debug.Log(textToLog);
        }
    }

    public IEventsService GetEventsService() {
        return _eventsService;
    }

    private void FixedUpdate()
    {
        _eventsService.Trigger(GameEvent.EventType.gameClockTick, null);
    }
}