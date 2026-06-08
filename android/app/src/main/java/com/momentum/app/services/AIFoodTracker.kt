package com.momentum.app.services

import android.content.Context
import android.graphics.Bitmap
import com.momentum.app.models.AIFoodRecognition
import com.momentum.app.models.BarcodeFoodItem
import com.momentum.app.models.FoodEntry
import com.momentum.app.models.FoodSource
import com.momentum.app.models.MealType
import java.util.UUID

class AIFoodTracker(private val context: Context) {

    data class FoodData(
        val name: String,
        val calories: Double,
        val protein: Double,
        val carbs: Double,
        val fat: Double,
        val alternativeNames: List<String>
    )

    private val foodDatabase = listOf(
        FoodData("Avocado Toast", 380.0, 12.0, 35.0, 22.0, listOf("Smashed avocado", "Toast with egg")),
        FoodData("Oatmeal with Berries", 340.0, 14.0, 52.0, 7.0, listOf("Porridge", "Berry oatmeal")),
        FoodData("Greek Yogurt + Almonds", 210.0, 18.0, 14.0, 10.0, listOf("Yogurt bowl", "Almond parfait")),
        FoodData("Grilled Chicken Salad", 420.0, 38.0, 12.0, 24.0, listOf("Caesar salad", "Chicken salad")),
        FoodData("Salmon Bowl", 580.0, 42.0, 28.0, 30.0, listOf("Salmon rice bowl", "Poke bowl")),
        FoodData("Smoothie Bowl", 350.0, 10.0, 55.0, 12.0, listOf("Acai bowl", "Fruit bowl")),
        FoodData("Turkey Sandwich", 450.0, 32.0, 40.0, 16.0, listOf("Turkey sub", "Club sandwich")),
        FoodData("Vegetable Stir Fry", 320.0, 14.0, 38.0, 14.0, listOf("Tofu stir fry", "Rice bowl")),
        FoodData("Margherita Pizza", 720.0, 28.0, 82.0, 32.0, listOf("Cheese pizza", "Flatbread")),
        FoodData("Chicken Wrap", 480.0, 34.0, 38.0, 20.0, listOf("Burrito", "Chicken roll-up")),
        FoodData("Black Bean Bowl", 440.0, 20.0, 60.0, 12.0, listOf("Veggie bowl", "Bean burrito")),
        FoodData("Steak with Vegetables", 520.0, 46.0, 16.0, 30.0, listOf("Steak plate", "Grilled meat")),
        FoodData("Pasta Primavera", 480.0, 16.0, 64.0, 18.0, listOf("Veggie pasta", "Noodle bowl")),
        FoodData("Tuna Salad", 300.0, 28.0, 12.0, 16.0, listOf("Tuna wrap", "Fish salad")),
        FoodData("Egg & Cheese Bagel", 400.0, 22.0, 44.0, 16.0, listOf("Bagel sandwich", "Breakfast sandwich")),
        FoodData("Chicken Rice Bowl", 550.0, 38.0, 52.0, 16.0, listOf("Teriyaki bowl", "Chicken plate")),
        FoodData("Hummus & Veggies", 280.0, 12.0, 30.0, 16.0, listOf("Veggie platter", "Dip plate")),
        FoodData("Fish Tacos", 420.0, 26.0, 38.0, 20.0, listOf("Taco plate", "Fish plate")),
        FoodData("Lentil Soup", 260.0, 18.0, 40.0, 4.0, listOf("Bean soup", "Vegetable soup")),
        FoodData("Protein Shake", 220.0, 30.0, 18.0, 4.0, listOf("Smoothie", "Protein drink"))
    )

    private val barcodeDatabase = listOf(
        BarcodeFoodItem("4901234567890", "Greek Yogurt", 120.0, 15.0, 8.0, 3.0),
        BarcodeFoodItem("5901234567890", "Protein Bar", 250.0, 20.0, 30.0, 8.0),
        BarcodeFoodItem("6901234567890", "Almond Milk", 60.0, 1.0, 8.0, 2.5),
        BarcodeFoodItem("7901234567890", "Mixed Nuts", 180.0, 6.0, 8.0, 16.0),
        BarcodeFoodItem("8901234567890", "Granola", 210.0, 5.0, 40.0, 4.0),
        BarcodeFoodItem("9901234567890", "Peanut Butter", 190.0, 8.0, 6.0, 16.0),
        BarcodeFoodItem("1911234567890", "Dark Chocolate", 170.0, 2.0, 18.0, 11.0),
        BarcodeFoodItem("2921234567890", "Hummus", 70.0, 2.0, 8.0, 3.5),
        BarcodeFoodItem("3931234567890", "Rice Cakes", 105.0, 2.0, 22.0, 0.5),
        BarcodeFoodItem("4941234567890", "Cottage Cheese", 110.0, 14.0, 4.0, 4.0)
    )

    fun recognizeFoodFromImage(bitmap: Bitmap): AIFoodRecognition {
        val food = foodDatabase.random()
        return AIFoodRecognition(
            name = food.name,
            estimatedCalories = food.calories,
            estimatedProtein = food.protein,
            estimatedCarbs = food.carbs,
            estimatedFat = food.fat,
            confidence = (60.0..95.0).random(),
            alternativeNames = food.alternativeNames
        )
    }

    fun recognizeFood(text: String): AIFoodRecognition? {
        val query = text.lowercase().trim()
        val match = foodDatabase.firstOrNull { food ->
            food.name.lowercase().contains(query) ||
                food.alternativeNames.any { it.lowercase().contains(query) }
        }
        return match?.let {
            AIFoodRecognition(
                name = it.name,
                estimatedCalories = it.calories,
                estimatedProtein = it.protein,
                estimatedCarbs = it.carbs,
                estimatedFat = it.fat,
                confidence = (80.0..99.0).random(),
                alternativeNames = it.alternativeNames
            )
        }
    }

    fun lookupBarcode(code: String): BarcodeFoodItem? {
        return barcodeDatabase.firstOrNull { it.barcode == code }
    }

    fun logFood(
        name: String,
        calories: Double,
        protein: Double,
        carbs: Double,
        fat: Double,
        mealType: MealType = MealType.Snack,
        source: FoodSource = FoodSource.Manual,
        imageUri: String? = null,
        barcode: String? = null
    ): FoodEntry {
        return FoodEntry(
            name = name,
            calories = calories,
            protein = protein,
            carbs = carbs,
            fat = fat,
            mealType = mealType,
            source = source,
            imageUri = imageUri,
            barcode = barcode
        )
    }
}
