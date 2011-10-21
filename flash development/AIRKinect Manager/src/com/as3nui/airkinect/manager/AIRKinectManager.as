/**
 *
 * User: rgerbasi
 * Date: 10/1/11
 * Time: 3:50 PM
 */
package com.as3nui.airkinect.manager {
	import com.as3nui.airkinect.manager.skeleton.Skeleton;
	import com.as3nui.nativeExtensions.kinect.AIRKinect;
	import com.as3nui.nativeExtensions.kinect.AIRKinectCameraConstants;
	import com.as3nui.nativeExtensions.kinect.data.SkeletonFrame;
	import com.as3nui.nativeExtensions.kinect.data.SkeletonPosition;
	import com.as3nui.nativeExtensions.kinect.events.CameraFrameEvent;
	import com.as3nui.nativeExtensions.kinect.events.SkeletonFrameEvent;

	import flash.display.BitmapData;
	import flash.geom.PerspectiveProjection;
	import flash.utils.Dictionary;

	import org.osflash.signals.Signal;

	public class AIRKinectManager {
		private static var _instance:AIRKinectManager;
		private static const DEFAULT_FLAGS:uint = 11;

		private static function get instance():AIRKinectManager {
			if (_instance) return _instance;
			_instance = new AIRKinectManager();
			return _instance;
		}

		public static function initialize(flags:uint = DEFAULT_FLAGS):void {
			instance.initialize(flags);
		}

		public static function shutdown():void {
			instance.shutdown();
		}

		public static function dispose():void {
			instance.dispose();
		}

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

		public static function get onRGBFrameUpdate():Signal {
			return instance.onRGBFrameUpdate;
		}

		public static function get onDepthFrameUpdate():Signal {
			return instance.onDepthFrameUpdate;
		}


		public static function numSkeletons():uint {
			return instance.numSkeletons();
		}

		public static function matchPerspectiveProjection(perspectiveProjection:PerspectiveProjection):void {
			perspectiveProjection.focalLength = AIRKinectCameraConstants.NUI_CAMERA_DEPTH_NOMINAL_FOCAL_LENGTH_IN_PIXELS * 10;
		}

		//----------------------------------
		// Start Instance
		//----------------------------------
		protected var _skeletonLookup:Dictionary;

		protected var _onSkeletonUpdate:Signal;
		protected var _onSkeletonAdded:Signal;
		protected var _onSkeletonRemoved:Signal;

		protected var _onRGBFrameUpdate:Signal;
		protected var _onDepthFrameUpdate:Signal;

		public function AIRKinectManager() {
			_skeletonLookup 		= new Dictionary();
			_onSkeletonAdded 		= new Signal(Skeleton);
			_onSkeletonUpdate 		= new Signal(Skeleton);
			_onSkeletonRemoved 		= new Signal(Skeleton);
			_onRGBFrameUpdate 		= new Signal(BitmapData);
			_onDepthFrameUpdate		= new Signal(BitmapData);
		}

		public function initialize(flags:uint = DEFAULT_FLAGS):void {
			AIRKinect.initialize(flags);
			AIRKinect.addEventListener(SkeletonFrameEvent.UPDATE, onSkeletonFrame);
			AIRKinect.addEventListener(CameraFrameEvent.RGB, onRGBFrame);
			AIRKinect.addEventListener(CameraFrameEvent.DEPTH, onDepthFrame);
		}

		/**
		 * Dispose Memory used by Kinect Manager and Kinect Extension
		 */
		public function shutdown():void {
			AIRKinect.removeEventListener(SkeletonFrameEvent.UPDATE, onSkeletonFrame);
			AIRKinect.removeEventListener(CameraFrameEvent.RGB, onRGBFrame);
			AIRKinect.removeEventListener(CameraFrameEvent.DEPTH, onDepthFrame);
			AIRKinect.shutdown();
			_skeletonLookup = null;
		}

		public function dispose():void {
			_onSkeletonAdded.removeAll();
			_onSkeletonUpdate.removeAll();
			_onSkeletonRemoved.removeAll();
			_onRGBFrameUpdate.removeAll();
			_onDepthFrameUpdate.removeAll();
			shutdown();
		}

		//----------------------------------
		// Skeleton Frame
		//----------------------------------

		protected function onSkeletonFrame(e:SkeletonFrameEvent):void {
			var skeletonFrame:SkeletonFrame = e.skeletonFrame;
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
		// RGB Frame
		//----------------------------------
		private function onRGBFrame(event:CameraFrameEvent):void {
			_onRGBFrameUpdate.dispatch(event.frame);
		}

		//----------------------------------
		// Depth Frame
		//----------------------------------
		private function onDepthFrame(event:CameraFrameEvent):void {
			_onDepthFrameUpdate.dispatch(event.frame);
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

		public function get onRGBFrameUpdate():Signal {
			return _onRGBFrameUpdate;
		}

		public function get onDepthFrameUpdate():Signal {
			return _onDepthFrameUpdate;
		}
	}
}