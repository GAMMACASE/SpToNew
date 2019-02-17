#include "sourcemod"
#define SNAME "[SPTONEW]"

#pragma dynamic 262144
#pragma semicolon 1
#define DEBUG 0

public Plugin myinfo = 
{
	name = "SpToNew",
	author = "GAMMA CASE",
	description = "Updates .sp and .inc files to new sp syntax.",
	version = "0.0.2",
	url = "https://steamcommunity.com/id/_GAMMACASE_/"
}

#include "sptonew/variables.sp"
#include "sptonew/cell.sp"
#include "sptonew/returnhandler.sp"
#include "sptonew/log.sp"
Log log;
#include "sptonew/args.sp"
Args g_args;
#include "sptonew/methodmaps.sp"

public void OnPluginStart()
{
	RegAdminCmd("sm_sptonew", SM_Sptonew, ADMFLAG_ROOT, "Start converting sp file to new syntax.");
	
	g_cvStackTraceType = CreateConVar("stn_stacktracetype", "0", "Stack trace type: 0 - Last function in stack trace; 1 - Full stack trace;", .hasMin = true, .hasMax = true, .max = 1.0);
	g_cvStackTrace = CreateConVar("stn_stacktrace", "1", "Create stack trace for error and debug log messages;", .hasMin = true, .hasMax = true, .max = 1.0);
	g_cvLogLevel = CreateConVar("stn_loglevel", "3", "Log level: 0 - None; 1 - Normal; 2 - Error; 3 - Debug;", .hasMin = true, .hasMax = true, .max = 3.0);
	g_cvOutputPostfix = CreateConVar("stn_outputpostfix", "_new", "Postfix that will be used as a default for output file;");
	g_cvLogLevel.AddChangeHook(CVHook_LogLevel);
	AutoExecConfig();
	
	log = Log(view_as<LogLevel>(g_cvLogLevel.IntValue));
	
	g_args = new Args();
	SetupArguments();
}

void SetupArguments()
{
	g_args.SetupArg("-h", ARG_PARSE_EXIT, .argcallback = ARG_Help_CB);
	Args subargs = new Args();
	subargs.SetupArg("@rawtext");
	g_args.SetupArg("-o", .argcallback = ARG_Outputfile_CB, .subargs = subargs);
}

public ARG_PARSE ARG_Outputfile_CB(const char[] parsedArg, const char[] parsedSubArg, int subArgNum)
{
	strcopy(g_sOutputPath, sizeof(g_sOutputPath), parsedSubArg);
}

public ARG_PARSE ARG_Help_CB(const char[] parsedArg)
{
	log.Info("All available arguments for sm_sptonew:\n \
			* -h - print help list;\n \
			* -o <pathtofile> - use different location for output file; (Note: It does not create folders.)");
}

public void CVHook_LogLevel(ConVar convar, const char[] oldValue, const char[] newValue)
{
	log.Level = view_as<LogLevel>(convar.IntValue);
}

public Action SM_Sptonew(int client, int args)
{
	if(args < 1 && g_args.ParseArgs(1, .silent = true) != ARG_PARSE_EXIT)
	{
		log.Info("Wrong number of parameters were passed, usage: sm_sptonew <pathtospfile> [additional arguments, use -h for help.]");
		return Plugin_Handled;
	}
	
	if(g_bisInProcess)
	{
		log.Info("Plugin already in progress, please wait...");
		return Plugin_Handled;
	}
	
	if(g_args.ParseArgs(args, 2) != ARG_PARSE_OK)
		return Plugin_Handled;
	
	Return ret = new Return();
	char path[PLATFORM_MAX_PATH], outpath[PLATFORM_MAX_PATH], postfix[PLATFORM_MAX_PATH];
	int pos;
	g_bisInProcess = true;
	
	GetCmdArg(1, path, sizeof(path));
	
	g_spFile = new SPFile(path);
	if(ret.Register(g_spFile) == -1)
	{
		log.Info("Wrong or incorrect file specified. Can't read from \"%s\".", path);
		return ret.Handle(Plugin_Handled, g_bisInProcess, false);
	}
	
	if(g_args.IsUsed("-o"))
		outpath = g_sOutputPath;
	else
	{
		outpath = path;
		pos = FindCharInString(outpath, '.', true);
		
		if(pos != -1 && (pos > FindCharInString(outpath, '/', true) || pos > FindCharInString(outpath, '\\', true)))
			outpath[pos] = '\0';
		
		g_cvOutputPostfix.GetString(postfix, sizeof(postfix));
		Format(outpath, sizeof(outpath), "%s%s.sp", outpath, postfix);
	}
	
	SPFile spoutfile = new SPFile(outpath, true);
	if(ret.Register(spoutfile) == -1)
	{
		log.Info("Wrong or incorrect output file specified. Can't write to \"%s\".", outpath);
		return ret.Handle(Plugin_Handled, g_bisInProcess, false);
	}
	
	//spfile.Preprocessline();
	g_spFile.Parse(spoutfile);
	
	return ret.Handle(Plugin_Handled, g_bisInProcess, false);
}