package com.as3nui.nativeExtensions.kinect.events {
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.utils.ByteArray;

	public class CameraFrameEvent extends Event {
		/**
		 * Dispatched with new RGB frame from Kinect Camera
		 */
		public static const RGB:String 		= "rgb_frame_update";
		/**
		 * Dispatched with new Depth Frame from Kinect Camers
		 */
		public static const DEPTH:String 	= "depth_frame_update";

		/**
		 * BitmapData for the current frame
		 */
		private var _frame:BitmapData;
		/**
		 * Only created using AIRkinectFlags.NUI_INITIALIZE_FLAG_USES_DEPTH mode. Data is a Byte Array in the format x,y,z where each us a Unsigned Short
		 * the array will contain ((_frame.width * _frame.height) * (2 *3)) bytes. (2 bytes per UShort and 3 USHORTs per pixel.)
		 */
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