package com.eiri.wifidb_uploader;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.ResultReceiver;
import android.os.StrictMode;
import android.util.Log;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.Switch;
import android.widget.TextView;

public class WiFiDemo extends Activity implements OnClickListener {
	private static final String TAG = "WiFiDemo";
	Switch ScanSwitch;
	TextView textStatus;
	Button buttonScan;
	MyResultReceiver resultReceiver;

	/** Called when the activity is first created. */
	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.main);
		
		StrictMode.setThreadPolicy(new StrictMode.ThreadPolicy.Builder()
	       .detectNetwork() // or .detectAll() for all detectable problems
	       .penaltyDialog()  //show a dialog
	       .permitNetwork() //permit Network access 
	       .build());

		// Setup UI
		resultReceiver = new MyResultReceiver(null);
		ScanSwitch = (Switch) findViewById(R.id.ScanSwitch);
		ScanSwitch.setOnClickListener(this);

		Log.d(TAG, "onCreate()");
	}

	public void onClick(View src) {
		switch (src.getId()) {
		    case R.id.ScanSwitch:
		    	Log.d(TAG, "ScanSwitch Pressed");
		      	ScanSwitch = (Switch) findViewById(R.id.ScanSwitch);
		      	if (ScanSwitch.isChecked()){
		      		Log.d(TAG, "Start Scan");
		      		startService(new Intent(this, ScanService.class));
		      		ScanSwitch.setChecked(true);
		      	} else {
		      		Log.d(TAG, "Stop Scan");
		      		stopService(new Intent(this, ScanService.class));
		      		ScanSwitch.setChecked(false);
		        }
		      	break;
	    }

	}
	class MyResultReceiver extends ResultReceiver
	{
		public MyResultReceiver(Handler handler) {
			super(handler);
		}
		
		@Override
		protected void onReceiveResult(int resultCode, Bundle resultData) 
		{
			Log.d(TAG, resultData.toString());
			if(resultCode == 100){
				textStatus.append("\n\nWiFi Status: " + resultData.toString());
			}
		}	
	}
}
