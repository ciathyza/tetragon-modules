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
package modules.dbmanager
{
	/**
	 * DBTable class
	 *
	 * @author Hexagon
	 */
	public class DBTable
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		private var _name:String;
		private var _columns:Vector.<DBColumn>;
		private var _rows:Vector.<Array>;
		private var _primaryKey:String;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 */
		public function DBTable(name:String)
		{
			_name = name;
			_columns = new <DBColumn>[];
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @param name
		 * @param type
		 * @param primaryKey
		 * @param autoInc
		 * @param allowNull
		 * @param unique
		 * @param defaultValue
		 * 
		 * @return true or false
		 */
		public function addColumn(name:String, type:String, primaryKey:Boolean = false,
			autoInc:Boolean = false, allowNull:Boolean = true, unique:Boolean = false,
			defaultValue:* = null):Boolean
		{
			if (containsColumn(name)) return false;
			
			var column:DBColumn = new DBColumn();
			column.name = name;
			column.type = type;
			column.primaryKey = primaryKey;
			column.autoInc = autoInc;
			column.allowNull = allowNull;
			column.unique = unique;
			column.defaultValue = defaultValue;
			
			_columns.push(column);
			
			if (primaryKey && _primaryKey == null)
			{
				_primaryKey = name;
			}
			
			return true;
		}
		
		
		/**
		 * Allows to add default rows of data to a database after creation.
		 * 
		 * @param tableName
		 * @param values
		 */
		public function addRow(values:Array):void
		{
			if (!_rows) _rows = new <Array>[];
			_rows.push(values);
		}
		
		
		/**
		 * @param name
		 * @return true or false
		 */
		public function containsColumn(name:String):Boolean
		{
			for (var i:uint = 0; i < _columns.length; i++)
			{
				if (_columns[i].name == name) return true;
			}
			return false;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		public function get name():String
		{
			return _name;
		}


		public function get columns():Vector.<DBColumn>
		{
			return _columns;
		}
		
		
		public function get rows():Vector.<Array>
		{
			return _rows;
		}


		public function get primaryKey():String
		{
			return _primaryKey;
		}
	}
}
