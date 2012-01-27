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
	import com.as3nui.nativeExtensions.kinect.data.AIRKinectSkeletonFrame;

	import flash.events.Event;

	/**
	 * Dispatched containing a new SkeletonFrame.
	 */
	public class SkeletonFrameEvent extends Event {

		/**
		 * Dispatched with a new skeleton frame
		 */
		public static const UPDATE:String = "update";

		/**
		 * Current Skeleton Frame
		 */
		private var _skeletonFrame:AIRKinectSkeletonFrame;

		public function SkeletonFrameEvent(skeletonFrame:AIRKinectSkeletonFrame) {
			super(UPDATE);
			_skeletonFrame = skeletonFrame;
		}

		public override function clone():Event {
			return new SkeletonFrameEvent(_skeletonFrame);
		}

		public override function toString():String {
			return formatToString("SkeletonFrameEvent", "type", "skeletonFrame");
		}

		/**
		 * Skeleton Frame for this event
		 */
		public function get skeletonFrame():AIRKinectSkeletonFrame {
			return _skeletonFrame;
		}
	}
}