package com.momentum.app.ui.profile

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
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.lazy.grid.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Bolt
import androidx.compose.material.icons.filled.Edit
import androidx.compose.material.icons.filled.Favorite
import androidx.compose.material.icons.filled.LocalFireDepartment
import androidx.compose.material.icons.filled.NightlightRound
import androidx.compose.material.icons.filled.Notifications
import androidx.compose.material.icons.filled.Person
import androidx.compose.material.icons.filled.SelfImprovement
import androidx.compose.material.icons.filled.Settings
import androidx.compose.material.icons.filled.Shield
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Switch
import androidx.compose.material3.SwitchDefaults
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.momentum.app.models.DayScore
import com.momentum.app.ui.theme.MomentumColors
import com.momentum.app.ui.theme.TextPrimary
import com.momentum.app.ui.theme.TextSecondary
import com.momentum.app.ui.theme.TextTertiary

data class Badge(
    val name: String,
    val icon: ImageVector,
    val color: Color,
    val unlocked: Boolean
)

@Composable
fun ProfileScreen(
    personaSummary: String,
    daysTracked: Int,
    averageScores: DayScore?,
    badges: List<Badge>,
    isDigitalWellbeing: Boolean,
    isNotificationsEnabled: Boolean,
    onDigitalWellbeingToggle: (Boolean) -> Unit,
    onNotificationsToggle: (Boolean) -> Unit,
    onResetData: () -> Unit
) {
    LazyColumn(
        modifier = Modifier
            .fillMaxSize()
            .background(MomentumColors.background)
            .padding(horizontal = 16.dp),
        verticalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        item { Spacer(modifier = Modifier.height(8.dp)) }

        item {
            AvatarSection(personaSummary, daysTracked)
        }

        item {
            StatsGrid(averageScores)
        }

        item {
            BadgesSection(badges)
        }

        item {
            QuickActions(onResetData)
        }

        item {
            SettingsSection(
                isDigitalWellbeing = isDigitalWellbeing,
                isNotificationsEnabled = isNotificationsEnabled,
                onDigitalWellbeingToggle = onDigitalWellbeingToggle,
                onNotificationsToggle = onNotificationsToggle
            )
        }

        item { Spacer(modifier = Modifier.height(16.dp)) }
    }
}

@Composable
private fun AvatarSection(persona: String, daysTracked: Int) {
    Box(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(20.dp))
            .background(
                Brush.linearGradient(
                    colors = listOf(
                        MomentumColors.teal.copy(alpha = 0.2f),
                        MomentumColors.focus.copy(alpha = 0.1f)
                    )
                )
            )
            .padding(20.dp)
    ) {
        Row(verticalAlignment = Alignment.CenterVertically) {
            Box(
                modifier = Modifier
                    .size(64.dp)
                    .clip(CircleShape)
                    .background(MomentumColors.teal.copy(alpha = 0.3f)),
                contentAlignment = Alignment.Center
            ) {
                Icon(Icons.Default.Person, null, tint = MomentumColors.teal, modifier = Modifier.size(36.dp))
            }
            Spacer(modifier = Modifier.width(16.dp))
            Column {
                Text(
                    "Momentum User",
                    style = MaterialTheme.typography.titleLarge,
                    fontWeight = FontWeight.Bold,
                    color = TextPrimary
                )
                Text(persona, fontSize = 12.sp, color = TextSecondary)
                Text(
                    "$daysTracked days tracked",
                    fontSize = 11.sp,
                    color = TextTertiary
                )
            }
        }
    }
}

@Composable
private fun StatsGrid(averageScores: DayScore?) {
    Row(
        modifier = Modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.SpaceEvenly
    ) {
        StatCard(Icons.Default.Bolt, "Energy", "${averageScores?.energy ?: 0}%", MomentumColors.energy)
        StatCard(Icons.Default.Favorite, "Focus", "${averageScores?.focus ?: 0}%", MomentumColors.focus)
        StatCard(Icons.Default.Shield, "Stress", "${averageScores?.stress ?: 0}%", MomentumColors.stress)
        StatCard(Icons.Default.NightlightRound, "Sleep", "${averageScores?.sleep ?: 0}%", MomentumColors.teal)
    }
}

@Composable
private fun StatCard(icon: ImageVector, label: String, value: String, color: Color) {
    Column(
        modifier = Modifier
            .clip(RoundedCornerShape(12.dp))
            .background(MomentumColors.card)
            .padding(12.dp),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Icon(icon, null, tint = color, modifier = Modifier.size(20.dp))
        Spacer(modifier = Modifier.height(4.dp))
        Text(value, fontWeight = FontWeight.Bold, color = TextPrimary, fontSize = 16.sp)
        Text(label, color = TextTertiary, fontSize = 10.sp)
    }
}

@Composable
private fun BadgesSection(badges: List<Badge>) {
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(16.dp))
            .background(MomentumColors.card)
            .padding(16.dp)
    ) {
        Text(
            "Badges",
            style = MaterialTheme.typography.titleSmall,
            fontWeight = FontWeight.Bold,
            color = TextPrimary
        )
        Spacer(modifier = Modifier.height(12.dp))
        LazyVerticalGrid(
            columns = GridCells.Fixed(4),
            modifier = Modifier.fillMaxWidth().height(120.dp),
            horizontalArrangement = Arrangement.spacedBy(8.dp),
            verticalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            items(badges) { badge ->
                Column(
                    horizontalAlignment = Alignment.CenterHorizontally,
                    modifier = Modifier.padding(4.dp)
                ) {
                    Box(
                        modifier = Modifier
                            .size(36.dp)
                            .clip(CircleShape)
                            .background(
                                if (badge.unlocked) badge.color.copy(alpha = 0.2f)
                                else MomentumColors.surface
                            ),
                        contentAlignment = Alignment.Center
                    ) {
                        Icon(
                            badge.icon,
                            null,
                            tint = if (badge.unlocked) badge.color else TextTertiary,
                            modifier = Modifier.size(20.dp)
                        )
                    }
                    Text(
                        badge.name,
                        fontSize = 9.sp,
                        color = if (badge.unlocked) TextSecondary else TextTertiary,
                        maxLines = 1
                    )
                }
            }
        }
    }
}

@Composable
private fun QuickActions(onResetData: () -> Unit) {
    Row(
        modifier = Modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        Button(
            onClick = { },
            colors = ButtonDefaults.buttonColors(containerColor = MomentumColors.card),
            shape = RoundedCornerShape(12.dp),
            modifier = Modifier.weight(1f)
        ) {
            Icon(Icons.Default.Edit, null, modifier = Modifier.size(16.dp), tint = MomentumColors.teal)
            Spacer(modifier = Modifier.width(4.dp))
            Text("Edit Profile", fontSize = 12.sp, color = TextPrimary)
        }
        Button(
            onClick = onResetData,
            colors = ButtonDefaults.buttonColors(containerColor = MomentumColors.card),
            shape = RoundedCornerShape(12.dp),
            modifier = Modifier.weight(1f)
        ) {
            Icon(Icons.Default.Settings, null, modifier = Modifier.size(16.dp), tint = MomentumColors.teal)
            Spacer(modifier = Modifier.width(4.dp))
            Text("Reset Data", fontSize = 12.sp, color = TextPrimary)
        }
    }
}

@Composable
private fun SettingsSection(
    isDigitalWellbeing: Boolean,
    isNotificationsEnabled: Boolean,
    onDigitalWellbeingToggle: (Boolean) -> Unit,
    onNotificationsToggle: (Boolean) -> Unit
) {
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(16.dp))
            .background(MomentumColors.card)
            .padding(16.dp)
    ) {
        Text(
            "Settings",
            style = MaterialTheme.typography.titleSmall,
            fontWeight = FontWeight.Bold,
            color = TextPrimary
        )
        Spacer(modifier = Modifier.height(12.dp))

        SettingRow(
            icon = Icons.Default.SelfImprovement,
            title = "Digital Wellbeing",
            description = "Mindful usage reminders",
            checked = isDigitalWellbeing,
            onToggle = onDigitalWellbeingToggle
        )
        Spacer(modifier = Modifier.height(8.dp))
        SettingRow(
            icon = Icons.Default.Notifications,
            title = "Notifications",
            description = "Daily insights & reminders",
            checked = isNotificationsEnabled,
            onToggle = onNotificationsToggle
        )
    }
}

@Composable
private fun SettingRow(
    icon: ImageVector,
    title: String,
    description: String,
    checked: Boolean,
    onToggle: (Boolean) -> Unit
) {
    Row(
        modifier = Modifier.fillMaxWidth(),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Icon(icon, null, tint = MomentumColors.teal, modifier = Modifier.size(24.dp))
        Spacer(modifier = Modifier.width(12.dp))
        Column(modifier = Modifier.weight(1f)) {
            Text(title, fontSize = 14.sp, fontWeight = FontWeight.Medium, color = TextPrimary)
            Text(description, fontSize = 11.sp, color = TextTertiary)
        }
        Switch(
            checked = checked,
            onCheckedChange = onToggle,
            colors = SwitchDefaults.colors(
                checkedThumbColor = MomentumColors.teal,
                checkedTrackColor = MomentumColors.teal.copy(alpha = 0.3f)
            )
        )
    }
}
