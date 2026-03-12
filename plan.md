# Plan: Hide drafts while status menu (objStatDisplay) is open

## Context
Opening the stats menu (objStatDisplay via objPortrait click) during a draft causes graphical overlap. Currently objPortrait blocks clicks only during objPsynergyDraft but not objDjinnDraft or objSummonDraft.

## Approach
Two changes:

### 1. Allow opening objStatDisplay during all drafts
**File:** `objects/objPortrait/Mouse_7.gml`
- Remove the `objPsynergyDraft`-only block at line 2
- Instead, when any draft is open, toggle objStatDisplay without calling `DestroyAllBut()` or `DeleteButtons()`/`CreateOptions()` (those would destroy the draft)
- Just create/destroy objStatDisplay directly when a draft exists

### 2. Hide draft drawing while objStatDisplay exists
**Files:**
- `objects/objPsynergyDraft/Draw_64.gml`
- `objects/objDjinnDraft/Draw_64.gml`
- `objects/objSummonDraft/Draw_64.gml`

Add at the top of each Draw_64:
```gml
if instance_exists(objStatDisplay) { exit }
```

This skips drawing the draft UI while the status menu is visible. The draft object and its state remain intact — it just doesn't render.

### 3. Also hide draft confirm/cancel buttons while status is open
The draft creates objConfirm and objCancel. These should also be hidden.

Toggle `visible = false` on objConfirm, objCancel, objHalfMenu when opening objStatDisplay during a draft, and restore `visible = true` when closing it.

## Changes

### 1. `objects/objPortrait/Mouse_7.gml`
Replace the `objPsynergyDraft`-only block. New logic:
```gml
var _inDraft = instance_exists(objPsynergyDraft) or instance_exists(objDjinnDraft) or instance_exists(objSummonDraft)

if _inDraft {
    // Toggle stats overlay without touching draft state
    if instance_exists(objStatDisplay) {
        instance_destroy(objStatDisplay)
        // Restore draft UI visibility
        with (objConfirm) { visible = true }
        with (objCancel) { visible = true }
        with (objHalfMenu) { visible = true }
    } else {
        instance_create_depth(0,0,0,objStatDisplay)
        // Hide draft UI
        with (objConfirm) { visible = false }
        with (objCancel) { visible = false }
        with (objHalfMenu) { visible = false }
    }
    exit
}

// --- existing non-draft toggle below (DestroyAllBut etc.) ---
```

### 2. Draft Draw_64 guards
Add to top of each file, after `draw_set_font(GoldenSun)`:
```gml
if instance_exists(objStatDisplay) { exit }
```

**Files:**
- `objects/objPsynergyDraft/Draw_64.gml`
- `objects/objDjinnDraft/Draw_64.gml`
- `objects/objSummonDraft/Draw_64.gml`

## Verification
- Open each draft type → click portrait → stats appear, draft hidden
- Click portrait again → stats close, draft reappears and works normally
- Non-draft stats toggle still works as before
