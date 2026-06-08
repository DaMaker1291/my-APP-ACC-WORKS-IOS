package com.momentum.app.services

import android.app.Activity
import android.content.Context
import com.google.android.gms.auth.api.signin.GoogleSignIn
import com.google.android.gms.fitness.Fitness
import com.google.android.gms.fitness.FitnessOptions
import com.google.android.gms.fitness.data.DataType
import com.google.android.gms.fitness.data.Field
import com.momentum.app.models.DailyMetrics
import com.momentum.app.models.EnergyLevel
import com.momentum.app.models.SleepQuality
import com.momentum.app.models.StressLevel
import java.time.LocalDate
import java.util.concurrent.TimeUnit

class HealthService(private val context: Context) {

    companion object {
        private const val STEPS_GOAL = 7500
    }

    private val fitnessOptions by lazy {
        FitnessOptions.builder()
            .addDataType(DataType.TYPE_STEP_COUNT_DELTA, FitnessOptions.ACCESS_READ)
            .addDataType(DataType.TYPE_HEART_RATE_BPM, FitnessOptions.ACCESS_READ)
            .addDataType(DataType.TYPE_HEART_RATE_VARIABILITY, FitnessOptions.ACCESS_READ)
            .addDataType(DataType.TYPE_SLEEP_SEGMENT, FitnessOptions.ACCESS_READ)
            .addDataType(DataType.TYPE_CALORIES_EXPENDED, FitnessOptions.ACCESS_READ)
            .build()
    }

    fun hasPermissions(): Boolean {
        val account = GoogleSignIn.getAccountForExtension(context, fitnessOptions)
        return GoogleSignIn.hasPermissions(account, fitnessOptions)
    }

    fun requestPermissions(activity: Activity, requestCode: Int = 1001) {
        val account = GoogleSignIn.getAccountForExtension(context, fitnessOptions)
        GoogleSignIn.requestPermissions(activity, requestCode, account, fitnessOptions)
    }

    fun fetchTodayMetrics(callback: (DailyMetrics) -> Unit) {
        val metrics = DailyMetrics()
        val account = GoogleSignIn.getAccountForExtension(context, fitnessOptions)

        if (!GoogleSignIn.hasPermissions(account, fitnessOptions)) {
            callback(metrics)
            return
        }

        val client = Fitness.getHistoryClient(context, account)
        val endTime = System.currentTimeMillis()
        val startTime = endTime - TimeUnit.DAYS.toMillis(1)

        client.readDailyData(DataType.TYPE_STEP_COUNT_DELTA, startTime, endTime)
            .addOnSuccessListener { response ->
                val totalSteps = response.iterator().asSequence()
                    .flatMap { ds -> ds.dataPoints.asSequence() }
                    .sumOf { it.getValue(Field.FIELD_STEPS).asInt() }
                metrics.steps = totalSteps
                fetchHeartRate(client, startTime, endTime, metrics, callback)
            }
            .addOnFailureListener {
                fetchHeartRate(client, startTime, endTime, metrics, callback)
            }
    }

    private fun fetchHeartRate(
        client: com.google.android.gms.fitness.HistoryClient,
        startTime: Long, endTime: Long,
        metrics: DailyMetrics,
        callback: (DailyMetrics) -> Unit
    ) {
        client.readDailyData(DataType.TYPE_HEART_RATE_BPM, startTime, endTime)
            .addOnSuccessListener { response ->
                val heartRates = response.iterator().asSequence()
                    .flatMap { ds -> ds.dataPoints.asSequence() }
                    .map { it.getValue(Field.FIELD_BPM).asFloat() }
                    .toList()
                if (heartRates.isNotEmpty()) {
                    metrics.heartRateAvg = heartRates.average()
                }
                fetchHRV(client, startTime, endTime, metrics, callback)
            }
            .addOnFailureListener {
                fetchHRV(client, startTime, endTime, metrics, callback)
            }
    }

    private fun fetchHRV(
        client: com.google.android.gms.fitness.HistoryClient,
        startTime: Long, endTime: Long,
        metrics: DailyMetrics,
        callback: (DailyMetrics) -> Unit
    ) {
        client.readDailyData(DataType.TYPE_HEART_RATE_VARIABILITY, startTime, endTime)
            .addOnSuccessListener { response ->
                val hrvValues = response.iterator().asSequence()
                    .flatMap { ds -> ds.dataPoints.asSequence() }
                    .map { it.getValue(Field.FIELD_HRV).asFloat() }
                    .toList()
                if (hrvValues.isNotEmpty()) {
                    metrics.heartRateVariability = hrvValues.average()
                }
                fetchSleep(client, startTime, endTime, metrics, callback)
            }
            .addOnFailureListener {
                fetchSleep(client, startTime, endTime, metrics, callback)
            }
    }

    private fun fetchSleep(
        client: com.google.android.gms.fitness.HistoryClient,
        startTime: Long, endTime: Long,
        metrics: DailyMetrics,
        callback: (DailyMetrics) -> Unit
    ) {
        client.readDailyData(DataType.TYPE_SLEEP_SEGMENT, startTime, endTime)
            .addOnSuccessListener { response ->
                val sleepMinutes = response.iterator().asSequence()
                    .flatMap { ds -> ds.dataPoints.asSequence() }
                    .sumOf { dp ->
                        val start = dp.getStartTime(TimeUnit.MILLISECONDS)
                        val end = dp.getEndTime(TimeUnit.MILLISECONDS)
                        (end - start)
                    }
                metrics.sleepHours = sleepMinutes / 60.0 / 1000.0
                inferMetrics(metrics)
                callback(metrics)
            }
            .addOnFailureListener {
                inferMetrics(metrics)
                callback(metrics)
            }
    }

    private fun inferMetrics(metrics: DailyMetrics) {
        if (metrics.sleepHours > 7) {
            metrics.sleepQuality = SleepQuality.Good
            metrics.energyLevel = if (metrics.steps > 3000) EnergyLevel.High else EnergyLevel.Moderate
        } else if (metrics.sleepHours > 5) {
            metrics.sleepQuality = SleepQuality.Average
            metrics.energyLevel = EnergyLevel.Moderate
        } else {
            metrics.sleepQuality = SleepQuality.Poor
            metrics.energyLevel = EnergyLevel.Low
        }

        metrics.stressLevel = when {
            metrics.steps < 1000 && metrics.sleepHours < 6 -> StressLevel.High
            metrics.steps < 3000 -> StressLevel.Moderate
            else -> StressLevel.Low
        }

        metrics.focusScore = ((metrics.sleepQuality.score / 100.0) * 40 +
                (metrics.heartRateVariability / 100.0) * 30 +
                (1.0 - metrics.steps.toDouble() / 10000.0).coerceIn(0.0, 1.0) * 30).toInt()
            .coerceIn(0, 100)
    }
}
