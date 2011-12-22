/**
 *
 * User: rgerbasi
 * Date: 10/3/11
 * Time: 11:04 AM
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