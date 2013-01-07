/*
 *      _________  __      __
 *    _/        / / /____ / /________ ____ ____  ___
 *   _/        / / __/ -_) __/ __/ _ `/ _ `/ _ \/ _ \
 *  _/________/  \__/\__/\__/_/  \_,_/\_, /\___/_//_/
 *                                   /___/
 * 
 * tetragon : Engine for Flash-based web and desktop games.
 * Licensed under the MIT License.
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy of
 * this software and associated documentation files (the "Software"), to deal in
 * the Software without restriction, including without limitation the rights to
 * use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
 * the Software, and to permit persons to whom the Software is furnished to do so,
 * subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
 * FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
 * COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
 * IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
package modules.nebula
{
	import modules.facebook.FacebookInterface;
	import modules.nebula.data.NebulaLeaderboard;

	import tetragon.debug.Log;
	import tetragon.modules.IModule;
	import tetragon.modules.Module;
	
	
	/**
	 * A service class that can be used to load hiscore leaderboards from a
	 * Nebula server. It allows for filtering hiscores to provide only the
	 * scores of the current player's Facebook friends.
	 * 
	 * <p>The class rerquires the inclusion of the FacebookInterface module!</p>
	 * 
	 * <p>Init Params:<br>
	 * <ul>
	 * <li>nebulaConnector</li>
	 * <li>facebookInterface</li>
	 * <li>nebulaLeaderboardID (optional)</li>
	 * <li>nebulaApplicationID (optional)</li>
	 * <li>nebulaLevelID (optional)</li>
	 * </ul>
	 * </p>
	 * 
	 * @author Hexagon
	 */
	public final class NebulaHiscoreService extends Module implements IModule
	{
		//-----------------------------------------------------------------------------------------
		// Constants
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Defines the Friends Leaderboard type.
		 */
		public static const FRIENDS_HISCORE:String = "friendsHiscore";
		
		/**
		 * Defines the Global Leaderboard type.
		 */
		public static const FULL_HISCORE:String = "fullHiscore";
		
		
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		/** @private */
		private var _nebulaConnector:NebulaConnector;
		/** @private */
		private var _facebookInterface:FacebookInterface;
		/** @private */
		private var _friendsLeaderboard:NebulaLeaderboard;
		/** @private */
		private var _fullLeaderboard:NebulaLeaderboard;
		/** @private */
		private var _nebulaLeaderboardID:String;
		/** @private */
		private var _nebulaApplicationID:String;
		/** @private */
		private var _nebulaLevelID:String;
		/** @private */
		private var _playerFacebookID:String;
		/** @private */
		private var _forceHiscoreReload:Boolean;
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override public function init():void
		{
			_nebulaConnector = initParams["nebulaConnector"];
			_facebookInterface = initParams["facebookInterface"];
			_nebulaLeaderboardID = initParams["nebulaLeaderboardID"];
			_nebulaApplicationID = initParams["nebulaApplicationID"];
			_nebulaLevelID = initParams["nebulaLevelID"];
			
			if (!_nebulaConnector)
			{
				Log.error("NebulaHiscoreService needs a reference to the NebulaConnector assigned"
					+ "by it's initParams (using key \"nebulaConnector\").", this);
			}
			if (!_facebookInterface)
			{
				Log.error("NebulaHiscoreService needs a reference to the FacebookInterface assigned"
					+ "by it's initParams (using key \"facebookInterface\").", this);
			}
		}
		
		
		/**
		 * Load the hiscore.
		 * 
		 * @param type Type of the highscore to load
		 *             (HighscoreVO.FULL_HIGHSCORE or HighscoreVO.FRIENDS_HIGHSCORE).
		 * @param completeHandler Callback when the loading encounters an error or completes
		 *             with signature function(leaderboard:NebulaLeaderboard, error:String).
		 * @param reload Reload the highscore even if it's already loaded.
		 */
		public function load(type:String = NebulaHiscoreService.FULL_HISCORE,
			completeHandler:Function = null, reload:Boolean = false):void
		{
			/* if a reload should be forced both friends and full leaderboards are discarded. */
			if (_forceHiscoreReload)
			{
				_friendsLeaderboard = null;
				_fullLeaderboard = null;
				_forceHiscoreReload = false;
			}
			
			/* Check if highscore is already loaded. */
			if (!reload)
			{
				if (type == FULL_HISCORE && _fullLeaderboard)
				{
					completeHandler(_fullLeaderboard, null);
					return;
				}
				else if (type == FRIENDS_HISCORE && _friendsLeaderboard)
				{
					completeHandler(_friendsLeaderboard, null);
					return;
				}
			}
			
			if (!_nebulaConnector || !_facebookInterface) return;
			
			/* Load the hiscores. */
			new HiscoreLoader(type, _playerFacebookID, this, _nebulaConnector, _facebookInterface,
				onLoaderComplete, completeHandler);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Module Default ID.
		 */
		public static function get defaultID():String
		{
			return "nebulaHiscoreService";
		}
		
		
		/**
		 * The Nebula leaderboard, containing only Facebook friends.
		 */
		public function get friendsLeaderboard():NebulaLeaderboard
		{
			return _friendsLeaderboard;
		}
		
		
		/**
		 * The full Nebula Leaderboard.
		 */
		public function get fullLeaderboard():NebulaLeaderboard
		{
			return _fullLeaderboard;
		}
		
		
		public function get nebulaLeaderboardID():String
		{
			return _nebulaLeaderboardID;
		}
		public function set nebulaLeaderboardID(v:String):void
		{
			_nebulaLeaderboardID = v;
		}
		
		
		public function get nebulaApplicationID():String
		{
			return _nebulaApplicationID;
		}
		public function set nebulaApplicationID(v:String):void
		{
			_nebulaApplicationID = v;
		}
		
		
		public function get nebulaLevelID():String
		{
			return _nebulaLevelID;
		}
		public function set nebulaLevelID(v:String):void
		{
			_nebulaLevelID = v;
		}
		
		
		/**
		 * The current player's Facebook ID.
		 */
		public function get playerFacebookID():String
		{
			return _playerFacebookID;
		}
		public function set playerFacebookID(v:String):void
		{
			_playerFacebookID = v;
		}
		
		
		/**
		 * If set to true, forces realing the leaderboards.
		 * 
		 * @default false
		 */
		public function get forceHiscoreReload():Boolean
		{
			return _forceHiscoreReload;
		}
		public function set forceHiscoreReload(v:Boolean):void
		{
			_forceHiscoreReload = v;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Callback Handlers
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private function onLoaderComplete(loader:HiscoreLoader):void
		{
			/* Handle error. */
			if (loader.errorMessage)
			{
				Log.warn("Failed loading hiscore: " + loader.errorMessage, this);
				if (loader.completeHandler != null)
				{
					loader.completeHandler(null, loader.errorMessage);
				}
			}
			else
			{
				if (loader.type == FULL_HISCORE)
				{
					_fullLeaderboard = loader.leaderboard;
				}
				else
				{
					_friendsLeaderboard = loader.leaderboard;
				}
				
				if (loader.completeHandler != null)
				{
					loader.completeHandler(loader.leaderboard, null);
				}
			}
		}
	}
}


import modules.facebook.FacebookFriend;
import modules.facebook.FacebookInterface;
import modules.nebula.NebulaConnector;
import modules.nebula.NebulaError;
import modules.nebula.NebulaHiscoreService;
import modules.nebula.data.NebulaLeaderboard;
import modules.nebula.data.NebulaScore;
import modules.nebula.data.filters.NebulaScoresPlayerIDFilter;
import modules.nebula.data.filters.NebulaScoresPlayersFilter;

import tetragon.debug.Log;


/**
 * Class used to load a Nebula hiscore leaderboard.
 * @private
 */
final class HiscoreLoader
{
	//-----------------------------------------------------------------------------------------
	// Properties
	//-----------------------------------------------------------------------------------------
	
	public var errorMessage:String;
	public var leaderboard:NebulaLeaderboard;
	public var type:String;
	public var completeHandler:Function;
	
	private var _playerFacebookID:String;
	private var _service:NebulaHiscoreService;
	private var _nebula:NebulaConnector;
	private var _facebookInterface:FacebookInterface;
	private var _callback:Function;
	
	
	//-----------------------------------------------------------------------------------------
	// Constructor
	//-----------------------------------------------------------------------------------------
	
	/**
	 * Load the hiscore of given type.
	 * 
	 * @param type Type of the hiscore, either HiscoreService.FRIENDS_HISCORE or 
	 *        HiscoreService.FULL_HISCORE.
	 * @param playerFacebookID The Facebook ID of the current player.
	 * @param service Reference to the NebulaHiscoreService.
	 * @param nebula Reference to the NebulaConnector.
	 * @param facebookInterface Reference to the FacebookInterface.
	 * @param callback Function that is called after hiscores were loaded or an error occured.
	 * @param completeHandler Reference to the external complete handler.
	 */
	public function HiscoreLoader(type:String, playerFacebookID:String, service:NebulaHiscoreService,
		nebula:NebulaConnector, facebookInterface:FacebookInterface, callback:Function,
		completeHandler:Function)
	{
		this.type = type;
		_playerFacebookID = playerFacebookID;
		_service = service;
		_nebula = nebula;
		_facebookInterface = facebookInterface;
		_callback = callback;
		this.completeHandler = completeHandler;
		
		if (type == NebulaHiscoreService.FRIENDS_HISCORE) loadFriends();
		else loadHiscore();
	}
	
	
	//-----------------------------------------------------------------------------------------
	// Callback Handlers
	//-----------------------------------------------------------------------------------------
	
	private function onFriendsReceived(friendsArray:Array):void
	{
		loadHiscore();
	}
	
	
	private function onFriendsReceivedError(errorMessage:String):void
	{
		errorMessage = "Error loading friends: " + errorMessage;
		_callback(this);
	}
	
	
	private function onHiscores(l:NebulaLeaderboard):void
	{
		/* removes the error listener. */
		_nebula.errorSignal.remove(onNebulaError);
		
		/* stores the loaded scores. */
		leaderboard = l;
		
		/* if facebook is available the scores are processed. */
		if (_facebookInterface && _facebookInterface.friends)
		{
			var friends:Object = _facebookInterface.friends;
			for each (var score:NebulaScore in l.scores)
			{
				if (!score.player) continue;
				/* overrides the name from facebook if available. */
				var facebookID:String = score.player.facebookId;
				if (friends[facebookID])
				{
					score.player.firstname = (friends[facebookID] as FacebookFriend).name;
					score.player.lastname = "";
				}
			}
		}
		_callback(this);
	}
	
	
	private function onNebulaError(error:NebulaError):void
	{
		errorMessage = "Error loading highscore: " + error.message;
		_callback(this);
	}
	
	
	//-----------------------------------------------------------------------------------------
	// Private Methods
	//-----------------------------------------------------------------------------------------
	
	private function loadFriends():void
	{
		if (_facebookInterface.hasFriends)
		{
			loadHiscore();
		}
		else
		{
			_facebookInterface.friendsReceivedSignal.addOnce(onFriendsReceived);
			_facebookInterface.errorSignal.addOnce(onFriendsReceivedError);
			_facebookInterface.getFriends();
		}
	}
	
	
	private function loadHiscore():void
	{
		var playerFilter:Array = [];
		/* Prepare filter containing all friends. */
		if (type == NebulaHiscoreService.FRIENDS_HISCORE)
		{
			if (_facebookInterface.me)
			{
				var friends:Object = _facebookInterface.friends;
				for each (var friend:FacebookFriend in friends)
				{
					playerFilter.push(friend.id);
				}
				// Add player himself
				playerFilter.push(_facebookInterface.me.id);
			}
			else
			{
				Log	.warn("User information is not available, loading complete hiscores instead.",
					this);
			}
		}
		
		/* registers the signals. */
		_nebula.scoresSignal.addOnce(onHiscores);
		_nebula.errorSignal.addOnce(onNebulaError);
		
		/* make the service call. */
		Log.debug("HiscoreLoader: Nebula service call (playerFilter: "
			+ (playerFilter.length > 0 ? playerFilter : "none") + ")");
		
		if (_playerFacebookID && _playerFacebookID != "")
		{
			_nebula.getLevelScores(_service.nebulaLeaderboardID, _service.nebulaApplicationID,
				_service.nebulaLevelID, 100, 0,
				new NebulaScoresPlayersFilter().facebookIDs(playerFilter),
				new NebulaScoresPlayerIDFilter().playerID(_playerFacebookID));
		}
		else
		{
			_nebula.getLevelScores(_service.nebulaLeaderboardID, _service.nebulaApplicationID,
				_service.nebulaLevelID, 100, 0,
				new NebulaScoresPlayersFilter().facebookIDs(playerFilter));
		}
	}
}
