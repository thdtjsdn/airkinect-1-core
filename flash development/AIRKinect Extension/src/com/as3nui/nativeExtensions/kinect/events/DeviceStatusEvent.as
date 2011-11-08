package com.as3nui.nativeExtensions.kinect.events {
	import flash.events.Event;

	public class DeviceStatusEvent extends Event {
		public static const DISCONNECTED:String 	= "disconnected";
		public static const RECONNECTED:String 		= "connected";

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