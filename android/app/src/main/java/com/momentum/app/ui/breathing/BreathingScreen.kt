package com.momentum.app.ui.breathing

import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.tween
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Close
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.momentum.app.ui.theme.MomentumColors
import com.momentum.app.ui.theme.TextPrimary
import com.momentum.app.ui.theme.TextSecondary
import kotlinx.coroutines.delay

@Composable
fun BreathingScreen(
    onClose: () -> Unit
) {
    var phase by remember { mutableIntStateOf(0) }
    var isActive by remember { mutableStateOf(true) }
    var cyclesCompleted by remember { mutableIntStateOf(0) }

    val phases = listOf("Breathe In", "Hold", "Breathe Out", "Hold")
    val phaseDurations = listOf(4000L, 4000L, 4000L, 4000L)
    val phaseScale = listOf(1f, 1f, 0.6f, 0.6f)
    val phaseColors = listOf(
        MomentumColors.teal,
        MomentumColors.focus,
        MomentumColors.recovery,
        MomentumColors.focus
    )

    val animatedScale by animateFloatAsState(
        targetValue = phaseScale[phase],
        animationSpec = tween(phaseDurations[phase].toInt()),
        label = "breathScale"
    )

    LaunchedEffect(isActive) {
        while (isActive) {
            delay(phaseDurations[phase])
            phase = (phase + 1) % 4
            if (phase == 0) cyclesCompleted++
        }
    }

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(
                Brush.radialGradient(
                    colors = listOf(
                        phaseColors[phase].copy(alpha = 0.3f),
                        MomentumColors.background
                    )
                )
            ),
        contentAlignment = Alignment.Center
    ) {
        IconButton(
            onClick = {
                isActive = false
                onClose()
            },
            modifier = Modifier
                .align(Alignment.TopEnd)
                .padding(16.dp)
                .size(40.dp)
                .background(Color.Black.copy(alpha = 0.5f), CircleShape)
        ) {
            Icon(Icons.Default.Close, "Close", tint = Color.White)
        }

        Column(
            modifier = Modifier.fillMaxWidth(),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Text(
                "Guided Breathing",
                style = androidx.compose.material3.MaterialTheme.typography.titleMedium,
                color = TextSecondary
            )
            Spacer(modifier = Modifier.height(32.dp))

            Box(
                contentAlignment = Alignment.Center,
                modifier = Modifier.size(250.dp)
            ) {
                Canvas(modifier = Modifier.fillMaxSize()) {
                    val size = this.size.minDimension
                    drawCircle(
                        color = phaseColors[phase].copy(alpha = 0.1f),
                        radius = size / 2
                    )
                }
                Box(
                    modifier = Modifier
                        .size((200 * animatedScale).dp)
                        .clip(CircleShape)
                        .background(
                            Brush.radialGradient(
                                colors = listOf(
                                    phaseColors[phase].copy(alpha = 0.6f),
                                    phaseColors[phase].copy(alpha = 0.2f)
                                )
                            )
                        ),
                    contentAlignment = Alignment.Center
                ) {
                    Text(
                        phases[phase],
                        style = androidx.compose.material3.MaterialTheme.typography.headlineMedium,
                        fontWeight = FontWeight.Bold,
                        color = Color.White
                    )
                }
            }

            Spacer(modifier = Modifier.height(32.dp))

            Text(
                "Cycle $cyclesCompleted",
                color = TextSecondary,
                fontSize = 14.sp
            )

            Spacer(modifier = Modifier.height(24.dp))

            Button(
                onClick = { isActive = !isActive },
                colors = ButtonDefaults.buttonColors(containerColor = MomentumColors.teal),
                shape = CircleShape,
                modifier = Modifier.size(64.dp)
            ) {
                Text(
                    if (isActive) "||" else "▶",
                    fontWeight = FontWeight.Bold,
                    color = Color.White,
                    fontSize = 20.sp
                )
            }
        }
    }
}
