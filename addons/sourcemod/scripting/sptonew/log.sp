#define LOG_MAX_MSG_BUFF 1024
#define LOG_MAX_TRACE_BUFF 256

enum LogLevel 
{
	LL_None = 0,
	LL_Normal = 1,
	LL_Error,
	LL_Debug
}

stock static LogLevel g_loglevel;
stock static int g_iclientUserId;
stock static bool g_bisNewSM;

methodmap Log
{
	//Check log feature for FrameIterator
	public static void __CheckSM()
	{
		ConVar cvSMVer = FindConVar("sourcemod_version");
		
		if(cvSMVer != null)
		{
			char sver[4][8], buff[32];
			int ver[2];
			
			cvSMVer.GetString(buff, sizeof(buff));
			if(ExplodeString(buff, ".", sver, 4, 8) == 4)
			{
				ver[0] = StringToInt(sver[1]);
				ver[1] = StringToInt(sver[3]);
				
				if((ver[0] == 9 && ver[1] >= 6274) || (ver[0] == 10 && ver[1] >= 6378) || ver[0] > 10)
					g_bisNewSM = true;
			}
			
			delete cvSMVer;
		}
	}
	
	public Log(LogLevel lvl = LL_Error)
	{
		Log.__CheckSM();
		g_loglevel = lvl;
	}
	
	property int Client
	{
		public get() { return GetClientOfUserId(g_iclientUserId); }
		public set(int client) { g_iclientUserId = (client > 0 && client <= MaxClients ? GetClientUserId(client) : 0); }
	}
	
	property LogLevel Level
	{
		public get() { return g_loglevel; }
		public set(LogLevel lvl) { g_loglevel = lvl; }
	}
	
	property bool __FIUsage
	{
		public get() { return g_bisNewSM; }
	}
	
	public void __GetStackTrace(char[] trace, int length)
	{
		if(!g_cvStackTrace.BoolValue)
			return;
		
		FrameIterator fi = new FrameIterator();
		char fname[64];
		int counter;
		
		fi.Next();
		fi.Next();
		
		if(this.__FIUsage)
		{
			while(fi.Next())
			{
				fi.GetFunctionName(fname, sizeof(fname));
				if(fname[0] == '\0')
					continue;
				
				Format(trace, length, "%s%s%s", trace, (!counter ? "" : " <- "), fname);
				
				counter++;
			}
		}
		else
		{
			if(fi.Next())
			{
				fi.GetFunctionName(fname, sizeof(fname));
				strcopy(trace, length, fname);
			}
		}
		
		Format(trace, length, "[%s]", trace);
		
		delete fi;
	}
	
	public void Info(const char[] text, any ...)
	{
		if(this.Level < LL_Normal)
			return;
		
		char buff[LOG_MAX_MSG_BUFF];
		VFormat(buff, sizeof(buff), text, 3);
		
		ReplyToCommand(this.Client, SNAME..." %s", buff);
	}
	
	public void Error(const char[] text, any ...)
	{
		if(this.Level < LL_Error)
			return;
		
		char buff[LOG_MAX_MSG_BUFF];
		VFormat(buff, sizeof(buff), text, 3);
		
		char trace[LOG_MAX_TRACE_BUFF];
		this.__GetStackTrace(trace, sizeof(trace));
		LogError("%s %s", trace, buff);
	}
	
	public void Debug(const char[] text, any ...)
	{
		if(this.Level < LL_Debug)
			return;
		
		char buff[LOG_MAX_MSG_BUFF];
		VFormat(buff, sizeof(buff), text, 3);
		
		char trace[LOG_MAX_TRACE_BUFF];
		this.__GetStackTrace(trace, sizeof(trace));
		LogMessage("[DEBUG] %s %s", trace, buff);
	}
}