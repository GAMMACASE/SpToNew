#define ARGS_MAX_ARG_BUFF 32
#define ARGS_MAX_TEXT_BUFF 128

enum ARG_PARSE
{
	ARG_PARSE_FAILED_SILENT = -2,
	ARG_PARSE_FAILED = -1,
	ARG_PARSE_OK = 0,
	ARG_PARSE_EXIT,
	ARG_PARSE_SKIPNEXT //Probably deprecated? ¯\_(ツ)_/¯
}

enum ARG_LEVEL
{
	ARG_ARG = 0,
	ARG_SUBARG = 1,
	ARG_ARGPLUSSUBARG
}

typeset ArgParsed 
{
	//Used for normal args;
	function ARG_PARSE (const char[] parsedArg);
	
	//Used for normal args that use custom variable;
	function ARG_PARSE (const char[] parsedArg, any variable);
	
	//Used for normal args that use subargs;
	function ARG_PARSE (const char[] parsedArg, const char[] parsedSubArg, int subArgNum);
	
	//Used for normal args that use subargs and custom variable;
	function ARG_PARSE (const char[] parsedArg, const char[] parsedSubArg, int subArgNum, any argVariable);
	
	//Used for normal args that use subargs, custom variable and custom variable for subargs;
	function ARG_PARSE (const char[] parsedArg, const char[] parsedSubArg, int subArgNum, any argVariable, any subArgVariable);
	
	//Used for subargs;
	function ARG_PARSE (const char[] parsedSubArg, int subArgNum);
	
	//Used for subargs that use custom variable;
	function ARG_PARSE (const char[] parsedSubArg, int subArgNum, any variable);
}

enum struct Args_t
{
	char arg[ARGS_MAX_ARG_BUFF];		//Arg name, can be special arg only for subargs!
	char textbuff[ARGS_MAX_TEXT_BUFF];	//Buffer to store custom text, that will be displayed if subarg was found, or on arg error
	ARG_PARSE rettype;					//Return type that will be returned if arg or subarg was found
	ArgParsed argcallback;				//Arg function that will be called when arg or subarg was found
	any variable;						//Variable that will be passed to callback function if arg of subarg was found
	Args subargs;						//Subargs handle that will be used for arg. (Subargs can't have subargs);
	int argnum;							//Arg position in what it were declared, will be passed to function callback if arg or subargs was found
}

/*enum struct SubArgs_t
{
	char arg[ARGS_MAX_ARG_BUFF];
}*/

stock static ArrayList g_alIncludedArgs;
stock static bool g_bisSilent;
/*static ArrayList g_alSubArgs;

methodmap SubArgs < ArrayList
{
	public SubArgs()
	{
		g_alSubArgs = new ArrayList(sizeof(SubArgs_t));
		return view_as<Args>(g_alSubArgs);
	}
}*/

methodmap Args < ArrayList
{
	//V2 parser here:
	property ArrayList IncludedArgs
	{
		public get() { return g_alIncludedArgs; }
		public set(ArrayList args) 
		{ 
			if(g_alIncludedArgs != null)
				delete g_alIncludedArgs;
			
			g_alIncludedArgs = args;
		}
	}
	
	property bool Silent
	{
		public get() { return g_bisSilent; }
		public set(bool silent) { g_bisSilent = silent; }
	}
	
	public Args()
	{
		return view_as<Args>(new ArrayList(sizeof(Args_t)));
	}
	
	public int SetupArg(const char arg[ARGS_MAX_ARG_BUFF], ARG_PARSE rettype = ARG_PARSE_OK, const char textbuff[ARGS_MAX_TEXT_BUFF] = "", ArgParsed argcallback = INVALID_FUNCTION, any variable = INVALID_HANDLE, Args subargs = null)
	{
		Args_t args;
		strcopy(args.arg, sizeof(args.arg), arg);
		strcopy(args.textbuff, sizeof(args.textbuff), textbuff);
		args.rettype = rettype;
		args.argcallback = argcallback;
		args.variable = variable;
		args.subargs = subargs;
		args.argnum = this.Length;
		
		return this.PushArray(args, sizeof(Args_t));
	}
	
#if DEBUG
	public void DebugArgs()
	{
		Args_t args, subargs;
		for(int i = 0; i < this.Length; i++)
		{
			this.GetArray(i, args, sizeof(Args_t));
			
			log.Debug("%s | %s | %i | %i", args.arg, args.textbuff, args.rettype, args.variable);
			
			if(args.argcallback != INVALID_FUNCTION)
			{
				Call_StartFunction(null, args.argcallback);
				Call_PushString(args.arg);
				Call_Finish();
			}
			
			if(args.subargs != null)
			{
				for(int x = 0; x < args.subargs.Length; x++)
				{
					args.subargs.GetArray(x, subargs, sizeof(Args_t));
					log.Debug("Subarg: %s | %s | %i | %i", subargs.arg, subargs.textbuff, subargs.rettype, subargs.variable);
					
					if(subargs.argcallback != INVALID_FUNCTION)
					{
						Call_StartFunction(null, subargs.argcallback);
						Call_PushString(subargs.arg);
						Call_Finish();
					}
				}
			}
		}
	}
#endif
	
	/*Possible special args:
	*	@rawtext - takes raw text as an argument;
	*/
	public bool IsSpecialArg(const char arg[ARGS_MAX_ARG_BUFF])
	{
		return StrEqual(arg, "@rawtext", false);
	}
	
	public ARG_PARSE CallCallBack(ARG_LEVEL level, Args_t args, Args_t subargs = INVALID_HANDLE, const char sarg[ARGS_MAX_ARG_BUFF] = "")
	{
		ARG_PARSE res;
		switch(level)
		{
			case ARG_ARG:
			{
				Call_StartFunction(null, args.argcallback);
				Call_PushString(args.arg);
				Call_PushCell(args.variable);
				if(Call_Finish(res) != SP_ERROR_NONE)
				{
					log.Error("Failed to call function callback for arg \"%s\".", args.arg);
					res = ARG_PARSE_FAILED_SILENT;
				}
			}
			
			case ARG_SUBARG:
			{
				Call_StartFunction(null, args.argcallback);
				Call_PushString(sarg);
				Call_PushCell(args.argnum);
				Call_PushCell(args.variable);
				if(Call_Finish(res) != SP_ERROR_NONE)
				{
					log.Error("Failed to call function callback for arg \"%s\".", args.arg);
					res = ARG_PARSE_FAILED_SILENT;
				}
			}
			
			case ARG_ARGPLUSSUBARG:
			{
				Call_StartFunction(null, args.argcallback);
				Call_PushString(args.arg);
				Call_PushString(sarg);
				Call_PushCell(subargs.argnum);
				Call_PushCell(args.variable);
				Call_PushCell(subargs.variable);
				if(Call_Finish(res) != SP_ERROR_NONE)
				{
					log.Error("Failed to call function callback for arg \"%s\".", args.arg);
					res = ARG_PARSE_FAILED_SILENT;
				}
			}
		}
		
		return res;
	}
	
	public ARG_PARSE ParseSubArg(const char arg[ARGS_MAX_ARG_BUFF], int& subargnum)
	{
		int customargused;
		Args_t subargs, customargs;
		ARG_PARSE res;
		for(int i = 0; i < this.Length; i++)
		{
			this.GetArray(i, subargs, sizeof(Args_t));
			
			if(this.IsSpecialArg(subargs.arg))
			{
				customargused++;
				customargs = subargs;
				continue;
			}
			
			if(StrEqual(arg, subargs.arg))
			{
				if(subargs.textbuff[0] != '\0' && !this.Silent)
					log.Info(subargs.textbuff);
				
				if(subargs.argcallback != INVALID_FUNCTION)
					res = this.CallCallBack(ARG_SUBARG, subargs, .sarg = arg);
				
				if(res == ARG_PARSE_OK)
					res = subargs.rettype;
				
				subargnum = i;
				return res;
			}
		}
		
		if(customargused > 1)
			log.Error("Args setup incorrectly, one of the args has few special args, which is not allowed. Last one will be used!");
		
		if(StrEqual(customargs.arg, "@rawtext"))
		{
			if(customargs.textbuff[0] != '\0' && !this.Silent)
				log.Info(customargs.textbuff);
			
			if(customargs.argcallback != INVALID_FUNCTION)
				res = this.CallCallBack(ARG_SUBARG, customargs, .sarg = arg);
			
			if(res == ARG_PARSE_OK)
				res = customargs.rettype;
			
			subargnum = customargs.argnum;
			return res;
		}
		
		return ARG_PARSE_FAILED;
	}
	
	public ARG_PARSE ParseArg(const char arg[ARGS_MAX_ARG_BUFF], int& counter)
	{
		Args_t args, subargs;
		int subargnum;
		char sarg[ARGS_MAX_ARG_BUFF];
		for(int i = 0; i < this.Length; i++)
		{
			this.GetArray(i, args, sizeof(Args_t));
			
			//Add possibility for special args here too? Fuck that;
			
			if(StrEqual(arg, args.arg))
			{
				if(this.IncludedArgs.FindString(arg) != -1)
				{
					if(!this.Silent)
						log.Info("Duplicate argument found \"%s\".", arg);
					return ARG_PARSE_FAILED_SILENT;
				}
				
				this.IncludedArgs.PushString(arg);
				
				if(args.subargs != null)
				{
					GetCmdArg(++counter, sarg, sizeof(sarg));
					
					//recursion is not possible in methodmaps :(
					ARG_PARSE res = args.subargs.ParseSubArg(sarg, subargnum);
					if(res == ARG_PARSE_FAILED && args.textbuff[0] != '\0')
					{
						if(!this.Silent)
							log.Info(args.textbuff);
						return ARG_PARSE_FAILED_SILENT;
					}
					else if (res == ARG_PARSE_EXIT || res == ARG_PARSE_FAILED_SILENT)
						return res;
					else
					{
						args.subargs.GetArray(subargnum, subargs, sizeof(Args_t));
						
						if(args.argcallback != INVALID_FUNCTION)
							res = this.CallCallBack(ARG_ARGPLUSSUBARG, args, subargs, sarg);
						
						return res;
					}
				}
				
				if(args.textbuff[0] != '\0' && !this.Silent)
					log.Info(args.textbuff);
				
				ARG_PARSE res;
				
				if(args.argcallback != INVALID_FUNCTION)
					res = this.CallCallBack(ARG_ARG, args);
				
				if(res == ARG_PARSE_OK)
					res = args.rettype;
				
				return res;
			}
		}
		
		return ARG_PARSE_FAILED;
	}
	
	public ARG_PARSE ParseArgs(int argsnum, int wheretostart = 1, bool silent = false)
	{
		char sarg[ARGS_MAX_ARG_BUFF];
		ARG_PARSE ret;
		
		this.Silent = silent;
		this.IncludedArgs = new ArrayList();
		
		for(int i = wheretostart; i <= argsnum; i++)
		{
			GetCmdArg(i, sarg, sizeof(sarg));
			ret = this.ParseArg(sarg, i);
			
			if(ret == ARG_PARSE_FAILED)
			{
				if(!this.Silent)
					log.Info("Unknown argument was passed \"%s\".", sarg);
				
				this.Silent = false;
				return ARG_PARSE_FAILED_SILENT;
			}
			else if(ret == ARG_PARSE_FAILED_SILENT || ret == ARG_PARSE_EXIT)
			{
				this.Silent = false;
				return ret;
			}
		}
		
		this.Silent = false;
		return ret;
	}
	
	public bool IsUsed(const char[] arg)
	{
		return this.IncludedArgs.FindString(arg) != -1;
	}
	
	
	//V1 parser here:
	/*public static ARG_PARSE ParseSortType(char[] buff)
	{
		char copybuff[8];
		strcopy(copybuff, sizeof(copybuff), buff);
		
		if(copybuff[0] != '+' && copybuff[0] != '-')
			g_sortorder = Sort_Ascending;
		else 
		{
			if (copybuff[0] == '+')
				g_sortorder = Sort_Ascending;
			else
				g_sortorder = Sort_Descending;
			
			strcopy(copybuff, sizeof(copybuff), copybuff[1]);
		}
		
		if(StrEqual(copybuff, "pln"))
		{
			g_sortfield = Sort_PluginNames;
			return ARG_PARSE_OK;
		}
		else if (StrEqual(copybuff, "hn"))
		{
			g_sortfield = Sort_HandleNames;
			return ARG_PARSE_OK;
		}
		else if (StrEqual(copybuff, "h"))
		{
			g_sortfield = Sort_Handles;
			return ARG_PARSE_OK;
		}
		else if (StrEqual(copybuff, "m"))
		{
			g_sortfield = Sort_Memory;
			return ARG_PARSE_OK;
		}
		
		return ARG_PARSE_FAILED;
	}
	
	public static ARG_PARSE ParseMemType(char[] buff)
	{
		if(StrEqual(buff, "kb", false))
		{
			g_memtype = MemType_KB;
			return ARG_PARSE_OK;
		}
		else if (StrEqual(buff, "mb", false))
		{
			g_memtype = MemType_MB;
			return ARG_PARSE_OK;
		}
		else if (StrEqual(buff, "gb", false))
		{
			g_memtype = MemType_GB;
			return ARG_PARSE_OK;
		}
		else
			return ARG_PARSE_FAILED;
	}
	
	public static ARG_PARSE ParseArgument(int client, char[] buff, int length, char[] buff2)
	{
		if(StrEqual(buff, "-h"))
		{
			log.Info(SNAME..." All available arguments for sm_checkhandles:\n \
			* -h - print help list;\n \
			* -sh - print sort help list;\n \
			* -th - print all available memory output types;\n \
			* -sd - save handle dump under the directory specified in hdf_handledumps_savefolder cvar;\n \
			* -so <path to file> - save output to a specific file;\n \
			* -c <path to file> - compare currect handle dump to another dump; (You can also use words \"lastsaved\" and \"lastcreated\" to get the appropriate files)\n \
			* -d <path to file> - set different path for raw handle dump;\n \
			* -st <sort type> - set custom sort type;\n \
			* -mt <memory type> - set custom memory output type (eg. KB, MB, GB);");
			
			return ARG_PARSE_EXIT;
		}
		else if(StrEqual(buff, "-sh"))
		{
			log.Info(SNAME..." All available sort types:\n \
			* -[SORT_FIELD] - sort in descending order;\n \
			* +[SORT_FIELD] - sort in ascending order;\n \
			* If no order specified, ascending order will be used as default;\n \
			[SORT_FIELDS]:\n \
			* pln - plugin name;\n \
			* hn - handle name;\n \
			* h - handle count;\n \
			* m - memory count;");
			
			return ARG_PARSE_EXIT;
		}
		else if(StrEqual(buff, "-th"))
		{
			log.Info(SNAME..." All available memory output types:\n \
			* kb - KiloByte;\n \
			* mb - MegaByte;\n \
			* gb - GigaByte;");
			
			return ARG_PARSE_EXIT;
		}
		else if(StrEqual(buff, "-sd"))
		{
			g_eargs |= Args_SaveDump;
			
			return ARG_PARSE_OK;
		}
		else if(StrEqual(buff, "-so"))
		{
			g_eargs |= Args_SaveOutPut;
			strcopy(g_sOutputPath, sizeof(g_sOutputPath), buff2);
			
			return ARG_PARSE_SKIPNEXT;
		}
		else if(StrEqual(buff, "-c"))
		{
			g_eargs |= Args_Compare;
			
			if(StrEqual(buff2, "lastsaved"))
			{
				if(g_sLastSaved[0] == '\0')
				{
					log.Info("There's no lastsaved dump.");
					return ARG_PARSE_FAILED_SILENT;
				}
				else
					strcopy(g_sComparePath, sizeof(g_sComparePath), g_sLastSaved);
			}
			else if(StrEqual(buff2, "lastcreated"))
			{
				if(g_sLastCreated[0] == '\0')
				{
					log.Info("There's no lastcreated dump.");
					return ARG_PARSE_FAILED_SILENT;
				}
				else
					strcopy(g_sComparePath, sizeof(g_sComparePath), g_sLastCreated);
			}
			else
				strcopy(g_sComparePath, sizeof(g_sComparePath), buff2);
			
			return ARG_PARSE_SKIPNEXT;
		}
		else if(StrEqual(buff, "-d"))
		{
			g_eargs |= Args_Destination;
			strcopy(g_sDistPath, sizeof(g_sDistPath), buff2);
			
			return ARG_PARSE_SKIPNEXT;
		}
		else if(StrEqual(buff, "-st"))
		{
			g_eargs |= Args_Sort;
			if(Args.ParseSortType(buff2) == ARG_PARSE_FAILED)
			{
				log.Info("Invalid sort type specified \"%s\"!", buff2);
				return ARG_PARSE_FAILED_SILENT;
			}
			
			return ARG_PARSE_SKIPNEXT;
		}
		else if(StrEqual(buff, "-mt"))
		{
			g_eargs |= Args_MemType;
			if(Args.ParseMemType(buff2) == ARG_PARSE_FAILED)
			{
				log.Info("Invalid memory output type specified \"%s\"!", buff2);
				return ARG_PARSE_FAILED_SILENT;
			}
			
			return ARG_PARSE_SKIPNEXT;
		}
		else
			return ARG_PARSE_FAILED;
	}*/
}
