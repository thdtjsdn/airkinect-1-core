#include "FlashRuntimeExtensions.h"
extern "C" {
	__declspec(dllexport) void initializer(void** extData, FREContextInitializer* ctxInitializer, FREContextFinalizer* ctxFinalizer);
	__declspec(dllexport) void finalizer(void* extData);

	//Start and Stop Declarations
	__declspec(dllexport) FREObject AIRKINECT_startKinect(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]);
	__declspec(dllexport) FREObject AIRKINECT_stopKinect(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]);

	//Supported
	__declspec(dllexport) FREObject AIRKINECT_avaliableKinect(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]);

	//Angle Modifiers
	__declspec(dllexport) FREObject AIRKINECT_getKinectAngle(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]);
	__declspec(dllexport) FREObject AIRKINECT_setKinectAngle(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]);

	//Skeleton Polling
	__declspec(dllexport) FREObject AIRKINECT_getSkeletonFrameData(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]);
	__declspec(dllexport) FREObject AIRKINECT_setTransformSmoothingParameters(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]);

	//Frame Polling
	__declspec(dllexport) FREObject AIRKINECT_getRGBFrame(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]);
	__declspec(dllexport) FREObject AIRKINECT_getDepthFrame(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]);

	static void CALLBACK onDeviceStatus(const NuiStatusData *pStatusData);
	RGBQUAD Nui_ShortToQuad_Depth( USHORT s, BOOLEAN usePlayer );
	NUI_IMAGE_RESOLUTION getResolutionFromIndex(uint32_t index);
}