package xyz.dokandar.user;

import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;

import io.flutter.app.FlutterApplication;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugins.firebasemessaging.FlutterFirebaseMessagingService;

public class ApplicationStatus extends FlutterApplication implements PluginRegistry.PluginRegistrantCallback {

    @Override
    public void onCreate() {
        super.onCreate();
        FirebaseOptions options = new FirebaseOptions.Builder()
                .setApplicationId("xyz.dokandar.user") // Required for Analytics.
                .setProjectId("dokandar-316216") // Required for Firebase Installations.
                .setApiKey("AIzaSyDNtJMAKKfqKgW8cjshI9n6AWE9CKQA5KE") // Required for Auth.
                .build();
        FirebaseApp.initializeApp(this,options,"Dokandar User");
        FlutterFirebaseMessagingService.setPluginRegistrant(this);
    }

    @Override
    public void registerWith(PluginRegistry registry) {
        FirebaseCloudMessagingPluginRegistrant.registerWith(registry);
    }
}
