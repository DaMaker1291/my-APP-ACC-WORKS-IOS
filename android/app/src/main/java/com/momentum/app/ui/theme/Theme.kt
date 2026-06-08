package com.momentum.app.ui.theme

import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color

private val MomentumDarkColorScheme = darkColorScheme(
    primary = Teal400,
    onPrimary = BgDark,
    primaryContainer = Teal700,
    onPrimaryContainer = Teal100,
    secondary = FocusBlue,
    onSecondary = BgDark,
    secondaryContainer = Color(0xFF1A237E),
    onSecondaryContainer = FocusBlueLight,
    tertiary = EnergyAmber,
    onTertiary = BgDark,
    tertiaryContainer = Color(0xFF3E2723),
    onTertiaryContainer = EnergyAmberLight,
    error = StressRed,
    onError = BgDark,
    errorContainer = Color(0xFF4A1C1C),
    onErrorContainer = StressRedLight,
    background = BgDark,
    onBackground = TextPrimary,
    surface = BgCard,
    onSurface = TextPrimary,
    surfaceVariant = SurfaceDark,
    onSurfaceVariant = TextSecondary,
    outline = BorderColor,
    outlineVariant = SurfaceLight
)

@Composable
fun MomentumTheme(content: @Composable () -> Unit) {
    MaterialTheme(
        colorScheme = MomentumDarkColorScheme,
        content = content
    )
}
