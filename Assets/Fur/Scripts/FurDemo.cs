using System.Collections;
using UnityEngine;

public class FurDemo : MonoBehaviour
{
    public Animator[] animators;
    void Start()
    {
        StartPlayAnimations();
    }
    void StartPlayAnimations()
    {
        foreach (var animator in animators)
        {
            animator.enabled = false;
        }
        StartCoroutine(PlayAnimations());
    }
    IEnumerator PlayAnimations()
    {
        int count = 0;
        while (count < animators.Length)
        {
            animators[count].enabled = true;
            count++;
            yield return new WaitForSeconds(2);
        }
    }
}