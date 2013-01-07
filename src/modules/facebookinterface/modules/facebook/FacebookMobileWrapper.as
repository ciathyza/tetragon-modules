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
	import com.facebook.graph.FacebookDesktop;
	import com.facebook.graph.data.Batch;
	import com.facebook.graph.data.FQLMultiQuery;
	import com.facebook.graph.data.FacebookAuthResponse;
	import com.facebook.graph.data.FacebookSession;
	import com.facebook.graph.net.FacebookRequest;
	import com.facebook.graph.utils.IResultParser;
	import com.hexagonstar.util.reflection.getClassName;
	
	
	/**
	 * TODO
	 * 
	 * @author Hexagon
	 */
	public class FacebookMobileWrapper implements IFacebookWrapper
	{
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		public function init(applicationId:String, callback:Function = null, options:Object = null,
			accessToken:String = null):void
		{
		}
		
		
		public function login(callback:Function, extendedPermissions:Array = null):void
		{
		}
		
		
		public function logout(callback:Function = null, appOrigin:String = null):void
		{
		}
		
		
		public function postData(method:String, callback:Function, params:* = null):void
		{
		}
		
		
		public function api(method:String, callback:Function = null, params:* = null,
			requestMethod:String = "GET"):void
		{
		}
		
		
		public function batchRequest(batch:Batch, callback:Function = null):void
		{
		}
		
		
		public function callRestAPI(methodName:String, callback:Function = null, values:* = null,
			requestMethod:String = "GET"):void
		{
		}
		
		
		public function deleteObject(method:String, callback:Function = null):void
		{
		}
		
		
		public function fqlMultiQuery(queries:FQLMultiQuery, callback:Function = null,
			parser:IResultParser = null):void
		{
		}
		
		
		public function fqlQuery(query:String, callback:Function = null, values:Object = null):void
		{
		}
		
		
		public function getImageUrl(id:String, type:String = null):String
		{
			return null;
		}
		
		
		public function getRawResult(data:Object):Object
		{
			return null;
		}
		
		
		public function getSession():FacebookSession
		{
			return null;
		}
		
		
		public function hasNext(data:Object):Boolean
		{
			return false;
		}
		
		
		public function hasPrevious(data:Object):Boolean
		{
			return false;
		}
		
		
		public function nextPage(data:Object, callback:Function):FacebookRequest
		{
			return null;
		}
		
		
		public function previousPage(data:Object, callback:Function):FacebookRequest
		{
			return null;
		}
		
		
		public function requestExtendedPermissions(callback:Function, ...args:*):void
		{
		}
		
		
		public function uploadVideo(method:String, callback:Function = null, params:* = null):void
		{
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
