package io.github.zyrouge.yukino;

import android.webkit.WebSettings;
import android.content.res.Configuration;

import com.getcapacitor.BridgeActivity;

public class MainActivity extends BridgeActivity {
    @Override
    public void onStart() {
        super.onStart();

        int nightModeFlags = getResources().getConfiguration().uiMode & Configuration.UI_MODE_NIGHT_MASK;
        WebSettings webSettings = this.bridge.getWebView().getSettings();
        if (nightModeFlags == Configuration.UI_MODE_NIGHT_YES) {
            webSettings.setUserAgentString(webSettings.getUserAgentString() + " ExclusiveDarkUI");
        }
    }
}
