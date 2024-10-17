/*|| https://wake.tools ||                                          | license | Apache License Version 2.0 |
  | --------------------------------------------------------------------------------------------------+-+++|>
  +-  jit.h
  |---------------------------------------------------------------------------------------------------+-+++|>
  +-  Jit main header
  |
  |-----|--------|---------------------|-----------------------------|--------------------------------+-+++|>
*/
#ifndef HDEF_WAKE
#define HDEF_WAKE

//#include "jit.h"
#include "view.h"
#include "nod.h"

typedef uint32_t process_handle_t;
/////////////////////////////////////
typedef void (*hview_fptr)(process_handle_t handle, view_t _out);
typedef void (*hcout_fptr)(process_handle_t handle, const char* _out);
//
typedef struct wake_param_t{
   hcout_fptr stdout_cb;
   hcout_fptr stderr_cb;
   hcout_fptr commandline_cb;
   //view_fptr process_launch_cb;
   bool no_execute;
   Nod* env_nod;
   char* env_json;
   
   bool no_run;

}wake_param_t;
//////////////////////////////////////////

extern int wake_app(view_t arg, wake_param_t _dataout);
extern size_t send_process_input(process_handle_t process_handle, char* input);


typedef int (*wake_app_fptr)(view_t arg, wake_param_t _dataout);


#endif

