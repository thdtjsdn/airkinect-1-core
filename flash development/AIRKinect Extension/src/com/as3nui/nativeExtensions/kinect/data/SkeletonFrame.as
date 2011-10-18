/**
 *
 * User: rgerbasi
 * Date: 9/29/11
 * Time: 6:03 PM
 */
package com.as3nui.nativeExtensions.kinect.data {
	public class SkeletonFrame {
		public static const MAX_NUM_SKELETONS:uint = 6;

		//Collection of Skeleton Positions
		private var _skeletonsPositions:Vector.<SkeletonPosition>;

		public function SkeletonFrame(skeletonsPositions:Vector.<SkeletonPosition>) {
			_skeletonsPositions = skeletonsPositions;
		}

		public function getSkeletonPosition(index:uint):SkeletonPosition {
			return _skeletonsPositions[index];
		}

		public function get skeletonsPositions():Vector.<SkeletonPosition> {
			return _skeletonsPositions;
		}

		public function get numSkeletons():int {
			return _skeletonsPositions.length;
		}
	}
}