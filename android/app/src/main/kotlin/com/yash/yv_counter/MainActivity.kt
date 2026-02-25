package com.yash.yv_counter

import io.flutter.embedding.android.FlutterActivity
import com.yash.YVCounter.BuildConfig
import android.os.Bundle
import android.util.Log
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
	override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
		super.configureFlutterEngine(flutterEngine)
		MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "yv_counter/config")
			.setMethodCallHandler { call, result ->
				when (call.method) {
					"getServerClientId" -> result.success(BuildConfig.SERVER_CLIENT_ID)
					else -> result.notImplemented()
				}
			}
	}

	override fun onCreate(savedInstanceState: Bundle?) {
		super.onCreate(savedInstanceState)
		// Fallback: if a FlutterEngine is already attached, register the channel there too.
		try {
			val engine = this.flutterEngine
			if (engine != null) {
				MethodChannel(engine.dartExecutor.binaryMessenger, "yv_counter/config")
					.setMethodCallHandler { call, result ->
						when (call.method) {
							"getServerClientId" -> result.success(BuildConfig.SERVER_CLIENT_ID)
							else -> result.notImplemented()
						}
					}
			}
		} catch (e: Exception) {
			Log.d("MainActivity - onCreate error:", "${e.toString()}")
		}
	}
}
