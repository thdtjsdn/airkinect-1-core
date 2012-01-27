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

package com.as3nui.nativeExtensions.kinect.settings {

	/**
	 * Flags for initialization of the Kinect. To combine flags use the following syntax.
	 * <p>
	 * <code>
	 *	 var flasg:uint = AIRKinectFlags.NUI_INITIALIZE_FLAG_USES_SKELETON | AIRKinectFlags.NUI_INITIALIZE_FLAG_USES_COLOR | AIRKinectFlags.NUI_INITIALIZE_FLAG_USES_DEPTH;
	 * </code>
	 * </p>
	 */
	public class AIRKinectFlags {
		public static const NUI_INITIALIZE_FLAG_USES_DEPTH_AND_PLAYER_INDEX:uint = 0x00000001;

		public static const NUI_INITIALIZE_FLAG_USES_COLOR:uint = 0x00000002;

		public static const NUI_INITIALIZE_FLAG_USES_SKELETON:uint = 0x00000008;

		public static const NUI_INITIALIZE_FLAG_USES_DEPTH:uint = 0x00000020;
	}
}