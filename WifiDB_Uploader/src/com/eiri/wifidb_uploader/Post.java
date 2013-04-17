package com.eiri.wifidb_uploader;

import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.util.ArrayList;
import java.util.List;

import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.NameValuePair;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.entity.UrlEncodedFormEntity;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.message.BasicNameValuePair;
import org.apache.http.util.EntityUtils;

import android.util.Log;

public class Post {
	public void postData(String sSID, String bSSID, String capabilities, String frequency, String level, String latitude_str, String longitude_str) {
	    // Create a new HttpClient and Post Header
	    DefaultHttpClient httpclient = new DefaultHttpClient();
	    HttpPost httppost = new HttpPost("http://dev01.wifidb.net/wifidb/api/live.php");
	    // Add your data
        List<NameValuePair> nameValuePairs = new ArrayList<NameValuePair>(2);
        nameValuePairs.add(new BasicNameValuePair("ssid", sSID));
        nameValuePairs.add(new BasicNameValuePair("mac", bSSID));
        nameValuePairs.add(new BasicNameValuePair("capabilities", capabilities));
        nameValuePairs.add(new BasicNameValuePair("radio", frequency));
        nameValuePairs.add(new BasicNameValuePair("signal", level));
        nameValuePairs.add(new BasicNameValuePair("latitude", latitude_str));
        nameValuePairs.add(new BasicNameValuePair("longitude", longitude_str));
        
        try {
			httppost.setEntity(new UrlEncodedFormEntity(nameValuePairs));
		} catch (UnsupportedEncodingException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
        // Execute HTTP Post Request
        try {
			HttpResponse result = httpclient.execute(httppost);
			HttpEntity entity = result.getEntity();
			
			Log.d("", "HTTP Receive message: " + EntityUtils.toString(entity));
		} catch (ClientProtocolException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	} 
	// see http://androidsnippets.com/executing-a-http-post-request-with-httpclient
}
