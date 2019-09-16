/**
 * Copyright (c) 2015-present, Horcrux.
 * All rights reserved.
 *
 * This source code is licensed under the MIT-style license found in the
 * LICENSE file in the root directory of this source tree.
 */


package com.horcrux.svg;

import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Matrix;
import android.graphics.Paint;
import android.graphics.PorterDuff;
import android.graphics.Rect;
import android.net.Uri;
import android.util.Log;
import android.util.Base64;
import android.graphics.BitmapFactory;

import com.facebook.common.executors.CallerThreadExecutor;
import com.facebook.common.references.CloseableReference;
import com.facebook.datasource.DataSource;
import com.facebook.common.logging.FLog;
import com.facebook.drawee.backends.pipeline.Fresco;
import com.facebook.imagepipeline.core.ImagePipeline;
import com.facebook.imagepipeline.datasource.BaseBitmapDataSubscriber;
import com.facebook.imagepipeline.image.CloseableImage;
import com.facebook.imagepipeline.request.ImageRequest;
import com.facebook.imagepipeline.request.ImageRequestBuilder;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.common.ReactConstants;
import com.facebook.react.uimanager.annotations.ReactProp;
import javax.annotation.Nullable;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.annotation.SuppressLint;
import com.facebook.react.bridge.Dynamic;
import com.facebook.react.bridge.ReactContext;
import android.graphics.Path;

/**
 * Shadow node for virtual RNSVGPath view
 */
@SuppressLint("ViewConstructor")
public class Base64ImageView extends PathView {

    private Bitmap mBitmap;
    private JSONObject mAtlasDescriptor;
    private JSONArray mFrameDescriptor;
    private int mX = 0;
    private int mY = 0;

    public Base64ImageView(ReactContext reactContext) {
        super(reactContext);
    }

    @ReactProp(name = "dx")
    public void setDx(int dx) {
        mX = dx;
        invalidate();
    }

    @ReactProp(name = "dy")
    public void setDy(int dy) {
        mY = dy;
        invalidate();
    }

    @ReactProp(name = "base64")
    public void setBase64(String encodedString) {
        try {
            byte [] encodeByte = Base64.decode(encodedString, Base64.DEFAULT);
            mBitmap = BitmapFactory.decodeByteArray(encodeByte, 0, encodeByte.length);
            invalidate();
        } catch (Exception e) {
            Log.e("Base64", e.getMessage());
        }
    }

    @ReactProp(name = "atlasDescriptor")
    public void setAtlasDescriptor(String atlasDescriptor) {
        try {
            mAtlasDescriptor = new JSONObject(atlasDescriptor);
            invalidate();
        } catch (JSONException e) {
            Log.e("Base64", e.getMessage());
        }
    }

    @ReactProp(name = "frameDescriptor")
    public void setFrameDescriptor(String frameDescriptor) {
        try {
            mFrameDescriptor = new JSONArray(frameDescriptor);
            invalidate();
        } catch (JSONException e) {
            Log.e("Base64", e.getMessage());
        }
    }

    @Override
    public void draw(Canvas canvas, Paint paint, float opacity) {
        SvgView node = getSvgView();

        if (mBitmap != null && mFrameDescriptor != null && mAtlasDescriptor != null) {

            Matrix transformMatrix = new Matrix();

            for (int i = 0; i < mFrameDescriptor.length(); i++) {
                try {

                    int count = saveAndSetupCanvas(canvas, mCTM);
                    clip(canvas, paint);
                    JSONObject frameRecord = mFrameDescriptor.getJSONObject(i);

                    //TODO: parse all objects on start (Full frames array and subtexture array)
                    String partId = frameRecord.getString("n");
                    JSONObject partTransform = frameRecord.getJSONObject("t");
                    float a = (float)partTransform.getDouble("a");
                    float b = (float)partTransform.getDouble("b");
                    float c = (float)partTransform.getDouble("c");
                    float d = (float)partTransform.getDouble("d");
                    float tx = (float)partTransform.getDouble("tx") + mX;
                    float ty = (float)partTransform.getDouble("ty") + mY;
                    transformMatrix.setValues(new float[]{a, b, tx, c, d, ty, 0.0f, 0.0f, 1.0f});

                    JSONObject subtexture = mAtlasDescriptor.getJSONObject(partId);
                    int sw = subtexture.getInt("w");
                    int sh = subtexture.getInt("h");
                    int sx = subtexture.getInt("x");
                    int sy = subtexture.getInt("y");
                    int srx = subtexture.getInt("rx");
                    int sry = subtexture.getInt("ry");
                    canvas.concat(transformMatrix);
                    canvas.drawBitmap(
                        mBitmap,
                        new Rect (sx, sy, sx + sw, sy + sh),
                        new Rect (srx, sry, srx + sw, sry + sh),
                        null);
                    //TODO: remove useless matrix concat
                    transformMatrix.setValues(new float[]{1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 0.0f, 0.0f, 1.0f});
                    canvas.concat(transformMatrix);
                    restoreCanvas(canvas, count);
                } catch (JSONException e) {
                }
            }

            invalidate();
        }
    }
}
