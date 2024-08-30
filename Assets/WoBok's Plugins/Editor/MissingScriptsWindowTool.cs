using System.Collections.Generic;
using System.IO;
using UnityEditor;
using UnityEngine;

namespace Tools.MissingScriptsToolWindowTool
{
    public class MissingScriptsWindowTool : EditorWindow
    {
        [MenuItem("Tools/Missing Scripts Window")]
        public static void ShowWindow()
        {
            GetWindow(typeof(MissingScriptsWindowTool), false, "Missing Scripts GameObjects");
        }

        List<GameObject> missGamoObjList = new List<GameObject>();

        private void OnEnable()
        {

            SelectMissingGameObjects(ref missGamoObjList);
        }

        private Vector2 scrollPosition = Vector2.zero;
        private void OnGUI()
        {
            GUILayout.BeginHorizontal();
            GUILayout.Box("丢失脚本物体列表:");
            if (GUILayout.Button("刷新列表", GUILayout.Width(150)))
            {
                SelectMissingGameObjects(ref missGamoObjList);
            }
            if (GUILayout.Button("清除无效脚本", GUILayout.Width(150)))
            {
                RemoveMissingGameObjects(ref missGamoObjList);
            }
            GUILayout.EndHorizontal();

            GUILayout.Space(10);
            if (missGamoObjList.Count == 0)
            {
                GUILayout.Label("没有丢失脚本的物体");
                return;
            }

            scrollPosition = GUILayout.BeginScrollView(scrollPosition);

            for (int i = 0; i < missGamoObjList.Count; i++)
            {
                GUILayout.BeginHorizontal("Box", GUILayout.Height(30));

                GUILayout.Label(i.ToString(), "AssetLabel", GUILayout.Width(40));
                GUILayout.Space(10);
                if (GUILayout.Button(missGamoObjList[i].name, "AnimLeftPaneSeparator"))
                {
                    GameObject selectTarget = missGamoObjList[i];
                    while (selectTarget.transform.parent != null)
                    {
                        selectTarget = selectTarget.transform.parent.gameObject;
                    }
                    EditorGUIUtility.PingObject(selectTarget);
                    Selection.activeObject = selectTarget;
                }

                GUILayout.EndHorizontal();
                GUILayout.Space(5);
            }

            GUILayout.EndScrollView();
        }

        private static void SelectMissingGameObjects(ref List<GameObject> gameObjList)
        {
            gameObjList.Clear();

            string[] paths = Directory.GetFiles("Assets", "*.prefab", SearchOption.AllDirectories);
            for (int i = 0; i < paths.Length; i++)
            {

                if (EditorUtility.DisplayCancelableProgressBar("查找GameObject···", "数量 : " + i, (float)i / paths.Length))
                {
                    EditorUtility.ClearProgressBar();
                    break;
                }

                GameObject tempObj = AssetDatabase.LoadAssetAtPath<GameObject>(paths[i]);
                if (tempObj != null)
                {
                    Transform[] transArr = tempObj.GetComponentsInChildren<Transform>();
                    for (int j = 0; j < transArr.Length; j++)
                    {
                        Component[] components = transArr[j].GetComponents<Component>();
                        for (int k = 0; k < components.Length; k++)
                        {
                            if (components[k] == null)
                            {
                                if (!gameObjList.Contains(transArr[j].gameObject))
                                    gameObjList.Add(transArr[j].gameObject);
                            }
                        }
                    }
                }
            }
            EditorUtility.ClearProgressBar();
        }

        private static void RemoveMissingGameObjects(ref List<GameObject> gameObjList)
        {
            if (gameObjList.Count == 0)
                return;

            for (int i = 0; i < gameObjList.Count; i++)
            {
                GameObjectUtility.RemoveMonoBehavioursWithMissingScript(gameObjList[i]);
            }
            AssetDatabase.SaveAssets();
            AssetDatabase.Refresh();
            gameObjList.Clear();
        }

    }

}