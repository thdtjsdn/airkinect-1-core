/**
 *
 * User: rgerbasi
 * Date: 11/11/11
 * Time: 11:12 AM
 */
package com.as3nui.nativeExtensions.kinect.settings {

	/**
	 * Available Resolutions for the cameras in the Kinect.
	 * <ul>
	 *	 <li>Valid RGB Resolutions are:</li>
	 *		 <ul>
	 *			 <li>AIRKinectCameraResolutions.NUI_IMAGE_RESOLUTION_640x480</li>
	 *			 <li>AIRKinectCameraResolutions.NUI_IMAGE_RESOLUTION_1280x1024</li>
	 *		 </ul>
	 *	 <li>Valid Depth Resolutions in NUI_INITIALIZE_FLAG_USES_DEPTH mode</li>
	 *		<ul>
	 *			<li>AIRKinectCameraResolutions.NUI_IMAGE_RESOLUTION_320x240</li>
	 *		</ul>
	 *	 <li>Valid Depth Resolutions in NUI_INITIALIZE_FLAG_USES_DEPTH_AND_PLAYER_INDEX mode</li>
	 *		 <ul>
	 *		 <li>AIRKinectCameraResolutions.NUI_IMAGE_RESOLUTION_80x60</li>
	 *		 <li>AIRKinectCameraResolutions.NUI_IMAGE_RESOLUTION_320x240</li>
	 *		 <li>AIRKinectCameraResolutions.NUI_IMAGE_RESOLUTION_640x480</li>
	 *		</ul>
	 * </ul>
	 */
	public class AIRKinectCameraResolutions {
		public static const NUI_IMAGE_RESOLUTION_80x60:uint = 0;

		public static const NUI_IMAGE_RESOLUTION_320x240:uint = 1;

		public static const NUI_IMAGE_RESOLUTION_640x480:uint = 2;

		public static const NUI_IMAGE_RESOLUTION_1280x1024:uint = 3;
	}
}