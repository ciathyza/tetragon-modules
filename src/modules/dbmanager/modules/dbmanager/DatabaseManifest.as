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
	import tetragon.Main;
	import tetragon.data.DataObject;
	import tetragon.data.Settings;

	import flash.filesystem.File;
	
	
	/**
	 * DatabaseManifest class
	 *
	 * @author Hexagon
	 */
	public class DatabaseManifest extends DataObject
	{
		//-----------------------------------------------------------------------------------------
		// Properties
		//-----------------------------------------------------------------------------------------
		
		private var _fileName:String;
		private var _fileSubFolder:String;
		private var _filePath:String;
		private var _file:File;
		private var _tables:Vector.<DBTable>;
		private var _rowsNum:int;
		
		private static var _userDataPath:String;
		
		
		//-----------------------------------------------------------------------------------------
		// Constructor
		//-----------------------------------------------------------------------------------------
		
		/**
		 * Creates a new instance of the class.
		 */
		public function DatabaseManifest(id:String, fileName:String, fileSubFolder:String = null)
		{
			_id = id;
			_fileName = fileName;
			_fileSubFolder = fileSubFolder;
			_tables = new <DBTable>[];
			_rowsNum = 0;
			
			resolveFile();
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Public Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @param table
		 * @return true or false
		 */
		public function addTable(table:DBTable):Boolean
		{
			if (containsTable(table)) return false;
			if (table.rows != null) _rowsNum += table.rows.length;
			_tables.push(table);
			return true;
		}
		
		
		/**
		 * @param name
		 * @return true or false
		 */
		public function containsTable(table:DBTable):Boolean
		{
			for (var i:uint = 0; i < _tables.length; i++)
			{
				if (_tables[i].name == table.name) return true;
			}
			return false;
		}
		
		
		/**
		 * @param name
		 */
		public function getTable(name:String):DBTable
		{
			for (var i:uint = 0; i < _tables.length; i++)
			{
				if (_tables[i].name == name) return _tables[i];
			}
			return null;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Accessors
		//-----------------------------------------------------------------------------------------
		
		public function get fileName():String
		{
			return _fileName;
		}


		public function get fileSubFolder():String
		{
			return _fileSubFolder;
		}
		
		
		/**
		 * The full path to the db file.
		 */
		public function get filePath():String
		{
			return _filePath;
		}
		
		
		public function get file():File
		{
			return _file;
		}
		
		
		public function get tables():Vector.<DBTable>
		{
			return _tables;
		}
		
		
		public function get rowsNum():int
		{
			return _rowsNum;
		}
		
		
		//-----------------------------------------------------------------------------------------
		// Private Methods
		//-----------------------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private function resolveFile():void
		{
			if (_userDataPath == null)
			{
				_userDataPath = Main.instance.registry.settings.getString(Settings.USER_DATA_DIR);
			}
			
			if (_fileSubFolder != null)
			{
				_filePath = _userDataPath + File.separator + _fileSubFolder + File.separator + _fileName;
			}
			else
			{
				_filePath = _userDataPath + File.separator + _fileName;
			}
			
			_file = new File();
			_file = _file.resolvePath(_filePath);
		}
	}
}
