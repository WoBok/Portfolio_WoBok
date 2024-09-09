using UnityEngine;

public class GBHighlightDemo : MonoBehaviour
{
    public GameObject[] gameObjects;
    public GameObject[] addGameObjects;
    public float duration;
    public int index;
    public void Pattern1()
    {
        GBHighlight.Open(gameObjects, duration);
    }
    public void Pattern2()
    {
        GBHighlight.Open(gameObjects, gameObjects[Mathf.Min(index, gameObjects.Length - 1)].transform.position, duration);
    }
    public void AddNewObjects()
    {
        GBHighlight.AddGameObjects(addGameObjects);
    }
    public void Close()
    {
        GBHighlight.Close();
    }
}