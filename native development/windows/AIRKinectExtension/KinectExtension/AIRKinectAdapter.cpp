#include "stdafx.h"
#include "AIRKinectAdapter.h"

NUI_TRANSFORM_SMOOTH_PARAMETERS m_transformSmoothingParameters;

AIRKinectAdapter::AIRKinectAdapter(){
	setDefaultSmoothingParameters();
}

void AIRKinectAdapter::reset() {
	context							= NULL;
		
	RGBFrameBuffer					= NULL;
	depthFrameBuffer				= NULL;

	m_hNextDepthFrameEvent			= NULL;
    m_hNextRGBFrameEvent			= NULL;
    m_hNextSkeletonEvent			= NULL;
    
	m_pDepthStreamHandle			= NULL;
    m_pRGBStreamHandle				= NULL;
    
	m_hThNuiProcess					= NULL;
    m_hEvNuiProcessStop				= NULL;
}

void AIRKinectAdapter::setDefaultSmoothingParameters() {
	//OutputDebugString( "AIRKinect Adapter :: setDefaultSmoothingParameters\n" );
	m_transformSmoothingParameters.fCorrection=0.5f;
	m_transformSmoothingParameters.fSmoothing=0.5f;
	m_transformSmoothingParameters.fPrediction =0.5f;
	m_transformSmoothingParameters.fJitterRadius =0.05f;
	m_transformSmoothingParameters.fMaxDeviationRadius=0.04f;
}

bool AIRKinectAdapter::isAvailable() {
	//OutputDebugString( "AIRKinect Adapter :: isAvailable\n" );
	HRESULT hr = NuiInitialize(NUI_INITIALIZE_FLAG_USES_SKELETON);
	NuiShutdown( );
	return !FAILED(hr);
}

HRESULT AIRKinectAdapter::start(uint32_t dwFlags) {
	//OutputDebugString( "AIRKinect Adapter :: Start\n" );
	HRESULT                hr;

	hr = NuiInitialize(dwFlags);	
    if (FAILED(hr)) return hr;

	m_hNextSkeletonEvent	= CreateEvent( NULL, TRUE, FALSE, NULL );
	m_hNextRGBFrameEvent	= CreateEvent( NULL, TRUE, FALSE, NULL );
	m_hNextDepthFrameEvent	= CreateEvent( NULL, TRUE, FALSE, NULL );

	if(dwFlags & NUI_INITIALIZE_FLAG_USES_SKELETON) {
		hr = NuiSkeletonTrackingEnable( m_hNextSkeletonEvent, 0 );
		if (FAILED(hr)) return hr;
	}

	if(dwFlags & NUI_INITIALIZE_FLAG_USES_COLOR) {
		hr = NuiImageStreamOpen( NUI_IMAGE_TYPE_COLOR, NUI_IMAGE_RESOLUTION_640x480, 0, 2, m_hNextRGBFrameEvent, &m_pRGBStreamHandle );
		if (FAILED(hr)) return hr;
	}

	if(dwFlags & NUI_INITIALIZE_FLAG_USES_DEPTH_AND_PLAYER_INDEX){
		hr = NuiImageStreamOpen(NUI_IMAGE_TYPE_DEPTH_AND_PLAYER_INDEX, NUI_IMAGE_RESOLUTION_320x240, 0, 2, m_hNextDepthFrameEvent, &m_pDepthStreamHandle );
		if (FAILED(hr)) return hr;
	}

    m_hEvNuiProcessStop=CreateEvent(NULL, FALSE, FALSE, NULL);
    m_hThNuiProcess=CreateThread(NULL, 0, processThread, this, 0, NULL);
    return hr;
}

void AIRKinectAdapter::dispose( ){
	//OutputDebugString( "AIRKinect Adapter :: Dispose\n" );
    if(m_hEvNuiProcessStop!=NULL) {
        SetEvent(m_hEvNuiProcessStop);

        if(m_hThNuiProcess!=NULL) {
            WaitForSingleObject(m_hThNuiProcess,INFINITE);
            CloseHandle(m_hThNuiProcess);
        }
        CloseHandle(m_hEvNuiProcessStop);
    }

    NuiShutdown( );
	
    if( m_hNextSkeletonEvent && ( m_hNextSkeletonEvent != INVALID_HANDLE_VALUE ) ) {
        CloseHandle( m_hNextSkeletonEvent );
        m_hNextSkeletonEvent = NULL;
		NuiSkeletonTrackingDisable();
    }

    if( m_hNextDepthFrameEvent && ( m_hNextDepthFrameEvent != INVALID_HANDLE_VALUE ) ) {
        CloseHandle( m_hNextDepthFrameEvent );
        m_hNextDepthFrameEvent = NULL;
    }
    if( m_hNextRGBFrameEvent && ( m_hNextRGBFrameEvent != INVALID_HANDLE_VALUE ) ) {
        CloseHandle( m_hNextRGBFrameEvent );
        m_hNextRGBFrameEvent = NULL;
    }

	reset();
}

DWORD WINAPI AIRKinectAdapter::processThread(LPVOID pParam) {
	//OutputDebugString( "AIRKinect Adapter :: processThread\n" );
	AIRKinectAdapter *pthis=(AIRKinectAdapter *) pParam;
    HANDLE	hEvents[4];
    int			nEventIdx;

    hEvents[0]=pthis->m_hEvNuiProcessStop;
	hEvents[1]=pthis->m_hNextSkeletonEvent;
	hEvents[2]=pthis->m_hNextRGBFrameEvent;
    hEvents[3]=pthis->m_hNextDepthFrameEvent;
    
    while(1) {
        nEventIdx=WaitForMultipleObjects(sizeof(hEvents)/sizeof(hEvents[0]),hEvents,FALSE,100);

        if(nEventIdx==0) break;

        switch(nEventIdx) {
            case 1:
				pthis->onSkeletonFrame( );
                break;
            case 2:
                pthis->onRGBFrame();
                break;
            case 3:
                pthis->onDepthFrame();
                break;
        }
    }

	pthis		= NULL;

    return (0);
}

void AIRKinectAdapter::onRGBFrame( ) {
	//OutputDebugString( "AIRKinect Adapter :: onRGBFrame\n" );
    const NUI_IMAGE_FRAME * pImageFrame = NULL;

    HRESULT hr = NuiImageStreamGetNextFrame(m_pRGBStreamHandle, 0, &pImageFrame );
    if (FAILED(hr))return;

    NuiImageBuffer * pTexture = pImageFrame->pFrameTexture;
    KINECT_LOCKED_RECT LockedRect;
    pTexture->LockRect( 0, &LockedRect, NULL, 0 );
    if( LockedRect.Pitch != 0 ) {
        RGBFrameBuffer = (BYTE *) LockedRect.pBits;

		const uint8_t* statusCode = (const uint8_t*) "RGBFrame";
		const uint8_t* level = (const uint8_t*) "";
		FREDispatchStatusEventAsync(context, statusCode, level);
    }
    else
    {
        //OutputDebugString( "Buffer length of received texture is bogus\r\n" );
    }

    NuiImageStreamReleaseFrame( m_pRGBStreamHandle, pImageFrame );
}


void AIRKinectAdapter::onDepthFrame( ) {
	//OutputDebugString( "AIRKinect Adapter :: onDepthFrame\n" );
    const NUI_IMAGE_FRAME * pImageFrame = NULL;

    HRESULT hr = NuiImageStreamGetNextFrame( m_pDepthStreamHandle, 0, &pImageFrame );

    if(FAILED(hr)) return;

    NuiImageBuffer * pTexture = pImageFrame->pFrameTexture;
    KINECT_LOCKED_RECT LockedRect;
    pTexture->LockRect( 0, &LockedRect, NULL, 0 );
    if( LockedRect.Pitch != 0 ) {
		depthFrameBuffer = (BYTE *) LockedRect.pBits;

		const uint8_t* statusCode = (const uint8_t*) "depthFrame";
		const uint8_t* level = (const uint8_t*) "";
		FREDispatchStatusEventAsync(context, statusCode, level);
    } else {
        //OutputDebugString( "Buffer length of received texture is bogus\r\n" );
    }

    NuiImageStreamReleaseFrame( m_pDepthStreamHandle, pImageFrame );
}

void AIRKinectAdapter::onSkeletonFrame( ) {
	//OutputDebugString( "AIRKinect Adapter :: onSkeletonFrame\n" );
	NUI_SKELETON_FRAME SkeletonFrame;

    HRESULT hr = NuiSkeletonGetNextFrame( 0, &SkeletonFrame );

	NuiTransformSmooth(&SkeletonFrame, &m_transformSmoothingParameters);
	skeletonFrameBuffer = SkeletonFrame;

	const uint8_t* statusCode = (const uint8_t*) "skeletonFrame";
	const uint8_t* level = (const uint8_t*) "";
	
	FREDispatchStatusEventAsync(context, statusCode, level);
}

void AIRKinectAdapter::setTransformSmoothingParameters(NUI_TRANSFORM_SMOOTH_PARAMETERS smoothingParameters) {
	//OutputDebugString( "AIRKinect Adapter :: setTransformSmoothingParameters\n" );
	m_transformSmoothingParameters = smoothingParameters;
}


HRESULT AIRKinectAdapter::cameraElevationGetAngle(LONG * value) {
	//OutputDebugString( "AIRKinect Adapter :: cameraElevationGetAngle\n" );
	return NuiCameraElevationGetAngle(value);
}

HRESULT AIRKinectAdapter::cameraElevationSetAngle(LONG value) {
	//OutputDebugString( "AIRKinect Adapter :: cameraElevationSetAngle\n" );
	return NuiCameraElevationSetAngle(value);
}