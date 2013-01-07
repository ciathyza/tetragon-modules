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
package modules.nebula.data.filters
{
	public class NebulaScoresDateFilter implements INebulaScoresFilter
	{
		//-----------------------------------------------------------------------------------------
		// Constants
		//-----------------------------------------------------------------------------------------
		
		public static const ALL_TIME:NebulaScoresDateFilter = new NebulaScoresDateFilter().to("now");
		public static const LAST_30_DAYS:NebulaScoresDateFilter = new NebulaScoresDateFilter().from("30 days ago").to("now");
		public static const LAST_7_DAYS:NebulaScoresDateFilter = new NebulaScoresDateFilter().from("7 days ago").to("now");
		public static const TODAY:NebulaScoresDateFilter = new NebulaScoresDateFilter().from("today");
		public static const YESTERDAY:NebulaScoresDateFilter = new NebulaScoresDateFilter().from("yesterday").to("today");
		
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		private var _fromDate:String;
		private var _toDate:String;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new NebulaScoresDateFilter instance.
		 */
		public function NebulaScoresDateFilter():void
		{
			_fromDate = "";
			_toDate = "";
		}
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		public function applyFilter(sendObject:Object):void
		{
			sendObject['dateFrom'] = _fromDate;
			sendObject['dateTo'] = _toDate;
		}


		public function from(date:String):NebulaScoresDateFilter
		{
			_fromDate = date;
			return this;
		}


		public function to(date:String):NebulaScoresDateFilter
		{
			_toDate = date;
			return this;
		}
	}
}
