/**
 *
 * User: rgerbasi
 * Date: 9/29/11
 * Time: 6:17 PM
 */
package com.as3nui.nativeExtensions.kinect.data {
	import com.as3nui.nativeExtensions.kinect.AIRKinect;
	import com.as3nui.nativeExtensions.kinect.settings.AIRKinectCameraConstants;

	import flash.geom.Point;

	import flash.geom.Vector3D;

	/**
	 * SkeletonPosition holds all body joints (hands, head, arms, etc)
	 * Also provides translation options and scaling options for all position vectors
	 */
	public class AIRKinectSkeleton {
		/**
		 * Translates all joint positions based on depth camera focal length
		 */
		public static const DEPTH_CAMERA_TRANSLATION_MODE:String = "depth_camera_mode";
		/**
		 * Translates all joint positions based on RGB camera focal length
		 */
		public static const RGB_CAMERA_TRANSLATION_MODE:String = "rgb_camera_mode";

		/**
		 * No Translation, this will passthru raw position vector from the kinect
		 */
		public static const RAW_TRANSLATION_MODE:String = "raw_mode";

		/**
		 * Flattens the Translation of all joints such that 0 is the left/top and 1 is the right/bottom regardless of depth (default)
		 */
		public static const FLAT_TRANSLATION_MODE:String = "flat_mode";

		/**
		 * Index of Skeletons Hip Center
		 */
		public static const HIP_CENTER:uint = 0;
		/**
		 * Index of Skeletons Spine
		 */
		public static const SPINE:uint = 1;
		/**
		 * Index of Skeletons Shoulder Center
		 */
		public static const SHOULDER_CENTER:uint = 2;
		/**
		 * Index of Skeletons Head
		 */
		public static const HEAD:uint = 3;
		/**
		 * Index of Skeletons Left Shoulder
		 */
		public static const SHOULDER_LEFT:uint = 4;
		/**
		 * Index of Skeletons Left Elbow
		 */
		public static const ELBOW_LEFT:uint = 5;
		/**
		 * Index of Skeletons Left Wrist
		 */
		public static const WRIST_LEFT:uint = 6;
		/**
		 * Index of Skeletons Left Hand
		 */
		public static const HAND_LEFT:uint = 7;
		/**
		 * Index of Skeletons Right Shoulder
		 */
		public static const SHOULDER_RIGHT:uint = 8;
		/**
		 * Index of Skeletons Right Elbow
		 */
		public static const ELBOW_RIGHT:uint = 9;
		/**
		 * Index of Skeletons Right Wrist
		 */
		public static const WRIST_RIGHT:uint = 10;
		/**
		 * Index of Skeletons Right Hand
		 */
		public static const HAND_RIGHT:uint = 11;
		/**
		 * Index of Skeletons Hip Left
		 */
		public static const HIP_LEFT:uint = 12;
		/**
		 * Index of Skeletons Left Knee
		 */
		public static const KNEE_LEFT:uint = 13;
		/**
		 * Index of Skeletons Left Ankle
		 */
		public static const ANKLE_LEFT:uint = 14;
		/**
		 * Index of Skeletons Left Foot
		 */
		public static const FOOT_LEFT:uint = 15;
		/**
		 * Index of Skeletons Hip Right
		 */
		public static const HIP_RIGHT:uint = 16;
		/**
		 * Index of Skeletons Right Knee
		 */
		public static const KNEE_RIGHT:uint = 17;
		/**
		 * Index of Skeletons Right Ankle
		 */
		public static const ANKLE_RIGHT:uint = 18;
		/**
		 * Index of Skeletons Right Foot
		 */
		public static const FOOT_RIGHT:uint = 19;

		/**
		 * Total joints in a skeleton
		 */
		public static const NUM_JOINTS:uint = 20;

		/**
		 * Skeleton joints are not tracking
		 */
		public static const STATE_NOT_TRACKED:uint = 0;

		/**
		 * Position og the skeleton is tracked but NOT the joints
		 */
		public static const STATE_POSITION_ONLY:uint = 1;

		/**
		 * All joints are tracked current this is the only available state for AIRKinect
		 */
		public static const STATE_SKELETON_TRACKED:uint = 2;

		/**
		 * Current Translation mode for all joints
		 * @see AIRKinectSkeleton.DEPTH_CAMERA_TRANSLATION_MODE
		 * @see AIRKinectSkeleton.RGB_CAMERA_TRANSLATION_MODE
		 * @see AIRKinectSkeleton.FLAT_TRANSLATION_MODE
		 * @see AIRKinectSkeleton.RAW_TRANSLATION_MODE
		 */
		public static var TRANSLATION_MODE:String = FLAT_TRANSLATION_MODE;

		/**
		 * Current Frame Number from the Kinect
		 * See MSKinect SDK for more information
		 */
		private var _frameNumber:uint;
		/**
		 * Timestamp of current Frame
		 * See MSKinect SDK for more information
		 */
		private var _timestamp:uint;
		/**
		 * Current skeleton Tracking ID
		 * See MSKinect SDK for more information
		 */
		private var _trackingID:uint;

		/**
		 * Current Tracking State for this skeleton
		 * See MSKinect SDK for more information
		 */
		private var _trackingState:uint;
		/**
		 * Collection of Skeleton joints
		 */
		private var _joints:Vector.<AIRKinectSkeletonJoint>;

		public function AIRKinectSkeleton(frameNumber:uint, timestamp:uint, trackingID:uint, trackingState:uint, joints:Vector.<AIRKinectSkeletonJoint>) {
			_frameNumber = frameNumber;
			_timestamp = timestamp;
			_trackingID = trackingID;
			_trackingState = trackingState;
			_joints = joints;
		}

		/**
		 * Helper function to determine if Skeleton has tracked joints
		 */
		public function get isSkeletonTracked():Boolean {
			return _trackingState == STATE_SKELETON_TRACKED;
		}

		/**
		 * Helper function to determine if an joint exists for a skeleton
		 * @param index			Skeleton joint index to check for
		 * @return				Boolean for existence
		 */
		public function jointExists(index:uint):Boolean {
			return _joints[index] is AIRKinectSkeletonJoint;
		}

		/**
		 * Returns the position of a current joint of a skelenton
		 * @param index			Joint index to look up
		 * @return				AIRKinectSkeletonJoint with the position of the current joint translated according to SkeletonPosition.TRANSLATION_MODE
		 */
		public function getJoint(index:uint):AIRKinectSkeletonJoint {
			var transformedJoint:AIRKinectSkeletonJoint = _joints[index].getClone() as AIRKinectSkeletonJoint;
			switch (TRANSLATION_MODE) {
				case DEPTH_CAMERA_TRANSLATION_MODE:
					transformedJoint.x = 0.5 + transformedJoint.x * (AIRKinectCameraConstants.NUI_CAMERA_DEPTH_NOMINAL_FOCAL_LENGTH_IN_PIXELS / transformedJoint.z ) / 320;
					transformedJoint.y = 0.5 - transformedJoint.y * (AIRKinectCameraConstants.NUI_CAMERA_DEPTH_NOMINAL_FOCAL_LENGTH_IN_PIXELS / transformedJoint.z ) / 240;
					break;
				case RGB_CAMERA_TRANSLATION_MODE:
					transformedJoint.x = 0.5 + transformedJoint.x * (AIRKinectCameraConstants.NUI_CAMERA_COLOR_NOMINAL_FOCAL_LENGTH_IN_PIXELS / transformedJoint.z ) / 640;
					transformedJoint.y = 0.5 - transformedJoint.y * (AIRKinectCameraConstants.NUI_CAMERA_COLOR_NOMINAL_FOCAL_LENGTH_IN_PIXELS / transformedJoint.z ) / 480;
					break;
				case FLAT_TRANSLATION_MODE:
					transformedJoint.x = (transformedJoint.x + 1) * .5;
					transformedJoint.y = (transformedJoint.y - 1) / -2;
					break;
				case RAW_TRANSLATION_MODE:
					break;
			}
			return transformedJoint;
		}

		/**
		 * Scales a joints position vector by any other vector.
		 * <p>
		 *     For example to scale to fit the stage one would use the following
		 * 		<p><code>
		 * 			var scaler:Vector3D = new Vector3D(stage.stageWidth, stage.stageHeight, KinectMaxDepthInFlash);
		 * 			var joint:AIRKinectSkeletonJoint = skeleton.getJointScaled(i, scaler);
		 * 		</code></p>
		 * </p>
		 * @param index		Joint to get scaled position of
		 * @param scale		AIRKinectSkeletonJoint to scale by
		 * @return
		 */
		public function getJointScaled(index:uint, scale:Vector3D):AIRKinectSkeletonJoint {
			var transformedJoint:AIRKinectSkeletonJoint = getJoint(index);
			transformedJoint.x *= scale.x;
			transformedJoint.y *= scale.y;
			transformedJoint.z *= scale.z;
			return transformedJoint;
		}

		/**
		 * Allows access to raw joint positions regardless of translation mode
		 * @param index		Joint to get raw position of
		 * @return			raw position of joint
		 */
		public function getJointRaw(index:uint):AIRKinectSkeletonJoint {
			return _joints[index];
		}

		/**
		 * Returns a joints position in RGB Space
		 * @param index 	Joint to get raw position of
		 * @return			2D Position of joint in RGB Space
		 */
		public function getJointInRGBSpace(index:uint):Point {
			return AIRKinect.getColorPixelFromJoint(this.getJointRaw(index));
		}

		/**
		 * Returns a joints position in Depth Space
		 * @param index 	Joint to get raw position of
		 * @return			2D Position of joint in Depth Space
		 */
		public function getJointInDepthSpace(index:uint):Point {
			return AIRKinect.getDepthPixelFromJoint(this.getJointRaw(index));
		}

		public function get trackingID():uint {
			return _trackingID;
		}

		public function get trackingState():uint {
			return _trackingState;
		}

		public function get numJoints():uint {
			return _joints.length;
		}

		public function get joints():Vector.<AIRKinectSkeletonJoint> {
			return _joints;
		}

		public function get frameNumber():uint {
			return _frameNumber;
		}

		public function get timestamp():uint {
			return _timestamp;
		}
	}
}