using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.InputSystem.LowLevel;
using UnityEngine.InputSystem.Controls;
using System.Collections.Generic;
using System.Text;

public class LocalDevicesInputManager : MonoBehaviour
{
    private IEventsService _eventsService;

    [Header("Keyboard Settings")]
    public List<string> keyboardKeysToCheck = new List<string> 
    { 
        "upArrow", "downArrow", "leftArrow", "rightArrow",
        "q", "w", "e", "r", "space", "leftCtrl"
    };

    [Header("Gamepad Settings")]
    public List<string> gamepadButtonsToCheck = new List<string> 
    { 
        "buttonSouth", "buttonEast", "buttonWest", "buttonNorth" 
    };
    
    public List<string> gamepadAxesToCheck = new List<string> 
    { 
        "leftStick", "rightStick", "dpad" 
    };

    private Dictionary<InputControl, string> keyboardControlNames = new Dictionary<InputControl, string>();
    private Dictionary<InputControl, string> gamepadControlNames = new Dictionary<InputControl, string>();

    private void Awake()
    {
        InputSystem.onEvent += OnInputEvent;
        InitializeControlMaps();
    }

    private void OnDestroy()
    {
        InputSystem.onEvent -= OnInputEvent;
    }

    private void InitializeControlMaps()
    {
        InitializeKeyboardControls();
        InitializeGamepadControls();
    }

    private void InitializeKeyboardControls()
    {
        keyboardControlNames.Clear();
        var keyboard = Keyboard.current;
        if (keyboard == null) return;

        foreach (var keyName in keyboardKeysToCheck)
        {
            // Método seguro para encontrar teclas
            var keyControl = FindKeyControl(keyboard, keyName);
            if (keyControl != null)
            {
                keyboardControlNames.Add(keyControl, keyName);
            }
            else
            {
                Debug.LogWarning($"Tecla no encontrada: {keyName}");
            }
        }
    }

    private KeyControl FindKeyControl(Keyboard keyboard, string keyName)
    {
        // Mapeo manual de nombres comunes a controles de teclado
        switch (keyName.ToLower())
        {
            case "uparrow": return keyboard.upArrowKey;
            case "downarrow": return keyboard.downArrowKey;
            case "leftarrow": return keyboard.leftArrowKey;
            case "rightarrow": return keyboard.rightArrowKey;
            case "space": return keyboard.spaceKey;
            case "leftctrl": return keyboard.leftCtrlKey;
            case "q": return keyboard.qKey;
            case "w": return keyboard.wKey;
            case "e": return keyboard.eKey;
            case "r": return keyboard.rKey;
            // Agregar más mapeos según sea necesario
            default: return null;
        }
    }

    private void InitializeGamepadControls()
    {
        gamepadControlNames.Clear();
        var gamepad = Gamepad.current;
        if (gamepad == null) return;

        foreach (var buttonName in gamepadButtonsToCheck)
        {
            var control = gamepad.TryGetChildControl(buttonName);
            if (control != null)
            {
                gamepadControlNames.Add(control, buttonName);
            }
        }

        foreach (var axisName in gamepadAxesToCheck)
        {
            var control = gamepad.TryGetChildControl(axisName);
            if (control != null)
            {
                gamepadControlNames.Add(control, axisName);
            }
        }
    }

    private void OnInputEvent(InputEventPtr eventPtr, InputDevice device)
    {
        if (!eventPtr.IsA<StateEvent>() && !eventPtr.IsA<DeltaStateEvent>())
            return;

        if (device is Keyboard keyboard)
        {
            TriggerKeyboardUpdate(eventPtr, keyboard);
        }
        else if (device is Gamepad gamepad)
        {
            TriggerGamepadUpdate(eventPtr, gamepad);
        }
    }

    private void TriggerKeyboardUpdate(InputEventPtr eventPtr, Keyboard keyboard)
    {
        var pressedKeys = new List<string>();
        var axisStatus = new List<AxisStatus>();

        foreach (var kvp in keyboardControlNames)
        {
            var control = kvp.Key;
            var name = kvp.Value;

            if (control is KeyControl keyControl)
            {
                bool pressed = keyControl.ReadValueFromEvent(eventPtr) > 0;
                if (pressed)
                {
                    pressedKeys.Add(name);
                }
            }
        }

        var inputStatusParams = new Dictionary<string, object>
        {
            { "controlId", keyboard.deviceId },
            { "pressedKeys", pressedKeys },
            { "axisStatus", axisStatus }
        };

        _eventsService?.Trigger(GameEvent.EventType.keyboardUpdate, inputStatusParams);
    }

    private void TriggerGamepadUpdate(InputEventPtr eventPtr, Gamepad gamepad)
    {
        var pressedKeys = new List<string>();
        var axisStatus = new List<AxisStatus>();

        foreach (var kvp in gamepadControlNames)
        {
            var control = kvp.Key;
            var name = kvp.Value;

            if (control is ButtonControl button)
            {
                bool pressed = button.ReadValueFromEvent(eventPtr) > 0;
                if (pressed)
                {
                    pressedKeys.Add(name);
                }
            }
            else if (control is StickControl stick)
            {
                Vector2 value = stick.ReadValueFromEvent(eventPtr);
                if (value.magnitude > 0.1f)
                {
                    axisStatus.Add(new AxisStatus
                    {
                        axisName = name,
                        value = value
                    });
                }
            }
            else if (control is DpadControl dpad)
            {
                Vector2 value = dpad.ReadValueFromEvent(eventPtr);
                if (value.magnitude > 0.1f)
                {
                    axisStatus.Add(new AxisStatus
                    {
                        axisName = name,
                        value = value
                    });
                }
            }
        }

        var inputStatusParams = new Dictionary<string, object>
        {
            { "controlId", gamepad.deviceId },
            { "pressedKeys", pressedKeys },
            { "axisStatus", axisStatus }
        };

        _eventsService?.Trigger(GameEvent.EventType.gamepadUpdate, inputStatusParams);
    }

    public void SetEventsService(IEventsService service)
    {
        _eventsService = service;
    }
}