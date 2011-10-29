package com.as3nui.nativeExtensions.kinect.events {
	import flash.events.Event;

	public class KinectErrorEvent extends Event {
		public static const CONNECTION_ERROR:String = "connection_error";

		public function KinectErrorEvent(type:String) {
			super(type);
		}

		public override function clone():Event {
			return new KinectErrorEvent(type);
		}

		public override function toString():String {
			return formatToString("KinectErrorEvent", "type", "bubbles", "cancelable", "eventPhase");
		}
	}
}