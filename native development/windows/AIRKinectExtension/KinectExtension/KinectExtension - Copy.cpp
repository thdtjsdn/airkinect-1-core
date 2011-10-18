// KinectExtension.cpp : Defines the exported functions for the DLL application.
//
#include "stdafx.h"
#include <string>
#include <stdlib.h>
#include <Windows.h>
#include <Ole2.h>
#include <MSR_NuiApi.h>
#include <MSR_NuiSkeleton.h>
#include <intrin.h>
#include "KinectExtension.h"

extern "C" {
	HANDLE m_hNextSkeletonEvent;

	HANDLE m_rgbStream;
	HANDLE m_hNextRGBFrameEvent;

	HANDLE m_depthStream;
	HANDLE m_hNextDepthFrameEvent;

	NUI_TRANSFORM_SMOOTH_PARAMETERS _transformSmoothingParameters;

	FREObject FIFTEENLETTERS_KINECT_init(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {

		_transformSmoothingParameters.fCorrection=0.5f;
		_transformSmoothingParameters.fSmoothing=0.5f;
		_transformSmoothingParameters.fPrediction =0.5f;
		_transformSmoothingParameters.fJitterRadius =0.05f;
		_transformSmoothingParameters.fMaxDeviationRadius=0.04f;

		return NULL;
	}

	FREObject FIFTEENLETTERS_KINECT_startKinect(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
		//HRESULT hr = NuiInitialize(NUI_INITIALIZE_FLAG_USES_SKELETON);
		HRESULT hr = NuiInitialize(NUI_INITIALIZE_FLAG_USES_DEPTH_AND_PLAYER_INDEX | NUI_INITIALIZE_FLAG_USES_SKELETON | NUI_INITIALIZE_FLAG_USES_COLOR);
		
		bool success = !FAILED(hr);
		if(success) {
			m_hNextSkeletonEvent = CreateEvent( NULL, TRUE, FALSE, NULL );
			NuiSkeletonTrackingEnable(m_hNextSkeletonEvent, NULL);

			HRESULT imagehr=S_OK;
			m_hNextRGBFrameEvent=CreateEvent( NULL, TRUE, FALSE, NULL );
			imagehr = NuiImageStreamOpen(NUI_IMAGE_TYPE_COLOR, NUI_IMAGE_RESOLUTION_640x480, 0,2,m_hNextRGBFrameEvent,&m_rgbStream);
			
			HRESULT depthhr=S_OK;
			m_hNextDepthFrameEvent=CreateEvent( NULL, TRUE, FALSE, NULL );
	 		depthhr = NuiImageStreamOpen(NUI_IMAGE_TYPE_DEPTH_AND_PLAYER_INDEX, NUI_IMAGE_RESOLUTION_320x240, 0, 2, m_hNextDepthFrameEvent, &m_depthStream );
		}

		FREObject retObj;
		FRENewObjectFromBool(success, &retObj);
		return retObj;
	}
	
	FREObject FIFTEENLETTERS_KINECT_stopKinect(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
		NuiSkeletonTrackingDisable();
		NuiShutdown();
		CloseHandle(m_hNextSkeletonEvent);
		CloseHandle(m_rgbStream);
		CloseHandle(m_depthStream);
		m_hNextSkeletonEvent = NULL;
		m_rgbStream = NULL;
		m_depthStream = NULL;


		FREObject rtnValue;
		FRENewObjectFromBool(true, &rtnValue);
		return rtnValue;
	}

	FREObject FIFTEENLETTERS_KINECT_avaliableKinect(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
		FREObject retVal;

		HRESULT hr = NuiInitialize(NUI_INITIALIZE_FLAG_USES_SKELETON);
		NuiShutdown();

		bool success = !FAILED(hr);
		if(success) {
			FRENewObjectFromBool(true, &retVal);
		}else{
			FRENewObjectFromBool(false, &retVal);
		}
		
		return retVal;
	}

	FREObject FIFTEENLETTERS_KINECT_getKinectAngle(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) { 
		long value;
		NuiCameraElevationGetAngle(&value);
		
		FREObject rtnValue;
		FRENewObjectFromInt32(value, &rtnValue);
		return rtnValue;
	}

	FREObject FIFTEENLETTERS_KINECT_setKinectAngle(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) { 
		int32_t value;
		FREGetObjectAsInt32(argv[0], &value);
		NuiCameraElevationSetAngle(value);
		
		FREObject rtnValue;
		FRENewObjectFromInt32(value, &rtnValue);
		return rtnValue;
	}

	FREObject FIFTEENLETTERS_KINECT_setTransformSmoothingParameters(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) { 
		FREObject retVal;
		if(argc > 0) {
			FREObject smoothingParams = argv[0];	

			FREObject fCorrection;
			FREResult result = FREGetObjectProperty(smoothingParams, (const uint8_t*) "fCorrection", &fCorrection, NULL);
			if(result == 0){
				FREObject fSmoothing, fPrediction, fJitterRadius, fMaxDeviationRadius;
				FREGetObjectProperty(smoothingParams, (const uint8_t*) "fSmoothing", &fSmoothing, NULL);
				FREGetObjectProperty(smoothingParams, (const uint8_t*) "fPrediction", &fPrediction, NULL);
				FREGetObjectProperty(smoothingParams, (const uint8_t*) "fJitterRadius", &fJitterRadius, NULL);
				FREGetObjectProperty(smoothingParams, (const uint8_t*) "fMaxDeviationRadius", &fMaxDeviationRadius, NULL);

				double dbl_fCorrection, dbl_fSmoothing, dbl_fPrediction, dbl_fJitterRadius, dbl_fMaxDeviationRadius;
				FREGetObjectAsDouble(fCorrection, &dbl_fCorrection);
				FREGetObjectAsDouble(fSmoothing, &dbl_fSmoothing);
				FREGetObjectAsDouble(fPrediction, &dbl_fPrediction);
				FREGetObjectAsDouble(fJitterRadius, &dbl_fJitterRadius);
				FREGetObjectAsDouble(fMaxDeviationRadius, &dbl_fMaxDeviationRadius);

				_transformSmoothingParameters.fCorrection=dbl_fCorrection;
				_transformSmoothingParameters.fSmoothing=dbl_fSmoothing;
				_transformSmoothingParameters.fPrediction =dbl_fPrediction;
				_transformSmoothingParameters.fJitterRadius =dbl_fJitterRadius;
				_transformSmoothingParameters.fMaxDeviationRadius=dbl_fMaxDeviationRadius;
			}else{
				FRENewObjectFromBool(false, &retVal);
			}

			FRENewObjectFromBool(true, &retVal);
		}else{
			FRENewObjectFromBool(false, &retVal);
		}

		return retVal;
	}


	FREObject FIFTEENLETTERS_KINECT_getSkeletonFrameData(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) { 
		while(WaitForSingleObject(m_hNextSkeletonEvent, INFINITE) != WAIT_OBJECT_0) { }


		NUI_SKELETON_FRAME SkeletonFrame;
		NuiSkeletonGetNextFrame(0, &SkeletonFrame);	

		NuiTransformSmooth(&SkeletonFrame,&_transformSmoothingParameters);
		FREObject skeletonFrame, skeletonsPositions;
		FREObject skeletonPosition, trackingID, trackingState, elements;
		FREObject element, x, y, z, w;
		
		Vector4 elementPosition;
		short int trackedSkeletons = 0;
		
		FRENewObject( (const uint8_t*) "Vector.<com.fifteenletters.nativeExtensions.kinect.data.SkeletonPosition>", 0, NULL, &skeletonsPositions, NULL);
		
		for(short int i=0; i<NUI_SKELETON_COUNT; i++) {
			if(SkeletonFrame.SkeletonData[i].eTrackingState == NUI_SKELETON_TRACKED) {
				
				FRENewObject( (const uint8_t*) "Vector.<flash.geom.Vector3D>", 0, NULL, &elements, NULL);
				for(uint32_t j=0; j<NUI_SKELETON_POSITION_COUNT; j++) {
					elementPosition = SkeletonFrame.SkeletonData[i].SkeletonPositions[j];
					FRENewObjectFromDouble(elementPosition.x, &x);
					FRENewObjectFromDouble(elementPosition.y, &y);
					FRENewObjectFromDouble(elementPosition.z, &z);
					FRENewObjectFromDouble(elementPosition.w, &w);
					FREObject elementParams [] = {x,y,z,w};
					FRENewObject( (const uint8_t*) "flash.geom.Vector3D", 4, elementParams, &element, NULL);
					FRESetArrayElementAt(elements, j, element);
				}	

				FRENewObjectFromInt32((SkeletonFrame.SkeletonData[i].dwTrackingID), &trackingID);
				FRENewObjectFromInt32((SkeletonFrame.SkeletonData[i].eTrackingState), &trackingState);
				FREObject skeletonParams [] = {trackingID, trackingState, elements};
			
				FRENewObject( (const uint8_t*) "com.fifteenletters.nativeExtensions.kinect.data.SkeletonPosition", 3, skeletonParams, &skeletonPosition, NULL);
				FRESetArrayElementAt(skeletonsPositions, trackedSkeletons, skeletonPosition);
				trackedSkeletons++;
			}
		}
	
		FREObject skelentonFrameParams [] = {skeletonsPositions};
		FRENewObject( (const uint8_t*) "com.fifteenletters.nativeExtensions.kinect.data.SkeletonFrame", 1, skelentonFrameParams, &skeletonFrame, NULL);
		return skeletonFrame;
	}

	FREObject FIFTEENLETTERS_KINECT_getStreamFrame(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) { 
		while(WaitForSingleObject(m_hNextRGBFrameEvent, 2000) != WAIT_OBJECT_0) { }

		const NUI_IMAGE_FRAME * pImageFrame = NULL;
		HRESULT hr = NuiImageStreamGetNextFrame(m_rgbStream,0,&pImageFrame );

		FREObject rtnValue;
		if (SUCCEEDED(hr)) {
			NuiImageBuffer * pTexture = pImageFrame->pFrameTexture;			

			KINECT_LOCKED_RECT LockedRect;
			pTexture->LockRect( 0, &LockedRect, NULL, 0 );
			BYTE * pBuffer = (BYTE*) LockedRect.pBits;

			DWORD width, height;
			NuiImageResolutionToSize(pImageFrame->eResolution, width, height);

			int bytes = width * height * 4;
			
			int32_t m_rgbWk[640*480];
			int32_t *rgbrun = m_rgbWk;
			int32_t * pBufferRun = (int32_t*) pBuffer;

			for( uint32_t x = 0 ; x < width ; x++ ) {
				for( uint32_t y = 0 ; y < height ; y++ ) {
					* rgbrun = 0xff << 24 | *pBufferRun;
					pBufferRun++;
					rgbrun++;
				}
			}

			FREObject objectByteArray = argv[0];

			FREByteArray byteArray;			
			FREObject length;
			FRENewObjectFromUint32(bytes, &length);
			FRESetObjectProperty(objectByteArray, (const uint8_t*) "length", length, NULL);
			FREAcquireByteArray(objectByteArray, &byteArray);
			memcpy(byteArray.bytes, m_rgbWk, bytes);
			FREReleaseByteArray(objectByteArray);
			

			NuiImageStreamReleaseFrame( m_rgbStream, pImageFrame );
			FRENewObjectFromBool(true, &rtnValue);

			/*
			MemoryStream^ stream = gcnew MemoryStream();
			bitmap->Save(stream, ImageFormat::Jpeg);
			array<Byte>^ raw = stream->ToArray();

			uint8_t* output = new uint8_t[width * height * 4];
			int outputSize = (int) stream->Length;
			Marshal::Copy(raw, 0, (IntPtr) output, outputSize);
			
			
			FREObject objectByteArray = argv[0];
			FREByteArray byteArray;
			FREObject length;
			FRENewObjectFromUint32(outputSize, &length);
			FRESetObjectProperty(objectByteArray, (const uint8_t*) "length", length, NULL);
			FREAcquireByteArray(objectByteArray, &byteArray);
			memcpy(byteArray.bytes, output, outputSize);

			FREReleaseByteArray(objectByteArray);
			delete bitmap;
			delete stream;
			delete output;
			delete [] raw;

			NuiImageStreamReleaseFrame( m_rgbStream, pImageFrame );
			FRENewObjectFromBool(true, &rtnValue);
			*/
		}else{
			FRENewObjectFromBool(false, &rtnValue);
		}
		return rtnValue;
	}

	FREObject FIFTEENLETTERS_KINECT_getDepthFrame(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) { 
		while(WaitForSingleObject(m_hNextDepthFrameEvent, INFINITE) != WAIT_OBJECT_0) { }
		
		const NUI_IMAGE_FRAME * pImageFrame = NULL;
		HRESULT hr = NuiImageStreamGetNextFrame(m_depthStream, 0, &pImageFrame );

		FREObject rtnValue;
		if (SUCCEEDED(hr)) {
			NuiImageBuffer * pTexture = pImageFrame->pFrameTexture;			

			KINECT_LOCKED_RECT LockedRect;
			pTexture->LockRect( 0, &LockedRect, NULL, 0 );
			BYTE * pBuffer = (BYTE*) LockedRect.pBits;
		
			DWORD width;
			DWORD height;
			NuiImageResolutionToSize(pImageFrame->eResolution, width, height);

			int bytes = width * height * 4;
			int32_t m_rgbWk[320*240];
			int32_t * rgbrun = m_rgbWk;
			USHORT * pBufferRun = (USHORT*) pBuffer;
			
			int32_t value;
			for( uint32_t y = 0 ; y < height ; y++ ) {
				for( uint32_t x = 0 ; x < width ; x++ ) {
					RGBQUAD quad = Nui_ShortToQuad_Depth( *pBufferRun );
					value = quad.rgbReserved << 24 | quad.rgbRed <<16 | quad.rgbGreen << 8| quad.rgbBlue;
					* rgbrun = 0xff << 24 | value;
					pBufferRun++;
					rgbrun++;
				}
			}

			
			FREObject objectByteArray = argv[0];

			FREByteArray byteArray;			
			FREObject length;
			FRENewObjectFromUint32(bytes, &length);
			FRESetObjectProperty(objectByteArray, (const uint8_t*) "length", length, NULL);
			FREAcquireByteArray(objectByteArray, &byteArray);
			memcpy(byteArray.bytes, m_rgbWk, bytes);
			
			FREReleaseByteArray(objectByteArray);
			NuiImageStreamReleaseFrame( m_depthStream, pImageFrame );
			FRENewObjectFromBool(true, &rtnValue);

		}else{
			FRENewObjectFromBool(false, &rtnValue);
		}
		return rtnValue;
	}


	void contextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx, uint32_t* numFunctions, const FRENamedFunction** functions) {
		*numFunctions = 10;

		FRENamedFunction* func = (FRENamedFunction*) malloc(sizeof(FRENamedFunction) * (*numFunctions));

		func[0].name = (const uint8_t*) "init";
		func[0].functionData = NULL;
		func[0].function = &FIFTEENLETTERS_KINECT_init;

		func[1].name = (const uint8_t*) "kinectStart";
		func[1].functionData = NULL;
		func[1].function = &FIFTEENLETTERS_KINECT_startKinect;

		func[2].name = (const uint8_t*) "kinectStop";
		func[2].functionData = NULL;
		func[2].function = &FIFTEENLETTERS_KINECT_stopKinect;

		func[3].name = (const uint8_t*) "kinectAvaliable";
		func[3].functionData = NULL;
		func[3].function = &FIFTEENLETTERS_KINECT_avaliableKinect;

		func[4].name = (const uint8_t*) "setKinectAngle";
		func[4].functionData = NULL;
		func[4].function = &FIFTEENLETTERS_KINECT_setKinectAngle;

		func[5].name = (const uint8_t*) "getKinectAngle";
		func[5].functionData = NULL;
		func[5].function = &FIFTEENLETTERS_KINECT_getKinectAngle;

		func[6].name = (const uint8_t*) "getSkeletonFrameData";
		func[6].functionData = NULL;
		func[6].function = &FIFTEENLETTERS_KINECT_getSkeletonFrameData;
		
		func[7].name = (const uint8_t*) "getStreamFrame";
		func[7].functionData = NULL;
		func[7].function = &FIFTEENLETTERS_KINECT_getStreamFrame;

		func[8].name = (const uint8_t*) "getDepthFrame";
		func[8].functionData = NULL;
		func[8].function = &FIFTEENLETTERS_KINECT_getDepthFrame;

		func[9].name = (const uint8_t*) "setTransformSmoothingParameters";
		func[9].functionData = NULL;
		func[9].function = &FIFTEENLETTERS_KINECT_setTransformSmoothingParameters;		
		

		*functions = func;
	}

	void contextFinalizer(FREContext ctx) {
		return;
	}

	void initializer(void** extData, FREContextInitializer* ctxInitializer, FREContextFinalizer* ctxFinalizer) {
		*ctxInitializer = &contextInitializer;
		*ctxFinalizer = &contextFinalizer;
	}

	void finalizer(void* extData) {
		NuiSkeletonTrackingDisable();
		NuiShutdown();
		CloseHandle(m_hNextSkeletonEvent);
		CloseHandle(m_rgbStream);
		CloseHandle(m_depthStream);
		m_hNextSkeletonEvent = NULL;
		m_rgbStream = NULL;
		m_depthStream = NULL;
		return;
	}

	RGBQUAD Nui_ShortToQuad_Depth( USHORT s ) {
		USHORT RealDepth = (s & 0xfff8) >> 3;
		USHORT Player = s & 7;

		// transform 13-bit depth information into an 8-bit intensity appropriate
		// for display (we disregard information in most significant bit)
		BYTE l = 255 - (BYTE)(256*RealDepth/0x0fff);

		RGBQUAD q;
		q.rgbRed = q.rgbBlue = q.rgbGreen = 0;

		switch( Player ) {
			case 0:
				q.rgbRed = l / 2;
				q.rgbBlue = l / 2;
				q.rgbGreen = l / 2;
				break;
			case 1:
				q.rgbRed = l;
				break;
			case 2:
				q.rgbGreen = l;
				break;
			case 3:
				q.rgbRed = l / 4;
				q.rgbGreen = l;
				q.rgbBlue = l;
				break;
			case 4:
				q.rgbRed = l;
				q.rgbGreen = l;
				q.rgbBlue = l / 4;
				break;
			case 5:
				q.rgbRed = l;
				q.rgbGreen = l / 4;
				q.rgbBlue = l;
				break;
			case 6:
				q.rgbRed = l / 2;
				q.rgbGreen = l / 2;
				q.rgbBlue = l;
				break;
			case 7:
				q.rgbRed = 255 - ( l / 2 );
				q.rgbGreen = 255 - ( l / 2 );
				q.rgbBlue = 255 - ( l / 2 );
		}

		return q;
	}

}