package com.momentum.app.viewmodels

import android.app.Application
import android.graphics.Bitmap
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import com.momentum.app.models.AIFoodRecognition
import com.momentum.app.models.BarcodeFoodItem
import com.momentum.app.models.FoodEntry
import com.momentum.app.models.FoodSource
import com.momentum.app.models.Insight
import com.momentum.app.models.MealType
import com.momentum.app.services.AIFoodTracker
import com.momentum.app.services.NutritionInsightEngine
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

class NutritionViewModel(application: Application) : AndroidViewModel(application) {

    private val foodTracker = AIFoodTracker(application)
    private val insightEngine = NutritionInsightEngine()

    private val _entries = MutableStateFlow<List<FoodEntry>>(emptyList())
    val entries: StateFlow<List<FoodEntry>> = _entries.asStateFlow()

    private val _insights = MutableStateFlow<List<Insight>>(emptyList())
    val insights: StateFlow<List<Insight>> = _insights.asStateFlow()

    private val _selectedMealType = MutableStateFlow(MealType.Breakfast)
    val selectedMealType: StateFlow<MealType> = _selectedMealType.asStateFlow()

    private val _searchQuery = MutableStateFlow("")
    val searchQuery: StateFlow<String> = _searchQuery.asStateFlow()

    private val _barcodeInput = MutableStateFlow("")
    val barcodeInput: StateFlow<String> = _barcodeInput.asStateFlow()

    private val _aiRecognition = MutableStateFlow<AIFoodRecognition?>(null)
    val aiRecognition: StateFlow<AIFoodRecognition?> = _aiRecognition.asStateFlow()

    private val _barcodeResult = MutableStateFlow<BarcodeFoodItem?>(null)
    val barcodeResult: StateFlow<BarcodeFoodItem?> = _barcodeResult.asStateFlow()

    private val _waterGlasses = MutableStateFlow(0)
    val waterGlasses: StateFlow<Int> = _waterGlasses.asStateFlow()

    private val _fastingActive = MutableStateFlow(false)
    val fastingActive: StateFlow<Boolean> = _fastingActive.asStateFlow()

    private val _fastingHours = MutableStateFlow(0)
    val fastingHours: StateFlow<Int> = _fastingHours.asStateFlow()

    private val _showMealLog = MutableStateFlow(false)
    val showMealLog: StateFlow<Boolean> = _showMealLog.asStateFlow()

    private val _showCamera = MutableStateFlow(false)
    val showCamera: StateFlow<Boolean> = _showCamera.asStateFlow()

    private val _photoDiary = MutableStateFlow<List<String>>(emptyList())
    val photoDiary: StateFlow<List<String>> = _photoDiary.asStateFlow()

    init {
        loadSampleData()
    }

    private fun loadSampleData() {
        viewModelScope.launch {
            refreshInsights()
        }
    }

    fun onMealTypeSelected(type: MealType) {
        _selectedMealType.value = type
    }

    fun onSearchQueryChanged(query: String) {
        _searchQuery.value = query
        if (query.length >= 2) {
            val recognition = foodTracker.recognizeFood(query)
            _aiRecognition.value = recognition
        } else {
            _aiRecognition.value = null
        }
    }

    fun onBarcodeInputChanged(code: String) {
        _barcodeInput.value = code
    }

    fun onBarcodeLookup() {
        val result = foodTracker.lookupBarcode(_barcodeInput.value)
        _barcodeResult.value = result
        if (result != null) {
            addEntry(
                FoodEntry(
                    name = result.name,
                    calories = result.calories,
                    protein = result.protein,
                    carbs = result.carbs,
                    fat = result.fat,
                    mealType = _selectedMealType.value,
                    source = FoodSource.Barcode,
                    barcode = result.barcode
                )
            )
        }
    }

    fun onFoodImageCaptured(bitmap: Bitmap) {
        val recognition = foodTracker.recognizeFoodFromImage(bitmap)
        _aiRecognition.value = recognition
        _showCamera.value = false
    }

    fun onConfirmRecognition(recognition: AIFoodRecognition) {
        addEntry(
            FoodEntry(
                name = recognition.name,
                calories = recognition.estimatedCalories,
                protein = recognition.estimatedProtein,
                carbs = recognition.estimatedCarbs,
                fat = recognition.estimatedFat,
                mealType = _selectedMealType.value,
                source = FoodSource.AI
            )
        )
        _aiRecognition.value = null
    }

    fun onManualLog(name: String, calories: Double, protein: Double, carbs: Double, fat: Double) {
        if (name.isBlank()) return
        addEntry(
            FoodEntry(
                name = name,
                calories = calories,
                protein = protein,
                carbs = carbs,
                fat = fat,
                mealType = _selectedMealType.value,
                source = FoodSource.Manual
            )
        )
    }

    fun onWaterAdd() {
        _waterGlasses.value = (_waterGlasses.value + 1).coerceAtMost(8)
    }

    fun toggleFasting() {
        _fastingActive.value = !_fastingActive.value
        if (_fastingActive.value) {
            viewModelScope.launch {
                while (_fastingActive.value) {
                    delay(3600000)
                    _fastingHours.value = _fastingHours.value + 1
                }
            }
        }
    }

    fun showMealLog() {
        _showMealLog.value = true
    }

    fun dismissMealLog() {
        _showMealLog.value = false
        _aiRecognition.value = null
        _barcodeResult.value = null
        _searchQuery.value = ""
        _barcodeInput.value = ""
    }

    fun showCamera() {
        _showCamera.value = true
    }

    fun dismissCamera() {
        _showCamera.value = false
    }

    private fun addEntry(entry: FoodEntry) {
        val updated = _entries.value + entry
        _entries.value = updated
        refreshInsights()
        dismissMealLog()
    }

    private fun refreshInsights() {
        _insights.value = insightEngine.generateInsights(_entries.value)
    }
}
