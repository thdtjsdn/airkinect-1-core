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
	import com.as3nui.nativeExtensions.kinect.events.SkeletonFrameEvent;

	import flash.display.BitmapData;
	import flash.events.EventDispatcher;
	import flash.events.StatusEvent;
	import flash.external.ExtensionContext;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	import flash.utils.Endian;

	public class AIRKinect extends EventDispatcher {
		public static const NUI_INITIALIZE_FLAG_USES_DEPTH_AND_PLAYER_INDEX:uint 	= 0x00000001;
		public static const NUI_INITIALIZE_FLAG_USES_COLOR:uint 					= 0x00000002;
		public static const NUI_INITIALIZE_FLAG_USES_SKELETON:uint 					= 0x00000008;

		//Static Constants
		private static const SKELETON_FRAME:String 	= "skeletonFrame";
		private static const RGB_FRAME:String 		= "RGBFrame";
		private static const DEPTH_FRAME:String 	= "depthFrame";
		private static const EXTENSION_ID:String 	= 'com.as3nui.extensions.AIRKinect';

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

		public static function initialize(flags:uint = NUI_INITIALIZE_FLAG_USES_SKELETON):void {
			instance.initialize(flags);
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
		private var _flags:ByteArray;

		public function AIRKinect() {
			_flags = new ByteArray();
			createContext();
		}

		public function createContext():void {
			_extCtx = ExtensionContext.createExtensionContext(EXTENSION_ID, null);
			if (_extCtx != null) {
				_extCtx.call("init");
			} else {
				throw new Error("Error while instantiating Kinect Extension");
			}
		}

		public function initialize(kinectFlags:uint = NUI_INITIALIZE_FLAG_USES_SKELETON):void {
			if(_KINECT_RUNNING) throw new Error("Only one instance of the Kinect maybe run at a time");

			_flags.writeByte(kinectFlags);

			if(_extCtx == null) createContext();
			
			if (!_extCtx.call("kinectStart", kinectFlags)) {
				throw new Error("Error while Starting Kinect");
			} else {
				_KINECT_RUNNING = true;
				_extCtx.addEventListener(StatusEvent.STATUS, onStatus);
			}

			if (rgbEnabled) {
				_rgbFrame = new ByteArray();
				_rgbImage = new BitmapData(640, 480, false);
			}

			if (depthEnabled) {
				_depthFrame = new ByteArray();
				_depthImage = new BitmapData(320, 240, false);
			}
		}

		public function shutdown():void {
			_KINECT_RUNNING = false;
			if(_extCtx) {
				_extCtx.call("kinectStop");
				_extCtx.removeEventListener(StatusEvent.STATUS, onStatus);
			}

			//Clean up RGB Frame and Image
			if(_rgbFrame) _rgbFrame = null;
			if(_rgbImage) {
				_rgbImage.dispose();
				_rgbImage = null;
			}

			//Cleanup Depth Frame and Image
			if(_depthFrame) _depthFrame = null;
			if(_depthImage) {
				_depthImage.dispose();
				_depthImage = null;
			}


			if (_extCtx) {
				_extCtx.dispose();
				_extCtx = null;
			}
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
			return (_flags[0] & NUI_INITIALIZE_FLAG_USES_DEPTH_AND_PLAYER_INDEX) != 0;
		}

		public function get skeletonEnabled():Boolean {
			return (_flags[0] & NUI_INITIALIZE_FLAG_USES_SKELETON) != 0;
		}

		//----------------------------------
		// Private Functions
		//----------------------------------
		protected function onStatus(event:StatusEvent):void {
			switch (event.code) {
				case SKELETON_FRAME:
					try{
						var currentSkeleton:SkeletonFrame = _extCtx.call('getSkeletonFrameData') as SkeletonFrame;
						this.dispatchEvent(new SkeletonFrameEvent(currentSkeleton));
					}catch(e:Error){
						trace("RGB Error :: " + e.message);
					}
					break;
				case RGB_FRAME:
					try{
						_extCtx.call('getRGBFrame', _rgbFrame);
						_rgbFrame.position = 0;
						_rgbFrame.endian = Endian.LITTLE_ENDIAN;
						_rgbImage.setPixels(new Rectangle(0, 0, 640, 480), _rgbFrame);
						this.dispatchEvent(new CameraFrameEvent(CameraFrameEvent.RGB, _rgbImage.clone()));
						_rgbImage.dispose();
					}catch(e:Error){
						trace("RGB Image Error :: " + e.message);
					}
					break;
				case DEPTH_FRAME:
					try{
						_extCtx.call('getDepthFrame', _depthFrame);
						_depthFrame.position = 0;
						_depthFrame.endian = Endian.LITTLE_ENDIAN;
						_depthImage.setPixels(new Rectangle(0, 0, 320, 240), _depthFrame);
						this.dispatchEvent(new CameraFrameEvent(CameraFrameEvent.DEPTH, _depthImage.clone()));
						_depthImage.dispose();
					}catch(e:Error){
						trace("Depth Image Error :: " + e.message);
					}
					break;
			}
		}
	}
}