package com.momentum.app.services

import android.content.Context
import android.content.SharedPreferences
import com.google.gson.Gson
import com.momentum.app.models.CalendarIntensity
import com.momentum.app.models.DailyMetrics
import com.momentum.app.models.EnergyLevel
import com.momentum.app.models.SleepQuality
import com.momentum.app.models.StressLevel
import java.time.LocalDate

class DataService(private val context: Context) {

    companion object {
        private const val PREFS_NAME = "momentum_data"
        private const val KEY_METRICS_PREFIX = "metrics_"
        private const val KEY_CURRENT_DATE = "current_date"
    }

    private val prefs: SharedPreferences =
        context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
    private val gson = Gson()

    fun saveMetrics(metrics: DailyMetrics) {
        val key = KEY_METRICS_PREFIX + metrics.date.toString()
        val json = gson.toJson(MetricData(
            sleepHours = metrics.sleepHours,
            sleepQuality = metrics.sleepQuality.name,
            steps = metrics.steps,
            heartRateAvg = metrics.heartRateAvg,
            heartRateVariability = metrics.heartRateVariability,
            screenTimeMinutes = metrics.screenTimeMinutes,
            focusScore = metrics.focusScore,
            energyLevel = metrics.energyLevel.name,
            stressLevel = metrics.stressLevel.name,
            calendarEventCount = metrics.calendarEventCount,
            calendarIntensity = metrics.calendarIntensity.name
        ))
        prefs.edit().putString(key, json).apply()
        prefs.edit().putString(KEY_CURRENT_DATE, metrics.date.toString()).apply()
    }

    fun loadMetrics(date: LocalDate): DailyMetrics? {
        val key = KEY_METRICS_PREFIX + date.toString()
        val json = prefs.getString(key, null) ?: return null
        try {
            val data = gson.fromJson(json, MetricData::class.java)
            return DailyMetrics(
                date = date,
                sleepHours = data.sleepHours,
                sleepQuality = SleepQuality.valueOf(data.sleepQuality),
                steps = data.steps,
                heartRateAvg = data.heartRateAvg,
                heartRateVariability = data.heartRateVariability,
                screenTimeMinutes = data.screenTimeMinutes,
                focusScore = data.focusScore,
                energyLevel = EnergyLevel.valueOf(data.energyLevel),
                stressLevel = StressLevel.valueOf(data.stressLevel),
                calendarEventCount = data.calendarEventCount,
                calendarIntensity = CalendarIntensity.valueOf(data.calendarIntensity)
            )
        } catch (_: Exception) {
            return null
        }
    }

    fun loadAllMetrics(): List<DailyMetrics> {
        val allKeys = prefs.all.keys.filter { it.startsWith(KEY_METRICS_PREFIX) }
        return allKeys.mapNotNull { key ->
            val json = prefs.getString(key, null) ?: return@mapNotNull null
            try {
                val data = gson.fromJson(json, MetricData::class.java)
                val dateStr = key.removePrefix(KEY_METRICS_PREFIX)
                val date = LocalDate.parse(dateStr)
                DailyMetrics(
                    date = date,
                    sleepHours = data.sleepHours,
                    sleepQuality = SleepQuality.valueOf(data.sleepQuality),
                    steps = data.steps,
                    heartRateAvg = data.heartRateAvg,
                    heartRateVariability = data.heartRateVariability,
                    screenTimeMinutes = data.screenTimeMinutes,
                    focusScore = data.focusScore,
                    energyLevel = EnergyLevel.valueOf(data.energyLevel),
                    stressLevel = StressLevel.valueOf(data.stressLevel),
                    calendarEventCount = data.calendarEventCount,
                    calendarIntensity = CalendarIntensity.valueOf(data.calendarIntensity)
                )
            } catch (_: Exception) {
                null
            }
        }
    }

    fun saveString(key: String, value: String) {
        prefs.edit().putString(key, value).apply()
    }

    fun getString(key: String, default: String = ""): String {
        return prefs.getString(key, default) ?: default
    }

    fun saveInt(key: String, value: Int) {
        prefs.edit().putInt(key, value).apply()
    }

    fun getInt(key: String, default: Int = 0): Int {
        return prefs.getInt(key, default)
    }

    fun saveFloat(key: String, value: Float) {
        prefs.edit().putFloat(key, value).apply()
    }

    fun getFloat(key: String, default: Float = 0f): Float {
        return prefs.getFloat(key, default)
    }

    fun saveBoolean(key: String, value: Boolean) {
        prefs.edit().putBoolean(key, value).apply()
    }

    fun getBoolean(key: String, default: Boolean = false): Boolean {
        return prefs.getBoolean(key, default)
    }

    fun clear() {
        prefs.edit().clear().apply()
    }

    private data class MetricData(
        val sleepHours: Double,
        val sleepQuality: String,
        val steps: Int,
        val heartRateAvg: Double,
        val heartRateVariability: Double,
        val screenTimeMinutes: Double,
        val focusScore: Int,
        val energyLevel: String,
        val stressLevel: String,
        val calendarEventCount: Int,
        val calendarIntensity: String
    )

    fun loadMetricsMap(): Map<String, DailyMetrics> {
        val allKeys = prefs.all.keys.filter { it.startsWith(KEY_METRICS_PREFIX) }
        val result = mutableMapOf<String, DailyMetrics>()
        allKeys.forEach { key ->
            val json = prefs.getString(key, null) ?: return@forEach
            try {
                val data = gson.fromJson(json, MetricData::class.java)
                val dateStr = key.removePrefix(KEY_METRICS_PREFIX)
                val date = LocalDate.parse(dateStr)
                result[dateStr] = DailyMetrics(
                    date = date,
                    sleepHours = data.sleepHours,
                    sleepQuality = SleepQuality.valueOf(data.sleepQuality),
                    steps = data.steps,
                    heartRateAvg = data.heartRateAvg,
                    heartRateVariability = data.heartRateVariability,
                    screenTimeMinutes = data.screenTimeMinutes,
                    focusScore = data.focusScore,
                    energyLevel = EnergyLevel.valueOf(data.energyLevel),
                    stressLevel = StressLevel.valueOf(data.stressLevel),
                    calendarEventCount = data.calendarEventCount,
                    calendarIntensity = CalendarIntensity.valueOf(data.calendarIntensity)
                )
            } catch (_: Exception) {
            }
        }
        return result
    }
}
