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
	import modules.nebula.data.NebulaPlayerIdentifierType;


	public class NebulaScoresPlayersFilter implements INebulaScoresFilter
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		private var _emails:Array;
		/** @private */
		private var _facebookIDs:Array;
		/** @private */
		private var _ids:Array;
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		public function applyFilter(sendData:Object):void
		{
			// initializes an array.
			if (sendData['players[]'] == null) sendData['players[]'] = [];
			
			if (_emails)
				addIdentifiersToSendData(NebulaPlayerIdentifierType.EMAIL, _emails, sendData);
			if (_facebookIDs)
				addIdentifiersToSendData(NebulaPlayerIdentifierType.FACEBOOK, _facebookIDs, sendData);
			if (_ids)
				addIdentifiersToSendData(NebulaPlayerIdentifierType.ID, _ids, sendData);
		}
		
		
		public function emails(emails:Array):NebulaScoresPlayersFilter
		{
			_emails = emails;
			return this;
		}
		
		
		public function facebookIDs(ids:Array):NebulaScoresPlayersFilter
		{
			_facebookIDs = ids;
			return this;
		}
		
		
		public function ids(ids:Array):NebulaScoresPlayersFilter
		{
			_ids = ids;
			return this;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private function addIdentifiersToSendData(identifierType:String, ids:Array,
			sendData:Object):void
		{
			var len:uint = ids.length;
			for (var i:uint = 0; i < len; i++)
			{
				(sendData['players[]'] as Array).push(identifierType + ":" + ids[i]);
			}
		}
	}
}
