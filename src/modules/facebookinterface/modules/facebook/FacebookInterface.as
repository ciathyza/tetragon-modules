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
package modules.facebook
{
	import tetragon.BuildType;
	import tetragon.debug.Log;
	import tetragon.modules.IModule;
	import tetragon.modules.IModuleInfo;
	import tetragon.modules.Module;

	import com.facebook.graph.data.FacebookSession;
	import com.hexagonstar.signals.Signal;
	import com.hexagonstar.util.reflection.getClassPropertyList;
	
	
	/**
	 * FacebookInterface module
	 *
	 * @author Hexagon
	 */
	public class FacebookInterface extends Module implements IModule
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		private var _facebook:IFacebookWrapper;
		private var _applicationID:String;
		private var _authToken:String;
		
		private var _session:FacebookSession;
		private var _friendsArray:Array;
		private var _me:FacebookUser;
		
		
		//-----------------------------------------------------------------------------------------
		// Signals
		//-----------------------------------------------------------------------------------------
		
		private var _initializedSignal:Signal;
		private var _initializationFailedSignal:Signal;
		private var _loginSignal:Signal;
		private var _loginFailedSignal:Signal;
		private var _logoutSignal:Signal;
		private var _errorSignal:Signal;
		private var _meReceivedSignal:Signal;
		private var _userReceivedSignal:Signal;
		private var _friendsReceivedSignal:Signal;
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override public function init():void
		{
			_applicationID = initParams['applicationID'];
			_authToken = initParams['authToken'];
			
			setup();
		}
		
		
		/**
		 * Initializes the Facebook connection.
		 */
		public function initialize():void
		{
			Log.debug("Initializing Facebook connection with appID \"" + _applicationID + "\" ...", this);
			if (_authToken) Log.debug("Auth Token: " + _authToken);
			_facebook.init(_applicationID, onFacebookInitialized, null, _authToken);
		}
		
		
		/**
		 * Logs into Facebook.
		 */
		public function login(extendedPermissions:Array = null):void
		{
			Log.debug("Logging into Facebook ...", this);
			_facebook.login(onFacebookLogin, extendedPermissions);
		}
		
		
		/**
		 * Logs out of Facebook.
		 */
		public function logout():void
		{
			Log.debug("Logging out of Facebook ...", this);
			_facebook.logout(onLogout);
		}
		
		
		public function api(method:String, params:* = null, requestMethod:String = "GET"):void
		{
			_facebook.api(method, onAPI, params, requestMethod);
		}
		
		
		/**
		 * Fetches infos about current Facebook User..
		 */
		public function getMe():void
		{
			_facebook.api("me", onAPIGetMe, null, "GET");
		}
		
		
		/**
		 * Fetches infos about a Facebook User.
		 */
		public function getUser(userID:String):void
		{
			_facebook.api(userID, onAPIGetUser, null, "GET");
		}
		
		
		/**
		 * Fetches list of friends of currently logged in Facebook user.
		 */
		public function getFriends():void
		{
			_facebook.api("me/friends", onAPIGetFriends, null, "GET");
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function dispose():void
		{
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		/**
		 * The default ID of the module.
		 */
		public static function get defaultID():String
		{
			return "facebookInterface";
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function get moduleInfo():IModuleInfo
		{
			return new FacebookInterfaceModuleInfo();
		}
		
		
		/**
		 * The ID of the Facebook application.
		 */
		public function get applicationID():String
		{
			return _applicationID;
		}
		
		
		public function get authToken():String
		{
			return _authToken;
		}
		
		
		public function get hasFriends():Boolean
		{
			return _friendsArray != null;
		}
		
		
		/**
		 * An array of FacebookFriend objects.
		 * (You need to call getFriends() first)
		 */
		public function get friendsArray():Array
		{
			return _friendsArray;
		}
		
		
		/**
		 * A map of FacebookFriend objects.
		 * (You need to call getFriends() first)
		 */
		public function get friends():Object
		{
			if (!_friendsArray)
			{
				Log.warn("Friends array is null.", this);
				return null;
			}
			var friends:Object = {};
			for (var i:uint = 0; i < _friendsArray.length; i++)
			{
				var f:FacebookFriend = _friendsArray[i];
				friends[f.id] = f;
			}
			return friends;
		}
		
		
		public function get me():FacebookUser
		{
			return _me;
		}
		
		
		/**
		 * Status of the current session.
		 */
		public function get loggedIn():Boolean
		{
			return (_session != null);
		}
		
		
		public function get initializedSignal():Signal
		{
			if (!_initializedSignal) _initializedSignal = new Signal();
			return _initializedSignal;
		}
		
		
		public function get initializationFailedSignal():Signal
		{
			if (!_initializationFailedSignal) _initializationFailedSignal = new Signal();
			return _initializationFailedSignal;
		}
		
		
		public function get loginSignal():Signal
		{
			if (!_loginSignal) _loginSignal = new Signal();
			return _loginSignal;
		}
		
		
		public function get loginFailedSignal():Signal
		{
			if (!_loginFailedSignal) _loginFailedSignal = new Signal();
			return _loginFailedSignal;
		}
		
		
		public function get logoutSignal():Signal
		{
			if (!_logoutSignal) _logoutSignal = new Signal();
			return _logoutSignal;
		}
		
		
		/**
		 * Dispatched after the me user has been received after a call to getUser().
		 * The signal passes a FacebookUser object.
		 */
		public function get meReceivedSignal():Signal
		{
			if (!_meReceivedSignal) _meReceivedSignal = new Signal();
			return _meReceivedSignal;
		}
		
		
		/**
		 * Dispatched after a user has been received after a call to getUser().
		 * The signal passes a FacebookUser object.
		 */
		public function get userReceivedSignal():Signal
		{
			if (!_userReceivedSignal) _userReceivedSignal = new Signal();
			return _userReceivedSignal;
		}
		
		
		/**
		 * Dispatched after the user's friends have been received after a call to getFriends().
		 * The signal passes an array of FacebookFriend objects.
		 */
		public function get friendsReceivedSignal():Signal
		{
			if (!_friendsReceivedSignal) _friendsReceivedSignal = new Signal();
			return _friendsReceivedSignal;
		}
		
		
		/**
		 * The error signal that is dispatched in case any errors occur in the module.
		 */
		public function get errorSignal():Signal
		{
			if (!_errorSignal) _errorSignal = new Signal();
			return _errorSignal;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Callback Handlers
		//-----------------------------------------------------------------------------------------
		
		private function onFacebookInitialized(success:Object, failObj:Object):void
		{
			Log.trace("Initialization success: " + success, this);
			
			/* Already logged in because of existing session. */
			if (success)
			{
				_session = success as FacebookSession;
				Log.debug("Init succeeded!", this);
				if (!_initializedSignal) return;
				_initializedSignal.dispatch();
			}
			else
			{
				/* Failed! Probably not logged in yet. */
				//failFBCallback(failObj, "Failed to initialize Facebook connection!", true);
				if (!_initializationFailedSignal) return;
				_initializationFailedSignal.dispatch();
			}
		}
		
		
		private function onFacebookLogin(success:Object, failObj:Object):void
		{
			Log.trace("onFacebookLogin(): success: " + success + ", failObj: " + failObj, this);
			
			if (success)
			{
				Log.debug("Login successful!", this);
				//Debug.trace(getClassPropertyList(success));
				
				/* '_session = success as FacebookSession' doesn't work! _session is still
				 * null after trying this! Either a bug in Adobe's Facebook API or Facebook
				 * changed something and Adobe's API is outdated! */
				_session = createSessionObject(success);
				if (!_loginSignal) return;
				_loginSignal.dispatch();
			}
			else
			{
				//failFBCallback(failObj, "Failed to log into Facebook!", true);
				if (!_loginFailedSignal) return;
				_loginFailedSignal.dispatch();
			}
		}
		
		
		private function onLogout(response:Object = null):void
		{
			_session = null;
			_me = null;
			_friendsArray = null;
			if (!_logoutSignal) return;
			_logoutSignal.dispatch();
		}
		
		
		private function onAPI(result:Object, failObj:Object):void
		{
			if (result)
			{
				Log.debug("API request successful!", this);
				//Debug.traceObj(result);
			}
			else
			{
				failFBCallback(failObj, "Failed API request!", true);
			}
		}
		
		
		private function onAPIGetUser(result:Object, failObj:Object):void
		{
			if (result)
			{
				Log.debug("API.getUser request successful!", this);
				if (!_userReceivedSignal) return;
				_userReceivedSignal.dispatch(createUserObject(result));
			}
			else
			{
				failFBCallback(failObj, "Failed API.getMe request!", true);
			}
		}
		
		
		private function onAPIGetMe(result:Object, failObj:Object):void
		{
			if (result)
			{
				Log.debug("API.getMe request successful!", this);
				_me = createUserObject(result);
				if (!_meReceivedSignal) return;
				_meReceivedSignal.dispatch(createUserObject(_me));
			}
			else
			{
				failFBCallback(failObj, "Failed API.getMe request!", true);
			}
		}
		
		
		private function onAPIGetFriends(result:Object, failObj:Object):void
		{
			if (result)
			{
				Log.debug("API.getFriends request successful!", this);
				_friendsArray = [];
				var a:Array = result as Array;
				for (var i:uint = 0; i < a.length; i++)
				{
					var o:Object = a[i];
					_friendsArray.push(new FacebookFriend(o['id'], o['name']));
				}
				Log.debug("Received " + _friendsArray.length + " friends.", this);
				if (!_friendsReceivedSignal) return;
				_friendsReceivedSignal.dispatch(_friendsArray);
			}
			else
			{
				failFBCallback(failObj, "Failed API.getFriends request!", true);
			}
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Sets up the module. This method is used to create any objects that the module might
		 * require, add event listeners, etc. Setup is called when the module is initialized.
		 */
		private function setup():void
		{
			var buildType:String = main.appInfo.buildType;
			if (buildType == BuildType.DESKTOP)
			{
				_facebook = new FacebookDesktopWrapper();
			}
			else if (buildType == BuildType.WEB)
			{
				_facebook = new FacebookWebWrapper();
			}
			else if (buildType == BuildType.ANDROID || buildType == BuildType.IOS)
			{
				_facebook = new FacebookMobileWrapper();
			}
		}
		
		
		/**
		 * @private
		 */
		private function createSessionObject(result:Object):FacebookSession
		{
			if (!result) return null;
			
			var session:FacebookSession = new FacebookSession();
			setValueToObject(result, session, "secret");
			setValueToObject(result, session, "availablePermissions");
			setValueToObject(result, session, "accessToken");
			setValueToObject(result, session, "expireDate");
			setValueToObject(result, session, "sig");
			setValueToObject(result, session, "uid");
			setValueToObject(result, session, "sessionKey");
			setValueToObject(result, session, "user");
			
			if (session.user)
			{
				_me = createUserObject(session.user);
			}
			
			Log.trace("FacebookSession:\n" + getClassPropertyList(session), this);
			return session;
		}
		
		
		/**
		 * @private
		 */
		private function createUserObject(result:Object):FacebookUser
		{
			var user:FacebookUser = new FacebookUser();
			setValueToObject(result, user, "id");
			setValueToObject(result, user, "name");
			setValueToObject(result, user, "first_name");
			setValueToObject(result, user, "middle_name");
			setValueToObject(result, user, "last_name");
			setValueToObject(result, user, "gender");
			setValueToObject(result, user, "locale");
			setValueToObject(result, user, "link");
			setValueToObject(result, user, "username");
			setValueToObject(result, user, "updated_time");
			setValueToObject(result, user, "email");
			
			Log.trace("FacebookUser:\n" + getClassPropertyList(user), this);
			return user;
		}
		
		
		/**
		 * @private
		 */
		private function setValueToObject(source:Object, target:Object, key:String):void
		{
			try
			{
				target[key] = source[key];
			}
			catch (err:Error)
			{
				Log.debug("Property \"" + key + "\" not found in source object.", this);
			}
		}
		
		
		/**
		 * Outputs an error message to the logger and dispatches the error signal in
		 * case any other objects are listening for it.
		 * 
		 * @param errorMessage The error message to output.
		 */
		private function fail(errorMessage:String, warn:Boolean = false):void
		{
			if (warn) Log.warn(errorMessage, this);
			else Log.error(errorMessage, this);
			if (!_errorSignal) return;
			_errorSignal.dispatch(errorMessage);
		}
		
		
		private function failFBCallback(failObj:Object, message:String, warn:Boolean = false):void
		{
			if (!failObj)
			{
				fail(message, warn);
				return;
			}
			
			var type:String = "";
			var msg:String = "";
			try
			{
				type = failObj['error']['type'];
				msg = failObj['error']['message'];
			}
			catch (err:Error)
			{
			}
			fail(message + " (Error was: " + type + ": " + msg + ")", warn);
		}
	}
}
