/**
 *
 * User: rgerbasi
 * Date: 9/28/11
 * Time: 3:09 PM
 */
package com.as3nui.nativeExtensions.kinect {
	import com.as3nui.nativeExtensions.kinect.data.NUITransformSmoothParameters;
	import com.as3nui.nativeExtensions.kinect.data.SkeletonFrame;

	import flash.events.EventDispatcher;
	import flash.events.StatusEvent;
	import flash.external.ExtensionContext;
	import flash.utils.ByteArray;

	import org.osflash.signals.Signal;

	public class AIRKinect extends EventDispatcher {
		private static var SKELETON_FRAME:String	= "skeletonFrame";
		private static var RGB_FRAME:String			= "RGBFrame";
		private static var DEPTH_FRAME:String		= "depthFrame";
		
		
		//Static Variables
		private static var isInstantiated:Boolean = false;
		private static var EXTENSION_ID:String = 'com.as3nui.extensions.AIRKinect';
		private static var extCtx:ExtensionContext;

		//Instance Variables
		protected var _onSkeletonFrame:Signal;
		protected var _onRGBFrame:Signal;
		protected var _onDepthFrame:Signal;

		protected var _nuiTransformSmoothingParameters:NUITransformSmoothParameters;
		protected var _rgbFrame:ByteArray;
		protected var _depthFrame:ByteArray;

		public function AIRKinect() {
			if(!isInstantiated){
				extCtx = ExtensionContext.createExtensionContext(EXTENSION_ID, null);
				if(extCtx != null){
					extCtx.call("init");

					if (!extCtx.call("kinectStart")) {
						throw new Error("Error while Starting Kinect");
					} else {
						extCtx.addEventListener(StatusEvent.STATUS, onStatus);
					}
				}
				isInstantiated = true;
			}

			if(extCtx != null){
				_onSkeletonFrame 	= new Signal(SkeletonFrame);
				_onRGBFrame			= new Signal(ByteArray);
				_onDepthFrame		= new Signal(ByteArray);

				_rgbFrame 			= new ByteArray();
				_depthFrame 		= new ByteArray();
			} else{
				throw new Error("Error while instantiating Kinect Extension");
			}
		}

		//----------------------------------
		// Public functions 
		//----------------------------------
		public function setKinectAngle(angle:int):void {
			extCtx.call('setKinectAngle', angle);
		}

		public function getKinectAngle():int {
			if (extCtx != null) {
				return extCtx.call('getKinectAngle') as int;
			}
			return NaN;
		}

		public function setTransformSmoothingParameters(nuiTransformSmoothingParameters:NUITransformSmoothParameters):Boolean {
			_nuiTransformSmoothingParameters = nuiTransformSmoothingParameters;
			return extCtx.call('setTransformSmoothingParameters', _nuiTransformSmoothingParameters);
		}

		public function getTransformSmoothingParameters():NUITransformSmoothParameters {
			return _nuiTransformSmoothingParameters;
		}

		public function dispose():void {
			if (extCtx != null) {
				extCtx.call("kinectStop");
				extCtx.removeEventListener(StatusEvent.STATUS, onStatus);
				extCtx.dispose();
				extCtx = null;

				_onDepthFrame.removeAll();
				_onSkeletonFrame.removeAll();
				_onDepthFrame.removeAll();
				_onSkeletonFrame = _onRGBFrame = _onDepthFrame = null;
			}
		}

		//----------------------------------
		// Private Functions
		//----------------------------------
		protected function onStatus(event:StatusEvent):void {
			switch(event.code){
				case SKELETON_FRAME:
						if(_onSkeletonFrame.numListeners >0){
							var _currentSkeleton:SkeletonFrame = extCtx.call('getSkeletonFrameData') as SkeletonFrame;
							_onSkeletonFrame.dispatch(_currentSkeleton);
						}
					break;
				case RGB_FRAME:
						if(_onRGBFrame.numListeners > 0){
							extCtx.call('getRGBFrame', _rgbFrame);
							_onRGBFrame.dispatch(_rgbFrame);
						}
					break;
				case DEPTH_FRAME:
						if(_onDepthFrame.numListeners > 0){
							extCtx.call('getDepthFrame', _depthFrame);
							_onDepthFrame.dispatch(_depthFrame);
						}
					break;
			}
		}
		public function get onSkeletonFrame():Signal {
			return _onSkeletonFrame;
		}

		public function get onRGBFrame():Signal {
			return _onRGBFrame;
		}

		public function get onDepthFrame():Signal {
			return _onDepthFrame;
		}
	}
}