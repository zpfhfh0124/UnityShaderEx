using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Coffee.UIEffects;
using UnityEngine.UI;

namespace GT
{
    public class Manager : MonoBehaviour
    {
        [Header("기능 버튼")] 
        [SerializeField] private Button btn_bgFXmode;
        
        [Header("이펙트")]
        [SerializeField] private UITransitionEffect uiTrFX_bg;
        [SerializeField] private UIEffect uiFX_unitychan;
        [SerializeField] private UIHsvModifier uiHsv_unitychan;

        private void Start()
        {
            btn_bgFXmode.onClick.AddListener(OnBgFxChange);  
        }

        void OnBgFxChange()
        {
            var curFxMode = uiTrFX_bg.effectMode;
            //curFxMode %= Enum.GetValues(typeof(UITransitionEffect.EffectMode)).Length;
        }
    }
}