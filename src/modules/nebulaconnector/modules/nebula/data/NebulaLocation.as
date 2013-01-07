/*
 *      _________  __      __
 *    _/        / / /____ / /________ ____ ____  ___
 *   _/        / / __/ -_) __/ __/ _ `/ _ `/ _ \/ _ \
 *  _/________/  \__/\__/\__/_/  \_,_/\_, /\___/_//_/
 *                                   /___/
 * 
 * Tetragon : Game Engine for multi-platform ActionScript projects.
 * http://www.tetragonengine.com/
 * Copyright (c) The respective Copyright Holder (see LICENSE).
 * 
 * Permission is hereby granted, to any person obtaining a copy of this software
 * and associated documentation files (the "Software") under the rules defined in
 * the license found at http://www.tetragonengine.com/license/ or the LICENSE
 * file included within this distribution.
 * 
 * The above copyright notice and this permission notice must be included in all
 * copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND. THE COPYRIGHT
 * HOLDER AND ITS LICENSORS DISCLAIM ALL WARRANTIES AND CONDITIONS, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO ANY IMPLIED WARRANTIES AND CONDITIONS OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT, AND ANY
 * WARRANTIES AND CONDITIONS ARISING OUT OF COURSE OF DEALING OR USAGE OF TRADE.
 * NO ADVICE OR INFORMATION, WHETHER ORAL OR WRITTEN, OBTAINED FROM THE COPYRIGHT
 * HOLDER OR ELSEWHERE WILL CREATE ANY WARRANTY OR CONDITION NOT EXPRESSLY STATED
 * IN THIS AGREEMENT.
 */
package modules.nebula.data
{
	import modules.nebula.utils.StringUtils;


	/**
	 *
	 * @author joe (joe@nothing.ch)
	 */
	public class NebulaLocation
	{
		/**
		 * Creates a new NebulaLocation object with the response data
		 * obtained from the server.
		 *
		 * @param response object containing the location information from the server.
		 *
		 * @return a new NebulaLocation that represents the data obtained from the server.
		 */
		public static function createFromResponse(response:Object):NebulaLocation
		{
			var tmp:NebulaLocation = new NebulaLocation();

			tmp.latitude = parseFloat(response['latitude']);
			tmp.longitude = parseFloat(response['longitude']);
			tmp.altitude = parseFloat(response['altitude']);

			return tmp;
		}


		/** The altitude in degrees. */
		public var altitude:Number;
		/** The latitude in degrees. */
		public var latitude:Number;
		/** The lontitude in degrees. */
		public var longitude:Number;


		public function toString():String
		{
			return StringUtils.format("[NebulaLocation latitude={0} longitude={1} altitude={2}]", latitude, longitude, altitude);
		}
	}
}
