package com.as3nui.nativeExtensions.kinect.events {
	import flash.events.Event;

	/**
	 * Dispatched anytime the Kinect triggers a Device Status Event.
	 * This could be disconnection or reconnection of the power or USB cable.
	 */
	public class DeviceStatusEvent extends Event {
		/**
		 * Dispatched when Kinect is started and ready to use
		 */
		public static const STARTED:String 	= "started";
		
		/**
		 * Dispatched when Kinect is disconnected from the system
		 */
		public static const DISCONNECTED:String 	= "disconnected";

		/**
		 * Dispatched on reconnect of the Kinect to the system
		 */
		public static const RECONNECTED:String 		= "reconnected";

		public function DeviceStatusEvent(type:String) {
			super(type);
		}

		public override function clone():Event {
			return new DeviceStatusEvent(type);
		}

		public override function toString():String {
			return formatToString("KinectErrorEvent", "type", "bubbles", "cancelable", "eventPhase");
		}
	}
}