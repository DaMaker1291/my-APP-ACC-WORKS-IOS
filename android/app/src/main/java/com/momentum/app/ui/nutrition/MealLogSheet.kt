package com.momentum.app.ui.nutrition

import android.net.Uri
import androidx.compose.foundation.background
import androidx.compose.foundation.border
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
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardActions
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Barcode
import androidx.compose.material.icons.filled.CameraAlt
import androidx.compose.material.icons.filled.Check
import androidx.compose.material.icons.filled.Close
import androidx.compose.material.icons.filled.Search
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.FilterChip
import androidx.compose.material3.FilterChipDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.OutlinedTextFieldDefaults
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
import androidx.compose.ui.text.input.ImeAction
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.momentum.app.models.AIFoodRecognition
import com.momentum.app.models.MealType
import com.momentum.app.ui.theme.MomentumColors
import com.momentum.app.ui.theme.TextPrimary
import com.momentum.app.ui.theme.TextSecondary
import com.momentum.app.ui.theme.TextTertiary

@Composable
fun MealLogSheet(
    aiRecognition: AIFoodRecognition?,
    selectedMealType: MealType,
    searchQuery: String,
    barcodeInput: String,
    onMealTypeSelected: (MealType) -> Unit,
    onSearchQueryChanged: (String) -> Unit,
    onBarcodeInputChanged: (String) -> Unit,
    onBarcodeLookup: () -> Unit,
    onOpenCamera: () -> Unit,
    onConfirmRecognition: (AIFoodRecognition) -> Unit,
    onManualLog: (name: String, calories: Double, protein: Double, carbs: Double, fat: Double) -> Unit,
    onDismiss: () -> Unit
) {
    var manualName by remember { mutableStateOf("") }
    var manualCalories by remember { mutableStateOf("") }
    var manualProtein by remember { mutableStateOf("") }
    var manualCarbs by remember { mutableStateOf("") }
    var manualFat by remember { mutableStateOf("") }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(MomentumColors.background)
            .verticalScroll(rememberScrollState())
            .padding(16.dp)
    ) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Text(
                "Log Meal",
                style = MaterialTheme.typography.headlineSmall,
                fontWeight = FontWeight.Bold,
                color = TextPrimary
            )
            IconButton(onClick = onDismiss) {
                Icon(Icons.Default.Close, "Close", tint = TextSecondary)
            }
        }

        Spacer(modifier = Modifier.height(16.dp))

        Box(
            modifier = Modifier
                .fillMaxWidth()
                .height(120.dp)
                .clip(RoundedCornerShape(16.dp))
                .background(MomentumColors.card)
                .clickable { onOpenCamera() },
            contentAlignment = Alignment.Center
        ) {
            Column(horizontalAlignment = Alignment.CenterHorizontally) {
                Box(
                    modifier = Modifier
                        .size(48.dp)
                        .clip(CircleShape)
                        .background(MomentumColors.teal.copy(alpha = 0.2f)),
                    contentAlignment = Alignment.Center
                ) {
                    Icon(Icons.Default.CameraAlt, null, tint = MomentumColors.teal, modifier = Modifier.size(24.dp))
                }
                Spacer(modifier = Modifier.height(4.dp))
                Text("Take Photo", color = TextSecondary, fontSize = 13.sp)
            }
        }

        Spacer(modifier = Modifier.height(12.dp))

        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceEvenly
        ) {
            MealType.entries.forEach { type ->
                FilterChip(
                    selected = selectedMealType == type,
                    onClick = { onMealTypeSelected(type) },
                    label = { Text(type.label, fontSize = 11.sp) },
                    colors = FilterChipDefaults.filterChipColors(
                        selectedContainerColor = MomentumColors.teal.copy(alpha = 0.2f),
                        selectedLabelColor = MomentumColors.teal
                    )
                )
            }
        }

        Spacer(modifier = Modifier.height(16.dp))

        OutlinedTextField(
            value = searchQuery,
            onValueChange = onSearchQueryChanged,
            placeholder = { Text("Search food...", color = TextTertiary) },
            leadingIcon = { Icon(Icons.Default.Search, null, tint = TextTertiary) },
            modifier = Modifier.fillMaxWidth(),
            singleLine = true,
            colors = OutlinedTextFieldDefaults.colors(
                focusedBorderColor = MomentumColors.teal,
                unfocusedBorderColor = MomentumColors.surface,
                focusedTextColor = TextPrimary,
                unfocusedTextColor = TextPrimary
            ),
            shape = RoundedCornerShape(12.dp),
            keyboardOptions = KeyboardOptions(imeAction = ImeAction.Search)
        )

        Spacer(modifier = Modifier.height(12.dp))

        Row(
            modifier = Modifier.fillMaxWidth(),
            verticalAlignment = Alignment.CenterVertically
        ) {
            OutlinedTextField(
                value = barcodeInput,
                onValueChange = onBarcodeInputChanged,
                placeholder = { Text("Barcode", color = TextTertiary) },
                leadingIcon = { Icon(Icons.Default.Barcode, null, tint = TextTertiary) },
                modifier = Modifier.weight(1f),
                singleLine = true,
                colors = OutlinedTextFieldDefaults.colors(
                    focusedBorderColor = MomentumColors.teal,
                    unfocusedBorderColor = MomentumColors.surface,
                    focusedTextColor = TextPrimary,
                    unfocusedTextColor = TextPrimary
                ),
                shape = RoundedCornerShape(12.dp)
            )
            Spacer(modifier = Modifier.width(8.dp))
            Button(
                onClick = onBarcodeLookup,
                colors = ButtonDefaults.buttonColors(containerColor = MomentumColors.teal),
                shape = RoundedCornerShape(12.dp)
            ) {
                Text("Lookup", fontSize = 13.sp)
            }
        }

        if (aiRecognition != null) {
            Spacer(modifier = Modifier.height(16.dp))
            AIRecognitionCard(aiRecognition, onConfirmRecognition)
        }

        Spacer(modifier = Modifier.height(16.dp))
        Text(
            "Manual Entry",
            style = MaterialTheme.typography.titleSmall,
            fontWeight = FontWeight.Bold,
            color = TextPrimary
        )
        Spacer(modifier = Modifier.height(8.dp))

        OutlinedTextField(
            value = manualName,
            onValueChange = { manualName = it },
            placeholder = { Text("Food name", color = TextTertiary) },
            modifier = Modifier.fillMaxWidth(),
            singleLine = true,
            colors = OutlinedTextFieldDefaults.colors(
                focusedBorderColor = MomentumColors.teal,
                unfocusedBorderColor = MomentumColors.surface,
                focusedTextColor = TextPrimary,
                unfocusedTextColor = TextPrimary
            ),
            shape = RoundedCornerShape(12.dp)
        )

        Spacer(modifier = Modifier.height(8.dp))

        Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(8.dp)) {
            OutlinedTextField(
                value = manualCalories,
                onValueChange = { manualCalories = it },
                placeholder = { Text("Cal", color = TextTertiary) },
                modifier = Modifier.weight(1f),
                singleLine = true,
                colors = OutlinedTextFieldDefaults.colors(
                    focusedBorderColor = MomentumColors.teal,
                    unfocusedBorderColor = MomentumColors.surface,
                    focusedTextColor = TextPrimary,
                    unfocusedTextColor = TextPrimary
                ),
                shape = RoundedCornerShape(12.dp)
            )
            OutlinedTextField(
                value = manualProtein,
                onValueChange = { manualProtein = it },
                placeholder = { Text("P", color = TextTertiary) },
                modifier = Modifier.weight(1f),
                singleLine = true,
                colors = OutlinedTextFieldDefaults.colors(
                    focusedBorderColor = MomentumColors.recovery,
                    unfocusedBorderColor = MomentumColors.surface,
                    focusedTextColor = TextPrimary,
                    unfocusedTextColor = TextPrimary
                ),
                shape = RoundedCornerShape(12.dp)
            )
            OutlinedTextField(
                value = manualCarbs,
                onValueChange = { manualCarbs = it },
                placeholder = { Text("C", color = TextTertiary) },
                modifier = Modifier.weight(1f),
                singleLine = true,
                colors = OutlinedTextFieldDefaults.colors(
                    focusedBorderColor = MomentumColors.focus,
                    unfocusedBorderColor = MomentumColors.surface,
                    focusedTextColor = TextPrimary,
                    unfocusedTextColor = TextPrimary
                ),
                shape = RoundedCornerShape(12.dp)
            )
            OutlinedTextField(
                value = manualFat,
                onValueChange = { manualFat = it },
                placeholder = { Text("F", color = TextTertiary) },
                modifier = Modifier.weight(1f),
                singleLine = true,
                colors = OutlinedTextFieldDefaults.colors(
                    focusedBorderColor = MomentumColors.stress,
                    unfocusedBorderColor = MomentumColors.surface,
                    focusedTextColor = TextPrimary,
                    unfocusedTextColor = TextPrimary
                ),
                shape = RoundedCornerShape(12.dp)
            )
        }

        Spacer(modifier = Modifier.height(16.dp))

        Button(
            onClick = {
                onManualLog(
                    manualName,
                    manualCalories.toDoubleOrNull() ?: 0.0,
                    manualProtein.toDoubleOrNull() ?: 0.0,
                    manualCarbs.toDoubleOrNull() ?: 0.0,
                    manualFat.toDoubleOrNull() ?: 0.0
                )
            },
            colors = ButtonDefaults.buttonColors(containerColor = MomentumColors.teal),
            shape = RoundedCornerShape(12.dp),
            modifier = Modifier.fillMaxWidth().height(48.dp)
        ) {
            Icon(Icons.Default.Check, null, modifier = Modifier.size(18.dp))
            Spacer(modifier = Modifier.width(8.dp))
            Text("Log Food", fontWeight = FontWeight.Bold)
        }

        Spacer(modifier = Modifier.height(32.dp))
    }
}

@Composable
private fun AIRecognitionCard(
    recognition: AIFoodRecognition,
    onConfirm: (AIFoodRecognition) -> Unit
) {
    Box(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(16.dp))
            .background(MomentumColors.card)
            .border(1.dp, MomentumColors.teal.copy(alpha = 0.3f), RoundedCornerShape(16.dp))
            .padding(12.dp)
    ) {
        Column {
            Text(
                "AI Recognition",
                style = MaterialTheme.typography.labelMedium,
                color = MomentumColors.teal,
                fontWeight = FontWeight.SemiBold
            )
            Spacer(modifier = Modifier.height(8.dp))
            Text(recognition.name, fontWeight = FontWeight.Bold, color = TextPrimary, fontSize = 18.sp)
            Spacer(modifier = Modifier.height(4.dp))
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceEvenly
            ) {
                Text("${recognition.estimatedCalories.toInt()} cal", color = TextSecondary, fontSize = 13.sp)
                Text("P: ${recognition.estimatedProtein.toInt()}g", color = MomentumColors.recovery, fontSize = 13.sp)
                Text("C: ${recognition.estimatedCarbs.toInt()}g", color = MomentumColors.focus, fontSize = 13.sp)
                Text("F: ${recognition.estimatedFat.toInt()}g", color = MomentumColors.stress, fontSize = 13.sp)
            }
            Spacer(modifier = Modifier.height(4.dp))
            Text(
                "Confidence: ${String.format("%.0f", recognition.confidence)}%",
                fontSize = 11.sp,
                color = TextTertiary
            )
            Spacer(modifier = Modifier.height(8.dp))
            Button(
                onClick = { onConfirm(recognition) },
                colors = ButtonDefaults.buttonColors(containerColor = MomentumColors.teal),
                shape = RoundedCornerShape(8.dp),
                modifier = Modifier.fillMaxWidth()
            ) {
                Text("Confirm & Log", fontWeight = FontWeight.Bold)
            }
        }
    }
}
