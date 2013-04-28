package com.eiri.wifidb_uploader;

import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.util.ArrayList;
import java.util.List;
import java.util.StringTokenizer;

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

public class WifiDB {
	private static final String TAG = "WiFiDB_POST";
	
	public static void postLiveData(String sAPIURL, 
									String sSID, 
									String sUsername, 
									String sApiKey, 
									String sSSID, 
									String sBSSID, 
									String sRADIO, 
									String sAUTH, 
									String sENCR, 
									String Label, 
									String sNetType, 
									Integer iSecType, 
									Integer iCHAN, 
									Integer iSignal, 
									Integer iRSSI, 
									Double dLat, 
									Double dLon,
									Integer dSats,
									Double dAlt,
									float fSpeed,
									float fTrack,
									String sDataTime) {
		//Get Date and Time
		StringTokenizer tk = new StringTokenizer(sDataTime);
		String date = tk.nextToken();  // <---  yyyy-mm-dd
		String time = tk.nextToken();  // <---  hh:mm:ss.SSS
		//Get Speeds 
		int iSpeedKMH=(int) ((fSpeed*3600)/1000);
		int iSpeedMPH=(int) (fSpeed*2.2369);
		
	    // Create a new HttpClient and Post Header
	    DefaultHttpClient httpclient = new DefaultHttpClient();
	    String HTTP_POST_HOST_PATH = sAPIURL + "live.php";
	    //String HTTP_POST_HOST_PATH = "http://dev01.wifidb.net/wifidb/api/live.php";
	    HttpPost httppost = new HttpPost(HTTP_POST_HOST_PATH);
	    // Upload your data, muahahahahaha
        List<NameValuePair> nameValuePairs = new ArrayList<NameValuePair>(2);
        nameValuePairs.add(new BasicNameValuePair("Sid", sSID));
        nameValuePairs.add(new BasicNameValuePair("Username", sUsername));
        nameValuePairs.add(new BasicNameValuePair("apikey", sApiKey));
        
        nameValuePairs.add(new BasicNameValuePair("SSID", sSSID));
        nameValuePairs.add(new BasicNameValuePair("Mac", sBSSID));
        nameValuePairs.add(new BasicNameValuePair("Rad", sRADIO));
        nameValuePairs.add(new BasicNameValuePair("Auth", sAUTH));
        nameValuePairs.add(new BasicNameValuePair("Encry", sENCR));
        nameValuePairs.add(new BasicNameValuePair("Label", Label));
        nameValuePairs.add(new BasicNameValuePair("NT", sNetType));
        nameValuePairs.add(new BasicNameValuePair("SecType", Integer.toString(iSecType)));
        nameValuePairs.add(new BasicNameValuePair("Chn", Integer.toString(iCHAN)));
        nameValuePairs.add(new BasicNameValuePair("Sig", Integer.toString(iSignal)));
        nameValuePairs.add(new BasicNameValuePair("RSSI", Integer.toString(iRSSI)));
        
        nameValuePairs.add(new BasicNameValuePair("Lat", Double.toString(dLat)));
        nameValuePairs.add(new BasicNameValuePair("Long", Double.toString(dLon)));
        nameValuePairs.add(new BasicNameValuePair("Sats", Integer.toString(dSats)));
        nameValuePairs.add(new BasicNameValuePair("ALT", Double.toString(dAlt)));
        nameValuePairs.add(new BasicNameValuePair("KMH", Integer.toString(iSpeedKMH)));
        nameValuePairs.add(new BasicNameValuePair("MPH", Integer.toString(iSpeedMPH)));
        nameValuePairs.add(new BasicNameValuePair("Track", Float.toString(fTrack)));
        nameValuePairs.add(new BasicNameValuePair("Date", date));
        nameValuePairs.add(new BasicNameValuePair("Time", time));
        
        
        try {
        	Log.d(TAG, "HTTP POST TO: " + HTTP_POST_HOST_PATH);
			httppost.setEntity(new UrlEncodedFormEntity(nameValuePairs));
		} catch (UnsupportedEncodingException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

        // Execute HTTP Post Request
        try {
			HttpResponse response = httpclient.execute(httppost);
			if (response.getStatusLine().getStatusCode() == 200)
            {
                HttpEntity entity = response.getEntity();
				Log.d(TAG, "HTTP Receive message: " + EntityUtils.toString(entity));
            }			

			
	    } catch (UnsupportedEncodingException uee) {
	        Log.d("Exceptions", "UnsupportedEncodingException");
	        uee.printStackTrace();
	    } catch (ClientProtocolException cpe) {
	        Log.d("Exceptions", "ClientProtocolException");
	        cpe.printStackTrace();
	    } catch (IOException ioe) {
	        Log.d("Exceptions", "IOException");
	        ioe.printStackTrace();
	    }  
	} 
	// see http://androidsnippets.com/executing-a-http-post-request-with-httpclient
}