using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using TMPro;

public static partial class PortugueseSupport
{
    static TMP_FontAsset fallback;
    static bool initializing;
    sealed class LayoutState
    {
        public TMP_Text Text;
        public float Maximum;
        public bool Wrap;
    }
    static readonly Dictionary<int, LayoutState> layouts = new Dictionary<int, LayoutState>();

    public static UnityEngine.TextCore.LowLevel.FontEngineError LoadFace(Font font, int size)
    {
        if (font != null && font.name.IndexOf("Georgia", StringComparison.OrdinalIgnoreCase) >= 0)
            return UnityEngine.TextCore.LowLevel.FontEngine.LoadFontFace(
                System.IO.Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.Fonts), "georgia.ttf"), size);
        return UnityEngine.TextCore.LowLevel.FontEngine.LoadFontFace(font, size);
    }

    static void EnsureFont()
    {
        if (fallback != null) return;
        Font font = Font.CreateDynamicFontFromOSFont("Georgia", 90);
        fallback = TMP_FontAsset.CreateFontAsset(font, 90, 9,
            UnityEngine.TextCore.LowLevel.GlyphRenderMode.SDFAA, 1024, 1024,
            AtlasPopulationMode.Dynamic, true);
        if (fallback == null) throw new Exception("Unable to create Portuguese fallback font.");
        fallback.name = "Portuguese Latin fallback";
        UnityEngine.Object.DontDestroyOnLoad(font);
        UnityEngine.Object.DontDestroyOnLoad(fallback);
        string missing;
        bool ok = fallback.TryAddCharacters("áàâãäéèêëíìîïóòôõöúùûüçÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇºª–—…", out missing, false);
        Debug.Log("PTBR 0.4.0 font ready; complete=" + ok + "; missing=" + missing);
        if (TMP_Settings.fallbackFontAssets != null && !TMP_Settings.fallbackFontAssets.Contains(fallback))
            TMP_Settings.fallbackFontAssets.Add(fallback);
    }

    // Called again immediately before rendering: the game may reset font settings after OnEnable.
    public static void Configure(TMP_Text text)
    {
        if (initializing || text == null) return;
        try
        {
            initializing = true;
            string localized = TranslateLabel(text.text);
            if (localized != text.text) text.text = localized;
            EnsureFont();
            TMP_FontAsset original = text.font;
            if (original != null)
            {
                if (original.fallbackFontAssetTable == null)
                    original.fallbackFontAssetTable = new List<TMP_FontAsset>();
                if (original != fallback && !original.fallbackFontAssetTable.Contains(fallback))
                    original.fallbackFontAssetTable.Add(fallback);
            }
            LayoutState state;
            int id = text.GetInstanceID();
            if (!layouts.TryGetValue(id, out state) || state.Text != text)
            {
                state = new LayoutState();
                state.Text = text;
                state.Maximum = text.enableAutoSizing && text.fontSizeMax > 0 ? text.fontSizeMax : text.fontSize;
                state.Wrap = text.enableWordWrapping;
                layouts[id] = state;
            }
            else if (!text.enableAutoSizing && text.fontSize > 0)
            {
                // Respect an explicit size assigned by the game, then fit that size to the box.
                state.Maximum = text.fontSize;
            }
            if (state.Maximum <= 0 || text.rectTransform.rect.width <= 0 || text.rectTransform.rect.height <= 0) return;
            // A percentage of fontSizeMax is unsafe: several game labels use a very
            // large maximum while their actual fitted size is less than 20 points.
            float minimum = Mathf.Min(5f, state.Maximum);
            if (!Mathf.Approximately(text.fontSizeMax, state.Maximum)) text.fontSizeMax = state.Maximum;
            if (!Mathf.Approximately(text.fontSizeMin, minimum)) text.fontSizeMin = minimum;
            if (!text.enableAutoSizing) text.enableAutoSizing = true;
            bool shortButton = text.GetComponentInParent<Button>() != null && text.text != null && text.text.Length <= 24;
            bool wrap = shortButton ? false : state.Wrap;
            if (text.enableWordWrapping != wrap) text.enableWordWrapping = wrap;
        }
        catch (Exception e) { Debug.LogError("PTBR 0.4.0 font setup: " + e); }
        finally { initializing = false; }
    }

}
