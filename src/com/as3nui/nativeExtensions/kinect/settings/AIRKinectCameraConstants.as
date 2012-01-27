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
	 * Camera Constants from the Kinect SDK to provide Focal Length based position translations.
	 */
	public class AIRKinectCameraConstants {
		public static const NUI_CAMERA_DEPTH_NOMINAL_FOCAL_LENGTH_IN_PIXELS:Number 			= 285.63;    // Based on 320x240 pixel size.
		public static const NUI_CAMERA_DEPTH_NOMINAL_INVERSE_FOCAL_LENGTH_IN_PIXELS:Number 	= 3.501e-3;  // (1/NUI_CAMERA_DEPTH_NOMINAL_FOCAL_LENGTH_IN_PIXELS)
		public static const NUI_CAMERA_DEPTH_NOMINAL_DIAGONAL_FOV:Number 					= 70.0;
		public static const NUI_CAMERA_DEPTH_NOMINAL_HORIZONTAL_FOV:Number					= 58.5;
		public static const NUI_CAMERA_DEPTH_NOMINAL_VERTICAL_FOV:Number					= 45.6;

		public static const NUI_CAMERA_COLOR_NOMINAL_FOCAL_LENGTH_IN_PIXELS:Number			= 531.15;   // Based on 640x480 pixel size.
		public static const NUI_CAMERA_COLOR_NOMINAL_INVERSE_FOCAL_LENGTH_IN_PIXELS:Number	= 1.83e-3; // (1/NUI_CAMERA_COLOR_NOMINAL_FOCAL_LENGTH_IN_PIXELS)
		public static const NUI_CAMERA_COLOR_NOMINAL_DIAGONAL_FOV:Number					= 73.9;
		public static const NUI_CAMERA_COLOR_NOMINAL_HORIZONTAL_FOV:Number					= 62.0;
		public static const NUI_CAMERA_COLOR_NOMINAL_VERTICAL_FOV:Number					= 48.6;
	}
}