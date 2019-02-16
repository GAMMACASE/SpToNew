methodmap Return < ArrayList
{
	public Return()
	{
		return view_as<Return>(new ArrayList());
	}
	
	public int Register(Handle handle)
	{
		return (handle == null ? -1 : this.Push(handle));
	}
	
	public any Handle(any ret = 0, any &val1 = INVALID_HANDLE, any val1res = INVALID_HANDLE, any &val2 = INVALID_HANDLE, any val2res = INVALID_HANDLE, any &val3 = INVALID_HANDLE, any val3res = INVALID_HANDLE)
	{
		val1 = val1res;
		val2 = val2res;
		val3 = val3res;
		
		for(int i = 0; i < this.Length; i++)
			delete view_as<Handle>(this.Get(i));
		
		delete this;
		
		return ret;
	}
}



