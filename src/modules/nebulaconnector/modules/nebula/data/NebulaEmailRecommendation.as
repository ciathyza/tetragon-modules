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
package modules.nebula.data
{
    import modules.nebula.utils.ObjectUtils;

    /**
     * @author Rune (rune@nothing.ch)
     */
    public final class NebulaEmailRecommendation
    {
        /** Defines the email property name. */
        private static const EMAIL_PROPERTY_NAME:String = "email";
        /** Defines the firstname property name. */
        private static const NAME_PROPERTY_NAME:String = "name";

        /**
         * Creates a new NebulaRecommendation using the information obtained
         * from the server response.
         *
         * @param response object that contains the properties of the email recommendation.
         *
         * @return a new NebulaRecommendation with the information obtained from the server.
         */
        public static function createFromResponse(response:Object):NebulaEmailRecommendation
        {
            var tmp:NebulaEmailRecommendation = new NebulaEmailRecommendation();

            for (var key:String in response)
            {
                // sets the obtained value from the server.
                tmp.setValue(key, response[key]);
            }

            return tmp;
        }

        /** Object used to store the values of the recommendation. All the values of the user are optional/*/
        private var _dataStorage:Object;

        /**
         * Creates a new NebulaRecommendation instance.
         */
        public function NebulaEmailRecommendation():void
        {
            // initializes the data storage for the recommendation info.
            _dataStorage = new Object;
        }

        /**
         * Creates an object that contains the stored information. The recommendation
         * details are flattened so that they can be sent to the server.
         *
         * @return an object with just one level of depth.
         */
        public function prepareData():Object
        {
            return ObjectUtils.flatten(_dataStorage);
        }

        public function toString():String
        {
            var tmpString:String = "[NebulaRecommendation";
            for (var key:String in _dataStorage)
            {
                if (typeof(_dataStorage[key]) == "string")
                    tmpString += " " + key + "=\"" + ObjectUtils.toString(_dataStorage[key]) + "\"";
                else
                    tmpString += " " + key + "=" + ObjectUtils.toString(_dataStorage[key]);
            }
            return tmpString + "]";
        }

        private function getValue(key:String):Object
        {
            return _dataStorage[key];
        }

        private function setValue(key:String, value:Object):void
        {
            _dataStorage[key] = value;
        }
			
        public function get email():String
        {
            return getValue(EMAIL_PROPERTY_NAME) as String;
        }

        public function set email(value:String):void
        {
            setValue(EMAIL_PROPERTY_NAME, value);
        }

		public function get name():String
		{
			return getValue(NAME_PROPERTY_NAME) as String;
		}
		
		public function set name(value:String):void
		{
			setValue(NAME_PROPERTY_NAME, value);
		}		
		
    }
}
