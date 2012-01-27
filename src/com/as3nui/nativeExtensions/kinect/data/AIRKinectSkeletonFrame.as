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
		 * Collection of All Skeletons for this current Frame
		 */
		private var _skeletons:Vector.<AIRKinectSkeleton>;

		/**
		 * Constructor
		 * @param skeletons			Skeleton Positions in this frame
		 */
		public function AIRKinectSkeletonFrame(skeletons:Vector.<AIRKinectSkeleton>) {
			_skeletons = skeletons;
		}

		/**
		 * Get a Skeleton by index in the Vector
		 * @param index			Index of the skeleton to retrieve
		 * @return				AIRKinectSkeleton for skeleton at that index
		 */
		public function getSkeleton(index:uint):AIRKinectSkeleton {
			return _skeletons[index];
		}

		/**
		 * Returns all the Skeletons for the current Frame
		 */
		public function get skeletons():Vector.<AIRKinectSkeleton> {
			return _skeletons;
		}

		/**
		 * Number of skeletons found in this frame
		 */
		public function get numSkeletons():int {
			return _skeletons.length;
		}
	}
}