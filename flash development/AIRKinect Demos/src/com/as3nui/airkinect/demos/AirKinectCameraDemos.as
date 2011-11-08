/**
 *
 * User: rgerbasi
 * Date: 10/16/11
 * Time: 5:51 PM
 */
package com.as3nui.airkinect.demos {
	import com.as3nui.nativeExtensions.kinect.AIRKinect;
	import com.as3nui.nativeExtensions.kinect.events.CameraFrameEvent;

	import flash.desktop.NativeApplication;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix3D;
	import flash.geom.PerspectiveProjection;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	import flash.utils.ByteArray;

	public class AirKinectCameraDemos extends Sprite {

		private var _flags:uint;

		private var _rgbImage:Bitmap;
		private var _depthImage:Bitmap;
		private var _depthPoints:ByteArray;
		private var _pointCloudImage:Bitmap;

		private var _buffer: Vector.<uint> = new Vector.<uint>( 320 * 240, true );
		private var _focalLength: Number;
		private var _matrix:Matrix3D = new Matrix3D();
		private var _targetZ:Number = 0;

		public function AirKinectCameraDemos() {
			var perspectiveProjection: PerspectiveProjection = new PerspectiveProjection( );
			perspectiveProjection.fieldOfView = 60.0;
			_focalLength = perspectiveProjection.focalLength;
			this.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage)
		}

		private function onAddedToStage(event:Event):void {
			initDemo();

			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;

			stage.addEventListener(Event.RESIZE, onStageResize);
		}

		private function onStageResize(event:Event):void {
			root.transform.perspectiveProjection.projectionCenter = new Point(stage.stageWidth / 2, stage.stageHeight / 2);

			if (_depthImage) _depthImage.x = stage.stageWidth - _depthImage.width;
			if (_pointCloudImage) {
				_pointCloudImage.x = stage.stageWidth/2 - _pointCloudImage.width/2;
				_pointCloudImage.y = stage.stageHeight/2 - _pointCloudImage.height/2;
			}
		}

		private function initDemo():void {
			_flags = AIRKinect.NUI_INITIALIZE_FLAG_USES_COLOR | AIRKinect.NUI_INITIALIZE_FLAG_USES_DEPTH;
			initKinect();
		}

		private function initKinect():void {
			if(!AIRKinect.initialize(_flags)){
				trace("Kinect Failed");
			}else{
				trace("Kinect Success");
				onKinectLoaded();
			}
		}

		private function onKinectLoaded():void {
			_rgbImage = new Bitmap(new BitmapData(AIRKinect.rgbSize.x, AIRKinect.rgbSize.y, true, 0xffff0000));
			_rgbImage.scaleX = _rgbImage.scaleY = .5;
			this.addChild(_rgbImage);
			AIRKinect.addEventListener(CameraFrameEvent.RGB, onRGBFrame);

			_depthImage = new Bitmap(new BitmapData(AIRKinect.depthSize.x, AIRKinect.depthSize.y, true, 0xffff0000));
			this.addChild(_depthImage);
			AIRKinect.addEventListener(CameraFrameEvent.DEPTH, onDepthFrame);

			_pointCloudImage = new Bitmap(new BitmapData(AIRKinect.depthSize.x, AIRKinect.depthSize.y, true, 0xffff0000));
			this.addChild(_pointCloudImage);

			//Listeners
			NativeApplication.nativeApplication.addEventListener(Event.EXITING, onExiting);
			onStageResize(null);

			this.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			stage.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
		}

		private function onMouseWheel(event:MouseEvent):void {
			_targetZ -= event.shiftKey ? event.delta *2 : event.delta;
		}

		private function onExiting(event:Event):void {
			AIRKinect.shutdown();
		}

		private function onRGBFrame(e:CameraFrameEvent):void {
			_rgbImage.bitmapData = e.frame;
		}

		private function onDepthFrame(e:CameraFrameEvent):void {
			_depthImage.bitmapData = e.frame;
			_depthPoints = e.data;
		}
		
		private function onEnterFrame(event:Event):void {
			drawPoints();
		}

		/**
		 * Drawing code adapter form Joa-ebert
		 * http://blog.joa-ebert.com/2009/04/03/massive-amounts-of-3d-particles-without-alchemy-and-pixelbender/
		 */
		private function drawPoints():void {
			if (!_depthPoints) return;

			var targetX:Number = ((( mouseX / stage.stageWidth) - .5) * 2) * 180;
			var targetY:Number = ((( mouseY / stage.stageHeight) - .5) * 2) * 180;

			_matrix.identity();
			_matrix.appendRotation(targetX, Vector3D.Y_AXIS);
			_matrix.appendRotation(targetY, Vector3D.X_AXIS);
			_matrix.appendTranslation(0.0, 0.0, _targetZ);

			var x:Number;
			var y:Number;
			var z:Number;
			var w:Number;

			var pz:Number;

			var xi:int;
			var yi:int;

			var p00:Number = _matrix.rawData[ 0x0 ];
			var p01:Number = _matrix.rawData[ 0x1 ];
			var p02:Number = _matrix.rawData[ 0x2 ];
			var p10:Number = _matrix.rawData[ 0x4 ];
			var p11:Number = _matrix.rawData[ 0x5 ];
			var p12:Number = _matrix.rawData[ 0x6 ];
			var p20:Number = _matrix.rawData[ 0x8 ];
			var p21:Number = _matrix.rawData[ 0x9 ];
			var p22:Number = _matrix.rawData[ 0xa ];
			var p32:Number = _matrix.rawData[ 0xe ];

			var bufferWidth:int = 320;
			var bufferMax:int = _buffer.length;
			var bufferMin:int = -1;
			var bufferIndex:int;
			var buffer:Vector.<uint> = _buffer;

			var cx:Number = 160.0;
			var cy:Number = 120.0;
			var minZ:Number = 0.0;

			var n:int = bufferMax;
			while (--n > -1) buffer[ n ] = 0xff000000;

			var r:Number;

			_depthPoints.position = 0;
			while (_depthPoints.bytesAvailable) {
				x = _depthPoints.readShort();
				x -= 160;

				y = _depthPoints.readShort();
				y -= 120;

				z = _depthPoints.readShort();
				if (z < 1) z = 1;
				if (z > 2047) z = 2047;
				z -= 1024;

				pz = _focalLength + x * p02 + y * p12 + z * p22 + p32;

				if (minZ < pz) {
					xi = int(( w = _focalLength / pz ) * ( x * p00 + y * p10 + z * p20 ) + cx);
					if (xi < 0) continue;
					if (xi > bufferWidth) continue;

					yi = int(w * ( x * p01 + y * p11 + z * p21 ) + cy);

					if (bufferMin < ( bufferIndex = int(xi + int(yi * bufferWidth)) ) && bufferIndex < bufferMax) {
						r = Math.abs((1 - Math.abs((z + 1024) / 2047)) * 255);
						buffer[ bufferIndex ] = 0xff << 24 | r << 16 | r << 8 | r;
					}
				}
			}

			_pointCloudImage.bitmapData.lock();
			_pointCloudImage.bitmapData.setVector(_pointCloudImage.bitmapData.rect, buffer);
			_pointCloudImage.bitmapData.unlock(_pointCloudImage.bitmapData.rect);
		}
	}
}