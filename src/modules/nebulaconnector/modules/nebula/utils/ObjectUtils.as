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
package modules.nebula.utils
{
	public class ObjectUtils
	{
		public static function flatten(object:Object):Object
		{
			return flattenInto("", object, {});
		}


		public static function flattenInto(parentName:String, object:Object, target:Object):Object
		{
			// format used to represent several levels.
			const SUBKEY_FORMAT:String = "{0}[{1}]";

			// iterates the object and flattens the items
			for (var key:String in object)
			{
				// if the current value is a string or a number its added normally using the key "parentName[key]"
				if (object[key] is String || object[key] is Number || object[key] is Boolean)
					target[parentName == "" ? key : StringUtils.format(SUBKEY_FORMAT, parentName, key)] = object[key];
				// if it is again a container it continues flattening the object recursively.
				else
					flattenInto(parentName == "" ? key : StringUtils.format(SUBKEY_FORMAT, parentName, key), object[key], target);
			}
			return target;
		}


		// [Event type="complete" bubbles=false cancelable=false eventPhase=2]
		public static function toString(object:Object):String
		{
			// format of the properties added to the string
			// representation of the object.
			const PROPERTY_FORMAT:String = "{0}:{1} ";
			const PROPERTY_STRING_FORMAT:String = '{0}:"{1}" ';
			const PROPERTY_ARRAY_FORMAT:String = "[{0}]";

			// checks that the object is not null
			if(object == null)
				return "null";
			
			// checks if the default object is usable.
			var string:String = object['toString']();

			// if it is not an object just return its string representation.
			if (typeof(object) != "object")
				return string;

			// special case for the array.
			if (object is Array)
				return StringUtils.format(PROPERTY_ARRAY_FORMAT, string);

			// tests the object respresents a normal dynamic object
			if (string != "[object Object]")
				return string;

			// flag used to truncate the trailing space.
			var looped:Boolean = false;
			// iterates the object extracting the properties.
			string = "{";
			for (var key:String in object)
			{
				looped = true;
				// if it's an object then we make the call recursively
				if (typeof(object[key]) == "object")
					string += StringUtils.format(PROPERTY_FORMAT, key, toString(object[key]));
				else if (typeof(object[key]) == "string")
					string += StringUtils.format(PROPERTY_STRING_FORMAT, key, object[key]);
				else // otherwise we print directly the value
					string += StringUtils.format(PROPERTY_FORMAT, key, object[key]);
			}

			return (looped ? string.slice(0, -1) : string) + "}";
		}
	}
}
