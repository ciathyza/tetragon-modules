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
package modules.geolocation
{
	import tetragon.core.signals.Signal;
	import tetragon.debug.Log;
	import tetragon.modules.IModule;
	import tetragon.modules.IModuleInfo;
	import tetragon.modules.Module;

	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	
	/**
	 * GeolocationManager class.
	 */
	public class GeolocationManager extends Module implements IModule
	{
		// -----------------------------------------------------------------------------------------
		// Properties
		// -----------------------------------------------------------------------------------------
		
		/** Last known Geolocation. */
		private var _lastKnownLocation:Geolocation;
		
		/** Service used to obtain the location. */
		private var _serviceURL:String;
		
		/** URLLoader used to request the location. */
		private var _urlLoader:URLLoader;
		
		
		// -----------------------------------------------------------------------------------------
		// Signals
		// -----------------------------------------------------------------------------------------
		
		/** @private */
		private var _updateSignal:Signal;
		/** @private */
		private var _errorSignal:Signal;
		
		
		// -----------------------------------------------------------------------------------------
		// Public Methods
		// -----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override public function init():void
		{
			_serviceURL = initParams["serviceURL"];
			setup();
		}
		
		
		/**
		 * Requests to the service the current Geolocation.
		 */
		public function loadLocation():void
		{
			if (_serviceURL == null)
			{
				Log.error("Can't load geolocation, no service URL was set!", this);
				return;
			}
			
			var request:URLRequest = new URLRequest(_serviceURL);
			_urlLoader.load(request);
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function dispose():void
		{
			super.dispose();
			if (!_urlLoader) return;
			_urlLoader.removeEventListener(Event.COMPLETE, onLoaderComplete);
			_urlLoader.removeEventListener(IOErrorEvent.IO_ERROR, onLoaderError);
		}
		
		
		// -----------------------------------------------------------------------------------------
		// Accessors
		// -----------------------------------------------------------------------------------------
		
		/**
		 * Default Module ID.
		 */
		public static function get defaultID():String
		{
			return "geolocationManager";
		}


		/**
		 * @inheritDoc
		 */
		override public function get moduleInfo():IModuleInfo
		{
			return new GeolocationManagerModuleInfo();
		}
		
		
		/**
		 * Service URL to fetch geolocation from.
		 */
		public function get serviceURL():String
		{
			return _serviceURL;
		}
		public function set serviceURL(v:String):void
		{
			_serviceURL = v;
		}
		
		
		public function get updateSignal():Signal
		{
			if (!_updateSignal) _updateSignal = new Signal();
			return _updateSignal;
		}
		
		
		public function get errorSignal():Signal
		{
			if (!_errorSignal) _errorSignal = new Signal();
			return _errorSignal;
		}
		
		
		// -----------------------------------------------------------------------------------------
		// Callback Handlers
		// -----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private function onLoaderComplete(e:Event):void
		{
			/* The data will be pushed into an array and proccessed. */
			try
			{
				var arrayData:Array = processData(e.target["data"]);
				_lastKnownLocation = new Geolocation(arrayData[5], arrayData[6]);
			}
			catch (err:Error)
			{
				Log.error("Could not process the received geolocation data (Error was: "
					+ err.message + ").", this);
				if (_errorSignal) _errorSignal.dispatch(err.message);
			}
			
			if (_updateSignal) _updateSignal.dispatch(_lastKnownLocation);
		}
		
		
		/**
		 * @private
		 */
		private function onLoaderError(e:IOErrorEvent):void
		{
			if (_errorSignal) _errorSignal.dispatch(e.text);
		}
		
		
		// -----------------------------------------------------------------------------------------
		// Private Methods
		// -----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private function setup():void
		{
			_urlLoader = new URLLoader();
			_urlLoader.addEventListener(Event.COMPLETE, onLoaderComplete);
			_urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onLoaderError);
		}
		
		
		/**
		 * Parses the data obtained from the service. The original source contains the
		 * following fields: [countryCode, countryName, city, region, regionName,
		 * latitude, longitude, postalcode]
		 * 
		 * @private
		 *
		 * @param xml String containing an XML to parse.
		 * @return Array
		 */
		private function processData(xml:String):Array
		{
			var patternQuote:RegExp = /'(.*)'/g;
			var str:String = xml.toString();
			var array:Array = str.match(patternQuote);
			
			for (var i:uint = 0; i < array.length; i++)
			{
				var pattern:RegExp = /'/g;
				var string:String = array[i];
				array[i] = string.replace(pattern, "");
			}
			return array;
		}
	}
}
