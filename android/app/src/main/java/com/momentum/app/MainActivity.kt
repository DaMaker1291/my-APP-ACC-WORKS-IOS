package com.momentum.app

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.animation.AnimatedContent
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.togetherWith
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Bolt
import androidx.compose.material.icons.filled.Favorite
import androidx.compose.material.icons.filled.FitnessCenter
import androidx.compose.material.icons.filled.Person
import androidx.compose.material.icons.filled.Restaurant
import androidx.compose.material.icons.filled.SelfImprovement
import androidx.compose.material.icons.filled.Timer
import androidx.compose.material3.Icon
import androidx.compose.material3.NavigationBar
import androidx.compose.material3.NavigationBarItem
import androidx.compose.material3.NavigationBarItemDefaults
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.sp
import com.momentum.app.ui.breathing.BreathingScreen
import com.momentum.app.ui.coach.CoachScreen
import com.momentum.app.ui.dashboard.DashboardScreen
import com.momentum.app.ui.design.MomentumTabBar
import com.momentum.app.ui.focus.FocusScreen
import com.momentum.app.ui.nutrition.NutritionScreen
import com.momentum.app.ui.profile.ProfileScreen
import com.momentum.app.ui.reels.ReelsScreen
import com.momentum.app.ui.theme.MomentumColors
import com.momentum.app.ui.theme.MomentumTheme
import com.momentum.app.ui.theme.TextSecondary

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            MomentumTheme {
                MomentumApp()
            }
        }
    }
}

data class TabItem(
    val label: String,
    val icon: ImageVector
)

@Composable
fun MomentumApp() {
    var selectedTab by remember { mutableIntStateOf(0) }
    var showBreathing by remember { mutableStateOf(false) }
    var focusRunning by remember { mutableStateOf(false) }
    var focusRemaining by remember { mutableIntStateOf(25 * 60) }
    var focusTotal by remember { mutableIntStateOf(25 * 60) }
    var focusDuration by remember { mutableIntStateOf(25) }
    var focusStreak by remember { mutableIntStateOf(3) }
    var weeklySessions by remember { mutableStateOf(listOf(25, 15, 0, 45, 30, 0, 0)) }
    var journalContent by remember { mutableStateOf("") }

    val tabs = listOf(
        TabItem("Dashboard", Icons.Default.Bolt),
        TabItem("Reels", Icons.Default.FitnessCenter),
        TabItem("Nutrition", Icons.Default.Restaurant),
        TabItem("Coach", Icons.Default.SelfImprovement),
        TabItem("Focus", Icons.Default.Timer),
        TabItem("Profile", Icons.Default.Person)
    )

    if (showBreathing) {
        BreathingScreen(onClose = { showBreathing = false })
        return
    }

    Scaffold(
        containerColor = MomentumColors.background,
        bottomBar = {
            NavigationBar(
                containerColor = MomentumColors.card,
                tonalElevation = androidx.compose.ui.unit.dp.times(0),
                contentColor = MomentumColors.textSecondary
            ) {
                tabs.forEachIndexed { index, tab ->
                    NavigationBarItem(
                        selected = selectedTab == index,
                        onClick = { selectedTab = index },
                        icon = {
                            Icon(
                                tab.icon,
                                contentDescription = tab.label,
                                tint = if (selectedTab == index) MomentumColors.teal else TextSecondary
                            )
                        },
                        label = {
                            Text(
                                tab.label,
                                fontSize = 10.sp,
                                color = if (selectedTab == index) MomentumColors.teal else TextSecondary,
                                fontWeight = if (selectedTab == index) FontWeight.Bold else FontWeight.Normal
                            )
                        },
                        colors = NavigationBarItemDefaults.colors(
                            indicatorColor = MomentumColors.teal.copy(alpha = 0.1f)
                        )
                    )
                }
            }
        }
    ) { paddingValues ->
        Box(
            modifier = Modifier
                .fillMaxSize()
                .padding(paddingValues)
        ) {
            when (selectedTab) {
                0 -> DashboardScreen(
                    metrics = null,
                    dayScore = null,
                    insights = emptyList(),
                    onOpenBreathing = { showBreathing = true },
                    onOpenReels = { selectedTab = 1 },
                    onOpenFocus = { selectedTab = 4 }
                )
                1 -> ReelsScreen(
                    reels = emptyList()
                )
                2 -> NutritionScreen(
                    entries = emptyList(),
                    insights = emptyList(),
                    waterGlasses = 0,
                    fastingActive = false,
                    fastingHours = 0,
                    onOpenCamera = { },
                    onLogFood = { },
                    onWaterAdd = { }
                )
                3 -> CoachScreen(
                    messages = emptyList(),
                    recoveryScore = 65,
                    journalEntry = journalContent,
                    onJournalChange = { journalContent = it },
                    onSaveJournal = { }
                )
                4 -> FocusScreen(
                    isRunning = focusRunning,
                    remainingSeconds = focusRemaining,
                    totalSeconds = focusTotal,
                    selectedDuration = focusDuration,
                    currentStreak = focusStreak,
                    weeklySessions = weeklySessions,
                    onDurationSelected = { focusDuration = it; focusTotal = it * 60; focusRemaining = it * 60 },
                    onStartStop = { focusRunning = !focusRunning },
                    onOpenBreathing = { showBreathing = true }
                )
                5 -> ProfileScreen(
                    personaSummary = "Balanced, active lifestyle",
                    daysTracked = 24,
                    averageScores = null,
                    badges = emptyList(),
                    isDigitalWellbeing = true,
                    isNotificationsEnabled = true,
                    onDigitalWellbeingToggle = { },
                    onNotificationsToggle = { },
                    onResetData = { }
                )
            }
        }
    }
}
