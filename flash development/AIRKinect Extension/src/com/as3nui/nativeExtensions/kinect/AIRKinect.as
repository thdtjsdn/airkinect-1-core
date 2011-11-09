/**
 *
 * User: rgerbasi
 * Date: 9/28/11
 * Time: 3:09 PM
 */
package com.as3nui.nativeExtensions.kinect {
	import com.as3nui.nativeExtensions.kinect.data.NUITransformSmoothParameters;
	import com.as3nui.nativeExtensions.kinect.data.SkeletonFrame;
	import com.as3nui.nativeExtensions.kinect.events.CameraFrameEvent;
	import com.as3nui.nativeExtensions.kinect.events.DeviceStatusEvent;
	import com.as3nui.nativeExtensions.kinect.events.SkeletonFrameEvent;

	import flash.display.BitmapData;
	import flash.events.EventDispatcher;
	import flash.events.StatusEvent;
	import flash.external.ExtensionContext;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	import flash.utils.Endian;

	public class AIRKinect extends EventDispatcher {
		public static const NUI_INITIALIZE_FLAG_USES_DEPTH_AND_PLAYER_INDEX:uint = 0x00000001;
		public static const NUI_INITIALIZE_FLAG_USES_COLOR:uint = 0x00000002;
		public static const NUI_INITIALIZE_FLAG_USES_SKELETON:uint = 0x00000008;
		public static const NUI_INITIALIZE_FLAG_USES_DEPTH:uint = 0x00000020;

		public static const NUI_IMAGE_RESOLUTION_80x60:uint = 0;
		public static const NUI_IMAGE_RESOLUTION_320x240:uint = 1;
		public static const NUI_IMAGE_RESOLUTION_640x480:uint = 2;
		public static const NUI_IMAGE_RESOLUTION_1280x1024:uint = 3;

		//Static Constants
		private static const DEVICE_STATUS:String = "deviceStatus";
		private static const SKELETON_FRAME:String = "skeletonFrame";
		private static const RGB_FRAME:String = "RGBFrame";
		private static const DEPTH_FRAME:String = "depthFrame";
		private static const CONNECTION_ERROR:String = "connectionError";
		private static const EXTENSION_ID:String = 'com.as3nui.extensions.AIRKinect';

		//Device Status Constants
		private const DEVICE_STATUS_CONNECTED:String 		= "connected";
		private const DEVICE_STATUS_DISCONNECTED:String 	= "disconnected";

		private static var _KINECT_RUNNING:Boolean;

		//----------------------------------
		// Singleton
		//----------------------------------

		//Static Variables
		private static var _instance:AIRKinect;
		public static function get instance():AIRKinect {
			if (!_instance) _instance = new AIRKinect();
			return _instance;
		}

		public static function initialize(flags:uint = NUI_INITIALIZE_FLAG_USES_SKELETON, rgbResolution:uint = NUI_IMAGE_RESOLUTION_640x480, depthResolution:uint = NUI_IMAGE_RESOLUTION_320x240):Boolean {
			return instance.initialize(flags, rgbResolution, depthResolution);
		}

		public static function shutdown():void {
			instance.shutdown();
		}

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

		public static function get rgbEnabled():Boolean {
			return instance.rgbEnabled;
		}

		public static function get depthEnabled():Boolean {
			return instance.depthEnabled;
		}
		
		public static function get isPlayerIndexEnabled():Boolean {
			return instance.isPlayerIndexEnabled;
		}

		public static function get skeletonEnabled():Boolean {
			return instance.skeletonEnabled;
		}

		public static function addEventListener(type:String, listener:Function, useWeakReference:Boolean = false):void {
			instance.addEventListener(type, listener, false, 0, useWeakReference);
		}

		public static function removeEventListener(type:String, listener:Function):void {
			instance.removeEventListener(type, listener);
		}

		public static function hasEventListener(type:String):Boolean {
			return instance.hasEventListener(type);
		}

		public static function willTrigger(type:String):Boolean {
			return instance.willTrigger(type);
		}

		public static function get KINECT_RUNNING():Boolean {
			return _KINECT_RUNNING;
		}

		public static function set KINECT_RUNNING(value:Boolean):void {
			_KINECT_RUNNING = value;
		}

		public static function get rgbSize():Point {
			return instance.rgbSize;
		}

		public static function get depthSize():Point {
			return instance.depthSize;
		}

		//----------------------------------
		// Begin Instance
		//----------------------------------

		//----------------------------------
		// Instance Variables
		//----------------------------------
		private var _extCtx:ExtensionContext;
		//Smoothing Params
		private var _nuiTransformSmoothingParameters:NUITransformSmoothParameters;

		//Camera Image Variables
		private var _rgbFrame:ByteArray;
		private var _rgbImage:BitmapData;

		private var _depthFrame:ByteArray;
		private var _depthImage:BitmapData;
		private var _depthPoints:ByteArray;

		//flags passed into c
		private var _flags:ByteArray;
		private var _rgbResolution:uint;
		private var _depthResolution:uint;
		private var _resolutionSize:Point;

		public function AIRKinect() {
			createContext();
		}

		public function createContext():void {
			_extCtx = ExtensionContext.createExtensionContext(EXTENSION_ID, null);
			if (_extCtx != null) {
				_extCtx.addEventListener(StatusEvent.STATUS, onStatus);
				_extCtx.call("init");
			} else {
				throw new Error("Error while instantiating Kinect Extension");
			}
		}

		public function initialize(kinectFlags:uint = NUI_INITIALIZE_FLAG_USES_SKELETON, rgbResolution:uint = NUI_IMAGE_RESOLUTION_640x480, depthResolution:uint = NUI_IMAGE_RESOLUTION_320x240):Boolean {
			if (_KINECT_RUNNING) throw new Error("Only one instance of the Kinect maybe run at a time");

			_flags = new ByteArray();
			_flags.writeByte(kinectFlags);

			_rgbResolution = rgbResolution;
			_depthResolution = depthResolution;

			if (_extCtx == null) createContext();

			if (!_extCtx.call("kinectStart", kinectFlags, rgbResolution, depthResolution)) {
				shutdown();
				return false;
			}

			_KINECT_RUNNING = true;
			if (rgbEnabled) {
				_rgbFrame = new ByteArray();
				_rgbImage = new BitmapData(rgbSize.x, rgbSize.y, false);
			}

			if (depthEnabled) {
				_depthFrame = new ByteArray();
				_depthImage = new BitmapData(depthSize.x, depthSize.y, false);
				if(isPlayerIndexEnabled){
					_depthPoints = null;
				}else{
					_depthPoints = new ByteArray();
				}
			}

			return true;
		}

		public function shutdown():void {
			cleanupNativeExtension();
			cleanupASExtension();
		}

		private function cleanupNativeExtension():void {
			if (_extCtx) {
				_extCtx.call("kinectStop");
				_extCtx.removeEventListener(StatusEvent.STATUS, onStatus);
				_extCtx.dispose();
				_extCtx = null;
			}
		}

		private function cleanupASExtension():void {
			_KINECT_RUNNING = false;
			_flags = new ByteArray();
			
			//Clean up RGB Frame and Image
			if (_rgbFrame) _rgbFrame = null;
			if (_rgbImage) {
				_rgbImage.dispose();
				_rgbImage = null;
			}

			//Cleanup Depth Frame and Image
			if (_depthFrame) _depthFrame = null;
			if (_depthImage) {
				_depthImage.dispose();
				_depthImage = null;
			}
		}

		private function onDisconnected():void {
			cleanupASExtension();
		}

		//----------------------------------
		// Public functions 
		//----------------------------------
		public function setKinectAngle(angle:int):void {
			_extCtx.call('setKinectAngle', angle);
		}

		public function getKinectAngle():int {
			if (_extCtx != null) {
				return _extCtx.call('getKinectAngle') as int;
			}
			return NaN;
		}

		public function setTransformSmoothingParameters(nuiTransformSmoothingParameters:NUITransformSmoothParameters):Boolean {
			_nuiTransformSmoothingParameters = nuiTransformSmoothingParameters;
			return _extCtx.call('setTransformSmoothingParameters', _nuiTransformSmoothingParameters);
		}

		public function getTransformSmoothingParameters():NUITransformSmoothParameters {
			return _nuiTransformSmoothingParameters;
		}

		public function get rgbEnabled():Boolean {
			return (_flags[0] & NUI_INITIALIZE_FLAG_USES_COLOR) != 0;
		}

		public function get depthEnabled():Boolean {
			return (((_flags[0] & NUI_INITIALIZE_FLAG_USES_DEPTH_AND_PLAYER_INDEX) != 0) || ((_flags[0] & NUI_INITIALIZE_FLAG_USES_DEPTH) != 0));
		}

		public function get isPlayerIndexEnabled():Boolean {
			return ((_flags[0] & NUI_INITIALIZE_FLAG_USES_DEPTH_AND_PLAYER_INDEX) != 0)
		}

		public function get skeletonEnabled():Boolean {
			return (_flags[0] & NUI_INITIALIZE_FLAG_USES_SKELETON) != 0;
		}

		public function get rgbSize():Point {
			return getResolutionToSize(_rgbResolution);
		}

		public function get depthSize():Point {
			return getResolutionToSize(_depthResolution);
		}

		private function getResolutionToSize(res:uint):Point {
			if (_resolutionSize == null) _resolutionSize = new Point();

			switch (res) {
				case NUI_IMAGE_RESOLUTION_80x60:
					_resolutionSize.x = 80;
					_resolutionSize.y = 60;
					break;
				case NUI_IMAGE_RESOLUTION_320x240:
					_resolutionSize.x = 320;
					_resolutionSize.y = 240;
					break;
				case NUI_IMAGE_RESOLUTION_640x480:
					_resolutionSize.x = 640;
					_resolutionSize.y = 480;
					break;
				case NUI_IMAGE_RESOLUTION_1280x1024 :
					_resolutionSize.x = 1280;
					_resolutionSize.y = 1024;
					break;
				default:
					_resolutionSize.x = 0;
					_resolutionSize.y = 0;
					break;
			}
			return _resolutionSize;
		}

		//----------------------------------
		// Private Functions
		//----------------------------------
		private function onStatus(event:StatusEvent):void {
			switch (event.code) {
				case DEVICE_STATUS:
//						trace("Device Status :: " + event.level);
						switch(event.level){
							case DEVICE_STATUS_DISCONNECTED:
								onDisconnected();
								this.dispatchEvent(new DeviceStatusEvent(DeviceStatusEvent.DISCONNECTED));
								break;
							case DEVICE_STATUS_CONNECTED:
								this.dispatchEvent(new DeviceStatusEvent(DeviceStatusEvent.RECONNECTED));
								break;
						}
					break;
				case SKELETON_FRAME:
					try {
						var currentSkeleton:SkeletonFrame = _extCtx.call('getSkeletonFrameData') as SkeletonFrame;
						this.dispatchEvent(new SkeletonFrameEvent(currentSkeleton));
					} catch(e:Error) {
						trace("Skeleton Frame Error :: " + e.message);
					}
					break;
				case RGB_FRAME:
					try {
						_extCtx.call('getRGBFrame', _rgbFrame);
						_rgbFrame.position = 0;
						_rgbFrame.endian = Endian.LITTLE_ENDIAN;
						_rgbImage.setPixels(new Rectangle(0, 0, _rgbImage.width, _rgbImage.height), _rgbFrame);
						this.dispatchEvent(new CameraFrameEvent(CameraFrameEvent.RGB, _rgbImage.clone()));
					} catch(e:Error) {
						trace("RGB Image Error :: " + e.message);
					}
					break;
				case DEPTH_FRAME:
					try {
						_extCtx.call('getDepthFrame', _depthFrame, _depthPoints);
						_depthFrame.position = 0;
						_depthFrame.endian = Endian.LITTLE_ENDIAN;

						if(_depthPoints){
							_depthPoints.position = 0;
							_depthPoints.endian = Endian.LITTLE_ENDIAN;
						}

						_depthImage.setPixels(new Rectangle(0, 0, _depthImage.width, _depthImage.height), _depthFrame);
						this.dispatchEvent(new CameraFrameEvent(CameraFrameEvent.DEPTH, _depthImage.clone(), _depthPoints));
					} catch(e:Error) {
						trace("Depth Image Error :: " + e.message);
					}
					break;
			}
		}
	}
}