/**
 *
 * User: rgerbasi
 * Date: 11/11/11
 * Time: 11:14 AM
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