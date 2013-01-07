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
     * @author joe (joe@nothing.ch)
     */
    public final class NebulaPlayer
    {
        /** Defines the details property name. */
        private static const DETAILS_PROPERTY_NAME:String = "details";
        /** Defines the email property name. */
        private static const EMAIL_PROPERTY_NAME:String = "email";
        /** Defines the facebookId property name. */
        private static const FACEBOOKID_PROPERTY_NAME:String = "facebookId";
        /** Defines the firstname property name. */
        private static const FIRSTNAME_PROPERTY_NAME:String = "firstname";
        /** Defines the id property name. */
        private static const ID_PROPERTY_NAME:String = "id";
        /** Defines the language property name. */
        private static const LANGUAGE_PROPERTY_NAME:String = "language";
        /** Defines the lastname property name. */
        private static const LASTNAME_PROPERTY_NAME:String = "lastname";
        /** Defines the nickname property name. */
        private static const NICKNAME_PROPERTY_NAME:String = "nickname";

        /**
         * Creates a new NebulaPlayer using the information obtained
         * from the server response.
         *
         * @param response object that contains the properties of the player.
         *
         * @return a new NebulaPlayer with the information obtained from the server.
         */
        public static function createFromResponse(response:Object):NebulaPlayer
        {
            var tmp:NebulaPlayer = new NebulaPlayer();

            for (var key:String in response)
            {
                // sets the obtained value from the server.
                tmp.setValue(key, response[key]);
            }

            return tmp;
        }

        /** Object used to store the values of the player. All the values of the user are optional/*/
        private var _dataStorage:Object;

        /**
         * Creates a new NebulaPlayer instance.
         */
        public function NebulaPlayer():void
        {
            // initializes the data storage for the player info.
            _dataStorage = new Object;
        }

        /**
         * Creates an object that contains the stored information. The player
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
            var tmpString:String = "[NebulaPlayer";
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

        public function get details():Object
        {
            // initializes the variable if it is null.
            if (getValue(DETAILS_PROPERTY_NAME) == null)
                this.details = new Object();
            return getValue(DETAILS_PROPERTY_NAME) as Object;
        }

        public function set details(value:Object):void
        {
            setValue(DETAILS_PROPERTY_NAME, value);
        }

        public function get email():String
        {
            return getValue(EMAIL_PROPERTY_NAME) as String;
        }

        public function set email(value:String):void
        {
            setValue(EMAIL_PROPERTY_NAME, value);
        }

        public function get facebookId():String
        {
            return getValue(FACEBOOKID_PROPERTY_NAME) as String;
        }

        public function set facebookId(value:String):void
        {
            setValue(FACEBOOKID_PROPERTY_NAME, value);
        }

        public function get firstname():String
        {
            return getValue(FIRSTNAME_PROPERTY_NAME) as String;
        }

        public function set firstname(value:String):void
        {
            setValue(FIRSTNAME_PROPERTY_NAME, value);
        }

        // TODO: temporarely changed to String since the server response 
        // contains a string.
        public function get id():String
        {
            return getValue(ID_PROPERTY_NAME) as String;
        }

        public function get language():String
        {
            return getValue(LANGUAGE_PROPERTY_NAME) as String;
        }

        public function set language(value:String):void
        {
            setValue(LANGUAGE_PROPERTY_NAME, value);
        }

        public function get lastname():String
        {
            return getValue(LASTNAME_PROPERTY_NAME) as String;
        }

        public function set lastname(value:String):void
        {
            setValue(LASTNAME_PROPERTY_NAME, value);
        }

        public function get nickname():String
        {
            return getValue(NICKNAME_PROPERTY_NAME) as String;
        }

        public function set nickname(value:String):void
        {
            setValue(NICKNAME_PROPERTY_NAME, value);
        }
    }
}
