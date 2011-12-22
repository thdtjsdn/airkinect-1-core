/**
 *
 * User: rgerbasi
 * Date: 9/29/11
 * Time: 6:03 PM
 */
package com.as3nui.nativeExtensions.kinect.data {

	/**
	 * Holds all the skeleton information for a frame. A Frame consists of 0, 1, or multiple Skeleton Positions
	 */
	public class AIRKinectSkeletonFrame {
		/**
		 * Max number of skeletons avaliable for the Kinect with Full joint data
		 */
		public static const MAX_NUM_SKELETONS:uint = 2;

		/**
		 * Collection of All Skeleton Positions for this current Frame
		 */
		private var _skeletonsPositions:Vector.<AIRKinectSkeleton>;

		/**
		 * Constructor
		 * @param skeletonsPositions			Skeleton Positions in this frame
		 */
		public function AIRKinectSkeletonFrame(skeletonsPositions:Vector.<AIRKinectSkeleton>) {
			_skeletonsPositions = skeletonsPositions;
		}

		/**
		 * Get the Position of a Skeleton by index in the Vector
		 * @param index			Index of the skeleton to retrieve
		 * @return				Skeleton Positon for skeleton at that index
		 */
		public function getSkeletonPosition(index:uint):AIRKinectSkeleton {
			return _skeletonsPositions[index];
		}

		/**
		 * Returns all the Skeletons for the current Frame
		 */
		public function get skeletonsPositions():Vector.<AIRKinectSkeleton> {
			return _skeletonsPositions;
		}

		/**
		 * Number of skeletons found in this frame
		 */
		public function get numSkeletons():int {
			return _skeletonsPositions.length;
		}
	}
}