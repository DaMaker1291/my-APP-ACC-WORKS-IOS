package com.momentum.app.ui.nutrition

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
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
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.CameraAlt
import androidx.compose.material.icons.filled.Fastfood
import androidx.compose.material.icons.filled.LocalFireDepartment
import androidx.compose.material.icons.filled.Timer
import androidx.compose.material.icons.filled.Water
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.LinearProgressIndicator
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.momentum.app.models.FoodEntry
import com.momentum.app.models.Insight
import com.momentum.app.models.MealType
import com.momentum.app.ui.theme.MomentumColors
import com.momentum.app.ui.theme.TextPrimary
import com.momentum.app.ui.theme.TextSecondary
import com.momentum.app.ui.theme.TextTertiary

@Composable
fun NutritionScreen(
    entries: List<FoodEntry>,
    insights: List<Insight>,
    waterGlasses: Int,
    fastingActive: Boolean,
    fastingHours: Int,
    onOpenCamera: () -> Unit,
    onLogFood: () -> Unit,
    onWaterAdd: () -> Unit
) {
    val totalCalories = entries.sumOf { it.calories }.toInt()
    val totalProtein = entries.sumOf { it.protein }.toInt()
    val totalCarbs = entries.sumOf { it.carbs }.toInt()
    val totalFat = entries.sumOf { it.fat }.toInt()
    val calorieGoal = 2000

    LazyColumn(
        modifier = Modifier
            .fillMaxSize()
            .background(MomentumColors.background)
            .padding(horizontal = 16.dp),
        verticalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        item { Spacer(modifier = Modifier.height(8.dp)) }

        item {
            CameraHeroSection(onOpenCamera)
        }

        item {
            MacroBars(totalCalories, calorieGoal, totalProtein, totalCarbs, totalFat)
        }

        item {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceEvenly
            ) {
                WaterTracker(waterGlasses, onWaterAdd)
                FastingTimer(fastingActive, fastingHours)
            }
        }

        item {
            MealTimeline(entries)
        }

        if (insights.isNotEmpty()) {
            item {
                Text(
                    "AI Nutrition Insights",
                    style = MaterialTheme.typography.titleMedium,
                    fontWeight = FontWeight.Bold,
                    color = TextPrimary
                )
            }
            items(insights.take(2)) { insight ->
                NutritionInsightCard(insight)
            }
        }

        item {
            Button(
                onClick = onLogFood,
                colors = ButtonDefaults.buttonColors(containerColor = MomentumColors.teal),
                shape = RoundedCornerShape(12.dp),
                modifier = Modifier.fillMaxWidth()
            ) {
                Icon(Icons.Default.Add, null, modifier = Modifier.size(18.dp))
                Spacer(modifier = Modifier.width(8.dp))
                Text("Log Food Manually", fontWeight = FontWeight.Bold)
            }
        }

        item { Spacer(modifier = Modifier.height(16.dp)) }
    }
}

@Composable
private fun CameraHeroSection(onOpenCamera: () -> Unit) {
    Box(
        modifier = Modifier
            .fillMaxWidth()
            .height(160.dp)
            .clip(RoundedCornerShape(16.dp))
            .background(MomentumColors.card)
            .clickable { onOpenCamera() },
        contentAlignment = Alignment.Center
    ) {
        Column(horizontalAlignment = Alignment.CenterHorizontally) {
            Box(
                modifier = Modifier
                    .size(56.dp)
                    .clip(CircleShape)
                    .background(MomentumColors.teal.copy(alpha = 0.2f)),
                contentAlignment = Alignment.Center
            ) {
                Icon(Icons.Default.CameraAlt, "Camera", tint = MomentumColors.teal, modifier = Modifier.size(28.dp))
            }
            Spacer(modifier = Modifier.height(8.dp))
            Text(
                "Snap a photo to log your meal",
                style = MaterialTheme.typography.bodyMedium,
                color = TextSecondary
            )
            Text(
                "AI will recognize your food instantly",
                style = MaterialTheme.typography.bodySmall,
                color = TextTertiary
            )
        }
    }
}

@Composable
private fun MacroBars(calories: Int, goal: Int, protein: Int, carbs: Int, fat: Int) {
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(16.dp))
            .background(MomentumColors.card)
            .padding(16.dp)
    ) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Icon(Icons.Default.LocalFireDepartment, null, tint = MomentumColors.energy, modifier = Modifier.size(20.dp))
                Spacer(modifier = Modifier.width(4.dp))
                Text("$calories / $goal cal", fontWeight = FontWeight.Bold, color = TextPrimary, fontSize = 16.sp)
            }
        }
        Spacer(modifier = Modifier.height(8.dp))
        LinearProgressIndicator(
            progress = { (calories.toFloat() / goal).coerceIn(0f, 1f) },
            modifier = Modifier.fillMaxWidth().height(8.dp).clip(RoundedCornerShape(4.dp)),
            color = MomentumColors.energy,
            trackColor = MomentumColors.surface
        )
        Spacer(modifier = Modifier.height(12.dp))
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceEvenly
        ) {
            MacroPill("P", "${protein}g", MomentumColors.recovery)
            MacroPill("C", "${carbs}g", MomentumColors.focus)
            MacroPill("F", "${fat}g", MomentumColors.stress)
        }
    }
}

@Composable
private fun MacroPill(label: String, value: String, color: Color) {
    Row(verticalAlignment = Alignment.CenterVertically) {
        Box(
            modifier = Modifier
                .size(10.dp)
                .clip(CircleShape)
                .background(color)
        )
        Spacer(modifier = Modifier.width(4.dp))
        Column {
            Text(value, fontSize = 13.sp, fontWeight = FontWeight.Bold, color = TextPrimary)
            Text(label, fontSize = 9.sp, color = TextTertiary)
        }
    }
}

@Composable
private fun WaterTracker(glasses: Int, onAdd: () -> Unit) {
    Box(
        modifier = Modifier
            .weight(1f)
            .clip(RoundedCornerShape(12.dp))
            .background(MomentumColors.card)
            .padding(12.dp)
    ) {
        Column(horizontalAlignment = Alignment.CenterHorizontally) {
            Icon(Icons.Default.Water, null, tint = MomentumColors.focus, modifier = Modifier.size(24.dp))
            Spacer(modifier = Modifier.height(4.dp))
            Text("$glasses/8", fontWeight = FontWeight.Bold, color = TextPrimary, fontSize = 18.sp)
            Text("glasses", color = TextTertiary, fontSize = 11.sp)
            Spacer(modifier = Modifier.height(4.dp))
            Button(
                onClick = onAdd,
                colors = ButtonDefaults.buttonColors(containerColor = MomentumColors.focus.copy(alpha = 0.2f)),
                shape = RoundedCornerShape(8.dp),
                modifier = Modifier.height(28.dp)
            ) {
                Text("+1", fontSize = 12.sp, color = MomentumColors.focus)
            }
        }
    }
}

@Composable
private fun FastingTimer(active: Boolean, hours: Int) {
    Box(
        modifier = Modifier
            .weight(1f)
            .clip(RoundedCornerShape(12.dp))
            .background(MomentumColors.card)
            .padding(12.dp)
    ) {
        Column(horizontalAlignment = Alignment.CenterHorizontally) {
            Icon(Icons.Default.Timer, null, tint = MomentumColors.energy, modifier = Modifier.size(24.dp))
            Spacer(modifier = Modifier.height(4.dp))
            if (active) {
                Text("${hours}h", fontWeight = FontWeight.Bold, color = TextPrimary, fontSize = 18.sp)
                Text("fasting", color = TextTertiary, fontSize = 11.sp)
            } else {
                Text("Stopped", fontWeight = FontWeight.Bold, color = TextTertiary, fontSize = 14.sp)
            }
        }
    }
}

@Composable
private fun MealTimeline(entries: List<FoodEntry>) {
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(16.dp))
            .background(MomentumColors.card)
            .padding(16.dp)
    ) {
        Text(
            "Today's Meals",
            style = MaterialTheme.typography.titleSmall,
            fontWeight = FontWeight.Bold,
            color = TextPrimary
        )
        Spacer(modifier = Modifier.height(8.dp))
        if (entries.isEmpty()) {
            Text("No meals logged yet", color = TextTertiary, fontSize = 13.sp)
        } else {
            entries.sortedByDescending { it.timestamp }.forEach { entry ->
                Row(
                    modifier = Modifier.fillMaxWidth().padding(vertical = 4.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Box(
                        modifier = Modifier
                            .size(8.dp)
                            .clip(CircleShape)
                            .background(mealTypeColor(entry.mealType))
                    )
                    Spacer(modifier = Modifier.width(8.dp))
                    Column(modifier = Modifier.weight(1f)) {
                        Text(entry.name, fontSize = 14.sp, fontWeight = FontWeight.Medium, color = TextPrimary)
                        Text(entry.mealType.label, fontSize = 11.sp, color = TextTertiary)
                    }
                    Text("${entry.calories.toInt()} cal", fontSize = 13.sp, color = TextSecondary)
                }
            }
        }
    }
}

@Composable
private fun NutritionInsightCard(insight: Insight) {
    Box(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(12.dp))
            .background(MomentumColors.cardLight)
            .padding(12.dp)
    ) {
        Row(verticalAlignment = Alignment.Top) {
            Icon(Icons.Default.Fastfood, null, tint = MomentumColors.teal, modifier = Modifier.size(20.dp))
            Spacer(modifier = Modifier.width(8.dp))
            Column {
                Text(insight.title, fontWeight = FontWeight.SemiBold, color = TextPrimary, fontSize = 14.sp)
                Text(insight.message, color = TextSecondary, fontSize = 12.sp)
            }
        }
    }
}

private fun mealTypeColor(type: MealType): Color {
    return when (type) {
        MealType.Breakfast -> MomentumColors.energy
        MealType.Lunch -> MomentumColors.recovery
        MealType.Dinner -> MomentumColors.focus
        MealType.Snack -> MomentumColors.stress
    }
}
