package com.as3nui.nativeExtensions.kinect.events {
	import flash.display.BitmapData;
	import flash.events.Event;

	public class CameraFrameEvent extends Event {
		public static const RGB:String 		= "rgb_frame_update";
		public static const DEPTH:String 	= "depth_frame_update";
		private var _frame:BitmapData;

		public function CameraFrameEvent(type:String, frame:BitmapData) {
			super(type);
			_frame = frame;
		}

		public override function clone():Event {
			return new CameraFrameEvent(type, _frame);
		}

		public override function toString():String {
			return formatToString("CameraFrameEvent", "type", "frame");
		}

		public function get frame():BitmapData {
			return _frame;
		}
	}
}