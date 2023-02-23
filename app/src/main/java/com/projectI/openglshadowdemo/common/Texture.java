package com.projectI.openglshadowdemo.common;

import android.opengl.GLES20;

public class Texture {

	private int target;
	private int id;
	private int width;
	private int height;

	public Texture(int target, int id) 
	{
		this.target = target;
		this.id = id;
	}

	public final void  delete()
	{
		GLES20.glDeleteTextures(1, new int[] {id}, 0);
	}
	
	public final int   getTarget() { return target; }
	public final int   getId()     { return id; }
	public final int   getWidth()  { return width; }
	public final int   getHeight() { return height; }
	public final float getRatio()  { return (float)width/height; }
	public void setWidth(int w)    { width = w; }
	public void setHeight(int h)   { height = h; }
}
