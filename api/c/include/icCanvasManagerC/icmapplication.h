#ifndef __ICCANVASMANAGER_CAPI__ICM_APPLICATION__H__
#define __ICCANVASMANAGER_CAPI__ICM_APPLICATION__H__

#include <icCanvasManagerC.h>

#ifdef __cplusplus
extern "C" {
#endif

    typedef void icm_application;

    icm_application* icm_application_get_instance();

    void icm_application_background_tick(icm_application *this);
    icm_renderscheduler* icm_application_get_render_scheduler(icm_application *this);

#ifdef __cplusplus
}
#endif

#endif
