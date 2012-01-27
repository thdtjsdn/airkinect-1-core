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
	 * Smoothing Parameters for Skeleton Frames
	 */
	public class AIRKinectTransformSmoothParameters {
		private var _fCorrection:Number;
		private var _fSmoothing:Number;
		private var _fPrediction:Number;
		private var _fJitterRadius:Number;
		private var _fMaxDeviationRadius:Number;

		public function AIRKinectTransformSmoothParameters(fCorrection:Number = .5, fSmoothing:Number =.5 , fPrediction:Number = .5, fJitterRadius:Number =.5, fMaxDeviationRadius:Number =.4) {
			_fCorrection					= fCorrection;
			_fSmoothing						= fSmoothing;
			_fPrediction					= fPrediction;
			_fJitterRadius					= fJitterRadius;
			_fMaxDeviationRadius			= fMaxDeviationRadius;
		}

		public function get fCorrection():Number {
			return _fCorrection;
		}

		public function get fSmoothing():Number {
			return _fSmoothing;
		}

		public function get fPrediction():Number {
			return _fPrediction;
		}

		public function get fJitterRadius():Number {
			return _fJitterRadius;
		}

		public function get fMaxDeviationRadius():Number {
			return _fMaxDeviationRadius;
		}
	}
}