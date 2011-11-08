#pragma once

#include <MSR_NuiApi.h>
#include "FlashRuntimeExtensions.h"

class AIRKinectAdapter {
public:
										AIRKinectAdapter();
//------------------------------------------------------------------
	void								reset();
	bool								isAvailable();
	HRESULT								start(uint32_t dwFlags, _NUI_IMAGE_RESOLUTION colorImageResolution = NUI_IMAGE_RESOLUTION_1280x1024, _NUI_IMAGE_RESOLUTION depthImageResolution = NUI_IMAGE_RESOLUTION_320x240);
	void								dispose();
	void								onDeviceStatus(const NuiStatusData *pStatusData);
	void								onDepthFrame();
	void								onRGBFrame();
	void								onSkeletonFrame();
	HRESULT								cameraElevationGetAngle(LONG * value);
	HRESULT								cameraElevationSetAngle(LONG value);
	void								setTransformSmoothingParameters(NUI_TRANSFORM_SMOOTH_PARAMETERS smoothingParameters);
	void								setDefaultSmoothingParameters();

	FREContext							context;

	NUI_SKELETON_FRAME					skeletonFrameBuffer;
	BYTE *								RGBFrameBuffer;
	BYTE *								depthFrameBuffer;
	BOOLEAN								depthUsesPlayerIndex;

	DWORD								RGBWidth;
	DWORD								RGBHeight;

	DWORD								DepthWidth;
	DWORD								DepthHeight;

private:
	static DWORD WINAPI					processThread(LPVOID pParam);

	NUI_TRANSFORM_SMOOTH_PARAMETERS		m_transformSmoothingParameters;

	HANDLE								m_hThNuiProcess;
    HANDLE								m_hEvNuiProcessStop;

    HANDLE								m_hNextDepthFrameEvent;
    HANDLE								m_hNextRGBFrameEvent;
    HANDLE								m_hNextSkeletonEvent;

    HANDLE								m_pDepthStreamHandle;
    HANDLE								m_pRGBStreamHandle;
};