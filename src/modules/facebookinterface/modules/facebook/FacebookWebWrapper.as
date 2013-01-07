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
	import tetragon.debug.Log;

	import com.facebook.graph.Facebook;
	import com.facebook.graph.data.Batch;
	import com.facebook.graph.data.FQLMultiQuery;
	import com.facebook.graph.data.FacebookAuthResponse;
	import com.facebook.graph.data.FacebookSession;
	import com.facebook.graph.net.FacebookRequest;
	import com.facebook.graph.utils.IResultParser;
	import com.hexagonstar.util.reflection.getClassName;
	
	
	/**
	 * @author Hexagon
	 */
	public class FacebookWebWrapper implements IFacebookWrapper
	{
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		public function init(applicationId:String, callback:Function = null, options:Object = null,
			accessToken:String = null):void
		{
			Facebook.init(applicationId, callback, options, accessToken);
		}
		
		
		public function login(callback:Function, extendedPermissions:Array = null):void
		{
			var options:Object;
			if (extendedPermissions)
			{
				var s:String = "";
				var l:uint = extendedPermissions.length;
				for (var i:uint = 0; i < l; i++)
				{
					s += extendedPermissions[i];
					if (i < l - 1) s += ", ";
				}
				options = {scope: s};
			}
			Log.debug("login extendedPermissions: {scope: " + s + "}", this);
			
			Facebook.login(callback, options);
		}
		
		
		public function logout(callback:Function = null, appOrigin:String = null):void
		{
			Facebook.logout(callback);
		}
		
		
		public function postData(method:String, callback:Function, params:* = null):void
		{
			Facebook.postData(method, callback, params);
		}
		
		
		public function api(method:String, callback:Function = null, params:* = null,
			requestMethod:String = "GET"):void
		{
			Facebook.api(method, callback, params, requestMethod);
		}
		
		
		public function addJSEventListener(event:String, listener:Function):void
		{
			Facebook.addJSEventListener(event, listener);
		}
		
		
		public function removeJSEventListener(event:String, listener:Function):void
		{
			Facebook.removeJSEventListener(event, listener);
		}
		
		
		public function batchRequest(batch:Batch, callback:Function = null):void
		{
			Facebook.batchRequest(batch, callback);
		}
		
		
		public function callJS(methodName:String, params:Object):void
		{
			Facebook.callJS(methodName, params);
		}
		
		
		public function callRestAPI(methodName:String, callback:Function = null, values:* = null,
			requestMethod:String = "GET"):void
		{
			Facebook.callRestAPI(methodName, callback, values, requestMethod);
		}
		
		
		public function deleteObject(method:String, callback:Function = null):void
		{
			Facebook.deleteObject(method, callback);
		}
		
		
		public function fqlMultiQuery(queries:FQLMultiQuery, callback:Function = null,
			parser:IResultParser = null):void
		{
			Facebook.fqlMultiQuery(queries, callback, parser);
		}
		
		
		public function fqlQuery(query:String, callback:Function = null, values:Object = null):void
		{
			Facebook.fqlQuery(query, callback, values);
		}
		
		
		public function getAuthResponse():FacebookAuthResponse
		{
			return Facebook.getAuthResponse();
		}
		
		
		public function getImageUrl(id:String, type:String = null):String
		{
			return Facebook.getImageUrl(id, type);
		}
		
		
		public function getLoginStatus():void
		{
			Facebook.getLoginStatus();
		}
		
		
		public function getRawResult(data:Object):Object
		{
			return Facebook.getRawResult(data);
		}
		
		
		public function hasJSEventListener(event:String, listener:Function):Boolean
		{
			return Facebook.hasJSEventListener(event, listener);
		}
		
		
		public function hasNext(data:Object):Boolean
		{
			return Facebook.hasNext(data);
		}
		
		
		public function hasPrevious(data:Object):Boolean
		{
			return Facebook.hasPrevious(data);
		}
		
		
		public function mobileLogin(redirectUri:String, display:String = "touch",
			extendedPermissions:Array = null):void
		{
			Facebook.mobileLogin(redirectUri, display, extendedPermissions);
		}
		
		
		public function mobileLogout(redirectUri:String):void
		{
			Facebook.mobileLogout(redirectUri);
		}
		
		
		public function nextPage(data:Object, callback:Function):FacebookRequest
		{
			return Facebook.nextPage(data, callback);
		}
		
		
		public function previousPage(data:Object, callback:Function):FacebookRequest
		{
			return Facebook.previousPage(data, callback);
		}
		
		
		public function setCanvasAutoResize(autoSize:Boolean = true, interval:uint = 100):void
		{
			Facebook.setCanvasAutoResize(autoSize, interval);
		}
		
		
		public function setCanvasSize(width:Number, height:Number):void
		{
			Facebook.setCanvasSize(width, height);
		}
		
		
		public function ui(method:String, data:Object, callback:Function = null,
			display:String = null):void
		{
			Facebook.ui(method, data, callback, display);
		}
		
		
		public function uploadVideo(method:String, callback:Function = null, params:* = null):void
		{
			Facebook.uploadVideo(method, callback, params);
		}
		
		
		/**
		 * Returns a String Representation of the class.
		 * 
		 * @return A String Representation of the class.
		 */
		public function toString():String
		{
			return getClassName(this);
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		public function set locale(v:String):void
		{
			Facebook.locale = v;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Unused
		//-----------------------------------------------------------------------------------------
		
		public function getSession():FacebookSession
		{
			return null;
		}
		public function requestExtendedPermissions(callback:Function, ...args:*):void
		{
		}
		public function set manageSession(v:Boolean):void
		{
		}
	}
}
