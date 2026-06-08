package com.momentum.app.ui.dashboard

import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.tween
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Favorite
import androidx.compose.material.icons.filled.LocalFireDepartment
import androidx.compose.material.icons.filled.NightlightRound
import androidx.compose.material.icons.filled.SelfImprovement
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.LinearProgressIndicator
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.momentum.app.models.CalendarIntensity
import com.momentum.app.models.DailyMetrics
import com.momentum.app.models.DayScore
import com.momentum.app.models.EnergyLevel
import com.momentum.app.models.Insight
import com.momentum.app.models.StressLevel
import com.momentum.app.ui.design.GlassCard
import com.momentum.app.ui.design.MomentumCard
import com.momentum.app.ui.design.ScoreRing
import com.momentum.app.ui.theme.MomentumColors
import com.momentum.app.ui.theme.TextPrimary
import com.momentum.app.ui.theme.TextSecondary
import com.momentum.app.ui.theme.TextTertiary
import com.momentum.app.ui.theme.energyToColor

@Composable
fun DashboardScreen(
    metrics: DailyMetrics?,
    dayScore: DayScore?,
    insights: List<Insight>,
    onOpenBreathing: () -> Unit = {},
    onOpenReels: () -> Unit = {},
    onOpenFocus: () -> Unit = {}
) {
    val energyBlobOffset by animateFloatAsState(
        targetValue = if (metrics?.energyLevel?.ordinal ?: 2 >= 3) 1f else 0f,
        animationSpec = tween(2000),
        label = "energyBlob"
    )

    LazyColumn(
        modifier = Modifier
            .fillMaxSize()
            .background(MomentumColors.background)
            .padding(horizontal = 16.dp),
        verticalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        item {
            Spacer(modifier = Modifier.height(16.dp))
        }

        item {
            EnergyBlob(metrics, energyBlobOffset)
        }

        item {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceEvenly
            ) {
                ScoreRing(
                    score = dayScore?.energy ?: 0,
                    ringColor = MomentumColors.energy,
                    label = "Energy",
                    size = 90
                )
                ScoreRing(
                    score = dayScore?.focus ?: 0,
                    ringColor = MomentumColors.focus,
                    label = "Focus",
                    size = 90
                )
                ScoreRing(
                    score = dayScore?.stress ?: 0,
                    ringColor = MomentumColors.stress,
                    label = "Stress",
                    size = 90
                )
                ScoreRing(
                    score = dayScore?.overall ?: 0,
                    ringColor = MomentumColors.teal,
                    label = "Overall",
                    size = 90
                )
            }
        }

        item {
            EnergyForecast(metrics)
        }

        item {
            AntiBurnoutShield(metrics, onOpenBreathing)
        }

        if (insights.isNotEmpty()) {
            item {
                Text(
                    "Daily Insights",
                    style = MaterialTheme.typography.titleMedium,
                    color = TextPrimary,
                    fontWeight = FontWeight.Bold
                )
            }

            items(insights.take(3)) { insight ->
                MomentumCard(glowColor = categoryColor(insight.category.name)) {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Icon(
                            imageVector = Icons.Default.SelfImprovement,
                            contentDescription = null,
                            tint = categoryColor(insight.category.name),
                            modifier = Modifier.size(24.dp)
                        )
                        Spacer(modifier = Modifier.width(12.dp))
                        Column {
                            Text(
                                insight.title,
                                style = MaterialTheme.typography.bodyMedium,
                                fontWeight = FontWeight.SemiBold,
                                color = TextPrimary
                            )
                            Text(
                                insight.message,
                                style = MaterialTheme.typography.bodySmall,
                                color = TextSecondary,
                                maxLines = 2
                            )
                        }
                    }
                }
            }
        }

        item {
            WeeklySummary(metrics)
            Spacer(modifier = Modifier.height(16.dp))
        }
    }
}

@Composable
private fun EnergyBlob(metrics: DailyMetrics?, offset: Float) {
    val energyColor = energyToColor(metrics?.energyLevel?.ordinal ?: 2)
    Box(
        modifier = Modifier
            .fillMaxWidth()
            .height(120.dp),
        contentAlignment = Alignment.Center
    ) {
        Canvas(modifier = Modifier.fillMaxSize()) {
            val cx = size.width / 2
            val cy = size.height / 2
            val path = Path().apply {
                moveTo(cx, cy - 40)
                cubicTo(
                    cx + 30 + offset * 10, cy - 35,
                    cx + 40, cy - 10,
                    cx + 35, cy + 10
                )
                cubicTo(
                    cx + 30, cy + 30,
                    cx + 10, cy + 40,
                    cx, cy + 35
                )
                cubicTo(
                    cx - 10, cy + 40,
                    cx - 30, cy + 30,
                    cx - 35, cy + 10
                )
                cubicTo(
                    cx - 40, cy - 10,
                    cx - 30 - offset * 10, cy - 35,
                    cx, cy - 40
                )
                close()
            }
            drawPath(
                path,
                brush = Brush.verticalGradient(
                    colors = listOf(energyColor.copy(alpha = 0.6f), energyColor.copy(alpha = 0.2f))
                )
            )
        }
        Column(horizontalAlignment = Alignment.CenterHorizontally) {
            Text(
                metrics?.energyLevel?.name ?: "Unknown",
                style = MaterialTheme.typography.headlineSmall,
                fontWeight = FontWeight.Bold,
                color = energyColor
            )
            Text(
                "Current Energy",
                style = MaterialTheme.typography.bodySmall,
                color = TextSecondary
            )
        }
    }
}

@Composable
private fun EnergyForecast(metrics: DailyMetrics?) {
    MomentumCard(glowColor = MomentumColors.energy) {
        Text(
            "Energy Forecast",
            style = MaterialTheme.typography.titleSmall,
            fontWeight = FontWeight.Bold,
            color = TextPrimary
        )
        Spacer(modifier = Modifier.height(8.dp))
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceEvenly
        ) {
            EnergyBlock("Now", metrics?.energyLevel?.name ?: "--", energyToColor(metrics?.energyLevel?.ordinal ?: 2))
            EnergyBlock("Next", predictedEnergyLabel(metrics, 1), MomentumColors.energy)
            EnergyBlock("Evening", predictedEnergyLabel(metrics, 2), MomentumColors.focus)
            EnergyBlock("TOM", predictedEnergyLabel(metrics, 3), MomentumColors.recovery)
        }
    }
}

@Composable
private fun EnergyBlock(label: String, value: String, color: Color) {
    Column(horizontalAlignment = Alignment.CenterHorizontally) {
        Box(
            modifier = Modifier
                .size(8.dp)
                .clip(CircleShape)
                .background(color)
        )
        Spacer(modifier = Modifier.height(4.dp))
        Text(value, fontSize = 9.sp, color = TextPrimary, fontWeight = FontWeight.Bold)
        Text(label, fontSize = 8.sp, color = TextTertiary)
    }
}

@Composable
private fun AntiBurnoutShield(metrics: DailyMetrics?, onOpenBreathing: () -> Unit) {
    val riskLevel = metrics?.stressLevel?.ordinal ?: 1
    val riskColor = when {
        riskLevel >= StressLevel.High.ordinal -> MomentumColors.stress
        riskLevel >= StressLevel.Moderate.ordinal -> MomentumColors.energy
        else -> MomentumColors.recovery
    }
    val shieldProgress = 1f - (riskLevel.toFloat() / 3f)

    MomentumCard(glowColor = riskColor) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Column(modifier = Modifier.weight(1f)) {
                Text(
                    "Anti-Burnout Shield",
                    style = MaterialTheme.typography.titleSmall,
                    fontWeight = FontWeight.Bold,
                    color = TextPrimary
                )
                Spacer(modifier = Modifier.height(4.dp))
                LinearProgressIndicator(
                    progress = { shieldProgress },
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(6.dp)
                        .clip(RoundedCornerShape(3.dp)),
                    color = riskColor,
                    trackColor = MomentumColors.surface
                )
                Spacer(modifier = Modifier.height(4.dp))
                Text(
                    when {
                        shieldProgress > 0.7 -> "You're in good shape"
                        shieldProgress > 0.4 -> "Moderate risk - take breaks"
                        else -> "High risk - recovery needed"
                    },
                    fontSize = 11.sp,
                    color = TextSecondary
                )
            }
            Spacer(modifier = Modifier.width(12.dp))
            Button(
                onClick = onOpenBreathing,
                colors = ButtonDefaults.buttonColors(containerColor = MomentumColors.teal),
                shape = RoundedCornerShape(12.dp),
                modifier = Modifier.height(40.dp)
            ) {
                Icon(Icons.Default.SelfImprovement, "Breathe", modifier = Modifier.size(18.dp))
                Spacer(modifier = Modifier.width(4.dp))
                Text("Breathe", fontSize = 12.sp)
            }
        }
    }
}

@Composable
private fun WeeklySummary(metrics: DailyMetrics?) {
    GlassCard(modifier = Modifier.fillMaxWidth()) {
        Text(
            "Weekly Summary",
            style = MaterialTheme.typography.titleSmall,
            fontWeight = FontWeight.Bold,
            color = TextPrimary
        )
        Spacer(modifier = Modifier.height(8.dp))
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween
        ) {
            StatItem(Icons.Default.NightlightRound, "Sleep", "${String.format("%.1f", metrics?.sleepHours ?: 0.0)}h")
            StatItem(Icons.Default.LocalFireDepartment, "Steps", "${metrics?.steps ?: 0}")
            StatItem(Icons.Default.Favorite, "HRV", "${String.format("%.0f", metrics?.heartRateVariability ?: 0.0)}")
        }
    }
}

@Composable
private fun StatItem(icon: androidx.compose.ui.graphics.vector.ImageVector, label: String, value: String) {
    Column(horizontalAlignment = Alignment.CenterHorizontally) {
        Icon(icon, null, tint = MomentumColors.teal, modifier = Modifier.size(20.dp))
        Spacer(modifier = Modifier.height(4.dp))
        Text(value, fontSize = 13.sp, fontWeight = FontWeight.Bold, color = TextPrimary)
        Text(label, fontSize = 9.sp, color = TextTertiary)
    }
}

private fun predictedEnergyLabel(metrics: DailyMetrics?, hourOffset: Int): String {
    val base = metrics?.energyLevel?.ordinal ?: 2
    val predicted = (base + hourOffset - 1).coerceIn(0, 4)
    return EnergyLevel.values()[predicted].name
}

private fun categoryColor(category: String): Color {
    return MomentumColors.categoryColors[category.lowercase()] ?: MomentumColors.teal
}
