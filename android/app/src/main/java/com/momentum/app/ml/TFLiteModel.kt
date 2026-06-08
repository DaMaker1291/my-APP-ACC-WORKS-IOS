package com.momentum.app.ml

import android.content.Context
import android.content.res.AssetFileDescriptor
import com.momentum.app.models.FeatureVector
import org.tensorflow.lite.Interpreter
import java.io.FileInputStream
import java.nio.ByteBuffer
import java.nio.ByteOrder
import java.nio.MappedByteBuffer
import java.nio.channels.FileChannel

class TFLiteModel(private val context: Context) {

    companion object {
        private const val MODEL_FILENAME = "momentum_predictor.tflite"
        private const val INPUT_SIZE = 15
        private const val OUTPUT_SIZE = 3
    }

    private var interpreter: Interpreter? = null

    init {
        try {
            val model = loadModelFile()
            interpreter = Interpreter(model)
        } catch (_: Exception) {
        }
    }

    private fun loadModelFile(): MappedByteBuffer {
        val assetFileDescriptor: AssetFileDescriptor = context.assets.openFd(MODEL_FILENAME)
        val inputStream = FileInputStream(assetFileDescriptor.fileDescriptor)
        val fileChannel = inputStream.channel
        val startOffset = assetFileDescriptor.startOffset
        val declaredLength = assetFileDescriptor.declaredLength
        val mappedBuffer = fileChannel.map(FileChannel.MapMode.READ_ONLY, startOffset, declaredLength)
        return mappedBuffer
    }

    fun predict(features: FeatureVector): FloatArray? {
        val interpreter = interpreter ?: return null

        val inputBuffer = ByteBuffer.allocateDirect(INPUT_SIZE * 4)
        inputBuffer.order(ByteOrder.nativeOrder())

        inputBuffer.putFloat(features.dayOfWeek.toFloat())
        inputBuffer.putFloat(features.hour.toFloat())
        inputBuffer.putFloat(features.sleepHours.toFloat())
        inputBuffer.putFloat(features.sleepQualityScore.toFloat())
        inputBuffer.putFloat(features.steps.toFloat())
        inputBuffer.putFloat(features.heartRateAvg.toFloat())
        inputBuffer.putFloat(features.heartRateVariability.toFloat())
        inputBuffer.putFloat(features.screenTimeMinutes.toFloat())
        inputBuffer.putFloat(features.calendarIntensity.toFloat())
        inputBuffer.putFloat(features.previousDayEnergy.toFloat())
        inputBuffer.putFloat(features.previousDayStress.toFloat())
        inputBuffer.putFloat(features.previousDayFocus.toFloat())
        inputBuffer.putFloat(features.weekToDateSleepAvg.toFloat())
        inputBuffer.putFloat(features.weekToDateStepsAvg.toFloat())
        inputBuffer.putFloat(features.monthToDateFocusAvg.toFloat())

        val outputBuffer = Array(1) { FloatArray(OUTPUT_SIZE) }

        try {
            interpreter.run(inputBuffer, outputBuffer)
            return outputBuffer[0]
        } catch (_: Exception) {
            return null
        }
    }

    fun close() {
        interpreter?.close()
        interpreter = null
    }
}
