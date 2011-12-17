/**
 *
 * User: rgerbasi
 * Date: 9/28/11
 * Time: 3:09 PM
 */
package com.as3nui.nativeExtensions.kinect {
	import com.as3nui.nativeExtensions.kinect.data.AIRKinectCameraResolutions;
	import com.as3nui.nativeExtensions.kinect.data.AIRKinectFlags;
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
	import flash.desktop.NativeApplication;
	import flash.events.Event;

	/**
	 * Main Singleton class providing access to Kinect native context.
	 * Initialization is done through the initialize function code, optional flags are passed in to enable different features.
	 * <p>
	 * In this Example Skeleton and Color Camera tracking is enabled.
	 * <p>
	 * <code>
	 *  	var flags:uint = AIRKinect.NUI_INITIALIZE_FLAG_USES_SKELETON | AIRKinect.NUI_INITIALIZE_FLAG_USES_COLOR
	 *		AIRKinect.initialize(flags);
	 * </code>
	 * </p>
	 * </p>
	 */
	public class AIRKinect extends EventDispatcher {

		/**
		 * Fully qualified name to Extension
		 */
		private static const EXTENSION_ID:String 				= "com.as3nui.extensions.AIRKinect";

		/**
		 * Dispatched from Native Code when Deivce Status Changes
		 * Will be paired with DEVICE_STATUS_RECONNECTED or DEVICE_STATUS_DISCONNECTED
		 */
		private static const DEVICE_STATUS:String 				= "deviceStatus";

		/**
		 * Dispatched from Native code when a new SkeletonFrame is available
		 */
		private static const SKELETON_FRAME:String 				= "skeletonFrame";

		/**
		 * Dispatched from Native code when a new RGBFrame is available
		 */
		private static const RGB_FRAME:String 					= "RGBFrame";

		/**
		 * Dispatched from Native code when a new Depth Frame is available
		 */
		private static const DEPTH_FRAME:String 				= "depthFrame";
		
		/**
		 * Dispatched as type in a Device Status event, indicates the kinect has been started.
		 */
		private static const DEVICE_STATUS_STARTED:String 	= "started";

		/**
		 * Dispatched as type in a Device Status event, indicates the kinect has been reconnected.
		 */
		private static const DEVICE_STATUS_RECONNECTED:String 	= "reconnected";

		/**
		 * Dispatched as type in a Device Status event, indicates the kinect has been disconnected.
		 */
		private static const DEVICE_STATUS_DISCONNECTED:String 	= "disconnected";

		/**
		 * Boolean indicator determining if a instance of the kinect is currently running
		 */
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

		/**
		 * @see AIRKinect.initialize
		 */
		public static function initialize(flags:uint = AIRKinectFlags.NUI_INITIALIZE_FLAG_USES_SKELETON, rgbResolution:uint = AIRKinectCameraResolutions.NUI_IMAGE_RESOLUTION_640x480, depthResolution:uint = AIRKinectCameraResolutions.NUI_IMAGE_RESOLUTION_320x240):Boolean {
			return instance.initialize(flags, rgbResolution, depthResolution);
		}

		/**
		 * @see AIRKinect.shutdown
		 */
		public static function shutdown():void {
			instance.shutdown();
		}

		/**
		 * @see AIRKinect.setKinectAngle
		 */
		public static function setKinectAngle(angle:int):void {
			instance.setKinectAngle(angle);
		}

		/**
		 * @see AIRKinect.getKinectAngle
		 */
		public static function getKinectAngle():int {
			return instance.getKinectAngle();
		}

		/**
		 * @see AIRKinect.setTransformSmoothingParameters
		 */
		public static function setTransformSmoothingParameters(nuiTransformSmoothingParameters:NUITransformSmoothParameters):Boolean {
			return instance.setTransformSmoothingParameters(nuiTransformSmoothingParameters);
		}

		/**
		 * @see AIRKinect.getTransformSmoothingParameters
		 */
		public static function getTransformSmoothingParameters():NUITransformSmoothParameters {
			return instance.getTransformSmoothingParameters();
		}

		/**
		 * @see AIRKinect.rgbEnabled
		 */
		public static function get rgbEnabled():Boolean {
			return instance.rgbEnabled;
		}

		/**
		 * @see AIRKinect.depthEnabled
		 */
		public static function get depthEnabled():Boolean {
			return instance.depthEnabled;
		}

		/**
		 * @see AIRKinect.isPlayerIndexEnabled
		 */
		public static function get isPlayerIndexEnabled():Boolean {
			return instance.isPlayerIndexEnabled;
		}

		/**
		 * @see AIRKinect.skeletonEnabled
		 */
		public static function get skeletonEnabled():Boolean {
			return instance.skeletonEnabled;
		}

		/**
		 * @see EventDispatcher.addEventListener
		 */
		public static function addEventListener(type:String, listener:Function, useWeakReference:Boolean = false):void {
			instance.addEventListener(type, listener, false, 0, useWeakReference);
		}

		/**
		 * @see EventDispatcher.removeEventListener
		 */
		public static function removeEventListener(type:String, listener:Function):void {
			instance.removeEventListener(type, listener);
		}

		/**
		 * @see EventDispatcher.hasEventListener
		 */
		public static function hasEventListener(type:String):Boolean {
			return instance.hasEventListener(type);
		}

		/**
		 * @see EventDispatcher.willTrigger
		 */
		public static function willTrigger(type:String):Boolean {
			return instance.willTrigger(type);
		}

		/**
		 * @see AIRKinect.KINECT_RUNNING
		 */
		public static function get KINECT_RUNNING():Boolean {
			return _KINECT_RUNNING;
		}

		/**
		 * @see AIRKinect.KINECT_RUNNING
		 */
		public static function set KINECT_RUNNING(value:Boolean):void {
			_KINECT_RUNNING = value;
		}

		/**
		 * @see AIRKinect.rgbSize
		 */
		public static function get rgbSize():Point {
			return instance.rgbSize;
		}

		/**
		 * @see AIRKinect.depthSize
		 */
		public static function get depthSize():Point {
			return instance.depthSize;
		}

		//----------------------------------
		// Begin Instance
		//----------------------------------

		/**
		 * Reference to the Native Code extension
		 */
		private var _extCtx:ExtensionContext;

		/**
		 * Skeleton Frame Smoothing Parameters
		 */
		private var _nuiTransformSmoothingParameters:NUITransformSmoothParameters;

		/**
		 * Byte Array of current pixel data for RGB frame
		 */
		private var _rgbFrame:ByteArray;
		/**
		 * BitmapData for current RGB Frame
		 */
		private var _rgbImage:BitmapData;

		/**
		 *  Byte Array of current pixel data for Depth Frame
		 */
		private var _depthFrame:ByteArray;

		/**
		 * Bitmap Data for current Depth Frame
		 */
		private var _depthImage:BitmapData;

		/**
		 * ByteArray containing Depth information per pixel.
		 * Format is x,y,z where each is a Unsigned Short.
		 */
		private var _depthPoints:ByteArray;

		/**
		 * Flags to be passed to native kinect code for initalization.
		 * @see AIRKinectFlags
		 */
		private var _flags:ByteArray;

		/**
		 * Resolution for the RGB camera output
		 * @see AIRKinectCameraResolutions
		 */
		private var _rgbResolution:uint;

		/**
		 * Resolution for the Depth camera output
		 * @see AIRKinectCameraResolutions
		 */
		private var _depthResolution:uint;

		/**
		 * Provides a point container for Width (x) and Height (y) of a requested Resolution
		 * @see AIRKinect.getResolutionToSize
		 * @see AIRKinectCameraResolutions
		 */
		private var _resolutionSize:Point;

		//Determines if a physical Kinect has been initalized.
		internal var _isPhysicalKinectInit:Boolean;

		
		public function AIRKinect() {
			createContext();
		}

		/**
		 * Creates a instance of the Native Code extension, adds listeners to this extension and calls the init function.
		 * this will initialize the DeviceStatusCallback for disconnected and reconnected events
		 * this also set default smoothing parameters for skeleton frames
		 */
		public function createContext():void {
			_extCtx = ExtensionContext.createExtensionContext(EXTENSION_ID, null);
			_extCtx.addEventListener(StatusEvent.STATUS, onStatus);
		}

		public function initContext():Boolean {
			if(_isPhysicalKinectInit) return true;

			try {
				_extCtx.call("init");
				return true;
			}catch(e:Error){}

			return false;
		}

		/**
		 * Attempts to initialize the Kinect and starts any combination of Skeleton, RGB, and depth tracking.
		 * @param kinectFlags (optional)		Flags informing the Kinect on which data is required. Default is Skeleton only. @see AIRKinectFlags
		 * @param rgbResolution (optional)		Sets the resolution of the RGB camera. Only used if the AIRKinectFlags.NUI_INITIALIZE_FLAG_USES_COLOR is used
		 * 										Valid RGB Resolutions are:
		 * 											<ul>
		 * 												<li>AIRKinectCameraResolutions.NUI_IMAGE_RESOLUTION_640x480</li>
		 * 												<li>AIRKinectCameraResolutions.NUI_IMAGE_RESOLUTION_1280x1024</li>
		 * 											</ul>
		 * @param depthResolution (optional)	Sets the resolution of the Depth camera. Only used if the AIRKinectFlags.NUI_INITIALIZE_FLAG_USES_DEPTH or AIRKinectFlags.NUI_INITIALIZE_FLAG_USES_DEPTH_AND_PLAYER_INDEX is used.
		 * 										Valid Depth Resolutions in NUI_INITIALIZE_FLAG_USES_DEPTH mode
		 * 											<ul>
		 * 												<li>AIRKinectCameraResolutions.NUI_IMAGE_RESOLUTION_320x240</li>
		 * 											</ul>
		 * 										Valid Depth Resolutions in NUI_INITIALIZE_FLAG_USES_DEPTH_AND_PLAYER_INDEX mode
		 * 											<ul>
		 * 												<li>AIRKinectCameraResolutions.NUI_IMAGE_RESOLUTION_80x60</li>
		 *												<li>AIRKinectCameraResolutions.NUI_IMAGE_RESOLUTION_320x240</li>
		 *												<li>AIRKinectCameraResolutions.NUI_IMAGE_RESOLUTION_640x480</li>
		 *											</ul>
		 * @return								Boolean stating whether the Kinect was started successfully or not.
		 */
		public function initialize(kinectFlags:uint = AIRKinectFlags.NUI_INITIALIZE_FLAG_USES_SKELETON, rgbResolution:uint = AIRKinectCameraResolutions.NUI_IMAGE_RESOLUTION_640x480, depthResolution:uint = AIRKinectCameraResolutions.NUI_IMAGE_RESOLUTION_320x240):Boolean {
			if (_KINECT_RUNNING) throw new Error("Only one instance of the Kinect maybe run at a time");

			_flags = new ByteArray();
			_flags.writeByte(kinectFlags);

			_rgbResolution = rgbResolution;
			_depthResolution = depthResolution;

			if (_extCtx == null) createContext();
			_isPhysicalKinectInit = initContext();

			if(_isPhysicalKinectInit) {
				if (!_extCtx.call("kinectStart", kinectFlags, rgbResolution, depthResolution)) {
					shutdown();
					return false;
				}
			}

			return _isPhysicalKinectInit;
		}
		
		/**
		 * Called when the kinect has started
		 */ 
		private function onStarted():void{
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
			//Add standard to shutdown Kinect when the native application window is closed
			NativeApplication.nativeApplication.addEventListener(Event.EXITING, shutdown);
		}

		/**
		 * Completely shuts down the Kinect cleaning up the Native Extension.
		 */
		public function shutdown(event:Event=null):void {
			NativeApplication.nativeApplication.removeEventListener(Event.EXITING, shutdown);
			cleanupNativeExtension();
			cleanupASExtension();
		}

		/**
		 * Cleans up the Native Extension side, calling Kinect Stop to dispose of all memory. 
		 */
		private function cleanupNativeExtension():void {
			if (_extCtx) {
				if(_isPhysicalKinectInit) _extCtx.call("kinectStop");

				_isPhysicalKinectInit = false;
				_extCtx.removeEventListener(StatusEvent.STATUS, onStatus);
				_extCtx.dispose();
				_extCtx = null;
			}
		}

		/**
		 * Cleansup the AS side of the extension clearing byte arrays and BitmapData
		 */
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

		/**
		 * Called when the Kinect is disconnected, causes the AS part of the extension to clean up
		 */
		private function onDisconnected():void {
			cleanupASExtension();
		}

		/**
		 * Sets the Angle, in degrees, of the Kinect. Minimum angle is -27 Maximum is 27
		 * @param angle		Desired angle to move to
		 */
		public function setKinectAngle(angle:int):void {
			if(_isPhysicalKinectInit) _extCtx.call('setKinectAngle', angle);
		}

		/**
		 * Returns the current Angle of the Kinect
		 * @return			Angle in Degrees
		 */
		public function getKinectAngle():int {
			if(!_isPhysicalKinectInit) return NaN;
			return _extCtx.call('getKinectAngle') as int;
		}

		/**
		 * Sets the Smoothing Parameters for Skeleton Frames.
		 * @param nuiTransformSmoothingParameters		Smoothing Object to use to smooth Skeleton Frames
		 * @return			Boolean of success
		 */
		public function setTransformSmoothingParameters(nuiTransformSmoothingParameters:NUITransformSmoothParameters):Boolean {
			if(!_isPhysicalKinectInit) return false;

			_nuiTransformSmoothingParameters = nuiTransformSmoothingParameters;
			return _extCtx.call('setTransformSmoothingParameters', _nuiTransformSmoothingParameters);
		}

		/**
		 * Retrieves the current Smoothing Parameters from the Native side
		 * @return	NUITransformSmoothParameters with current smoothing data
		 */
		public function getTransformSmoothingParameters():NUITransformSmoothParameters {
			return _nuiTransformSmoothingParameters;
		}

		/**
		 * Boolean, based on Initialization flags, of RGB Camera activation
		 */
		public function get rgbEnabled():Boolean {
			return (_flags[0] & AIRKinectFlags.NUI_INITIALIZE_FLAG_USES_COLOR) != 0;
		}

		/**
		 * Boolean, based on Initialization flags, of Depth Camera activation
		 */
		public function get depthEnabled():Boolean {
			return (((_flags[0] & AIRKinectFlags.NUI_INITIALIZE_FLAG_USES_DEPTH_AND_PLAYER_INDEX) != 0) || ((_flags[0] & AIRKinectFlags.NUI_INITIALIZE_FLAG_USES_DEPTH) != 0));
		}

		/**
		 * Boolean, based on Initialization flags, of Player Index activation
		 */
		public function get isPlayerIndexEnabled():Boolean {
			return ((_flags[0] & AIRKinectFlags.NUI_INITIALIZE_FLAG_USES_DEPTH_AND_PLAYER_INDEX) != 0)
		}

		/**
		 * Boolean, based on Initialization flags, of Skeleton Frame activation
		 */
		public function get skeletonEnabled():Boolean {
			return (_flags[0] & AIRKinectFlags.NUI_INITIALIZE_FLAG_USES_SKELETON) != 0;
		}

		/**
		 * Helper function to get Resolution of the RGB image
		 */
		public function get rgbSize():Point {
			return getResolutionToSize(_rgbResolution);
		}

		/**
		 * Helper function to get Resolution of Depth Image
		 */
		public function get depthSize():Point {
			return getResolutionToSize(_depthResolution);
		}

		/**
		 * Utility function to convert AIRKinectCameraResolutions to Width (x) & Height (y)
		 * @param res		AIRKinectCameraResolutions in which to convert
		 * @return			Point with format of x as width and y as height
		 */
		private function getResolutionToSize(res:uint):Point {
			if (_resolutionSize == null) _resolutionSize = new Point();

			switch (res) {
				case AIRKinectCameraResolutions.NUI_IMAGE_RESOLUTION_80x60:
					_resolutionSize.x = 80;
					_resolutionSize.y = 60;
					break;
				case AIRKinectCameraResolutions.NUI_IMAGE_RESOLUTION_320x240:
					_resolutionSize.x = 320;
					_resolutionSize.y = 240;
					break;
				case AIRKinectCameraResolutions.NUI_IMAGE_RESOLUTION_640x480:
					_resolutionSize.x = 640;
					_resolutionSize.y = 480;
					break;
				case AIRKinectCameraResolutions.NUI_IMAGE_RESOLUTION_1280x1024 :
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

		/**
		 * Event Listener for Native Code. 
		 * @param event			Native Dispatched Event
		 */
		private function onStatus(event:StatusEvent):void {
			switch (event.code) {
				//Device Status Events are redispatched. In the case of a disconnected the AS side of the extension is cleaned up
				case DEVICE_STATUS:
						switch(event.level)
						{
							case DEVICE_STATUS_STARTED:
								onStarted();
								this.dispatchEvent(new DeviceStatusEvent(DeviceStatusEvent.STARTED));
								break;
							case DEVICE_STATUS_DISCONNECTED:
								onDisconnected();
								this.dispatchEvent(new DeviceStatusEvent(DeviceStatusEvent.DISCONNECTED));
								break;
							case DEVICE_STATUS_RECONNECTED:
								this.dispatchEvent(new DeviceStatusEvent(DeviceStatusEvent.RECONNECTED));
								break;
						}
					break;
				//Skeleton Frame events are redispatched
				case SKELETON_FRAME:
					if(_isPhysicalKinectInit) {
						try {
							var currentSkeleton:SkeletonFrame = _extCtx.call('getSkeletonFrameData') as SkeletonFrame;
							this.dispatchEvent(new SkeletonFrameEvent(currentSkeleton));
						} catch(e:Error) {
							trace("Skeleton Frame Error :: " + e.message);
						}
					}
					break;
				//RGB frame events are written into Bitmap Data and dispatched
				case RGB_FRAME:
					if(_isPhysicalKinectInit) {
						try {
							_extCtx.call('getRGBFrame', _rgbFrame);
							_rgbFrame.position = 0;
							_rgbFrame.endian = Endian.LITTLE_ENDIAN;
							_rgbImage.setPixels(new Rectangle(0, 0, _rgbImage.width, _rgbImage.height), _rgbFrame);
							this.dispatchEvent(new CameraFrameEvent(CameraFrameEvent.RGB, _rgbImage.clone()));
						} catch(e:Error) {
							trace("RGB Image Error :: " + e.message);
						}
					}
					break;
				//Depth Frame events are written into Bitmap Data. Point are property positioned and set to proper Endian, then dispatched
				case DEPTH_FRAME:
					if(_isPhysicalKinectInit) {
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
					}
					break;
			}
		}
	}
}