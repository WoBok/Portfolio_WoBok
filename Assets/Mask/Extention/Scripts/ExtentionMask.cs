using System;
using System.Collections;
using UnityEngine;
using UnityEngine.Rendering.Universal;

public class ExtentionMask : MonoBehaviour
{
    public int index;
    public float duration;
    Coroutine m_Coroutine;
    Vector3 m_Scale;
    void Start()
    {
        m_Scale = transform.localScale;
    }
    public void Open()
    {
        Open(index, duration, null);
    }
    public void Open(int index, float duration, Action callback = null)
    {
        var URPData = Camera.main.GetComponent<UniversalAdditionalCameraData>();
        if (URPData != null)
        {
            URPData.SetRenderer(index);
            StopCoroutine();
            m_Coroutine = StartCoroutine(OpenMask(duration, () =>
            {
                Close();
                callback?.Invoke();
                StopCoroutine();
            }));
        }
    }
    public void Close()
    {
        var URPData = Camera.main.GetComponent<UniversalAdditionalCameraData>();
        if (URPData != null)
        {
            URPData.SetRenderer(0);
        }
    }
    void StopCoroutine()
    {
        if (m_Coroutine != null)
            StopCoroutine(m_Coroutine);
    }
    IEnumerator OpenMask(float duration, Action callback = null)
    {
        var distance = Vector3.Distance(transform.position, Camera.main.transform.position);
        var speed = distance / duration;
        var timer = 0f;
        var invoked = false;
        transform.localScale = m_Scale;
        while (transform.localScale.x <= Camera.main.farClipPlane)
        {
            transform.localScale += Vector3.one * speed * Time.fixedDeltaTime * 2;

            timer += Time.fixedDeltaTime;
            if (timer >= duration && !invoked)
            {
                callback?.Invoke();
                invoked = true;
            }
            yield return new WaitForFixedUpdate();
        }
    }
}