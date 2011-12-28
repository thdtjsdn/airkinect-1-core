package com.as3nui.nativeExtensions.kinect.events {
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.utils.ByteArray;

	/**
	 * Dispatched when any camera frame is updated could be either Depth or RGB Data.
	 * In the case of Depth without player the data properly will container per pixel depth data, otherwise will be null.
	 */
	public class CameraFrameEvent extends Event {
		/**
		 * Dispatched with new RGB frame from Kinect Camera
		 */
		public static const RGB:String 		= "rgb";
		/**
		 * Dispatched with new Depth Frame from Kinect Camera
		 */
		public static const DEPTH:String 	= "depth";
		/**
		 * Dispatched with new Player Mask Frame from Kinect Camera
		 */
		public static const PLAYER_MASK:String 	= "playerMask";

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