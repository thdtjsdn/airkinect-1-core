package com.as3nui.nativeExtensions.kinect.events {
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.utils.ByteArray;

	public class CameraFrameEvent extends Event {
		public static const RGB:String 		= "rgb_frame_update";
		public static const DEPTH:String 	= "depth_frame_update";
		private var _frame:BitmapData;
		private var _data:ByteArray;

		public function CameraFrameEvent(type:String, frame:BitmapData, data:ByteArray = null) {
			super(type);
			_frame = frame;
			_data = data;
		}

		public override function clone():Event {
			return new CameraFrameEvent(type, _frame, _data);
		}

		public override function toString():String {
			return formatToString("CameraFrameEvent", "type", "frame");
		}

		public function get frame():BitmapData {
			return _frame;
		}

		public function get data():ByteArray {
			return _data;
		}
	}
}