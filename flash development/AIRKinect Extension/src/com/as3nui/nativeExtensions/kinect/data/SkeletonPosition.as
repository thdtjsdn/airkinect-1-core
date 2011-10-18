/**
 *
 * User: rgerbasi
 * Date: 9/29/11
 * Time: 6:17 PM
 */
package com.as3nui.nativeExtensions.kinect.data {
	import com.as3nui.nativeExtensions.kinect.AIRKinectCameraConstants;

	import flash.geom.Vector3D;

	public class SkeletonPosition {
		public static const DEPTH_CAMERA_TRANSLATION_MODE:String	= "depth_camera_mode";
		public static const RGB_CAMERA_TRANSLATION_MODE:String		= "rgb_camera_mode";
		public static const RAW_TRANSLATION_MODE:String				= "raw_mode";
		public static const FLAT_TRANSLATION_MODE:String			= "flat_mode";

		public static const HIP_CENTER:uint			= 0;
		public static const SPINE:uint				= 1;
		public static const SHOULDER_CENTER:uint	= 2;
		public static const HEAD:uint				= 3;
		public static const SHOULDER_LEFT:uint		= 4;
		public static const ELBOW_LEFT:uint			= 5;
		public static const WRIST_LEFT:uint			= 6;
		public static const HAND_LEFT:uint			= 7;
		public static const SHOULDER_RIGHT:uint		= 8;
		public static const ELBOW_RIGHT:uint		= 9;
		public static const WRIST_RIGHT:uint		= 10;
		public static const HAND_RIGHT:uint			= 11;
		public static const HIP_LEFT:uint			= 12;
		public static const KNEE_LEFT:uint			= 13;
		public static const ANKLE_LEFT:uint			= 14;
		public static const FOOT_LEFT:uint			= 15;
		public static const HIP_RIGHT:uint			= 16;
		public static const KNEE_RIGHT:uint			= 17;
		public static const ANKLE_RIGHT:uint		= 18;
		public static const FOOT_RIGHT:uint			= 19;
		public static const MAX_NUM_ELEMENTS:uint	= 20;


		public static const STATE_NOT_TRACKED:uint		= 0;
		public static const STATE_POSITION_ONLY:uint 	= 1;
		public static const STATE_SKELETON_TRACKED:uint	= 2;

		public static var TRANSLATION_MODE:String		= FLAT_TRANSLATION_MODE;

		private var _frameNumber:uint;
		private var _timestamp:uint;
		private var _trackingID:uint;
		private var _trackingState:uint;
		private var _elements:Vector.<Vector3D>;

		public function SkeletonPosition(frameNumber:uint, timestamp:uint, trackingID:uint,  trackingState:uint,  elements:Vector.<Vector3D>) {
			_frameNumber		= frameNumber;
			_timestamp			= timestamp;
			_trackingID 		= trackingID;
			_trackingState 		= trackingState;
			_elements 			= elements;
		}

		public function get isSkeletonTracked():Boolean {
			return _trackingState == STATE_SKELETON_TRACKED;
		}

		public function elementExists(index:uint):Boolean {
			return _elements[index] is Vector3D;
		}

		public function getElement(index:uint):Vector3D {
			var transformedElement:Vector3D = _elements[index].clone();
			switch(TRANSLATION_MODE){
				case DEPTH_CAMERA_TRANSLATION_MODE:
					transformedElement.x = 0.5 + transformedElement.x * (AIRKinectCameraConstants.NUI_CAMERA_DEPTH_NOMINAL_FOCAL_LENGTH_IN_PIXELS/ transformedElement.z ) /  320;
					transformedElement.y = 0.5 - transformedElement.y * (AIRKinectCameraConstants.NUI_CAMERA_DEPTH_NOMINAL_FOCAL_LENGTH_IN_PIXELS / transformedElement.z ) / 240;
					break;
				case RGB_CAMERA_TRANSLATION_MODE:
					transformedElement.x = 0.5 + transformedElement.x * (AIRKinectCameraConstants.NUI_CAMERA_COLOR_NOMINAL_FOCAL_LENGTH_IN_PIXELS/ transformedElement.z ) /  640;
					transformedElement.y = 0.5 - transformedElement.y * (AIRKinectCameraConstants.NUI_CAMERA_COLOR_NOMINAL_FOCAL_LENGTH_IN_PIXELS / transformedElement.z ) / 480;
					break;
				case FLAT_TRANSLATION_MODE:
					transformedElement.x = (transformedElement.x + 1) * .5;
					transformedElement.y = (transformedElement.y - 1) / -2;
					break;
				case RAW_TRANSLATION_MODE:
					break;
			}
			return transformedElement;
		}

		public function getElementScaled(index:uint, scale:Vector3D):Vector3D {
			var transformedElement:Vector3D = getElement(index);
			transformedElement.x *= scale.x;
			transformedElement.y *= scale.y;
			transformedElement.z *= scale.z;
			return transformedElement;
		}

		public function getElementRaw(index:uint):Vector3D {
			return _elements[index];
		}

		public function get trackingID():uint {
			return _trackingID;
		}

		public function get trackingState():uint {
			return _trackingState;
		}

		public function get numElements():uint {
			return _elements.length;
		}

		public function get elements():Vector.<Vector3D> {
			return _elements;
		}

		public function get frameNumber():uint {
			return _frameNumber;
		}

		public function get timestamp():uint {
			return _timestamp;
		}
	}
}