package com.decibel.decibel_sdk

import android.util.Log
import androidx.annotation.NonNull
import com.decibel.builder.prod.Decibel
import com.decibel.common.enums.PlatformType
import com.decibel.common.internal.models.Customer
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodChannel

/** DecibelSdkPlugin */
class DecibelSdkPlugin: FlutterPlugin, Messages.DecibelSdkApi {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    Messages.DecibelSdkApi.setup(flutterPluginBinding.binaryMessenger, this)
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    Messages.DecibelSdkApi.setup(binding.binaryMessenger, null)
  }

  override fun initialize(arg: Messages.SessionMessage?) {
//    Log.d("LOGTAG", "init")
    arg?.let {
      Decibel.sdk.initialize(Customer(it.account, it.property), PlatformType.FLUTTER)
    }
  }

  override fun startScreen(msg: Messages.StartScreenMessage?) {
    msg?.let {
      Decibel.sdk.startScreen(it.screenId, it.screenName, it.startTime)
    }
  }

  override fun endScreen(msg: Messages.EndScreenMessage?) {
    msg?.let {
      Decibel.sdk.endScreen(it.screenId, it.screenName, it.endTime)
    }
  }

  override fun setEnableConsents(arg: Messages.ConsentsMessage?) {
    TODO("Not yet implemented")
  }

  override fun setDisableConsents(arg: Messages.ConsentsMessage?) {
    TODO("Not yet implemented")
  }

  override fun saveScreenshot(arg: Messages.ScreenshotMessage?) {
    arg?.let {
//      Log.d("LOGTAG", "sendScreenshot with bytearray.size ${it.screenshotData.size}")
      Decibel.sdk.saveScreenShot(it.screenshotData, it.screenId, it.screenName, it.startFocusTime)
    }
  }

  override fun sendDimensionWithString(msg: Messages.DimensionStringMessage?) {
    msg?.let {
      Decibel.sdk.sendCustomDimension(msg.dimensionName, msg.value)
    }
  }

  override fun sendDimensionWithNumber(msg: Messages.DimensionNumberMessage?) {
    msg?.let {
      Decibel.sdk.sendCustomDimension(msg.dimensionName, msg.value)
    }
  }

  override fun sendDimensionWithBool(msg: Messages.DimensionBoolMessage?) {
    msg?.let {
      Decibel.sdk.sendCustomDimension(msg.dimensionName, msg.value)
    }
  }

  override fun sendGoal(msg: Messages.GoalMessage?) {
    msg?.let {
      Decibel.sdk.sendGoal(msg.goal, msg.value)
    }
  }
}