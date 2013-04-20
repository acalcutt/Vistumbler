package com.eiri.wifidb_uploader;

import android.os.Bundle;
import android.preference.PreferenceActivity;


public class QuickPrefsActivity extends PreferenceActivity {
    
    @Override
    public void onCreate(Bundle savedInstanceState) {        
        super.onCreate(savedInstanceState);        
        addPreferencesFromResource(R.xml.preferences);        
    }

}
