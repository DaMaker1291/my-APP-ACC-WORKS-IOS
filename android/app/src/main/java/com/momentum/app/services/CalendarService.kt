package com.momentum.app.services

import android.Manifest
import android.content.ContentResolver
import android.content.Context
import android.content.pm.PackageManager
import android.provider.CalendarContract
import androidx.core.content.ContextCompat
import com.momentum.app.models.CalendarIntensity
import java.util.Date

class CalendarService(private val context: Context) {

    private val contentResolver: ContentResolver = context.contentResolver

    fun hasCalendarPermission(): Boolean {
        return ContextCompat.checkSelfPermission(
            context, Manifest.permission.READ_CALENDAR
        ) == PackageManager.PERMISSION_GRANTED
    }

    fun fetchTodayEvents(): List<CalendarEvent> {
        if (!hasCalendarPermission()) return emptyList()

        val events = mutableListOf<CalendarEvent>()
        val now = System.currentTimeMillis()
        val startOfDay = getStartOfDay(now)
        val endOfDay = getEndOfDay(now)

        val projection = arrayOf(
            CalendarContract.Events._ID,
            CalendarContract.Events.TITLE,
            CalendarContract.Events.DESCRIPTION,
            CalendarContract.Events.DTSTART,
            CalendarContract.Events.DTEND,
            CalendarContract.Events.ALL_DAY,
            CalendarContract.Events.DURATION
        )

        val selection = "${CalendarContract.Events.DTSTART} >= ? AND ${CalendarContract.Events.DTSTART} <= ?"
        val selectionArgs = arrayOf(startOfDay.toString(), endOfDay.toString())

        try {
            val cursor = contentResolver.query(
                CalendarContract.Events.CONTENT_URI,
                projection,
                selection,
                selectionArgs,
                "${CalendarContract.Events.DTSTART} ASC"
            )

            cursor?.use {
                while (it.moveToNext()) {
                    val id = it.getLong(it.getColumnIndexOrThrow(CalendarContract.Events._ID))
                    val title = it.getString(it.getColumnIndexOrThrow(CalendarContract.Events.TITLE)) ?: "Untitled"
                    val description = it.getString(it.getColumnIndexOrThrow(CalendarContract.Events.DESCRIPTION)) ?: ""
                    val dtStart = it.getLong(it.getColumnIndexOrThrow(CalendarContract.Events.DTSTART))
                    val dtEnd = it.getLong(it.getColumnIndexOrThrow(CalendarContract.Events.DTEND))
                    val allDay = it.getInt(it.getColumnIndexOrThrow(CalendarContract.Events.ALL_DAY)) == 1

                    events.add(
                        CalendarEvent(
                            id = id,
                            title = title,
                            description = description,
                            startTime = dtStart,
                            endTime = dtEnd,
                            allDay = allDay
                        )
                    )
                }
            }
        } catch (_: Exception) {
        }

        return events
    }

    fun calculateIntensity(events: List<CalendarEvent>): CalendarIntensity {
        if (events.isEmpty()) return CalendarIntensity.Low

        val now = System.currentTimeMillis()
        val activeHours = events.filter { !it.allDay }.map { it.startTime to it.endTime }

        val overlapCount = activeHours.count { (start, end) ->
            start <= now && now <= end
        }

        val totalDurationMinutes = activeHours.sumOf { (start, end) ->
            (end - start) / 60000
        }

        val meetingBackToBack = countBackToBack(activeHours)

        val score = (overlapCount * 10) + (totalDurationMinutes / 30) + (meetingBackToBack * 5)

        return when {
            score > 50 -> CalendarIntensity.Overwhelming
            score > 30 -> CalendarIntensity.High
            score > 15 -> CalendarIntensity.Medium
            else -> CalendarIntensity.Low
        }
    }

    private fun countBackToBack(activeHours: List<Pair<Long, Long>>): Int {
        if (activeHours.size < 2) return 0
        var count = 0
        for (i in 1 until activeHours.size) {
            val gap = activeHours[i].first - activeHours[i - 1].second
            if (gap in 0..300000) count++
        }
        return count
    }

    private fun getStartOfDay(now: Long): Long {
        val cal = java.util.Calendar.getInstance().apply { timeInMillis = now }
        cal.set(java.util.Calendar.HOUR_OF_DAY, 0)
        cal.set(java.util.Calendar.MINUTE, 0)
        cal.set(java.util.Calendar.SECOND, 0)
        cal.set(java.util.Calendar.MILLISECOND, 0)
        return cal.timeInMillis
    }

    private fun getEndOfDay(now: Long): Long {
        val cal = java.util.Calendar.getInstance().apply { timeInMillis = now }
        cal.set(java.util.Calendar.HOUR_OF_DAY, 23)
        cal.set(java.util.Calendar.MINUTE, 59)
        cal.set(java.util.Calendar.SECOND, 59)
        cal.set(java.util.Calendar.MILLISECOND, 999)
        return cal.timeInMillis
    }

    data class CalendarEvent(
        val id: Long,
        val title: String,
        val description: String,
        val startTime: Long,
        val endTime: Long,
        val allDay: Boolean
    )
}
