#pragma once

#include <MSR_NuiApi.h>
#include "FlashRuntimeExtensions.h"

class AIRKinectAdapter {
public:
										AIRKinectAdapter();
//------------------------------------------------------------------
	void								reset();
	bool								isAvailable();
	HRESULT								start(uint32_t dwFlags);
	void								dispose();
	void								onDepthFrame();
	void								onRGBFrame();
	void								onSkeletonFrame();
	HRESULT								cameraElevationGetAngle(LONG * value);
	HRESULT								cameraElevationSetAngle(LONG value);
	void								setTransformSmoothingParameters(NUI_TRANSFORM_SMOOTH_PARAMETERS smoothingParameters);
	void								setDefaultSmoothingParameters();
	void								onConnectionError();

	FREContext							context;

	NUI_SKELETON_FRAME					skeletonFrameBuffer;
	BYTE *								RGBFrameBuffer;
	BYTE *								depthFrameBuffer;

private:
	static DWORD WINAPI					processThread(LPVOID pParam);

	NUI_TRANSFORM_SMOOTH_PARAMETERS		m_transformSmoothingParameters;
	uint32_t							m_brokenFrames;

	HANDLE								m_hThNuiProcess;
    HANDLE								m_hEvNuiProcessStop;

    HANDLE								m_hNextDepthFrameEvent;
    HANDLE								m_hNextRGBFrameEvent;
    HANDLE								m_hNextSkeletonEvent;

    HANDLE								m_pDepthStreamHandle;
    HANDLE								m_pRGBStreamHandle;
};