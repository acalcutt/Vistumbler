package com.eiri.wifidb_uploader;

import java.util.List;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.location.Criteria;
import android.location.Location;
import android.location.LocationManager;
import android.net.wifi.ScanResult;
import android.net.wifi.WifiManager;
import android.util.Log;
import android.widget.Toast;

public class WiFiScanReceiver extends BroadcastReceiver {
  private static final String TAG = "WiFiScanReceiver";
  WiFiDemo wifiDemo;

  public WiFiScanReceiver(WiFiDemo wifiDemo) {
    super();
    this.wifiDemo = wifiDemo;
  }

  @Override
  public void onReceive(Context c, Intent intent) {
    List<ScanResult> results = wifiDemo.wifi.getScanResults();
    ScanResult bestSignal = null;
    Context act = null;
	@SuppressWarnings("null")
	LocationManager lm = (LocationManager)act.getSystemService(Context.LOCATION_SERVICE);
    Criteria crit = new Criteria();
    crit.setAccuracy(Criteria.ACCURACY_FINE);
    String provider = lm.getBestProvider(crit, true);
    for (ScanResult result : results) {
    	Location loc = lm.getLastKnownLocation(provider);
    	Double latitude = loc.getLatitude();
    	String latitude_str = latitude.toString();
    	
    	Double longitude = loc.getLongitude();
    	String longitude_str = longitude.toString();
    	Log.d("", "HTTP Receive message: " + longitude_str + " --- " + latitude_str);
    	Post post = new Post();
		post.postData("SSID TEST", "MAC TEST", "CAPABILITIES", "", "", latitude_str, longitude_str);
      if (bestSignal == null
          || WifiManager.compareSignalLevel(bestSignal.level, result.level) < 0)
        bestSignal = result;
    }

    String message = String.format("%s networks found. %s is the strongest.",
        results.size(), bestSignal.SSID);
    Toast.makeText(wifiDemo, message, Toast.LENGTH_LONG).show();

    Log.d(TAG, "onReceive() message: " + message);
  }
}