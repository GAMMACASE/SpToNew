#define sLINEMAX 4095
#define TOKEN_STR_MAX 128
#define MAX_TOKEN_DEPTH 4
#define sNAMEMAX 63
#define METHOD_NAMEMAX sNAMEMAX * 2 + 6
#define sDEF_LITMAX 500		/* initial size of the literal pool, in "cells" */

#define PUBLIC_CHAR	'@'		/* character that defines a function "public" */
#define CTRL_CHAR	'\\'		/* default control character */
#define sCHARBITS	8			/* size of a packed character */

/* flags for litchar() */
#define RAWMODE		0x1
#define UTF8MODE	0x2
#define ISPACKED	0x4

#define FALSE	0
#define TRUE	1

#define NULL 0

public bool sLiteralQueueDisabled = false;
public const char sc_ctrlchar = '\\';
public const char sc_tokens[][] = {
				 "*=", "/=", "%=", "+=", "-=", "<<=", ">>>=", ">>=", "&=", "^=", "|=",
				 "||", "&&", "==", "!=", "<=", ">=", "<<", ">>>", ">>", "++", "--",
				 "...", "..", "::",
				 "acquire",
				 "as",
				 "assert",
				 "break",
				 "builtin",
				 "catch",
				 "case",
				 "cast_to",
				 "cellsof",
				 "char",
				 "const",
				 "continue",
				 "decl",
				 "default",
				 "defined",
				 "delete",
				 "do",
				 "double",
				 "else",
				 "enum",
				 "exit",
				 "explicit",
				 "finally",
				 "for",
				 "foreach",
				 "forward",
				 "funcenum",
				 "functag",
				 "function",
				 "goto",
				 "if",
				 "implicit",
				 "import",
				 "in",
				 "int",
				 "int8",
				 "int16",
				 "int32",
				 "int64",
				 "interface",
				 "intn",
				 "let",
				 "methodmap",
				 "namespace",
				 "native",
				 "new",
				 "null",
				 "__nullable__",
				 "object",
				 "operator",
				 "package",
				 "private",
				 "protected",
				 "public",
				 "readonly",
				 "return",
				 "sealed",
				 "sizeof",
				 "static",
				 "stock",
				 "struct",
				 "switch",
				 "tagof",
				 "this",
				 "throw",
				 "try",
				 "typedef",
				 "typeof",
				 "typeset",
				 "uint8",
				 "uint16",
				 "uint32",
				 "uint64",
				 "uintn",
				 "union",
				 "using",
				 "var",
				 "variant",
				 "view_as",
				 "virtual",
				 "void",
				 "volatile",
				 "while",
				 "with",
				 "#assert", "#define", "#else", "#elseif", "#endif", "#endinput",
				 "#endscript", "#error", "#warning", "#file", "#if", "#include",
				 "#line", "#pragma", "#tryinclude", "#undef",
				 ";", ";", "-integer value-", "-rational value-", "-identifier-",
				 "-label-", "-string-", "-string-"
};

enum //TokenKind 
{
	/* value of first multi-character operator */
	tFIRST		 = 256,
	/* multi-character operators */
	taMULT		 = tFIRST, /* *= */
	taDIV,		 /* /= */
	taMOD,		 /* %= */
	taADD,		 /* += */
	taSUB,		 /* -= */
	taSHL,		 /* <<= */
	taSHRU,		/* >>>= */
	taSHR,		 /* >>= */
	taAND,		 /* &= */
	taXOR,		 /* ^= */
	taOR,			/* |= */
	tlOR,			/* || */
	tlAND,		 /* && */
	tlEQ,			/* == */
	tlNE,			/* != */
	tlLE,			/* <= */
	tlGE,			/* >= */
	tSHL,			/* << */
	tSHRU,		 /* >>> */
	tSHR,			/* >> */
	tINC,			/* ++ */
	tDEC,			/* -- */
	tELLIPS,	 /* ... */
	tDBLDOT,	 /* .. */
	tDBLCOLON, /* :: */
	/* value of last multi-character operator */
	tMIDDLE		= tDBLCOLON,
/* reserved words (statements) */
	tACQUIRE,
	tAS,
	tASSERT,
	tBREAK,
	tBUILTIN,
	tCATCH,
	tCASE,
	tCAST_TO,
	tCELLSOF,
	tCHAR,
	tCONST,
	tCONTINUE,
	tDECL,
	tDEFAULT,
	tDEFINED,
	tDELETE,
	tDO,
	tDOUBLE,
	tELSE,
	tENUM,
	tEXIT,
	tEXPLICIT,
	tFINALLY,
	tFOR,
	tFOREACH,
	tFORWARD,
	tFUNCENUM,
	tFUNCTAG,
	tFUNCTION,
	tGOTO,
	tIF,
	tIMPLICIT,
	tIMPORT,
	tIN,
	tINT,
	tINT8,
	tINT16,
	tINT32,
	tINT64,
	tINTERFACE,
	tINTN,
	tLET,
	tMETHODMAP,
	tNAMESPACE,
	tNATIVE,
	tNEW,
	tNULL,
	tNULLABLE,
	tOBJECT,
	tOPERATOR,
	tPACKAGE,
	tPRIVATE,
	tPROTECTED,
	tPUBLIC,
	tREADONLY,
	tRETURN,
	tSEALED,
	tSIZEOF,
	tSTATIC,
	tSTOCK,
	tSTRUCT,
	tSWITCH,
	tTAGOF,
	tTHIS,
	tTHROW,
	tTRY,
	tTYPEDEF,
	tTYPEOF,
	tTYPESET,
	tUINT8,
	tUINT16,
	tUINT32,
	tUINT64,
	tUINTN,
	tUNION,
	tUSING,
	tVAR,
	tVARIANT,
	tVIEW_AS,
	tVIRTUAL,
	tVOID,
	tVOLATILE,
	tWHILE,
	tWITH,
	/* compiler directives */
	tpASSERT,		 /* #assert */
	tpDEFINE,
	tpELSE,			 /* #else */
	tpELSEIF,		 /* #elseif */
	tpENDIF,
	tpENDINPUT,
	tpENDSCRPT,
	tpERROR,
	tpWARNING,
	tpFILE,
	tpIF,				 /* #if */
	tINCLUDE,
	tpLINE,
	tpPRAGMA,
	tpTRYINCLUDE,
	tpUNDEF,
	tLAST = tpUNDEF,	 /* value of last multi-character match-able token */
	/* semicolon is a special case, because it can be optional */
	tTERM,					/* semicolon or newline */
	tENDEXPR,			 /* forced end of expression */
	/* other recognized tokens */
	tNUMBER,				/* integer number */
	tRATIONAL,			/* rational number */
	tSYMBOL,
	tLABEL,
	tSTRING,
	tPENDING_STRING, 	/* string, but not yet dequeued (NOTE: Unused)*/
	tEXPR,					/* for assigment to "lastst" only (see SC1.C) */
	tENDLESS,			 /* endless loop, for assigment to "lastst" only */
	tEMPTYBLOCK,		/* empty blocks for AM bug 4825 */
	tEOL,					 /* newline, only returned by peek_new_line() */
	tNEWDECL,			 /* for declloc() */
	tLAST_TOKEN_ID
};

enum 
{
	CMD_NONE = 0,
	CMD_TERM = 1,
	CMD_EMPTYLINE,
	CMD_CONDFALSE,
	CMD_INCLUDE,
	CMD_DEFINE,
	CMD_IF,
	CMD_DIRECTIVE
};

enum cell {}; //int32_t : int;

enum struct token_t
{
	int id;
	cell val;
	char str[TOKEN_STR_MAX];
}

enum struct token_pos_t
{
	int line;
	int col;
};

enum struct token_ident_t
{
	token_t tok;
	char name[METHOD_NAMEMAX + 1];
};

enum struct full_token_t
{
	int id;
	int value;
	char_t str;
	int len;
	token_pos_t start;
	token_pos_t end;
};

enum struct token_buffer_t
{
	// Total number of tokens parsed.
	int num_tokens;
	
	// Number of tokens that we've rewound back to.
	int depth;
	
	// Most recently fetched token.
	int cursor;
	
	// Circular token buffer.
	//full_token_t tokens[MAX_TOKEN_DEPTH]; ERROR: Enum struct fields cannot have more that one dimension :(
	ArrayList tokens; //HACK;
};

//Simulating *cell;
/*enum struct cell_t
{
	cell val;
	int pos;
}*/

//Simulating *char;
enum struct char_t
{
	char buff[sLINEMAX];
	int pos;
}

token_buffer_t g_sNormalBuffer;
token_buffer_t g_sPreprocessBuffer;
token_buffer_t g_sTokenBuffer;

ConVar g_cvLogLevel,
	g_cvOutputPostfix,
	g_cvStackTrace;

bool g_bisInProcess,
	g_bisReading,
	g_bComment,
	g_bLexNewline;

char g_sOutputPath[PLATFORM_MAX_PATH];

char_t g_sInpLine,				/* points to the current position in "g_spLine" */
	g_spLine;					/* the line read from the input file */

int g_bStmtIndent,				/* current indent of the statement */
	sc_tabsize = 8,				/* assume a TAB is 8 spaces */
	g_ifLine,					/* the line number in the current file */
	g_iLitidx,					/* index to literal table */
	sc_packstr = TRUE,			/* strings are packed by default? */
	g_iglbstringread;			/* last global string read */
//	g_iLitmax = sDEF_LITMAX;	/* current size of the literal table */

//cell g_litq[sDEF_LITMAX * 4];		// the literal queue (sizeof(cell) : cell : int32_t : int : 4 bytes)
ArrayList g_litq;					//HACK: Using ArrayList instead normal dynamic array.
