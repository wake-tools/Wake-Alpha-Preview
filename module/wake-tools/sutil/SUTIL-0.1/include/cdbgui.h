#pragma once
/*
The typical debug UI overlay useful for most sokol-app samples
*/
#if defined(USE_DBG_UI)
#include "sokol_app.h"
SOKOL_IMGUI_API_DECL void __cdbgui_setup(int sample_count);
SOKOL_IMGUI_API_DECL void __cdbgui_shutdown(void);
SOKOL_IMGUI_API_DECL void __cdbgui_draw(void);
SOKOL_IMGUI_API_DECL void __cdbgui_event(const sapp_event* e);
#else
static inline SOKOL_IMGUI_API_DECL void __cdbgui_setup(int sample_count) { (void)(sample_count); }
static inline SOKOL_IMGUI_API_DECL void __cdbgui_shutdown(void) { }
static inline SOKOL_IMGUI_API_DECL void __cdbgui_draw(void) { }
static inline SOKOL_IMGUI_API_DECL void __cdbgui_event(const sapp_event* e) { (void)(e); }
#endif

