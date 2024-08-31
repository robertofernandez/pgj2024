using UnityEngine;
using System.Collections;

public class CharacterFollower : MonoBehaviour {
	public Transform characterTransform;
	public GameObject charactersManagerObject;
	public float minYinGroundZone;

	private CharactersManager charactersManager;

	void Start () {
		charactersManager = charactersManagerObject.GetComponent<CharactersManager>();
		if(charactersManager == null) {
			Debug.Log("charactersManager null");
		}
	}

	void Update () {
		Transform characterTransform = charactersManager.getMainPlayerTransform();
		if(characterTransform == null) {
			Debug.Log("characterTransform null");
		}
		transform.position = new Vector3(characterTransform.position.x, characterTransform.position.y, transform.position.z);
	}
}
