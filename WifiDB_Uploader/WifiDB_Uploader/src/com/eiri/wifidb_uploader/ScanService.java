package com.eiri.wifidb_uploader;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import java.util.Locale;
import java.util.Timer;
import java.util.TimerTask;

import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.location.Location;
import android.net.wifi.ScanResult;
import android.net.wifi.WifiManager;
import android.os.Bundle;
import android.os.IBinder;
import android.preference.PreferenceManager;
import android.util.Log;
import android.widget.Toast;

public class ScanService extends Service {
	private static final String TAG = "WiFiDB_ScanService";
	public static final int MSG_SET_MAP_POSITION = 1;
	public static final int MSG_SET_MAP_ZOOM_LEVEL = 2;
	private static Timer timer;
	private Context ctx;
	static WifiManager wifi;
	SharedPreferences sharedPrefs;
	
	@Override
	public IBinder onBind(Intent intent) {
		return null;
	}
	
	@Override
	public void onCreate() {
		super.onCreate();
		ctx = this; 
		Toast.makeText(this, "My Service Created", Toast.LENGTH_LONG).show();
		sharedPrefs = PreferenceManager.getDefaultSharedPreferences(ctx);
		Log.d(TAG, "onCreate");   		
	}
	
	@Override
	public void onDestroy() {
		super.onDestroy();
		Toast.makeText(this, "My Service Stopped", Toast.LENGTH_LONG).show(); 	
		// Stop Timer
		if(timer != null) {
			timer.cancel();
			timer.purge();
			timer = null;
		}
				
		// Stop WiFi
		wifi = null;
						
		// Stop GpS
		GPS.stop(ctx);
	}
	
	@Override
	public void onStart(Intent intent, int startid) {
		Toast.makeText(this, "My Service Started", Toast.LENGTH_LONG).show();
		Log.d(TAG, "onStart");
		timer = new Timer();
		// Setup WiFi
		wifi = (WifiManager) getSystemService(Context.WIFI_SERVICE);
		wifi.startScan();		
		//Setup GpS
		GPS.start(ctx);
		//Setup Timer
		Integer RefreshInterval = Integer.parseInt(sharedPrefs.getString("wifidb_upload_interval", "10000"));
		Log.d(TAG, "RefreshInterval:" + RefreshInterval);
		timer.scheduleAtFixedRate(new ScanTask(), 0, RefreshInterval);
		timer.scheduleAtFixedRate(new UploadTask(), 0, RefreshInterval);
	}
	
	private class UploadTask extends TimerTask
    { 
        public void run() 
        {
        	// Get Prefs
        	String WifiDb_ApiURL = sharedPrefs.getString("wifidb_upload_api_url", "@string/default_wifidb_upload_api_url");
        	String WifiDb_Username = sharedPrefs.getString("wifidb_username", "@string/default_wifidb_username"); 
        	String WifiDb_ApiKey = sharedPrefs.getString("wifidb_upload_apikey", "@string/default_wifidb_upload_apikey");     	
        	String WifiDb_SID = "1";
        	Log.d(TAG, "WifiDb_ApiURL: " + WifiDb_ApiURL + " WifiDb_Username: " + WifiDb_Username + " WifiDb_ApiKey: " + WifiDb_ApiKey + " WifiDb_SID: " + WifiDb_SID);
	    		       	
        	// Upload APs
        	DatabaseHandler db = new DatabaseHandler(ctx);
        	db.UploadToWifiDB(WifiDb_ApiURL, WifiDb_Username, WifiDb_ApiKey);
        }
    }    
	
	private class ScanTask extends TimerTask
    { 
        public void run() 
        {
        	//Get Current Time
        	SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS", Locale.US);
        	String currentDateandTime = sdf.format(new Date());
        	
        	//Initiate Wifi Scan
        	wifi.startScan();

        	// Get Location
        	Location location = GPS.getLocation(ctx);
        	final Double latitude = location.getLatitude();
        	final Double longitude = location.getLongitude();
        	final float Accuracy = location.getAccuracy();
        	final double Altitude = location.getAltitude();
        	final float Bearing = location.getBearing();
        	final Bundle Extras = location.getExtras();
        	final String Provider = location.getProvider();
        	final float Speed = location.getSpeed();
        	
        	Integer sats = GPS.getSats(ctx);
        	Log.d(TAG, "LAT: " + latitude.toString()
        			+ " LONG: " + longitude.toString()
        			+ " Accuracy: " + Accuracy
        			+ " Altitude: " + Altitude
        			+ " Bearing: " + Bearing 
        			+ " Extras" + Extras.toString()
        			+ " Provider: " + Provider 
        			+ " Speed: " + Speed 
        			+ " sats: " + sats);
        	
        	DatabaseHandler db = new DatabaseHandler(ctx);
        	long GpsID = db.addGPS(latitude, longitude, sats, Accuracy, Altitude, Speed, Bearing, currentDateandTime);     	

        	// Get Wifi Info
        	List<ScanResult> results = ScanService.wifi.getScanResults();
        	for (ScanResult result : results) {  
        		long ApID = db.addAP(GpsID, result.BSSID, result.SSID, result.frequency, result.capabilities, result.level, currentDateandTime);
        		long HistID = db.addHist(ApID, GpsID, result.level, currentDateandTime);
        		Log.d(TAG, "GpsID:" + GpsID
        					+ " HistID:" + HistID
        					+ " ApID:" + ApID 
        					+ " SSID:" + result.SSID
        					+ " BSSID:" + result.BSSID 
        					+ " capabilities:" + result.capabilities
        					+ " freq:" + result.frequency 
        					+ " level:" + result.level);
     	    }
        }
    }	
}