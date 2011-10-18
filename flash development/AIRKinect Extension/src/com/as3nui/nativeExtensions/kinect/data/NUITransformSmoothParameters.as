/**
 *
 * User: rgerbasi
 * Date: 10/1/11
 * Time: 1:14 AM
 */
package com.as3nui.nativeExtensions.kinect.data {
	public class NUITransformSmoothParameters {
		private var _fCorrection:Number;
		private var _fSmoothing:Number;
		private var _fPrediction:Number;
		private var _fJitterRadius:Number;
		private var _fMaxDeviationRadius:Number;

		public function NUITransformSmoothParameters(fCorrection:Number = .5, fSmoothing:Number =.5 , fPrediction:Number = .5, fJitterRadius:Number =.5, fMaxDeviationRadius:Number =.4) {
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