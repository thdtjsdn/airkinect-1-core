/*
 * Copyright 2012 AS3NUI
 *
 *    Licensed under the Apache License, Version 2.0 (the "License");
 *    you may not use this file except in compliance with the License.
 *    You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *    Unless required by applicable law or agreed to in writing, software
 *    distributed under the License is distributed on an "AS IS" BASIS,
 *    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *    See the License for the specific language governing permissions and
 *    limitations under the License.
 */

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