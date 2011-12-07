package com.as3nui.nativeExtensions.kinect.events {
	import com.as3nui.nativeExtensions.kinect.data.SkeletonFrame;

	import flash.events.Event;

	/**
	 * Dispatched containing a new SkeletonFrame.
	 */
	public class SkeletonFrameEvent extends Event {

		/**
		 * Dispatched with a new skeleton frame
		 */
		public static const UPDATE:String = "skeleton_frame_update";

		/**
		 * Current Skeleton Frame
		 */
		private var _skeletonFrame:SkeletonFrame;

		public function SkeletonFrameEvent(skeletonFrame:SkeletonFrame) {
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
		public function get skeletonFrame():SkeletonFrame {
			return _skeletonFrame;
		}
	}
}