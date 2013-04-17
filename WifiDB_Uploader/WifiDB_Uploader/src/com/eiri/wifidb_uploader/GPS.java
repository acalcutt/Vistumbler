package com.eiri.wifidb_uploader;

import java.util.List;

import android.content.Context;
import android.location.Location;
import android.location.LocationManager;

public class GPS {
	private double[] getGPS() {
		 LocationManager lm = (LocationManager) getSystemService(Context.LOCATION_SERVICE);
		 List<String> providers = lm.getProviders(true);
	
		 Location l = null;
		 
		 for (int i=providers.size()-1; i>=0; i--) {
		  l = lm.getLastKnownLocation(providers.get(i));
		  if (l != null) break;
		 }
		 
		 double[] gps = new double[2];
		 if (l != null) {
		  gps[0] = l.getLatitude();
		  gps[1] = l.getLongitude();
		 }
	
		 return gps;
	}

	private LocationManager getSystemService(String locationService) {
		// TODO Auto-generated method stub
		return null;
	}
}