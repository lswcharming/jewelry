package com.projectI.openglshadowdemo.common;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.net.Uri;
import android.opengl.GLES11Ext;
import android.opengl.GLES20;
import android.opengl.GLES30;
import android.opengl.GLUtils;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;

public class TextureUtil 
{
	private TextureUtil() {}
	public static Texture buildBitmapTexture(Bitmap bitmap) 
	{
		int[] textureHandle = new int[1];
		GLES20.glGenTextures(1, textureHandle, 0);
		
		GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, textureHandle[0]);

		GLES20.glTexParameteri(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_WRAP_S, GLES20.GL_CLAMP_TO_EDGE);
		GLES20.glTexParameteri(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_WRAP_T, GLES20.GL_CLAMP_TO_EDGE);
		GLES20.glTexParameteri(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_MIN_FILTER, GLES20.GL_LINEAR);
		GLES20.glTexParameteri(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_MAG_FILTER, GLES20.GL_LINEAR);

		GLUtils.texImage2D(GLES20.GL_TEXTURE_2D, 0, bitmap, 0);

		Texture tex = new Texture(GLES20.GL_TEXTURE_2D, textureHandle[0]);
		tex.setWidth(bitmap.getWidth()); 
		tex.setHeight(bitmap.getHeight()); 
		
		bitmap.recycle();
		bitmap = null;
		
		return tex;
	}
	
	public static Texture buildBitmapTexturefromAsset(Context context, String path) 
	{
	 	Bitmap bitmap = null;
    	try	{
    		InputStream is;
			is = context.getAssets().open(path);

			BitmapFactory.Options opts = new BitmapFactory.Options();
			opts.inPremultiplied = false;

	    	bitmap = BitmapFactory.decodeStream(is, null, opts);
	    	is.close();
		} 
		catch (IOException e) {
			e.printStackTrace();
			throw new AssertionError("Falied to load bitmap : " + path);
		}
    	
		int[] textureHandle = new int[1];
		GLES20.glGenTextures(1, textureHandle, 0);
		
		GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, textureHandle[0]);

		GLES20.glTexParameteri(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_WRAP_S, GLES20.GL_REPEAT); // [c] test GL_REPEAT); // GL_CLAMP_TO_EDGE);
		GLES20.glTexParameteri(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_WRAP_T, GLES20.GL_REPEAT);
		GLES20.glTexParameteri(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_MIN_FILTER, GLES20.GL_LINEAR);
		GLES20.glTexParameteri(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_MAG_FILTER, GLES20.GL_LINEAR);

		GLUtils.texImage2D(GLES20.GL_TEXTURE_2D, 0, bitmap, 0);
		
		Texture tex = new Texture(GLES20.GL_TEXTURE_2D, textureHandle[0]);
		tex.setWidth(bitmap.getWidth()); 
		tex.setHeight(bitmap.getHeight()); 

		bitmap.recycle();
		bitmap = null;
		
		return tex;
	}
	
	public static Texture buildBitmapTexturefromStorage(String path) 
	{
	 	Bitmap bitmap = null;
    	try	{
    		File file = new File(Uri.parse(path).toString());
    		FileInputStream  is = new FileInputStream (file);
	    	bitmap = BitmapFactory.decodeStream(is);
	    	is.close();
		} 
		catch (IOException e) {
			e.printStackTrace();
			throw new AssertionError("Falied to load bitmap : " + path);
		}
    	
		int[] textureHandle = new int[1];
		GLES30.glGenTextures(1, textureHandle, 0);

		GLES30.glBindTexture(GLES30.GL_TEXTURE_2D, textureHandle[0]);

		GLES30.glTexParameteri(GLES30.GL_TEXTURE_2D, GLES30.GL_TEXTURE_WRAP_S, GLES30.GL_CLAMP_TO_EDGE);
		GLES30.glTexParameteri(GLES30.GL_TEXTURE_2D, GLES30.GL_TEXTURE_WRAP_T, GLES30.GL_CLAMP_TO_EDGE);
		GLES30.glTexParameteri(GLES30.GL_TEXTURE_2D, GLES30.GL_TEXTURE_MIN_FILTER, GLES30.GL_LINEAR);
		GLES30.glTexParameteri(GLES30.GL_TEXTURE_2D, GLES30.GL_TEXTURE_MAG_FILTER, GLES30.GL_LINEAR);

		GLUtils.texImage2D(GLES30.GL_TEXTURE_2D, 0, bitmap, 0);

		Texture tex = new Texture(GLES30.GL_TEXTURE_2D, textureHandle[0]);
		tex.setWidth(bitmap.getWidth()); 
		tex.setHeight(bitmap.getHeight()); 
		
		bitmap.recycle();
		bitmap = null;
		
		return tex;
	}
	
	public static Texture buildExternalTexture() 
	{
		// Bind to the texture in OpenGL
		int[] textureHandle = new int[1];
		GLES20.glBindTexture(GLES11Ext.GL_TEXTURE_EXTERNAL_OES,	textureHandle[0]);

		// Set filtering
		GLES20.glTexParameteri(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_WRAP_S, GLES20.GL_CLAMP_TO_EDGE);
		GLES20.glTexParameteri(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_WRAP_T, GLES20.GL_CLAMP_TO_EDGE);
		GLES20.glTexParameteri(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, GLES20.GL_TEXTURE_MIN_FILTER, GLES20.GL_LINEAR);
		GLES20.glTexParameteri(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, GLES20.GL_TEXTURE_MAG_FILTER, GLES20.GL_LINEAR);

		return new Texture(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, textureHandle[0]);
	}
	
	public static Texture buildTextTexture(String text, Paint paint, int width, int height, int backgroundColor)
	{
		Bitmap bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888);
		Canvas canvas = new Canvas(bitmap);

		if (backgroundColor != Color.TRANSPARENT)
		{
			canvas.drawARGB( Color.alpha(backgroundColor)
					       , Color.red(backgroundColor)
					       , Color.green(backgroundColor)
					       , Color.blue(backgroundColor) );
		}

		int x = canvas.getWidth() / 2;
		int y = (int) ((canvas.getHeight() / 2) - ((paint.descent() + paint.ascent()) / 2));
		//paint.getTextWidths(text, widths);
		canvas.drawText(text, x, y, paint);
		Texture tex = buildBitmapTexture(bitmap);
		
		bitmap.recycle();
		bitmap = null;
		
		return tex;
	}
	
	public static void changeTextTexture(Texture texture, String text, Paint paint, int width, int height, int backgroundColor) 
	{
		Bitmap bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888);
		Canvas canvas = new Canvas(bitmap);

		if (backgroundColor != Color.TRANSPARENT)
		{
			canvas.drawARGB( Color.alpha(backgroundColor)
					       , Color.red(backgroundColor)
					       , Color.green(backgroundColor)
					       , Color.blue(backgroundColor) );
		}

		int x = canvas.getWidth() / 2;
		int y = (int) ((canvas.getHeight() / 2) - ((paint.descent() + paint.ascent()) / 2));

		canvas.drawText(text, x, y, paint);
		
		GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, texture.getId());
		GLUtils.texSubImage2D(GLES20.GL_TEXTURE_2D, 0, 0, 0, bitmap);  
		bitmap.recycle();
		bitmap = null;
	}
}
