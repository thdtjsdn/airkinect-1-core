// KinectExtension.cpp : Defines the exported functions for the DLL application.
//
#include <stdio.h>
#include <stdlib.h>

#include "stdafx.h"
#include "AIRKinectExtension.h"
#include "AIRKinectAdapter.h"

extern "C" {
	AIRKinectAdapter	g_AIRKinectAdapter;
	NUI_TRANSFORM_SMOOTH_PARAMETERS _transformSmoothingParameters;
	int32_t *m_rgbBa;
	
	int32_t *m_depthBa;
	USHORT *m_depthPointsBa;


	FREObject AIRKINECT_init(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
		//OutputDebugString( "AIRKinect :: init\n" );
		g_AIRKinectAdapter.setDefaultSmoothingParameters();
		return NULL;
	}

	FREObject AIRKINECT_startKinect(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
		//OutputDebugString( "AIRKINECT_startKinect\n" );

		FREObject fdwFlags = argv[0];
		uint32_t dwFlags;
		FREGetObjectAsUint32(fdwFlags, &dwFlags);

		FREObject fColorResolution = argv[1];
		uint32_t colorResolutionIndex;
		FREGetObjectAsUint32(fColorResolution, &colorResolutionIndex);
		NUI_IMAGE_RESOLUTION colorImageResolution = getResolutionFromIndex(colorResolutionIndex);

		FREObject fDepthResolution = argv[2];

		uint32_t depthResolutionIndex;
		FREGetObjectAsUint32(fDepthResolution, &depthResolutionIndex);
		NUI_IMAGE_RESOLUTION depthImageResolution = getResolutionFromIndex(depthResolutionIndex);

		HRESULT hr = g_AIRKinectAdapter.start(dwFlags, colorImageResolution,depthImageResolution);

		bool success = !FAILED(hr);
		FREObject retObj;
		FRENewObjectFromBool(success, &retObj);
		return retObj;
	}
	
	FREObject AIRKINECT_stopKinect(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {\
		//OutputDebugString( "AIRKINECT_stopKinect\n" );
		g_AIRKinectAdapter.dispose();
		return NULL;
	}

	FREObject AIRKINECT_avaliableKinect(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
		//OutputDebugString( "AIRKINECT_avaliableKinect\n" );
		FREObject retVal;

		bool success = g_AIRKinectAdapter.isAvailable();
		FRENewObjectFromBool(success, &retVal);
		return retVal;
	}

	FREObject AIRKINECT_getKinectAngle(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) { 
		//OutputDebugString( "AIRKINECT_getKinectAngle\n" );
		long value;
		g_AIRKinectAdapter.cameraElevationGetAngle(&value);
		
		FREObject rtnValue;
		FRENewObjectFromInt32(value, &rtnValue);
		return rtnValue;
	}

	FREObject AIRKINECT_setKinectAngle(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) { 
		//OutputDebugString( "AIRKINECT_setKinectAngle\n" );
		int32_t value;
		FREGetObjectAsInt32(argv[0], &value);

		g_AIRKinectAdapter.cameraElevationSetAngle(value);
		return argv[0];
	}

	FREObject AIRKINECT_setTransformSmoothingParameters(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) { 
		//OutputDebugString( "AIRKINECT_setTransformSmoothingParameters\n" );
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
				g_AIRKinectAdapter.setTransformSmoothingParameters(_transformSmoothingParameters);
			}else{
				FRENewObjectFromBool(false, &retVal);
			}

			FRENewObjectFromBool(true, &retVal);
		}else{
			FRENewObjectFromBool(false, &retVal);
		}

		return retVal;
	}


	FREObject AIRKINECT_getSkeletonFrameData(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) { 
		//OutputDebugString( "AIRKINECT_getSkeletonFrameData\n" );
		
		NUI_SKELETON_FRAME SkeletonFrame = g_AIRKinectAdapter.skeletonFrameBuffer;
		FREObject skeletonFrame, skeletonsPositions;
		FREObject skeletonPosition, trackingID, trackingState, frameNumber, timestamp, elements;
		FREObject element, x, y, z, w;
		
		Vector4 elementPosition;
		short int trackedSkeletons = 0;
		
		FRENewObject( (const uint8_t*) "Vector.<com.as3nui.nativeExtensions.kinect.data.SkeletonPosition>", 0, NULL, &skeletonsPositions, NULL);
		
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

				FRENewObjectFromUint32((SkeletonFrame.dwFrameNumber), &frameNumber);
				FRENewObjectFromUint32((SkeletonFrame.liTimeStamp.LowPart), &timestamp);
				FRENewObjectFromUint32((SkeletonFrame.SkeletonData[i].dwTrackingID), &trackingID);
				FRENewObjectFromUint32((SkeletonFrame.SkeletonData[i].eTrackingState), &trackingState);
				FREObject skeletonParams [] = {frameNumber, timestamp, trackingID, trackingState, elements};
			
				FRENewObject( (const uint8_t*) "com.as3nui.nativeExtensions.kinect.data.SkeletonPosition", 5, skeletonParams, &skeletonPosition, NULL);

				FRESetArrayElementAt(skeletonsPositions, trackedSkeletons, skeletonPosition);
				trackedSkeletons++;
			}
		}
	
		FREObject skelentonFrameParams [] = {skeletonsPositions};
		FRENewObject( (const uint8_t*) "com.as3nui.nativeExtensions.kinect.data.SkeletonFrame", 1, skelentonFrameParams, &skeletonFrame, NULL);
		return skeletonFrame;
	}

	FREObject AIRKINECT_getRGBFrame(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) { 
		//OutputDebugString( "AIRKINECT_getRGBFrame\n" );
		
		BYTE * pBuffer = g_AIRKinectAdapter.RGBFrameBuffer;
		int32_t rgbBytesLength = g_AIRKinectAdapter.RGBWidth * g_AIRKinectAdapter.RGBHeight * 4;

		if(m_rgbBa == 0) m_rgbBa = new int32_t[g_AIRKinectAdapter.RGBWidth * g_AIRKinectAdapter.RGBHeight];

		int32_t *rgbrun = m_rgbBa;
		int32_t * pBufferRun = (int32_t*) pBuffer;

		for( uint32_t x = 0 ; x < g_AIRKinectAdapter.RGBWidth * g_AIRKinectAdapter.RGBHeight ; x++ ) {
			* rgbrun = 0xff << 24 | *pBufferRun;
			pBufferRun++;
			rgbrun++;
		}

		FREObject objectByteArray = argv[0];

		FREByteArray byteArray;			
		FREObject length;
		FRENewObjectFromUint32(rgbBytesLength, &length);
		FRESetObjectProperty(objectByteArray, (const uint8_t*) "length", length, NULL);
		FREAcquireByteArray(objectByteArray, &byteArray);
		memcpy(byteArray.bytes, m_rgbBa, rgbBytesLength);
		FREReleaseByteArray(objectByteArray);

		return NULL;
	}

	FREObject AIRKINECT_getDepthFrame(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) { 
		//OutputDebugString( "AIRKINECT_getDepthFrame\n" );
		BYTE * pBuffer = g_AIRKinectAdapter.depthFrameBuffer;
		int32_t depthBytes = g_AIRKinectAdapter.DepthWidth * g_AIRKinectAdapter.DepthHeight * 4;
		int32_t pointsBytes = (g_AIRKinectAdapter.DepthWidth * g_AIRKinectAdapter.DepthHeight) * (2*3);
		
		if(m_depthBa == 0) m_depthBa = new int32_t[g_AIRKinectAdapter.DepthWidth * g_AIRKinectAdapter.DepthHeight];
		if(m_depthPointsBa == 0) m_depthPointsBa = new USHORT[(g_AIRKinectAdapter.DepthWidth * g_AIRKinectAdapter.DepthHeight)*3];
		
		//Points Byte Array could be Buyte Array or NULL if not used
		FREObject objectPointsByteArray = argv[1];

		int32_t * depthRun = m_depthBa;
		USHORT * depthPointsRun = m_depthPointsBa;

		USHORT * pBufferRun = (USHORT*) pBuffer;
		
		
		int32_t value;
		USHORT currentX = 0;
		USHORT currentY = 0;
		for( uint32_t x = 0 ; x < g_AIRKinectAdapter.DepthWidth * g_AIRKinectAdapter.DepthHeight ; x++ ) {
			
			//Depth Camera only
			if(! g_AIRKinectAdapter.depthUsesPlayerIndex && objectPointsByteArray != NULL){
				* depthPointsRun = currentX;
				depthPointsRun++;
				* depthPointsRun = currentY;
				depthPointsRun++;
				* depthPointsRun = * pBufferRun;
				
				depthPointsRun++;
				currentX++;
				if(currentX >= g_AIRKinectAdapter.DepthWidth){
					currentX = 0;
					currentY++;
				}
			}

			RGBQUAD quad = Nui_ShortToQuad_Depth( *pBufferRun, g_AIRKinectAdapter.depthUsesPlayerIndex );
			value = quad.rgbReserved << 24 | quad.rgbRed <<16 | quad.rgbGreen << 8| quad.rgbBlue;
			* depthRun = 0xff << 24 | value;
			pBufferRun++;
			depthRun++;
		}
		
		//Get Byte Array from flash
		FREObject objectByteArray = argv[0];
		//Byte Array for Transfer of memory
		FREByteArray byteArray;			
		//Length of Bytes
		FREObject length;

		//Convert Total Bytes to flash uint
		FRENewObjectFromUint32(depthBytes, &length);
		
		//save total bytes into Flash Byte Array
		FRESetObjectProperty(objectByteArray, (const uint8_t*) "length", length, NULL);

		//Aquire Flash byte array into byte array
		FREAcquireByteArray(objectByteArray, &byteArray);
		
		//MemCopy current Byte data into byte array
		memcpy(byteArray.bytes, m_depthBa, depthBytes);

		//Release Flash Byte Array
		FREReleaseByteArray(objectByteArray);
		

		//Depth Points, only used in DEPTH only mode, not player
		if(! g_AIRKinectAdapter.depthUsesPlayerIndex && objectPointsByteArray != NULL){
			FREByteArray pointsByteArray;			
			FREObject pointsLength;
			FRENewObjectFromUint32(pointsBytes, &pointsLength);
			FRESetObjectProperty(objectPointsByteArray, (const uint8_t*) "length", pointsLength, NULL);
			FREAcquireByteArray(objectPointsByteArray, &pointsByteArray);
			memcpy(pointsByteArray.bytes, m_depthPointsBa, pointsBytes);
			FREReleaseByteArray(objectPointsByteArray);
		}

		return NULL;
	}


	void contextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx, uint32_t* numFunctions, const FRENamedFunction** functions) {
		//OutputDebugString( "contextInitializer\n" );
		*numFunctions = 10;

		FRENamedFunction* func = (FRENamedFunction*) malloc(sizeof(FRENamedFunction) * (*numFunctions));

		func[0].name = (const uint8_t*) "init";
		func[0].functionData = NULL;
		func[0].function = &AIRKINECT_init;

		func[1].name = (const uint8_t*) "kinectStart";
		func[1].functionData = NULL;
		func[1].function = &AIRKINECT_startKinect;

		func[2].name = (const uint8_t*) "kinectStop";
		func[2].functionData = NULL;
		func[2].function = &AIRKINECT_stopKinect;

		func[3].name = (const uint8_t*) "kinectAvaliable";
		func[3].functionData = NULL;
		func[3].function = &AIRKINECT_avaliableKinect;

		func[4].name = (const uint8_t*) "setKinectAngle";
		func[4].functionData = NULL;
		func[4].function = &AIRKINECT_setKinectAngle;

		func[5].name = (const uint8_t*) "getKinectAngle";
		func[5].functionData = NULL;
		func[5].function = &AIRKINECT_getKinectAngle;

		func[6].name = (const uint8_t*) "getSkeletonFrameData";
		func[6].functionData = NULL;
		func[6].function = &AIRKINECT_getSkeletonFrameData;
		
		func[7].name = (const uint8_t*) "getRGBFrame";
		func[7].functionData = NULL;
		func[7].function = &AIRKINECT_getRGBFrame;

		func[8].name = (const uint8_t*) "getDepthFrame";
		func[8].functionData = NULL;
		func[8].function = &AIRKINECT_getDepthFrame;

		func[9].name = (const uint8_t*) "setTransformSmoothingParameters";
		func[9].functionData = NULL;
		func[9].function = &AIRKINECT_setTransformSmoothingParameters;		

		g_AIRKinectAdapter.reset();
		g_AIRKinectAdapter.context = ctx;
		
		*functions = func;
	}

	void contextFinalizer(FREContext ctx) {
		//OutputDebugString( "contextFinalizer\n" );
		g_AIRKinectAdapter.dispose();
		return;
	}

	void initializer(void** extData, FREContextInitializer* ctxInitializer, FREContextFinalizer* ctxFinalizer) {
		//OutputDebugString( "initializer\n" );
		*ctxInitializer = &contextInitializer;
		*ctxFinalizer = &contextFinalizer;
	}

	void finalizer(void* extData) {
		//OutputDebugString( "finalizer\n" );
		return;
	}

	RGBQUAD Nui_ShortToQuad_Depth( USHORT s, BOOLEAN usePlayer ) {
		RGBQUAD q;
		q.rgbRed = q.rgbBlue = q.rgbGreen = 0;

		if(usePlayer) {
			USHORT RealDepth = (s & 0xfff8) >> 3;
			USHORT Player = s & 7;
			BYTE l = 255 - (BYTE)(256*RealDepth/0x0fff);

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
		}else{
			if(s > 0x7ff) s = 0x800;
			BYTE ds = (1 - (((double)s)/0x800)) * 0xff;
			q.rgbRed = q.rgbGreen = q.rgbBlue = ds;
		}

		return q;
	}


	NUI_IMAGE_RESOLUTION getResolutionFromIndex(uint32_t index){
		NUI_IMAGE_RESOLUTION result = NUI_IMAGE_RESOLUTION_320x240;
		switch(index){
			case 0:
				result =  NUI_IMAGE_RESOLUTION_80x60;
				break;
			case 1:
				result =  NUI_IMAGE_RESOLUTION_320x240;
				break;
			case 2:
				result =  NUI_IMAGE_RESOLUTION_640x480;
				break;
			case 3:
				result =  NUI_IMAGE_RESOLUTION_1280x1024;
				break;
		}
		return result;
	}
}