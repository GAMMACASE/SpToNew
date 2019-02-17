methodmap Util
{
	public static int strncopy(char[] dest, int destlen, char[] source, int lentocopy)
	{
		int srclen = strlen(source);
		
		if(srclen < lentocopy)
			lentocopy = srclen;
		
		if(destlen < lentocopy)
			lentocopy = destlen - 1;
		
		for(int i = 0; i < lentocopy; i++)
			dest[i] = source[i];
		
		dest[lentocopy] = '\0';
		
		return lentocopy;
	}
	
	public static int strchr(char[] buff, int symbol)
	{
		int i;
		
		do
		{
			if(buff[i] == symbol)
				return i;
		} while(buff[i++]);
		
		return -1;
	}
	
	public static int ishex(char c)
	{
		return (c >= '0' && c <= '9') || (c >= 'a' && c <= 'f') || (c >= 'A' && c <= 'F');
	}
	
	public static int alphanum(char c)
	{
		return (IsCharAlpha(c) || IsCharNumeric(c));
	}
	
	public static int isoctal(char c)
	{
		return (c >= '0' && c <= '7');
	}
	
	public static void chk_grow_litq()
	{
		#if 0 //TODO: (pure c++) Do not think it's still needed since I use ArrayList;
		if (g_iLitidx >= g_iLitmax)
		{
			cell *p;
			
			g_iLitmax += sDEF_LITMAX;
			p = (cell *)realloc(litq,g_iLitmax*sizeof(cell));
			litq = p;
		}
		#endif
	}
	
	public static void litinsert(cell value, int pos)
	{
		Util.chk_grow_litq();
		g_litq.ShiftUp(pos); //memmove(litq+(pos+1),litq+pos,(litidx-pos)*sizeof(cell));
		g_iLitidx++;
		g_litq.Set(pos, value);
	}
	
	public static void litadd(cell value)
	{
		Util.chk_grow_litq();
		g_iLitidx++;
		g_litq.Push(value);
	}
	
	public static cell get_utf8_char(char string, char& endptr)
	{
		int follow,
			lowmark; //long;
		char ch;
		cell result;
		
		if (endptr != NULL)
			endptr = string;
		
		for (;;)
		{
			ch = string++;
			
			if (follow > 0 && (ch & 0xc0) == 0x80)
			{
				result = (result << view_as<cell>(6)) | view_as<cell>((ch & 0x3f));
				if ( --follow == 0)
				{
					if (result < lowmark)
						return view_as<cell>(-1);
					
					if ((result >= 0xd800 && result <= 0xdfff) || result == 0xfffe || result == 0xffff)
						return view_as<cell>(-1);
				}
				
				break;
			} else if (follow == 0 && (ch & 0x80) == 0x80)
			{
				/* UTF-8 leader code */
				if ((ch & 0xe0) == 0xc0)
				{
					/* 110xxxxx 10xxxxxx */
					follow = 1;
					lowmark = 0x80;
					result = ch & 0x1f;
				}
				else if ((ch & 0xf0) == 0xe0)
				{
					/* 1110xxxx 10xxxxxx 10xxxxxx (16 bits, BMP plane) */
					follow = 2;
					lowmark = 0x800;
					result = ch & 0x0f;
				}
				else if ((ch & 0xf8) == 0xf0)
				{
					/* 11110xxx 10xxxxxx 10xxxxxx 10xxxxxx */
					follow = 3;
					lowmark = 0x10000;
					result = ch & 0x07;
				} 
				else if ((ch & 0xfc) == 0xf8)
				{
					/* 111110xx 10xxxxxx 10xxxxxx 10xxxxxx 10xxxxxx */
					follow = 4;
					lowmark = 0x200000;
					result = ch & 0x03;
				}
				else if ((ch & 0xfe) == 0xfc)
				{
					/* 1111110x 10xxxxxx 10xxxxxx 10xxxxxx 10xxxxxx 10xxxxxx (32 bits) */
					follow = 5;
					lowmark = 0x4000000;
					result = ch & 0x01;
				}
				else
					/* this is invalid UTF-8 */
					return view_as<cell>(-1);
				
			}
			else if (follow == 0 && (ch & 0x80) == 0x00)
			{
				/* 0xxxxxxx (US-ASCII) */
				result = ch;
				break;
			}
			else
				/* this is invalid UTF-8 */
				return view_as<cell>(-1);
			
		}
		
		if (endptr != NULL)
			endptr = string;
		return result;
	}
	
	public static cell litchar(char_t lptr, int flags)
	{
		cell c;
		char cptr;
		
		cptr = lptr.buff[lptr.pos];
		if ((flags & RAWMODE) != 0 || cptr != sc_ctrlchar)
		{
				if ((flags & UTF8MODE) != 0)
					c = Util.get_utf8_char(cptr, cptr);
				else
				{
					c = cptr;
					cptr++;
				}
		}
		else
		{
			cptr++;
			if (cptr == sc_ctrlchar)
			{
				c = cptr;
				cptr++;
			}
			else
			{
				switch (cptr)
				{
					case 'a':
					{
						c = 7;
						cptr++;
					}
					
					case 'b':
					{
						c = 8;
						cptr++;
					}
					
					case 'e':
					{
						c = 27;
						cptr ++;
					}
					
					case 'f':
					{
						c = 12;
						cptr++;
					}
					
					case 'n':
					{
						c = 10;
						cptr++;
					}
					
					case 'r':
					{
						c = 13;
						cptr++;
					}
					
					case 't':
					{
						c = 9;
						cptr++;
					}
					
					case 'v':
					{
						c = 11;
						cptr++;
					}
					
					case 'x':
					{
						int digits = 0;
						cptr++;
						c = 0;
						while (Util.ishex(cptr) && digits < 2)
						{
							if (IsCharNumeric(cptr))
								c = (c << view_as<cell>(4)) + (cptr - '0');
							else
								c = (c << view_as<cell>(4)) + (CharToLower(cptr) - 'a' + 10);
							cptr++;
							digits++;
						}
						
						if (cptr == ';')
							cptr++;
					}
					
					case '\'', '"', '%':
					{
						c = cptr;
						cptr++;
					}
					
					default:
					{
						if (IsCharNumeric(cptr))
						{
							c = 0;
							while (cptr >= '0' && cptr <= '9')
								c = c * 10 + cptr++ - '0';
							
							if (cptr == ';')
								cptr++;
						}
					}
				}
			}
		}
		
		lptr.buff[lptr.pos] = cptr;
		return c;
	}
	
	//Hacky workaround for sp; HACK:
	//Actually I don't do any conversion, just checking if the float number is typed correctly, and then using StringToFloat() as a conversion method.
	//Hope that don't mess things up;
	public static int ftoi(cell& val, char_t curptr)
	{
		char_t ptr;
		ptr = curptr;
		
		if (!IsCharNumeric(ptr.buff[ptr.pos]))
			return 0;
		
		while (IsCharNumeric(ptr.buff[ptr.pos]) || ptr.buff[ptr.pos] == '_')
			ptr.pos++;
		
		if (ptr.buff[ptr.pos] != '.')
			return 0;
		
		ptr.pos++;
		if (!IsCharNumeric(ptr.buff[ptr.pos]))
			return 0;
		
		while (IsCharNumeric(ptr.buff[ptr.pos]) || ptr.buff[ptr.pos] == '_')
			ptr.pos++;
		
		if (ptr.buff[ptr.pos] == 'e')
		{
			ptr.pos++;
			if (ptr.buff[ptr.pos] == '-')
				ptr.pos++;
			
			if (!IsCharNumeric(ptr.buff[ptr.pos]))
				return 0;
			
			while (IsCharNumeric(ptr.buff[ptr.pos]))
				ptr.pos++;
		}
		
		char num[128];
		int diff = ptr.pos - curptr.pos;
		Util.strncopy(num, sizeof(num), ptr.buff[ptr.pos - diff - 1], diff + 1);
		
		val = StringToFloat(num);
		
		return diff;
		
	}
	
	public static int htoi(cell& val, char_t curptr)
	{
		char_t ptr;
		
		val = 0;
		ptr = curptr;
		
		if(!IsCharNumeric(ptr.buff[ptr.pos]))
			return 0;
		
		if(ptr.buff[ptr.pos] == '0' && ptr.buff[ptr.pos + 1] == 'x')
		{
			ptr.pos += 2;
			while (Util.ishex(ptr.buff[ptr.pos]) || ptr.buff[ptr.pos] == '_')
			{
				if (ptr.buff[ptr.pos] != '_')
				{
					val <<= view_as<cell>(4);
					if (IsCharNumeric(ptr.buff[ptr.pos]))
						val += (ptr.buff[ptr.pos] - '0');
					else
						val += (CharToLower(ptr.buff[ptr.pos]) - 'a' + 10);
				}
				ptr.pos++;
			}
		}
		else
			return 0;
		if (Util.alphanum(ptr.buff[ptr.pos]))
			return 0;
		else
			return ptr.pos - curptr.pos;
	}
	
	public static int dtoi(cell& val, char_t curptr)
	{
		char_t ptr;
		
		val = 0;
		ptr=curptr;
		
		if (!IsCharNumeric(ptr.buff[ptr.pos]))
			return 0;
		while (IsCharNumeric(ptr.buff[ptr.pos]) || ptr.buff[ptr.pos] == '_')
		{
			if (ptr.buff[ptr.pos] != '_')
				val = (val * 10) + (ptr.buff[ptr.pos] - '0');
			ptr.pos++;
		}
		if (Util.alphanum(ptr.buff[ptr.pos]))
			return 0;
		if (ptr.buff[ptr.pos] == '.' && IsCharNumeric(ptr.buff[ptr.pos + 1]))
			return 0;
		return ptr.pos - curptr.pos;
	}
	
	public static int otoi(cell& val, char_t curptr)
	{
		char_t ptr;
		
		val = 0;
		ptr = curptr;
		
		if (!IsCharNumeric(ptr.buff[ptr.pos]))
			return 0;
		if (ptr.buff[ptr.pos] == '0' && ptr.buff[ptr.pos + 1] == 'o')
		{
			ptr.pos += 2;
			while (Util.isoctal(ptr.buff[ptr.pos]) || ptr.buff[ptr.pos] == '_')
			{
				if (ptr.buff[ptr.pos] != '_')
					val = (val << view_as<cell>(3)) + (ptr.buff[ptr.pos] - '0');
				ptr.pos++;
			}
		}
		else
			return 0;
		if (Util.alphanum(ptr.buff[ptr.pos]))
			return 0;
		else
			return ptr.pos - curptr.pos;
	}
	
	public static int btoi(cell& val, char_t curptr)
	{
		char_t ptr;
		
		val = 0;
		ptr = curptr;
		
		if (ptr.buff[ptr.pos] == '0' && ptr.buff[ptr.pos + 1] == 'b')
		{
			ptr.pos += 2;
			while (ptr.buff[ptr.pos] == '0' || ptr.buff[ptr.pos] == '1' || ptr.buff[ptr.pos] == '_')
			{
				if (ptr.buff[ptr.pos] != '_')
					val = (val << view_as<cell>(1)) | view_as<cell>((ptr.buff[ptr.pos] - '0'));
				ptr.pos++;
			}
		}
		else
			return 0;
		if (Util.alphanum(ptr.buff[ptr.pos]))
			return 0;
		else
			return ptr.pos - curptr.pos;
	}
	
	public static int number(cell& val, char_t curptr)
	{
		int i;
		cell value;
	
		if ((i = Util.btoi(value, curptr)) != 0			/* binary? */
				|| (i = Util.htoi(value, curptr)) != 0	/* hexadecimal? */
				|| (i = Util.dtoi(value, curptr)) != 0	/* decimal? */
				|| (i = Util.otoi(value, curptr)) != 0)	/* octal? */
		{
			val = value;
			return i;
		} 
		else
			return 0;
	}
	
	//Does not care about documentation comments. TODO: For now it strips them permanently!!!
	public static void StripComments(char_t buffer)
	{
		char_t cbuff;
		
		while(buffer.buff[buffer.pos])
		{
			if (g_bComment)
			{
				if (buffer.buff[buffer.pos] == '*' && buffer.buff[buffer.pos + 1] == '/')
				{
					g_bComment = false;
					buffer.buff[buffer.pos] = ' ';
					buffer.buff[buffer.pos + 1] = ' ';
					buffer.pos += 2;
				}
				else 
				{
					buffer.buff[buffer.pos] = ' ';
					buffer.pos++;
				}
			}
			else
			{
				if (buffer.buff[buffer.pos] == '/' && buffer.buff[buffer.pos + 1] == '*')
				{
					g_bComment = true;
					buffer.buff[buffer.pos] = ' ';
					buffer.buff[buffer.pos + 1] = ' ';
					buffer.pos += 2;
				}
				else if (buffer.buff[buffer.pos] == '/' && buffer.buff[buffer.pos + 1] == '/')
				{
					buffer.buff[buffer.pos++] = '\n';
					buffer.buff[buffer.pos] = '\0';
				}
				else
				{
					if (buffer.buff[buffer.pos] == '\"' || buffer.buff[buffer.pos] == '\'')
					{
						cbuff = buffer;
						buffer.pos++;
						
						while (buffer.buff[buffer.pos] != cbuff.buff[cbuff.pos] && buffer.buff[buffer.pos] != '\0')
						{
							if (buffer.buff[buffer.pos] == sc_ctrlchar && buffer.buff[buffer.pos + 1] != '\0')
								buffer.pos++;
							buffer.pos++;
						}
						
						buffer.pos++;
					}
					else
						buffer.pos++;
				}
			}
		}
	}
}

//TODO: Should probably rename it to Lexer?
methodmap Parser
{
	public static bool LexNumber(full_token_t tok, cell& lexvalue)
	{
		int i;
		if ((i = Util.number(view_as<cell>(tok.value), g_sInpLine)))
		{
			tok.id = tNUMBER;
			lexvalue = tok.value;
			g_sInpLine.pos += i;
			return true;
		}
		
		if ((i = Util.ftoi(view_as<cell>(tok.value), g_sInpLine)))
		{
			tok.id = tRATIONAL;
			lexvalue = tok.value;
			g_sInpLine.pos += i;
			return true;
		}
		return false;
	}
	
	public static bool LexMatchChar(char c)
	{
		if (g_sInpLine.buff[g_sInpLine.pos] != c)
			return false;
		
		g_sInpLine.pos++;
		return true;
	}
	
	public static any UnpackedString(char_t lptr, int flags)
	{
		while (lptr.buff[lptr.pos] != '\"' && lptr.buff[lptr.pos] != '\0')
		{
			if (lptr.buff[lptr.pos] == '\a')
			{
				lptr.pos++;
				continue;
			}
			
			Util.litadd(Util.litchar(lptr, flags | UTF8MODE));
		}
		
		Util.litadd(0);
		return lptr;
	}
	
	public static any PackedString(char_t lptr, int flags)
	{
		int i; 
		cell val, c; //ucell
		
		g_iglbstringread = 1;
		while (lptr.buff[lptr.pos] != '\"' && lptr.buff[lptr.pos] != '\0')
		{
			if (lptr.buff[lptr.pos] == '\a')
			{
				lptr.pos++;
				continue;
			}
			
			c = Util.litchar(lptr, flags);
			
			val |= (c << view_as<cell>(8 * i));
			g_iglbstringread++;
			
			if (i == 4 - (sCHARBITS / 8)) //sizeof(ucell) (ucell : uint32_t : unsigned long int : 4 bytes)
			{
				Util.litadd(val);
				val = 0;
				i = 0;
			}
			else
				i++;
		}
		
		if (i != 0)
			Util.litadd(val);
		else
			Util.litadd(0);
		return lptr;
	}
	
	public static int ScanEllipsis(char_t lptr)
	{
		#if 0 //TODO: (pure c++)
		static void *inpfmark=NULL;
		unsigned char *localbuf;
		short localcomment,found;
	
		/* first look for the ellipsis in the remainder of the string */
		while (*lptr<=' ' && *lptr!='\0')
			lptr++;
		if (lptr[0]=='.' && lptr[1]=='.' && lptr[2]=='.')
			return 1;
		if (*lptr!='\0')
			return 0;					 /* stumbled on something that is not an ellipsis and not white-space */
	
		/* the ellipsis was not on the active line, read more lines from the current
		 * file (but save its position first)
		 */
		if (inpf==NULL || pc_eofsrc(inpf))
			return 0;					 /* quick exit: cannot read after EOF */
		if ((localbuf=(unsigned char*)malloc((sLINEMAX+1)*sizeof(unsigned char)))==NULL)
			return 0;
		inpfmark=pc_getpossrc(inpf);
		localcomment=icomment;
	
		found=0;
		/* read from the file, skip preprocessing, but strip off comments */
		while (!found && pc_readsrc(inpf,localbuf,sLINEMAX)!=NULL) {
			stripcom(localbuf);
			lptr=localbuf;
			/* skip white space */
			while (*lptr<=' ' && *lptr!='\0')
				lptr++;
			if (lptr[0]=='.' && lptr[1]=='.' && lptr[2]=='.')
				found=1;
			else if (*lptr!='\0')
				break;											 /* stumbled on something that is not an ellipsis and not white-space */
		} /* while */
	
		/* clean up & reset */
		free(localbuf);
		pc_resetsrc(inpf,inpfmark);
		icomment=localcomment;
		return found;
		#endif
		return 0;
	}
	
	public static void LexStringLiteral(full_token_t tok, cell& lexvalue)
	{
		if (sLiteralQueueDisabled)
		{
			tok.id = tPENDING_STRING;
			tok.end = tok.start;
			return;
		}
		
		int stringflags, segmentflags;
		char_t cat;
		tok.id = tSTRING;
		lexvalue = tok.value = g_iLitidx;
		tok.str.buff[0] = '\0';
		stringflags = -1;
		
		for (;;)
		{
			if(g_sInpLine.buff[g_sInpLine.pos] == '!')
				segmentflags = (g_sInpLine.buff[g_sInpLine.pos + 1] == sc_ctrlchar) ? RAWMODE | ISPACKED : ISPACKED;
			else if (g_sInpLine.buff[g_sInpLine.pos] == sc_ctrlchar)
				segmentflags = (g_sInpLine.buff[g_sInpLine.pos + 1] == '!') ? RAWMODE | ISPACKED : RAWMODE;
			else
				segmentflags = 0;
			
			if ((segmentflags & ISPACKED) != 0)
				g_sInpLine.pos++;
			if ((segmentflags & RAWMODE) != 0)
				g_sInpLine.pos++;
			
			g_sInpLine.pos++;
			if (stringflags == -1)
				stringflags = segmentflags;
			
			cat.buff = tok.str.buff;
			cat.pos = Util.strchr(tok.str.buff, '\0');
			
			while (g_sInpLine.buff[g_sInpLine.pos] != '\"' && g_sInpLine.buff[g_sInpLine.pos] != '\0' && (cat.pos - tok.str.pos) < sLINEMAX)
			{
				if (g_sInpLine.buff[g_sInpLine.pos] != '\a')
				{
					cat.buff[cat.pos++] = g_sInpLine.buff[g_sInpLine.pos];
					if (g_sInpLine.buff[g_sInpLine.pos] == sc_ctrlchar && g_sInpLine.buff[g_sInpLine.pos + 1] != '\0')
						cat.buff[cat.pos++]=g_sInpLine.buff[++g_sInpLine.pos];
				}
				g_sInpLine.pos++;
			}
			
			cat.buff[cat.pos] = '\0';
			tok.len = cat.pos - tok.str.pos;
			if (g_sInpLine.buff[g_sInpLine.pos] == '\"')
				g_sInpLine.pos++;
			
			if (!Parser.ScanEllipsis(g_sInpLine))
				break;
			
			while (g_sInpLine.buff[g_sInpLine.pos] <= ' ')
			{
				if (g_sInpLine.buff[g_sInpLine.pos] == '\0')
					PreprocessInLex();
				else
					g_sInpLine.pos++;
			}
			
			g_sInpLine.pos += 3;
			
			while (g_sInpLine.buff[g_sInpLine.pos] <= ' ')
			{
				if (g_sInpLine.buff[g_sInpLine.pos] == '\0')
					PreprocessInLex();
				else
					g_sInpLine.pos++;
			}
			
			if (!g_bisReading || !(g_sInpLine.buff[g_sInpLine.pos] == '\"'))
				break;
		}
		
		if (sc_packstr)
			stringflags ^= ISPACKED;
		
		//HACK: Can't pass it normally, array sizes do not match, or destination array is too small.
		char_t tempstr;
		//tempstr = tok.str; //Can't assign it like that: array must be indexed error.
		tempstr.buff = tok.str.buff;
		tempstr.pos = tok.str.pos;
		
		if ((stringflags & ISPACKED) != 0)
			Parser.PackedString(tempstr, stringflags);
		else
			Parser.UnpackedString(tempstr, stringflags);
		
		tok.str.buff = tempstr.buff;
		tok.str.pos = tempstr.pos;
	}
	
	public static int LexKeywordImpl(char_t match, int length)
	{
		int val;
		char buff[sNAMEMAX];
		
		Util.strncopy(buff, sizeof(buff), match.buff[match.pos], length);
		g_sKeywords.GetValue(buff, val);
		
		return val;
	}
	
	public static bool IsUnimplementedKeyword(int token)
	{
		switch (token)
		{
			case tACQUIRE, tAS, tCATCH, tCAST_TO, tDOUBLE, tEXPLICIT, tFINALLY, 
			tFOREACH, tIMPLICIT, tIMPORT, tIN, tINT8, tINT16, tINT32, tINT64, 
			tINTERFACE, tINTN, tLET, tNAMESPACE, tPACKAGE, tPRIVATE, tPROTECTED, 
			tREADONLY, tSEALED, tTHROW, tTRY, tTYPEOF, tUINT8, tUINT16, tUINT32, 
			tUINT64, tUINTN, tUNION, tVAR, tVARIANT, tVIRTUAL, tVOLATILE, tWITH:
			{
				return true;
			}
			
			default:
			{
				return false;
			}
		}
	}
	
	public static void GetTokenString(int tok_id, char[] token, int length)
	{
		strcopy(token, length, sc_tokens[tok_id - tFIRST]);
	}
	
	public static bool LexKeyword(full_token_t tok, char_t token_start)
	{
		int tok_id = Parser.LexKeywordImpl(token_start, tok.len);
		if (!tok_id)
			return false;
		
		if (Parser.IsUnimplementedKeyword(tok_id))
		{
			tok.id = tSYMBOL;
			Parser.GetTokenString(tok_id, tok.str.buff, sizeof(char_t::buff));
			tok.len = strlen(tok.str.buff);
		}
		else if (g_sInpLine.buff[g_sInpLine.pos] == ':' && (tok_id == tINT || tok_id == tVOID))
		{
			g_sInpLine.pos++;
			tok.id = tLABEL;
			Parser.GetTokenString(tok_id, tok.str.buff, sizeof(char_t::buff));
			tok.len = strlen(tok.str.buff);
		}
		else
			tok.id = tok_id;
		
		return true;
	}
	
	public static void LexSymbol(full_token_t tok, char_t token_start)
	{
		Util.strncopy(tok.str.buff, sizeof(char_t::buff), token_start.buff[token_start.pos], tok.len);
		if (tok.len > sNAMEMAX)
		{
			tok.str.buff[sNAMEMAX] = '\0';
			tok.len = sNAMEMAX;
		}
		
		tok.id = tSYMBOL;
		
		if (g_sInpLine.buff[g_sInpLine.pos] == ':' && g_sInpLine.buff[g_sInpLine.pos + 1] != ':')
		{
			if (sc_allowtags)
			{
				tok.id = tLABEL;
				g_sInpLine.pos++;
			}
		}
		else if (tok.len == 1 && token_start.buff[token_start.pos] == '_')
		{
			tok.id = '_';
		}
	}
	
	public static bool LexSymbolOrKeyword(full_token_t tok)
	{
		char_t token_start;
		token_start = g_sInpLine;
		char first_char = g_sInpLine.buff[g_sInpLine.pos];
		
		bool maybe_keyword = (first_char != PUBLIC_CHAR);
		
		char c;
		for(;;)
		{
			c = g_sInpLine.buff[++g_sInpLine.pos];
			if (IsCharNumeric(c))
			{
				if (first_char == '#')
					break;
				
				maybe_keyword = false;
			}
			else if (!IsCharAlpha(c) && c != '_')
				break;
		}
		
		tok.len = g_sInpLine.pos - token_start.pos;
		if (tok.len == 1 && first_char == PUBLIC_CHAR)
		{
			tok.id = PUBLIC_CHAR;
			return true;
		}
		
		if (maybe_keyword)
		{
			if (Parser.LexKeyword(tok, token_start))
				return true;
		}
		
		if (first_char != '#')
		{
			Parser.LexSymbol(tok, token_start);
			return true;
		}
		
		g_sInpLine.pos = token_start.pos;
		return false;
	}
	
	public static void LexOnce(full_token_t tok, cell& lexvalue)
	{
		switch (g_sInpLine.buff[g_sInpLine.pos])
		{
			case '0', '1', '2', '3', '4', '5', '6', '7', '8', '9':
			{
				if (Parser.LexNumber(tok, lexvalue))
					return;
			}
			
			case '*':
			{
				g_sInpLine.pos++;
				if (Parser.LexMatchChar('='))
					tok.id = taMULT;
				else
					tok.id = '*';
				
				return;
			}
			
			case '/':
			{
				g_sInpLine.pos++;
				if (Parser.LexMatchChar('='))
					tok.id = taDIV;
				else
					tok.id = '/';
				
				return;
			}
			
			case '%':
			{
				g_sInpLine.pos++;
				if (Parser.LexMatchChar('='))
					tok.id = taMOD;
				else
					tok.id = '%';
				
				return;
			}
			
			case '+':
			{
				g_sInpLine.pos++;
				if (Parser.LexMatchChar('='))
					tok.id = taADD;
				else if (Parser.LexMatchChar('+'))
					tok.id = tINC;
				else
					tok.id = '+';
				
				return;
			}
			
			case '-':
			{
				g_sInpLine.pos++;
				if (Parser.LexMatchChar('='))
					tok.id = taSUB;
				else if (Parser.LexMatchChar('-'))
					tok.id = tDEC;
				else
					tok.id = '-';
				
				return;
			}
			
			case '<':
			{
				g_sInpLine.pos++;
				if (Parser.LexMatchChar('<'))
				{
					if (Parser.LexMatchChar('='))
						tok.id = taSHL;
					else
						tok.id = tSHL;
				}
				else if (Parser.LexMatchChar('='))
					tok.id = tlLE;
				else
					tok.id = '<';
				
				return;
			}
			
			case '>':
			{
				g_sInpLine.pos++;
				if (Parser.LexMatchChar('>'))
				{
					if (Parser.LexMatchChar('>'))
					{
						if (Parser.LexMatchChar('='))
							tok.id = taSHRU;
						else
							tok.id = tSHRU;
					}
					else if (Parser.LexMatchChar('='))
						tok.id = taSHR;
					else
						tok.id = tSHR;
				} 
				else if (Parser.LexMatchChar('='))
					tok.id = tlGE;
				else
					tok.id = '>';
				
				return;
			}
			
			case '&':
			{
				g_sInpLine.pos++;
				if (Parser.LexMatchChar('='))
					tok.id = taAND;
				else if (Parser.LexMatchChar('&'))
					tok.id = tlAND;
				else
					tok.id = '&';
				
				return;
			}
			
			case '^':
			{
				g_sInpLine.pos++;
				if (Parser.LexMatchChar('='))
					tok.id = taXOR;
				else
					tok.id = '^';
				
				return;
			}
			
			case '|':
			{
				g_sInpLine.pos++;
				if (Parser.LexMatchChar('='))
					tok.id = taOR;
				else if (Parser.LexMatchChar('|'))
					tok.id = tlOR;
				else
					tok.id = '|';
				
				return;
			}
			
			case '=':
			{
				g_sInpLine.pos++;
				if (Parser.LexMatchChar('='))
					tok.id = tlEQ;
				else
					tok.id = '=';
				
				return;
			}
			
			case '!':
			{
				g_sInpLine.pos++;
				if (Parser.LexMatchChar('='))
					tok.id = tlNE;
				else
					tok.id = '!';
				
				return;
			}
			
			case '.':
			{
				g_sInpLine.pos++;
				if (Parser.LexMatchChar('.'))
				{
					if (Parser.LexMatchChar('.'))
						tok.id = tELLIPS;
					else
						tok.id = tDBLDOT;
				}
				else
					tok.id = '.';
				
				return;
			}
			
			case ':':
			{
				g_sInpLine.pos++;
				if (Parser.LexMatchChar(':'))
					tok.id = tDBLCOLON;
				else
					tok.id = ':';
				
				return;
			}
			
			case '"':
			{
				Parser.LexStringLiteral(tok, lexvalue);
				return;
			}
			
			case '\'':
			{
				g_sInpLine.pos++;
				tok.id = tNUMBER;
				lexvalue = tok.value = Util.litchar(g_sInpLine, UTF8MODE);
				if (g_sInpLine.buff[g_sInpLine.pos] == '\'')
					g_sInpLine.pos++;
				
				return;
			}
			
			case ';':
			{
				tok.id = ';';
				g_sInpLine.pos++;
				return;
			}
		}
		
		if (IsCharAlpha(g_sInpLine.buff[g_sInpLine.pos]) || g_sInpLine.buff[g_sInpLine.pos] == '#')
			if (Parser.LexSymbolOrKeyword(tok))
				return;
		
		tok.id = g_sInpLine.buff[g_sInpLine.pos++];
	}
	
	public static any CurrentToken()
	{
		full_token_t tok;
		g_sTokenBuffer.tokens.GetArray(g_sTokenBuffer.cursor, tok, sizeof(full_token_t));
		return tok;
	}
	
	public static int TokenInfo(cell& val, char str[sLINEMAX])
	{
		full_token_t tok;
		tok = Parser.CurrentToken();
		val = tok.value;
		str = tok.str.buff;
		return tok.id;
	}
	
	public static void LexClr(int clreol)
	{
		g_sTokenBuffer.depth = 0;
		if (clreol)
		{
			g_sInpLine = g_spLine;
			g_sInpLine.pos = Util.strchr(g_spLine.buff, '\0');
		}
	}
	
	public static void LexPush()
	{
		full_token_t tok;
		tok = Parser.CurrentToken();
		if (tok.id == tPENDING_STRING)
			return;
		
		g_sTokenBuffer.depth++;
		if (g_sTokenBuffer.cursor == 0)
			g_sTokenBuffer.cursor = MAX_TOKEN_DEPTH - 1;
		else
			g_sTokenBuffer.cursor--;
	}
	
	public static void LexPop()
	{
		g_sTokenBuffer.depth--;
		g_sTokenBuffer.cursor++;
		if (g_sTokenBuffer.cursor == MAX_TOKEN_DEPTH)
			g_sTokenBuffer.cursor = 0;
	}
	
	public static void UpdateCurrentToken(full_token_t tok)
	{
		g_sTokenBuffer.tokens.SetArray(g_sTokenBuffer.cursor, tok, sizeof(full_token_t));
	}
	
	public static any AdvanceToken()
	{
		g_sTokenBuffer.num_tokens++;
		g_sTokenBuffer.cursor++;
		if (g_sTokenBuffer.cursor == MAX_TOKEN_DEPTH)
			g_sTokenBuffer.cursor = 0;
		
		return Parser.CurrentToken();
	}
	
	public static int Lex(cell& lexvalue, char lexsym[sLINEMAX])
	{
		bool newline;
		
		if (g_sTokenBuffer.depth > 0)
		{
			Parser.LexPop();
			full_token_t tok;
			tok = Parser.CurrentToken();
			lexvalue = tok.value;
			//lexsym = tok.str.buff; //HACK: Can't do it that way, array must be indexed error!
			strcopy(lexsym, sizeof(lexsym), tok.str.buff);
			return tok.id;
		}
		
		full_token_t tok;
		tok = Parser.AdvanceToken(); //TODO: Array index out of bounds;
		tok.id = 0;
		tok.value = 0;
		tok.str.buff[0] = '\0';
		tok.len = 0;
		
		lexvalue = tok.value;
		//lexsym = tok.str.buff; //HACK: Can't do it that way, array must be indexed error!
		strcopy(lexsym, sizeof(lexsym), tok.str.buff);
		
		g_bLexNewline = false;
		if (!g_bisReading)
			return 0;
		
		newline = (g_sInpLine.pos == g_spLine.pos);
		
		while (g_sInpLine.buff[g_sInpLine.pos] <= ' ')
		{
			if (g_sInpLine.buff[g_sInpLine.pos] == '\0')
			{
				PreprocessInLex(); //FIXME;
				if (!g_bisReading)
					return 0;
				
				/*if (lptr==term_expr)		TODO (pure c++)
					return (tok.id = tENDEXPR);*/
				g_bLexNewline = true;
				newline = true;
			}
			else
				g_sInpLine.pos++;
		}
		
		if (newline)
		{
			g_bStmtIndent = 0;
			for (int i = 0; i < g_sInpLine.pos - g_spLine.pos; i++)
				if (g_spLine.buff[i] == '\t' && sc_tabsize > 0)
					g_bStmtIndent += sc_tabsize - (g_bStmtIndent + sc_tabsize) % sc_tabsize;
				else
					g_bStmtIndent++;
		}
		
		tok.start.line = g_ifLine;
		tok.start.col = g_sInpLine.pos - g_spLine.pos;
		
		Parser.LexOnce(tok, lexvalue);
		
		tok.end.line = g_ifLine;
		tok.end.col = g_sInpLine.pos - g_spLine.pos;
		
		Parser.UpdateCurrentToken(tok);
		
		return tok.id;
	}
	
	public static int MatchToken(int token)
	{
		cell val;
		char_t str;
		int tok;
		
		tok = Parser.Lex(val, str.buff);
		
		if (token == tok)
			return 1;
		if (token == tTERM && (tok == ';' || tok == tENDEXPR))
			return 1;
		
		/*if (!sc_needsemicolon && token == tTERM && (_lexnewline || !freading)) //TODO: Do I still need in it?
		{
			Parser.LexPush();
			return 2;
		}*/
		
		Parser.LexPush();
		return 0;
	}
	
	public static int LexPeek(int id)
	{
		if (Parser.MatchToken(id))
		{
			Parser.LexPush();
			return true;
		}
		
		return false;
	}
	
	public static int LexTok(token_t tok)
	{
		tok.id = Parser.Lex(tok.val, tok.str.buff);
		return tok.id;
	}
	
	public static int GetCommand()
	{
		int tok, ret;
		cell val;
		char str[sLINEMAX];
		
		while (g_sInpLine.buff[g_sInpLine.pos] <= ' ' && g_sInpLine.buff[g_sInpLine.pos] != '\0')
			g_sInpLine.pos++;
		
		if (g_sInpLine.buff[g_sInpLine.pos] == '\0')
			return CMD_EMPTYLINE;
		
		if (g_sInpLine.buff[g_sInpLine.pos] != '#')
			return CMD_NONE;
		
		//lexclr(FALSE); //TODO add lexclr; (pure c++)
		
		//TODO (pure c++)
		/*if (!sc_needsemicolon && stgget(&index,&code_index))
		{
			lptr=term_expr;
			return CMD_TERM;
		}*/
		
		tok = Parser.Lex(val, str);
		ret = CMD_DIRECTIVE;
		
		switch (tok)
		{
			case tpIF:
			{
				ret = CMD_IF;
			}
			
			case tpELSE, tpELSEIF:
			{
				ret = CMD_IF;
			}
			
			case tpENDIF:
			{
				ret = CMD_IF;
			}
			
			case tINCLUDE, tpTRYINCLUDE:
			{
				ret = CMD_INCLUDE;
			}
			
			case tpDEFINE:
			{
				ret = CMD_DEFINE;
			}
			
			default:
			{
				ret = CMD_NONE;
			}
		}
		
		return ret;
	}
	
	//TODO;
	/*public static void SubstAllPatterns(const char line[sLINEMAX], int length)
	{
		char start[sLINEMAX];
		int startpos;
		
		start = line;
		
		
	}*/
}

methodmap SPFile < File
{
	public SPFile(const char[] path, bool forwrite = false)
	{
		File file = OpenFile(path, (forwrite ? "w" : "r"), true);
		return view_as<SPFile>(file);
	}
	
	public void Preprocessline()
	{
		int iscommand;
		cell val;
		char str[sLINEMAX];
		
		g_bisReading = !this.EndOfFile();
		
		if(!g_bisReading)
			return;
		
		do
		{
			this.ReadLine(g_spLine.buff, sizeof(g_spLine.buff) - 1);
			g_spLine.pos = 0;
			g_ifLine++; //HACK: probs should change that;
			Util.StripComments(g_spLine);
			g_sInpLine = g_spLine;
			g_sInpLine.pos = 0;
			iscommand = Parser.GetCommand();
			
			Parser.Lex(val, str);
			
			//TODO;
			/*if (iscommand == CMD_NONE)
			{
				this.SubstAllPatterns(line, sizeof(line));
				g_sInpLine.buff = line;
			}*/
			
			g_bisReading = !this.EndOfFile();
			
		} while (iscommand != CMD_NONE && iscommand != CMD_TERM && g_bisReading);
	}
	
	public void Parse(SPFile outfile)
	{
		full_token_t ftok;
		//token_t tok;
		Return ret = new Return();
		
		g_sNormalBuffer.tokens = new ArrayList();
		if(ret.Register(g_sNormalBuffer.tokens) == -1)
		{
			log.Error("Can't init g_NormalBuffer.tokens!");
			ret.Handle();
			return;
		}
		
		g_sTokenBuffer.tokens = new ArrayList();
		if(ret.Register(g_sTokenBuffer.tokens) == -1)
		{
			log.Error("Can't init g_sTokenBuffer.tokens!");
			ret.Handle();
			return;
		}
		
		g_sPreprocessBuffer.tokens = new ArrayList();
		if(ret.Register(g_sPreprocessBuffer.tokens) == -1)
		{
			log.Error("Can't init g_sPreprocessBuffer.tokens!");
			ret.Handle();
			return;
		}
		
		for(int i = 0; i < MAX_TOKEN_DEPTH; i++)
		{
			g_sTokenBuffer.tokens.PushArray(ftok, sizeof(full_token_t));
			g_sNormalBuffer.tokens.PushArray(ftok, sizeof(full_token_t));
			g_sPreprocessBuffer.tokens.PushArray(ftok, sizeof(full_token_t));
		}
		
		g_litq = new ArrayList();
		if(ret.Register(g_litq) == -1)
		{
			log.Error("Can't init g_litq!");
			ret.Handle();
			return;
		}
		
		g_sKeywords = new StringMap();
		if(ret.Register(g_sKeywords) == -1)
		{
			log.Error("Can't init g_sKeywords!");
			ret.Handle();
			return;
		}
		
		//int kStart = tMIDDLE + 1;
		for (int kStart = tMIDDLE + 1, i = kStart; i <= tLAST; i++)
			g_sKeywords.SetValue(sc_tokens[i - tFIRST], i);
		
		g_bisReading = !this.EndOfFile();
		
		if(!g_bisReading)
		{
			log.Info("Empty file? Nothing to read were found in specified file!");
			ret.Handle();
			return;
		}
		
		while(g_bisReading)
		{
			this.Preprocessline();
			
			
			g_bisReading = !this.EndOfFile();
		}
		
		ret.Handle();
	}
}

//FUCKING HATE THAT I CAN'T DEFINE METHODMAPPED VARIABLES BEFORE METHODMAP DEFINE :FIXME:HACK:IDK:
SPFile g_spFile;

//SAME HERE ^ :FIXME:HACK:IDK:
public void PreprocessInLex()
{
	g_sTokenBuffer = g_sPreprocessBuffer;
	g_spFile.Preprocessline();
	g_sTokenBuffer = g_sNormalBuffer;
}

public int strncopy2(char[] dest, int destlen, char[] source, int lentocopy)
{
	int srclen = strlen(source);
	
	if(srclen < lentocopy)
		lentocopy = srclen;
	
	if(destlen < lentocopy)
		lentocopy = destlen - 1;
	
	for(int i = 0; i < lentocopy; i++)
		dest[i] = source[i];
	
	dest[lentocopy] = '\0';
	
	return lentocopy;
}
