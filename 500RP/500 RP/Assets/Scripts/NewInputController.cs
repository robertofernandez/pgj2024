using System;
using UnityEngine;
using System.Collections.Generic;

public class NewInputController : MonoBehaviour
{
    [Header("Valores de Salida (Read-only)")]
    public float moveY;
    public float aimAngle;
    public bool isCharging;
    public bool chargePressed;
    public bool chargeReleased;

    private IEventsService _eventsService;
    private bool _wasCharging = false;

    private Guid keyboardInputRegistryId = new Guid();
    private Guid gamepadInputRegistryId = new Guid();

    // Público para que GameController pueda asignarlo
    public void SetEventsService(IEventsService service)
    {
        _eventsService = service;
        RegisterInputEvents();
    }

    void Start()
    {

    }

    private void RegisterInputEvents()
    {
        if (_eventsService != null)
        {
            keyboardInputRegistryId = _eventsService.Register(GameEvent.EventType.keyboardUpdate, OnInputUpdate);
            gamepadInputRegistryId = _eventsService.Register(GameEvent.EventType.gamepadUpdate, OnInputUpdate);
        }
    }

    void OnDestroy()
    {
        UnregisterInputEvents();
    }

    private void UnregisterInputEvents()
    {
        if (_eventsService != null)
        {
            _eventsService.Unregister(GameEvent.EventType.keyboardUpdate, keyboardInputRegistryId);
            _eventsService.Unregister(GameEvent.EventType.gamepadUpdate, gamepadInputRegistryId);
        }
    }

    void Update()
    {
        chargePressed = false;
        chargeReleased = false;
        
        if (isCharging && !_wasCharging)
            chargePressed = true;
        else if (!isCharging && _wasCharging)
            chargeReleased = true;
            
        _wasCharging = isCharging;
    }

    public void OnInputUpdate(Dictionary<string, object> parameters)
    {
        ProcessKeyboardInput(parameters);
        ProcessGamepadInput(parameters);
    }

    private void ProcessKeyboardInput(Dictionary<string, object> parameters)
    {
        if (parameters.TryGetValue("pressedKeys", out object keysObj) && keysObj is List<string> pressedKeys)
        {
            // Movimiento vertical (flechas arriba/abajo)
            moveY = 0f;
            if (pressedKeys.Contains("upArrow")) moveY += 1f;
            if (pressedKeys.Contains("downArrow")) moveY -= 1f;

            // Apuntado (flechas izquierda/derecha)
            aimAngle = 0f;
            if (pressedKeys.Contains("leftArrow")) aimAngle += 1f;
            if (pressedKeys.Contains("rightArrow")) aimAngle -= 1f;

            // Carga de disparo
            isCharging = pressedKeys.Contains("space");
        }
    }

    private void ProcessGamepadInput(Dictionary<string, object> parameters)
    {
        // Procesar botones del gamepad
        if (parameters.TryGetValue("pressedKeys", out object keysObj) && keysObj is List<string> pressedKeys)
        {
            // Carga de disparo (botón Este/B normalmente)
            if (pressedKeys.Contains("buttonEast"))
                isCharging = true;
        }

        // Procesar ejes del gamepad
        if (parameters.TryGetValue("axisStatus", out object axisObj) && axisObj is List<AxisStatus> axisStatus)
        {
            foreach (var axis in axisStatus)
            {
                if (axis.axisName == "leftStick")
                {
                    // Usar leftStick para movimiento vertical
                    moveY = axis.value.y;
                }
                else if (axis.axisName == "rightStick")
                {
                    // Usar rightStick para apuntado
                    aimAngle = axis.value.x;
                }
                else if (axis.axisName == "dpad")
                {
                    // Usar dpad como alternativa
                    if (Mathf.Abs(axis.value.y) > 0.1f)
                        moveY = axis.value.y;
                    if (Mathf.Abs(axis.value.x) > 0.1f)
                        aimAngle = axis.value.x;
                }
            }
        }
    }
}