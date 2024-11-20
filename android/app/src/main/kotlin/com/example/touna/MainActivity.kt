package com.example.touna

import android.content.ContentValues
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.media.MediaScannerConnection
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.Environment
import android.provider.MediaStore
import android.util.Log
import android.widget.Toast
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.IOException
import java.io.OutputStream

class MainActivity : FlutterActivity() {
    private lateinit var channel: MethodChannel

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        channel = MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, "touna")
        channel.setMethodCallHandler { call, result -> onMethodChannel(call, result) }

    }

    private fun onMethodChannel(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "save" -> {
                call.arguments.apply {
                    val data = this as Map<*, *>
                    val img = data["image"] as ByteArray
                    val path = data["path"] as String

                    val dir: String = Environment.DIRECTORY_PICTURES + File.separator + "absensi"

                    if (!File(dir).exists()) {
                        File(dir).mkdirs()
                    }

                    val contentValues = ContentValues().apply {
                        put(MediaStore.Images.ImageColumns.DISPLAY_NAME, path)
                        put(MediaStore.MediaColumns.MIME_TYPE, "image/png")

                        // without this part causes "Failed to create new MediaStore record" exception to be invoked (uri is null below)
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                            put(MediaStore.Images.ImageColumns.RELATIVE_PATH, dir)
                        }
                    }

                    val contentUri = MediaStore.Images.Media.EXTERNAL_CONTENT_URI
                    var stream: OutputStream? = null
                    var uri: Uri? = null

                    try {
                        uri = contentResolver.insert(contentUri, contentValues)
                        if (uri == null) {
                            throw IOException("Failed to create new MediaStore record.")
                        }

                        stream = contentResolver.openOutputStream(uri)

                        if (stream == null) {
                            throw IOException("Failed to get output stream.")
                        }
                        val bitmap = BitmapFactory.decodeByteArray(img, 0, img.lastIndex)

                        if (!bitmap.compress(Bitmap.CompressFormat.PNG, 100, stream)) {
                            throw IOException("Failed to save bitmap.")
                        }

                        Toast.makeText(context, "Saved", Toast.LENGTH_SHORT).show()
                    } catch (e: IOException) {
                        if (uri != null) {
                            contentResolver.delete(uri, null, null)
                        }
                        throw IOException(e)
                    } finally {
                        stream?.close()
                    }
                }

                if (Build.VERSION.SDK_INT <= Build.VERSION_CODES.Q) {
                    try {
                        @Suppress("DEPRECATION") sendBroadcast(
                            Intent(
                                Intent.ACTION_MEDIA_SCANNER_SCAN_FILE,
                                Uri.parse("file://" + Environment.getExternalStorageDirectory())
                            )
                        )
                        result.success("Success Via BROADCAST")
                    } catch (e: Exception) {
                        Log.e("BROADCAST_ERROR", e.toString())
                    }
                } else {
                    val file = call.argument<String>("file")
                    val mediaScanner =
                        object : MediaScannerConnection.MediaScannerConnectionClient {
                            override fun onScanCompleted(p0: String?, p1: Uri?) {
                                MediaScannerConnection.scanFile(
                                    context, arrayOf(file), null
                                ) { _, uri: Uri ->
                                    println("media scanned: ${uri.path}")
                                }
                            }

                            override fun onMediaScannerConnected() {
                                Log.d("", "Media scan completed")
                            }
                        }

                    val scanner = MediaScannerConnection(context, mediaScanner)
                    try {
                        scanner.connect()
                        scanner.scanFile(file, "image/png")
                        result.success("Success Via MediaScanner")
                    } catch (e: Exception) {
                        Log.d("MEDIA_SCANNER_ERROR", e.toString())
                    }
                }

            }
            "scan" -> {
                if (Build.VERSION.SDK_INT <= Build.VERSION_CODES.Q) {
                    try {
                        @Suppress("DEPRECATION") sendBroadcast(
                            Intent(
                                Intent.ACTION_MEDIA_SCANNER_SCAN_FILE,
                                Uri.parse("file://" + Environment.getExternalStorageDirectory())
                            )
                        )
                        result.success("Success Via BROADCAST")
                    } catch (e: Exception) {
                        Log.e("BROADCAST_ERROR", e.toString())
                    }
                } else {
                    val file = call.argument<String>("file")
                    val mediaScanner =
                        object : MediaScannerConnection.MediaScannerConnectionClient {
                            override fun onScanCompleted(p0: String?, p1: Uri?) {
                                MediaScannerConnection.scanFile(
                                    context, arrayOf(file), null
                                ) { _, uri: Uri ->
                                    println("media scanned: ${uri.path}")
                                }
                            }

                            override fun onMediaScannerConnected() {
                                Log.d("", "Media scan completed")
                            }
                        }

                    val scanner = MediaScannerConnection(context, mediaScanner)
                    try {
                        scanner.connect()
                        scanner.scanFile(file, "image/png")
                        result.success("Success Via MediaScanner")
                    } catch (e: Exception) {
                        Log.d("MEDIA_SCANNER_ERROR", e.toString())
                    }
                }
            }

            else -> {
                result.error("Not Implemented", null, null)
            }
        }
    }
}
