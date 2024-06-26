using UnityEngine;
using UnityEditor;

[CustomEditor(typeof(MaterialSetPass))] [CanEditMultipleObjects]
public class MaterialSetPassEditor : Editor
{
    private Material m_mat;

    private void OnEnable()
    {
        MaterialSetPass mss = target as MaterialSetPass;
        MeshRenderer mr = mss.GetComponent<MeshRenderer>();
        if (mr != null)
        {
            m_mat = mr.sharedMaterial;
        }
    }

    public override void OnInspectorGUI()
    {
        EditorGUILayout.HelpBox("���̴��� ����Ʈ��� �±׸� ���� Pass�� �־����. �������� Render Features���� Render Objects�� LightMode Tags�� ������ ���Ŀ� �۵���", MessageType.Info);
        base.OnInspectorGUI();
        if (m_mat != null)
        {
            MaterialSetPass msp = target as MaterialSetPass;

            GUILayout.BeginHorizontal();
            if (GUILayout.Button("Enable " + msp.m_lightMode))
            {
                m_mat.SetShaderPassEnabled(msp.m_lightMode, true);
            }
            if (GUILayout.Button("Disable " + msp.m_lightMode))
            {
                m_mat.SetShaderPassEnabled(msp.m_lightMode, false);
            }
            GUILayout.EndHorizontal();
        }
    }
}
