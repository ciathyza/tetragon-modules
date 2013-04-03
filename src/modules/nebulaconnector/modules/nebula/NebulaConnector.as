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
package modules.nebula
{
	import modules.nebula.data.*;
	import modules.nebula.data.filters.*;
	import modules.nebula.net.*;
	import modules.nebula.utils.*;

	import tetragon.debug.Log;
	import tetragon.modules.IModule;
	import tetragon.modules.IModuleInfo;
	import tetragon.modules.Module;

	import com.hexagonstar.net.HTTPStatusCodes;
	import com.hexagonstar.signals.Signal;
	import com.hexagonstar.util.reflection.dumpObj;
	import com.hurlant.crypto.hash.HMAC;
	import com.hurlant.crypto.hash.SHA1;
	import com.hurlant.util.Hex;

	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.system.Security;
	import flash.utils.ByteArray;
	import flash.utils.Timer;


	/**
	 * A connector module used for communication between Tetragon and Nebula.
	 *
	 * @author hexagon (hexagon@nothing.ch)
	 * @author joe (joe@nothing.ch)
	 */
	public class NebulaConnector extends Module implements IModule
	{
		//-----------------------------------------------------------------------------------------
		// Constants
		//-----------------------------------------------------------------------------------------
		
		/** Percentage of the lifetime, that the connector will wait, to send a keep alive request. */
		public static const LIFETIME_WAIT_PERCENTAGE:Number = 0.75;
		/** Identifier of the createCheckpoint method. */
		public static const METHOD_CREATE_CHECKPOINT:String = "CREATE_CHECKPOINT";
		/** Identifier of the endGame method. */
		public static const METHOD_END_GAME:String = "END_GAME";
		/** Identifier of the endLevel method. */
		public static const METHOD_END_LEVEL:String = "END_LEVEL";
		/** Identifier of the endSession method. */
		public static const METHOD_END_SESSION:String = "END_SESSION";
		/** Identifier of the getPlayer and getPlayers methods. */
		public static const METHOD_GET_PLAYER:String = "GET_PLAYER";
		/** Identifier of the getScores method. */
		public static const METHOD_GET_SCORES:String = "GET_SCORES";
		/** Identifier of the keepalive method. */
		public static const METHOD_KEEPALIVE_SESSION:String = "KEEPALIVE_SESSION";
		/** Identifier of the log method. */
		public static const METHOD_LOG:String = "LOG";
		/** Identifier of the setLocation method. */
		public static const METHOD_SET_LOCATION:String = "SET_LOCATION";
		/** Identifier of the setPlayer method. */
		public static const METHOD_SET_PLAYER:String = "SET_PLAYER";
		/** Identifier of the setRecommendation method. */
		public static const METHOD_SEND_EMAIL_RECOMMENDATION:String = "SEND_EMAIL_RECOMMENDATION";
		
		/** Identifier of the startGame method. */
		public static const METHOD_START_GAME:String = "START_GAME";
		/** Identifier of the startLevel method. */
		public static const METHOD_START_LEVEL:String = "START_LEVEL";
		/** Identifier of the startSession method. */
		public static const METHOD_START_SESSION:String = "START_SESSION";
		/** Identifier of the publishGame method. */
		public static const METHOD_SUBMIT_SCORE:String = "SUBMIT_SCORE";
		/** Identifier of the updateLevel method. */
		public static const METHOD_UPDATE_LEVEL:String = "UPDATE_LEVEL";
		
		/** @private */
		private static const API_GAMES_ID:String = "/games/{0}"; // PUT
		/** @private */
		private static const API_GAMES_ID_LEVELS:String = "/games/{0}/levels"; // POST
		/** @private */
		private static const API_LEVELS_ID:String = "/levels/{0}"; // PUT
		/** @private */
		private static const API_LEVELS_ID_CHECKPOINTS:String = "/levels/{0}/checkpoints"; // POST
		/** @private */
		private static const API_LOGS:String = "/logs"; // POST
		/** @private */
		private static const API_PLAYERS:String = "/players"; // GET
		
		/** @private */
		private static const API_PLAYERS_ID:String = "/players/{0}"; // GET
		/** @private */
		private static const API_SCORES:String = "/scores/{0}"; // GET, POST
		/** @private */
		private static const API_SESSIONS:String = "/sessions"; // POST
		/** @private */
		private static const API_SESSIONS_ME:String = "/sessions/me"; // PUT
		/** @private */
		private static const API_SESSIONS_ME_GAMES:String = "/sessions/me/games"; // POST
		/** @private */
		private static const API_SESSIONS_ME_LOCATION:String = "/sessions/me/location"; // PUT
		/** @private */
		private static const API_SESSIONS_ME_PLAYER:String = "/sessions/me/player"; // PUT
		// private static const API_STATUS:String = "/status"; // GET
		/** @private */
		private static const API_URL_RECOMMEND:String = "/recommend/email"; // POST
		
		
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/**
		 * URL where the service is located, without the application id.
		 * (e.g. http://nebula.nothing.ch/api/foo/ for the foo app).
		 * @private
		 */
		private var _apiURL:String;
		
		/**
		 * Application identifier that is used to connect to the service.
		 * @private
		 */
		private var _appID:String;
		
		/**
		 * Active request done by the connector. Can be null.
		 * @private
		 */
		private var _currentRequest:NebulaRequest;
		
		/**
		 * Data format in which the response is expected.
		 * @private
		 */
		private var _dataFormat:String;
		
		/**
		 * Identifier of the current game, obtained from the server.
		 * @private
		 */
		private var _gameID:int;
		
		/**
		 * Helper class used to sign each request.
		 * @private
		 */
		private var _hmacHash:HMAC;
		
		/**
		 * Current HTTPStatus of the URLLoader. It is used to track errors.
		 * @private
		 */
		private var _httpStatus:String;
		
		/**
		 * Stores the identifier of the last game.
		 * @private
		 */
		private var _lastGameID:int;
		
		/**
		 * Identifier of the last active level.
		 * @private
		 */
		private var _lastLevelID:int;
		
		/**
		 * Identifier of the currently active level.
		 * @private
		 */
		private var _levelID:int;
		
		/**
		 * List with pending requests. Once a request is processed the next request in the
		 * list is executed.
		 * @private
		 */
		private var _pendingRequests:Vector.<NebulaRequest>;
		
		/**
		 * Parser used to process the raw response from Nebula.
		 * @private
		 */
		private var _responseParser:IResponseParser;
		
		/**
		 * Secret key used to sigh the API calls. It is used to sign the requests.
		 * @private
		 */
		private var _secretKey:String;
		
		/**
		 * Current loaded session.
		 * @private
		 */
		private var _session:NebulaSession;
		
		/**
		 * Timer used to renew the session lifetime.
		 * @private
		 */
		private var _sessionLifetimeTimer:Timer;
		
		/**
		 * URLLoader used to perform each request to the Nebula service.
		 * @private
		 */
		private var _urlLoader:URLLoader;
		
		/**
		 * @private
		 */
		private var _debug:Boolean = true;
		
		
		//-----------------------------------------------------------------------------------------
		// Signals
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Signal called when createCheckpoint returns successfully.
		 * @private
		 */
		private var _checkpointCreatedSignal:Signal;
		
		/**
		 * Signal used to handle errors in the connector. The expected signature is
		 * function(error:NebulaError):void {}
		 * 
		 * @private
		 */
		private var _errorSignal:Signal;
		
		/**
		 * Signal called when endGame returns successfully.
		 * @private
		 */
		private var _gameEndedSignal:Signal;
		
		/**
		 * Signal called when startGame returns successfully.
		 * @private
		 */
		private var _gameStartedSignal:Signal;
		
		/**
		 * Signal called when endLevel returns successfully.
		 * @private
		 */
		private var _levelEndedSignal:Signal;
		
		/**
		 * Signal called when startLevel returns successfully.
		 * @private
		 */
		private var _levelStartedSignal:Signal;
		
		/**
		 * Signal called when updateLevel returns successfully.
		 * @private
		 */
		private var _levelUpdatedSignal:Signal;
		
		/**
		 * Signal called when setLocation returns successfully.
		 * @private
		 */
		private var _locationSetSignal:Signal;
		
		/**
		 * Signal called when log returns successfully.
		 * @private
		 */
		private var _nebulaLogSignal:Signal;
		
		/**
		 * Signal called when setPlayer returns successfully.
		 * @private
		 */
		private var _playerSetSignal:Signal;
		
		/**
		 * Signal called when sendRecommendations returns successfully.
		 * @private
		 */
		private var _emailRecommendationSetSignal:Signal;
		
		/**
		 * Signal called when getPlayer or getPlayers return successfully.
		 * @private
		 */
		private var _playersSignal:Signal;
		
		/**
		 * Signal called when submitScore returns successfully.
		 * @private
		 */
		private var _scoreSubmittedSignal:Signal;
		
		/**
		 * Signal called when getScore or getScoreForGame return successfully.
		 * @private
		 */
		private var _scoresSignal:Signal;
		
		/**
		 * Signal called when endSession returns successfully.
		 * @private
		 */
		private var _sessionEndedSignal:Signal;
		
		/**
		 * Signal called when startSession returns successfully.
		 * @private
		 */
		private var _sessionStartedSignal:Signal;
		

		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override public function init():void
		{
			/* Loads the configuration from the initParams. */
			_apiURL = initParams['apiURL'];
			_appID = initParams['appId'] || initParams['appID'];
			_secretKey = initParams['secretKey'];
			_dataFormat = initParams['dataFormat'];
			
			if (initParams['debug'] != null) _debug = initParams['debug'] as Boolean;
			
			/* Fallback params. */
			if (!_apiURL) _apiURL = NebulaDefaults.API_URL_DEV;
			if (!_appID) _appID = NebulaDefaults.DEFAULT_APP_ID;
			if (!_secretKey) _secretKey = NebulaDefaults.DEFAULT_APP_SECRET_KEY;
			if (!_dataFormat) _dataFormat = NebulaResponseDataFormat.JSON;
			
			if (_dataFormat == NebulaResponseDataFormat.JSON)
				_responseParser = new JSONResponseParser();
			else if (_dataFormat == NebulaResponseDataFormat.XML)
				_responseParser = new XMLResponseParser();
			
			/* indicates flash where the application specific cross domain file will be found.
			* This command does not load the file itself, it just tells flash where it could
			* be found when a request needs to be done. */
			Security.loadPolicyFile(_apiURL + _appID + "/crossdomain.xml");
			
			/* Initializes the internal variables of the connector. */
			setup();
			
			if (_debug)
			{
				log("Initialized with apiURL: " + _apiURL + ", appID: " + _appID + ", secretKey: "
					+ mask(_secretKey) + ", dataFormat: " + _dataFormat);
			}
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function dispose():void
		{
			super.dispose();
			if (!_sessionLifetimeTimer) return;
			_sessionLifetimeTimer.stop();
			_sessionLifetimeTimer.removeEventListener(TimerEvent.TIMER, onSessionLifetimeTimer);
			_sessionLifetimeTimer = null;
		}
		
		
		/**
		 * Creates a checkpoint in the current level. The score stored with the checkpoint
		 * is also updated to the current level.
		 *
		 * @param identifier identifier used for grouping/sorting of the checkpoint.
		 * @param score store to store with the checkpoint.
		 * @param name name used for display purposes in the admin part.
		 */
		public function createCheckpoint(identifier:String, score:int, name:String = null):void
		{
			// TODO Determine what to do with the response.
			var onSuccess:Function = function(r:NebulaRequest):void
			{
				if (_checkpointCreatedSignal) _checkpointCreatedSignal.dispatch();
			};
			var onError:Function = function(r:NebulaRequest):void
			{
				callbackFail("Failed to create a checkpoint.", METHOD_CREATE_CHECKPOINT, r);
			};
			var sendData:Object =
				{
					name: name ? name : "",
						identifier: identifier ? identifier : "",
						score: score
				};
			var url:String = StringUtils.format(API_LEVELS_ID_CHECKPOINTS, _levelID);
			
			/* Queue a signed request. */
			queueSignedRequest(new NebulaRequest(NebulaRequestMethod.POST, url, sendData,
				onSuccess, onError));
		}
		
		
		/**
		 * Ends the current game. If completed is set to true the status
		 * of the game will be completed, otherwise failed. Any active levels
		 * will be marked with the same status of the game.
		 *
		 * @param completed whether the game was completed or failed.
		 */
		public function endGame(completed:Boolean = false):void
		{
			// TODO determine what to do with the response.
			var onSuccess:Function = function(r:NebulaRequest):void
			{
				if (_debug) log("Ended Nebula game.");
				if (_gameEndedSignal) _gameEndedSignal.dispatch();
			};
			var onError:Function = function(r:NebulaRequest):void
			{
				callbackFail("Failed to end Nebula game", METHOD_END_GAME, r);
			};
			
			var sendData:Object = {status:completed ? NebulaGameStatus.COMPLETED : NebulaGameStatus.FAILED};
			var url:String = StringUtils.format(API_GAMES_ID, _gameID);
			
			// queues a signed request.
			queueSignedRequest(new NebulaRequest(NebulaRequestMethod.PUT, url, sendData, onSuccess, onError));
		}
		
		
		/**
		 * Ends the currently active level with the given score. If completed
		 * was set to true the status of the level is set as completed, otherwise
		 * as failed.
		 *
		 * @param score score obtained at the end of the level.
		 * @param completed whether the level was completed succesfully.
		 *
		 */
		public function endLevel(score:int, completed:Boolean = false):void
		{
			if (_debug) log("Ending Nebula level with score: " + score);
			
			// TODO: determine what to do with the response.
			var onSuccess:Function = function(r:NebulaRequest):void
			{
				if (_debug) log("Ended Nebula level.");
				_levelID = -1;
				if (_levelEndedSignal) _levelEndedSignal.dispatch();
			};
			var onError:Function = function(r:NebulaRequest):void
			{
				callbackFail("Failed to end Nebula level", METHOD_END_LEVEL, r);
			};
			
			var sendData:Object = {score:score, status:completed ? NebulaLevelStatus.COMPLETED : NebulaLevelStatus.FAILED};
			var url:String = StringUtils.format(API_LEVELS_ID, _levelID);
			
			// queues a signed request.
			queueSignedRequest(new NebulaRequest(NebulaRequestMethod.PUT, url, sendData, onSuccess, onError));
		}
		
		
		/**
		 * Ends the current Nebula session. Any active games and levels will be ended and marked
		 * as failed.
		 */
		public function endSession():void
		{
			// TODO: determine what to do with the response.
			if (!_session)
			{
				// session is already closed.
				if (_sessionEndedSignal)
					_sessionEndedSignal.dispatch();
				return;
			}
			var onSuccess:Function = function(r:NebulaRequest):void
			{
				if (_debug)
				{
					log("Ended Nebula session with ID \"" + _session.id.toString() + "\".");
				}
				_session = null;
				_gameID = -1;
				_levelID = -1;
				
				// cleans the lifetime timer.
				if (_sessionLifetimeTimer != null)
				{
					_sessionLifetimeTimer.stop();
					_sessionLifetimeTimer.removeEventListener(TimerEvent.TIMER, onSessionLifetimeTimer);
				}
				
				_sessionLifetimeTimer = null;
				
				if (_sessionEndedSignal)
					_sessionEndedSignal.dispatch();
			};
			var onError:Function = function(r:NebulaRequest):void
			{
				callbackFail("Failed to end Nebula session", METHOD_END_SESSION, r);
			};
			
			var sendData:Object = {status:NebulaSessionStatus.ENDED};
			
			// queues a signed request
			queueSignedRequest(new NebulaRequest(NebulaRequestMethod.PUT, API_SESSIONS_ME, sendData, onSuccess, onError));
		}
		
		
		/**
		 * @param leaderboardID
		 * @param gameID
		 * @param limit
		 * @param offset
		 * @param filters
		 */
		public function getGameScores(leaderboardID:String, gameID:String = null, limit:uint = 100,
									  offset:uint = 0, ... filters):void
		{
			getScores.apply(this, [leaderboardID, gameID, null, limit, offset].concat(filters));
		}
		
		
		/**
		 * @param leaderboardID
		 * @param gameID
		 * @param levelID
		 * @param limit
		 * @param offset
		 * @param filters
		 */
		public function getLevelScores(leaderboardID:String, gameID:String = null,
									   levelID:String = null, limit:uint = 100, offset:uint = 0, ... filters):void
		{
			getScores.apply(this, [leaderboardID, gameID, levelID, limit, offset].concat(filters));
		}
		
		
		/**
		 * Gets the player with the given id. If the player does not exist
		 * an error will be produced.
		 *
		 * @param id id of the desired player.
		 */
		public function getPlayer(id:int):void
		{
			// TODO: return proper player object.
			var onSuccess:Function = function(r:NebulaRequest):void
			{
				if (_debug) log("Loaded player from Nebula");
				
				if (_playersSignal)
				{
					// extracts the single player from the response.
					var playerObject:NebulaPlayer = NebulaPlayer.createFromResponse(r.responseData['player']);
					
					_playersSignal.dispatch(Vector.<NebulaPlayer>([playerObject]));
				}
			};
			var onError:Function = function(r:NebulaRequest):void
			{
				callbackFail("Failed to load the Player .", METHOD_GET_PLAYER, r);
			};
			
			var sendData:Object = {};
			var url:String = StringUtils.format(API_PLAYERS_ID, id);
			
			// queues the request
			queueRequest(new NebulaRequest(NebulaRequestMethod.GET, url, sendData, onSuccess, onError));
		}
		
		
		/**
		 * Gets an array of players that share the given identifier. Possible identifierType values
		 * are NebulaPlayerIdentifierType.EMAL and NebulaPlayerIdentifierType.FACEBOOK, any other
		 * identifierType value will produce an error.
		 *
		 * The identifierType NebulaPlayerIdentifierType.ID is not supported.
		 *
		 * @param identifierType type of identifier used to filter. Possible values are
		 *         NebulaPlayerIdentifierType.EMAIL and NebulaPlayerIdentifierType.FACEBOOK.
		 * @param value value to search for of the given identifier type.
		 */
		public function getPlayers(identifierType:String, value:String):void
		{
			// TODO: test this method.
			var onSuccess:Function = function(r:NebulaRequest):void
			{
				if (_debug) log("Loaded player from Nebula.");
				if (_playersSignal)
				{
					var responseArray:Array = r.responseData['players'];
					var responseArrayCount:uint = responseArray.length;
					
					var players:Vector.<NebulaPlayer> = new Vector.<NebulaPlayer>(responseArray.length, true);
					
					// creates a NebulaPlayer from each object in the response
					for (var x:uint = 0; x < responseArrayCount; x++)
					{
						players[x] = NebulaPlayer.createFromResponse(responseArray[x]);
					}
					
					_playersSignal.dispatch(players);
				}
			};
			var onError:Function = function(r:NebulaRequest):void
			{
				callbackFail("Failed to load the Player .", METHOD_GET_PLAYER, r);
			};
			
			// identifierType is taken as the parameter name.
			var sendData:Object = {};
			sendData[identifierType] = value;
			
			// queues the request
			queueRequest(new NebulaRequest(NebulaRequestMethod.GET, API_PLAYERS, sendData, onSuccess, onError));
		}
		
		
		/**
		 * A very simple command that logs the given message and log id to the database.
		 *
		 * @param id
		 * @param message
		 */
		public function nebulaLog(id:String, message:String = null, details:Object = null):void
		{
			var onSuccess:Function = function(r:NebulaRequest):void
			{
				if (_nebulaLogSignal)
					_nebulaLogSignal.dispatch();
			};
			var onError:Function = function(r:NebulaRequest):void
			{
				callbackFail("Failed to log message", METHOD_LOG, r);
			};
			
			// random data is send since something needs to be signed.
			var sendData:Object = {id:id};
			
			// data is not included if invalid.
			if (message != null)
				sendData['message'] = message;
			
			// value is added differently if it's a real object than if it is a String, Boolean or Number.
			if (details != null)
			{
				if (details is String || details is Number || details is Boolean)
					sendData['details'] = details;
				else
					ObjectUtils.flattenInto("details", details, sendData);
			}
			
			// queues the request.
			queueSignedRequest(new NebulaRequest(NebulaRequestMethod.POST, API_LOGS, sendData, onSuccess, onError));
		}
		
		
		/**
		 * Sets the current location.
		 *
		 * @param latitude A float representing the latitude.
		 * @param longitude A float representing the longitude.
		 * @param altitude A float representing the altitude, can be 0 if not available.
		 */
		public function setLocation(latitude:Number, longitude:Number, altitude:Number = 0):void
		{
			var onSuccess:Function = function(r:NebulaRequest):void
			{
				if (_debug) log("Nebula location set.");
				if (_locationSetSignal) _locationSetSignal.dispatch();
			};
			
			var onError:Function = function(r:NebulaRequest):void
			{
				callbackFail("Failed to set Nebula location", METHOD_SET_LOCATION, r, true);
			};
			
			var sendData:Object = {latitude:latitude, longitude:longitude, altitude:altitude};
			
			// queues the request.
			queueSignedRequest(new NebulaRequest(NebulaRequestMethod.PUT, API_SESSIONS_ME_LOCATION, sendData, onSuccess, onError));
		}
		
		
		/**
		 * Sets the current player information. The details object can only contain native object
		 * types, meaning Number, Boolean, String, Object and Array. Custom classes will be ignored.
		 *
		 * @param player player information to send to the server.
		 */
		public function setPlayer(player:NebulaPlayer):void
		{
			// TODO Determine what to do with the returned data.
			
			/* Success callback handler. */
			var onSuccess:Function = function(r:NebulaRequest):void
			{
				if (_debug) log("Nebula player set.");
				
				var tmpPlayer:NebulaPlayer = NebulaPlayer.createFromResponse( r.responseData['session']['player'] );
				if (_playerSetSignal) _playerSetSignal.dispatch( tmpPlayer );
				
			};
			
			/* Error callback handler. */
			var onError:Function = function(r:NebulaRequest):void
			{
				callbackFail("Failed to set Nebula player.", METHOD_SET_PLAYER, r);
			};
			
			/* Player object prepares the data that will be sent. */
			var sendData:Object = player.prepareData();
			
			/* Queues a signed request. */
			queueSignedRequest(new NebulaRequest(NebulaRequestMethod.PUT, API_SESSIONS_ME_PLAYER,
				sendData, onSuccess, onError));
		}
		
		/**
		 * Sets the current recommend information. The details object can only contain native object
		 * types, meaning Number, Boolean, String, Object and Array. Custom classes will be ignored.
		 *
		 * @param name and eMail information to send to the server.
		 */
		public function sendEmailRecommendation( emailrecommendation:NebulaEmailRecommendation ):void
		{			
			/* Success callback handler. */
			var onSuccess:Function = function(r:NebulaRequest):void
			{
				if (_debug) log("Nebula e-mail recommendation sent.");				

				if (_emailRecommendationSetSignal) _emailRecommendationSetSignal.dispatch();
			};
			
			/* Error callback handler. */
			var onError:Function = function(r:NebulaRequest):void
			{
				callbackFail("Failed to send e-mail recommendation.", METHOD_SEND_EMAIL_RECOMMENDATION, r);
			};
			
			/*The data that will be sent. */
			var sendData:Object = emailrecommendation.prepareData();
			
			/* Queues a signed request. */
			queueSignedRequest(new NebulaRequest(NebulaRequestMethod.POST, API_URL_RECOMMEND,
				sendData, onSuccess, onError));
		}		
		
		
		/**
		 * Signals Nebula that a game has started.
		 *
		 * @param levelId The current level identifier (can be anything, but all level
		 *        identifiers should be alphanumerically sortable in the order of the game).
		 */
		public function startGame(identifier:String, name:String = null):void
		{
			var onSuccess:Function = function(r:NebulaRequest):void
			{
				_gameID = parseInt(r.responseData['game']['id']);
				_lastGameID = _gameID;
				
				// since a new game is created all the stored level information should be destroyed.
				_levelID = -1;
				// TODO: should this id be reset?
				_lastLevelID = -1;
				
				log("Started Nebula game with id \"" + _gameID.toString() + "\".");
				
				if (_gameStartedSignal)
					_gameStartedSignal.dispatch(_gameID);
			};
			var onError:Function = function(r:NebulaRequest):void
			{
				callbackFail("Failed to start Nebula game", METHOD_START_GAME, r);
			};
			
			var sendData:Object = {name:name ? name : "", identifier:identifier ? identifier : ""};
			
			// queues a signed request.
			queueSignedRequest(new NebulaRequest(NebulaRequestMethod.POST, API_SESSIONS_ME_GAMES, sendData, onSuccess, onError));
		}
		
		
		/**
		 *
		 * @param identifier
		 * @param name
		 */
		public function startLevel(identifier:String, name:String = null):void
		{
			var onSuccess:Function = function(r:NebulaRequest):void
			{
				_levelID = parseInt(r.responseData['level']['id']);
				_lastLevelID = _levelID;
				
				if (_debug) log("Started Nebula level with ID \"" + _levelID + "\".");
				if (_levelStartedSignal) _levelStartedSignal.dispatch(_levelID);
			};
			var onError:Function = function(r:NebulaRequest):void
			{
				callbackFail("Failed to start Nebula level", METHOD_START_LEVEL, r);
			};
			
			var sendData:Object = {name:name ? name : "", identifier:identifier ? identifier : ""};
			var url:String = StringUtils.format(API_GAMES_ID_LEVELS, _gameID);
			
			// queues a signed request.
			queueSignedRequest(new NebulaRequest(NebulaRequestMethod.POST, url, sendData, onSuccess, onError));
		}
		
		
		/**
		 * Starts a Nebula session.
		 */
		public function startSession():void
		{
			if (_session)
			{
				fail("A session is already started, call endSession() first.", null);
				return;
			}
			
			/* Success handler. */
			var onSuccess:Function = function(r:NebulaRequest):void
			{
				/* Creates a new session from the values returned by the server. */
				_session = new NebulaSession(parseInt(r.responseData['id']),
					r.responseData['sessionKey'], r.responseData['authToken'],
					parseInt(r.responseData['startNonce']), parseInt(r.responseData['lifetime']));
				
				/* if there is a valid lifetime, a timer is started that is triggered
				* after LIFETIME_WAIT_PERCENTAGE of the lifetime. */
				if (_session.lifetime != 0)
				{
					_sessionLifetimeTimer = new Timer(_session.lifetime * 1000 * LIFETIME_WAIT_PERCENTAGE);
					_sessionLifetimeTimer.addEventListener(TimerEvent.TIMER, onSessionLifetimeTimer);
					_sessionLifetimeTimer.start();
				}
				
				if (_debug) log("Started Nebula session with ID \"" + _session.id.toString() + "\".");
				if (_sessionStartedSignal) _sessionStartedSignal.dispatch();
			};
			
			/* Error handler. */
			var onError:Function = function(r:NebulaRequest):void
			{
				callbackFail("Failed to start Nebula session.", METHOD_START_SESSION, r);
			};
			
			/* random data is send since something needs to be signed. */
			var sendData:Object = {init: 1};
			
			/* queues a signed request. */
			queueSignedRequest(new NebulaRequest(NebulaRequestMethod.POST, API_SESSIONS, sendData,
				onSuccess, onError));
		}
		
		
		public function submitGameScore(leaderboard:String):void
		{
			submitScore(leaderboard, "gameId", _lastGameID);
		}
		
		
		public function submitLevelScore(leaderboard:String):void
		{
			submitScore(leaderboard, "levelId", _lastLevelID);
		}
		
		
		/**
		 * Updates the current game information for Nebula.
		 *
		 * This should be called at least every 10-15 minutes if a player is idle or stuck for
		 * long on one level, to keep the session active.
		 *
		 * @param levelId The current level identifier (can be anything, but all level
		 *        identifiers should be alphanumerically sortable in the order of the game)
		 * @param score The current score.
		 */
		public function updateLevel(score:int):void
		{
			if (_debug) log("Updating Nebula level with score: " + score);
			
			// TODO: store internally level id or it should be provided by the user?
			var onSuccess:Function = function(r:NebulaRequest):void
			{
				if (_debug) log("Updated Nebula level.");
				if (_levelUpdatedSignal) _levelUpdatedSignal.dispatch();
			};
			var onError:Function = function(r:NebulaRequest):void
			{
				callbackFail("Failed to update Nebula level", METHOD_UPDATE_LEVEL, r);
			};
			
			var sendData:Object = {score:score, status:NebulaLevelStatus.RUNNING};
			var url:String = StringUtils.format(API_LEVELS_ID, _levelID);
			
			// queues the request.
			queueSignedRequest(new NebulaRequest(NebulaRequestMethod.PUT, url, sendData, onSuccess, onError));
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Signal Accessors
		//-----------------------------------------------------------------------------------------
		
		public function get checkpointCreatedSignal():Signal
		{
			if (!_checkpointCreatedSignal) _checkpointCreatedSignal = new Signal();
			return _checkpointCreatedSignal;
		}
		
		
		public function get errorSignal():Signal
		{
			if (!_errorSignal) _errorSignal = new Signal();
			return _errorSignal;
		}
		
		
		public function get gameEndedSignal():Signal
		{
			if (!_gameEndedSignal) _gameEndedSignal = new Signal();
			return _gameEndedSignal;
		}
		
		
		public function get gameStartedSignal():Signal
		{
			if (!_gameStartedSignal) _gameStartedSignal = new Signal();
			return _gameStartedSignal;
		}
		
		
		public function get levelEndedSignal():Signal
		{
			if (!_levelEndedSignal) _levelEndedSignal = new Signal();
			return _levelEndedSignal;
		}
		
		
		public function get levelStartedSignal():Signal
		{
			if (!_levelStartedSignal) _levelStartedSignal = new Signal();
			return _levelStartedSignal;
		}
		
		
		public function get levelUpdatedSignal():Signal
		{
			if (!_levelUpdatedSignal) _levelUpdatedSignal = new Signal();
			return _levelUpdatedSignal;
		}
		
		
		public function get locationSetSignal():Signal
		{
			if (!_locationSetSignal) _locationSetSignal = new Signal();
			return _locationSetSignal;
		}
		
		
		public function get nebulaLogSignal():Signal
		{
			if (!_nebulaLogSignal) _nebulaLogSignal = new Signal();
			return _nebulaLogSignal;
		}
		
		
		public function get playerSetSignal():Signal
		{
			if (!_playerSetSignal) _playerSetSignal = new Signal();
			return _playerSetSignal;
		}
		
		public function get recommendationSetSignal():Signal
		{
			if(!_emailRecommendationSetSignal) _emailRecommendationSetSignal = new Signal();
			return _emailRecommendationSetSignal;
		}
		
		
		public function get playersSignal():Signal
		{
			if (!_playersSignal) _playersSignal = new Signal();
			return _playersSignal;
		}
		
		
		/**
		 * Dispatches a NebulaHighscores object.
		 */
		public function get scoresSignal():Signal
		{
			if (!_scoresSignal) _scoresSignal = new Signal();
			return _scoresSignal;
		}
		
		
		public function get scoreSubmittedSignal():Signal
		{
			if (!_scoreSubmittedSignal) _scoreSubmittedSignal = new Signal();
			return _scoreSubmittedSignal;
		}
		
		
		public function get sessionStartedSignal():Signal
		{
			if (!_sessionStartedSignal) _sessionStartedSignal = new Signal();
			return _sessionStartedSignal;
		}
		
		
		public function get sessionEndedSignal():Signal
		{
			if (!_sessionEndedSignal) _sessionEndedSignal = new Signal();
			return _sessionEndedSignal;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		public static function get defaultID():String
		{
			return "nebulaConnector";
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function get moduleInfo():IModuleInfo
		{
			return new NebulaConnectorModuleInfo();
		}
		
		
		public function get gameID():int
		{
			return _gameID;
		}
		
		
		public function get lastGameID():int
		{
			return _lastGameID;
		}
		
		
		public function get appID():String
		{
			return _appID;
		}
		
		
		public function get levelID():int
		{
			return _levelID;
		}
		
		
		public function get lastLevelID():int
		{
			return _lastLevelID;
		}
		
		
		public function get hasActiveSession():Boolean
		{
			return _session != null;
		}
		
		
		/**
		 * If set to true the connector will send more verbose logging data to the console.
		 * Set this property to false on release builds!
		 * 
		 * @default true
		 */
		public function get debug():Boolean
		{
			return _debug;
		}
		public function set debug(v:Boolean):void
		{
			_debug = v;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Callback Handlers
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private function onSessionLifetimeTimer(e:TimerEvent):void
		{
			// stops the timer
			_sessionLifetimeTimer.stop();
			// sends to the server the keepalive request.
			keepAliveSession();
		}
		
		
		/**
		 * @private
		 */
		private function onURLLoaderComplete(e:Event):void
		{
			processResponse(e);
		}
		
		
		/**
		 * @private
		 */
		private function onURLLoaderHTTPStatus(e:HTTPStatusEvent):void
		{
			_httpStatus = e.status + " " + HTTPStatusCodes.getStatusCode(e.status) + "";
		}
		
		
		/**
		 * @private
		 */
		private function onURLLoaderIOError(e:IOErrorEvent):void
		{
			processResponse(e);
		}
		
		
		/**
		 * @private
		 */
		private function onURLLoaderSecurityError(e:SecurityErrorEvent):void
		{
			processResponse(e);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		protected function keepAliveSession():void
		{
			// valid session needs to exist.
			if (!_session)
				return;
			
			var onSuccess:Function = function(r:NebulaRequest):void
			{
				_sessionLifetimeTimer.start();
				if (_debug) log("keepalive returned successfully.");
			};
			var onError:Function = function(r:NebulaRequest):void
			{
				callbackFail("Failed to extend the lifetime of the session", METHOD_KEEPALIVE_SESSION, r);
			};
			
			var sendData:Object = {status:NebulaSessionStatus.RUNNING};
			
			// queues a signed request
			queueSignedRequest(new NebulaRequest(NebulaRequestMethod.PUT, API_SESSIONS_ME, sendData, onSuccess, onError));
		}
		
		
		/**
		 * Automatically handles the pending requests. If a request is found in the
		 * list it is processed.
		 * 
		 * @private
		 */
		private function dequeuePendingRequest():void
		{
			if (_pendingRequests.length != 0 && _currentRequest == null)
			{
				// sets the active request.
				_currentRequest = _pendingRequests.shift();
				_httpStatus = null;
				
				// adds the variables to send to the request.
				var requestVariables:URLVariables = new URLVariables();
				for (var k:String in _currentRequest.sendData)
				{
					requestVariables[k] = _currentRequest.sendData[k];
				}
				
				// prepares the url request. // {_apiURL}/{_appId}{/urlPath}.{format}
				var urlRequest:URLRequest = new URLRequest(_apiURL + _appID + _currentRequest.urlPath + "." + _dataFormat);
				
				if (_debug)
				{
					Log.debug("dequeuePendingRequest: " + _currentRequest.requestMethod + " " + urlRequest.url, this);
				}
				
				// depending on the request method, different options are set.
				switch (_currentRequest.requestMethod)
				{
					case NebulaRequestMethod.GET:
						urlRequest.method = URLRequestMethod.GET;
						break;
					case NebulaRequestMethod.POST:
						urlRequest.method = URLRequestMethod.POST;
						break;
					case NebulaRequestMethod.DELETE:
						urlRequest.method = URLRequestMethod.POST;
						urlRequest.requestHeaders.push(new URLRequestHeader("X-HTTP-Method-Override", "DELETE"));
						break;
					case NebulaRequestMethod.PUT:
						urlRequest.method = URLRequestMethod.POST;
						urlRequest.requestHeaders.push(new URLRequestHeader("X-HTTP-Method-Override", "PUT"));
						break;
					case NebulaRequestMethod.GET_OVERRIDE:
						urlRequest.method = URLRequestMethod.POST;
						urlRequest.requestHeaders.push(new URLRequestHeader("X-HTTP-Method-Override", "GET"));
						break;
				}
				
				// sets the variables.
				urlRequest.data = requestVariables;
				// sets the content type.
				urlRequest.contentType = "application/x-www-form-urlencoded";
				urlRequest.requestHeaders.push(new URLRequestHeader("Accept", "application/" + _dataFormat));
				
				// stores the object to be requested.
				_currentRequest.urlRequest = urlRequest;
				
				// checks if something should be done before sending the request.
				if (_currentRequest.beforeSendHandler != null)
					_currentRequest.beforeSendHandler(_currentRequest);
				
				// loads the url.
				_urlLoader.load(urlRequest);
			}
		}
		
		
		/**
		 * @private
		 * 
		 * @param message
		 * @param method
		 * @param r
		 * @param warn
		 */
		private function callbackFail(message:String, method:String, r:NebulaRequest,
									  warn:Boolean = false):void
		{
			/* Not using the urlPath since it includes identifiers, format and other stuff. */
			if (r.responseData != null)
			{
				fail(message + " (error was: \"" + r.responseData['error']['message'] + "\").",
					method, r.responseData['error'], warn);
			}
			else
			{
				fail(message, method, {type: "http_500", message: _httpStatus, details: {}}, warn);
			}
		}
		
		
		/**
		 * @private
		 * 
		 * @param message
		 * @param method
		 * @param error
		 * @param warn
		 */
		private function fail(message:String, method:String = null, error:Object = null,
							  warn:Boolean = false):void
		{
			if (warn) Log.warn(message, this);
			else Log.error(message, this);
			
			// TODO use the id field of the NebulaError to identify each possible error.
			if (_errorSignal && method && error)
			{
				_errorSignal.dispatch(new NebulaError(0, error['type'], error['message'],
					error['details'], method));
			}
		}
		
		
		/**
		 * Requests the hiscores for a given game. A session does not need to be active to use
		 * this method.
		 * 
		 * @private
		 *
		 * @param leaderboardID
		 * @param gameID
		 * @param levelID
		 * @param limit The maximum amount of results you want.
		 * @param offset The offset for the results (e.g. offset 100 with a limit of 10 gets you
		 *        hiscores 100 to 110).
		 * @param filters filters that will be used to get the scores.
		 */
		private function getScores(leaderboardID:String, gameID:String = null,
								   levelID:String = null, limit:uint = 100, offset:uint = 0, ... filters):void
		{
			/* Success callback handler. */
			var onSuccess:Function = function(r:NebulaRequest):void
			{
				if (_debug) log("Received Nebula hiscores.");
				if (!_scoresSignal) return;
				
				/* Create new leaderboard VO. */
				var vo:NebulaLeaderboard = new NebulaLeaderboard();
				
				/* Get the total amount of players. */
				vo.totalPlayers = parseInt(r.responseData['totalPlayers']);
				
				/* Result of playerID filter. */
				vo.playerPosition = r.responseData['playerPosition'] != null
					? parseInt(r.responseData['playerPosition'])
					: -1;
				vo.playerScore = r.responseData['playerScore'] != null
					? parseInt(r.responseData['playerScore'])
					: -1;
				
				/* Extracts the score info. */
				var a:Array = r.responseData['scores'];
				vo.scores = new Vector.<NebulaScore>(a.length, true);
				
				/* Extract scores. */
				for (var i:uint = 0; i < a.length; i++)
				{
					/* Create new score, extract it and set player. */
					var s:NebulaScore = new NebulaScore();
					s.score = parseInt(a[i]['score']);
					s.player = NebulaPlayer.createFromResponse(a[i]['player']);
					
					/* Save the return_date data. */
					if (a[i]['date'] != null)
					{
						s.date = new Date(parseInt(a[i]['date']) * 1000);
					}
					
					/* Save the return_game_progress data. */
					s.lastCheckpoint = a[i]['lastCheckpoint'];
					s.lastLevel = a[i]['lastLevel'];
					
					/* Save the return_location data. */
					if (a[i]['location'] != null)
					{
						s.location = NebulaLocation.createFromResponse(a[i]['location']);
					}
					
					/* Add the score to the leaderboard. */
					vo.scores[i] = s;
				}
				_scoresSignal.dispatch(vo);
			};
			
			/* Error callback handler. */
			var onError:Function = function(r:NebulaRequest):void
			{
				callbackFail("Failed to get Nebula hiscores for game.", METHOD_GET_SCORES, r);
			};
			
			var sendData:Object =
				{
					offset:	offset,
					limit:	limit,
					level:	levelID ? levelID : "",
						game:	gameID ? gameID : ""
				};
			var url:String = StringUtils.format(API_SCORES, leaderboardID);
			
			/* Iterates the filters, applying them to the sendData. */
			for (var j:uint = 0; j < filters.length; j++)
			{
				var f:INebulaScoresFilter = filters[j];
				if (f) f.applyFilter(sendData);
			}
			
			if (_debug)
			{
				Log.debug("getScores:\n" + dumpObj(sendData), this);
			}
			
			/* Queues the request. */
			queueRequest(new NebulaRequest(NebulaRequestMethod.GET_OVERRIDE, url, sendData,
				onSuccess, onError));
		}
		
		
		/**
		 * @private
		 */
		private function log(message:String):void
		{
			Log.debug(message, this);
		}
		
		
		/**
		 * Masks the given identifier so that only the last characters
		 * are visible.
		 * 
		 * @private
		 *
		 * @param id identifier to mask.
		 */
		private function mask(id:String):String
		{
			if (id == null) return null;
			return id.substr(0, int(id.length * 0.5)) + id.substr(int(id.length * 0.5)).replace(/./g, "*");
		}
		
		
		/**
		 * @private
		 */
		private function processResponse(e:Event):void
		{
			if (_currentRequest == null)
			{
				fail("processResponse: The currentRequest is empty! This should never happen!");
				return;
			}
			
			var responseData:String = _urlLoader.data;
			var isValid:Boolean = true;
			
			if (responseData == null || responseData == "")
			{
				// TODO Correctly handle this case since the _currentRequest is empty.
				fail("processResponse: The Nebula server response data was null!");
				if (_currentRequest.errorHandler != null)
				{
					_currentRequest.errorHandler(_currentRequest);
				}
				return;
			}
			
			/* Parse the data using the current parser. */
			try
			{
				_currentRequest.responseData = _responseParser.parse(responseData);
			}
			catch (err:Error)
			{
				Log.error("processResponse: Failed to parse the Nebula response data! (Error was: "
					+ err.message + ").", this);
				if (_debug && responseData)
				{
					/* Dumping out a maximum of 256 chars of the response data. */
					var s:String = responseData.length > 256
						? responseData.substr(0, 256) + "..."
						: responseData;
					Log.error("responseData content:\n" + s, this);
				}
				isValid = false;
			}
			
			/* Check if it was successful. */
			if (!isValid || _currentRequest.responseData['success'] == false)
			{
				if (_currentRequest.errorHandler != null)
					_currentRequest.errorHandler(_currentRequest);
			}
			else if (_currentRequest.responseData['success'] == true)
			{
				if (_currentRequest.successHandler != null)
					_currentRequest.successHandler(_currentRequest);
			}
			
			/* Current request is nulled since it will not be used anymore. */
			_currentRequest = null;
			
			/* Check for other pending requests. */
			dequeuePendingRequest();
		}
		
		
		/**
		 * Adds the request to the pending request list. Afterwards it is checked
		 * if it is ready to be performed or not.
		 * 
		 * @private
		 *
		 * @param request NebulaRequest that will be queued.
		 */
		private function queueRequest(request:NebulaRequest):void
		{
			if (!_pendingRequests)
			{
				fail("queueRequest: pendingRequests is null! Did you call start() before using the connector?");
				return;
			}
			
			/* Adds the request to the list. */
			_pendingRequests.push(request);
			/* Checks if it should be executed. */
			dequeuePendingRequest();
		}
		
		
		/**
		 * Adds the request to the pending request list. Afterwards it is checked
		 * if it is ready to be performed or not. It is also modified to be signed
		 * before being sent.
		 * 
		 * @private
		 *
		 * @param request NebulaRequest that will be signed and queued.
		 */
		private function queueSignedRequest(request:NebulaRequest):void
		{
			// adds the authToken/nonce if a session is available.
			if (_session)
			{
				// increases the nonce of the next request and adds it to the data to send.
				request.sendData['nonce'] = ++_session.nonce;
				// includes the access token
				request.sendData['authToken'] = _session.authToken;
			}
			
			// if no function was provided, the request will be signed.
			if (request.beforeSendHandler == null)
				request.beforeSendHandler = signRequest;
			
			queueRequest(request);
		}
		
		
		/**
		 * Sets up the class.
		 * 
		 * @private
		 */
		private function setup():void
		{
			// connector variables.
			_hmacHash = new HMAC(new SHA1());
			_currentRequest = null;
			_pendingRequests = new Vector.<NebulaRequest>();
			_httpStatus = null;
			
			_gameID = -1;
			_lastGameID = -1;
			_levelID = -1;
			_lastLevelID = -1;
			
			// creates the loader used to make the requests.
			_urlLoader = new URLLoader();
			_urlLoader.dataFormat = URLLoaderDataFormat.TEXT;
			_urlLoader.addEventListener(Event.COMPLETE, onURLLoaderComplete);
			_urlLoader.addEventListener(HTTPStatusEvent.HTTP_STATUS, onURLLoaderHTTPStatus);
			_urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onURLLoaderSecurityError);
			_urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onURLLoaderIOError);
		}
		
		
		/**
		 * Adds a HMAC-SHA1 signature of the request's data.
		 * Uses the global secret key + the session key, unless options.nebulaSkipSession is true.
		 * 
		 * @private
		 *
		 * @param options An option hash.
		 */
		private function signRequest(request:NebulaRequest):void
		{
			var secretKey:String = _secretKey;
			var key:String;
			var sortedKeys:Array = [];
			var message:String = "";
			
			for (key in request.sendData)
			{
				sortedKeys.push(key);
			}
			sortedKeys.sort();
			
			// creates a message with the sorted keys. This will be used to calculate
			// the signature of the request.
			for (key in sortedKeys)
			{
				if (message)
					message += "&";
				message += sortedKeys[key] + "=" + request.sendData[sortedKeys[key]];
			}
			
			// if a session is available the session key is appended to the
			// secretKey
			if (_session)
				secretKey += _session.sessionKey;
			
			// calculates the signature of the request based on the message
			// and the secretKey.
			var keyBytes:ByteArray;
			var messageBytes:ByteArray;
			var shaBytes:ByteArray;
			var sha:String;
			
			keyBytes = new ByteArray();
			keyBytes.writeUTFBytes(secretKey);
			messageBytes = new ByteArray();
			messageBytes.writeUTFBytes(message);
			shaBytes = _hmacHash.compute(keyBytes, messageBytes);
			sha = Hex.fromArray(shaBytes);
			
			// adds the X-Nebula-Sign header with the signature.
			request.urlRequest.requestHeaders.push(new URLRequestHeader("X-Nebula-Sign", sha));
		}
		
		
		/**
		 * @private
		 */
		private function submitScore(leaderboard:String, identifier:String, id:int):void
		{
			// TODO: what should I do with the game and levelids?
			var onSuccess:Function = function(r:NebulaRequest):void
			{
				if (_debug) log("Published Nebula game.");
				if (_scoreSubmittedSignal) _scoreSubmittedSignal.dispatch(_lastGameID, _lastLevelID);
			};
			var onError:Function = function(r:NebulaRequest):void
			{
				callbackFail("Failed to publish Nebula game", METHOD_SUBMIT_SCORE, r);
			};
			
			// adds the identifier and the id to the data to send.
			var sendData:Object = {};
			sendData[identifier] = id;
			
			var url:String = StringUtils.format(API_SCORES, leaderboard);
			
			// queues the request.
			queueSignedRequest(new NebulaRequest(NebulaRequestMethod.POST, url, sendData, onSuccess, onError));
		}
	}
}
