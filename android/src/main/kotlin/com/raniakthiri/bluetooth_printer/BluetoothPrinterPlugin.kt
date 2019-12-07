package com.raniakthiri.bluetooth_printer

import android.app.Activity
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.util.Log
import android.widget.Toast
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry
import io.flutter.plugin.common.PluginRegistry.Registrar

class BluetoothPrinterPlugin(private val activity: Activity, private val channel: MethodChannel, registrar: Registrar) : MethodCallHandler, PluginRegistry.ActivityResultListener {

    private var mBluetoothPlugin = BluetoothPlugin()
    private var mPrinterPlugin = PrinterPlugin()
    private var mBeanList: MutableList<Map<String, String>> = ArrayList()


    companion object {

        @JvmStatic
        fun registerWith(registrar: Registrar) {
            val channel = MethodChannel(registrar.messenger(), "bluetooth_printer/methodChannel")
            val plugin = BluetoothPrinterPlugin(registrar.activity(), channel, registrar)
            channel.setMethodCallHandler(plugin)

            registrar.addActivityResultListener(plugin)
        }

    }

    init {

        this.channel.setMethodCallHandler(this)

        EventChannel(registrar.messenger(), "bluetooth_printer/scanBlueToothEvent").setStreamHandler(
                object : EventChannel.StreamHandler {
                    override fun onListen(args: Any, events: EventChannel.EventSink) {
                        mBluetoothPlugin.setEventChannel(events)
                        Log.w("MainDprint", "adding listener")
                    }

                    override fun onCancel(args: Any) {
                        Log.w("MainDprint", "cancelling listener")
                    }
                }
        )
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        if (this.mBluetoothPlugin.isAdapterNull() && "isAvailable" != call.method) {
            result.error("bluetooth_unavailable", "the device does not have bluetooth", null)
            return
        }

        when (call.method) {
            "isConnected" -> {
                result.success(if(mPrinterPlugin.isConnected()) 1 else 0)
                if (!mPrinterPlugin.isConnected()) init()
            }
            "startScanBlueTooth" -> {
                init()
                mBeanList = ArrayList()
                mBluetoothPlugin.startScan(activity)
            }
            "getBoundDevices" -> getBoundDevices(result)
            "connectBlueTooth" -> connectToDevice(call, result)
            "print" -> printLabel(call, result)
            "imagePrint" -> printImage(call, result)
            "destroy" -> destroy()
            else -> result.notImplemented()
        }
    }


    private fun init() {
        mBluetoothPlugin.startBluetooth(activity)

        val filter = IntentFilter()
        filter.addAction(BluetoothDevice.ACTION_FOUND)
        filter.addAction(BluetoothAdapter.ACTION_DISCOVERY_STARTED)
        filter.addAction(BluetoothAdapter.ACTION_DISCOVERY_FINISHED)
        filter.addAction(BluetoothDevice.ACTION_ACL_CONNECTED)
        filter.addAction(BluetoothDevice.ACTION_ACL_DISCONNECT_REQUESTED)
        filter.addAction(BluetoothDevice.ACTION_ACL_DISCONNECTED)
        this.activity.registerReceiver(mReceiver, filter)
    }


    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode == BluetoothPlugin.REQUEST_ENABLE_BT && resultCode == Activity.RESULT_OK) {
            return true
        }
        return false
    }

    private fun getBoundDevices(result: Result) {
        val devices = mBluetoothPlugin.getBoundDevices()
        val list = devices?.map<BluetoothDevice?, Map<String, String>> { item ->
            mapOf<String, String>(Pair("name", item!!.name), Pair("address", item.address))
        }
        result.success(list)
    }

    private fun connectToDevice(call: MethodCall, result: Result) {
        val map = call.arguments as Map<*, *>
        val index = map["index"] as Int
        val device = mBeanList[index]

        activity.showToast("Connecting to ${device["name"]}...")

        try {
            val res = mPrinterPlugin.connectToPrinter(device, activity)
            if (res) 
                activity.showToast("Connected to ${device["name"]}")
            else 
            activity.showToast("Failed to connect !")

            result.success(if(res) 1 else 0)
        } catch (e: Exception) {
            e.printStackTrace()

            activity.showToast("Failed to connect !")
            result.success(0)
        }
    }

    private fun printLabel(call: MethodCall, result: Result) {
        if (this.mPrinterPlugin.isConnected()) {
            val label = call.arguments as Map<*, *>

            try {
                activity.showToast("Printing Label...")
                val res = mPrinterPlugin.printLabel(label)
                result.success(if(res) 1 else 0)
                return
            } catch (e: Exception) {
                activity.showToast("Error: ${e.message}")
            }
        }

        activity.showToast("Please connect to printer !")
        result.success(0)
        return
    }

    private fun printImage(call: MethodCall, result: Result) {
        if (this.mPrinterPlugin.isConnected()) {
            try {
                activity.showToast("Printing Label...")
                val args: List<*> = call.arguments as List<*>
                val image = args[0] as ByteArray
                val quantity = args[1] as Int
                val res = mPrinterPlugin.printImage(image, quantity)
                result.success(if(res) 1 else 0)
                return
            } catch (e: Exception) {
                activity.showToast("Error: ${e.message}")
            }
        }

        activity.showToast("Please connect to printer !")
        result.success(0)
        return
    }

    private fun destroy() {
        this.activity.unregisterReceiver(mReceiver)
        this.mBluetoothPlugin.destroy()
        this.mPrinterPlugin.destroy()
    }

    // Create a BroadcastReceiver for ACTION_FOUND.
    private val mReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            Log.d("MainReciever", intent.action)
            // Discovery has found a device. Get the BluetoothDevice
            // object and its info from the Intent.

            when (intent.action) {
                BluetoothDevice.ACTION_FOUND -> {
                    // Discovery has found a device. Get the BluetoothDevice
                    // object and its info from the Intent.
                    val device = intent.getParcelableExtra<BluetoothDevice>(BluetoothDevice.EXTRA_DEVICE)

//                    mBluetoothPlugin.sendMsg(mapOf<String, Any>(Pair("status", 0), Pair("name", device.name), Pair("address", device.address)))

                    mBeanList.add(mapOf(Pair("name", device.name), Pair("address", device.address)))
                    mBluetoothPlugin.sendMsg(mBeanList)

                }
//                BluetoothAdapter.ACTION_DISCOVERY_STARTED -> mBluetoothPlugin.sendMsg(mapOf<String, Any>(Pair("status", 1)))
//                BluetoothAdapter.ACTION_DISCOVERY_FINISHED -> mBluetoothPlugin.sendMsg(mapOf<String, Any>(Pair("status", 2)))

//                BluetoothDevice.ACTION_ACL_CONNECTED -> {
//                    if (mPrinterPlugin.isConnected())
//                        mBluetoothPlugin.sendMsg(mapOf<String, Any>(Pair("status", 3)))
//                }
//                BluetoothDevice.ACTION_ACL_DISCONNECT_REQUESTED ->
//                BluetoothDevice.ACTION_ACL_DISCONNECTED -> connected = false
            }
        }
    }

    private fun Activity.showToast(text: String) {
        Toast.makeText(this, text, Toast.LENGTH_SHORT).show()
    }

}
