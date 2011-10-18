/**
 *
 * User: rgerbasi
 * Date: 10/1/11
 * Time: 3:50 PM
 */
package com.as3nui.nui.airkinect.manager {
	import com.as3nui.nativeExtensions.kinect.AIRKinect;
	import com.as3nui.nativeExtensions.kinect.AIRKinectCameraConstants;
	import com.as3nui.nativeExtensions.kinect.data.NUITransformSmoothParameters;
	import com.as3nui.nativeExtensions.kinect.data.SkeletonFrame;
	import com.as3nui.nativeExtensions.kinect.data.SkeletonPosition;
	import com.as3nui.nui.airkinect.manager.skeleton.Skeleton;

	import flash.geom.PerspectiveProjection;
	import flash.utils.Dictionary;

	import org.osflash.signals.Signal;

	public class AIRKinectManager {
		private static var _instance:AIRKinectManager;

		private static function get instance():AIRKinectManager {
			if (_instance) return _instance;
			_instance = new AIRKinectManager();
			return _instance;
		}

		public static function dispose():void {
			instance.dispose();
		}

		//----------------------------------
		// Kinect Manager Functions
		//----------------------------------
		public static function get onSkeletonUpdate():Signal {
			return instance.onSkeletonUpdate;
		}

		public static function get onSkeletonAdded():Signal {
			return instance.onSkeletonAdded;
		}

		public static function get onSkeletonRemoved():Signal {
			return instance.onSkeletonRemoved;
		}

		public static function getNextSkeleton():Skeleton {
			return instance.getNextSkeleton();
		}

		public static function numSkeletons():uint {
			return instance.numSkeletons();
		}

		public static function matchPerspectiveProjection(perspectiveProjection:PerspectiveProjection):void {
			perspectiveProjection.focalLength = AIRKinectCameraConstants.NUI_CAMERA_DEPTH_NOMINAL_FOCAL_LENGTH_IN_PIXELS * 10;
			//perspectiveProjection.fieldOfView = KinectCameraConstants.NUI_CAMERA_DEPTH_NOMINAL_DIAGONAL_FOV;
		}

		//----------------------------------
		// KINECT Extension Functions
		//----------------------------------
		public static function setKinectAngle(angle:int):void {
			instance.setKinectAngle(angle);
		}

		public static function getKinectAngle():int {
			return instance.getKinectAngle();
		}

		public static function setTransformSmoothingParameters(nuiTransformSmoothingParameters:NUITransformSmoothParameters):Boolean {
			return instance.setTransformSmoothingParameters(nuiTransformSmoothingParameters);
		}

		public static function getTransformSmoothingParameters():NUITransformSmoothParameters {
			return instance.getTransformSmoothingParameters();
		}

		public static function get onSkeletonFrame():Signal {
			return instance.onSkeletonFrame;
		}

		public static function get onRGBFrame():Signal {
			return instance.onRGBFrame;
		}

		public static function get onDepthFrame():Signal {
			return instance.onDepthFrame;
		}

		//----------------------------------
		// Start Instance
		//----------------------------------

		protected var _kinectExtension:AIRKinect;

		protected var _skeletonLookup:Dictionary;
		protected var _onSkeletonUpdate:Signal;
		protected var _onSkeletonAdded:Signal;
		protected var _onSkeletonRemoved:Signal;

		public function AIRKinectManager() {
			_kinectExtension = new AIRKinect();
			_skeletonLookup = new Dictionary();
			_onSkeletonAdded = new Signal(Skeleton);
			_onSkeletonUpdate = new Signal(Skeleton);
			_onSkeletonRemoved = new Signal(Skeleton);

			_kinectExtension.onSkeletonFrame.add(onKinectSkeletonFrame);
		}

		/**
		 * Dispose Memory used by Kinect Manager and Kinect Extension
		 */
		public function dispose():void {
			if(_kinectExtension) {
				_kinectExtension.onSkeletonFrame.remove(onKinectSkeletonFrame);
				_kinectExtension.dispose();
				_kinectExtension = null;
			}

			_skeletonLookup = null;
			_onSkeletonAdded.removeAll();
			_onSkeletonUpdate.removeAll();
			_onSkeletonRemoved.removeAll();
		}

		/**
		 * Process Skeleton Frames into Single Skeletons updates
		 * @param skeletonFrame
		 */
		protected function onKinectSkeletonFrame(skeletonFrame:SkeletonFrame):void {
			var skeletonPosition:SkeletonPosition;
			var skeleton:Skeleton;
			var trackedSkeletonIDs:Vector.<uint> = new Vector.<uint>();

			if (skeletonFrame.numSkeletons > 0) {
				for (var j:uint = 0; j < skeletonFrame.numSkeletons; j++) {
					skeletonPosition = skeletonFrame.getSkeletonPosition(j);
					trackedSkeletonIDs.push(skeletonPosition.trackingID);

					if (_skeletonLookup[skeletonPosition.trackingID] == null) {
						skeleton = _skeletonLookup[skeletonPosition.trackingID] = new Skeleton(skeletonPosition);
						_onSkeletonAdded.dispatch(skeleton);
					} else {
						skeleton = _skeletonLookup[skeletonPosition.trackingID] as Skeleton;
						skeleton.update(skeletonPosition);
						_onSkeletonUpdate.dispatch(skeleton);
					}
				}
			}

			var skeletonRemoveIndex:String;
			for (skeletonRemoveIndex in _skeletonLookup) {
				if (skeletonFrame.numSkeletons == 0 || trackedSkeletonIDs.indexOf(skeletonRemoveIndex) == -1) {
					skeleton = _skeletonLookup[skeletonRemoveIndex] as Skeleton;
					_skeletonLookup[skeletonRemoveIndex] = null;
					delete _skeletonLookup[skeletonRemoveIndex];
					_onSkeletonRemoved.dispatch(skeleton);
				}
			}
		}

		public function getNextSkeleton():Skeleton {
			var skeletonRemoveIndex:String;
			for (skeletonRemoveIndex in _skeletonLookup) {
				if (_skeletonLookup[skeletonRemoveIndex] is Skeleton) {
					return _skeletonLookup[skeletonRemoveIndex] as Skeleton;
				}
			}
			return null;
		}

		public function numSkeletons():uint {
			var count:uint = 0;
			var skeletonRemoveIndex:String;
			for (skeletonRemoveIndex in _skeletonLookup) {
				if (_skeletonLookup[skeletonRemoveIndex] is Skeleton) {
					count++;
				}
			}
			return count;

		}

		//----------------------------------
		// Kinect Manager Signals
		//----------------------------------

		public function get onSkeletonAdded():Signal {
			return _onSkeletonAdded;
		}

		public function get onSkeletonRemoved():Signal {
			return _onSkeletonRemoved;
		}

		public function get onSkeletonUpdate():Signal {
			return _onSkeletonUpdate;
		}

		//----------------------------------
		// Kinect Extension Composite Functions
		//----------------------------------
		public function setKinectAngle(angle:int):void {
			_kinectExtension.setKinectAngle(angle);
		}

		public function getKinectAngle():int {
			return _kinectExtension.getKinectAngle();
		}

		public function setTransformSmoothingParameters(nuiTransformSmoothingParameters:NUITransformSmoothParameters):Boolean {
			return _kinectExtension.setTransformSmoothingParameters(nuiTransformSmoothingParameters);
		}

		public function getTransformSmoothingParameters():NUITransformSmoothParameters {
			return _kinectExtension.getTransformSmoothingParameters();
		}

		public function get onSkeletonFrame():Signal {
			return _kinectExtension.onSkeletonFrame;
		}

		public function get onRGBFrame():Signal {
			return _kinectExtension.onRGBFrame;
		}

		public function get onDepthFrame():Signal {
			return _kinectExtension.onDepthFrame;
		}
	}
}