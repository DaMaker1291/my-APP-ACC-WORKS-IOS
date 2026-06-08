package com.momentum.app.ui.theme

import androidx.compose.ui.graphics.Color

val Teal500 = Color(0xFF009688)
val Teal400 = Color(0xFF26A69A)
val Teal300 = Color(0xFF4DB6AC)
val Teal200 = Color(0xFF80CBC4)
val Teal100 = Color(0xFFB2DFDB)
val Teal700 = Color(0xFF00796B)
val FocusBlue = Color(0xFF42A5F5)
val FocusBlueLight = Color(0xFF90CAF9)
val EnergyAmber = Color(0xFFFFC107)
val EnergyAmberLight = Color(0xFFFFE082)
val StressRed = Color(0xFFEF5350)
val StressRedLight = Color(0xFFEF9A9A)
val RecoveryGreen = Color(0xFF66BB6A)
val RecoveryGreenLight = Color(0xFFA5D6A7)
val BgDark = Color(0xFF0D1117)
val BgCard = Color(0xFF161B22)
val BgCardLight = Color(0xFF1C2333)
val GlassWhite = Color(0x33FFFFFF)
val GlassWhiteLight = Color(0x66FFFFFF)
val TextPrimary = Color(0xFFE6EDF3)
val TextSecondary = Color(0xFF8B949E)
val TextTertiary = Color(0xFF6E7681)
val SurfaceDark = Color(0xFF21262D)
val SurfaceLight = Color(0xFF30363D)
val BorderColor = Color(0xFF30363D)

object MomentumColors {
    val teal = Teal400
    val focus = FocusBlue
    val energy = EnergyAmber
    val stress = StressRed
    val recovery = RecoveryGreen
    val background = BgDark
    val card = BgCard
    val cardLight = BgCardLight
    val glass = GlassWhite
    val glassLight = GlassWhiteLight
    val textPrimary = TextPrimary
    val textSecondary = TextSecondary
    val textTertiary = TextTertiary
    val surface = SurfaceDark
    val surfaceLight = SurfaceLight
    val border = BorderColor

    val categoryColors = mapOf(
        "sleep" to Teal400,
        "energy" to EnergyAmber,
        "focus" to FocusBlue,
        "stress" to StressRed,
        "activity" to RecoveryGreen,
        "nutrition" to Color(0xFFAB47BC),
        "calendar" to Color(0xFFFF7043)
    )

    val energyGradient = listOf(EnergyAmber, EnergyAmberLight)
    val focusGradient = listOf(FocusBlue, FocusBlueLight)
    val stressGradient = listOf(StressRed, StressRedLight)
    val recoveryGradient = listOf(RecoveryGreen, RecoveryGreenLight)
    val tealGradient = listOf(Teal400, Teal200)
}

fun energyToColor(level: Int): Color {
    return when (level) {
        0 -> Color(0xFF90A4AE)
        1 -> Color(0xFF81C784)
        2 -> EnergyAmber
        3 -> EnergyAmber
        4 -> StressRed
        else -> EnergyAmber
    }
}
