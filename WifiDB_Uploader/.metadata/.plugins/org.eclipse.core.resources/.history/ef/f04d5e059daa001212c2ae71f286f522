package com.eiri.wifidb_uploader;

import java.util.List;


import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.location.Location;
import android.net.wifi.ScanResult;
import android.preference.PreferenceManager;
import android.util.Log;


public class WiFiScanReceiver extends BroadcastReceiver {
  private static final String TAG = "WiFiDB_WiFiScanReceiver";
  ScanService ScanService;

  public WiFiScanReceiver(ScanService ScanService) {
    super();
    this.ScanService = ScanService;
  }

  @Override
  public void onReceive(Context c, Intent intent) {
	  
    List<ScanResult> results = ScanService.wifi.getScanResults();

    for (ScanResult result : results) {
    	Log.d(TAG, "onReceive() http post");
    	WifiDB post = new WifiDB();
    	//Log.d(TAG, "onReceive() get gps");
    	//GPS gps = new GPS(c);
    	//if(!gps.canGetLocation())
    	//{
    	//	gps.showSettingsAlert();
    	//}
    	//Integer sats = gps.getSats();
	    //Location location = gps.getLocation();
	    //double latitude_str = location.getLatitude();
	    //double longitude_str = location.getLongitude();
	    
	    SharedPreferences sharedPrefs = PreferenceManager.getDefaultSharedPreferences(c);
	    String WifiDb_ApiURL = sharedPrefs.getString("wifidb_upload_api_url", "https://api.wifidb.net/");
	    String WifiDb_Username = sharedPrefs.getString("wifidb_username", "Anonymous"); 
	    String WifiDb_ApiKey = sharedPrefs.getString("wifidb_upload_api_url", ""); 
    	
	    String latitude_str = "";
	    String longitude_str = "";
	    String sats = "";
	    Log.d(TAG, "LAT: " + latitude_str + "LONG: " + longitude_str + "SATS: " + sats);
    	post.postLiveData(WifiDb_ApiURL, result.SSID, result.BSSID, result.capabilities, result.frequency, result.level, latitude_str, longitude_str);
    }

  }

public static String getTag() {
	return TAG;
}
}