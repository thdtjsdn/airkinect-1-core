/**
 *
 * User: Ross
 * Date: 12/21/11
 * Time: 10:19 PM
 */
package com.as3nui.nativeExtensions.kinect.data {
	import flash.geom.Vector3D;
	public class AIRKinectSkeletonJoint extends Vector3D {
		public function AIRKinectSkeletonJoint(x:Number=0,y:Number=0,z:Number=0,w:Number=0) {
			super(x, y, z, w)
		}

		public function getClone():AIRKinectSkeletonJoint {
			return new AIRKinectSkeletonJoint(x, y, z, w);
		}
	}
}