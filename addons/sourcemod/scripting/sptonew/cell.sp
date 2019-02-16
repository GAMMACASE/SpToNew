//Int
stock cell operator=(int oper)
{
	return view_as<cell>(oper);
}

stock cell operator-(cell oper1, int oper2)
{
	return oper1-view_as<cell>(oper2);
}

stock cell operator-(int oper1, cell oper2)
{
	return view_as<cell>(oper1)-oper2;
}

stock cell operator*(cell oper1, int oper2)
{
	return oper1*view_as<cell>(oper2);
}

stock cell operator*(int oper1, cell oper2)
{
	return view_as<cell>(oper1)*oper2;
}

stock cell operator/(cell oper1, int oper2)
{
	return oper1/view_as<cell>(oper2);
}

stock cell operator/(int oper1, cell oper2)
{
	return view_as<cell>(oper1)/oper2;
}

stock cell operator%(cell oper1, int oper2)
{
	return oper1%view_as<cell>(oper2);
}

stock cell operator%(int oper1, cell oper2)
{
	return view_as<cell>(oper1)%oper2;
}

stock cell operator+(cell oper1, int oper2)
{
	return oper1+view_as<cell>(oper2);
}

stock cell operator+(int oper1, cell oper2)
{
	return view_as<cell>(oper1)+oper2;
}

stock bool operator==(cell oper1, int oper2)
{
	return oper1==view_as<cell>(oper2);
}

stock bool operator==(int oper1, cell oper2)
{
	return view_as<cell>(oper1)==oper2;
}

stock bool operator!=(cell oper1, int oper2)
{
	return oper1!=view_as<cell>(oper2);
}

stock bool operator!=(int oper1, cell oper2)
{
	return view_as<cell>(oper1)!=oper2;
}

stock bool operator>(cell oper1, int oper2)
{
	return oper1>view_as<cell>(oper2);
}

stock bool operator>(int oper1, cell oper2)
{
	return view_as<cell>(oper1)>oper2;
}

stock bool operator>=(cell oper1, int oper2)
{
	return oper1>=view_as<cell>(oper2);
}

stock bool operator>=(int oper1, cell oper2)
{
	return view_as<cell>(oper1)>=oper2;
}

stock bool operator<(cell oper1, int oper2)
{
	return oper1<view_as<cell>(oper2);
}

stock bool operator<(int oper1, cell oper2)
{
	return view_as<cell>(oper1)<oper2;
}

stock bool operator<=(cell oper1, int oper2)
{
	return oper1<=view_as<cell>(oper2);
}

stock bool operator<=(int oper1, cell oper2)
{
	return view_as<cell>(oper1)<=oper2;
}

//Float
stock cell operator=(float r)
{
	return view_as<cell>(r);
}

stock cell operator-(cell oper1, float oper2)
{
	return oper1-view_as<cell>(oper2);
}

stock cell operator-(float oper1, cell oper2)
{
	return view_as<cell>(oper1)-oper2;
}

stock cell operator*(cell oper1, float oper2)
{
	return oper1*view_as<cell>(oper2);
}

stock cell operator*(float oper1, cell oper2)
{
	return view_as<cell>(oper1)*oper2;
}

stock cell operator/(cell oper1, float oper2)
{
	return oper1/view_as<cell>(oper2);
}

stock cell operator/(float oper1, cell oper2)
{
	return view_as<cell>(oper1)/oper2;
}

stock cell operator%(cell oper1, float oper2)
{
	return oper1%view_as<cell>(oper2);
}

stock cell operator%(float oper1, cell oper2)
{
	return view_as<cell>(oper1)%oper2;
}

stock cell operator+(cell oper1, float oper2)
{
	return oper1+view_as<cell>(oper2);
}

stock cell operator+(float oper1, cell oper2)
{
	return view_as<cell>(oper1)+oper2;
}

stock bool operator==(cell oper1, float oper2)
{
	return oper1==view_as<cell>(oper2);
}

stock bool operator==(float oper1, cell oper2)
{
	return view_as<cell>(oper1)==oper2;
}

stock bool operator!=(cell oper1, float oper2)
{
	return oper1!=view_as<cell>(oper2);
}

stock bool operator!=(float oper1, cell oper2)
{
	return view_as<cell>(oper1)!=oper2;
}

stock bool operator>(cell oper1, float oper2)
{
	return oper1>view_as<cell>(oper2);
}

stock bool operator>(float oper1, cell oper2)
{
	return view_as<cell>(oper1)>oper2;
}

stock bool operator>=(cell oper1, float oper2)
{
	return oper1>=view_as<cell>(oper2);
}

stock bool operator>=(float oper1, cell oper2)
{
	return view_as<cell>(oper1)>=oper2;
}

stock bool operator<(cell oper1, float oper2)
{
	return oper1<view_as<cell>(oper2);
}

stock bool operator<(float oper1, cell oper2)
{
	return view_as<cell>(oper1)<oper2;
}

stock bool operator<=(cell oper1, float oper2)
{
	return oper1<=view_as<cell>(oper2);
}

stock bool operator<=(float oper1, cell oper2)
{
	return view_as<cell>(oper1)<=oper2;
}

//Char
stock cell operator=(char r)
{
	return view_as<cell>(r);
}

stock cell operator-(cell oper1, char oper2)
{
	return oper1-view_as<cell>(oper2);
}

stock cell operator-(char oper1, cell oper2)
{
	return view_as<cell>(oper1)-oper2;
}

stock cell operator*(cell oper1, char oper2)
{
	return oper1*view_as<cell>(oper2);
}

stock cell operator*(char oper1, cell oper2)
{
	return view_as<cell>(oper1)*oper2;
}

stock cell operator/(cell oper1, char oper2)
{
	return oper1/view_as<cell>(oper2);
}

stock cell operator/(char oper1, cell oper2)
{
	return view_as<cell>(oper1)/oper2;
}

stock cell operator%(cell oper1, char oper2)
{
	return oper1%view_as<cell>(oper2);
}

stock cell operator%(char oper1, cell oper2)
{
	return view_as<cell>(oper1)%oper2;
}

stock cell operator+(cell oper1, char oper2)
{
	return oper1+view_as<cell>(oper2);
}

stock cell operator+(char oper1, cell oper2)
{
	return view_as<cell>(oper1)+oper2;
}

stock bool operator==(cell oper1, char oper2)
{
	return oper1==view_as<cell>(oper2);
}

stock bool operator==(char oper1, cell oper2)
{
	return view_as<cell>(oper1)==oper2;
}

stock bool operator!=(cell oper1, char oper2)
{
	return oper1!=view_as<cell>(oper2);
}

stock bool operator!=(char oper1, cell oper2)
{
	return view_as<cell>(oper1)!=oper2;
}

stock bool operator>(cell oper1, char oper2)
{
	return oper1>view_as<cell>(oper2);
}

stock bool operator>(char oper1, cell oper2)
{
	return view_as<cell>(oper1)>oper2;
}

stock bool operator>=(cell oper1, char oper2)
{
	return oper1>=view_as<cell>(oper2);
}

stock bool operator>=(char oper1, cell oper2)
{
	return view_as<cell>(oper1)>=oper2;
}

stock bool operator<(cell oper1, char oper2)
{
	return oper1<view_as<cell>(oper2);
}

stock bool operator<(char oper1, cell oper2)
{
	return view_as<cell>(oper1)<oper2;
}

stock bool operator<=(cell oper1, char oper2)
{
	return oper1<=view_as<cell>(oper2);
}

stock bool operator<=(char oper1, cell oper2)
{
	return view_as<cell>(oper1)<=oper2;
}