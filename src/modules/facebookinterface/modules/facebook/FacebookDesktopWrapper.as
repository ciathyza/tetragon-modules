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
	import tetragon.util.reflection.getClassName;

	import com.facebook.graph.FacebookDesktop;
	import com.facebook.graph.data.Batch;
	import com.facebook.graph.data.FQLMultiQuery;
	import com.facebook.graph.data.FacebookAuthResponse;
	import com.facebook.graph.data.FacebookSession;
	import com.facebook.graph.net.FacebookRequest;
	import com.facebook.graph.utils.IResultParser;
	
	
	/**
	 * @author Hexagon
	 */
	public class FacebookDesktopWrapper implements IFacebookWrapper
	{
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		public function init(applicationId:String, callback:Function = null, options:Object = null,
			accessToken:String = null):void
		{
			FacebookDesktop.init(applicationId, callback, accessToken);
		}
		
		
		public function login(callback:Function, extendedPermissions:Array = null):void
		{
			Log.debug("extendedPermissions: " + extendedPermissions, this);
			FacebookDesktop.login(callback, extendedPermissions);
		}
		
		
		public function logout(callback:Function = null, appOrigin:String = null):void
		{
			FacebookDesktop.logout(callback, appOrigin);
		}
		
		
		public function postData(method:String, callback:Function, params:* = null):void
		{
			FacebookDesktop.postData(method, callback, params);
		}
		
		
		public function api(method:String, callback:Function = null, params:* = null,
			requestMethod:String = "GET"):void
		{
			FacebookDesktop.api(method, callback, params, requestMethod);
		}
		
		
		public function batchRequest(batch:Batch, callback:Function = null):void
		{
			FacebookDesktop.batchRequest(batch, callback);
		}
		
		
		public function callRestAPI(methodName:String, callback:Function = null, values:* = null,
			requestMethod:String = "GET"):void
		{
			FacebookDesktop.callRestAPI(methodName, callback, values, requestMethod);
		}
		
		
		public function deleteObject(method:String, callback:Function = null):void
		{
			FacebookDesktop.deleteObject(method, callback);
		}
		
		
		public function fqlMultiQuery(queries:FQLMultiQuery, callback:Function = null,
			parser:IResultParser = null):void
		{
			FacebookDesktop.fqlMultiQuery(queries, callback, parser);
		}
		
		
		public function fqlQuery(query:String, callback:Function = null, values:Object = null):void
		{
			FacebookDesktop.fqlQuery(query, callback, values);
		}
		
		
		public function getImageUrl(id:String, type:String = null):String
		{
			return FacebookDesktop.getImageUrl(id, type);
		}
		
		
		public function getRawResult(data:Object):Object
		{
			return FacebookDesktop.getRawResult(data);
		}
		
		
		public function getSession():FacebookSession
		{
			return FacebookDesktop.getSession();
		}
		
		
		public function hasNext(data:Object):Boolean
		{
			return FacebookDesktop.hasNext(data);
		}
		
		
		public function hasPrevious(data:Object):Boolean
		{
			return FacebookDesktop.hasPrevious(data);
		}
		
		
		public function nextPage(data:Object, callback:Function):FacebookRequest
		{
			return FacebookDesktop.nextPage(data, callback);
		}
		
		
		public function previousPage(data:Object, callback:Function):FacebookRequest
		{
			return FacebookDesktop.previousPage(data, callback);
		}
		
		
		public function requestExtendedPermissions(callback:Function, ...args:*):void
		{
			FacebookDesktop.requestExtendedPermissions(callback, args);
		}
		
		
		public function uploadVideo(method:String, callback:Function = null, params:* = null):void
		{
			FacebookDesktop.uploadVideo(method, callback, params);
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
			FacebookDesktop.locale = v;
		}
		
		
		public function set manageSession(v:Boolean):void
		{
			FacebookDesktop.manageSession = v;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Unused
		//-----------------------------------------------------------------------------------------
		
		public function addJSEventListener(event:String, listener:Function):void
		{
		}
		public function removeJSEventListener(event:String, listener:Function):void
		{
		}
		public function callJS(methodName:String, params:Object):void
		{
		}
		public function getAuthResponse():FacebookAuthResponse
		{
			return null;
		}
		public function getLoginStatus():void
		{
		}
		public function hasJSEventListener(event:String, listener:Function):Boolean
		{
			return false;
		}
		public function mobileLogin(redirectUri:String, display:String = "touch",
			extendedPermissions:Array = null):void
		{
		}
		public function mobileLogout(redirectUri:String):void
		{
		}
		public function setCanvasAutoResize(autoSize:Boolean = true, interval:uint = 100):void
		{
		}
		public function setCanvasSize(width:Number, height:Number):void
		{
		}
		public function ui(method:String, data:Object, callback:Function = null,
			display:String = null):void
		{
		}
	}
}
