/**
 *
 * User: rgerbasi
 * Date: 10/16/11
 * Time: 5:51 PM
 */
package com.as3nui.airkinect.demos {
	import com.as3nui.nativeExtensions.kinect.AIRKinect;
	import com.as3nui.nativeExtensions.kinect.data.SkeletonFrame;
	import com.as3nui.nativeExtensions.kinect.data.SkeletonPosition;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	import flash.utils.ByteArray;
	import flash.utils.Endian;

	public class AirKinectDemos extends Sprite {

		private var _airKinect:AIRKinect;
		private var _currentSkeletons:Vector.<SkeletonPosition>;

		private var _skeletonsSprite:Sprite;
		private var _kinectMaxDepthInFlash:uint = 200;

		private var _rgbImage:Bitmap;
		private var _depthImage:Bitmap;

		public function AirKinectDemos() {
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
		}

		private function initDemo():void {
			_skeletonsSprite = new Sprite();
			this.addChild(_skeletonsSprite);

			_rgbImage = new Bitmap(new BitmapData(640, 480, true, 0xffff0000));
			_rgbImage.scaleX = _rgbImage.scaleY = .5;
			this.addChild(_rgbImage);

			_depthImage = new Bitmap(new BitmapData(320, 240, true, 0xffff0000));
			this.addChild(_depthImage);

			_airKinect = new AIRKinect();
			_airKinect.onSkeletonFrame.add(onSkeletonFrame);

			_airKinect.onRGBFrame.add(onRGBFrame);
			_airKinect.onDepthFrame.add(onDepthFrame);

			this.addEventListener(Event.ENTER_FRAME, onEnterFrame)
		}

		private function onRGBFrame(byteArray:ByteArray):void {
			byteArray.position = 0;
			byteArray.endian = Endian.LITTLE_ENDIAN;
			_rgbImage.bitmapData.setPixels(new Rectangle(0, 0, 640, 480), byteArray);
		}

		private function onDepthFrame(byteArray:ByteArray):void {
			byteArray.position = 0;
			byteArray.endian = Endian.LITTLE_ENDIAN;
			_depthImage.bitmapData.setPixels(new Rectangle(0, 0, 320, 240), byteArray);
		}

		private function onSkeletonFrame(skeletonFrame:SkeletonFrame):void {
			_currentSkeletons = new <SkeletonPosition>[];

			if (skeletonFrame.numSkeletons > 0) {
				for (var j:uint = 0; j < skeletonFrame.numSkeletons; j++) {
					_currentSkeletons.push(skeletonFrame.getSkeletonPosition(j));
				}
			}
		}

		private function onEnterFrame(event:Event):void {
			drawSkeletons();
		}

		private function drawSkeletons():void {
			while (_skeletonsSprite.numChildren > 0) _skeletonsSprite.removeChildAt(0);

			var element:Vector3D;
			var scaler:Vector3D = new Vector3D(stage.stageWidth, stage.stageHeight, _kinectMaxDepthInFlash);
			var elementSprite:Sprite;

			var color:uint;
			for each(var skeleton:SkeletonPosition in _currentSkeletons) {
				for (var i:uint = 0; i < skeleton.numElements; i++) {
					element = skeleton.getElementScaled(i, scaler);

					elementSprite = new Sprite();
					color = (element.z / (_kinectMaxDepthInFlash * 4)) * 255 << 16 | (1 - (element.z / (_kinectMaxDepthInFlash * 4))) * 255 << 8 | 0;
					elementSprite.graphics.beginFill(color);
					elementSprite.graphics.drawCircle(0, 0, 15);
					elementSprite.x = element.x;
					elementSprite.y = element.y;
					elementSprite.z = element.z;
					_skeletonsSprite.addChild(elementSprite);
				}
			}
		}
	}
}